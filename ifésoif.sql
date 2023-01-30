DROP DATABASE IF EXISTS ifesoif;
CREATE DATABASE ifesoif;

\c ifesoif

CREATE TABLE client(
       mail VARCHAR(64) PRIMARY KEY,
       nom VARCHAR(20) NOT NULL,
       prenom VARCHAR(20) NOT NULL,
       date_naissance DATE NOT NULL,
       numero_tel VARCHAR(10),
       degre INT DEFAULT 0 NOT NULL,
       date_inscripton DATE DEFAULT NOW(),
       parrain VARCHAR(64) REFERENCES client(mail),
       ci_validee BOOLEAN DEFAULT FALSE,
       --- ci validée => personne majeure
       CHECK ((ci_validee and EXTRACT(YEAR from AGE(NOW(), date_naissance)) >= 18) or (not ci_validee))
);

CREATE TABLE type_produit(
       id_type SERIAL PRIMARY KEY,
       categorie VARCHAR(32) NOT NULL,
       specification VARCHAR(64),
       UNIQUE (categorie, specification)
);

CREATE TABLE label(
       id_label SERIAL PRIMARY KEY,
       nom VARCHAR(128) UNIQUE NOT NULL
);

CREATE TABLE produit(
       id_produit SERIAL PRIMARY KEY,
       id_type INT NOT NULL REFERENCES type_produit(id_type) ON DELETE CASCADE,
       id_label INT REFERENCES label(id_label) ON DELETE SET NULL,
       nom VARCHAR(128) NOT NULL,
       prix FLOAT NOT NULL CONSTRAINT pas_gratuit CHECK (prix > 0),
       degre FLOAT NOT NULL CONSTRAINT pos_degre CHECK (degre >= 0),
       volume INT NOT NULL CONSTRAINT pos_volume CHECK (volume > 0),
       origine VARCHAR(64),
       UNIQUE (id_type, nom, prix, volume, origine)
);

--- Créer un stock indisponible à l'insertion d'un produit
CREATE FUNCTION create_stock() RETURNS trigger AS $emp_stamp$
BEGIN
       INSERT INTO stock(id_produit, etat, quantite) VALUES (NEW.id_produit, 'indisponible', 0);
       RETURN NEW;
END;
$emp_stamp$ LANGUAGE plpgsql;

--- Trigger qui déclenche la màj, a l'insertion
CREATE TRIGGER always_stocked
AFTER INSERT ON produit
FOR EACH ROW EXECUTE PROCEDURE create_stock();

CREATE TABLE prix(
       id_produit INT NOT NULL REFERENCES produit(id_produit) ON DELETE CASCADE,
       date_prix TIMESTAMP DEFAULT NOW(),
       prix FLOAT NOT NULL CONSTRAINT pas_gratuit CHECK (prix > 0),
       PRIMARY KEY (id_produit, date_prix)
);

--- Fonction permettant de garder a jour les nouveaux prix

CREATE FUNCTION keep_track() RETURNS trigger AS $emp_stamp$
BEGIN
       INSERT INTO prix(id_produit, prix) VALUES (NEW.id_produit,NEW.prix);
       RETURN NEW;
END;
$emp_stamp$ LANGUAGE plpgsql;

--- Trigger qui déclenche la màj, a l'insertion ou update
CREATE TRIGGER prix_histo
AFTER INSERT OR UPDATE ON produit
FOR EACH ROW EXECUTE PROCEDURE keep_track();

CREATE TYPE ETAT_STOCK AS ENUM(
       'disponible', 'commande', 'indisponible'
);

CREATE TABLE stock(
       id_produit INT PRIMARY KEY REFERENCES produit(id_produit),
       etat ETAT_STOCK DEFAULT 'indisponible' NOT NULL,
       quantite INT CONSTRAINT pos_qtte CHECK (quantite >= 0) NOT NULL,
       delai INT,
       CHECK (
              (etat = 'disponible' AND quantite > 0 AND delai IS NULL)
              or (etat = 'commande' AND quantite = 0 AND delai IS NOT NULL)
              or (etat = 'indisponible' AND quantite = 0 AND delai IS NULL)
       )     
);

CREATE TABLE article(
       id_article SERIAL PRIMARY KEY,
       id_produit INT REFERENCES produit(id_produit) NOT NULL,
       num_lot VARCHAR(8) NOT NULL,
       date_production DATE NOT NULL
);

--- Met à jour le stock en incrémentant sa valeur
CREATE FUNCTION increment_stock() RETURNS trigger AS $emp_stamp$
BEGIN
       UPDATE stock s SET quantite = (s.quantite + 1), etat = 'disponible', delai = NULL
       WHERE s.id_produit = NEW.id_produit;
       RETURN NEW;
END;
$emp_stamp$ LANGUAGE plpgsql;

--- Trigger qui déclenche la màj, a l'insertion
CREATE TRIGGER increment_stock
AFTER INSERT ON article
FOR EACH ROW EXECUTE PROCEDURE increment_stock();

CREATE TABLE panier(
       id_panier SERIAL PRIMARY KEY
);

CREATE TABLE produit_panier(
       id_produit INT REFERENCES produit(id_produit),
       id_panier INT REFERENCES panier(id_panier) ON DELETE CASCADE,
       quantite INT NOT NULL,
       PRIMARY KEY (id_produit, id_panier)
);

--- Quand on met a jour une valeur, on supprime tout les quantites nulles du panier
CREATE RULE qtte_not_null AS ON UPDATE TO 
produit_panier DO INSTEAD 
DELETE FROM produit_panier p where p.quantite = 0;

CREATE TABLE commande(
       id_commande SERIAL PRIMARY KEY,
       mail VARCHAR(64) REFERENCES client(mail) NOT NULL,
       date_commande DATE DEFAULT NOW(),
       adresse_livraison VARCHAR(64) NOT NULL,
       adresse_facturation VARCHAR(64),
       cheque BOOLEAN DEFAULT FALSE,
       payee BOOLEAN DEFAULT FALSE
);

CREATE TYPE ETAT_ARTICLE AS ENUM(
       'livraison','livré','attente','preparation','annulé'
);

CREATE TABLE article_commande(
       id_ac SERIAL PRIMARY KEY,
       id_commande INT REFERENCES commande(id_commande) NOT NULL,
       id_article INT REFERENCES article(id_article) NOT NULL,
       etat ETAT_ARTICLE DEFAULT 'attente',
       date_annulation DATE,
       CHECK (
              --- livraison ou livré => id_ac dans article_livraison
              ((etat = 'livraison' OR etat = 'livré') 
              AND date_annulation IS NULL
              ) OR (etat = 'attente' OR etat = 'preparation') 
              --- annulé => date_annulation non nulle
              OR (etat = 'annulé' AND date_annulation IS NOT NULL)
       )
);

CREATE FUNCTION keep_degre_alive() RETURNS trigger AS $emp_stamp$
BEGIN     
       WITH client_now AS (
                     SELECT mail FROM commande c
                     WHERE c.id_commande = NEW.id_commande
              )
       UPDATE client SET degre = (
              SELECT (coalesce(sum(p.degre), 0) + (
                     SELECT degre FROM produit p
                     JOIN article a ON p.id_produit = a.id_produit
                     WHERE a.id_article = NEW.id_article
              ))
              /
              (count(cli.mail) + 1)
              FROM client_now cli
              JOIN commande c ON c.mail = cli.mail
              JOIN article_commande ac ON ac.id_commande = c.id_commande
              JOIN article a ON a.id_article = ac.id_article
              JOIN produit p ON p.id_produit = a.id_produit
       ) WHERE client.mail = (
              SELECT mail FROM client_now
       );
       RETURN NEW;
END;
$emp_stamp$ LANGUAGE plpgsql;

--- Trigger qui déclenche la màj, avant l'insertion
CREATE TRIGGER keep_degre_alive
BEFORE INSERT ON article_commande
FOR EACH ROW EXECUTE PROCEDURE keep_degre_alive();

--- Met à jour le stock en décrementant sa valeur
CREATE FUNCTION decrement_stock() RETURNS trigger AS $emp_stamp$
BEGIN
       --- si la décrementation du stock passe le stock à 0
       IF 
              (SELECT s.quantite - 1 
              FROM stock s
              JOIN article a ON s.id_produit = a.id_produit
              WHERE a.id_article = NEW.id_article) 
              <= 0
       THEN
       --- alors on rend l'article indisponible (et c'est à un maintainer de changer l'état en commande si tel est le cas)
              UPDATE stock chef SET quantite = 0, etat = 'indisponible', delai = NULL
              FROM stock s JOIN article a ON s.id_produit = a.id_produit 
              WHERE a.id_article = NEW.id_article AND chef.id_produit = s.id_produit;
       ELSE
       --- sinon on décremente
              UPDATE stock chef SET quantite = (s.quantite - 1), etat = 'disponible', delai = NULL
              FROM stock s JOIN article a ON s.id_produit = a.id_produit 
              WHERE a.id_article = NEW.id_article AND chef.id_produit = s.id_produit;
       END IF;
       RETURN NEW;
END;
$emp_stamp$ LANGUAGE plpgsql;

--- Trigger qui déclenche la màj, a l'insertion
CREATE TRIGGER decrement_stock
AFTER INSERT ON article_commande
FOR EACH ROW EXECUTE PROCEDURE decrement_stock();

CREATE FUNCTION increment_stock_annul() RETURNS trigger AS $emp_stamp$
BEGIN
       IF NEW.etat == 'annulé' THEN
              UPDATE stock chef SET quantite = (s.quantite + 1), etat = 'disponible', delai = NULL
              FROM stock s JOIN article a ON s.id_produit = a.id_produit 
              WHERE a.id_article = NEW.id_article  AND chef.id_produit = s.id_produit;
       END IF;
       RETURN NEW;
END;
$emp_stamp$ LANGUAGE plpgsql;

CREATE TRIGGER increment_stock_annul
AFTER UPDATE ON article_commande
FOR EACH ROW EXECUTE PROCEDURE increment_stock_annul();

CREATE TABLE remboursement(
       id_remboursement SERIAL PRIMARY KEY,
       id_ac INT REFERENCES article_commande(id_ac),
       date_remboursement DATE NOT NULL DEFAULT NOW()
);

CREATE TABLE article_livraison(
       id_ac INT REFERENCES article_commande(id_ac) PRIMARY KEY,
       date_expedition DATE NOT NULL DEFAULT NOW(),
       date_livraison DATE,
       --- date_livraison != null => date_expedition <= date_livraison
       CHECK ((date_livraison IS NOT NULL AND date_expedition <= date_livraison
       AND date_livraison <= NOW())
       OR date_livraison IS NULL)
);

CREATE TABLE article_retourne(
       id_ac INT REFERENCES article_commande(id_ac) PRIMARY KEY,
       date_retour DATE NOT NULL DEFAULT NOW(),
       effectif BOOLEAN DEFAULT FALSE,
       raison VARCHAR(64),
       id_remboursement INT REFERENCES remboursement(id_remboursement),
       --- date_retour > date_livraison
       CHECK (
       --- effectif vrai => id_remboursement non null
       (effectif = TRUE AND id_remboursement IS NOT NULL) OR (effectif = FALSE)
       )
);

CREATE FUNCTION increment_stock_retour() RETURNS trigger AS $emp_stamp$
BEGIN
       UPDATE stock chef SET quantite = (s.quantite + 1), etat = 'disponible', delai = NULL
       FROM stock s JOIN article a ON s.id_produit = a.id_produit 
       WHERE a.id_article = NEW.id_article AND chef.id_produit = s.id_produit;
       RETURN NEW;
END;
$emp_stamp$ LANGUAGE plpgsql;

CREATE TRIGGER increment_stock_retour
AFTER UPDATE ON article_retourne
FOR EACH ROW EXECUTE PROCEDURE increment_stock_retour();

CREATE TABLE avis(
       mail VARCHAR(64) REFERENCES client(mail),
       id_produit INT REFERENCES produit(id_produit),
       commentaire TEXT,
       note INT NOT NULL CONSTRAINT note_etoile CHECK (note > 0 AND note <= 5),
       PRIMARY KEY(mail,id_produit)
);

--- un triger qui vérifie que le client a déjà acheté le produit sur lequel il aimerait mettre un avis, et qu'il l'a reçu
CREATE FUNCTION has_bought() RETURNS trigger AS $emp_stamp$
BEGIN
       IF NOT EXISTS (
              SELECT *
              FROM commande c
              JOIN article_commande ac ON c.id_commande = ac.id_commande
              JOIN article_livraison al ON ac.id_ac = al.id_ac
              JOIN article a ON a.id_article = ac.id_article
              JOIN produit p ON p.id_produit = a.id_produit
              WHERE mail = NEW.mail
              AND p.id_produit = NEW.id_produit
              AND date_livraison IS NOT NULL
       ) THEN 
              RAISE EXCEPTION 'Impossible de mettre un avis sur un article non commandé'; 
       END IF; 
       return NEW; 
END;
$emp_stamp$ LANGUAGE plpgsql;

CREATE TRIGGER has_bought
BEFORE INSERT ON avis
FOR EACH ROW EXECUTE PROCEDURE has_bought();
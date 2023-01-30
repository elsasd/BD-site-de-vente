\copy client(mail, nom, prenom, date_naissance) FROM 'data/client.csv' DELIMITER ';' CSV HEADER;

\copy type_produit(categorie, specification) FROM 'data/type.csv' DELIMITER ';' CSV

\copy label(nom) FROM 'data/label.csv' DELIMITER ';' CSV;
--- on import les produits
\copy produit(id_type, id_label, nom, prix, degre, volume, origine) FROM 'data/produit.csv' DELIMITER ';' CSV;

--- on va importer les bières dans une table temporaire
CREATE TEMP TABLE temp_biere(
    row INT NOT NULL,
    percentage FLOAT,
    ibv FLOAT,
    id INT UNIQUE NOT NULL,
    name VARCHAR(128) NOT NULL,
    style VARCHAR(128),
    brewery_id INT NOT NULL,
    ounces FLOAT NOT NULL
);

\copy temp_biere FROM 'data/beers.csv' DELIMITER ',' CSV HEADER

--- On insère tous les nouveaux types de bière
INSERT INTO type_produit(categorie, specification)
SELECT 'Bière', style FROM temp_biere ON CONFLICT DO NOTHING;

--- puis les brewery dans une autre table temporaire
CREATE TEMP TABLE temp_breweries(
    brewery_id INT NOT NULL,
    name VARCHAR(128) NOT NULL,
    city VARCHAR(128) NOT NULL,
    state VARCHAR(3) NOT NULL
);

\copy temp_breweries FROM 'data/breweries.csv' DELIMITER ',' CSV HEADER;

--- on insère les breweries dans les labels
INSERT INTO label(nom) 
SELECT name 
FROM temp_breweries 
ON CONFLICT DO NOTHING;

--- Puis on insère les bières
INSERT INTO produit(id_type, id_label, nom, prix, degre, volume, origine)
SELECT
(
    SELECT id_type 
    FROM type_produit
    WHERE categorie = 'Bière'
    AND specification = style
), --- selectionner le type correspondant
(
    SELECT id_label
    FROM label
    WHERE nom = (
        SELECT name
        FROM temp_breweries brew
        WHERE brew.brewery_id = temp_biere.brewery_id
    ) --- selectionner le label par nom via l'id de la brewerie
), --- selectionner le label correspondant
name,
(
    SELECT floor(random() * (12.5 - 3.5 + 1) + 3.5)::int
), --- generer un prix aléatoire
ROUND((percentage * 100)::numeric,1),
ROUND(ounces / 0.033814), --- ounces -> mL
(
    SELECT brew.city || ',' || brew.state
    FROM temp_breweries brew
    WHERE brew.brewery_id = temp_biere.brewery_id
) --- selectionner l'origine dans le label
FROM temp_biere 
WHERE EXISTS ( --- on insère seulement celles qui ont un type
    SELECT id_type 
    FROM type_produit
    WHERE categorie = 'Bière'
    AND specification = style
)
ON CONFLICT DO NOTHING;

DROP TABLE temp_biere;
DROP TABLE temp_breweries;

--- on fait le reste

\copy article(id_produit, num_lot, date_production) FROM 'data/article.csv' DELIMITER ';' CSV;

\copy commande(mail, adresse_livraison, adresse_facturation) FROM 'data/commande.csv' DELIMITER ';' CSV;

\copy article_commande(id_commande, id_article) FROM 'data/article_commande.csv' DELIMITER ';' CSV;

\copy remboursement(id_ac) FROM 'data/remboursement.csv' DELIMITER ';' CSV;

\copy avis(mail, id_produit, commentaire, note) FROM 'data/avis.csv' DELIMITER ';' CSV;

--- on envoie les modifieurs aléatoire
\i scripts/sqlgens/rdcli.sql
\i scripts/sqlgens/stock_commande.sql
\i scripts/sqlgens/parrain.sql
\i scripts/sqlgens/whisky.sql

\copy client(mail, nom, prenom, date_naissance,numero_tel,degre, date_inscripton, parrain, ci_validee) FROM 'data/client.csv' DELIMITER ';' CSV HEADER;

\copy type_produit(id_type, categorie, specification) FROM 'data/type.csv' DELIMITER ';' CSV HEADER;

\copy label(id_label, nom) FROM 'data/label.csv' DELIMITER ';' CSV HEADER;

\copy produit(id_produit, id_type, id_label, nom, prix, degre, volume, origine) FROM 'data/produit.csv' DELIMITER ';' CSV HEADER;

\copy article(id_produit, num_lot, date_production) FROM 'data/article.csv' DELIMITER ';' CSV;

\copy commande(mail, adresse_livraison, adresse_facturation) FROM 'data/commande.csv' DELIMITER ';' CSV;

\copy article_commande(id_commande, id_article) FROM 'data/article_commande.csv' DELIMITER ';' CSV;

\copy remboursement(id_ac) FROM 'data/remboursement.csv' DELIMITER ';' CSV;

\copy article_livraison(id_ac, date_livraison) FROM 'data/article_livraison.csv' DELIMITER ';' CSV HEADER;

\copy avis(mail, id_produit, commentaire, note) FROM 'data/avis.csv' DELIMITER ';' CSV;

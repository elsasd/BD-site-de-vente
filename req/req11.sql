--- La bière préférée des -25 ans
\echo #11 La bière préferée des moins de 25

WITH binouz AS (
    SELECT specification, client.mail
    FROM type_produit
    JOIN produit ON type_produit.id_type = produit.id_type
    JOIN article ON article.id_produit = produit.id_produit
    JOIN article_commande ON article_commande.id_article = article.id_article
    JOIN commande ON commande.id_commande = article_commande.id_commande
    JOIN client ON client.mail = commande.mail
    WHERE categorie = 'Bière'
    AND EXTRACT(year from NOW()) - EXTRACT(year FROM date_naissance) <= 25
)
SELECT specification as "TOP #1"
FROM binouz
GROUP BY specification
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM binouz
    GROUP BY specification
);
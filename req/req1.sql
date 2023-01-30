--- Une requête portant sur trois tables
--- Tous les produits commandés par les clients dont le degre est > 50
\echo #1 Tous les produits commandés par les clients dont le degre est > 50
SELECT distinct P.nom, P.degre as Nom_boisson
FROM produit P, article A, article_commande AC
WHERE P.id_produit = A.id_produit 
AND A.id_article = AC.id_article
AND P.degre > 50;
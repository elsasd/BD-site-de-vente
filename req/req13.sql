-- La catégorie de boissons préférée des plus de 40ans
\echo #13 La catégorie de boissons préférée des plus de 40 ans

WITH TAB(categorie, compte) AS (
    SELECT T.categorie, COUNT(*) AS cout 
    FROM article_commande AC 
    JOIN article A 
    ON AC.id_article = A.id_article 
    JOIN produit P 
    ON A.id_produit = P.id_produit 
    JOIN type_produit T 
    ON P.id_type = T.id_type 
    JOIN commande Co
    ON AC.id_commande = Co.id_commande
    JOIN client Cl
    ON Cl.mail = Co.mail
    WHERE DATE_PART('year', CURRENT_DATE::date) - DATE_PART('year', Cl.date_naissance::date) >=40
    GROUP BY T.categorie
) 
SELECT categorie
FROM tab 
WHERE compte 
= (
    SELECT MAX(compte)
    FROM tab
);
-- Les client.e.s qui ont déjà commandé, mais jamais de whisky
\echo #15 Les client.e.s qui ont déjà commandé, mais jamais de whisky

SELECT DISTINCT mail
FROM commande
EXCEPT
SELECT mail
FROM commande
WHERE EXISTS (
    SELECT *
    FROM article_commande
    JOIN article ON article.id_article = article_commande.id_article
    JOIN produit ON produit.id_produit = article.id_produit
    JOIN type_produit ON type_produit.id_type = produit.id_type
    WHERE commande.id_commande = article_commande.id_commande
    AND categorie = 'Spiritueux'
    AND specification = 'Whisky'
);
--- Une sous-requête dans le WHERE
--- Les noms des produits qui ont au moins un avis

\echo #5 Les noms des produits qui ont un avis
SELECT nom
FROM produit p
WHERE p.id_produit
IN (
    SELECT id_produit
    FROM avis
);
--- Deux agrégats necessitant GROUP BY et HAVING
--- La (ou les) types de boissons qui ont le degré moyen maximal

\echo #6 La (ou les) types de boissons qui ont le degré moyen maximal
WITH type_and_produit AS (
     SELECT categorie, specification, degre
     FROM type_produit t
     JOIN produit p ON t.id_type = p.id_type
)
SELECT categorie, specification, AVG(degre)
FROM type_and_produit
GROUP BY (categorie, specification)
HAVING AVG(degre) >= ALL (
       SELECT AVG(degre)
       FROM type_and_produit
       GROUP BY (categorie, specification)
);
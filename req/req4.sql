--- Une sous-requête dans le FROM
--- Le nom de tous les Rhums et Gins

\echo #4 Le nom de tous les Rhums et Gins
SELECT specification || ' : ' || nom as "Rhum ou gin"
FROM (
     SELECT nom, specification
     FROM produit p
     JOIN type_produit t
     ON t.id_type = p.id_type
) AS boisson
WHERE specification = 'Rhum'
OR specification = 'Gin';
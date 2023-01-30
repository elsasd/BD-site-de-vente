-- Le produit avec la plus grande différence de note
\echo #14 Le produit avec la plus grande différence de note

SELECT nom, MAX(note), MIN(note)
FROM produit
NATURAL JOIN avis
GROUP BY id_produit
HAVING MAX(note) - MIN(note) >= ALL (
    SELECT MAX(note) - MIN(note)
    FROM avis
    GROUP BY id_produit
);

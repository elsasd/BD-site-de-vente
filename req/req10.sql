--- deux requêtes qui renverraient le même résultat si vos tables de contenaient pas de nulls, 
--- mais qui renvoient des résultats différents ici 
\echo #10 Les parrains qui ont exactement un filleul

\echo Methode 1
SELECT mail
FROM client c
WHERE (
    SELECT COUNT(*)
    FROM client c2
    WHERE c.mail = c2.parrain
) = 1;

\echo Methode 2
SELECT mail as "s'il vous plait, faites attention aux nulls..."
FROM client c
WHERE NOT EXISTS (
    SELECT *
    FROM client c2
    WHERE c.parrain = c2.parrain
);

\echo Correction de la seconde méthode pour fonctionner dans le cas général (dans l esprit du cours :-))
SELECT DISTINCT parrain
FROM client c
WHERE parrain IS NOT NULL
--- existe pas un autre client avec le même parrain
AND NOT EXISTS (
    SELECT *
    FROM client c2
    WHERE c2.parrain IS NOT NULL
    AND c.mail <> c2.mail
    AND c.parrain = c2.parrain
);
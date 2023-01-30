--- Une requête impliquant le calcul de deux agrégats
--- Le parrain dont la somme des degrés des filleuls est la plus grande

\echo #7 Le parrain dont la somme des degrés des filleuls est la plus grande
WITH parrains AS (
     SELECT DISTINCT c1.mail, SUM(c2.degre) AS degre
     FROM client c1
     JOIN client c2 ON c1.mail = c2.parrain
     GROUP BY c1.mail
)
SELECT mail, degre
FROM parrains
WHERE degre >= (
      SELECT MAX(degre)
      FROM parrains
);
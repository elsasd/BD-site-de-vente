--- Sous-requête corrélée
--- Les parrains qui ont plusieurs filleuls
\echo #3 Les parrains qui ont plusieurs filleuls
SELECT DISTINCT parrain
FROM client C1
WHERE parrain
IN (
   SELECT parrain
   FROM client C2
   WHERE C1.mail <> C2.mail
);
-- Le degré moyen des client.e.s (ayant déjà commandé) entre 20 et 30 ans
\echo #17 Le degré moyen des clients (ayant déjà commandé) entre 20 et 30 ans

SELECT ROUND(AVG(C.degre), 2)
FROM client C 
WHERE DATE_PART('year', CURRENT_DATE::date) - DATE_PART('year', C.date_naissance::date) 
BETWEEN 20 AND 30
AND C.mail
IN (
    SELECT DISTINCT mail 
    FROM commande
);
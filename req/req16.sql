-- La ville où il y a le plus de personnes qui ont commandé
\echo #16 La ville ou il y a le plus de personnes qui ont commandé

WITH client_ville AS (
    SELECT mail, 
    SUBSTRING(
        adresse_livraison, 
        LENGTH(adresse_livraison) - POSITION(',' in REVERSE(adresse_livraison)) + 3,
        LENGTH(adresse_livraison)
    ) as ville
    FROM commande
)
SELECT ville
FROM client_ville
GROUP BY ville
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM client_ville
    GROUP BY ville
);
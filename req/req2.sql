--- Jointure d'une table à elle même
--- Les client.e.s et leurs parrains

\echo #2 Les clients et leurs parrains
SELECT C1.mail AS parrainé, C2.mail AS parrain
FROM client C1
JOIN client C2
ON C1.parrain = C2.mail;
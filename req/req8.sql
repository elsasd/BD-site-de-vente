--- Deux requêtes  équivalentes exprimant une condition de totalité, l’une avec des sous requêtes corrélées et l’autre avec de l’agrégation
--- Les client.e.s qui ont commandé tous les genres de whisky

\echo #8 Les client.e.s qui ont commandé tous les genres de whisky

--- SOUS REQUETE CORELEE
\echo Sous requête corélée
--- Les clients tels qu'il n'existe pas
SELECT mail FROM client c WHERE NOT EXISTS (
       -- De whisky
       SELECT *
       FROM produit p
       JOIN type_produit t ON p.id_type = t.id_type
       WHERE t.specification = 'Whisky'
       -- Qui ne soit pas dans liste des whiskys
       -- commandé par ce même client
       AND p.id_produit NOT IN (
       	   -- AYEZ CRAINTE DU MEGA JOIN
	   -- (désolé.e.s c'était le seul moyen de faire un lien entre
	   -- une commande et un type de produit)
       	   SELECT p2.id_produit
	   FROM commande com
	   JOIN article_commande ac ON com.id_commande = ac.id_commande
	   JOIN article ar ON ar.id_article = ac.id_article
	   JOIN produit p2 ON p2.id_produit = ar.id_produit
	   JOIN type_produit t2 ON t2.id_type = p2.id_type
	   WHERE com.mail = c.mail
	   AND t2.specification = 'Whisky'
       )
);

--- AGREGATION
\echo Agrégation
SELECT c.mail
FROM client c
JOIN commande com ON c.mail = com.mail
JOIN article_commande ac ON com.id_commande = ac.id_commande
JOIN article ar ON ar.id_article = ac.id_article
JOIN produit p ON p.id_produit = ar.id_produit
JOIN type_produit t ON t.id_type = p.id_type
WHERE t.specification = 'Whisky'
GROUP BY c.mail HAVING COUNT(distinct p.id_produit) = (
      SELECT COUNT(*)
      FROM produit p2
      JOIN type_produit t2 ON p2.id_type = t2.id_type
      WHERE t2.specification='Whisky'
);
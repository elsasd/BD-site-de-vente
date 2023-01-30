--- les client.e.s qui ont demandé le remboursement de tous leurs articles commandés

\echo #18 Les client.e.s qui ont demandé le remboursement de tous leurs articles commandés

--- les client.e.s tq il n'existe pas un de leurs articles commandés qui n'apparaisse pas dans la table des remboursements
SELECT DISTINCT mail
FROM commande c
WHERE NOT EXISTS (
    SELECT *
    FROM article_commande ac
    WHERE ac.id_commande = c.id_commande
    AND NOT EXISTS (
        SELECT *
        FROM remboursement r
        WHERE r.id_ac = ac.id_ac
    )
);
--- Le pourcentage de client.e.s qui boivent du rosé (parmis ceux qui ont au moins une commande)
\echo #12 Le pourcentage de gens qui boivent du rosé

WITH client_boisson AS (
    SELECT mail, categorie, specification
    FROM type_produit tp
    JOIN produit p ON p.id_type = tp.id_type
    JOIN article a ON a.id_produit = p.id_produit
    JOIN article_commande ac ON a.id_article = ac.id_article
    JOIN commande c ON ac.id_commande = c.id_commande
)
SELECT ROUND(
   (
       COUNT(DISTINCT mail) :: real
        /
        (SELECT COUNT(DISTINCT mail) FROM commande) :: real
    ) :: numeric * 100, 2
) || ' %' as "Pourcentage"
FROM client_boisson
WHERE categorie = 'Vin'
AND specification = 'Rosé';
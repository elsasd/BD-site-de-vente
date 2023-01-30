--- une jointure externe (LEFT JOIN, RIGHT JOIN ou FULL JOIN) 

\echo #9 Les labels qui ont produit plus de 10 produits et le nombre de produit qu ils produisent

SELECT COALESCE(label.nom, 'Label inconnu') as "Nom label"
, COUNT(produit.nom) as "Nombre produits" 
FROM produit 
LEFT JOIN label ON produit.id_label = label.id_label
GROUP BY label.nom
HAVING COUNT(produit.nom) >= 10
ORDER BY COUNT(produit.nom) DESC
;
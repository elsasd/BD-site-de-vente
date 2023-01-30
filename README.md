# IFESOIF
### Membres
* 71618550 Elsa SANTOS DUARTE 
* 71805512 Eugène VALTY 

### Initialisation
Pour remplir la base de donnée il faut exécuter depuis psql la commande `\i ifesoif.sql` puis `\i fill.sql`.  
* Le fichier `ifesoif.sql` contient les requête de créations de tables et de triggers.
* Le fichier `fill.sql` contient les commandes permettant de copier les données depuis les `.csv` jusque dans les tables créées au préalable.

### Structure
* **/data**  
`/data` contient tous les `.csv` nécessaires à remplir la BDD. Il contient aussi un sous dossier, `data_old/`, contenant les anciens `.csv`, ainsi que l'ancien `fill.sql` qui permettait de remplir la BDD via différents `.csv` grâce à des tables temporaires et des fichiers `.sql` d'update. Ces tables ont ensuite été réexportée en `.csv` pour avoir des données plus propres.
* **/scripts**  
`/scripts` contient deux sous-dossiers : `scrapper/` et `sqlgens/`.
    - `scrapper/` contient un programme `NodeJS` réalisé par nos soins, utilisant `puppeter` et scrappant une page d'un site web de vente d'alcools. Cela nous a permis de récuperer beaucoup de donneés (~3100) sur des articles alcoolisés.
    - `sqlgens/` contient plusieurs programmes `python` générant des données pseudo-aléatoires à partir des données disponibles dans `/data`.
* **/req**  
`/req` contient toutes les requêtes sql, dans les fichiers de la forme `req[n].sql` avec `[n]` un entier. `req.sql` exécute toutes les requêtes en une fois.

### Divers
* `bd-modif.png` contient le schéma E/R validé par notre chargée de TD. Une nouvelle version légerement modifée, `bd-final.png`, correspondant à la structure de notre BDD à la fin est aussi disponible.
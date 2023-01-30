import random

prod_file = "../../data/produit.csv"
client_file = "../../data/client.csv"
dest_file = "./whisky.sql"
type_file = "../../data/type.csv"
art_file = "../../data/article.csv"
cmd_file = "../../data/commande.csv"

if __name__ == "__main__":
    d = dict()
    mail = ""
    i = 1
    t = 1
    with open(type_file,"r") as f:
        for l in f.readlines()[1:]:
            h = l.split(';')
            d[int(h[0])] = h[-1].strip()
            t += 1
    with open(client_file, "r") as f:
        f.readline()
        mail = f.readline().split(';')[0]
    with open(prod_file, "r") as f, open(dest_file,"w") as w, open(art_file,"r") as art, open(cmd_file,"r") as cmd:
        id_art=len(art.readlines())+1
        art.close()
        id_cmd=len(cmd.readlines())+1
        cmd.close()
        w.write("INSERT INTO commande(mail, adresse_livraison) VALUES ('"+mail+"','12 rue de jspquoi, 75018, Paris');\n")
        for l in f.readlines()[1:]:
            h = l.split(';')
            if d[int(h[1])] == 'Whisky':
                w.write("INSERT INTO article(id_produit, num_lot, date_production) VALUES ('" + h[0] + "', 'WISKGOOD', NOW());\n")
                w.write("INSERT INTO article_commande(id_commande, id_article) VALUES ('"+str(id_cmd)+"', '"+str(id_art)+"');\n")
                id_art += 1
            i += 1
            

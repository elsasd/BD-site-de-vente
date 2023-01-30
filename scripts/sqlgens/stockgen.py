import random

prod_file = "../../data/produit.csv"
dest_file = "stock_commande.sql"
article_file = "../../data/article.csv"

etats = ['disponible', 'commande', 'indisponible']

MAX_QTTY = 500
MAX_DELAY = 60
LOT_QUANTITY = (1, 6)

def rd_lot(s):
    n = ''.join([str(random.randint(0,9)) for _ in range(8)])
    while n in s:
        n = ''.join([str(random.randint(0,9)) for _ in range(8)])
    return n

def rd_date():
    return str(random.randint(1, 28)) + '/' + str(random.randint(1,12)) + '/' + str(random.randint(1970, 2021))


if __name__ == "__main__":
    generated_lot = set()

    with open(prod_file, "r") as f, open(dest_file,"w") as w, open(article_file, "w") as a:
        for i in f.readlines()[1:]:
            id_produit = int(i.split(';')[0])
            
            etat = random.sample(etats, 1)[0]
            if etat == 'disponible':
                qtty = random.randint(50, MAX_QTTY)

                while qtty > 0:
                    lot_nbr = rd_lot(generated_lot)
                    generated_lot.add(lot_nbr)

                    lot_size = min(qtty, random.randint(LOT_QUANTITY[0], LOT_QUANTITY[1]))

                    lot_date = rd_date()

                    for j in range(lot_size):
                        a.write(str(id_produit) + ';' + lot_nbr + ';' + lot_date + '\n')

                    qtty -= lot_size
            elif etat == 'commande':
                delai = random.randint(1, MAX_DELAY)
                w.write("UPDATE stock SET etat = 'commande', delai = " + str(delai) + " WHERE id_produit = " + str(id_produit) + ';\n')
                

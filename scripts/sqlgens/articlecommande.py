import random

prod_file = "../../data/commande.csv"
preciso_de_este_file = "../../data/article.csv"
dest_file = "../../data/article_commande.csv"
# 1 -> 24

escogidos = []
if __name__ == "__main__":
    r = open(prod_file, "r")
    src = open(preciso_de_este_file, "r")
    w = open(dest_file, "w")
    n = len(r.readlines())
    n_src = len(src.readlines())
    
    for i in range (n) :
        nb_art = random.randint(1,10)
        for j in range (nb_art) :
            rand = random.randint(1, n_src)
            while (rand in escogidos):
                rand = random.randint(1, n_src)
            escogidos = escogidos + [rand]
            w.write(str(i+1)+";"+str(rand)+"\n")
            
    r.close()
    w.close()
    src.close()


import random

prod_file = "../../data/client.csv"
dest_file = "./parrain.sql"

parrain_percent = .15;

if __name__ == "__main__":
    generated_lot = set()
    parrain_lot = set()

    with open(prod_file, "r") as f, open(dest_file,"w") as w:
        i = 0
        f.readline();
        for l in f.readlines():
            h = l.split(";")
            email = h[0]
            generated_lot.add(email)
            if i < 10:
                parrain_lot.add(email)
                i += 1
        for _ in range(int(len(generated_lot) * parrain_percent)):
            cli = random.choice(tuple(generated_lot))
            parrain = random.choice(tuple(parrain_lot))
            while parrain == cli:
                parrain = random.choice(tuple(parrain_lot))
            w.write("UPDATE client SET parrain = '" + parrain + "' WHERE mail = '" + cli + "';\n")

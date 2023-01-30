import random

client_file = "../../data/client.csv"
rd_percentage = 75;

def rd_phone_number():
    return '0' + str(random.randint(4,9)) + ''.join([str(random.randint(0,8)) for _ in range(8)])

def rd_ci_valide():
    return str(random.randint(0,1) == 0).upper()

categories = [('numero_tel', rd_phone_number), ('ci_validee', rd_ci_valide)]

if __name__ == "__main__":
    with open(client_file, "r") as f, open("rdcli.sql","w") as w:
        for l in f.readlines():
            # On selectionne aléatoirement les clients (~ `rd_percentage`%)
            if random.randint(0, 100) <= rd_percentage:
                h = list(map(lambda x : x.strip(), l.split(';')))
                
                col = random.sample(categories, 1)[0]
                w.write('UPDATE client SET ' + col[0] + ' = ' + "'" + col[1]() + "'" + ' WHERE mail = ' + "'" + h[0] + "'" + ';\n')
    

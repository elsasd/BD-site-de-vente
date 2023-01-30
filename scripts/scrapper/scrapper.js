// Import de puppeteer
const puppeteer = require("puppeteer")
const fs = require('fs');

let WAIT_TIME = 1000;

if (fs.existsSync('../data/type.csv')) fs.unlinkSync('../data/type.csv');
if (fs.existsSync('../data/produit.csv')) fs.unlinkSync('../data/produit.csv');
if (fs.existsSync('../data/label.csv')) fs.unlinkSync('../data/label.csv');

let URLS = [{
    'link': "https://www.vinatis.com/achat-vin#p1&n15&t7&f[]27[]11425:f[]27[]11427",
    'nb-pages': 250,
    'type': 'Spiritueux & Vin'
},
];

const write_drinks = function (drink) {
    fs.appendFileSync('../data/type.csv', drink)
}

const write_product = function (id, id_label, nom_produit, price, degree, volume, origine) {
    fs.appendFileSync('../data/produit.csv',
        id + ';' + id_label + ';' + nom_produit + ';' + price + ';' + degree + ';' + volume + ';' + origine + '\n'
    );
}

const write_label = function (label) {
    fs.appendFileSync('../data/label.csv', label + '\n')
}

let products = []
let labels = []

const getData = async (link, nb_pages) => {
    // 1 - Créer une instance de navigateur
    const browser = await puppeteer.launch({ headless: false })
    const page = await browser.newPage()

    // 2 - Naviguer jusqu'à l'URL cible
    await page.goto(link)

    for (let i = 0; i < nb_pages; i++) {
        await page.waitForSelector('.col-lg-4.col-md-6.col-xs-12.bloc-product-full.full-height.padding-10');

        let p = await page.evaluate(() => {
            let n = []
            let a = []
            let name = document.getElementsByClassName('col-lg-7 col-md-7 col-xs-7 no-padding full-height')
            for (let i = 0; i < name.length; i++) {
                let val = name[i].getElementsByClassName('taille-xxs color-gray-darker text-align-left')[0].textContent.trim()

                if (val.split('/').length < 3) continue;

                let h = val.split('/');

                let offset = 0;
                if (!h[h.length - 1].includes('vol')) {
                    offset = -1
                }

                let categorie = h[h.length - 2 + offset].trim()
                let nom = h[0].trim()
                let bonus = ""
                if (nom.includes(' ')) {
                    bonus = nom.slice(nom.indexOf(' ') + 1, nom.length)
                    nom = nom.slice(0, nom.indexOf(' '))
                }

                let type_val = ''
                let label = undefined
                let origine = ''

                if (nom === 'Spiritueux') {
                    type_val = nom + ';' + categorie + '\n'
                    origine = h[1].trim() + ((h.length > 4) ? ',' + h[2].trim() : '')
                } else {
                    type_val = nom + ';' + bonus + '\n'
                    label = h.length > 3 ? categorie : undefined
                    origine = h[1].trim()
                }

                if (!n.includes(type_val)) {
                    n.push(type_val);
                }

                let degree = parseFloat(h.filter((e) => e.includes('vol'))[0].trim(0, -5).replace(',', '.'))

                let nom_produit = name[i]
                    .getElementsByClassName('product-title')[0].textContent.trim()

                if (!name[i].getElementsByClassName('btn-sm bg-transparent color-gray border border-gray no-pointer inline-block')[0]) continue;
                let volume =
                    name[i].getElementsByClassName('btn-sm bg-transparent color-gray border border-gray no-pointer inline-block')[0].textContent.trim()
                volume = parseFloat(volume.slice(0, volume.length - 1).replace(',', '.').trim()) * 1000

                if (!name[i].getElementsByClassName('our_price_display')[0]) continue;
                let price = name[i].getElementsByClassName('our_price_display')[0].textContent.trim()
                price = price.slice(0, price.indexOf('€')).replace(',', '.').trim()

                if (price.includes(' ')) continue

                a.push({
                    'nom_produit': nom_produit,
                    'price': price,
                    'volume': volume,
                    'val': type_val,
                    'degree': degree,
                    'label': label,
                    'origine': origine
                })

            }
            return {
                'n': n,
                'a': a
            };
        })

        for (let e of p.n) {
            if (!products.includes(e)) {
                products.push(e);
                write_drinks(e);
            }
        }

        for (let a of p.a) {
            a['id'] = products.indexOf(a.val) + 1
            if (a['id']) {
                let id_label = ''
                if (a.label && !a.label.includes('%')) {
                    if (!labels.includes(a.label)) {
                        labels.push(a.label)
                        write_label(a.label)
                    }
                    id_label = labels.length
                }
                write_product(a.id, id_label, a.nom_produit, a.price, a.degree, a.volume, a.origine);
            }
        }

        await page.waitForSelector('.pagination_right');
        await page.evaluate(() => document.querySelector('.pagination_right').click())
    }

    browser.close();

    // 5 - Retourner les données

    return products;
}

// Appel de la fonction getData() et affichage des données
for (boiskay of URLS) {
    getData(boiskay.link, boiskay["nb-pages"]).then((res) => {
        console.log(res.length);
    }).catch((err) => {
        console.log(err)
    })
}

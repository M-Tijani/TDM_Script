ETAPES[#ETAPES + 1] = {
    cle    = "bouftou",
    nom    = "Porte 325, quete, Donjon Bouftou",
    succes = { 37 },
    acces  = "tp",
    quete  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(191105026)" },
        { map = "191105026", path = "right" },
        { map = "191106050", door = "325" },
        { map = "192413696", path = "484", custom = function()
            if lireEtat("D325") ~= "1" then
                parler(4370, { -1, -1, -1 })
                parler(4370, { -1, -1, -1, -1, -1 })
                ecrireEtat("D325", 1)
            end
        end },
        { map = "6,-18", path = "havenbag" },
        { map = "162791424", path = "zaap(191105026)" },
        { map = "5,-18", path = "left" },
        { map = "4,-18", path = "left" },
        { map = "3,-18", path = "left" },
        { map = "2,-18", path = "left" },
        { map = "1,-18", path = "bottom" },
        { map = "1,-17", path = "bottom" },
        { map = "1,-16", path = "bottom" },
        { map = "188743687", custom = function()
            if lireEtat("QUETE2_1577") ~= "1" then
                parler(1577, { -3, -1, -1, -1, -1, -1, -1 })
                ecrireEtat("QUETE2_1577", 1)
            end
        end },
    },
    aller  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(120062979)" },
        { map = "1,-32", path = "right" },
        { map = "2,-32", path = "top" },
        { map = "2,-33", path = "top" },
        { map = "120063489" },
    },
    entree = {
        carte = "120063489",
        pnj = 173,
        reponses = { -1, -1 },
        reponsesTp = { -2 },
    },
    donjon = {
        { map = "121373185", fight = true },
        { map = "121374209", fight = true },
        { map = "121375233", fight = true },
        { map = "121373187", fight = true },
        { map = "121374211", fight = true },
        { map = "121375235", custom = function()
            parler(173, { -1, -1 }, { changeCarte = 5000 })
        end },
    },
    apres  = nil,
}

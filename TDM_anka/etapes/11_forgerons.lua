local ETAPE = {
    cle    = "forgerons",
    nom    = "PNJ 814 puis Donjon des Forgerons",
    succes = { 43 },
    donjonSolo = true,
    acces  = "tp",
}
ETAPE.quete = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(88213271)" },
    { map = "-2,0", path = "right" },
    { map = "-1,0", path = "right" },
    { map = "0,0", path = "right" },
    { map = "1,0", path = "right" },
    { map = "2,0", path = "right" },
    { map = "3,0", path = "right" },
    { map = "4,0", path = "right" },
    { map = "88082711", custom = function()
        parler(814, { -1, -1 })
    end, path = "havenbag" },
}
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(88085249)" },
    { map = "10,22", path = "right" },
    { map = "11,22", path = "right" },
    { map = "12,22", path = "right" },
    { map = "13,22", path = "top" },
}
ETAPE.entree = {
    carte = "88086786",
    pnj = 1162,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
}
ETAPE.donjon = {
    { map = "87294465", path = "262" },
    { map = "87295489", fight = true },
    { map = "87296513", fight = true },
    { map = "87297537", path = "221" },
    { map = "87294467", fight = true },
    { map = "87295491", fight = true },
    { map = "87296515", fight = true },
    { map = "87297539", custom = function()
        parler(2030, { -1, -1 }, { changeCarte = 5000 })
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

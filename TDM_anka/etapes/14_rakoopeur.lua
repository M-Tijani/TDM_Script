local ETAPE = {
    cle    = "rakoopeur",
    nom    = "PNJ 814, passage 6801 puis Refuge Sylvestre",
    succes = { 5911 },
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
    { map = "162791424", path = "zaap(88213271)" },
    { map = "-2,0", path = "right" },
    { map = "-1,0", path = "right" },
    { map = "0,0", path = "right" },
    { map = "1,0", path = "right" },
    { map = "2,0", path = "right" },
    { map = "3,0", path = "right" },
    { map = "4,0", path = "right" },
    { map = "88082711", path = "top" },
    { map = "5,-1", path = "top" },
    { map = "5,-2", path = "top" },
    { map = "5,-3", path = "right" },
    { map = "6,-3", path = "right" },
    { map = "7,-3", path = "right" },
    { map = "8,-3", path = "right" },
    { map = "9,-3", path = "right" },
    { map = "68421124", custom = function()
        parler(6801, { -3 }, { changeCarte = 5000 })
    end },
    { map = "223347712", path = "top" },
    { map = "223347970", path = "top" },
    { map = "223347972", path = "top" },
    { map = "223347974", path = "right" },
    { map = "223348486", path = "top" },
    { map = "223348487", path = "right" },
    { map = "223348999", path = "top" },
    { map = "223349000", path = "top" },
    { map = "223349001", path = "top" },
    { map = "223349002", path = "right" },
    { map = "223350026", path = "top" },
}
ETAPE.entree = {
    carte = "223350028",
    pnj = 6809,
    reponses = { -1, -1 },
    positionTp = 3,
    reponsesTp = { -2 },
}
ETAPE.donjon = {
    { map = "224133120", fight = true },
    { map = "224134144", fight = true },
    { map = "224135168", fight = true },
    { map = "224136192", fight = true },
    { map = "224137216", fight = true },
    { map = "224137218", custom = function()
        local ici = carte()
        parler(6807, { -1 }, { changeCarte = 5000 })
        if carte() == ici then parler(6809, { -1 }, { changeCarte = 5000 }) end
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

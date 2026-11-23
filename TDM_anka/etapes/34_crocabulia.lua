charger("etapes\\lib_donjons.lua", true)
local ETAPE = {
    cle    = "donjons_crocabulia",
    nom    = "Kal Vissi puis Antre de Crocabulia",
    succes = {},
    acces  = "pied",
}
ETAPE.quete = trajetVersKal(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(88212481)" },
    { map = "-1,24", path = "left" },
    { map = "-2,24", path = "left" },
    { map = "-3,24", path = "left" },
    { map = "84411392", door = "202" },
    { map = "199230724", door = "274" },
    { map = "198181888", path = "right" },
    { map = "198182400", path = "right" },
    { map = "198182912", path = "bottom" },
    { map = "198182913", door = "319" },
}
ETAPE.entree = {
    carte = "198967296",
    pnj = 789,
    reponses = { -1, -1 },
}
ETAPE.donjon = {
    { map = "198968320", fight = true },
    { map = "198969344", fight = true },
    { map = "198970368", fight = true },
    { map = "198971392", fight = true },
    { map = "198972416", fight = true },
    { map = "198972418", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(789, { -1, -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

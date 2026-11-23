charger("etapes\\lib_juge.lua", true)
local ETAPE = {
    cle    = "juge_meulou",
    nom    = "Chris de Naire puis Taniere du Meulou",
    succes = { 39 },
    acces  = "tp",
}
ETAPE.quete = trajetVersChris(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(73400320)" },
    { map = "73400320", path = "top" },
    { map = "73400577", path = "left" }, { map = "73532161", path = "left" }, { map = "73532673", path = "left" },
    { map = "73533185", path = "left" }, { map = "73533697", path = "left" }, { map = "73534209", path = "left" },
    { map = "73534721", path = "top" },
    { map = "73534722", path = "left" },
    { map = "171706890", path = "left" },
    { map = "171706378", path = "bottom" },
    { map = "171706379", path = "right" },
    { map = "171706891" },
}
ETAPE.entree = {
    carte = "171706891",
    pnj = 3947,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
    positionTp = 3,
}
ETAPE.donjon = {
    { map = "155713536", fight = true },
    { map = "155714560", fight = true },
    { map = "155715584", door = "177" },
    { map = "155716610", fight = true },
    { map = "155717632", fight = true },
    { map = "155718656", fight = true },
    { map = "155719680", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(3947, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

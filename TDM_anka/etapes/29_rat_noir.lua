charger("etapes\\lib_juge.lua", true)
local ETAPE = {
    cle    = "juge_rat_noir",
    nom    = "Chris de Naire puis Sousouriciere du Rat Noir",
    succes = { 5194 },
    acces  = "tp",
}
ETAPE.quete = trajetVersChris(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(212992514)" },
    { map = "-26,37", path = "left" },
    { map = "-28,36", path = "left" },
    { map = "-29,36", path = "top" },
    { map = "212992514", door = "398" },
    { map = "216927751" },
}
ETAPE.entree = {
    carte = "216927751",
    pnj = 800,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
    positionTp = 3,
}
ETAPE.donjon = {
    { map = "218890240", fight = true },
    { map = "218891264", fight = true },
    { map = "218892288", fight = true },
    { map = "218893312", fight = true },
    { map = "218894336", fight = true },
    { map = "218894338", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(6614, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

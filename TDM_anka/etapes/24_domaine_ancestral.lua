charger("etapes\\lib_juge.lua", true)
local ETAPE = {
    cle    = "juge_ancestral",
    nom    = "Chris de Naire puis Domaine Ancestral",
    succes = { 35 },
    acces  = "tp",
}
ETAPE.quete = trajetVersChris(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(191105026)" },
    { map = "5,-18", path = "left" }, { map = "4,-18", path = "left" }, { map = "3,-18", path = "left" },
    { map = "2,-18", path = "left" }, { map = "1,-18", path = "left" }, { map = "0,-18", path = "left" },
    { map = "-1,-18", path = "left" }, { map = "-2,-18", path = "left" }, { map = "-3,-18", path = "left" },
    { map = "-4,-18", path = "left" }, { map = "-5,-18", path = "left" }, { map = "-6,-18", path = "left" },
    { map = "-7,-18", path = "left" }, { map = "-8,-18", path = "left" }, { map = "-9,-18", path = "bottom" },
    { map = "-9,-17", path = "bottom" }, { map = "-9,-16", path = "bottom" }, { map = "-9,-15", path = "bottom" },
    { map = "147851777" },
}
ETAPE.entree = {
    carte = "147851777",
    pnj = 1619,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
    positionTp = 3,
}
ETAPE.donjon = {
    { map = "149684224", fight = true },
    { map = "149685248", fight = true },
    { map = "149686272", fight = true },
    { map = "149687296", fight = true },
    { map = "149688320", fight = true },
    { map = "149689344", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(1619, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

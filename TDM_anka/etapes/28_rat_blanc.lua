charger("etapes\\lib_juge.lua", true)
local ETAPE = {
    cle    = "juge_rat_blanc",
    nom    = "Chris de Naire puis Garde-manger du Rat Blanc",
    succes = { 5188 },
    acces  = "tp",
}
ETAPE.quete = trajetVersChris(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(212600323)" },
    { map = "-31,-56", path = "left" },
    { map = "-32,-56", path = "top" },
    { map = "212599810", path = "top" },
    { map = "212599809", door = "523" },
    { map = "216269574", door = "402" },
    { map = "216269572", path = "left" },
    { map = "216400644", path = "left" },
    { map = "216401668", path = "top" },
    { map = "216401670", door = "259" },
    { map = "216401672", path = "left" },
    { map = "216402696", door = "178" },
    { map = "216402698" },
}
ETAPE.entree = {
    carte = "216402698",
    pnj = 799,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
    positionTp = 3,
}
ETAPE.donjon = {
    { map = "218628096", fight = true },
    { map = "218629120", fight = true },
    { map = "218630144", fight = true },
    { map = "218631168", fight = true },
    { map = "218632192", fight = true },
    { map = "218632194", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(6612, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

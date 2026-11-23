local ETAPE = {
    cle    = "champs",
    nom    = "Quete puis Donjon des Champs",
    succes = { 40 },
    acces  = "tp",
}
ETAPE.quete = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(191105026)" },
    { map = "5,-18", path = "left" },
    { map = "4,-18", path = "left" },
    { map = "3,-18", path = "left" },
    { map = "2,-18", path = "left" },
    { map = "1,-18", path = "bottom" },
    { map = "1,-17", path = "bottom" },
    { map = "1,-16", path = "bottom" },
    { map = "188743687", custom = function()
        parler(1577, { -3, -1, -1, -1 })
    end },
}
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(191105026)" },
    { map = "5,-18", path = "right" },
    { map = "6,-18", path = "right" },
    { map = "7,-18", path = "top" },
    { map = "7,-19", path = "top" },
    { map = "7,-20", path = "top" },
    { map = "7,-21", path = "top" },
    { map = "7,-22", path = "top" },
    { map = "7,-23", path = "top" },
    { map = "189794311", door = "328" },
    { map = "192937992" },
}
ETAPE.entree = {
    carte = "192937992",
    pnj = 780,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
    custom = function()
        if lireEtat("CHAMPS_4370") ~= "1" and not (estLeader() and leaderPasseur(ETAPE.n)) then
            parler(4370, { -1, -1, -1, -1, -1, -1, -1 })
            ecrireEtat("CHAMPS_4370", 1)
        end
        entrerDansLeDonjon(ETAPE)
    end,
}
ETAPE.donjon = {
    { map = "190449664", fight = true },
    { map = "190448640", fight = true },
    { map = "190316544", fight = true },
    { map = "190317568", fight = true },
    { map = "190318592", fight = true },
    { map = "190318594", custom = function()
        parler(780, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

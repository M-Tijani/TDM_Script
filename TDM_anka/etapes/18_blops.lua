local function versCarte(id) avancerVers(id) end
local ETAPE = {
    cle    = "blops",
    nom    = "Zaap, PNJ 1577 et 1578 puis Clos des Blops",
    succes = { 36 },
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
        parler(1577, { -3, -1 })
        versCarte(99091977)
    end },
    { map = "99091977", custom = function()
        parler(1578, { -1, -1, -1 })
        versCarte(99090953)
    end },
}
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(156240386)" },
    { map = "-3,-42", path = "left" },
    { map = "-4,-42", path = "top" },
    { map = "160696320", door = "153" },
    { map = "-4,-43", path = "left" },
    { map = "-5,-43", path = "left" },
    { map = "-6,-43", path = "left" },
    { map = "156238337", door = "164" },
}
ETAPE.entree = {
    carte = "166985728",
    pnj = 1034,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
}
local function coequipiersDevant(cartes)
    local n = 0
    for _, a in ipairs(comptesEquipe()) do
        local c = tostring(carteDe(a))
        for _, x in ipairs(cartes) do if c == x then n = n + 1 end end
    end
    return n
end
SUITE_SALLE5 = { "166986754", "166987778", "166985730", "166988802", "166989826", "166990850" }
SUITE_SALLE7 = { "166990850" }
ETAPE.donjon = {
    { map = "166986752", fight = true },
    { map = "166987776", fight = true },
    { map = "166988800", fight = true },
    { map = "166989824", fight = true },
    { map = "166990848", custom = function()
        local ici = carte()
        if coequipiersDevant(SUITE_SALLE5) == 0 and not equipeAuComplet(ici, nil, true) then return end
        parler(1034, { -3, -1 }, { changeCarte = 5000 })
    end },
    { map = "166986754", fight = true },
    { map = "166987778", fight = true },
    { map = "166985730", fight = true },
    { map = "166988802", fight = true },
    { map = "166989826", custom = function()
        local ici = carte()
        if coequipiersDevant(SUITE_SALLE7) == 0 and not equipeAuComplet(ici, nil, true) then return end
        parler(1034, { -1, -1 }, { changeCarte = 5000 })
    end },
    { map = "166990850", fight = true },
    { map = "166985728" },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

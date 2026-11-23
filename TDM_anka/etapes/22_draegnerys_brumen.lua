local function versCarte(id) avancerVers(id) end
local ETAPE = {
    cle    = "draegnerys_brumen",
    nom    = "Alain Deix, Draegnerys, Laboratoire de Brumen puis Alain Deix",
    succes = { 2128 },
    acces  = "tp",
}
ETAPE.quete = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(68419587)" },
    { map = "99091977", custom = function()
        parler(1578, { -1, -1, -1 })
        parler(1578, { -1, -1, -1 })
        ecrireEtat("QUETE_draegnerys_brumen", 1)
        versCarte(99090953)
    end },
}
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(88212481)" },
    { map = "-1,24", path = "left" },
    { map = "-2,24", path = "bottom" },
    { map = "-2,25", path = "left" },
    { map = "-3,25", path = "left" },
    { map = "-4,25", path = "bottom" },
    { map = "-4,26", path = "bottom" },
    { map = "-4,27", path = "bottom" },
    { map = "-4,28", path = "bottom" },
}
ETAPE.entree = {
    carte = "84411397",
    pnj = 4946,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
}
ETAPE.donjon = {
    { map = "199753728", fight = true },
    { map = "199754752", fight = true },
    { map = "199755776", fight = true },
    { map = "199756800", fight = true },
    { map = "199757824", fight = true },
    { map = "199757826", custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(4947, { -1, -1 }, { changeCarte = 5000 })
        if carte() == ici then parler(4947, { -1 }, { changeCarte = 5000 }) end
    end },
}
BRUMEN_PLUS_TARD = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(171967506)" },
    { map = "-25,12", path = "left" },
    { map = "-26,12", path = "bottom" },
    { map = "-26,13", path = "bottom" },
    { map = "-26,14", path = "bottom" },
    { map = "-26,15", path = "bottom" },
    { map = "-26,16", path = "bottom" },
    { map = "-26,17", path = "left" },
    { map = "173016577", door = "271" },
    { map = "177079296", custom = function()
        local ici = carte()
        if not equipeAuComplet(ici, nil, true) then return end
        entrerDansLeDonjon({ entree = { pnj = 1410, reponses = { -1, -1, -1 } } })
    end },
    { map = "176947200", fight = true },
    { map = "176948224", fight = true },
    { map = "176949248", fight = true },
    { map = "176950272", fight = true },
    { map = "176951296", fight = true },
    { map = "176952320", custom = function()
        local ici = carte()
        parler(1410, { -1 }, { changeCarte = 5000 })
        if carte() == ici then parler(1621, { -1 }, { changeCarte = 5000 }) end
        if carte() == ici then parler(1410, { -1 }, { changeCarte = 5000 }) end
    end },
    { map = "177079296", path = "havenbag" },
    { map = "162791424", path = "zaap(68419587)" },
    { map = "99091977", custom = function()
        parler(1578, { -1 })
        versCarte(99090953)
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

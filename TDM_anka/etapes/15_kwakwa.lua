local ETAPE = {
    cle    = "kwakwa",
    nom    = "PNJ 814 puis Nid du Kwakwa",
    succes = { 67 },
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
    { map = "-2,0", path = "top" },
    { map = "-2,-1", path = "right" },
    { map = "-1,-1", path = "top" },
    { map = "-1,-2", path = "top" },
    { map = "-1,-3", path = "left" },
    { map = "-2,-3", path = "top" },
    { map = "-2,-4", path = "top" },
    { map = "-2,-5", path = "top" },
    { map = "-2,-6", path = "top" },
    { map = "-2,-7", path = "left" },
    { map = "-3,-7", path = "left" },
}
ETAPE.entree = {
    carte = "185861122",
    pnj = 1404,
    reponses = { -2, -1 },
    reponsesTp = { -2 },
}
ETAPE.donjon = {
    { map = "64749568", fight = true },
    { map = "64750592", fight = true },
    { map = "64751616", fight = true },
    { map = "64752640", fight = true },
    { map = "64753664", fight = true },
    { map = "64754688", custom = function()
        local ici = carte()
        local autres = 0
        for _, a in ipairs(comptesEquipe()) do
            if idDe(a) ~= moiId() and carteDe(a) == ici then autres = autres + 1 end
        end
        if autres > 0 and not equipeAuComplet(ici, nil, true) then return end
        parler(5817, { -1, -1, -1, -1, -1, -1 })
        parler(1404, { -1 }, { changeCarte = 5000 })
        if carte() == ici then parler(1404, { -1, -2 }, { changeCarte = 5000 }) end
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

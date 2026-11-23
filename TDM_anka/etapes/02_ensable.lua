ETAPES[#ETAPES + 1] = {
    cle    = "ensable",
    nom    = "Chateau Ensable",
    succes = { 54 },
    acces  = "tp",
    quete  = nil,
    aller  = {
        { map = "190056961" },
    },
    entree = {
        carte = "190056961",
        pnj = 798,
        reponses = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 },
        reponsesTp = { -2 },
    },
    donjon = {
        { map = "193725440", fight = true },
        { map = "193726464", fight = true },
        { map = "193727488", fight = true },
        { map = "193728512", fight = true },
        { map = "193729536", fight = true },
        { map = "193730560", custom = function()
            parler(798, { -1, -1 }, { changeCarte = 5000 })
        end },
    },
    apres  = nil,
}

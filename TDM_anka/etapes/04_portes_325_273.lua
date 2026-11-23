ETAPES[#ETAPES + 1] = {
    cle    = "portes_325_273",
    nom    = "Porte 325 puis porte 273",
    succes = {},
    validee = function() return lireEtat("PNJ813") == "1" end,
    acces  = "aucun",
    quete  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(191105026)" },
        { map = "191105026", path = "right" },
        { map = "191106050", door = "325" },
        { map = "192413696", path = "484", custom = function()
            if lireEtat("D325B") ~= "1" then
                parler(4370, { -1, -1 })
                parler(4370, { -1, -1, -1 })
                ecrireEtat("D325B", 1)
            end
        end },
        { map = "6,-18", path = "havenbag" },
        { map = "162791424", path = "zaap(165153537)" },
        { map = "-11,-36", path = "right" },
        { map = "-10,-36", path = "right" },
        { map = "-9,-36", path = "right" },
        { map = "-8,-36", path = "right" },
        { map = "-7,-36", path = "right" },
        { map = "-6,-36", path = "top" },
        { map = "156238855", door = "273" },
        { map = "160697344", door = "480", custom = function()
            if lireEtat("PNJ813") ~= "1" then
                parler(813, { -1 })
                ecrireEtat("PNJ813", 1)
            end
        end },
    },
    aller  = nil,
    entree = nil,
    donjon = nil,
    apres  = nil,
}

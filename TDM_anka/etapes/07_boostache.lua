local function uneFois(cle, f)
    if lireEtat(cle) == "1" then return end
    f()
    ecrireEtat(cle, 1)
end
ETAPES[#ETAPES + 1] = {
    cle    = "boostache",
    nom    = "Quetes puis donjon du Boostache",
    succes = { 66 },
    acces  = "tp",
    quete  = {
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
            uneFois("Q_BOOSTACHE_1577", function() parler(1577, { -3, -1, -1 }) end)
        end, path = "havenbag" },
        { map = "162791424", path = "zaap(165153537)" },
        { map = "-11,-36", path = "right" },
        { map = "-10,-36", path = "right" },
        { map = "-9,-36", path = "right" },
        { map = "-8,-36", path = "right" },
        { map = "-7,-36", path = "right" },
        { map = "-6,-36", path = "top" },
        { map = "156238855", door = "273" },
        { map = "160697344", custom = function()
            uneFois("Q_BOOSTACHE_813", function() parler(813, { -1, -1 }) end)
        end, path = "havenbag" },
    },
    aller  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(165153537)" },
        { map = "-11,-36", path = "top" },
        { map = "-11,-37", path = "top" },
        { map = "-11,-38", path = "top" },
        { map = "-11,-39", path = "top" },
        { map = "-11,-40", path = "top" },
        { map = "-11,-41", path = "left" },
        { map = "-12,-41", path = "left" },
    },
    entree = {
        carte = "139723265",
        pnj = 1387,
        reponses = { -2, -1 },
        reponsesTp = { -2 },
    },
    donjon = {
        { map = "163578368", fight = true },
        { map = "163579392", fight = true },
        { map = "163580416", fight = true },
        { map = "163581440", fight = true },
        { map = "163582464", fight = true },
        { map = "163583488", custom = function()
            parler(1387, { -1 }, { changeCarte = 5000 })
        end },
    },
    apres  = nil,
}

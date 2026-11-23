local function uneFois(cle, f)
    if lireEtat(cle) == "1" then return end
    f()
    ecrireEtat(cle, 1)
end
ETAPES[#ETAPES + 1] = {
    cle    = "gobelins",
    nom    = "Quete puis donjon des Gobelins",
    succes = { 5213 },
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
            uneFois("Q_GOBELINS_1577", function() parler(1577, { -3, -1, -1 }) end)
        end, path = "havenbag" },
    },
    aller  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(88082704)" },
        { map = "5,7", path = "bottom" },
        { map = "5,8", path = "left" },
        { map = "4,8", path = "left" },
        { map = "3,8", path = "left" },
        { map = "2,8", path = "left" },
        { map = "1,8", path = "left" },
        { map = "0,8", path = "left" },
        { map = "-1,8", door = "369" },
        { map = "-2,8", path = "left" },
        { map = "-3,8", path = "left" },
        { map = "-4,8", path = "top" },
        { map = "-4,7", path = "top" },
        { map = "-4,6", path = "top" },
        { map = "-4,5", path = "top" },
        { map = "-4,4", path = "top" },
        { map = "-4,3", path = "left" },
    },
    entree = {
        carte = "104071939",
        pnj = 6674,
        reponses = { -1, -1 },
        reponsesTp = { -2 },
    },
    donjon = {
        { map = "221774336", fight = true },
        { map = "221775360", fight = true },
        { map = "221776384", fight = true },
        { map = "221777408", fight = true },
        { map = "221778432", fight = true },
        { map = "221778434", custom = function()
            parler(6673, { -1 }, { changeCarte = 5000 })
        end },
    },
    apres  = nil,
}

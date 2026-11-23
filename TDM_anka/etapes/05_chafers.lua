local CARTE_FERMOIR = "82314497"
local CELLULES_FERMOIR = { 114, 99, 260 }
local function passerFermoir()
    for essai = 1, 3 do
        if carte() ~= CARTE_FERMOIR then return end
        if essai > 1 then alerte("fermoir des Squelettes : pas passe, essai " .. essai) end
        for _, c in ipairs(CELLULES_FERMOIR) do
            pcall(function() map:moveToCell(c) end)
            attendre(function()
                return carte() ~= CARTE_FERMOIR
                    or tonumber(sur(function() return map:currentCell() end, -1)) == c
            end, 3000)
            if carte() ~= CARTE_FERMOIR then return end
        end
        attendre(function() return carte() ~= CARTE_FERMOIR end, 2000)
    end
end
ETAPES[#ETAPES + 1] = {
    cle    = "chafers",
    nom    = "Donjon des Chafers",
    succes = { 49 },
    acces  = "tp",
    quete  = nil,
    aller  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(88082704)" },
        { map = "5,7", path = "right" },
        { map = "6,7", path = "right" },
        { map = "7,7", path = "right" },
        { map = "8,7", path = "right" },
        { map = "9,7", path = "right" },
        { map = "10,7", path = "right" },
        { map = "11,7", path = "bottom" },
        { map = "11,8", path = "bottom" },
        { map = "11,9", path = "bottom" },
        { map = "11,10", path = "bottom" },
        { map = "11,11", path = "bottom" },
        { map = "11,12", path = "right" },
        { map = "12,12", path = "right" },
        { map = "13,12", path = "bottom" },
        { map = "13,13", path = "bottom" },
        { map = "13,14", path = "bottom" },
        { map = "13,15", path = "bottom" },
        { map = "13,16", path = "left" },
        { map = "12,16", path = "left" },
        { map = "11,16", path = "left" },
        { map = "10,16", path = "top" },
        { map = CARTE_FERMOIR, custom = passerFermoir },
    },
    entree = {
        carte = "87032320",
        pnj = 1163,
        reponses = { -1, -1 },
        reponsesTp = { -2 },
    },
    donjon = {
        { map = "87033344", fight = true },
        { map = "87034368", fight = true },
        { map = "87035392", fight = true },
        { map = "87032322", fight = true },
        { map = "87033346", fight = true },
        { map = "87034370", custom = function()
            parler(6459, { -1, -1, -1 }, { changeCarte = 5000 })
        end },
    },
    apres  = nil,
}

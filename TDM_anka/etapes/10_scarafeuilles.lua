local CARTE_TRAPPES = "94111744"
local CELLULES_TRAPPES = { 428, 399, 371, 356, 313 }
local PORTE_TRAPPES = 267
local CARTE_TROU = "94111746"
local DELAI_CASE_PIEGEE_MS = 700
local function traverserTrappes()
    for essai = 1, 4 do
        if carte() ~= CARTE_TRAPPES then return end
        if essai > 1 then alerte("trappes des Scarafeuilles : on refait le passage (essai " .. essai .. ")") end
        attendre(function()
            return not sur(function() return character:isBusy() end, false) and not enCombat()
        end, 10000, 100)
        local rate = false
        for _, c in ipairs(CELLULES_TRAPPES) do
            pcall(function() map:moveToCell(c) end)
            local ok = attendre(function() return carte() ~= CARTE_TRAPPES or celluleCourante() == c end, 3000)
            if carte() ~= CARTE_TRAPPES then return end
            if not ok then rate = true break end
            global:delay(DELAI_CASE_PIEGEE_MS)
        end
        if not rate then
            pcall(function() map:door(PORTE_TRAPPES) end)
            attendre(function() return carte() ~= CARTE_TRAPPES end, 8000)
            if carte() ~= CARTE_TRAPPES then return end
        end
    end
end
local function uneFois(cle, f)
    if lireEtat(cle) == "1" then return end
    f()
    ecrireEtat(cle, 1)
end
local function celluleCourante() return tonumber(sur(function() return map:currentCell() end, -1)) end

ETAPES[#ETAPES + 1] = {
    cle    = "scarafeuilles",
    nom    = "Quetes puis donjon des Scarafeuilles",
    succes = { 48 },
    donjonSolo = true,
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
            uneFois("Q_SCARA_1577", function() parler(1577, { -3, -1, -1 }) end)
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
            uneFois("Q_SCARA_813", function() parler(813, { -1 }) end)
        end, path = "havenbag" },
        { map = "162791424", path = "zaap(88213271)" },
        { map = "-2,0", path = "right" },
        { map = "-1,0", path = "right" },
        { map = "0,0", path = "right" },
        { map = "1,0", path = "right" },
        { map = "2,0", path = "right" },
        { map = "3,0", path = "right" },
        { map = "4,0", path = "right" },
        { map = "88082711", custom = function()
            uneFois("Q_SCARA_814", function() parler(814, { -1 }) end)
        end, path = "havenbag" },
    },
    aller  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(88212481)" },
        { map = "88212481", path = "right" },
        { map = "0,24", path = "right" },
        { map = "1,24", path = "bottom" },
        { map = "1,25", path = "bottom" },
    },
    entree = {
        carte = "88080387",
        pnj = 781,
        reponses = { -2, -1 },
        reponsesTp = { -2 },
    },
    donjon = {
        { map = "94109696", door = "296" },
        { map = "94110720", fight = true },
        { map = CARTE_TROU, door = "230" },
        { map = CARTE_TRAPPES, custom = traverserTrappes },
        { map = "94112768", fight = true },
        { map = "94113792", fight = true },
        { map = "94114816", fight = true },
        { map = "94115840", fight = true },
        { map = "94116864", door = "315" },
    },
    apres  = nil,
}

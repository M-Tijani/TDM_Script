local CARTE_PIEGES = "96206850"
local CELLULES_PIEGES = { 425, 426, 398, 370, 342, 328, 315, 300, 287, 273, 260, 274, 289, 262 }
local PORTE_PIEGES = 248
local CARTE_TROU = "96206852"
local function traverserPieges()
    for essai = 1, 4 do
        if carte() ~= CARTE_PIEGES then return end
        if essai > 1 then alerte("pieges des Tofus : on refait le passage (essai " .. essai .. ")") end
        attendre(function()
            return not sur(function() return character:isBusy() end, false) and not enCombat()
        end, 10000, 100)
        local rate = false
        for _, c in ipairs(CELLULES_PIEGES) do
            pcall(function() map:moveToCell(c) end)
            local ok = attendre(function() return carte() ~= CARTE_PIEGES or celluleCourante() == c end, 3000)
            if carte() ~= CARTE_PIEGES then return end
            if not ok then rate = true break end
        end
        if not rate then
            pcall(function() map:door(PORTE_PIEGES) end)
            attendre(function() return carte() ~= CARTE_PIEGES end, 8000)
            if carte() ~= CARTE_PIEGES then return end
        end
    end
end
local function celluleCourante() return tonumber(sur(function() return map:currentCell() end, -1)) end

ETAPES[#ETAPES + 1] = {
    cle    = "tofus",
    nom    = "Donjon des Tofus",
    succes = { 50 },
    donjonSolo = true,
    acces  = "tp",
    quete  = nil,
    aller  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(88082704)" },
        { map = "88082704", path = "top" },
        { map = "88082705", door = "329" },
        { map = "99352580", door = "217" },
    },
    entree = {
        carte = "96338944",
        pnj = 777,
        reponses = { -1, -1, -1 },
        reponsesTp = { -1, -2 },
    },
    donjon = {
        { map = "96338946", fight = true },
        { map = CARTE_TROU, door = "244" },
        { map = CARTE_PIEGES, custom = traverserPieges },
        { map = "96206848", fight = true },
        { map = "96207874", fight = true },
        { map = "96208898", fight = true },
        { map = "96209922", fight = true },
        { map = "96210946", custom = function()
            parler(777, { -1, -1 }, { changeCarte = 5000 })
        end },
    },
    apres  = nil,
}

charger("etapes\\lib_donjons.lua", true)
local CARTE_PIEGES = "96206854"
local CELLULES_PIEGES = { 471, 413, 424, 380, 299, 285, 270 }
local PORTE_PIEGES = 241
local CARTE_TROU = "96207876"
local function traverserPieges()
    for essai = 1, 4 do
        if carte() ~= CARTE_PIEGES then return end
        if essai > 1 then alerte("pieges du Tofu Royal : on refait le passage (essai " .. essai .. ")") end
        attendre(function()
            return not sur(function() return character:isBusy() end, false) and not enCombat()
        end, 10000, 100)
        local rate = false
        for _, c in ipairs(CELLULES_PIEGES) do
            pcall(function() map:moveToCell(c) end)
            local ok = attendre(function() return carte() ~= CARTE_PIEGES or celluleCourante() == c end, 3000)
            if carte() ~= CARTE_PIEGES then return end
            if not ok then rate = true break end
            attendre(function() return false end, 300, 100)
        end
        if not rate then
            pcall(function() map:door(PORTE_PIEGES) end)
            attendre(function() return carte() ~= CARTE_PIEGES end, 8000)
            if carte() ~= CARTE_PIEGES then return end
        end
    end
end
local function celluleCourante() return tonumber(sur(function() return map:currentCell() end, -1)) end

local ETAPE = {
    cle    = "donjons_tofu_royal",
    nom    = "Kal Vissi puis Tofulailler Royal",
    succes = {},
    donjonSolo = true,
    acces  = "pied",
}
ETAPE.quete = trajetVersKal(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(88082704)" },
    { map = "88082704", path = "top" },
    { map = "88082705", door = "329" },
    { map = "99352580", door = "217" },
}
ETAPE.entree = {
    carte = "96338944",
    pnj = 778,
    reponses = { -1, -1 },
}
ETAPE.donjon = {
    { map = "96338948", fight = true },
    { map = "96338950", fight = true },
    { map = CARTE_TROU, door = "244" },
    { map = CARTE_PIEGES, custom = traverserPieges },
    { map = "96207878", fight = true },
    { map = "96208902", fight = true },
    { map = "96209926", fight = true },
    { map = "96210950", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(778, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

charger("etapes\\lib_juge.lua", true)
local ETAPE = {
    cle    = "juge_koulosse",
    nom    = "Chris de Naire puis Caverne du Koulosse",
    succes = { 29 },
    acces  = "pied",
}
ETAPE.quete = trajetVersChris(ETAPE.cle)
function koulosseBoucle()
    local c = tonumber(sur(function() return map:currentCell() end, 0)) or 0
    local premier, second = "bottom", "top"
    if c % 14 >= 7 then premier, second = "top", "bottom" end
    local ok = sur(function() return map:changeMap(premier) end, false)
    if ok ~= true then pcall(function() map:changeMap(second) end) end
end
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(73400320)" },
    { map = "73400320", path = "bottom" }, { map = "73400321", path = "bottom" }, { map = "73400322", path = "bottom" },
    { map = "73400323", path = "bottom" }, { map = "73400324", path = "bottom" }, { map = "73400325", path = "bottom" },
    { map = "73400326", path = "left" },
    { map = "73531910", path = "bottom" },
    { map = "139784", path = "bottom" },
    { map = "139785", path = "right" },
    { map = "139273", custom = function() koulosseBoucle() end },
    { map = "139274", path = "right" },
    { map = "138762", custom = function() koulosseBoucle() end },
    { map = "138763", path = "right" },
    { map = "138251", path = "top" },
    { map = "138250", path = "left" },
    { map = "138761", path = "left" },
    { map = "139272", path = "left" },
}
ETAPE.entree = {
    carte = "139784",
    pnj = 754,
    reponses = { -2, -1 },
    custom = function()
        pcall(function() map:moveToCell(96) end)
        attendre(function() return tonumber(sur(function() return map:currentCell() end, -1)) == 96 end, 4000, 100)
        parler(754, { -2, -1 }, { changeCarte = 5000 })
    end,
}
ETAPE.donjon = {
    { map = "107216896", fight = true },
    { map = "107217920", fight = true },
    { map = "107218944", path = "bottom" },
    { map = "107219968", path = "bottom" },
    { map = "107220992", path = "right" },
    { map = "107223040", path = "right" },
    { map = "107224064", path = "right" },
    { map = "107225088", fight = true },
    { map = "107226112", fight = true },
    { map = "107227136", fight = true },
    { map = "107228160", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(755, { -1, -1, -1, -1, -1, -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

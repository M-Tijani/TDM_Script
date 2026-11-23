local ETAPE = {
    cle    = "bworks",
    nom    = "PNJ 814 puis Donjon des Bworks",
    succes = { 38 },
    donjonSolo = true,
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
    { map = "162791424", path = "zaap(88082704)" },
    { map = "5,7", path = "bottom" },
    { map = "5,8", path = "left" },
    { map = "4,8", path = "left" },
    { map = "3,8", path = "left" },
    { map = "2,8", path = "left" },
    { map = "1,8", path = "left" },
    { map = "0,8", path = "left" },
    { map = "88212751", door = "369" },
    { map = "-2,8", path = "left" },
    { map = "-3,8", path = "left" },
    { map = "-4,8", path = "bottom" },
    { map = "-4,9", path = "bottom" },
    { map = "-4,10", path = "left" },
    { map = "104071684", door = "213" },
}
ETAPE.entree = {
    carte = "104862211",
    pnj = 775,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
}
local function fouler(c, ici)
    for _ = 1, 4 do
        pcall(function() map:moveToCell(c) end)
        if attendre(function() return surCellule(c) or carte() ~= ici end, 1500) then
            return carte() == ici
        end
    end
    return false
end
local function traverserLaSalleSpeciale()
    local ici = carte()
    attendre(function() return not sur(function() return character:isBusy() end, false) end, 5000)
    for _, serie in ipairs({ { 395, 354, 314 }, { 367, 287 } }) do
        local ok = true
        for _, c in ipairs(serie) do
            if not fouler(c, ici) then ok = false break end
        end
        if carte() ~= ici then return end
        if ok then
            pcall(function() map:door(302) end)
            if attendre(function() return carte() ~= ici end, 8000) then return end
        end
    end
    alerte("Bworks : salle speciale non traversee (cellules 395/354/314 puis 367/287, porte 302)")
end
local function surCellule(c)
    return tonumber(sur(function() return map:currentCell() end, -1)) == c
end

ETAPE.donjon = {
    { map = "104595969", fight = true },
    { map = "104596993", fight = true },
    { map = "104598017", fight = true },
    { map = "104599041", custom = traverserLaSalleSpeciale },
    { map = "104595971", fight = true },
    { map = "104596995", fight = true },
    { map = "104598019", custom = function()
        parler(776, { -1, -1 }, { changeCarte = 5000 })
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

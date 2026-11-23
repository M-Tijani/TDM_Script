local ETAPE = {
    cle    = "larves",
    nom    = "PNJ 814 puis Donjon des Larves (controller)",
    succes = { 34 },
    acces  = "pied",
    controleur = "larves",
    pilotee = true,
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
OEUF_LARVE, CLEF_LARVE, OEUF_PRIX_MAX = 7423, 7425, 30000
function besoinOeufLarve()
    local autorise = ACHAT_OEUF_LARVE == true
    if not autorise and lvP ~= nil and lvGen ~= nil then
        local g = tonumber(sur(function() return lireMem(lvP() .. "ACHAT_OEUF") end, nil)) or 0
        autorise = g > 0 and g == lvGen()
    end
    if not autorise then return false end
    if not ETAPE.n then for i, x in ipairs(ETAPES or {}) do if x == ETAPE then ETAPE.n = i end end end
    if not estLeader() and not queteFaitePourMoi(ETAPE) then return false end
    local o = tonumber(sur(function() return inventory:itemCount(OEUF_LARVE) end, 0)) or 0
    local c = tonumber(sur(function() return inventory:itemCount(CLEF_LARVE) end, 0)) or 0
    return o == 0 and c == 0
end
function acheterOeufLarve()
    for essai = 1, 3 do
        if not besoinOeufLarve() then break end
        pcall(function() npc:npc(315, 6) end)
        attendre(function() return false end, 1200, 100)
        pcall(function() sale:buyItem(OEUF_LARVE, 1, OEUF_PRIX_MAX) end)
        attendre(function() return not besoinOeufLarve() end, 3000, 100)
        fermerInterfaces()
    end
    fermerInterfaces()
    local function aUnOeuf()
        return (tonumber(sur(function() return inventory:itemCount(OEUF_LARVE) end, 0)) or 0) > 0
            or (tonumber(sur(function() return inventory:itemCount(CLEF_LARVE) end, 0)) or 0) > 0
    end
    attendre(aUnOeuf, 5000, 200)
    if not aUnOeuf() then
        alerte("larves : aucun oeuf achete sous " .. OEUF_PRIX_MAX .. " kamas")
        if lvP ~= nil and lvGen ~= nil and lvMoi ~= nil then
            pcall(function() ecrireMem(lvP() .. "ACHAT_ECHEC_" .. lvMoi(), tostring(lvGen())) end)
        end
    else dire("larves : oeuf de Larve achete") end
end
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", pathFn = function()
        return besoinOeufLarve() and "zaap(191105026)" or "zaap(88213271)"
    end },
    { map = "191102976", custom = function() acheterOeufLarve() end, path = "havenbag" },
    { map = "-2,0", path = "top" },
    { map = "-2,-1", path = "right" },
    { map = "-1,-1", path = "top" },
    { map = "-1,-2", path = "top" },
    { map = "-1,-3", path = "left" },
    { map = "-2,-3", path = "top" },
    { map = "-2,-4", path = "top" },
    { map = "185862148", door = "367" },
    { map = "97255951", path = "203" },
    { map = "97256975", path = "323" },
    { map = "97257999", path = "268" },
    { map = "97260047", path = "379" },
    { map = "97261071", path = "469" },
    { map = "97255953", path = "500" },
    { map = "97256977", path = "404" },
    { map = "97258001", path = "277" },
    { map = "97259025", path = "290" },
}
ETAPE.entree = {
    carte = "96993793",
    pnj = nil,
    reponses = nil,
    reponsesTp = nil,
    custom = function() bouclePilotee() end,
}
ETAPE.donjon = nil
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

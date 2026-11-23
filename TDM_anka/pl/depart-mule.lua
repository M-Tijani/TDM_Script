FIGHT_KICK = 0
SURVEILLANCE_BLOCAGE = false
IGNORE_REQUEST_EXCHANGE = false
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/deblocage.lua") end)
DOSSIER = global:getCurrentScriptDirectory()
pcall(function() dofile(DOSSIER .. "\\..\\Settings.lua") end)
KIT_SASA = KIT_SASA or {
    { gid = 732, q = 1 }, { gid = 835, q = 1 }, { gid = 712, q = 1 }, { gid = 2390, q = 1 },
    { gid = 1487, q = 1 }, { gid = 2532, q = 1 }, { gid = 7131, q = 1 }, { gid = 1665, q = 1 },
    { gid = 18667, q = 1 }, { gid = 972, q = 1 }, { gid = 34615, q = 1 }, { gid = 8342, q = 80 },
}
SET_RUN_MULE = SET_RUN_MULE or { 8463, 8464, 8465, 8466, 8467, 8468, 250, 1499, 18687 }
KAMAS_MULE = KAMAS_MULE or 40000
FINI = false
MARGE_KAMAS = 1000
CARTE_DEVANT_BANQUE = 191104002
PORTE_BANQUE = 288
CARTE_BANQUE = 192415750
ZAAP_ASTRUB = 191105026
CARTE_HAVRE_SAC = 162791424
function kitMule()
    local q, ordre = {}, {}
    local function ajouter(g, n)
        g = tonumber(g); n = tonumber(n) or 1
        if g == nil then return end
        if q[g] == nil then ordre[#ordre + 1] = g; q[g] = 0 end
        q[g] = q[g] + n
    end
    for _, l in ipairs(KIT_SASA) do ajouter(l.gid, l.q) end
    for _, g in ipairs(SET_RUN_MULE) do ajouter(g, 1) end
    local L = {}
    for _, g in ipairs(ordre) do L[#L + 1] = { gid = g, q = q[g] } end
    return L
end
KIT_MULE = kitMule()
function moi() return tostring(character:id()) end
function dansUnEchange() local o = false; pcall(function() o = exchange:isInExchange() == true end); return o end
function accepterEchange() paquet("kax", "{}") end
function move()
    if FINI then return {} end
    do local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end end
    local m = ici()
    if m == CARTE_BANQUE then return { { map = tostring(m), custom = attendreLeKit } } end
    if m == CARTE_DEVANT_BANQUE then return { { map = tostring(m), door = tostring(PORTE_BANQUE) } } end
    if m == CARTE_HAVRE_SAC then return { { map = tostring(m), path = "zaap(" .. ZAAP_ASTRUB .. ")" } } end
    local zone = ""
    pcall(function() zone = tostring(map:currentArea()) end)
    if zone == "Incarnam" then
        return {
            { map = "241443329", path = "right" },
            { map = "241444353", path = "right" },
            { map = "241445377", custom = handleNpc, door = "475" },
            { map = "154010883", path = "right" },
            { map = "154010371", path = "right" },
            { map = "153878787", path = "right" },
            { map = "153879299", path = "right" },
            { map = "153879811", path = "right" },
            { map = "153880323", path = "right" },
            { map = "153880835", custom = versAstrub },
        }
    end
    if zone == "Astrub" or zone == "Cité d'Astrub" or m == ZAAP_ASTRUB then
        return { { map = tostring(m), custom = function() pcall(function() map:moveToward(CARTE_DEVANT_BANQUE) end) end } }
    end
    return { { map = tostring(m), path = "havenbag" } }
end
function mem(cle, v)
    pcall(function()
        if developer:getInGlobalMemory(cle) ~= nil then developer:editInGlobalMemory(cle, tostring(v))
        else developer:addInGlobalMemory(cle, tostring(v)) end
    end)
end
function attendreLeKit()
    local n = monNom()
    if dansUnEchange() then fermerEchange() end
    while not FINI do
        if kitComplet() then kitTermine() return end
        unTour(n)
        if not kitComplet() then
            local b = besoin()
            if b ~= "" then global:printColor("#F39C12", "[SASA] kit incomplet, nouvelle demande : " .. b) end
        end
    end
end
function paquet(n, j) return pcall(function() developer:sendMessage(developer:createMessageFromJson(n, j)) end) end
function besoin()
    local c = compter()
    local L = {}
    local croca = tonumber(lireMem("KIT_CROCA_" .. monNom()))

    if lireMem("RS_MODE_CLEFS_" .. moi()) == "1" then
        local q = 80
        for _, l in ipairs(KIT_MULE) do if l.gid == 8342 then q = l.q end end
        if croca ~= nil and croca > 0 then q = croca end
        local m = q - nb(8342, c)
        return m > 0 and ("8342:" .. m) or ""
    end
    for _, l in ipairs(KIT_MULE) do
        local q = l.q
        if l.gid == 8342 and croca ~= nil and croca > 0 then q = croca end
        local m = q - nb(l.gid, c)
        if m > 0 then L[#L + 1] = l.gid .. ":" .. m end
    end
    local k = KAMAS_MULE - kamas()
    if k > MARGE_KAMAS then L[#L + 1] = "kamas:" .. k end
    return table.concat(L, ",")
end
function kitComplet() return besoin() == "" end
function versAstrub()
    pcall(function() npc:npc(4398, 3) end)
    pcall(function() npc:reply(-1) end)
    pcall(function() npc:reply(-1) end)
    pcall(function() global:leaveDialog() end)
end
function ici() local m = 0; pcall(function() m = tonumber(map:currentMapId()) end); return m end
function kamas() return tonumber(sur(function() return character:kamas() end, 0)) or 0 end
function sur(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end
function compter()
    local c = {}
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local g = tonumber(it.Item.Gid)
            if g then c[g] = (c[g] or 0) + 1 end
        end
    end)
    return c
end
function inscrireDemande(n)
    local l = lireMem("KIT_DEMANDES")
    for brut in string.gmatch(l, "[^,;]+") do
        if brut:gsub("^%s+", ""):gsub("%s+$", "") == n then return end
    end
    mem("KIT_DEMANDES", (l ~= "" and (l .. ",") or "") .. n)
end
function handleNpc()
    attendre(function() return not character:isBusy() end, 1500)
    if character:isBusy() then pcall(function() npc:reply(-1) end); pcall(function() npc:reply(-1) end) end
end
function bank() return move() end
function monNom() return tostring(sur(function() return character:name() end, "?")) end
function attendre(cond, maxMs)
    local t = 0
    while t <= maxMs do
        local ok, r = pcall(cond)
        if ok and r then return true end
        global:delay(50); t = t + 50
    end
    return false
end
function kitTermine()
    local n = monNom()
    if dansUnEchange() then fermerEchange() end
    mem("KIT_PRET_" .. n, 0)
    mem("KIT_MPOSE_" .. n, 0)
    mem("KIT_BESOIN_" .. n, "")
    mem("KIT_RECU_" .. n, 1)
    if lireMem("RS_MODE_CLEFS_" .. moi()) == "1" then
        mem("RS_MODE_CLEFS_" .. moi(), 0)
        global:printSuccess("[CLEFS] " .. nb(8342) .. " clefs Croca recues, retour au Croca")
        FINI = true
        global:finishScript()
        return
    end
    mem("RS_BESOIN_SASA_" .. moi(), 0)
    mem("RS_SASA_OK_" .. moi(), 1)
    global:printSuccess("[SASA] kit recu : stuff sasa + stuff de run, " .. nb(8342) .. " clefs Croca, " .. kamas() .. " kamas")
    FINI = true
    global:finishScript()
end

function unTour(n)
    inscrireDemande(n)
    local b = besoin()
    mem("KIT_RECU_" .. n, 0)
    mem("KIT_MPOSE_" .. n, 0)
    mem("KIT_BESOIN_" .. n, b)
    mem("KIT_PRET_" .. n, 1)
    mem("RS_BESOIN_SASA_" .. moi(), 1)
    global:printMessage("[SASA] " .. n .. " attend le compte banque, manque : " .. b)
    if not attendre(dansUnEchange, 60000) then return end
    accepterEchange()
    global:delay(1200)
    if not dansUnEchange() then return end
    TOUR = (TOUR or 0) + 1
    local jeton = tostring(os.time()):gsub("%D", "") .. "-" .. TOUR
    mem("KIT_PRET_" .. n, 0)
    mem("KIT_MPOSE_" .. n, jeton)
    attendre(function() return lireMem("KIT_POSE_" .. n) == jeton or not dansUnEchange() end, 60000)
    if dansUnEchange() and lireMem("KIT_POSE_" .. n) == jeton then
        pcall(function() exchange:ready() end)
        attendre(function() return not dansUnEchange() end, 60000)
    end
    if dansUnEchange() then fermerEchange() end
    mem("KIT_MPOSE_" .. n, 0)
    attendre(kitComplet, 3000)
end
function lireMem(cle) return tostring(sur(function() return developer:getInGlobalMemory(cle) end, "") or "") end
function fermerEchange() pcall(function() exchange:leave() end); pcall(function() global:leaveDialog() end) end
function phenix() return move() end
function nb(gid, c)
    local n = 0
    pcall(function() n = tonumber(inventory:itemCount(gid)) or 0 end)
    if c and (c[gid] or 0) > n then n = c[gid] end
    local pos = nil
    pcall(function() pos = tonumber(inventory:itemPosition(gid)) end)
    if n == 0 and pos ~= nil and pos >= 0 and pos ~= 63 then n = 1 end
    return n
end

FIGHT_KICK = 0
SURVEILLANCE_BLOCAGE = false
RECONNECT_ON_TIMEOUT = false
IGNORE_REQUEST_DUEL = true
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
KITS_MAX_SAC = 10
PODS_MAX_BANQUE = 88
ECART_COFFRE_S = 8
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
function ici() local m = 0; pcall(function() m = tonumber(map:currentMapId()) end); return m end
function paquet(n, j) return pcall(function() developer:sendMessage(developer:createMessageFromJson(n, j)) end) end
function sur(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end
function mem(cle) return sur(function() return developer:getInGlobalMemory(cle) end, nil) end
function contenuSac()
    local L = {}
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local p = tonumber(it.Position)
            if p == nil or p == 63 then L[#L + 1] = { g = tonumber(it.Item.Gid), u = tonumber(it.Item.Uid) } end
        end
    end)
    return L
end
function fermer() pcall(function() exchange:leave() end); pcall(function() global:leaveDialog() end) end
function lireMem(cle) return tostring(mem(cle) or "") end
function podsP() return tonumber(sur(function() return inventory:podsP() end, 0)) or 0 end
function nomsDemandes()
    local L, vu = {}, {}
    for brut in string.gmatch(lireMem("KIT_DEMANDES"), "[^,;]+") do
        local nom = brut:gsub("^%s+", ""):gsub("%s+$", "")
        if nom ~= "" and not vu[nom] then vu[nom] = true; L[#L + 1] = nom end
    end
    return L
end
function alerte(m) global:printColor("#F39C12", "[BANQUE] " .. m) end
function sac(gid, contenu)
    local n = tonumber(sur(function() return inventory:itemCount(gid) end, 0)) or 0
    local lignes = 0
    for _, x in ipairs(contenu or contenuSac()) do if x.g == gid then lignes = lignes + 1 end end
    if lignes > n then n = lignes end
    return n
end
function attendre(cond, maxMs)
    local t = 0
    while t <= maxMs do
        local ok, r = pcall(cond)
        if ok and r then return true end
        global:delay(50); t = t + 50
    end
    return false
end
function maintenant() return tonumber((tostring(os.time()):gsub(",", "."))) or 0 end
function kamas() return tonumber(sur(function() return character:kamas() end, 0)) or 0 end
function memEcrire(cle, v)
    pcall(function()
        if developer:getInGlobalMemory(cle) ~= nil then developer:editInGlobalMemory(cle, tostring(v))
        else developer:addInGlobalMemory(cle, tostring(v)) end
    end)
end
function nonServies()
    local L = {}
    for _, n in ipairs(nomsDemandes()) do if lireMem("KIT_RECU_" .. n) ~= "1" then L[#L + 1] = n end end
    return L
end
function dansUnEchange() return sur(function() return exchange:isInExchange() == true end, false) end
function info(m) global:printMessage("[BANQUE] " .. m) end

PAUSE_MULE = PAUSE_MULE or {}
function pretes()
    local L = {}
    local t = maintenant()
    for _, n in ipairs(nonServies()) do
        if lireMem("KIT_PRET_" .. n) == "1" and (PAUSE_MULE[n] or 0) <= t
            and (SERVI_JETON == nil or SERVI_JETON[n] == nil or lireMem("KIT_MPOSE_" .. n) ~= SERVI_JETON[n]) then L[#L + 1] = n end
    end
    return L
end
function besoinDe(n)
    local b, k, vu = {}, 0, false
    for g, q in string.gmatch(lireMem("KIT_BESOIN_" .. n), "([%w]+):(%d+)") do
        vu = true
        if g == "kamas" then k = tonumber(q) or 0
        elseif tonumber(g) then b[tonumber(g)] = (b[tonumber(g)] or 0) + (tonumber(q) or 0) end
    end
    if not vu then
        for _, l in ipairs(KIT_MULE) do b[l.gid] = l.q end
        k = KAMAS_MULE
    end
    return b, k
end
DERNIER_COFFRE = DERNIER_COFFRE or -1000
MANQUE_COFFRE = MANQUE_COFFRE or {}
MANQUE_COFFRE_S = 300
function ouvrirCoffre()
    local ecart = maintenant() - DERNIER_COFFRE
    if ecart >= 0 and ecart < ECART_COFFRE_S then
        attendre(function() return maintenant() - DERNIER_COFFRE >= ECART_COFFRE_S end, (ECART_COFFRE_S + 1) * 1000)
    end
    fermer()
    for _ = 1, 3 do
        pcall(function() npc:npcBank(-1) end)
        if attendre(coffreOuvert, 4000) then return true end
        if sur(function() return character:isBusy() end, false) == true then
            pcall(function() npc:reply(-1) end)
            if attendre(coffreOuvert, 3000) then return true end
        end
        pcall(function() global:leaveDialog() end)
        attendre(function() return not sur(function() return character:isBusy() end, false) end, 2000)
    end
    return false
end
function recharger()
    if not ouvrirCoffre() then
        alerte("coffre non ouvert")
        DERNIER_COFFRE = maintenant()
        return false
    end
    MANQUE_COFFRE = {}
    local D, besoinK, faits = {}, 0, 0
    for _, n in ipairs(nonServies()) do
        if faits >= KITS_MAX_SAC then break end
        if lireMem("KIT_BESOIN_" .. n) ~= "" or lireMem("KIT_PRET_" .. n) == "1" then
            local b, k = besoinDe(n)
            for g, q in pairs(b) do D[g] = (D[g] or 0) + q end
            besoinK = besoinK + (k or 0)
            faits = faits + 1
        end
    end
    for g, q in pairs(D) do
        local manque = q - sac(g)
        if manque > 0 and not MANQUE_COFFRE[g] then
            if not sortir(g, manque) then MANQUE_COFFRE[g] = true end
        end
        if podsP() >= PODS_MAX_BANQUE then break end
    end
    besoinK = besoinK - kamas()
    if besoinK > 0 then
        local av = kamas()
        pcall(function() exchange:getKamas(besoinK) end)
        attendre(function() return kamas() > av end, 1500)
    end
    fermer()
    DERNIER_COFFRE = maintenant()
    local m = {}
    for g in pairs(MANQUE_COFFRE) do m[#m + 1] = tostring(g) end
    info(faits .. " kit(s) au sac, pods " .. podsP() .. " %, " .. kamas() .. " kamas"
        .. (#m > 0 and (" ; ABSENT DU COFFRE : " .. table.concat(m, " ")) or ""))
    return true
end
function coffreOuvert() local ok, k = pcall(function() return exchange:storageKamas() end); return ok and k ~= nil end
function sacCouvre(b, k)
    local c = contenuSac()
    local oublier = maintenant() - DERNIER_COFFRE > MANQUE_COFFRE_S
    for g, q in pairs(b) do if (oublier or not MANQUE_COFFRE[g]) and sac(g, c) < q then return false end end
    return kamas() >= k
end
function sortir(g, manque)
    local avant = sac(g)
    local cible = avant + manque
    pcall(function() exchange:getItem(g, manque) end)
    attendre(function() return sac(g) >= cible end, 600)
    while sac(g) < cible do
        local a = sac(g)
        pcall(function() exchange:getItem(g, 1) end)
        if not attendre(function() return sac(g) > a end, 1500) then break end
    end
    return sac(g) >= cible
end

SERVI_JETON = SERVI_JETON or {}
ECHECS = ECHECS or {}
function bank() return move() end
function move()
    do local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end end
    local m = ici()
    if m == CARTE_BANQUE then return { { map = tostring(m), custom = servirTout } } end
    if m == CARTE_DEVANT_BANQUE then return { { map = tostring(m), door = tostring(PORTE_BANQUE) } } end
    if m == CARTE_HAVRE_SAC then return { { map = tostring(m), path = "zaap(" .. ZAAP_ASTRUB .. ")" } } end
    local zone = sur(function() return tostring(map:currentArea()) end, "")
    if zone == "Astrub" or zone == "Cité d'Astrub" or m == ZAAP_ASTRUB then
        return { { map = tostring(m), custom = function() pcall(function() map:moveToward(CARTE_DEVANT_BANQUE) end) end } }
    end
    return { { map = tostring(m), path = "havenbag" } }
end
function poserEnRafale(b, k)
    local c = contenuSac()
    local pris, poses = {}, 0
    for g, q in pairs(b) do
        local reste = q
        for _, x in ipairs(c) do
            if reste <= 0 then break end
            if x.g == g and x.u and not pris[x.u] then
                pris[x.u] = true
                local n = 1
                if reste > 1 then n = math.min(reste, sac(g)) end
                paquet("jys", '{"fxyo":' .. x.u .. ',"fxyq":' .. n .. '}')
                reste = reste - n
                poses = poses + 1
            end
        end
        if reste > 0 then alerte("manque " .. reste .. " x " .. g .. " au sac") end
    end
    local kk = math.min(k, kamas())
    if kk > 0 then pcall(function() exchange:putKamas(kk) end) end
    return poses, kk
end
function servirTout()
    memEcrire("RS_BANQUE_SASA_PRETE", 1)
    memEcrire("KIT_BANQUE_PRETE", 1)
    if dansUnEchange() then fermer() end
    local vide = 0
    while true do
        local L = pretes()
        table.sort(L, function(a, b) return (ECHECS[a] or 0) < (ECHECS[b] or 0) end)
        if #L > 0 then
            vide = 0
            servir(L[1])
        else
            vide = vide + 1
            if vide % 600 == 1 then info(#nonServies() .. " mule(s) a servir, aucune prete a la banque") end
            attendre(function() return #pretes() > 0 end, 1000)
        end
    end
end
function servir(n)
    local b, k = besoinDe(n)
    if not sacCouvre(b, k) then recharger() end
    fermer()
    local c, rien = contenuSac(), (k <= 0 or kamas() <= 0)
    for g, q in pairs(b) do if q > 0 and sac(g, c) > 0 then rien = false break end end
    if rien then
        PAUSE_MULE[n] = maintenant() + MANQUE_COFFRE_S
        alerte(n .. " : rien a lui donner (coffre vide pour " .. lireMem("KIT_BESOIN_" .. n) .. "), pause 5 min")
        return false
    end
    local ok = sur(function() return exchange:launchExchangeWithPlayerByName(n) end, false)
    if ok == false and not attendre(dansUnEchange, 1500) then
        ECHECS[n] = (ECHECS[n] or 0) + 1
        alerte(n .. " : demande d echange refusee (" .. ECHECS[n] .. ")")
        return false
    end
    if not attendre(dansUnEchange, 5000) then
        ECHECS[n] = (ECHECS[n] or 0) + 1
        alerte(n .. " : echange non ouvert (" .. ECHECS[n] .. ")")
        fermer()
        return false
    end
    local jeton = ""
    attendre(function()
        jeton = lireMem("KIT_MPOSE_" .. n)
        return (jeton ~= "" and jeton ~= "0" and jeton ~= SERVI_JETON[n]) or not dansUnEchange()
    end, 20000)
    if not dansUnEchange() or jeton == "" or jeton == "0" or jeton == SERVI_JETON[n] then
        ECHECS[n] = (ECHECS[n] or 0) + 1
        alerte(n .. " : pas de reponse dans l echange (" .. ECHECS[n] .. ")")
        fermer()
        return false
    end
    b, k = besoinDe(n)
    local poses, kk = poserEnRafale(b, k)
    global:delay(200)
    SERVI_JETON[n] = jeton
    memEcrire("KIT_POSE_" .. n, jeton)
    pcall(function() exchange:ready() end)
    attendre(function() return not dansUnEchange() end, 60000)
    if dansUnEchange() then fermer() end
    ECHECS[n] = 0
    info(n .. " : " .. poses .. " pose(s), " .. kk .. " kamas ; verification par la mule")
    attendre(function() return lireMem("KIT_RECU_" .. n) == "1" or lireMem("KIT_PRET_" .. n) == "1" end, 15000)
    if lireMem("KIT_RECU_" .. n) == "1" then global:printSuccess("[BANQUE] kit remis a " .. n) end
    return true
end
function phenix() return move() end

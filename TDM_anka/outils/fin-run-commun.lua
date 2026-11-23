DOSSIER_FR = DOSSIER_FR or global:getCurrentScriptDirectory()
pcall(function() dofile(DOSSIER_FR .. "\\..\\Settings.lua") end)
CARTE_DEVANT_BANQUE = 191104002
PORTE_BANQUE        = 288
CARTE_BANQUE        = 192415750
ZAAP_ASTRUB         = 191105026
CARTE_HAVRE_SAC     = 162791424
ECART_COFFRE_S      = 8
function coffreOuvert() local ok, k = pcall(function() return exchange:storageKamas() end) return ok and k ~= nil end
function monNom() return tostring(sur(function() return character:name() end, "?")) end
function attendre(cond, ms, pas)
    pas = pas or 50
    local t = 0
    while t < ms do if sur(cond, false) then return true end global:delay(pas) t = t + pas end
    return sur(cond, false) == true
end
function monCompte() return tostring(sur(function() return global:username() end, "?")) end
function podsP() return tonumber(sur(function() return inventory:podsP() end, 0)) or 0 end
function maintenant() return tonumber((tostring(os.time()):gsub(",", "."))) or 0 end
function lireMem(c) return tostring(sur(function() return developer:getInGlobalMemory(c) end, "") or "") end
function monId() return tostring(sur(function() return character:id() end, "?")) end
function kamas() return math.floor(tonumber(sur(function() return character:kamas() end, 0)) or 0) end
function ecrireMem(c, v)
    pcall(function()
        if developer:getInGlobalMemory(c) ~= nil then developer:editInGlobalMemory(c, tostring(v))
        else developer:addInGlobalMemory(c, tostring(v)) end
    end)
end
function fermer()
    pcall(function() exchange:leave() end)
    pcall(function() global:leaveDialog() end)
    attendre(function() return not enEchange() and not coffreOuvert() end, 2000)
end
function sur(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function nbSac(g) return tonumber(sur(function() return inventory:itemCount(g) end, 0)) or 0 end
function ici() return tonumber(sur(function() return map:currentMapId() end, 0)) or 0 end
function occupe() return sur(function() return character:isBusy() end, false) == true end
function paquet(n, j) return pcall(function() developer:sendMessage(developer:createMessageFromJson(n, j)) end) end
function enEchange() return sur(function() return exchange:isInExchange() end, false) == true end

PREFIXE = PREFIXE or "[FIN-RUN]"
function qteSac(g)
    local n, lignes = nbSac(g), 0
    for _, x in ipairs(contenu()) do if x.g == g and x.p == 63 then lignes = lignes + 1 end end
    return math.max(n, lignes)
end
function contenu()
    local L = {}
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            L[#L + 1] = { g = tonumber(it.Item.Gid), u = tonumber(it.Item.Uid), p = tonumber(it.Position) or 63 }
        end
    end)
    return L
end
function lignes(g)
    local n = 0
    for _, x in ipairs(contenu()) do if x.g == g then n = n + 1 end end
    return n
end
function alerte(m) global:printColor("#F39C12", PREFIXE .. " " .. m) end
function info(m) global:printMessage(PREFIXE .. " " .. m) end

PROTEGES = {}
local function proteger(liste) for _, g in ipairs(liste or {}) do if tonumber(g) then PROTEGES[tonumber(g)] = true end end end
proteger(SET_RUN_MULE or { 8463, 8464, 8465, 8466, 8467, 8468, 250, 1499, 18687 })
proteger({ 8463, 8464, 8465, 8466, 8467, 8468, 250, 1499, 18687 })
for _, e in ipairs(KIT_SASA or {}) do if tonumber(e.gid) then PROTEGES[tonumber(e.gid)] = true end end
proteger({ 732, 835, 712, 2390, 1487, 2532, 7131, 1665, 18667, 972, 34615, 8342 })
proteger({ 8243, 8534, 8242, 17495, 2373, 8217, 8222, 103, 8072, 6716 })
proteger({ 6731, 6750, 6753, 6951, 6947, 6939, 6941 })
proteger({ 8262, 16169, 8263, 13851, 8470, 8471, 8847, 8265, 33044, 737, 694, 17078, 12724, 13759, 13829, 18686,
           14848, 1019, 1021 })
proteger(KIT_COIFFE_CAPE or {})
proteger(KIT_COIFFE_CAPE_LEADER or {})
proteger({ 10207, 7423, 7425, 996, 15990, 8343, 7927, 12073, 8151, 6965 })
CLEFS_RUN = {}
if #CLEFS_RUN == 0 then
    CLEFS_RUN = { 8143, 8545, 8437, 1568, 1570, 15991, 11799, 26680, 7918, 8139, 1569, 8135, 27374, 12017, 8917, 9248, 9254,
                  11798, 14464, 7927, 8343, 12073, 7557, 7511, 8320, 7908, 8156, 8439, 8438, 7926, 11174, 7924, 8142, 996, 7423 }
end
proteger(CLEFS_RUN)
CLEFS_MULE_A_DONNER = {}
for _, g in ipairs(CLEFS_RUN) do CLEFS_MULE_A_DONNER[g] = true end
CLEFS_MULE_A_DONNER[8342], CLEFS_MULE_A_DONNER[996], CLEFS_MULE_A_DONNER[7423] = nil, nil, nil
NON_ECHANGEABLES_CONNUS = { 10784, 10785, 10794, 10797, 10798, 10799, 10800, 10801, 15990, 1728, 8151, 33011, 7423 }
proteger(NON_ECHANGEABLES_CONNUS)
TYPES_PROTEGES = { [84] = true, [24] = true, [18] = true, [121] = true, [23] = true, [151] = true, [97] = true, [196] = true, [207] = true }
function protege(g)
    g = tonumber(g)
    if g == nil then return true end
    if ROLE == "mule" and CLEFS_MULE_A_DONNER and CLEFS_MULE_A_DONNER[g] then return false end
    if PROTEGES[g] then return true end
    local ty = tonumber(sur(function() return inventory:getTypeId(g) end, nil))
    if ty ~= nil and TYPES_PROTEGES[ty] then return true end
    local tn = string.lower(tostring(sur(function() return inventory:getTypeName(g) end, "")))
    if tn:find("qu.-te") or tn:find("clef") or tn:find("familier") or tn:find("montilier") or tn:find("dofus") then return true end
    return false
end
function protegeStrict(g)
    if protege(g) then return true end
    local ty = tonumber(sur(function() return inventory:getTypeId(g) end, nil))
    local tn = tostring(sur(function() return inventory:getTypeName(g) end, ""))
    return ty == nil and tn == ""
end
NON_DEPOSABLES = { [930] = true, [931] = true, [10784] = true, [10785] = true, [10794] = true, [10797] = true, [10798] = true, [10799] = true,
    [10800] = true, [10801] = true, [10207] = true }
function protegesAuSac()
    local n = 0
    for _, x in ipairs(contenu()) do if x.p == 63 and protege(x.g) and not NON_DEPOSABLES[x.g] then n = n + 1 end end
    return n
end
NON_ECHANGEABLES = NON_ECHANGEABLES or {}
for _, g in ipairs(NON_ECHANGEABLES_CONNUS) do NON_ECHANGEABLES[g] = true end
pcall(function() for g in lireMem("FRV_NE_" .. monNom()):gmatch("%d+") do NON_ECHANGEABLES[tonumber(g)] = true end end)
function estLeaderOrchestre() return false end
function noterNonEchangeable(g)
    NON_ECHANGEABLES[tonumber(g)] = true
    local t = {}
    for x, _ in pairs(NON_ECHANGEABLES) do t[#t + 1] = tostring(x) end
    ecrireMem("FRV_NE_" .. monNom(), table.concat(t, " "))
end
function roleDuCompte()
    if estLeaderOrchestre() then return "leader" end
    if lireMem("FR_ROLE_" .. monCompte()) == "leader" then return "leader" end
    if lireMem("FR_ROLE_" .. monCompte()) == "mule" then return "mule" end
    if lireMem("RS_PREPA_ROLE_" .. monCompte()) == "leader" then return "leader" end
    local l = lireMem("RS_EQUIPE_DE_" .. monCompte())
    if l ~= "" and l:match("^([^,]+)") == monCompte() then return "leader" end
    return "mule"
end
DERNIER_COFFRE = DERNIER_COFFRE or -1000
function handleNpcIncarnam()
    attendre(function() return not occupe() end, 1500)
    if occupe() then pcall(function() npc:reply(-1) end); pcall(function() npc:reply(-1) end) end
end
function ouvrirCoffre()
    local ecart = maintenant() - DERNIER_COFFRE
    if ecart >= 0 and ecart < ECART_COFFRE_S then
        attendre(function() return maintenant() - DERNIER_COFFRE >= ECART_COFFRE_S end, (ECART_COFFRE_S + 1) * 1000, 200)
    end
    fermer()
    for _ = 1, 3 do
        pcall(function() npc:npcBank(-1) end)
        if attendre(coffreOuvert, 4000) then return true end
        if occupe() then
            pcall(function() npc:reply(-1) end)
            if attendre(coffreOuvert, 3000) then return true end
        end
        pcall(function() global:leaveDialog() end)
        attendre(function() return not occupe() end, 2000)
    end
    DERNIER_COFFRE = maintenant()
    return false
end
function kamasCoffre() return math.floor(tonumber(sur(function() return exchange:storageKamas() end, 0)) or 0) end
function fermerCoffre()
    fermer()
    DERNIER_COFFRE = maintenant()
end
function sortirDuCoffre(g, q, podsMax)
    if q <= 0 then return 0 end
    local avant = qteSac(g)
    pcall(function() exchange:getItem(g, q) end)
    attendre(function() return qteSac(g) >= avant + q end, 800)
    local n = 0
    while qteSac(g) < avant + q and podsP() < (podsMax or 95) and n < q + 2 do
        n = n + 1
        local a = qteSac(g)
        pcall(function() exchange:getItem(g, 1) end)
        if not attendre(function() return qteSac(g) > a end, 1500) then break end
    end
    return qteSac(g) - avant
end
function elements(c)
    local l = {}
    if c == nil then return l end
    if type(c) == "table" then for _, e in pairs(c) do l[#l + 1] = e end return l end
    local n = nil
    pcall(function() n = tonumber(c.Count) end)
    for i = 0, (n or 0) - 1 do local okk, e = pcall(function() return c[i] end) if okk and e ~= nil then l[#l + 1] = e end end
    return l
end
function deposerSaufListe(garder)
    local avant = podsP()
    pcall(function() exchange:putAllItemsExcept(garder) end)
    attendre(function() return podsP() < avant end, 4000)
end
function deshabiller()
    for _ = 1, 3 do
        local restants = 0
        for _, o in ipairs(contenu()) do
            if o.p ~= 63 then
                restants = restants + 1
                pcall(function() inventory:equipItem(o.g, 63) end)
                attendre(function()
                    for _, x in ipairs(contenu()) do if x.u == o.u then return x.p == 63 end end
                    return true
                end, 1500)
            end
        end
        if restants == 0 then return true end
    end
    for _, o in ipairs(contenu()) do if o.p ~= 63 then alerte("objet " .. tostring(o.g) .. " encore porte apres 3 passes") return false end end
    return true
end
function contenuCoffre()
    local t = {}
    for _, g in ipairs(elements(sur(function() return exchange:storageItems() end, nil))) do
        local gid = tonumber(g)
        if gid then t[gid] = tonumber(sur(function() return exchange:storageItemQuantity(gid) end, 0)) or 0 end
    end
    return t
end
function versAstrubDepuisIncarnam()
    pcall(function() npc:npc(4398, 3) end)
    pcall(function() npc:reply(-1) end)
    pcall(function() npc:reply(-1) end)
    pcall(function() global:leaveDialog() end)
end
SALLES_KARDORIM = { [152829952] = true, [152830976] = true, [152832000] = true, [152833024] = true, [152834048] = true, [152835072] = true }
function trajetBanque(customBanque)
    local m = ici()
    if SALLES_KARDORIM[m] then return { { map = tostring(m), custom = sortirKardorim } } end
    if m == CARTE_BANQUE then return { { map = tostring(m), custom = customBanque } } end
    if m == CARTE_DEVANT_BANQUE then return { { map = tostring(m), door = tostring(PORTE_BANQUE) } } end
    if m == CARTE_HAVRE_SAC then return { { map = tostring(m), path = "zaap(" .. ZAAP_ASTRUB .. ")" } } end
    if m == ZAAP_ASTRUB then return { { map = tostring(m), custom = function() pcall(function() map:moveToward(CARTE_DEVANT_BANQUE) end) end } } end
    local zone = tostring(sur(function() return map:currentArea() end, ""))
    if zone == "Incarnam" then
        return {
            { map = "241443329", path = "right" },
            { map = "241444353", path = "right" },
            { map = "241445377", custom = handleNpcIncarnam, door = "475" },
            { map = "154010883", path = "right" },
            { map = "154010371", path = "right" },
            { map = "153878787", path = "right" },
            { map = "153879299", path = "right" },
            { map = "153879811", path = "right" },
            { map = "153880323", path = "right" },
            { map = "153880835", custom = versAstrubDepuisIncarnam },
            { map = "153881600", path = "left" },
            { map = "153881088", path = "bottom" },
            { map = "153881089", path = "left" },
            { map = "153880064", path = "top" },
            { map = "153880321", path = "top" },
            { map = "153880322", path = "top" },
            { map = "*", path = "havenbag" },
        }
    end
    if zone == "Astrub" or zone == "Cité d'Astrub" then
        return { { map = tostring(m), custom = function() pcall(function() map:moveToward(CARTE_DEVANT_BANQUE) end) end } }
    end
    return { { map = tostring(m), path = "havenbag" } }
end
function sortirKardorim()
    local m = ici()
    for _ = 1, 3 do
        if m == 152835072 then
            pcall(function() npc:npc(2936, 3) end)
            pcall(function() npc:reply(-2) end)
            if attendre(function() return ici() ~= m end, 5000) then return end
            pcall(function() global:leaveDialog() end)
        end
        paquet("kgy", '{"fzcf":false}')
        if attendre(function() return ici() ~= m end, 4000) then return end
    end
    alerte("toujours dans la crypte de Kardorim (" .. m .. ") : relance du script")
    pcall(function() global:restartScript() end)
end

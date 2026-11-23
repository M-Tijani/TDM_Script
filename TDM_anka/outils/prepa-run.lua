RECONNECT_ON_TIMEOUT = false
FIGHT_KICK = 0
IGNORE_REQUEST_DUEL = true
IGNORE_REQUEST_EXCHANGE = true
CARTE_DEVANT_ASTRUB = 191104002
PORTE_ASTRUB        = 288
BANQUE_ASTRUB       = 192415750
ZAAP_ASTRUB         = 191105026
BANQUE_BONTA        = 217059328
CARTE_HAVRE_SAC     = 162791424
PODS_MAX_P          = 95
SET_RUN_MULE = { 8465, 250, 8466, 8468, 1499, 8467, 8463, 8464, 18687 }
CLEFS_RUN = {}
if #CLEFS_RUN == 0 then
    CLEFS_RUN = { 8143, 8545, 8437, 1568, 1570, 15991, 11799, 26680, 7918, 8139, 1569, 8135, 27374, 12017, 8917, 9248, 9254,
                  11798, 14464, 7927, 8343, 12073, 7557, 7511, 8320, 7908, 8156, 8439, 8438, 7926, 11174, 7924, 8142, 996, 7423 }
end
TYPES_A_GARDER = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true,
                   [9] = true, [10] = true, [11] = true, [16] = true, [17] = true, [19] = true, [20] = true,
                   [21] = true, [22] = true, [82] = true, [114] = true, [84] = true, [24] = true, [23] = true, [151] = true, [121] = true,
                   [97] = true, [196] = true, [207] = true }
GIDS_A_GARDER = { [10207] = true, [7423] = true, [7425] = true, [996] = true, [15990] = true, [8343] = true, [7927] = true,
                  [12073] = true, [8151] = true, [6965] = true, [8342] = true, [33044] = true }
GIDS_A_GARDER[34615] = true
for _, g in ipairs(SET_RUN_MULE) do GIDS_A_GARDER[g] = true end
for _, g in ipairs(CLEFS_RUN) do GIDS_A_GARDER[g] = true end
function nb(g) return tonumber(sur(function() return inventory:itemCount(g) end, 0)) or 0 end
function coffreOuvert()
    if enEchange() then return true end
    return sur(function() return exchange:storageKamas() end, nil) ~= nil
end
function attendre(cond, ms, pas)
    pas = pas or 100
    local t = 0
    while t < ms do if sur(cond, false) then return true end global:delay(pas) t = t + pas end
    return sur(cond, false) == true
end
function podsP() return tonumber(sur(function() return inventory:podsP() end, 0)) or 0 end
function sur(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function ici() return tonumber(sur(function() return map:currentMapId() end, 0)) or 0 end
function qteCoffre(g) return tonumber(sur(function() return exchange:storageItemQuantity(g) end, 0)) or 0 end
function idPerso() return tostring(sur(function() return character:id() end, "?")) end
function compte() return tostring(sur(function() return global:username() end, "?")) end
function info(m) global:printMessage("[PREPA] " .. m) end
function occupe() return sur(function() return character:isBusy() end, false) == true end
function alerte(m) global:printColor("#F39C12", "[PREPA] " .. m) end
function roleDuCompte()
    if lireMem("RS_PREPA_ROLE_" .. compte()) == "leader" then return "leader" end
    local l = lireMem("RS_EQUIPE_DE_" .. compte())
    if l ~= nil and l:match("^([^,]+)") == compte() then return "leader" end
    return "mule"
end
function enEchange() return sur(function() return exchange:isInExchange() end, false) == true end
function ecrireMem(c, v)
    pcall(function() developer:deleteFromGlobalMemory(c) end)
    pcall(function() developer:addInGlobalMemory(c, tostring(v)) end)
end
function lireMem(c)
    local v = sur(function() return developer:getInGlobalMemory(c) end, nil)
    if v == nil or tostring(v) == "" then return nil end
    return tostring(v)
end

ROLE = roleDuCompte()
function nomPerso() return tostring(sur(function() return character:name() end, "?")) end
function cleCoffre() return "RS_PREPA_COFFRE_" .. idPerso() end
FINI = false
function lignes(g)
    local n = 0
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            if tonumber(it.Item.Gid) == g then n = n + 1 end
        end
    end)
    return n
end
function terminer(etat, m)
    if etat == "1" and ROLE == "mule" then
        local manque = setManquant()
        if #manque > 0 then etat = "echec" m = m .. " — set de run INCOMPLET : " .. table.concat(manque, " ") end
    end
    ecrireMem("RS_PREPA_RUN_" .. compte(), etat)
    if nomPerso() ~= "?" and nomPerso() ~= compte() then ecrireMem("RS_PREPA_RUN_" .. nomPerso(), etat) end
    if etat == "1" then global:printSuccess("[PREPA] " .. m) else alerte(m) end
    FINI = true
    global:finishScript()
end
function present(g)
    local oui = false
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            if tonumber(it.Item.Gid) == g then oui = true break end
        end
    end)
    return oui
end
function setManquant()
    local l = {}
    for _, g in ipairs(SET_RUN_MULE) do if lignes(g) == 0 then l[#l + 1] = tostring(g) end end
    return l
end
DEMANDE = {}
function auCoffre()
    local e = lireMem(cleCoffre())
    if e == "1" then terminer("1", "coffre deja traite") return end
    if e == "tente" or e == "echec" then
        terminer("echec", "coffre deja tente (" .. e .. ") : pas de seconde ouverture (timeout 60 s). Effacer " .. cleCoffre() .. " puis relancer.")
        return
    end
    ecrireMem(cleCoffre(), "tente")
    pcall(function() npc:npcBank(-1) end)
    attendre(function() return coffreOuvert() or occupe() end, 5000)
    if not coffreOuvert() and occupe() then pcall(function() npc:reply(-1) end) attendre(coffreOuvert, 3000) end
    if not coffreOuvert() then
        ecrireMem(cleCoffre(), "echec")
        pcall(function() global:leaveDialog() end)
        terminer("echec", "le coffre ne s est pas ouvert : preparation a faire a la main")
        return
    end
    local garder, n = aGarder()
    local avant = podsP()
    if n > 0 then
        pcall(function() exchange:putAllItemsExcept(garder) end)
        attendre(function() return podsP() < avant end, 5000)
    end
    local pris = {}
    if ROLE == "mule" then
        for passe = 1, 2 do
            for _, g in ipairs(SET_RUN_MULE) do
                if prendreUnique(g) > 0 then pris[#pris + 1] = g .. "x1" end
            end
        end
        for _, g in ipairs(CLEFS_RUN) do
            local x = prendre(g, nil) if x > 0 then pris[#pris + 1] = g .. "x" .. x end
        end
    end
    if coffreOuvert() then pcall(function() exchange:leave() end) end
    attendre(function() return not coffreOuvert() end, 3000)
    pcall(function() global:leaveDialog() end)
    ecrireMem(cleCoffre(), "1")
    local manque = {}
    if ROLE == "mule" then manque = setManquant() end
    if #manque > 0 then alerte("set de run INCOMPLET (ni porte, ni au sac, ni au coffre) : " .. table.concat(manque, " ")) end
    local bilan = ROLE .. " : " .. n .. " ligne(s) deposee(s), pods " .. avant .. " % -> " .. podsP() .. " % ; retire : "
        .. (#pris > 0 and table.concat(pris, " ") or "rien")
    if ici() == BANQUE_ASTRUB then
        info(bilan .. " — sortie de la banque (trigger 424, juste apres ce custom)")
        return
    end
    terminer("1", bilan)
end
function aGarder()
    local garder, deposer = {}, 0
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local g = tonumber(it.Item.Gid)
            if g ~= nil and tonumber(it.Position) == 63 then
                local ty = tonumber(sur(function() return inventory:getTypeId(g) end, nil))
                if GIDS_A_GARDER[g] or (ty ~= nil and TYPES_A_GARDER[ty]) then garder[#garder + 1] = g
                else deposer = deposer + 1 end
            end
        end
    end)
    return garder, deposer
end
function prendreUnique(g)
    if lignes(g) > 0 then return 0 end
    if DEMANDE[g] and attendre(function() return lignes(g) > 0 end, 3000, 50) then return 1 end
    if qteCoffre(g) <= 0 then return 0 end
    if podsP() >= PODS_MAX_P then return 0 end
    DEMANDE[g] = true
    pcall(function() exchange:getItem(g, 1) end)
    if attendre(function() return lignes(g) > 0 end, 2000, 50) then return 1 end
    return 0
end
function quantitePermise(g, voulu)
    if podsP() >= PODS_MAX_P then return 0 end
    local w = tonumber(sur(function() return inventory:itemWeight(g) end, 0)) or 0
    if w <= 0 then return voulu end
    local maxi = tonumber(sur(function() return inventory:podsMax() end, 0)) or 0
    local pris = tonumber(sur(function() return inventory:pods() end, 0)) or 0
    if maxi <= 0 then return voulu end
    return math.max(0, math.min(voulu, math.floor((math.floor(maxi * PODS_MAX_P / 100) - pris) / w)))
end
function prendre(g, voulu)
    local reste = qteCoffre(g)
    if reste <= 0 then return 0 end
    local n = quantitePermise(g, math.min(voulu or reste, reste))
    if n <= 0 then return 0 end
    pcall(function() exchange:getItem(g, n) end)
    if not attendre(function() return qteCoffre(g) < reste end, 2000) and n > 1 then
        pcall(function() exchange:getItem(g, 1) end)
        attendre(function() return qteCoffre(g) < reste end, 2000)
    end
    return reste - qteCoffre(g)
end

pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/sortie-croca.lua") end)
function move()
    if FINI then return {} end
    do local s = sortieCroca and sortieCroca() if s then return s end end
    local m = ici()
    if m == BANQUE_ASTRUB and lireMem(cleCoffre()) == "1" and not FINI then
        return { { map = tostring(m), path = "424" } }
    end
    if m == CARTE_DEVANT_ASTRUB and lireMem(cleCoffre()) == "1" then
        return { { map = tostring(m), custom = function() terminer("1", "preparation faite, sorti de la banque d Astrub") end } }
    end
    if m == BANQUE_ASTRUB then return { { map = tostring(m), custom = auCoffre, path = "424" } } end
    if m == BANQUE_BONTA then return { { map = tostring(m), custom = auCoffre } } end
    if m == CARTE_DEVANT_ASTRUB then return { { map = tostring(m), door = tostring(PORTE_ASTRUB) } } end
    if m == ZAAP_ASTRUB then return { { map = tostring(m), path = "left" } } end
    if m == CARTE_HAVRE_SAC then return { { map = tostring(m), path = "zaap(" .. ZAAP_ASTRUB .. ")" } } end
    local zone = tostring(sur(function() return map:currentArea() end, ""))
    if zone == "Bonta" then
        return { { map = tostring(m), custom = function() pcall(function() map:moveToward(BANQUE_BONTA) end) end } }
    end
    if zone == "Astrub" then
        return { { map = tostring(m), custom = function() pcall(function() map:moveToward(CARTE_DEVANT_ASTRUB) end) end } }
    end
    return { { map = tostring(m), path = "havenbag" } }
end
function lost() return move() end
function phenix() return move() end
function bank() return move() end

info("preparation de la run (" .. ROLE .. ") : pods " .. podsP() .. " %")
if not ANTI_OCCUPE_INSTALLE and type(move) == "function" then
    ANTI_OCCUPE_INSTALLE = true
    local function aoSur(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
    local function aoCarte() return tostring(aoSur(function() return map:currentMapId() end, "")) end
    local function aoAttendre(cond, ms)
        local t = 0
        while t < ms do if aoSur(cond, false) then return true end global:delay(100) t = t + 100 end
        return aoSur(cond, false)
    end
    local function aoCombat() return aoSur(function() return character:isInFight() end, false) == true end
    function aoMessageOccupe()
        local L = aoSur(function() return global:consoleLines() end, nil)
        if type(L) ~= "table" then return false end
        for i = #L, math.max(1, #L - 3), -1 do
            if tostring(L[i] or ""):find("tes occup", 1, true) then return true end
        end
        return false
    end
    function aoDebloquer(raison)
        pcall(function() global:printMessage("[ANTI-OCCUPE] " .. tostring(raison) .. " -> leaveDialog + exchange:leave + petit pas") end)
        pcall(function() global:leaveDialog() end)
        pcall(function() exchange:leave() end)
        pcall(function() npc:leaveDialog() end)
        aoAttendre(function() return not aoSur(function() return character:isBusy() end, false) end, 1500)
        local c = tonumber(aoSur(function() return map:currentCell() end, -1)) or -1
        if c >= 0 then
            for _, d in ipairs({ 1, -1, 14, -14, 15, -15, 28, -28 }) do
                pcall(function() map:moveToCell(c + d) end)
                if aoAttendre(function() return (tonumber(aoSur(function() return map:currentCell() end, -1)) or -1) ~= c end, 1500) then break end
            end
        end
    end
    local function aoHavreSac()
        local avant = aoCarte()
        if aoMessageOccupe() or aoSur(function() return character:isBusy() end, false) then aoDebloquer("avant havre-sac") end
        for essai = 1, 3 do
            pcall(function() map:changeMap("havenbag") end)
            if aoAttendre(function() return aoCarte() ~= avant end, 4000) then return end
            aoDebloquer("havre-sac refuse (essai " .. essai .. ")")
        end
    end
    local moveOrigineAO = move
    function move(...)
        local actions = moveOrigineAO(...)
        if type(actions) ~= "table" then return actions end
        for _, e in ipairs(actions) do
            if type(e) == "table" and not e.aoEnv then
                e.aoEnv = true
                if e.path == "havenbag" and e.custom == nil and e.door == nil then
                    e.path = nil
                    e.custom = aoHavreSac
                elseif type(e.custom) == "function" then
                    local f = e.custom
                    e.custom = function(...)
                        local avant = aoCarte()
                        local r = f(...)
                        if aoCarte() == avant and not aoCombat() and aoMessageOccupe() then
                            aoDebloquer("action refusee")
                            r = f(...)
                        end
                        return r
                    end
                end
            end
        end
        return actions
    end
end

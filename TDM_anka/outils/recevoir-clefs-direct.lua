RECONNECT_ON_TIMEOUT = false
IGNORE_REQUEST_EXCHANGE = false
IGNORE_REQUEST_DUEL = true
CARTE_BANQUE = 217059328
ZAAP_BONTA, HAVRE = 217318404, 162791424
SUITE = global:getCurrentScriptDirectory() .. "\\..\\pl\\vers-croca.lua"
KIT = { 8143, 8545, 8437, 1568, 1570, 15991, 11799, 26680, 7918, 8139, 1569, 8135, 27374, 8917, 9254, 7927, 7511, 8320, 7908, 7926, 996 }
function ici() return tonumber(sur(function() return map:currentMapId() end, 0)) or 0 end
function sur(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function info(m) global:printMessage("[CLEFS] " .. m) end
function attendre(c, ms) local t = 0 while t < ms do if sur(c, false) then return true end global:delay(100) t = t + 100 end return sur(c, false) end
function paquet(n, j) return pcall(function() developer:sendMessage(developer:createMessageFromJson(n, j)) end) end
function enEchange() return sur(function() return exchange:isInExchange() end, false) == true end
function nb(g) return tonumber(sur(function() return inventory:itemCount(g) end, 0)) or 0 end

FINI = false
function bank() return move() end
function move()
    if FINI then return {} end
    local m = ici()
    if m == CARTE_BANQUE then return { { map = tostring(m), custom = recevoir } } end
    if m == HAVRE then return { { map = tostring(m), path = "zaap(" .. ZAAP_BONTA .. ")" } } end
    if tostring(sur(function() return map:currentArea() end, "")) == "Bonta" then
        return { { map = tostring(m), custom = function() pcall(function() map:moveToward(CARTE_BANQUE) end) end } }
    end
    return { { map = tostring(m), path = "havenbag" } }
end
function reprendre()
    FINI = true
    if not pcall(function() global:loadAndStart(SUITE) end) then global:printError("[CLEFS] relancer pl\\vers-croca.lua a la main") global:finishScript() end
end
function recevoir()
    pcall(function() exchange:leave() end) pcall(function() global:leaveDialog() end)
    local base = {}
    for _, g in ipairs(KIT) do base[g] = nb(g) end
    info("attente de l echange du compte banque")
    if attendre(enEchange, 900000) then
        paquet("kax", "{}")
        global:delay(12000)
        if enEchange() then pcall(function() exchange:ready() end) end
        if not attendre(function() return not enEchange() end, 40000) and enEchange() then
            pcall(function() exchange:ready() end)
            attendre(function() return not enEchange() end, 40000)
        end
    else
        global:printError("[CLEFS] aucun echange en 15 min")
    end
    local recu = {}
    for _, g in ipairs(KIT) do if nb(g) > base[g] then recu[#recu + 1] = g .. ":" .. (nb(g) - base[g]) end end
    global:printSuccess("[CLEFS] recu " .. (#recu > 0 and table.concat(recu, ",") or "RIEN") .. " ; reprise du PL Croca")
    reprendre()
end
function lost() return move() end

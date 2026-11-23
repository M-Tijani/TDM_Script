RECONNECT_ON_TIMEOUT = false
FIGHT_KICK = 0
IGNORE_REQUEST_DUEL = true
IGNORE_REQUEST_EXCHANGE = true
NIVEAU_CIBLE = NIVEAU_COFFRE or 11
VIE_MIN_POUR_COMBATTRE = 80
CONFIG_NIV1 = global:getCurrentScriptDirectory() .. "\\..\\xml\\SACRI LVL1 PIOU.xml"
ZAAP_ASTRUB = 191105026
function zone() return tostring(sur(function() return map:currentArea() end, "")) end
function niveau() return tonumber(sur(function() return character:level() end, 0)) or 0 end
function ici() return tostring(sur(function() return map:currentMapId() end, "")) end
function sur(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function vie() return tonumber(sur(function() return character:lifePointsP() end, 100)) or 100 end
function info(m) global:printMessage("[NIV10] " .. m) end
CONFIG_CHARGEE = false
function fini()
    local id = tostring(sur(function() return character:id() end, "0"))
    pcall(function()
        developer:deleteFromGlobalMemory("RS_NIV10_" .. id)
        developer:addInGlobalMemory("RS_NIV10_" .. id, "1")
    end)
    global:printSuccess("[NIV10] niveau " .. niveau() .. " atteint : fin du script")
    global:finishScript()
end
function placerLesPoints()
    local n = tonumber(sur(function() return character:statsPoint() end, 0)) or 0
    if n > 0 then pcall(function() character:upgradeVitality(n) end) end
end
function reglerLesGroupes()
    MIN_MONSTERS = 1
    MAX_MONSTERS = (niveau() >= 5) and 3 or 2
end
function npcVersAstrub()
    pcall(function() npc:npc(4398, 3) end) global:delay(1000)
    pcall(function() npc:reply(-1) end) global:delay(1000)
    pcall(function() npc:reply(-1) end) global:delay(1000)
    pcall(function() npc:leaveDialog() end)
end
function handleNpc()
    global:delay(1000)
    if sur(function() return character:isBusy() end, false) then
        pcall(function() npc:reply(-1) end) global:delay(1000)
        pcall(function() npc:reply(-1) end) global:delay(1000)
    end
end
function attendreLaVie()
    local essais = 0
    while vie() < VIE_MIN_POUR_COMBATTRE and essais < 120 do
        if essais == 0 then info("vie a " .. vie() .. " % : on attend " .. VIE_MIN_POUR_COMBATTRE .. " %") end
        global:delay(5000)
        essais = essais + 1
    end
end
function chargerConfig()
    if CONFIG_CHARGEE then return end
    CONFIG_CHARGEE = true
    local ok = pcall(function() global:loadConfigurationWithoutScript(CONFIG_NIV1) end)
    info("config niveau 1 " .. CONFIG_NIV1 .. (ok and " chargee" or " : ECHEC du chargement (config actuelle gardee)"))
end

TRAJET_INCARNAM = {
    { map = "241443329", path = "right" },
    { map = "241444353", path = "right" },
    { map = "241445377", custom = handleNpc, door = "475" },
    { map = "154010883", path = "right" },
    { map = "154010371", path = "right" },
    { map = "153878787", path = "right" },
    { map = "153879299", path = "right" },
    { map = "153879811", path = "right" },
    { map = "153880323", path = "right" },
    { map = "153880835", custom = npcVersAstrub },
}
CASES = {
    { "5,-19", "left" }, { "4,-19", "left" }, { "3,-19", "bottom" }, { "3,-18", "left" },
    { "2,-18", "top" }, { "2,-19", "top" }, { "2,-20", "right" }, { "3,-20", "right" },
    { "4,-20", "right" }, { "5,-20", "right" }, { "6,-20", "right" }, { "7,-20", "top" },
    { "7,-21", "left" }, { "6,-21", "left" }, { "5,-21", "left" }, { "4,-21", "left" },
    { "3,-21", "left" }, { "2,-21", "left" }, { "1,-21", "bottom" }, { "1,-20", "bottom" },
    { "1,-19", "bottom" }, { "1,-18", "bottom" }, { "1,-17", "right" }, { "2,-17", "bottom" },
    { "2,-16", "left" }, { "1,-16", "bottom" }, { "1,-15", "right" }, { "2,-15", "right" },
    { "3,-15", "top" }, { "3,-16", "right" }, { "4,-16", "bottom" }, { "4,-15", "right" },
    { "5,-15", "top" }, { "5,-16", "right" }, { "6,-16", "bottom" }, { "6,-15", "right" },
    { "7,-15", "top" }, { "7,-16", "top" }, { "7,-17", "top" }, { "7,-18", "left" },
    { "6,-18", "bottom" }, { "6,-17", "left" }, { "5,-17", "left" }, { "4,-17", "top" },
    { "4,-18", "right" }, { "5,-18", "top" },
}
function phenix() return move() end
function circuit()
    local trajet, dedans = {}, {}
    for _, c in ipairs(CASES) do
        trajet[#trajet + 1] = { map = c[1], path = c[2], fight = true }
        dedans[c[1]] = true
    end
    local pos = tostring(sur(function() return map:currentMap() end, ""))
    if pos ~= "" and pos ~= "0,0" and not dedans[pos] then
        return { { map = ici(), custom = function()
            info("hors du circuit (" .. pos .. ") : autopilote vers les Pious (5,-19)")
            pcall(function() map:moveToward(5, -19) end)
        end } }
    end
    return trajet
end
function lost() return move() end
function move()
    chargerConfig()
    placerLesPoints()
    if niveau() >= NIVEAU_CIBLE then
        return { { map = ici(), custom = fini } }
    end
    if zone() == "Incarnam" then
        for _, e in ipairs(TRAJET_INCARNAM) do if e.map == ici() then return TRAJET_INCARNAM end end
        return { { map = ici(), custom = function() pcall(function() map:moveToward(153880835) end) end } }
    end
    reglerLesGroupes()
    attendreLaVie()
    return circuit()
end
function bank() return move() end

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

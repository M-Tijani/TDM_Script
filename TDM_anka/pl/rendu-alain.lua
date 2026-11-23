FIGHT_KICK = 0
CARTE_HAVRE_SAC = 162791424
CARTE_ALAIN = 99091977
function fait() return tostring(sur(function() return developer:getInGlobalMemory("RS_RENDU_ALAIN_" .. moi()) end, "")) == "1" end
function sur(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end
function ici() return tonumber(sur(function() return map:currentMapId() end, 0)) or 0 end
function marquer()
    pcall(function()
        local k = "RS_RENDU_ALAIN_" .. moi()
        if developer:getInGlobalMemory(k) ~= nil then developer:editInGlobalMemory(k, "1") else developer:addInGlobalMemory(k, "1") end
    end)
end
function attendre(cond, ms)
    local t = 0
    while t < ms do
        if sur(cond, false) then return true end
        global:delay(100); t = t + 100
    end
    return sur(cond, false)
end
function bank() return move() end
function moi() return sur(function() return global:thisAccountController():getUsername() end, "?") end
function move()
    local m = ici()
    if fait() then
        global:printSuccess("[RENDU] « C'est radical ici » rendu a Alain Deix")
        global:finishScript()
        return { { map = tostring(m), custom = function() end } }
    end
    if m == CARTE_ALAIN then
        return { { map = tostring(m), custom = function()
            pcall(function() global:leaveDialog() end)
            pcall(function() npc:npc(1578, 3) end)
            global:delay(1500)
            pcall(function() npc:reply(-1) end)
            global:delay(1500)
            pcall(function() global:leaveDialog() end)
            marquer()
            global:printSuccess("[RENDU] dialogue Alain Deix fait")
        end } }
    end
    if m == CARTE_HAVRE_SAC then return { { map = tostring(m), path = "zaap(68419587)" } } end
    local d = tonumber(sur(function() return map:GetPathDistance(m, CARTE_ALAIN) end, 99)) or 99
    if d > 12 then return { { map = tostring(m), path = "havenbag" } } end
    return { { map = tostring(m), custom = function()
        pcall(function() global:leaveDialog() end)
        pcall(function() map:moveToward(CARTE_ALAIN) end)
        attendre(function() return ici() ~= m end, 4000)
    end } }
end
function phenix() return move() end

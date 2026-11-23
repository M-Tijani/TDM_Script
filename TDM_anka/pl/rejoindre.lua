FIGHT_KICK = 0
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/deblocage.lua") end)
CARTE_HAVRE_SAC = 162791424
function ici() return tonumber(sur(function() return map:currentMapId() end, 0)) or 0 end
function phenix() return move() end
function cible()
    local n = sur(function() return global:thisAccountController():getUsername() end, "")
    return tonumber(sur(function() return developer:getInGlobalMemory("RS_REJOINDRE_" .. n) end, nil))
end
function move()
    do local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end end
    local m, c = ici(), cible()
    if c == nil or m == c then
        global:printSuccess("[REJOINDRE] sur la carte du leader")
        global:finishScript()
        return { { map = tostring(m), custom = function() end } }
    end
    if m == CARTE_HAVRE_SAC then
        return { { map = tostring(m), custom = function()
            local z = tonumber(sur(function() return map:closestZaapV2(c) end, 0)) or 0
            if z > 0 then pcall(function() map:toZaap(z, 3) end) else pcall(function() global:leaveDialog() end) end
            local t = 0
            while t < 5000 and ici() == CARTE_HAVRE_SAC do global:delay(100); t = t + 100 end
        end } }
    end
    local d = tonumber(sur(function() return map:GetPathDistance(m, c) end, 0)) or 0
    if d > 8 then
        return { { map = tostring(m), custom = function()
            pcall(function() map:changeMap("havenbag") end)
            local t = 0
            while t < 3000 and ici() == m do global:delay(100); t = t + 100 end
            if ici() == m then
                pcall(function() developer:sendMessage(developer:createMessage("DungeonQuitRequest")) end)
                t = 0
                while t < 5000 and ici() == m do global:delay(100); t = t + 100 end
            end
        end } }
    end
    return { { map = tostring(m), custom = function() pcall(function() map:moveToward(c) end) end } }
end
function bank() return move() end
function sur(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end

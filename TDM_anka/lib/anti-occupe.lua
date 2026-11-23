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

function sortieCroca()
    local m = scIci()
    if m < 198968000 or m > 198972999 then return nil end
    return { { map = tostring(m), custom = function()
        for essai = 1, 3 do
            if m == 198972418 then
                pcall(function() npc:npc(789, 3) end)
                pcall(function() npc:reply(-1) end)
            else
                pcall(function() developer:sendMessage(developer:createMessageFromJson("kgy", '{"fzcf":false}')) end)
            end
            local t = 0
            while t < 4000 and scIci() == m do global:delay(50) t = t + 50 end
            if scIci() ~= m then return end
            pcall(function() global:leaveDialog() end)
        end
        pcall(function() global:restartScript() end)
    end } }
end
local function scIci() local m = 0 pcall(function() m = tonumber(map:currentMapId()) end) return m end

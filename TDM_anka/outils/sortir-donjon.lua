function move()
    return { { map = tostring(map:currentMapId()), custom = function()
        local avant = map:currentMapId()
        pcall(function() global:leaveDialog() end)
        pcall(function() developer:sendMessage(developer:createMessage("DungeonQuitRequest")) end)
        local t = 0
        while t < 6000 and map:currentMapId() == avant do global:delay(100) t = t + 100 end
        global:printSuccess("[SORTIE] donjon quitte : " .. tostring(avant) .. " -> " .. tostring(map:currentMapId()))
        global:finishScript()
    end } }
end

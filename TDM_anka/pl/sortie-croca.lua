FIGHT_KICK = 0
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/sortie-croca.lua") end)
function bank() return move() end
function move()
    local s = sortieCroca and sortieCroca()
    if s then return s end
    global:printSuccess("[SORTIE-CROCA] hors des salles (carte " .. tostring(map:currentMapId()) .. ")")
    global:finishScript()
    return {}
end
function lost() return move() end

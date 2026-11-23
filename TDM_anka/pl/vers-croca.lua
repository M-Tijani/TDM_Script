FIGHT_KICK = 0
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/deblocage.lua") end)
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/sans-havre-sac.lua") end)
ZAAP_SCARA = 88212481
ENTREE_CROCA = 198967296
CARTE_HAVRE_SAC = 162791424
function arrive()
    local id = tostring(character:id())
    pcall(function()
        if developer:getInGlobalMemory("RS_CROCA_ARRIVE_" .. id) ~= nil then developer:editInGlobalMemory("RS_CROCA_ARRIVE_" .. id, "1")
        else developer:addInGlobalMemory("RS_CROCA_ARRIVE_" .. id, "1") end
    end)
    global:printSuccess("[CROCA] arrive devant le Croca")
    global:finishScript()
end
function ici() local m = 0; pcall(function() m = tonumber(map:currentMapId()) end); return m end

TRAJET_CROCA = {
    { map = "88212481", path = "left" },
    { map = "84412416", path = "left" },
    { map = "84411904", path = "left" },
    { map = "84411392", door = "202" },
    { map = "199230724", door = "274" },
    { map = "198181888", path = "right" },
    { map = "198182400", path = "right" },
    { map = "198182912", path = "bottom" },
    { map = "198182913", door = "319" },
    { map = "198967296", custom = arrive },
}
function bank() return move() end
function move()
    do local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end end
    local m = ici()
    for _, e in ipairs(TRAJET_CROCA) do
        if tonumber(e.map) == m then return { e } end
    end
    if m == CARTE_HAVRE_SAC then return { { map = tostring(m), path = "zaap(" .. ZAAP_SCARA .. ")" } } end
    local t = zaapSansHavre and zaapSansHavre(ZAAP_SCARA)
    if t then return t end
    return { { map = tostring(m), path = "havenbag" } }
end
function phenix() return move() end
function lost() return (perduSansHavre and perduSansHavre(ZAAP_SCARA)) or move() end

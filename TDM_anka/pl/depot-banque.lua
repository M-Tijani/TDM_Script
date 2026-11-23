FIGHT_KICK = 0
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/deblocage.lua") end)
GIDS_A_GARDER = { 10207, 7423, 7425, 996, 15990, 8343, 7927, 12073, 8151, 6965 }
for _, x in ipairs({ 8342, 8143, 8545, 8437, 1568, 1570, 15991, 11799, 26680, 7918, 8139, 1569, 8135, 27374, 12017, 8917, 9248, 9254, 11798, 14464, 7927, 8343, 12073, 7557, 7511, 8320, 7908, 8156, 8439, 8438, 7926, 11174, 7924, 8142, 996, 7423 }) do GIDS_A_GARDER[#GIDS_A_GARDER + 1] = x end
CARTE_HAVRE_SAC = "162791424"
function sur(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end
function attendre(cond, maxMs)
    local t = 0
    while t <= maxMs do
        if sur(cond, false) then return true end
        global:delay(50); t = t + 50
    end
    return false
end
function podsP() return tonumber(sur(function() return inventory:podsP() end, 0)) or 0 end
SASA_MULE = { 732, 835, 712, 2390, 1487, 2532, 7131, 1665, 18667 }
for _, x in ipairs(SASA_MULE) do GIDS_A_GARDER[#GIDS_A_GARDER + 1] = x end
for _, x in ipairs({ 972, 34615, 8342 }) do GIDS_A_GARDER[#GIDS_A_GARDER + 1] = x end
for _, x in ipairs({ 8262, 16169, 8263, 13851, 8470, 8471, 8847, 8265, 33044, 737, 694, 17078, 12724, 13759, 13829,
                     18686, 14848, 1019, 1021 }) do GIDS_A_GARDER[#GIDS_A_GARDER + 1] = x end
TYPES_A_GARDER = { [84] = true, [24] = true, [18] = true, [121] = true }
function gidsAGarder()
    local g = {}
    for _, x in ipairs(GIDS_A_GARDER) do g[#g + 1] = x end
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local gid = tonumber(it.Item.Gid)
            if gid ~= nil and tonumber(it.Position) == 63 then
                local tn = string.lower(tostring(sur(function() return inventory:getTypeName(gid) end, "")))
                local ty = tonumber(sur(function() return inventory:getTypeId(gid) end, nil))
                if tn:find("qu.-te") or tn:find("clef") or tn:find("familier") or tn:find("montilier")
                   or (ty ~= nil and TYPES_A_GARDER[ty]) then
                    g[#g + 1] = gid
                end
            end
        end
    end)
    return g
end
DEPOT_FAIT = false
function deposer()
    if DEPOT_FAIT then global:finishScript() return end
    DEPOT_FAIT = true
    local avant = podsP()
    pcall(function() npc:npcBank(-1) end)
    if not attendre(function() return exchange:storageKamas() ~= nil end, 5000) then
        pcall(function() npc:reply(-1) end)
        attendre(function() return exchange:storageKamas() ~= nil end, 3000)
    end
    pcall(function() exchange:putAllItemsExcept(gidsAGarder()) end)
    attendre(function() return podsP() < avant end, 5000)
    pcall(function() exchange:leave() end)
    pcall(function() global:leaveDialog() end)
    global:printSuccess("[BANQUE] depot : " .. avant .. " % -> " .. podsP() .. " %")
    if podsP() >= 85 then
        global:printColor("#F39C12", "[BANQUE] encore " .. podsP() .. " % de pods apres le depot (objets gardes trop lourds ?) : a verifier")
    end
    global:finishScript()
end
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/sortie-croca.lua") end)
function bank() return move() end
function phenix() return move() end
function move()
    do local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end end
    do local s = sortieCroca and sortieCroca() if s then return s end end
    local m = tostring(sur(function() return map:currentMapId() end, ""))
    if m == "192415750" then return { { map = m, custom = deposer } } end
    if m == "191104002" then return { { map = m, door = "288" } } end
    if m == "191105026" then return { { map = m, path = "left" } } end
    if m == CARTE_HAVRE_SAC then return { { map = m, path = "zaap(191105026)" } } end
    return { { map = m, custom = function()
        pcall(function() global:leaveDialog() end)
        pcall(function() exchange:leave() end)
        if sur(function() return map:changeMap("havenbag") end, false) and attendre(function() return tostring(map:currentMapId()) ~= m end, 2500) then return end
        local cellules = sur(function() return map:getWalkableCells() end, nil)
        local liste = {}
        pcall(function() for _, c in ipairs(cellules) do liste[#liste + 1] = c end end)
        if #liste > 0 then
            pcall(function() map:moveToCell(liste[math.random(1, #liste)]) end)
            global:delay(800)
        end
        pcall(function() map:changeMap("havenbag") end)
        attendre(function() return tostring(map:currentMapId()) ~= m end, 2500)
    end } }
end

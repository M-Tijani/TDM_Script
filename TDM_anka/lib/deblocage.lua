BLOCAGE_SEUIL = BLOCAGE_SEUIL or 4
SURVEILLANCE_BLOCAGE = (SURVEILLANCE_BLOCAGE ~= false)
BLOCAGE = BLOCAGE or { carte = nil, n = 0, essais = 0 }
function surveillerBlocage()
    if not SURVEILLANCE_BLOCAGE then return nil end
    if surB(function() return character:isInFight() end, false) then BLOCAGE.n = 0 return nil end
    if surB(function() return global:afterFight() end, false) then BLOCAGE.n = 0 return nil end
    local c = tostring(surB(function() return map:currentMapId() end, ""))
    if c ~= BLOCAGE.carte then
        BLOCAGE.carte, BLOCAGE.n, BLOCAGE.essais = c, 0, 0
        return nil
    end
    BLOCAGE.n = BLOCAGE.n + 1
    if BLOCAGE.n < BLOCAGE_SEUIL then return nil end
    BLOCAGE.n = 0
    BLOCAGE.essais = BLOCAGE.essais + 1
    local niveau = math.min(3, BLOCAGE.essais)
    return { { map = c, custom = function() debloquer(niveau) end } }
end
function fermerInterfaces()
    pcall(function() global:leaveDialog() end)
    pcall(function() exchange:leave() end)
end
function debloquer(niveau)
    niveau = niveau or 1
    pcall(function() global:printColor("#F39C12", "[DEBLOCAGE] niveau " .. niveau .. " sur la carte " .. tostring(surB(function() return map:currentMapId() end, "?"))) end)
    fermerInterfaces()
    if niveau >= 2 then pasAleatoire() end
    if niveau >= 3 then pcall(function() global:reconnectSec(5) end) end
end
function pasAleatoire()
    local cellules = surB(function() return map:getWalkableCells() end, nil)
    local liste = {}
    pcall(function() for _, c in ipairs(cellules) do liste[#liste + 1] = c end end)
    if #liste == 0 then return false end
    local ici = surB(function() return map:currentCell() end, -1)
    for _ = 1, 3 do
        local c = liste[math.random(1, #liste)]
        if c ~= ici then
            pcall(function() map:moveToCell(c) end)
            local t = 0
            while t < 2500 and surB(function() return map:currentCell() end, ici) == ici do global:delay(50); t = t + 50 end
            if surB(function() return map:currentCell() end, ici) ~= ici then return true end
        end
    end
    return false
end
local function surB(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end

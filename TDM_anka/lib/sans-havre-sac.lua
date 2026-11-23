ZSH_ZAAPS_CONNUS = { [191105026] = true, [88212481] = true }
local function zshIci() local m = 0 pcall(function() m = tonumber(map:currentMapId()) end) return m end
function zshNiveau() local n = 0 pcall(function() n = tonumber(character:level()) or 0 end) return n end
ZSH_ROUTE = { ["9,-2"] = "top", ["9,-3"] = "left", ["8,-3"] = "left", ["7,-3"] = "top" }
local function zshPos() local p = "" pcall(function() p = tostring(map:currentMap()) end) return p end
function perduSansHavre(cible)
    if zshNiveau() >= 10 then return nil end
    local m = zshIci()
    return { { map = tostring(m), custom = function()
        pcall(function() global:printMessage("[SANS-HAVRE] carte " .. m .. " (" .. zshPos() .. ") : a pied vers un zaap (niv < 10)") end)
        for essai = 1, 4 do
            local vers = (essai <= 2) and cible or 191105026
            pcall(function() map:moveToward(vers) end)
            local t = 0
            while t < 1500 and zshIci() == m do global:delay(50) t = t + 50 end
            if zshIci() ~= m then return end
            pcall(function() global:leaveDialog() end)
        end
        pcall(function() global:restartScript(false) end)
    end } }
end
function zaapSansHavre(cible)
    if zshNiveau() >= 10 then return nil end
    local m = zshIci()
    if m == cible then return nil end
    if ZSH_ZAAPS_CONNUS[m] or zshPos() == "7,-4" then return { { map = tostring(m), path = "zaap(" .. cible .. ")" } } end
    if m == 106169344 then return { { map = tostring(m), path = "471" } } end
    local dir = ZSH_ROUTE[zshPos()]
    if dir then return { { map = tostring(m), path = dir } } end
    return perduSansHavre(cible)
end

CLEFS_CROCA_LEADER = 80
dofile(global:getCurrentScriptDirectory() .. "\\..\\pl\\depart-mule.lua")
KIT_MULE = { { gid = 8342, q = CLEFS_CROCA_LEADER } }
KAMAS_MULE = 0
CLEFS_PAR_DONJON = 1
CLEFS_NON_ECHANGEABLES = { [7423] = true }
local clefsRun = {}
if #clefsRun == 0 then
    clefsRun = { 8143, 8545, 8437, 1568, 1570, 15991, 11799, 26680, 7918, 8139, 1569, 8135, 27374, 12017, 8917, 9248, 9254,
                 11798, 14464, 7927, 8343, 12073, 7557, 7511, 8320, 7908, 8156, 8439, 8438, 7926, 11174, 7924, 8142, 996, 7423 }
end
local vus = { [8342] = true }
for _, g in ipairs(clefsRun) do
    if not vus[g] then
        vus[g] = true
        if CLEFS_NON_ECHANGEABLES[g] then
            if nb(g) < CLEFS_PAR_DONJON then global:printColor("#F39C12", "[FIN-RUN CLEFS] " .. g .. " lie au compte : a reprendre au coffre du compte (" .. nb(g) .. "/" .. CLEFS_PAR_DONJON .. "), pas demande au compte banque") end
        else KIT_MULE[#KIT_MULE + 1] = { gid = g, q = CLEFS_PAR_DONJON } end
    end
end
global:printMessage("[FIN-RUN CLEFS] " .. monNom() .. " : clefs du Croca a " .. CLEFS_CROCA_LEADER .. " (au sac : " .. nb(8342) .. ") + " .. (#KIT_MULE - 1) .. " clefs de donjon x" .. CLEFS_PAR_DONJON .. " ; manque : " .. besoin())
STAGNATION_MAX_S = 12 * 60
do
    local tourOrig = unTour
    local function heure() return tonumber((tostring(os.time()):gsub(",", "."))) or 0 end
    local dernierBesoin, depuis = nil, heure()
    unTour = function(n)
        tourOrig(n)
        local b = besoin()
        if b ~= dernierBesoin then dernierBesoin = b; depuis = heure() return end
        if b ~= "" and nb(8342) >= CLEFS_CROCA_LEADER and (heure() - depuis) > STAGNATION_MAX_S then
            mem("FRL_MANQUE_" .. moi(), b)
            global:printColor("#E74C3C", "[FIN-RUN CLEFS] compte banque sans stock pour : " .. b .. " -> leader termine avec ce manque (a crafter)")
            kitTermine()
        end
    end
end

FRAIS_KAMAS = 2500
dofile(global:getCurrentScriptDirectory() .. "\\..\\pl\\depart-mule.lua")
KIT_MULE = {}
KAMAS_MULE = FRAIS_KAMAS
MARGE_KAMAS = 500
function kitTermine()
    local n = monNom()
    if dansUnEchange() then fermerEchange() end
    mem("KIT_PRET_" .. n, 0)
    mem("KIT_MPOSE_" .. n, 0)
    mem("KIT_BESOIN_" .. n, "")
    mem("KIT_RECU_" .. n, 1)
    mem("FRK_" .. moi(), 1)
    global:printSuccess("[FIN-RUN FRAIS] " .. n .. " : " .. kamas() .. " kamas en poche (frais du coffre)")
    FINI = true
    global:finishScript()
end
global:printMessage("[FIN-RUN FRAIS] " .. monNom() .. " : frais du coffre demandes au compte banque (" .. kamas() .. " kamas en poche)")

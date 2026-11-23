CLEFS_CROCA_MULE = 50
dofile(global:getCurrentScriptDirectory() .. "\\..\\pl\\depart-mule.lua")
KIT_MULE = { { gid = 8342, q = CLEFS_CROCA_MULE } }
KAMAS_MULE = 0
global:printMessage("[FIN-RUN CLEFS MULE] " .. monNom() .. " : clefs du Croca a completer a " .. CLEFS_CROCA_MULE .. " (au sac : " .. nb(8342) .. ")")

charger("etapes\\lib_donjons.lua", true)
local ETAPE = {
    cle    = "donjons_maitre_des_clefs",
    nom    = "Kal Vissi (fin de la run, sans le Maitre des clefs)",
    succes = {},
    validee = function() return lireEtat("DONJONS_FIN") == "1" or lireEtat("QUETE_donjons_maitre_des_clefs") == "1" end,
    acces  = "aucun",
}
ETAPE.quete = trajetVersKal(ETAPE.cle, true)
ETAPES[#ETAPES + 1] = ETAPE

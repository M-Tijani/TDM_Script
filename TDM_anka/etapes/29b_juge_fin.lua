charger("etapes\\lib_juge.lua", true)
local ETAPE = {
    cle    = "juge_fin",
    nom    = "Retour chez Chris de Naire (fin du Juge hysterique)",
    succes = {},
    validee = function() return lireEtat("JUGE_FIN") == "1" end,
    acces  = "aucun",
}
ETAPE.quete = trajetVersChris(ETAPE.cle)
ETAPE.quete[#ETAPE.quete].custom = function()
    parler(JUGE_PNJ_CHRIS, { -1, -1 })
    ecrireEtat("QUETE_" .. ETAPE.cle, 1)
    ecrireEtat("JUGE_FIN", 1)
end
ETAPES[#ETAPES + 1] = ETAPE

RECONNECT_ON_TIMEOUT = false
FIGHT_KICK = 0
IGNORE_REQUEST_DUEL = true
IGNORE_REQUEST_EXCHANGE = true
PREFIXE = "[FIN-RUN REPRISE]"
DOSSIER_FR = global:getCurrentScriptDirectory()
dofile(DOSSIER_FR .. "\\fin-run-commun.lua")
CLEFS_CROCA_VOULUES = 50
KAMAS_VOULUS = KAMAS_MULE or 40000
OBJETS_UNIQUES = {}
do
    local vu = {}
    for _, e in ipairs(KIT_SASA or {}) do
        local g = tonumber(e.gid)
        if g and g ~= 8342 and not vu[g] then vu[g] = true OBJETS_UNIQUES[#OBJETS_UNIQUES + 1] = g end
    end
    for _, g in ipairs(SET_RUN_MULE or { 8463, 8464, 8465, 8466, 8467, 8468, 250, 1499, 18687 }) do
        g = tonumber(g)
        if g and not vu[g] then vu[g] = true OBJETS_UNIQUES[#OBJETS_UNIQUES + 1] = g end
    end
end
FINI = false
function terminer(etat, m)
    ecrireMem("FRR_" .. monId(), etat)
    if etat == "1" then global:printSuccess(PREFIXE .. " " .. m) else alerte(m) end
    FINI = true
    global:finishScript()
end
DEMANDE = {}
function lost() return move() end
function phenix() return move() end
function move()
    if FINI then return {} end
    local niv = tonumber(sur(function() return character:level() end, 0)) or 0
    if niv > 0 and niv <= 10 then terminer("echec", monNom() .. " niveau " .. niv .. " : coffre inaccessible (<= 10) : montee UP10 d abord (orchestre)") return {} end
    return trajetBanque(auCoffre)
end
function prendreUnique(g)
    if lignes(g) > 0 then return 0 end
    if DEMANDE[g] and attendre(function() return lignes(g) > 0 end, 3000) then return 1 end
    if (tonumber(sur(function() return exchange:storageItemQuantity(g) end, 0)) or 0) <= 0 then return 0 end
    if podsP() >= 95 then return 0 end
    DEMANDE[g] = true
    pcall(function() exchange:getItem(g, 1) end)
    if attendre(function() return lignes(g) > 0 end, 2000) then return 1 end
    return 0
end
function auCoffre()
    if FINI then return end
    local e = lireMem("FRR_COFFRE_" .. monId())
    if e == "1" then terminer("1", "coffre deja traite pour " .. monNom()) return end
    ecrireMem("FRR_COFFRE_" .. monId(), "tente")
    if not ouvrirCoffre() then terminer("echec", "le coffre ne s ouvre pas (kamas " .. kamas() .. ", niveau " .. tostring(sur(function() return character:level() end, "?")) .. ") : AUCUN repli par le compte banque, l orchestre bloque") return end
    local pris = {}
    for passe = 1, 2 do
        for _, g in ipairs(OBJETS_UNIQUES) do if prendreUnique(g) > 0 then pris[#pris + 1] = tostring(g) end end
    end
    local manqueClefs = CLEFS_CROCA_VOULUES - qteSac(8342)
    local auCoffreClefs = tonumber(sur(function() return exchange:storageItemQuantity(8342) end, 0)) or 0
    local clefs = 0
    if manqueClefs > 0 and auCoffreClefs > 0 then clefs = sortirDuCoffre(8342, math.min(manqueClefs, auCoffreClefs), 95) end
    local clefsDonjon = 0
    for g in pairs(CLEFS_MULE_A_DONNER or {}) do
        local q = tonumber(sur(function() return exchange:storageItemQuantity(g) end, 0)) or 0
        if q > 0 and podsP() < 90 then clefsDonjon = clefsDonjon + (sortirDuCoffre(g, q, 90) or 0) end
    end
    if clefsDonjon > 0 then global:printSuccess(PREFIXE .. " " .. clefsDonjon .. " clef(s) de donjon reprises du coffre (pour le compte banque)") end
    local kk = math.min(KAMAS_VOULUS - kamas(), kamasCoffre())
    if kk > 0 then
        local av = kamas()
        pcall(function() exchange:getKamas(kk) end)
        attendre(function() return kamas() > av end, 2000)
    end
    fermerCoffre()
    ecrireMem("FRR_COFFRE_" .. monId(), "1")
    local manque = {}
    for _, g in ipairs(OBJETS_UNIQUES) do if lignes(g) == 0 then manque[#manque + 1] = tostring(g) end end
    ecrireMem("FRR_MANQUE_" .. monId(), #manque > 0 and table.concat(manque, " ") or "0")
    terminer("1", monNom() .. " : repris " .. #pris .. " objet(s), " .. clefs .. " clef(s) Croca (" .. qteSac(8342) .. " au sac), "
        .. kamas() .. " kamas" .. (#manque > 0 and (" ; ABSENTS du coffre (le compte banque ne les donne PAS) : " .. table.concat(manque, " ")) or ""))
end
function bank() return move() end

info(monNom() .. " : reprise du kit au coffre du compte")
pcall(function() dofile(DOSSIER_FR .. "\\..\\lib\\anti-occupe.lua") end)

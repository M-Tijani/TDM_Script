RECONNECT_ON_TIMEOUT = false
FIGHT_KICK = 0
IGNORE_REQUEST_DUEL = true
IGNORE_REQUEST_EXCHANGE = true
PREFIXE = "[FIN-RUN DEPOT]"
DOSSIER_FR = global:getCurrentScriptDirectory()
dofile(DOSSIER_FR .. "\\fin-run-commun.lua")
KAMAS_COFFRE = KAMAS_MULE or 40000
FRAIS_POCHE  = 5000
ROLE = roleDuCompte()
FINI = false
function bank() return move() end
function phenix() return move() end
function auCoffre()
    if FINI then return end
    if lireMem("FRD_COFFRE_" .. monId()) == "1" and protegesAuSac() == 0 and deshabiller() then terminer("1", "coffre deja traite pour " .. monNom()) return end
    if not deshabiller() then terminer("echec", "des objets restent portes (deshabillage) : rien depose") return end
    ecrireMem("FRD_COFFRE_" .. monId(), "tente")
    if not ouvrirCoffre() then terminer("echec", "le coffre ne s ouvre pas (kamas pour les frais ? " .. kamas() .. ")") return end
    local garder, vu, nProt = {}, {}, 0
    for _, x in ipairs(contenu()) do
        if x.p == 63 and x.g and not vu[x.g] then
            vu[x.g] = true
            if protege(x.g) then nProt = nProt + 1 else garder[#garder + 1] = x.g end
        end
    end
    if nProt > 0 then deposerSaufListe(garder) end
    local k = math.min(kamas() - FRAIS_POCHE, KAMAS_COFFRE - kamasCoffre())
    if k > 0 then
        local avant = kamas()
        pcall(function() exchange:putKamas(k) end)
        attendre(function() return kamas() < avant end, 3000)
    end
    local manque = {}
    for _, g in ipairs(SET_RUN_MULE or { 8463, 8464, 8465, 8466, 8467, 8468, 250, 1499, 18687 }) do
        if (tonumber(sur(function() return exchange:storageItemQuantity(g) end, 0)) or 0) < 1 then manque[#manque + 1] = tostring(g) end
    end
    local clefs = tonumber(sur(function() return exchange:storageItemQuantity(8342) end, 0)) or 0
    local kc = kamasCoffre()
    local restePorte, resteGids = 0, {}
    for _, x in ipairs(contenu()) do if x.p == 63 and protege(x.g) and not (NON_DEPOSABLES or {})[x.g] then
        restePorte = restePorte + 1
        resteGids[#resteGids + 1] = tostring(x.g) .. ":" .. tostring(sur(function() return inventory:getTypeName(x.g) end, "?"))
    end end
    fermerCoffre()
    ecrireMem("FRD_COFFRE_" .. monId(), "1")
    local surMoi = {}
    for _, g in ipairs(manque) do if lignes(tonumber(g)) > 0 then surMoi[#surMoi + 1] = g end end
    if #surMoi > 0 then terminer("echec", "stuff de run encore sur le perso apres le depot : " .. table.concat(surMoi, " ")) return end
    if restePorte > 0 then terminer("echec", restePorte .. " ligne(s) protegee(s) encore au sac apres le depot : " .. table.concat(resteGids, ", ")) return end
    if not deshabiller() then terminer("echec", "des objets restent portes apres le depot") return end
    if #manque > 0 then alerte("stuff de run ABSENT du coffre et du perso : " .. table.concat(manque, " ") .. " (le perso suivant le redemandera au compte banque)") end
    terminer("1", monNom() .. " : " .. nProt .. " sorte(s) d objets proteges au coffre, " .. #garder .. " sorte(s) gardees pour le compte banque ; coffre = "
        .. clefs .. " clefs Croca, " .. kc .. " kamas ; poche " .. kamas() .. " kamas, pods " .. podsP() .. " %")
end
function lost() return move() end
function terminer(etat, m)
    ecrireMem("FRD_" .. monId(), etat)
    if etat == "1" then global:printSuccess(PREFIXE .. " " .. m) else alerte(m) end
    FINI = true
    global:finishScript()
end
function move()
    if FINI then return {} end
    if ROLE == "leader" then terminer("1", "leader : rien a deposer (il garde son stuff et ses clefs)") return {} end
    do local s = sortieCroca and sortieCroca() if s then return s end end
    return trajetBanque(auCoffre)
end

pcall(function() dofile(DOSSIER_FR .. "\\..\\lib\\sortie-croca.lua") end)
info(monNom() .. " (" .. ROLE .. ") : depot de fin de run au coffre du compte, pods " .. podsP() .. " %")
pcall(function() dofile(DOSSIER_FR .. "\\..\\lib\\anti-occupe.lua") end)

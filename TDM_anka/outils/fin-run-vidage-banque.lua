RECONNECT_ON_TIMEOUT = false
FIGHT_KICK = 0
IGNORE_REQUEST_DUEL = true
IGNORE_REQUEST_EXCHANGE = false
PREFIXE = "[FIN-RUN VIDAGE]"
DOSSIER_FR = global:getCurrentScriptDirectory()
dofile(DOSSIER_FR .. "\\fin-run-commun.lua")
ROLE = roleDuCompte()
KAMAS_POCHE  = (ROLE == "leader") and 50000 or 10000
KAMAS_COFFRE = (ROLE == "leader") and 0 or (KAMAS_MULE or 40000)
PODS_LOT = 80
ATTENTE_BANQUE_MS = 15 * 60000
TOURS_MAX = 60
FINI = false
function travail()
    if FINI then return end
    local n = monNom()
    fermer()
    if lireMem("FRV_FAIT_" .. n) == "1" then terminer("1", n .. " : vidage deja fait") return end
    local sansProgres, coffreKo = 0, 0
    for tour = 1, TOURS_MAX do
        local r = donner(n)
        if r == "absent" then terminer("echec", n .. " : compte banque absent " .. (ATTENTE_BANQUE_MS / 60000) .. " min") return end
        if r == "rien" then sansProgres = sansProgres + 1 elseif r == "ok" then sansProgres = 0 end
        if sansProgres >= 3 then terminer("echec", n .. " : 3 echanges de suite sans rien transmettre") return end
        if r == "ok" then
            local reste = sortirUnLot()
            if reste < 0 then
                coffreKo = coffreKo + 1
                if coffreKo >= 3 then terminer("echec", n .. " : le coffre ne s ouvre pas (kamas " .. kamas() .. ")") return end
            else
                coffreKo = 0
                if reste == 0 and #aDonner() == 0 and kamasADonner() == 0 then
                    if ROLE == "mule" and protegesAuSac() > 0 then
                        if sortirUnLot() < 0 or protegesAuSac() > 0 then terminer("echec", n .. " : objets proteges encore au sac (coffre)") return end
                    end
                    terminer("1", n .. " (" .. ROLE .. ") : plus rien de non protege au sac ni au coffre ; poche " .. kamas()
                        .. " kamas, pods " .. podsP() .. " %")
                    return
                end
                info(n .. " : tour " .. tour .. ", " .. reste .. " sorte(s) d objets encore au coffre")
            end
        end
    end
    terminer("echec", n .. " : vidage non termine apres " .. TOURS_MAX .. " tours")
end
function bank() return move() end
function donner(n)
    local lot, k = aDonner(), kamasADonner()
    if #lot == 0 and k == 0 then return "ok" end
    local L = (tonumber(lireMem("FRV_LOT_" .. n)) or 0) + 1
    ecrireMem("FRV_LOT_" .. n, L)
    ecrireMem("FRV_MPOSE_" .. n, 0)
    ecrireMem("FRV_PRET_" .. n, L)
    info(n .. " : lot " .. L .. " = " .. #lot .. " ligne(s) et " .. k .. " kamas, attend le compte banque")
    if not attendre(enEchange, ATTENTE_BANQUE_MS, 100) then
        ecrireMem("FRV_PRET_" .. n, 0)
        return "absent"
    end
    if not attendre(function() return lireMem("FRV_DEMANDE_" .. n) == tostring(L) end, 15000, 100) then
        alerte(n .. " : demande d echange qui n est pas celle du compte banque (lot " .. L .. ") : refusee")
        fermer()
        ecrireMem("FRV_PRET_" .. n, 0)
        attendre(function() return false end, 1500, 100)
        return "refus"
    end
    paquet("kax", "{}")
    attendre(function() return false end, 1200, 100)
    if not enEchange() then ecrireMem("FRV_PRET_" .. n, 0) return "rien" end
    local parGid = {}
    for _, x in ipairs(lot) do parGid[x.g] = (parGid[x.g] or 0) + 1 end
    for _, x in ipairs(lot) do
        local q = (parGid[x.g] == 1) and math.max(1, nbSac(x.g)) or 1
        paquet("jys", '{"fxyo":' .. x.u .. ',"fxyq":' .. q .. '}')
    end
    local k0 = kamas()
    if k > 0 then pcall(function() exchange:putKamas(k) end) end
    ecrireMem("FRV_MPOSE_" .. n, L)
    attendre(function() return lireMem("FRV_POSE_" .. n) == tostring(L) or not enEchange() end, 90000, 100)
    if enEchange() and lireMem("FRV_POSE_" .. n) == tostring(L) then
        pcall(function() exchange:ready() end)
        attendre(function() return not enEchange() end, 60000, 100)
    end
    if enEchange() then fermer() end
    ecrireMem("FRV_PRET_" .. n, 0)
    ecrireMem("FRV_MPOSE_" .. n, 0)
    attendre(function() return #aDonner() < #lot or kamas() < k0 end, 3000, 100)
    local _kd = k0 - kamas(); if _kd > 0 then pcall(function() (function() end)() end) end
    local apres = aDonner()
    if not (#apres < #lot or (k > 0 and kamas() < k0)) then return "rien" end
    local refus = {}
    for _, x in ipairs(apres) do
        if not NON_ECHANGEABLES[x.g] then noterNonEchangeable(x.g) refus[#refus + 1] = tostring(x.g) end
    end
    if #refus > 0 then alerte(n .. " : refuse(s) a l echange (lies au compte), remis au coffre ensuite : " .. table.concat(refus, " ")) end
    return "ok"
end
function kamasADonner() return math.max(0, kamas() - KAMAS_POCHE) end
function terminer(etat, m)
    local n = monNom()
    ecrireMem("FRV_PRET_" .. n, 0)
    ecrireMem("FRV_MPOSE_" .. n, 0)
    ecrireMem("FRV_FAIT_" .. n, etat)
    if etat == "1" then global:printSuccess(PREFIXE .. " " .. m) else alerte(m) end
    FINI = true
    global:finishScript()
end
function lost() return move() end
function move()
    if FINI then return {} end
    do local s = sortieCroca and sortieCroca() if s then return s end end
    return trajetBanque(travail)
end
function phenix() return move() end
function sortirUnLot()
    if true then return 0 end
    if not ouvrirCoffre() then return -1 end
    local garder, vu, aDeposer = {}, {}, 0
    for _, x in ipairs(contenu()) do
        if x.p == 63 and x.g and not vu[x.g] then
            vu[x.g] = true
            local remettre = NON_ECHANGEABLES[x.g] or (ROLE == "mule" and protege(x.g))
            if remettre then aDeposer = aDeposer + 1 else garder[#garder + 1] = x.g end
        end
    end
    if aDeposer > 0 then deposerSaufListe(garder) end
    local kc = kamasCoffre()
    if kc > KAMAS_COFFRE then
        local av = kamas()
        pcall(function() exchange:getKamas(kc - KAMAS_COFFRE) end)
        attendre(function() return kamas() > av end, 2000)
    elseif kamas() < 3000 and kc > 0 then
        local av = kamas()
        pcall(function() exchange:getKamas(math.min(5000, kc)) end)
        attendre(function() return kamas() > av end, 2000)
    end
    local c = contenuCoffre()
    local reste, lignesC = 0, {}
    for g, q in pairs(c) do
        if q > 0 and not NON_ECHANGEABLES[g] and not protegeStrict(g) then
            if podsP() >= PODS_LOT then reste = reste + 1
            else
                lignesC[#lignesC + 1] = g .. "x" .. q
                local pris = sortirDuCoffre(g, q, PODS_LOT)
                if pris < q then reste = reste + 1 end
            end
        end
    end
    fermerCoffre()
    if #lignesC > 0 then info("coffre -> sac : " .. table.concat(lignesC, " ")) end
    return reste
end
function aDonner()
    local L = {}
    for _, x in ipairs(contenu()) do
        if x.p == 63 and x.g and x.u and not NON_ECHANGEABLES[x.g] and not protege(x.g) then L[#L + 1] = x end
    end
    return L
end

pcall(function() dofile(DOSSIER_FR .. "\\..\\lib\\sortie-croca.lua") end)
info(monNom() .. " (" .. ROLE .. ") : vidage de fin de run vers le compte banque, pods " .. podsP() .. " %, " .. kamas() .. " kamas")
pcall(function() dofile(DOSSIER_FR .. "\\..\\lib\\anti-occupe.lua") end)

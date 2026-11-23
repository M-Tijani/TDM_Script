RECONNECT_ON_TIMEOUT = false
FIGHT_KICK = 0
IGNORE_REQUEST_DUEL = true
IGNORE_REQUEST_EXCHANGE = true
SURVEILLANCE_BLOCAGE = false
PREFIXE = "[FIN-RUN BANQUE]"
DOSSIER_FR = global:getCurrentScriptDirectory()
dofile(DOSSIER_FR .. "\\fin-run-commun.lua")
PODS_DEPOT = 60
DUREE_MAX_S = 3 * 3600
function receveurs()
    local L, vu = {}, {}
    for brut in string.gmatch(lireMem("FRV_RECEVEURS"), "[^,;]+") do
        local n = brut:gsub("^%s+", ""):gsub("%s+$", "")
        if n ~= "" and not vu[n] then vu[n] = true L[#L + 1] = n end
    end
    return L
end
function deposer()
    if not ouvrirCoffre() then alerte("coffre non ouvert (depot)") return false end
    deposerSaufListe({})
    fermerCoffre()
    info("depot au coffre : pods " .. podsP() .. " %")
    return true
end
SERVI = SERVI or {}
RECUS = RECUS or {}
PAUSE = PAUSE or {}
function recevoir(n, L)
    local k0, p0 = kamas(), podsP()
    ecrireMem("FRV_POSE_" .. n, 0)
    ecrireMem("FRV_DEMANDE_" .. n, L)
    attendre(function() return false end, 3000, 100)
    local ok = sur(function() return exchange:launchExchangeWithPlayerByName(n) end, false)
    if not attendre(enEchange, 25000, 100) then
        alerte(n .. " : echange non ouvert (" .. tostring(ok) .. "), nouvel essai dans 20 s")
        fermer()
        PAUSE[n] = maintenant() + 20
        return
    end
    attendre(function() return lireMem("FRV_MPOSE_" .. n) == L or not enEchange() end, 90000, 100)
    if not enEchange() then PAUSE[n] = maintenant() + 5 return end
    if lireMem("FRV_MPOSE_" .. n) ~= L then
        alerte(n .. " : rien pose apres 90 s (lot " .. L .. "), echange ferme")
        fermer()
        PAUSE[n] = maintenant() + 20
        return
    end
    attendre(function() return false end, 200, 100)
    ecrireMem("FRV_POSE_" .. n, L)
    pcall(function() exchange:ready() end)
    attendre(function() return not enEchange() end, 60000, 100)
    if enEchange() then fermer() end
    SERVI[n] = L
    RECUS[n] = (RECUS[n] or 0) + (kamas() - k0)
    info(n .. " : lot " .. L .. " recu (+" .. (kamas() - k0) .. " kamas, pods " .. p0 .. " -> " .. podsP() .. " %)")
end
FINI = false
function travail()
    if FINI then return end
    fermer()
    ecrireMem("FRV_BANQUE_FINI", 0)
    if podsP() >= 20 then deposer() end
    ecrireMem("FRV_BANQUE_PRETE", 1)
    local debut = maintenant()
    local dit = 0
    while not FINI do
        if lireMem("FRV_FIN") == "1" then break end
        if maintenant() - debut > DUREE_MAX_S then alerte("duree max atteinte sans FRV_FIN") break end
        if podsP() >= PODS_DEPOT and not enEchange() then deposer() end
        local servi = false
        for _, n in ipairs(receveurs()) do
            local L = lireMem("FRV_PRET_" .. n)
            if L ~= "" and L ~= "0" and SERVI[n] ~= L and (PAUSE[n] or 0) <= maintenant() and not enEchange() then
                recevoir(n, L)
                servi = true
            end
        end
        if not servi then
            if maintenant() - dit > 120 then dit = maintenant() info("en attente des lots de : " .. lireMem("FRV_RECEVEURS")) end
            attendre(function() return false end, 300, 100)
        end
    end
    ecrireMem("FRV_BANQUE_PRETE", 0)
    deposer()
    local t = {}
    for n, k in pairs(RECUS) do t[#t + 1] = n .. " +" .. k .. " k" end
    ecrireMem("FRV_BANQUE_FINI", 1)
    global:printSuccess(PREFIXE .. " FINI : " .. table.concat(t, ", ") .. " ; kamas en poche " .. kamas())
    FINI = true
    global:finishScript()
end
function lost() return move() end
function move()
    if FINI then return {} end
    return trajetBanque(travail)
end
function phenix() return move() end
function bank() return move() end

info("reception du vidage : " .. lireMem("FRV_RECEVEURS"))
pcall(function() dofile(DOSSIER_FR .. "\\..\\lib\\anti-occupe.lua") end)

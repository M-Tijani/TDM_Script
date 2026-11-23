local ETAPE = {
    cle    = "otomai",
    nom    = "PNJ 1577 puis la quete d'Otomai",
    succes = {},
    acces  = "aucun",
}
local CARTE_1577   = 188743687
local OTO_PNJ      = 925
local OTO_DEPART   = 95420420
local OTO_HDV      = 90707714
local OTO_HDV_PNJ  = 515281
local OTO_BANQUE   = 91753985
local OTO_PRIX_MAX = 20000
local OTO_ACHATS = {
    { gid = 429,  nom = "Misericorde du Chafer d Elite", quantite = 2 },
    { gid = 2553, nom = "Gros Boulet",                   quantite = 1, farmable = true },
    { gid = 2551, nom = "Oreille de Foufayteur",         quantite = 1 },
    { gid = 399,  nom = "Huile de Sesame",               quantite = 1 },
    { gid = 1002, nom = "Tronc de Kokoko",               quantite = 1, farmable = true },
    { gid = 8759, nom = "Coffret maudit du Flib",        quantite = 1, farmable = true },
    { gid = 2618, nom = "Kokopaille",                    quantite = 1, farmable = true },
    { gid = 2617, nom = "Tranche de Nodkoko",            quantite = 1, farmable = true },
}
local GROS_BOULET  = 2553
local OTO_COMBATS  = { [26214400] = 26215424, [26215424] = 26216448, [26216448] = 26217472 }
local OTO_EMBARQUEMENT = 26214400
local OTO_NAUFRAGE = 26217472
local OTO_CAMP     = 153090
local OTO_FARM     = { 153090, 153602, 153601, 153089 }
local OTO_OBJETS = {
    { gid = 1002, nom = "Tronc de Kokoko" },
    { gid = 8759, nom = "Coffret maudit du Flib" },
    { gid = 2618, nom = "Kokopaille" },
    { gid = 2617, nom = "Tranche de Nodkoko" },
}
local OTO_APRES_LIVRAISON = 153621
local ROUTE_CORAILLEUR = { 153621, 155667, 157205, 63963136, 161299, 161295 }
local CARTE_CORAILLEUR = 161295
local RAUL_LIGNE = { 88082689, 88083201, 88083713, 88084225, 88084737, 88085249, 88085761,
                     88086273, 88086785, 88087297, 232653313, 232653315, 232653317, 232653569,
                     232653571, 88083461, 88083456, 88082949, 88082944, 88082436, 88082435,
                     88082432, 88081922, 88081921, 88081920 }
local RAUL_ZAAP    = 88085249
local RAUL_MOPS    = 926
local OTO_MIN_MONSTRES = 4
local OTO_SOLO = (OTOMAI_SOLO ~= false)
local OTO_MAX_SOLO = 4
local function moiChef() return OTO_SOLO or estLeader() end
ETAPE.leaderAttendSuivante = OTO_SOLO
local SUCCES_ILE_DES_NAUFRAGES = 385
local SUCCES_GRANDE_KRADOC = 600
local ATTENTE_BOULETS_MS = 1800000
local GARDER_AU_SAC = { 8359, 8358 }
ETAPE.validee = function() return SUCCES_VALIDE[SUCCES_GRANDE_KRADOC] == true end
local function cle(k) return cleEquipe() .. "OTO_" .. k end
local function achatsManquants(sansFarmables)
    local m = {}
    for _, a in ipairs(OTO_ACHATS) do
        if not (sansFarmables and a.farmable) and nb(a.gid) < a.quantite then
            m[#m + 1] = a.nom .. " (" .. nb(a.gid) .. "/" .. a.quantite .. ")"
        end
    end
    return m
end
local function surLIle(c)
    return c ~= nil and (c < 1000000 or (c >= 63000000 and c < 64500000))
end
local function fait(p) return lireEtat("OTO_P" .. p) == "1" end
local function dansListe(t, c)
    for i, x in ipairs(t) do if x == c then return i end end
    return nil
end
local function surLeBateau(c)
    return c == OTO_EMBARQUEMENT or c == OTO_NAUFRAGE or OTO_COMBATS[c] ~= nil
end
local function objetsManquants()
    local m = {}
    for _, o in ipairs(OTO_OBJETS) do if nb(o.gid) < 1 then m[#m + 1] = o.nom end end
    return m
end
local function dialogue925(n, opts)
    local r = {}
    for i = 1, n do r[i] = -1 end
    parler(OTO_PNJ, r, opts)
end
local function ici() return tonumber(carte()) end
local function viser(cible)
    for i, e in ipairs(ETAPE.quete) do
        if tostring(e.map) == tostring(cible) then ETAT_ETAPE.idx = i break end
    end
    avancerVers(cible)
end
local function nb(gid) return tonumber(sur(function() return inventory:itemCount(gid) end, 0)) or 0 end
local function marquer(p) ecrireEtat("OTO_P" .. p, 1) end
local function occupe() return sur(function() return character:isBusy() end, false) == true end
local function effacer(p) ecrireEtat("OTO_P" .. p, 0) end

local REGLAGES = nil
local function rendreReglages()
    if REGLAGES == nil then return end
    FORCE_MONSTERS, FORBIDDEN_MONSTERS = REGLAGES.force, REGLAGES.interdits
    MIN_MONSTERS, MAX_MONSTERS = REGLAGES.mini, REGLAGES.maxi
    REGLAGES = nil
end
local function poserReglages(t)
    if REGLAGES == nil then
        REGLAGES = { force = FORCE_MONSTERS, interdits = FORBIDDEN_MONSTERS, mini = MIN_MONSTERS, maxi = MAX_MONSTERS }
    end
    for k, v in pairs(t) do _G[k] = v end
end
local function marquerJusqua(liste)
    for _, p in ipairs(liste) do if not fait(p) then marquer(p) end end
end
local P_JUSQUA_7 = { "1", "2", "3", "4", "4B", "5", "6", "7" }
local function rattraper()
    local c = ici()
    if SUCCES_VALIDE[SUCCES_GRANDE_KRADOC] == true then
        marquerJusqua({ "1", "2", "3", "4", "4B", "5", "6", "7", "8", "9", "10" })
    elseif SUCCES_VALIDE[SUCCES_ILE_DES_NAUFRAGES] == true then
        marquerJusqua(P_JUSQUA_7)
    end
    if c == OTO_APRES_LIVRAISON or dansListe(ROUTE_CORAILLEUR, c) or c == 154642 then
        marquerJusqua({ "1", "2", "3", "4", "4B", "5", "6", "7", "8", "9", "10" })
    elseif surLeBateau(c) then
        marquerJusqua({ "1", "2", "3", "4", "4B", "5" })
    elseif c == OTO_CAMP then
        marquerJusqua(P_JUSQUA_7)
    end
end
local ORDRE = { "1", "2", "3", "4", "4B", "5", "6", "7", "8", "9", "10" }
local function embarquementOtomai()
    local manque = achatsManquants(true)
    if #manque > 0 then
        alerte("Otomai : l'embarquement reclame " .. table.concat(manque, ", ") .. " — achats a refaire")
        effacer("4")
        viser(OTO_HDV)
        return
    end
    if OTO_SOLO and nb(GROS_BOULET) < 1 then viser(RAUL_ZAAP) return end
    local pret = OTO_SOLO or attendre(function()
        publierBoulet()
        return bouletsPrets() or equipeDoitFarmer()
    end, ATTENTE_BOULETS_MS, 2000)
    if not OTO_SOLO and not bouletsPrets() and equipeDoitFarmer() then viser(RAUL_ZAAP) return end
    if not pret then alerte("Otomai : 30 min d'attente des Gros Boulets — on embarque quand meme") end
    if nb(GROS_BOULET) < 1 then
        alerte("Otomai : pas de Gros Boulet en sac — le 925 refusera l'embarquement")
    end
    attendre(monTourDEmbarquer, 600000, 500)
    dialogue925(2)
    marquer("5")
    publierBoulet()
    dialogue925(1, { changeCarte = 5000 })
end
local function phaseCourante()
    for _, p in ipairs(ORDRE) do
        if p == "4B" then
            if nb(GROS_BOULET) >= 1 then marquer("4B") end
        elseif p == "6" then
        elseif not fait(p) then
            return p
        end
    end
    return "fin"
end
local function farmerRaulMops()
    local c = ici()
    local chef = comptesEquipe()[1]
    if not moiChef() then
        local cc = tonumber(carteDe(chef))
        if cc ~= nil and cc ~= c and dansListe(RAUL_LIGNE, cc) then viser(cc) return end
        attendre(function() return enCombat() or tonumber(carteDe(chef)) ~= c end, 120000, 200)
        if enCombat() then return end
        local cc2 = tonumber(carteDe(chef))
        if cc2 ~= nil and cc2 ~= c then viser(cc2) return end
    else
        if not OTO_SOLO and not equipeAuComplet(c, 60000) then return end
        if OTO_SOLO then
            poserReglages({ FORCE_MONSTERS = { RAUL_MOPS }, FORBIDDEN_MONSTERS = {}, MIN_MONSTERS = 1, MAX_MONSTERS = OTO_MAX_SOLO })
        else
            poserReglages({ FORCE_MONSTERS = { RAUL_MOPS }, FORBIDDEN_MONSTERS = {} })
        end
        pcall(function() map:fight() end)
        if attendre(function() return enCombat() end, 3000) then return end
        rendreReglages()
    end
    local i = dansListe(RAUL_LIGNE, c) or 0
    for k = 1, #RAUL_LIGNE - 1 do
        local cible = RAUL_LIGNE[((i - 1 + k) % #RAUL_LIGNE) + 1]
        viser(cible)
        if ici() ~= c then return end
    end
end
local function pairesDEchange()
    local equipe, stocks, paires = comptesEquipe(), {}, {}
    for i, a in ipairs(equipe) do stocks[i] = stockDe(a) end
    for _, o in ipairs(OTO_OBJETS) do
        local donneurs, receveurs = {}, {}
        for i = 1, #equipe do
            local n = stocks[i][o.gid]
            if n ~= nil and n >= 2 then for _ = 2, n do donneurs[#donneurs + 1] = i end end
            if n ~= nil and n == 0 then receveurs[#receveurs + 1] = i end
        end
        for k = 1, math.min(#donneurs, #receveurs) do
            paires[#paires + 1] = { de = equipe[donneurs[k]], vers = equipe[receveurs[k]], gid = o.gid }
        end
    end
    return paires
end
local function stockDe(a)
    local s = tostring(lireMem(cle("STOCK_" .. idDe(a))) or "")
    local t = {}
    for g, n in s:gmatch("(%d+)=(%d+)") do t[tonumber(g)] = tonumber(n) end
    return t
end
local function banqueOtomai()
    local avant = tonumber(sur(function() return inventory:pods() end, 0)) or 0
    pcall(function() npc:npcBank(-1) end)
    local ouvert = function() return sur(function() return exchange:isInExchange() end, false) == true end
    attendre(function() return ouvert() or occupe() end, 3000)
    if not ouvert() and occupe() then
        pcall(function() npc:reply(-1) end)
        attendre(ouvert, 3000)
    end
    local garder = {}
    pcall(function() garder = gidsAGarder(inventory) end)
    for _, g in ipairs(GARDER_AU_SAC) do garder[#garder + 1] = g end
    local ok = pcall(function() exchange:putAllItemsExcept(garder) end)
    attendre(function() return (tonumber(sur(function() return inventory:pods() end, avant)) or avant) < avant end, 5000)
    pcall(function() exchange:leave() end)
    attendre(function() return not ouvert() end, 3000)
    marquer("3")
    effacer("4")
    viser(OTO_HDV)
end
local function statutBoulet()
    if fait("5") then return "E" end
    if nb(GROS_BOULET) >= 1 then return "1" end
    if fait("4") then return "0" end
    return "A"
end
local function bouletsPrets()
    local t = statutsBoulets()
    if t == nil then return nb(GROS_BOULET) >= 1 end
    for _, v in ipairs(t) do if v ~= "1" and v ~= "E" then return false end end
    return true
end
local function enEchange() return sur(function() return exchange:isInExchange() end, false) == true end
local function monTourDEmbarquer()
    local moi = monRang()
    for i, a in ipairs(comptesEquipe()) do
        if i ~= moi then
            if surLeBateau(tonumber(carteDe(a))) then return false end
            if i < moi and tostring(lireMem(cle("PH_" .. idDe(a))) or "") == "5" then return false end
        end
    end
    return true
end
local function uidDe(gid)
    local uid = nil
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            if tonumber(it.Item.Gid) == gid and tonumber(it.Position) == 63 then uid = tonumber(it.Item.Uid) break end
        end
    end)
    return uid
end
local function echangeEnAttenteIci()
    if ECHANGES_OTOMAI ~= true then return false end
    local c = carte()
    for _, p in ipairs(pairesDEchange()) do
        if carteDe(p.de) == c and carteDe(p.vers) == c then return true end
    end
    return false
end
local function publierBoulet() ecrireMem(cle("BOULET_" .. moiId()), statutBoulet()) end
local function echangerLesDoublons()
    if ECHANGES_OTOMAI ~= true then return end
    publierStock()
    local moi, c = moiId(), carte()
    for _, p in ipairs(pairesDEchange()) do
        local de, vers = idDe(p.de), idDe(p.vers)
        if (de == moi or vers == moi) and carteDe(p.de) == c and carteDe(p.vers) == c then
            local jeton = cle("ECH_" .. de .. "_" .. vers .. "_" .. p.gid)
            if vers == moi then
                ecrireMem(jeton, "ecoute")
                attendre(function()
                    envoyerPaquetBrut("accepterEchange", {}, "acceptation de l echange")
                    return enEchange()
                end, 30000, 1000)
                if enEchange() then validerJusquALaFermeture() end
                ecrireMem(jeton, "fini")
            else
                if attendre(function() return lireMem(jeton) == "ecoute" end, 15000, 300) then
                    local nom = sur(function() return p.vers.character:name() end, nil)
                    pcall(function() exchange:launchExchangeWithPlayerByName(nom) end)
                    if attendre(enEchange, 8000) then
                        local uid = uidDe(p.gid)
                        local ok = uid ~= nil and envoyerPaquetBrut("poserObjetDansLEchange", { uid = tostring(uid), quantite = 1 }, "pose du doublon")
                        if not ok then pcall(function() exchange:putItem(p.gid, 1) end) end
                        validerJusquALaFermeture()
                    end
                end
            end
            publierStock()
            return true
        end
    end
    return false
end
local function publierStock()
    local t = {}
    for _, o in ipairs(OTO_OBJETS) do t[#t + 1] = o.gid .. "=" .. nb(o.gid) end
    ecrireMem(cle("STOCK_" .. moiId()), table.concat(t, ","))
end
local function validerJusquALaFermeture()
    attendre(function()
        envoyerPaquetBrut("validerLEchange", {}, "validation de l echange")
        pcall(function() exchange:ready() end)
        return not enEchange()
    end, 20000, 1000)
    if enEchange() then pcall(function() exchange:leave() end) end
end
local function statutsBoulets()
    local t = {}
    for i, a in ipairs(comptesEquipe()) do
        local v = lireMem(cle("BOULET_" .. idDe(a)))
        if v == nil then return nil end
        t[i] = tostring(v)
    end
    return t
end
local function achatsOtomai()
    local pods = tonumber(sur(function() return inventory:podsP() end, 0)) or 0
    if pods >= 95 then
        alerte("Otomai : sac a " .. pods .. " % — retour a la banque avant d'acheter")
        effacer("3")
        viser(OTO_BANQUE)
        return
    end
    pcall(function() npc:npc(OTO_HDV_PNJ, 6) end)
    attendre(occupe, 3000)
    for passe = 1, 4 do
        if #achatsManquants(false) == 0 then break end
        if passe > 1 then dire("Otomai : passe d'achat " .. passe .. "/4 — il manque " .. table.concat(achatsManquants(false), ", ")) end
        for _, a in ipairs(OTO_ACHATS) do
            local reste = a.quantite - nb(a.gid)
            for _ = 1, reste do
                local avant = nb(a.gid)
                pcall(function() sale:buyItem(a.gid, 1, OTO_PRIX_MAX) end)
                attendre(function() return nb(a.gid) > avant end, 3000)
            end
        end
    end
    fermerInterfaces()
    attendre(function() return #achatsManquants(true) == 0 end, 4500, 500)
    local manque = achatsManquants(true)
    if #manque > 0 then
        alerte("Otomai : introuvables sous " .. OTO_PRIX_MAX .. " k : " .. table.concat(manque, ", ")
            .. " — arret (relever OTO_PRIX_MAX ou attendre l'HDV)")
        pcall(function() global:finishScript() end)
        return
    end
    if nb(GROS_BOULET) < 1 then dire("Otomai : pas de Gros Boulet a l'HDV — farm de Raul Mops a huit") end
    marquer("4")
    publierBoulet()
    viser(OTO_DEPART)
end
local function equipeDoitFarmer()
    if fait("5") then return false end
    publierBoulet()
    local t = statutsBoulets()
    if t == nil then return false end
    local zero = false
    for i, v in ipairs(t) do
        if v == "E" then if i == 1 then return false end
        elseif v == "A" then return false
        elseif v == "0" then zero = true end
    end
    return zero
end

local DERNIER_COMBAT = nil
local function depart()
    local c = ici()
    if surLIle(c) or surLeBateau(c) then return otoAgir() end
    pcall(function() map:changeMap("havenbag") end)
end
local function livraisonOtomai()
    rendreReglages()
    if #objetsManquants() > 0 then
        alerte("Otomai : livraison reportee, il manque " .. table.concat(objetsManquants(), ", "))
        effacer("9")
        return viser(OTO_FARM[2])
    end
    dialogue925(4)
    marquer("10")
    local avant = carte()
    dialogue925(1, { changeCarte = 5000 })
    if carte() == avant then viser(OTO_FARM[2]) end
end
local function otoAgir()
    rendreReglages()
    rattraper()
    local c = ici()
    local p = phaseCourante()
    if estLeader() and leaderPasseur(ETAT_ETAPE and ETAT_ETAPE.n) then
        p = "fin"
        if not surLIle(c) and not surLeBateau(c) then
            if c == OTO_DEPART then dialogue925(3, { changeCarte = 5000 }) return end
            return viser(OTO_DEPART)
        end
    end
    ecrireMem(cle("PH_" .. moiId()), p)
    publierBoulet()
    if OTO_COMBATS[c] ~= nil then
        pcall(function() map:fight() end)
        return
    end
    if c == OTO_NAUFRAGE then
        marquer("6") marquer("7")
        dialogue925(1, { changeCarte = 5000 })
        return
    end
    if fait("7") and not surLIle(c) and not surLeBateau(c) and p ~= "fin" and tonumber(p) ~= nil and tonumber(p) < 10 then
        if c == OTO_DEPART then dialogue925(3, { changeCarte = 5000 }) return end
        return viser(OTO_DEPART)
    end
    if p == "1" then
        if c ~= CARTE_1577 then return viser(CARTE_1577) end
        parler(1577, { -3, -1, -1 })
        marquer("1")
        return viser(OTO_DEPART)
    elseif p == "2" then
        if c ~= OTO_DEPART then return viser(OTO_DEPART) end
        dialogue925(3)
        marquer("2")
        return viser(OTO_BANQUE)
    elseif p == "3" then
        if c ~= OTO_BANQUE then return viser(OTO_BANQUE) end
        return banqueOtomai()
    elseif p == "4" then
        if c ~= OTO_HDV then return viser(OTO_HDV) end
        return achatsOtomai()
    elseif p == "5" then
        if (OTO_SOLO and nb(GROS_BOULET) < 1) or (not OTO_SOLO and equipeDoitFarmer()) then
            if dansListe(RAUL_LIGNE, c) then return farmerRaulMops() end
            local cible = RAUL_ZAAP
            if not moiChef() then
                local cc = tonumber(carteDe(comptesEquipe()[1]))
                if cc ~= nil and dansListe(RAUL_LIGNE, cc) then cible = cc end
            end
            return viser(cible)
        end
        if c ~= OTO_DEPART then return viser(OTO_DEPART) end
        return embarquementOtomai()
    elseif p == "7" then
        alerte("Otomai : embarquement non pris (carte " .. tostring(c) .. ") — retour au 925")
        effacer("5")
        return viser(OTO_DEPART)
    elseif p == "8" then
        if c ~= OTO_CAMP then return viser(OTO_CAMP) end
        if not OTO_SOLO and not equipeAuComplet(OTO_CAMP) then return end
        dialogue925(4)
        marquer("8")
        return viser(OTO_FARM[2])
    elseif p == "9" then
        if #objetsManquants() == 0 then marquer("9") return viser(OTO_CAMP) end
        if dansListe(OTO_FARM, c) then return farmOtomai() end
        return viser(OTO_FARM[1])
    elseif p == "10" then
        if c ~= OTO_CAMP then return viser(OTO_CAMP) end
        return livraisonOtomai()
    end
    if c == CARTE_CORAILLEUR then
        ETAT_ETAPE.idx = #ETAPE.quete + 1
        return
    end
    local i = dansListe(ROUTE_CORAILLEUR, c)
    if i ~= nil and ROUTE_CORAILLEUR[i + 1] ~= nil then return viser(ROUTE_CORAILLEUR[i + 1]) end
    if c ~= nil and c >= 153000 and c < 154000 then
        if #objetsManquants() > 0 then effacer("9") effacer("10") return viser(OTO_FARM[1]) end
        if c == OTO_CAMP then effacer("10") return livraisonOtomai() end
        return viser(OTO_CAMP)
    end
    viser(CARTE_CORAILLEUR)
end
local function farmOtomai()
    local c = ici()
    local i = dansListe(OTO_FARM, c)
    local suivante = OTO_FARM[((i or 0) % #OTO_FARM) + 1]
    if not OTO_SOLO then echangerLesDoublons() end
    if #objetsManquants() == 0 then marquer("9") return viser(OTO_CAMP) end
    local chef = comptesEquipe()[1]
    local chefAuFarm = dansListe(OTO_FARM, tonumber(carteDe(chef))) ~= nil
    if moiChef() then
        if DERNIER_COMBAT == c then DERNIER_COMBAT = nil return viser(suivante) end
        DERNIER_COMBAT = c
        if OTO_SOLO then
            poserReglages({ MIN_MONSTERS = 1, MAX_MONSTERS = OTO_MAX_SOLO })
        elseif estLeader() then
            if not equipeAuComplet(c, 60000) then DERNIER_COMBAT = nil return end
            attendre(function() publierStock() return not echangeEnAttenteIci() end, 45000, 1000)
            poserReglages({ MIN_MONSTERS = OTO_MIN_MONSTRES })
        else
            poserReglages({ MIN_MONSTERS = 1, MAX_MONSTERS = 8 })
        end
        pcall(function() map:fight() end)
        if attendre(function() return enCombat() end, 3000) then return end
        rendreReglages()
        DERNIER_COMBAT = nil
        return viser(suivante)
    end
    local cc = tonumber(carteDe(chef))
    if cc ~= c then return viser(cc) end
    attendre(function()
        publierStock()
        return enCombat() or tonumber(carteDe(chef)) ~= c or echangeEnAttenteIci()
    end, 120000, 300)
    if enCombat() then return end
    if echangeEnAttenteIci() then echangerLesDoublons() end
    local cc2 = tonumber(carteDe(chef))
    if cc2 ~= nil and cc2 ~= c then return viser(cc2) end
    viser(suivante)
end

ETAPE.quete = {
    { map = "*", custom = depart },
    { map = "162791424", custom = function()
        local p = phaseCourante()
        local passe = estLeader() and leaderPasseur(ETAT_ETAPE and ETAT_ETAPE.n)
        local z = (p == "3" or p == "4" or passe) and 95422468 or 191105026
        pcall(function() map:changeMap("zaap(" .. z .. ")") end)
    end },
    { map = "5,-18", path = "left" },
    { map = "4,-18", path = "left" },
    { map = "3,-18", path = "left" },
    { map = "2,-18", path = "left" },
    { map = "1,-18", path = "bottom" },
    { map = "1,-17", path = "bottom" },
    { map = "1,-16", path = "bottom" },
    { map = tostring(CARTE_1577), custom = otoAgir },
    { map = tostring(OTO_DEPART), custom = otoAgir },
    { map = tostring(OTO_BANQUE), custom = otoAgir },
    { map = tostring(OTO_HDV), custom = otoAgir },
}
for _, c in ipairs(RAUL_LIGNE) do ETAPE.quete[#ETAPE.quete + 1] = { map = tostring(c), custom = otoAgir } end
for _, c in ipairs({ 26214400, 26215424, 26216448, OTO_NAUFRAGE }) do
    ETAPE.quete[#ETAPE.quete + 1] = { map = tostring(c), custom = otoAgir }
end
for _, c in ipairs(OTO_FARM) do ETAPE.quete[#ETAPE.quete + 1] = { map = tostring(c), custom = otoAgir } end
for i = 1, #ROUTE_CORAILLEUR - 1 do
    ETAPE.quete[#ETAPE.quete + 1] = { map = tostring(ROUTE_CORAILLEUR[i]), custom = otoAgir }
end
ETAPE.aller = nil
ETAPE.entree = nil
ETAPE.donjon = nil
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

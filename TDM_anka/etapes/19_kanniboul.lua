local function versCarte(id) avancerVers(id) end
local DEGUISEMENT = {
    { gid = 1019, nom = "Casque", position = 6 },
    { gid = 1021, nom = "Ailes en bois", position = 7 },
}
local PRIX_MAX = 20000
local ESSAIS = 4
local function objetDuSacParType(motifs)
    local g = nil
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local gid = tonumber(it.Item.Gid)
            if g == nil and tonumber(it.Position) == 63 and gid ~= 1019 and gid ~= 1021 and not SCARA[gid] then
                local tn = string.lower(tostring(sur(function() return inventory:getTypeName(gid) end, "")))
                for _, m in ipairs(motifs) do if tn:find(m, 1, true) then g = gid end end
            end
        end
    end)
    return g
end
local function manquants()
    local m = {}
    for _, o in ipairs(DEGUISEMENT) do if not possede(o) then m[#m + 1] = o end end
    return m
end
local function pos(gid) return tonumber(sur(function() return inventory:itemPosition(gid) end, -1)) end
local function objetEnPosition(p)
    local g = nil
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            if tonumber(it.Position) == p then g = tonumber(it.Item.Gid) end
        end
    end)
    return g
end
local function nb(gid) return tonumber(sur(function() return inventory:itemCount(gid) end, 0)) or 0 end
local function possede(o) return nb(o.gid) >= 1 or pos(o.gid) == o.position end

local SCARA = { [10800] = true, [10801] = true }
function kitCoiffeCape()
    if estLeader() and KIT_COIFFE_CAPE_LEADER ~= nil then return KIT_COIFFE_CAPE_LEADER end
    return KIT_COIFFE_CAPE or {}
end
local function equiperKit()
    for _, g in ipairs(kitCoiffeCape()) do
        if nb(g) > 0 and objetEnPosition(6) ~= g and objetEnPosition(7) ~= g then
            for _, p in ipairs({ 6, 7 }) do
                pcall(function() inventory:equipItem(g, p) end)
                if attendre(function() return objetEnPosition(p) == g end, 2500, 200) then
                    dire("Moon : objet du kit " .. g .. " remis en " .. p)
                    break
                end
            end
        end
    end
end
local function equiperLeDeguisement()
    for _, o in ipairs(DEGUISEMENT) do
        if pos(o.gid) ~= o.position then
            local avant = objetEnPosition(o.position)
            if avant ~= nil and avant ~= o.gid then ecrireEtat("AVANT_DEGUISEMENT_" .. o.position, avant) end
            pcall(function() inventory:equipItem(o.gid, o.position) end)
            attendre(function() return pos(o.gid) == o.position end, 2000)
        end
    end
end
function besoinRhabillage()
    if deguiseHorsMoon() then return false end
    local enSac = false
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local g = tonumber(it.Item.Gid)
            for _, k in ipairs(kitCoiffeCape()) do
                if g == k and tonumber(it.Position) == 63 then enSac = true end
            end
        end
    end)
    return enSac or objetEnPosition(6) == nil or objetEnPosition(7) == nil
end
function deguiseHorsMoon()
    local m = tonumber(sur(function() return map:currentMapId() end, 0)) or 0
    local surMoon = m >= 156000000 and m < 158000000
    return not surMoon and (pos(1019) == 6 or pos(1021) == 7 or ici_passage_saharach(m))
end
function ici_passage_saharach(m) return m == 88085773 or m == 95422468 or m == 90702849 end
function remettreCoiffeEtCape()
    if deguiseHorsMoon() then return end
    equiperKit()
    for _, x in ipairs({ { 6, { "chapeau", "coiffe" } }, { 7, { "cape" } } }) do
        local p, motifs = x[1], x[2]
        local g = tonumber(lireEtat("AVANT_DEGUISEMENT_" .. p))
        if g == nil or g == 0 then g = objetDuSacParType(motifs) end
        if g ~= nil and SCARA[g] then g = nil end
        if objetEnPosition(p) ~= nil and not SCARA[objetEnPosition(p)] then g = nil end
        if g ~= nil and objetEnPosition(p) ~= g then
            for _ = 1, 3 do
                pcall(function() inventory:equipItem(g, p) end)
                if attendre(function() return objetEnPosition(p) == g end, 2500, 200) then break end
            end
            if objetEnPosition(p) == g then dire("Moon : objet " .. g .. " remis en " .. p)
            else alerte("Moon : objet " .. g .. " PAS equipe en " .. p) end
        end
    end
end

local INDEX_PASSAGE = 5
local function acheterLeDeguisement()
    if #manquants() > 0 then
        pcall(function() npc:npc(515283, 6) end)
        attendre(function() return sur(function() return character:isBusy() end, false) end, 3000)
        for _ = 1, ESSAIS do
            local m = manquants()
            if #m == 0 then break end
            for _, o in ipairs(m) do
                local avant = nb(o.gid)
                pcall(function() sale:buyItem(o.gid, 1, PRIX_MAX) end)
                attendre(function() return nb(o.gid) > avant end, 3000)
            end
        end
        fermerInterfaces()
    end
    if #manquants() > 0 then
        local noms = {}
        for _, o in ipairs(manquants()) do noms[#noms + 1] = o.nom end
        alerte("deguisement de Saharach introuvable sous " .. PRIX_MAX .. " kamas : " .. table.concat(noms, ", "))
        pcall(function() global:finishScript() end)
        return
    end
    allerAuPassage()
end
function allerAuPassage()
    equiperLeDeguisement()
    if ETAT_ETAPE ~= nil and ETAT_ETAPE.phase == "aller" and (ETAT_ETAPE.idx or 0) < INDEX_PASSAGE then
        ETAT_ETAPE.idx = INDEX_PASSAGE
    end
    versCarte(88085773)
end

local KANNIBOUL_DEVANT = 156499971
local ZAAP_MOON = 156762120
local function cotemoon(m) m = tonumber(m) or 0 return m >= 156000000 and m < 158000000 end
local function passageAuComplet(ici)
    local passe = leaderPasseur(ETAT_ETAPE and ETAT_ETAPE.n)
    local function ok()
        for i, a in ipairs(comptesEquipe()) do
            local m = carteDe(a)
            if idDe(a) ~= moiId() and not (i == 1 and passe) and m ~= tostring(ici) and not cotemoon(m) then return false end
        end
        return true
    end
    if attendre(ok, ATTENTE_EQUIPE_MS, 200) then return true end
    rejouerCetteEntree()
    alerte("passage de Saharach : toutes les mules ne sont pas encore la")
    return false
end
local function leaderDejaPasse() return estLeader() and leaderPasseur(ETAT_ETAPE and ETAT_ETAPE.n) end

local ETAPE = {
    cle    = "kanniboul",
    nom    = "PNJ 1578, Saharach puis Village Kanniboul",
    succes = { 56 },
    acces  = "pied",
}
ETAPE.quete = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(191105026)" },
    { map = "99091977", custom = function()
        parler(1578, { -1, -1, -1 })
        versCarte(95422468)
    end },
}
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", custom = function()
        if leaderDejaPasse() then
            local z = tonumber(sur(function() return map:closestZaapV2(KANNIBOUL_DEVANT) end, 0)) or 0
            if z == ZAAP_MOON then
                dire("leader deja passe : pas de deguisement, zaap de Moon " .. z)
                ETAT_ETAPE.idx = #ETAPE.aller
                ZAAP_PRIS_POUR = ZAAP_PRIS_POUR or {}
                ZAAP_PRIS_POUR[KANNIBOUL_DEVANT] = os.time()
                pcall(function() map:toZaap(z, 3) end)
                return
            end
            pcall(function() global:leaveDialog() end)
            alerte("zaap de Moon inconnu : passage par Saharach avec deguisement")
        end
        pcall(function() map:changeMap("zaap(95422468)") end)
    end },
    { map = "95422468", custom = function()
        if leaderDejaPasse() then
            local z = tonumber(sur(function() return map:closestZaapV2(KANNIBOUL_DEVANT) end, 0)) or 0
            if z == ZAAP_MOON then
                dire("leader deja passe : zaap de Moon " .. z .. " depuis Saharach")
                ETAT_ETAPE.idx = #ETAPE.aller
                ZAAP_PRIS_POUR = ZAAP_PRIS_POUR or {}
                ZAAP_PRIS_POUR[KANNIBOUL_DEVANT] = os.time()
                pcall(function() map:toZaap(z, 3) end)
                return
            end
            pcall(function() global:leaveDialog() end)
        end
        if #manquants() > 0 then pcall(function() map:changeMap("left") end)
        else allerAuPassage() end
    end },
    { map = "90702849", custom = acheterLeDeguisement },
    { map = "88085773", custom = function()
        local ici = carte()
        if not passageAuComplet(ici) then return end
        equiperLeDeguisement()
        local avantDlg = dernierDialogue and dernierDialogue() or nil
        pcall(function() npc:npc(153, 3) end)
        attendre(function() return signatureRepliques() ~= "" and (avantDlg == nil or dernierDialogue() ~= avantDlg) end, 3000)
        local vus = {}
        for _ = 1, 12 do
            local brut = signatureRepliques()
            if brut == "" then break end
            vus[brut] = (vus[brut] or 0) + 1
            if vus[brut] > 2 then break end
            local opts = optionsDuMenu()
            local choix, canon, prio = nil, false, 0
            if opts then
                for k, t in pairs(opts) do
                    local tl = string.lower(t)
                    local p = 0
                    if tl:find("approcher du canon", 1, true) then p = 100
                    elseif tl:find("ticket", 1, true) then p = 90
                    elseif tl:find("destination", 1, true) then p = 50
                    elseif tl:find("accepter", 1, true) or tl:find("partir", 1, true) or tl:find("voyage", 1, true) then p = 40
                    elseif tl:find("en savoir plus", 1, true) then p = 30
                    elseif tl:find("agence touriste", 1, true) then p = 1
                    else p = 10 end
                    if p > prio then prio, choix = p, -k canon = (p == 100) end
                end
            end
            if choix == nil then break end
            dire("PNJ 153 : reponse " .. tostring(choix) .. " (" .. tostring(prio) .. ")")
            pcall(function() npc:reply(choix) end)
            if canon then break end
            attendre(function() return signatureRepliques() ~= brut end, 2500)
        end
        pcall(function() global:leaveDialog() end)
        attendre(function() return not sur(function() return character:isBusy() end, false) end, 3000)
        for _ = 1, 3 do
            if carte() ~= ici then return end
            equiperLeDeguisement()
            pcall(function() map:door(355) end)
            if attendre(function() return carte() ~= ici end, 5000) then return end
        end
        pcall(function() map:door(355) end)
    end },
    { map = "156893704", custom = function()
        remettreCoiffeEtCape()
        if lireEtat("ZAAP_MOON") ~= "1" then ETAT_ETAPE.idx = #ETAPE.aller - 1 versCarte(ZAAP_MOON)
        else ETAT_ETAPE.idx = #ETAPE.aller versCarte(156499971) end
    end },
    { map = tostring(ZAAP_MOON), custom = function()
        if lireEtat("ZAAP_MOON") ~= "1" then
            pcall(function() map:saveZaap() end)
            ecrireEtat("ZAAP_MOON", 1)
            dire("zaap de Moon enregistre")
        end
        fermerInterfaces()
        attendre(function() return not sur(function() return character:isBusy() end, false) end, 2000)
        ETAT_ETAPE.idx = #ETAPE.aller
        versCarte(156499971)
    end },
    { map = "156499971", custom = function() remettreCoiffeEtCape() end },
}
ETAPE.entree = {
    carte = "156499971",
    pnj = 1384,
    reponses = { -2, -1 },
    reponsesTp = { -2 },
}
ETAPE.donjon = {
    { map = "157548544", fight = true },
    { map = "157549568", fight = true },
    { map = "157550592", fight = true },
    { map = "157551616", fight = true },
    { map = "157552640", fight = true },
    { map = "157553664", custom = function()
        parler(1384, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

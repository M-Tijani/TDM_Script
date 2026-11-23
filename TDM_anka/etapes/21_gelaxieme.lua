local function nb(gid) return tonumber(sur(function() return inventory:itemCount(gid) end, 0)) or 0 end
local function versCarte(id) avancerVers(id) end
local function occupe() return sur(function() return character:isBusy() end, false) == true end
local MULTYGELY = 996
local MULTYGELY_PRIX_MAX = 15000
local FLAQUES = { Bleuet = 2430, Citron = 2431, Fraise = 2432, Menthe = 2433 }
local MONSTRES = { [55] = "Bleuet", [56] = "Menthe", [57] = "Fraise", [429] = "Citron" }
local ROYALES = { [58] = true, [85] = true, [86] = true, [430] = true }
local function combatGelee()
    if enCombat() then return end
    publierMesFlaques()
    local ici = carte()
    if not estLeader() then
        attendre(function() pcall(autoPretAJour) return enCombat() or carte() ~= ici end, ATTENTE_EQUIPE_MS, 200)
        if not enCombat() and carte() == ici then rejouerCetteEntree() end
        return
    end
    if not attendre(function() pcall(reinviterAbsents) return equipePrete() end, ATTENTE_EQUIPE_MS, 200) then
        alerte("Gelaxieme " .. ici .. " : equipe pas prete (absents / groupe / auto join) -> pas de combat")
        rejouerCetteEntree()
        return
    end
    attendre(function()
        for _, a in ipairs(comptesEquipe()) do
            if carteDe(a) == ici and lireMem(cleFlaques(idDe(a))) == nil then return false end
        end
        return true
    end, 5000, 100)
    local g = groupeAEngager(ici)
    if g == nil then
        alerte("Gelaxieme " .. ici .. " : aucun groupe d'une couleur manquante (A VERIFIER : sortie de la salle)")
        return
    end
    local avant = FORCE_MONSTERS
    FORCE_MONSTERS = { tonumber(g.id) }
    pcall(function() map:fight() end)
    attendre(enCombat, 5000)
    FORCE_MONSTERS = avant
end
local function publierMesFlaques()
    local t = {}
    for c, gid in pairs(FLAQUES) do if nb(gid) >= 1 then t[#t + 1] = c end end
    ecrireMem(cleFlaques(moiId()), "," .. table.concat(t, ",") .. ",")
end
local function groupeAEngager(ici)
    local voulues = {}
    for _, a in ipairs(comptesEquipe()) do
        if carteDe(a) == ici then
            local f = tostring(lireMem(cleFlaques(idDe(a))) or ",")
            for c, _ in pairs(FLAQUES) do
                if not f:find("," .. c .. ",", 1, true) then voulues[c] = (voulues[c] or 0) + 1 end
            end
        end
    end
    local meilleur = nil
    for _, g in ipairs(groupesDeLaCarte()) do
        if g.royale then return g end
        local poids = g.couleur and voulues[g.couleur] or 0
        if poids > 0 and (meilleur == nil or poids > meilleur.poids
            or (poids == meilleur.poids and (tonumber(g.cellId) or 0) < (tonumber(meilleur.g.cellId) or 0))) then
            meilleur = { g = g, poids = poids }
        end
    end
    return meilleur and meilleur.g or nil
end
local function groupesDeLaCarte()
    local brut = sur(function() return map:monsterGroups() end, nil)
    local liste = {}
    if type(brut) ~= "table" then return liste end
    for _, g in ipairs(brut) do
        local parCouleur, royale = {}, false
        for _, m in ipairs(g.monsters or {}) do
            local id = tonumber(m.id)
            if ROYALES[id] then royale = true end
            local c = MONSTRES[id]
            if c ~= nil then parCouleur[c] = (parCouleur[c] or 0) + 1 end
        end
        local couleur, meilleur = nil, 0
        for c, n in pairs(parCouleur) do if n > meilleur then couleur, meilleur = c, n end end
        liste[#liste + 1] = { id = g.contextualId, cellId = g.cellId, couleur = couleur, royale = royale }
    end
    return liste
end
local function cleFlaques(id) return cleEquipe() .. "GEL_FLAQUES_" .. tostring(id) end

local ETAPE = {
    cle    = "gelaxieme",
    nom    = "Alain Deix, Multygely puis Gelaxieme Dimension",
    succes = { 60 },
    acces  = "multigely",
    detour = function()
        if ETAT_ETAPE == nil or (ETAT_ETAPE.phase ~= "aller" and ETAT_ETAPE.phase ~= "entree") or nb(MULTYGELY) < 1 then return nil end
        local c = carte()
        if c == "99091977" then
            if ETAT_ETAPE.phase ~= "entree" then changerPhase("entree") end
            return nil
        end
        if tostring(c):match("^9856") or tostring(c):match("^9857") then return nil end
        if c == tostring(CARTE_HAVRE_SAC) then return { { map = c, path = "zaap(68419587)" } } end
        local d = tonumber(sur(function() return map:GetPathDistance(tonumber(c), 99091977) end, 99)) or 99
        if d <= 15 then return { { map = c, custom = function() avancerVers(99091977) end } } end
        return { { map = c, path = "havenbag" } }
    end,
}
ETAPE.quete = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(68419587)" },
    { map = "99091977", custom = function()
        parler(1578, { -1, -1, -1 })
        versCarte(99095051)
    end },
}
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(191105026)" },
    { map = "191102976", custom = function()
        for _ = 1, 3 do
            if nb(MULTYGELY) >= 1 then break end
            pcall(function() npc:npc(315, 6) end)
            attendre(occupe, 3000)
            pcall(function() sale:buyItem(MULTYGELY, 1, MULTYGELY_PRIX_MAX) end)
            attendre(function() return nb(MULTYGELY) >= 1 end, 3000)
            fermerInterfaces()
        end
        if nb(MULTYGELY) < 1 then alerte("Multygely introuvable sous " .. MULTYGELY_PRIX_MAX .. " kamas") end
    end, path = "havenbag" },
    { map = "162791424", path = "zaap(68419587)" },
    { map = "99091977" },
}
ETAPE.entree = {
    carte = "99091977",
    pnj = nil,
    reponses = nil,
    reponsesTp = nil,
    custom = function()
        if nb(MULTYGELY) < 1 then
            alerte("aucun Multygely en sac : entree impossible dans la Gelaxieme")
            return
        end
        local avant = carte()
        if not pcall(function() inventory:useItem(MULTYGELY) end) then
            pcall(function() inventory:useItem(MULTYGELY) end)
        end
        attendre(function() return carte() ~= avant end, 5000)
    end,
}
ETAPE.donjon = {
    { map = "98566657", custom = combatGelee },
    { map = "98567681", custom = combatGelee },
    { map = "98566659", custom = combatGelee },
    { map = "98567683", custom = combatGelee },
    { map = "98568707", custom = function()
        local ici = carte()
        local dejaPasses = 0
        for _, a in ipairs(comptesEquipe()) do if tostring(carteDe(a)) == "98567687" then dejaPasses = dejaPasses + 1 end end
        if dejaPasses == 0 and not equipeAuComplet(ici, nil, true) then return end
        parler(374, { -1 }, { changeCarte = 5000 })
    end },
    { map = "98567687", custom = combatGelee },
    { map = "98568705", custom = function()
        if #groupesDeLaCarte() > 0 then combatGelee() return end
        local avant = carte()
        for _, cellule in ipairs({ 268, 430 }) do
            pcall(function() map:door(cellule) end)
            if attendre(function() return carte() ~= avant end, 2500) then return end
            pcall(function() global:leaveDialog() end)
        end
        for _, d in ipairs({ "bottom", "top", "right", "left" }) do
            pcall(function() map:changeMap(d) end)
            if attendre(function() return carte() ~= avant end, 2500) then return end
        end
    end },
}
ETAPE.apres = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(68419587)" },
    { map = "99091977", custom = function()
        parler(1578, { -1, -1, -1 })
        versCarte(99090953)
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

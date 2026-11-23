FIGHT_KICK = 0
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/deblocage.lua") end)
global:printSuccess("-------------------------------------------------------------------------------")
global:printSuccess("-------------------------------------------- DJ-CROCA -----------------------------------------------")
global:printColor("#FFBBFF", "--------------------------------------------By Astro ----------------------------------------------")
IGNORE_REQUEST_DUEL = true
IGNORE_REQUEST_EXCHANGE = true
delete_items = {381,1736,311,2436,16827,380,31519,2471,2432,2430,2431,2472,2447,2470,2446,16833}
LEVEL_UP_DELAY_MIN = 0
LEVEL_UP_DELAY_MAX = 0
targetLevel = 160
MAP_ENTRY = 198967296
CAC_ID = 18604
STUFFS = {
    [712] = 6,
    [8243] = 6,
    [18667] = 15,
    [2532] = 7,
    [8534] = 7,
    [1487] = 3,
    [8242] = 3,
    [1665] = 5,
    [17495] = 5,
    [2373] = 5,
    [2390] = 0,
    [8217] = 0,
    [732] = 2,
    [8222] = 2,
    [103] = 4,
    [835] = 1,
    [7131] = 4,
    [972] = 10,
    [8072] = 11,
    [6716] = 8,
    [34615] = 12,
}
local function setTeamVariable(varName, varValue)
	local bossAccount  = global:thisAccountController()
	local teamAccounts = bossAccount:getTeamAccounts()
	for _, account in pairs(teamAccounts) do
	   account:setScriptVariable(varName, varValue)
	end
 end
 function ici() return tostring(sur(function() return map:currentMapId() end, "")) end
function cibleDe(account)
	local id = tostring(account.character:id())
	local v = nil
	pcall(function() v = developer:getInGlobalMemory("RS_CIBLE_PL_" .. id) end)
	return tonumber(v) or targetLevel
 end
 function podsP() return tonumber(sur(function() return inventory:podsP() end, 0)) or 0 end
function sur(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end
function checkTeamLevel()
	local bossAccount  = global:thisAccountController()
	local teamAccounts = bossAccount:getTeamAccounts()
	local nomChef = bossAccount:getUsername()
	for _, account in pairs(teamAccounts) do
	   if account:getUsername() ~= nomChef and account.character:level() < cibleDe(account) then
		  return false
	   end
	end
	return true
 end
function attendre(cond, maxMs)
    local t = 0
    while t <= maxMs do
        if sur(cond, false) then return true end
        global:delay(50); t = t + 50
    end
    return false
end

RESTAT_MULES_PL = false
function chooseChallenge(challengeId, i)
    local envoye = false
    for _, nom in ipairs({ "ChallengeSelectionRequest", "ChallengeSelectionMessage" }) do
        if not envoye then
            envoye = pcall(function()
                local msg = developer:createMessage(nom)
                pcall(function() msg.challengeId = challengeId end)
                pcall(function() msg.ChallengeId = challengeId end)
                developer:sendMessage(msg)
            end)
        end
    end
    return challengeId
end
function leave()
	parlerAuPnjCroca(1, "sortie du donjon")
end
function getBetterItem(position, levelmax, sac)
    sac = sac or contenuSac()
    local best, bestNiv = nil, -1
    for g, p in pairs(STUFFS) do
        if p == position and sac[g] ~= nil then
            local n = niveauObjet(g)
            if n <= levelmax and n > bestNiv then best, bestNiv = g, n end
        end
    end
    return best or false
end
function parlerAuPnjCroca(reponses, quoi)
    local depart = ici()
    for essai = 1, 3 do
        pcall(function() npc:npc(789, 3) end)
        local premiere = -1
        if reponses >= 2 then
            local ids = {}
            local t = 0
            while t < 2000 and #ids == 0 do
                pcall(function() local r = global:getReplies() for _, x in ipairs(r) do ids[#ids + 1] = x end end)
                if #ids == 0 then pcall(function() local r = global:getReplies() for i = 0, r.Count - 1 do ids[#ids + 1] = r[i] end end) end
                if #ids == 0 then global:delay(50) t = t + 50 end
            end
            for _, x in ipairs(ids) do if tostring(x) == "47058" then premiere = x end end
            if premiere == -1 and #ids >= 4 then premiere = ids[2] end
        end
        for k = 1, reponses do pcall(function() npc:reply(k == 1 and premiere or -1) end) end
        if attendre(function() return ici() ~= depart end, 4000) then
            global:printSuccess("[CROCA] " .. quoi)
            return
        end
        pcall(function() global:leaveDialog() end)
        global:printError("[CROCA] " .. quoi .. " : carte inchangee (essai " .. essai .. "/3)")
    end
    pcall(function() global:restartScript() end)
end
function contenuSac()
    local t = {}
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local gid = tonumber(it.Item.Gid)
            local pos = tonumber(it.Position)
            if gid ~= nil then
                local e = t[gid]
                if e == nil or (e.pos == 63 and pos ~= 63) then t[gid] = { uid = it.Item.Uid, pos = pos } end
            end
        end
    end)
    return t
end
function join ()
	parlerAuPnjCroca(2, "entree dans le donjon")
end
function equipItem(gid, position, uid)
    if uid == nil then
        local e = contenuSac()[gid]
        if e == nil or e.pos ~= 63 then return false end
        uid = e.uid
    end
    local ok = pcall(function()
        local message = developer:createMessage("ObjectSetPositionRequest")
        message.ObjectUid = uid
        message.Quantity = 1
        message.Position = position
        developer:sendMessage(message)
    end)
    if not ok then return false end
    local fait = attendre(function() local e = contenuSac()[gid]; return e ~= nil and e.pos == position end, 2000)
    if fait then global:printSuccess("[STUFF] " .. gid .. " equipe en place " .. position) end
    return fait
end
function restatSelonLeRole()
    if sur(function() return character:isInFight() end, false) then return end
    if estLeLeader() then return end
    if RESTAT_MULES_PL == true and not RESTAT_SAGESSE_ENVOYE
       and ((tonumber(sur(function() return character:getVitalityBase() end, 0)) or 0) > 0
         or (tonumber(sur(function() return character:getStrenghtBase() end, 0)) or 0) > 0) then
        RESTAT_SAGESSE_ENVOYE = true
        local avant = tonumber(sur(function() return character:statsPoint() end, 0)) or 0
        global:printMessage("[RESTAT] mule (RESTAT_MULES_PL = true) -> reinitialisation (full sagesse)")
        developer:sendMessage(developer:createMessageFromJson("krd", "{}"))
        attendre(function() return character:statsPoint() > avant end, 3000)
    end
    local pts = tonumber(sur(function() return character:statsPoint() end, 0)) or 0
    if pts <= 0 then return end
    pcall(function() character:upgradeWisdom(pts) end)
    attendre(function() return character:statsPoint() < pts end, 2000)
    global:printSuccess("[STATS] mule : " .. pts .. " point(s) en sagesse | sagesse "
        .. tostring(sur(function() return character:getWisdomBase() end, "?"))
        .. " | points restants " .. tostring(sur(function() return character:statsPoint() end, "?")))
end
function stuff()
    if sur(function() return character:isInFight() end, false) then return end
    local niv = tonumber(sur(function() return character:level() end, 0)) or 0
    local sac = contenuSac()
    local vues = {}
    for _, position in pairs(STUFFS) do
        if not vues[position] then
            vues[position] = true
            local g = getBetterItem(position, niv, sac)
            if g and sac[g].pos == 63 then equipItem(g, position, sac[g].uid) end
        end
    end
end
function niveauObjet(gid) return tonumber(sur(function() return inventory:getLevel(gid) end, 9999)) or 9999 end
function estLeLeader()
    if sur(function() return global:isBoss() end, false) == true then return true end
    return (tonumber(sur(function() return character:level() end, 0)) or 0) >= 160
end
function preparerMembrePL()
	if PL_PREPARE then return end
	PL_PREPARE = true
	local dossier = global:getCurrentScriptDirectory()
	local xml = global:isBoss() and "SACRI CROCA 300 VITA FORCE.xml" or "MULE 0 FLAG.xml"
	pcall(function() global:loadConfigurationWithoutScript(dossier .. "\\..\\xml\\" .. xml) end)
	local n = 0
	pcall(function() local l = global:charactersList(); n = l.Characters and #l.Characters or 0 end)
	if n == 0 then pcall(function() local l = global:charactersList(); for _ in ipairs(l) do n = n + 1 end end) end
	if n > 0 then
		local cle = "RS_NB_PERSOS_" .. tostring(character:id())
		pcall(function()
			if developer:getInGlobalMemory(cle) ~= nil then developer:editInGlobalMemory(cle, tostring(n)) else developer:addInGlobalMemory(cle, tostring(n)) end
		end)
	end
end

CARTES_DONJON = { ["198967296"] = true, ["198968320"] = true, ["198969344"] = true, ["198970368"] = true,
    ["198971392"] = true, ["198972416"] = true, ["198972418"] = true }
ZAAP_SCARA = 88212481
CARTE_HAVRE_SAC = "162791424"
TRAJET_VERS_CROCA = {
    ["88212481"] = { path = "left" },
    ["84412416"] = { path = "left" },
    ["84411904"] = { path = "left" },
    ["84411392"] = { door = "202" },
    ["199230724"] = { door = "274" },
    ["198181888"] = { path = "right" },
    ["198182400"] = { path = "right" },
    ["198182912"] = { path = "bottom" },
    ["198182913"] = { door = "319" },
}
function retourVersCroca(m)
    local e = TRAJET_VERS_CROCA[m]
    if e ~= nil then return { { map = m, path = e.path, door = e.door } } end
    if m == CARTE_HAVRE_SAC then return { { map = m, path = "zaap(" .. ZAAP_SCARA .. ")" } } end
    return { { map = m, custom = versHavreSac } }
end
function move()
    do local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end end
	pcall(preparerMembrePL)
	pcall(restatSelonLeRole)
	if global:isBoss() then
    if checkTeamLevel() then
        global:printSuccess("[PL] TOUTES LES MULES ONT ATTEINT LEUR NIVEAU CIBLE")
        pcall(function()
            local cle = "RS_PL_FINI_" .. tostring(character:id())
            if developer:getInGlobalMemory(cle) ~= nil then developer:editInGlobalMemory(cle, "1") else developer:addInGlobalMemory(cle, "1") end
        end)
        global:finishScript()
        return
    end
end
		local m = ici()
		if not CARTES_DONJON[m] then return retourVersCroca(m) end
		 if inventory:itemCount(8342) == 0 and map:currentMapId() == 198967296 then
			global:disconnect()
		end
		if map:currentMapId() == MAP_ENTRY then
			if global:isBoss() then
				local cle = "DCL_ATTENDRE_" .. tostring(character:name())
				local v = nil
				pcall(function() v = developer:getInGlobalMemory(cle) end)
				if tostring(v) == "1" then
					pcall(function() developer:deleteFromGlobalMemory(cle) end)
					global:printSuccess("[PL] clefs de donjon a recevoir : passage a la banque de Bonta")
					if pcall(function() global:loadAndStart(global:getCurrentScriptDirectory() .. "\\..\\outils\\recevoir-clefs-direct.lua") end) then return {} end
				end
			end
			if not global:isBoss() then
			   pcall(stuff)
			end
		end
    return
		{
			{ map = "198967296", custom = join},
            { map = "198968320", forcefight = true, done = false },
            { map = "198969344", forcefight = true, done = false },
            { map = "198970368", forcefight = true, done = false },
            { map = "198971392", forcefight = true, done = false },
            { map = "198972416", forcefight = true, done = false },
			{ map = "198972418", custom = leave},
		   }
end
function versHavreSac()
    local m = ici()
    pcall(function() global:leaveDialog() end)
    pcall(function() exchange:leave() end)
    if sur(function() return map:changeMap("havenbag") end, false) then return end
    local cellules = sur(function() return map:getWalkableCells() end, nil)
    local liste = {}
    pcall(function() for _, c in ipairs(cellules) do liste[#liste + 1] = c end end)
    if #liste > 0 then
        local c0 = sur(function() return map:currentCell() end, nil)
        pcall(function() map:moveToCell(liste[math.random(1, #liste)]) end)
        attendre(function() return sur(function() return map:currentCell() end, nil) ~= c0 end, 1500)
    end
    if sur(function() return map:changeMap("havenbag") end, false) then return end
    if attendre(function() return ici() ~= m end, 2500) then return end
    global:printError("[PL] havre-sac refuse sur " .. m .. " : relance du script")
    pcall(function() global:restartScript() end)
end

SASA_A_GARDER = { 732, 835, 712, 2390, 1487, 2532, 7131, 1665, 18667, 972, 34615 }
CLEFS_A_GARDER = { 8342 }
OBJETS_RUN_A_GARDER = { 10207, 7423, 7425, 996, 15990, 8343, 7927, 12073, 8151, 6965,
    8143, 8545, 8437, 1568, 1570, 15991, 11799, 26680, 7918, 8139, 1569, 8135, 27374, 12017, 8917, 9248, 9254, 11798,
    14464, 7557, 7511, 8320, 7908, 8156, 8439, 8438, 7926, 11174, 7924, 8142,
    8262, 16169, 8263, 13851, 8470, 8471, 8847, 8265, 33044, 737, 694, 17078, 12724, 13759, 13829,
    18686, 14848, 1019, 1021 }
STUFF_RUN_A_DEPOSER = { 8463, 8464, 8465, 8466, 8467, 8468, 250, 1499, 18687 }
CARTE_BANQUE_ASTRUB = "192415750"
function gidsGardesAuDepot()
    local exclus = {}
    for _, g in ipairs(STUFF_RUN_A_DEPOSER) do exclus[g] = true end
    local vus, liste = {}, {}
    local function ajouter(g) if not exclus[g] and not vus[g] then vus[g] = true; liste[#liste + 1] = g end end
    for _, g in ipairs(SASA_A_GARDER) do ajouter(g) end
    for _, g in ipairs(CLEFS_A_GARDER) do ajouter(g) end
    for _, g in ipairs(OBJETS_RUN_A_GARDER) do ajouter(g) end
    for g, _ in pairs(STUFFS) do ajouter(g) end
    return liste
end
DEPOTS_SANS_EFFET = DEPOTS_SANS_EFFET or 0
function bank()
    local m = ici()
    if CARTES_DONJON[m] and m ~= tostring(MAP_ENTRY) then return move() end
    if m == CARTE_BANQUE_ASTRUB then return { { map = m, custom = deposerBanque } } end
    if m == "191104002" then return { { map = m, door = "288" } } end
    if m == "191105026" then return { { map = m, path = "left" } } end
    if m == CARTE_HAVRE_SAC then return { { map = m, path = "zaap(191105026)" } } end
    return { { map = m, custom = versHavreSac } }
end
function check()
	for _, v in ipairs(delete_items) do
		if inventory:itemCount(v) > 0 then
			inventory:deleteItem(v, inventory:itemCount(v))
		end
	end
end
function deposerBanque()
    local avant = podsP()
    pcall(function() npc:npcBank(-1) end)
    if not attendre(function() return exchange:storageKamas() ~= nil end, 5000) then
        pcall(function() npc:reply(-1) end)
        attendre(function() return exchange:storageKamas() ~= nil end, 3000)
    end
    pcall(function() exchange:putAllItemsExcept(gidsGardesAuDepot()) end)
    attendre(function() return podsP() < avant end, 5000)
    pcall(function() exchange:leave() end)
    pcall(function() global:leaveDialog() end)
    local apres = podsP()
    global:printSuccess("[BANQUE] depot Astrub : " .. avant .. " % -> " .. apres .. " %")
    if apres >= avant then
        DEPOTS_SANS_EFFET = DEPOTS_SANS_EFFET + 1
        if DEPOTS_SANS_EFFET >= 2 then
            global:printError("[BANQUE] 2 depots sans effet : arret du script (verifier le coffre / la liste gardee)")
            global:finishScript()
            return
        end
    else
        DEPOTS_SANS_EFFET = 0
    end
    versHavreSac()
end
function phenix()
    global:printError("[PL] perso mort (fantome) : aucun trajet phenix dans pl-croca.lua")
    return {}
end
function challengeManagement(challengeCount, isMule)
	local challengesPriority = {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
	}
	local challengeBonus = 0
	local challengeMod = 1
	local challengeBonusText = { "XP", "DROP" }
	local challengeModText = { "Manuel", "Aléatoire" }
	local ChallengeBonusChoiceRequest = developer:createMessage("ChallengeBonusChoiceRequest")
	ChallengeBonusChoiceRequest.ChallengeBonus = challengeBonus
	developer:sendMessage(ChallengeBonusChoiceRequest)
	if not isMule then
		global:printSuccess("Challenges: "..challengeModText[challengeMod + 1].." - Bonus: "..challengeBonusText[challengeBonus + 1])
	else
		global:printSuccess("[MULE] Bonus: "..challengeBonusText[challengeBonus + 1])
		return
	end
	local ChallengeModSelectRequest = developer:createMessage("ChallengeModSelectRequest")
	ChallengeModSelectRequest.ChallengeMod = challengeMod
	developer:sendMessage(ChallengeModSelectRequest)
	if challengeMod == 0 then
		global:printMessage("Attente aléatoire avant ...")
		global:delay(global:random(1000, 2000))
		global:printMessage("Passage à l'étape du choix des challenges ...")
		local ChallengeReadyRequest = developer:createMessage("ChallengeReadyRequest")
		ChallengeReadyRequest.ChallengeMod = challengeMod
		developer:sendMessage(ChallengeReadyRequest)
		for i = 1, challengeCount do
			local state = developer:suspendScriptUntil("ChallengeProposalEvent", "", false, 5000, true, 50)
			if state == false then
				return
			end
			local proposedChallenges = fightChallenge:getLastChallengeProposalMessage()
			global:printMessage("Liste des challenges proposés pour le slot N°"..tostring(i)..":")
			for index, proposedChallenge in ipairs(proposedChallenges.ChallengeProposals) do
				if index > 2 then
					break
				end
				global:printMessage("         Challenge: "..fightChallenge:challengeName(proposedChallenge.ChallengeId).." - Bonus XP: "..tostring(proposedChallenge.XpBonus).."% - Bonus DROP: "..tostring(proposedChallenge.DropBonus).."%")
			end
			local choosedChallengeId = chooseChallenge(proposedChallenges.ChallengeProposals[1].ChallengeId, i)
			local found = false
			for _, challengePriority in ipairs(challengesPriority) do
				for index, proposedChallenge in ipairs(proposedChallenges.ChallengeProposals) do
					if index > 2 then
						break
					end
					if proposedChallenge.ChallengeId == challengePriority then
						if index > 1 then
							choosedChallengeId = chooseChallenge(proposedChallenge.ChallengeId, i)
						end
						found = true
						break
					end
				end
				if found then
					break
				end
			end
		end
		global:printMessage("Attente aléatoire après ...")
		global:delay(global:random(1000, 2000))
	end
end

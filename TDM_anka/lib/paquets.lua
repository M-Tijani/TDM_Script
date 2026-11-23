function direTechnique(couleur, texte) if MODE_TECHNIQUE then pcall(function() global:printColor(couleur, texte) end) end end
JSON_AUTO_JOIN  = '{"fpyv":null}'
JSON_AUTO_READY = '{"fpvl":0}'
function envoyerPaquetJson(nom, json, role)
    if nom == nil or nom == "" or json == nil or json == "" then
        return false
    end
    local ok = pcall(function()
        developer:sendMessage(developer:createMessageFromJson(nom, json))
    end)
    if not ok then
        global:printError("« " .. tostring(role) .. " » a echoue. JSON envoye : "
            .. tostring(json))
        return false
    end
    return true
end
PAQUETS_BRUTS = {
    accepterInvitation = {
        { nom = "PartyInvitationAcceptRequest",
          json = function(p) return '{"PartyId":' .. p.partyId .. '}' end },
        { nom = "ikg", json = function(p) return '{"fqbi":' .. p.partyId .. ',"fqbj":0}' end },
    },
    refuserInvitation = {
        { nom = "PartyInvitationRefuseRequest",
          json = function(p) return '{"PartyId":' .. p.partyId .. '}' end },
        { nom = "ilu", json = function(p) return '{"fqhg":0,"fqhh":' .. p.partyId .. '}' end },
    },
    exclureDuGroupe = {
        { nom = "PartyKickRequest",
          json = function(p) return '{"PartyId":' .. p.partyId .. ',"PlayerId":' .. p.playerId .. '}' end },
        { nom = "iko", json = function(p) return '{"fqcu":' .. p.partyId .. ',"fqcv":' .. p.playerId .. '}' end },
    },
    quitterLeGroupe = {
        { nom = "PartyLeaveRequest",
          json = function(p) return '{"PartyId":' .. p.partyId .. '}' end },
        { nom = "ilb", json = function(p) return '{"fqev":' .. p.partyId .. ',"fqew":{}}' end },
    },
    demanderIdentifiantGroupe = {
        { nom = "PartyInvitationRequest", json = function() return '{"Target":{},"PartyType":1}' end },
        { nom = "jyb", json = function() return '{"fwmg":{},"fwmh":1}' end },
    },
    autoJoin  = { { nom = "ily", json = function() return '{"fpyv":null}' end } },
    autoReady = { { nom = "ikm", json = function() return '{"fpvl":0}' end } },
    confirmerTeleportationDesMembres = {
        { nom = "TeleportBuddiesAnswerRequest", json = function() return '{"Accept":true}' end },
        { nom = "hit", json = function() return '{"fmcl":true,"fmcm":false,"fmcn":[]}' end },
    },
    ouvrirLePanneauDesSucces = { { nom = "knz", json = function() return '{"fysm":0,"fysn":true}' end } },
    demanderCategorieDeSucces = {
        { nom = "AchievementsDetailedRequest",
          json = function(p) return '{"CategoryId":' .. p.categorie .. '}' end },
        { nom = "mdk", json = function(p) return '{"gezq":null,"gezr":' .. p.categorie .. '}' end },
    },
    regenerationRapide = {
        { nom = "EmotePlayRequest", json = function() return '{"EmoteId":1}' end },
        { nom = "kez", json = function() return JSON_REGENERATION_RAPIDE end },
    },
    nourrirLeFamilier = {
        { nom = "ObjectFeedRequest",
          json = function(p) return '{"ObjectUid":' .. p.familier .. ',"Meal":[{"Quantity":'
              .. p.quantite .. ',"ObjectUid":' .. p.uid .. '}]}' end },
        { nom = "isq",
          json = function(p) return '{"frka":' .. p.familier .. ',"frkb":[{"garl":"","garm":'
              .. p.quantite .. ',"garn":' .. p.uid .. '}],"frkc":0}' end },
    },
    poserObjetDansLEchange = {
        { nom = "ExchangeObjectMoveRequest",
          json = function(p) return '{"ObjectUid":' .. p.uid .. ',"Quantity":' .. (p.quantite or 1) .. '}' end },
        { nom = "kec", json = function(p) return '{"fxnl":' .. (p.quantite or 1) .. ',"fxnm":' .. p.uid .. '}' end },
    },
    validerLEchange = {
        { nom = "ExchangeReadyRequest", json = function() return '{"Ready":true,"Step":5}' end },
        { nom = "kcs", json = function() return '{"fxig":false,"fxih":true,"fxii":5}' end },
    },
    reinitialiserCaracteristiques = {
        { nom = "ResetCharacterCharacteristicsRequest", json = function() return "{}" end },
        { nom = "krt", json = function() return "{}" end },
    },
}
PAQUETS_OBFUSQUES_VERSION = 'releve du sniffer 10/10/2026 (sha1 c44c5e3b72), genere le 10/10/2026 09:46'
PAQUETS_OBFUSQUES = {
    accepterInvitation = { nom = 'ijh', json = function(p) return '{"frkw":' .. p.partyId .. '}' end },
    refuserInvitation = { nom = 'iif', json = function(p) return '{"frfv":' .. p.partyId .. '}' end },
    exclureDuGroupe = { nom = 'ihd', json = function(p) return '{"frbu":' .. p.playerId .. ',"frbv":' .. p.partyId .. '}' end },
    quitterLeGroupe = { nom = 'ihb', json = function(p) return '{"frbj":' .. p.partyId .. '}' end },
    demanderIdentifiantGroupe = { nom = 'iks', json = function(p) return '{"frqg":1,"frqh":{}}' end },
    autoJoin = { nom = 'ikg', json = function(p) return '{}' end },
    autoReady = { nom = 'iko', json = function(p) return '{}' end },
    confirmerTeleportationDesMembres = { nom = 'hhm', json = function(p) return '{"fnlf":true}' end },
    accepterTeleportation = { nom = 'hgo', json = function(p) return '{}' end },
    ouvrirLePanneauDesSucces = { nom = 'mdt', json = function(p) return '{}' end },
    demanderCategorieDeSucces = { nom = 'mdm', json = function(p) return '{"ggnb":' .. p.categorie .. '}' end },
    poserObjetDansLEchange = { nom = 'jys', json = function(p) return '{"fxyo":' .. p.uid .. ',"fxyq":' .. (p.quantite or 1) .. '}' end },
    validerLEchange = { nom = 'kba', json = function(p) return '{"fyia":5,"fyib":true}' end },
    accepterEchange = { nom = 'kax', json = function(p) return '{}' end },
    reinitialiserCaracteristiques = { nom = 'krd', json = function(p) return '{}' end },
}
PAQUETS_RECEPTION = {
    partyId = { 'iiw', 'ijs', 'ijd' },
    invitation = { 'ije' },
    infoTexte = { 'lof' },
    demandeEchange = { 'kaz' },
    succes = { 'mdo' },
    sortieEchange = { 'kbr' },
    offreTeleport = { 'hhi' },
    champs = {
        partyId = { 'frkg', 'frii', 'frlw', 'frjy' },
        fromName = { 'frke' },
    },
}
CANONIQUES_VERIFIES = {
    PartyLeaveRequest            = true,
    TeleportToBuddyAnswerRequest = true,
    TeleportToBuddyOfferEvent    = true,
    AchievementsDetailedEvent    = true,
    TextInformationEvent         = true,
    ExchangeRequestedTradeEvent  = true,
    ExchangeLeaveEvent           = true,
}
PAQUETS_HISTORIQUES_PERMIS = false
function nomsDeChamp(connus, cle)
    local liste, vus = {}, {}
    for _, groupe in ipairs({ connus or {}, (PAQUETS_RECEPTION.champs or {})[cle] or {} }) do
        for _, n in ipairs(groupe) do
            if n ~= nil and n ~= "" and not vus[n] then
                vus[n] = true
                table.insert(liste, n)
            end
        end
    end
    return liste
end
function nomsDePaquets(canoniques, generes, historiques)
    local liste, vus = {}, {}
    local function ajouter(n)
        if n ~= nil and n ~= "" and not vus[n] then
            vus[n] = true
            table.insert(liste, n)
        end
    end
    for _, n in ipairs(canoniques or {}) do
        if CANONIQUES_VERIFIES[n] == true then ajouter(n) end
    end
    for _, n in ipairs(generes or {}) do ajouter(n) end
    if PAQUETS_HISTORIQUES_PERMIS == true and #liste == 0 then
        for _, n in ipairs(historiques or {}) do ajouter(n) end
    end
    return liste
end

PAQUETS_BRUTS_RETENU = {}
PAQUETS_SANS_FORME_DIT = {}
function envoyerAutoReady()
    if envoyerPaquetBrut("autoReady", {}, "auto ready") then
        return true
    end
    local ok = pcall(function() global:teamCheck() end)
    if not ok then
        global:printError("global:teamCheck() a echoue : l equipe ne se"
            .. " declarera pas prete automatiquement")
    end
    return ok
end
function envoyerPaquetBrut(cle, p, role)
    local formes = PAQUETS_BRUTS[cle]
    if formes == nil then
        global:printError("[PAQUET] cle inconnue : " .. tostring(cle))
        return false
    end
    p = p or {}
    role = role or cle
    local generee = PAQUETS_OBFUSQUES[cle]
    local verifiees = {}
    if generee ~= nil then table.insert(verifiees, generee) end
    for _, f in ipairs(formes) do
        if CANONIQUES_VERIFIES[f.nom] == true then table.insert(verifiees, f) end
    end
    if #verifiees == 0 and PAQUETS_HISTORIQUES_PERMIS == true then verifiees = formes end
    if #verifiees == 0 then
        if PAQUETS_SANS_FORME_DIT[cle] ~= true then
            PAQUETS_SANS_FORME_DIT[cle] = true
            global:printColor("#F39C12", "[PAQUET] « " .. tostring(role) .. " » : aucune forme"
                .. " verifiee pour « " .. tostring(cle) .. " » (ni classe du jour relevee au"
                .. " sniffer, ni canonique de la liste blanche) — rien n est envoye, le repli"
                .. " natif prend la main s il existe")
        end
        return false
    end
    formes = verifiees
    local ordre = {}
    local retenue = PAQUETS_BRUTS_RETENU[cle]
    if retenue ~= nil and retenue <= #formes then table.insert(ordre, retenue) end
    for i = 1, #formes do
        if i ~= retenue then table.insert(ordre, i) end
    end
    local essayes = ""
    for _, i in ipairs(ordre) do
        local forme = formes[i]
        local okJson, json = pcall(forme.json, p)
        if okJson and type(json) == "string" and json ~= "" then
            local ok = pcall(function()
                developer:sendMessage(developer:createMessageFromJson(forme.nom, json))
            end)
            if ok then
                if PAQUETS_BRUTS_RETENU[cle] ~= i then
                    PAQUETS_BRUTS_RETENU[cle] = i
                    direTechnique("#7F8C8D", "[PAQUET] « " .. tostring(role)
                        .. " » passe par « " .. tostring(forme.nom) .. " »")
                end
                return true
            end
        end
        essayes = essayes .. " " .. tostring(forme.nom)
    end
    global:printError("« " .. tostring(role) .. " » a echoue : aucun nom accepte parmi"
        .. essayes .. ".")
    global:printMessage("  Le protocole a tourne : relevez le nouveau nom et ses champs"
        .. " au sniffer, et ajoutez une forme a PAQUETS_BRUTS." .. tostring(cle) .. ".")
    return false
end
function champPaquet(message, noms)
    for _, nom in ipairs(noms) do
        local valeur = nil
        local ok = pcall(function() valeur = message[nom] end)
        if ok and valeur ~= nil then
            return valeur, nom
        end
    end
    return nil, nil
end
function envoyerAutoJoin()
    if envoyerPaquetBrut("autoJoin", {}, "auto join") then
        return true
    end
    local ok = pcall(function() global:joinBoss() end)
    if not ok then
        global:printError("global:joinBoss() a echoue : les mules ne"
            .. " rejoindront pas le combat du chef")
    end
    return ok
end
function enregistrerMessage(nom, fonction, role)
    if fonction == nil then
        global:printError("Message « " .. tostring(nom) .. " » (" .. role
            .. ") : gestionnaire introuvable, enregistrement ignore")
        return false
    end
    local ok = pcall(function()
        developer:registerMessage(nom, fonction)
    end)
    if not ok then
        global:printError("Message « " .. tostring(nom) .. " » REFUSE par le bot"
            .. " — « " .. role .. " » est desactive. Le nom du paquet a"
            .. " probablement change : relevez-le au sniffer.")
        return false
    end
    return true
end
function longueurCollection(collection)
    if collection == nil then return 0 end
    local n = nil
    pcall(function() n = #collection end)
    if type(n) ~= "number" then
        pcall(function() n = collection.Count end)
    end
    if type(n) ~= "number" or n < 0 then return 0 end
    return n
end
PAQUETS_INFO_TEXTE = nomsDePaquets({ "TextInformationEvent" }, PAQUETS_RECEPTION.infoTexte, { "log", "lqn" })
PAQUETS_INVITATION = nomsDePaquets({ "PartyInvitationEvent" }, PAQUETS_RECEPTION.invitation, { "ijz", "ikb" })
PAQUET_INVITATION  = PAQUETS_INVITATION[1]
PAQUET_INFO_TEXTE  = PAQUETS_INFO_TEXTE[1]

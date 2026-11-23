local function occupe() return sur(function() return character:isBusy() end, false) == true end
local function coffreOuvert()
    if sur(function() return exchange:isInExchange() end, false) == true then return true end
    return sur(function() return exchange:storageKamas() end, nil) ~= nil
end
local function equipeDeQueteSur(c)
    local passeur = false
    for i, a in ipairs(comptesEquipe()) do
        if not (i == 1 and passeur) and carteDe(a) ~= tostring(c) then return false end
    end
    return true
end
local function versCarte(id) avancerVers(id) end
local function nb(gid) return tonumber(sur(function() return inventory:itemCount(gid) end, 0)) or 0 end

local CLEF_CRAQ = 7927
local AILES = { 1455, 1456, 1457, 1458 }
local function retournerAcheterLaCle()
    dire("leader sans clef des Craqueleurs -> HDV ressources de Sufokia")
end
local function acheterLesAiles()
    local m = (lireEtat("CRAQ_119") == "1") and {} or ailesManquantes()
    if #m > 0 then
        pcall(function() npc:npc(515220, 6) end)
        attendre(occupe, 3000)
        for _, g in ipairs(m) do
            local avant = nb(g)
            pcall(function() sale:buyItem(g, 1, 2000) end)
            attendre(function() return nb(g) > avant end, 3000)
        end
        pcall(function() global:leaveDialog() end)
    end
    if false and estLeader() and ACHAT_CLE_CRAQUELEURS_LEADER == true and nb(CLEF_CRAQ) < 1 then
        fermerInterfaces()
        local prix = {}
        local kamas = tonumber(sur(function() return character:kamas() end, 0)) or 0
        pcall(function() npc:npc(515220, 6) end)
        attendre(occupe, 3000)
        for _, lot in ipairs({ 1, 10 }) do
            if nb(CLEF_CRAQ) >= 1 then break end
            local p = prix[lot]
            local plafond = (p ~= nil and p > 1) and p or kamas
            if plafond <= kamas then
                pcall(function() sale:buyItem(CLEF_CRAQ, lot, plafond) end)
                attendre(function() return nb(CLEF_CRAQ) >= 1 end, 4000)
            end
        end
        fermerInterfaces()
        if nb(CLEF_CRAQ) >= 1 then dire("clef des Craqueleurs achetee (HDV ressources)")
        else
            alerte("clef des Craqueleurs : aucune offre achetable a l HDV ressources 515220 (voir prix ci-dessus) -> nouvel essai dans 30 s")
            attendre(function() return false end, 30000, 1000)
            rejouerCetteEntree()
            return
        end
    end
    if lireEtat("CRAQ_119") == "1" then
        pcall(function() map:changeMap("havenbag") end)
        return
    end
    if lireEtat("CRAQ_119") ~= "1" and #ailesManquantes() > 0 then
        alerte("Ailes de Scarafeuille manquantes apres coffre et HDV : le 119 ne validera pas (A VERIFIER)")
    end
    versCarte(185862149)
end
local function leaderSansCle()
    local j = jetonClef()
    return j ~= nil and lireEtat("CLEF_CRAQ_" .. j) ~= "1" and nb(CLEF_CRAQ) < 1
end
local function ailesManquantes()
    local m = {}
    for _, g in ipairs(AILES) do if nb(g) < 1 then m[#m + 1] = g end end
    return m
end
local function retirerLesAiles()
    if #ailesManquantes() == 0 then return end
    pcall(function() npc:npcBank(-1) end)
    attendre(function() return coffreOuvert() or occupe() end, 3000)
    if not coffreOuvert() and occupe() then
        pcall(function() npc:reply(-1) end)
        attendre(coffreOuvert, 2500)
    end
    for _, g in ipairs(ailesManquantes()) do
        pcall(function() exchange:getItem(g, 1) end)
        attendre(function() return nb(g) >= 1 end, 2000)
    end
    pcall(function() exchange:leave() end)
    attendre(function() return not coffreOuvert() end, 2000)
end
local function jetonClef()
    local j = ACHAT_CLE_CRAQUELEURS_LEADER
    if type(j) ~= "string" or j == "" then return nil end
    return j
end

local CARTE_HDV_SUFOKIA, PNJ_HDV_SUFOKIA, ZAAP_SUFOKIA = "90707714", 515281, 95422468
local function detourClef()
    if not leaderDoitRentrer() then return nil end
    local c = carte()
    if not leaderSansCle() and not tostring(c):match("^1069") then return nil end
    if c == CARTE_HDV_SUFOKIA then return { { map = c, custom = acheterClefSufokia } } end
    if c == tostring(CARTE_HAVRE_SAC) then return { { map = c, path = "zaap(" .. ZAAP_SUFOKIA .. ")" } } end
    if tostring(c):match("^1069") then
        return { { map = c, custom = function()
            dire("sortie du donjon des Craqueleurs pour rentrer par la clef avec les 8 (salle 1)")
            pcall(function() global:leaveDialog() end)
            pcall(function() developer:sendMessage(developer:createMessage("DungeonQuitRequest")) end)
            attendre(function() return carte() ~= c end, 8000)
        end } }
    end
    local d = tonumber(sur(function() return map:GetPathDistance(tonumber(c), tonumber(CARTE_HDV_SUFOKIA)) end, 99)) or 99
    if d <= 15 then return { { map = c, custom = function() avancerVers(tonumber(CARTE_HDV_SUFOKIA)) end } } end
    return { { map = c, path = "havenbag" } }
end
local function leaderDoitRentrer()
    local j = jetonClef()
    return j ~= nil and lireEtat("CLEF_ENTREE_" .. j) ~= "1"
end
local function acheterClefSufokia()
    fermerInterfaces()
    pcall(function() npc:npc(PNJ_HDV_SUFOKIA, 6) end)
    attendre(occupe, 3000)
    local kamas = tonumber(sur(function() return character:kamas() end, 0)) or 0
    for _ = 1, 3 do
        if nb(CLEF_CRAQ) >= 1 then break end
        pcall(function() sale:buyItem(CLEF_CRAQ, 1, kamas) end)
        attendre(function() return nb(CLEF_CRAQ) >= 1 end, 5000)
    end
    fermerInterfaces()
    if nb(CLEF_CRAQ) >= 1 then
        if jetonClef() ~= nil then ecrireEtat("CLEF_CRAQ_" .. jetonClef(), 1) end
        dire("clef des Craqueleurs achetee a Sufokia -> retour aux Craqueleurs")
        if ETAT_ETAPE ~= nil then ETAT_ETAPE.idx = 8 end
        pcall(function() map:changeMap("havenbag") end)
    else
        alerte("clef des Craqueleurs introuvable a l HDV de Sufokia -> nouvel essai dans 30 s")
        attendre(function() return false end, 30000, 1000)
    end
end

local PONT = { 426, 412, 399, 385, 372, 358, 345, 331, 318, 304, 291 }
local POTION_WABBIT, CARTE_119 = 960, "185862149"
local function detourPotion()
    if ETAT_ETAPE == nil or ETAT_ETAPE.phase == "quete" then return nil end
    if nb(POTION_WABBIT) >= 1 or #ailesManquantes() > 0 then return nil end
    local c = carte()
    if c == CARTE_119 then
        return { { map = c, custom = function()
            dire("pas de Potion Wabbit -> PNJ 119 (4 ailes) pour le remede")
            parler(119, { -1, -1 })
            parler(119, { -1, -1 })
            if nb(POTION_WABBIT) >= 1 then
                dire("Potion Wabbit obtenue -> retour au 134 (trajet aller depuis le debut)")
                if ETAT_ETAPE.phase == "aller" or ETAT_ETAPE.phase == "entree" then ETAT_ETAPE.phase = "aller" ETAT_ETAPE.idx = 1 end
                DERNIERE_ACTION = nil
            else alerte("PNJ 119 : pas de Potion Wabbit apres le dialogue") end
        end } }
    end
    if c == tostring(CARTE_HAVRE_SAC) then return { { map = c, path = "zaap(88213271)" } } end
    local d = tonumber(sur(function() return map:GetPathDistance(tonumber(c), tonumber(CARTE_119)) end, 99)) or 99
    if d <= 15 then return { { map = c, custom = function() avancerVers(tonumber(CARTE_119)) end } } end
    return { { map = c, path = "havenbag" } }
end
local CARTE_1578 = "99091977"
local function traverserLesPieges()
    local ici = "106959872"
    attendre(function() return not enCombat() and not occupe() end, 10000)
    local cle = cleEquipe() .. "PONT_CRAQ"
    local function libre()
        local v = tostring(lireMem(cle) or "")
        local qui, t = v:match("^(%d+):(%d+)$")
        return qui == nil or qui == moiId() or os.time() - (tonumber(t) or 0) > 25
    end
    if not attendre(libre, 60000, 300) then dire("pont : verrou tenu trop longtemps, je passe") end
    if carte() ~= ici then return end
    ecrireMem(cle, moiId() .. ":" .. math.floor(os.time()))
    for _, c in ipairs(PONT) do
        pcall(function() map:moveToCell(c) end)
        attendre(function()
            return carte() ~= ici or tonumber(sur(function() return map:currentCell() end, -1)) == c
        end, 4000, 100)
        if carte() ~= ici then ecrireMem(cle, "") return end
        ecrireMem(cle, moiId() .. ":" .. math.floor(os.time()))
    end
    pcall(function() map:door(251) end)
    attendre(function() return carte() ~= ici end, 4000, 100)
    ecrireMem(cle, "")
end
local function detourAlain()
    if ETAT_ETAPE == nil or ETAT_ETAPE.phase == "quete" then return nil end
    if nb(14464) >= 1 or lireEtat("ALAIN_APRES_CRAQ") == "1" then return nil end
    local c = carte()
    if c == CARTE_1578 then
        return { { map = c, custom = function()
            dire("rattrapage du debut d etape : Alain Deix (1578, 3e passage)")
            parler(1578, { -1, -1, -1 })
            ecrireEtat("ALAIN_APRES_CRAQ", 1)
            if ETAT_ETAPE.phase == "aller" or ETAT_ETAPE.phase == "entree" then ETAT_ETAPE.phase = "aller" ETAT_ETAPE.idx = 1 end
            DERNIERE_ACTION = nil
        end } }
    end
    if c == tostring(CARTE_HAVRE_SAC) then return { { map = c, path = "zaap(68419587)" } } end
    local d = tonumber(sur(function() return map:GetPathDistance(tonumber(c), tonumber(CARTE_1578)) end, 99)) or 99
    if d <= 15 then return { { map = c, custom = function() avancerVers(tonumber(CARTE_1578)) end } } end
    return { { map = c, path = "havenbag" } }
end

local ETAPE = {
    cle    = "craqueleurs_wabbit",
    queteAvecLeader = true,
    nom    = "Ailes, PNJ 119, Craqueleurs, 814, PNJ 134 puis Chateau du Wa Wabbit",
    succes = { 41, 57 },
    acces  = "tp",
    detour = function() return detourClef() or detourAlain() or detourPotion() end,
    trou = { ["106959874"] = true },
    quatreTout = {
        ["106954752"] = true, ["106955776"] = true, ["106956800"] = true,
        ["106954764"] = true, ["106956812"] = true,
    },
    debutQuete = function()
        if lireEtat("CRAQ_119") == "1" then return 8 end
        return 1
    end,
}
ETAPE.quete = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(68419587)" },
    { map = "99091977", custom = function()
        parler(1578, { -1, -1, -1 })
        versCarte(99095051)
    end },
    { map = "99095051", custom = retirerLesAiles, path = "havenbag" },
    { map = "162791424", path = "zaap(191105026)" },
    { map = "191104004", custom = acheterLesAiles },
    { map = "185862149", custom = function()
        if leaderSansCle() then return retournerAcheterLaCle() end
        if lireEtat("CRAQ_119") == "1" then return end
        local ici = carte()
        while not attendre(function() return equipeDeQueteSur(ici) end, ATTENTE_EQUIPE_MS, 200) do
            if enCombat() or carte() ~= ici then return end
            alerte("PNJ 119 : equipe incomplete, j attends ici")
        end
        parler(119, { -1, -1 })
        parler(119, { -1, -1 })
        ecrireEtat("CRAQ_119", 1)
    end, path = "havenbag" },
    { map = "162791424", path = "zaap(88213271)" },
    { map = "-2,0", path = "top" },
    { map = "-2,-1", path = "right" },
    { map = "-1,-1", path = "top" },
    { map = "-1,-2", path = "top" },
    { map = "-1,-3", path = "left" },
    { map = "-2,-3", path = "top" },
    { map = "-2,-4", path = "top" },
    { map = "-2,-5", path = "top" },
    { map = "-2,-6", path = "top" },
    { map = "-2,-7", path = "left" },
    { map = "185861634", custom = function()
        if leaderSansCle() then return retournerAcheterLaCle() end
        local ici = carte()
        local rentree = leaderDoitRentrer()
        local function auComplet()
            for _, a in ipairs(comptesEquipe()) do
                local m = tostring(carteDe(a))
                if m ~= tostring(ici) and (rentree or not m:match("^1069")) then return false end
            end
            return true
        end
        if not attendre(auComplet, ATTENTE_EQUIPE_MS, 200) then
            alerte("entree des Craqueleurs : equipe incomplete -> j attends (personne n entre sans les 8)")
            rejouerCetteEntree()
            return
        end
        local j = jetonClef()
        if j ~= nil and lireEtat("CLEF_ENTREE_" .. j) ~= "1" then
            if nb(CLEF_CRAQ) < 1 then alerte("entree des Craqueleurs : pas de clef en sac") return end
            ecrireEtat("CLEF_ENTREE_" .. j, 1)
            local avant = nb(CLEF_CRAQ)
            parler(772, { -1, -2, -1 }, { changeCarte = 5000 })
            if carte() == tostring(ici) and nb(CLEF_CRAQ) >= avant then
                ecrireEtat("CLEF_ENTREE_" .. j, 0)
                alerte("entree des Craqueleurs par la clef : rien ne s est passe, nouvel essai")
            end
            return
        end
        parler(772, { -1, -1, -1 }, { changeCarte = 5000 })
    end },
    { map = "106954752", fight = true },
    { map = "106955776", fight = true },
    { map = "106956800", fight = true },
    { map = "106954764", fight = true },
    { map = "106956812", fight = true },
    { map = "106957824", fight = true },
    { map = "106957826", fight = true },
    { map = "106957828", fight = true },
    { map = "106958848", fight = true },
    { map = "106959872", custom = traverserLesPieges },
    { map = "106959874", fight = true },
    { map = "106960896", fight = true },
    { map = "106961920", barriere = true, custom = function()
        parler(772, { -1 }, { changeCarte = 5000 })
    end },
    { map = "185861634", path = "havenbag" },
    { map = "162791424", path = "zaap(88213271)" },
    { map = "-2,0", path = "right" },
    { map = "-1,0", path = "right" },
    { map = "0,0", path = "right" },
    { map = "1,0", path = "right" },
    { map = "2,0", path = "right" },
    { map = "3,0", path = "right" },
    { map = "4,0", path = "right" },
    { map = "88082711", custom = function()
        parler(814, { -1, -1 })
        versCarte(68420613)
    end },
}
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(68419587)" },
    { map = "68420613", custom = function()
        parler(134, { -1 }, { changeCarte = 5000 })
    end },
    { map = "99614728", path = "top" },
    { map = "99614727", path = "top" },
    { map = "99614726", path = "top" },
    { map = "99614725", path = "right" },
    { map = "99615237", path = "top" },
    { map = "99615236", path = "right" },
    { map = "99615748", path = "top" },
    { map = "99615747", path = "top" },
    { map = "99615746", door = "240" },
    { map = "116916234", door = "301" },
    { map = "106698240", door = "204" },
    { map = "106693122", door = "249" },
    { map = "106694146", door = "263" },
    { map = "106695170", door = "265" },
    { map = "116919300", path = "414" },
    { map = "99616001", path = "right" },
    { map = "99616513", path = "top" },
    { map = "99616514", path = "left" },
    { map = "99616002", door = "234" },
    { map = "116917252", door = "382" },
    { map = "106693136", door = "268" },
    { map = "106698254", door = "184" },
    { map = "106697230", door = "172" },
    { map = "106696206", door = "351" },
    { map = "116918272", path = "369" },
    { map = "99614980", path = "left" },
    { map = "99746564", path = "bottom" },
    { map = "99746563", path = "right" },
}
ETAPE.entree = {
    carte = "99614979",
    pnj = 1439,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
}
ETAPE.donjon = {
    { map = "116392448", fight = true },
    { map = "116393472", fight = true },
    { map = "116394496", fight = true },
    { map = "116395520", fight = true },
    { map = "116392450", fight = true },
    { map = "116393474", custom = function()
        local ici = carte()
        parler(137, { -2 }, { changeCarte = 5000 })
        if carte() == ici then parler(137, { -1 }, { changeCarte = 5000 }) end
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

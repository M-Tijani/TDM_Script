if DOSSIER == nil then
    pcall(function() DOSSIER = global:getCurrentScriptDirectory() end)
end
if charger == nil then
    function charger(rel, obligatoire)
        local base = DOSSIER or (global and global:getCurrentScriptDirectory()) or "."
        local path = tostring(base) .. "\\" .. tostring(rel)
        local ok, err = pcall(function() dofile(path) end)
        if not ok and obligatoire then
            pcall(function() global:printError("[CHARGER] " .. tostring(rel) .. " : " .. tostring(err)) end)
        end
        return ok
    end
end

FIGHT_KICK = 0
DOSSIER = nil
pcall(function() DOSSIER = global:getCurrentScriptDirectory() end)

if charger ~= CHARGER_ENVELOPPE then
    local base = charger
    CHARGER_ENVELOPPE = function(rel, obligatoire)
        local ok = base(rel, obligatoire)
        local essai = 0
        while not ok and obligatoire and essai < 3 do
            essai = essai + 1
            pcall(function() global:delay(500 * essai) end)
            ok = base(rel, obligatoire)
            if ok then pcall(function() global:printMessage("[RUN] " .. tostring(rel) .. " charge au nouvel essai " .. essai) end) end
        end
        return ok
    end
    charger = CHARGER_ENVELOPPE
end
SONDAGE_MS = 30
MODE_TECHNIQUE = false
XML_LEADER_RUN = "xml\\SACRI CROCA 650 VITA0FORCE.xml"
XML_MULE_RUN = "xml\\sacri-eau.xml"
VARIANTES_MULE = { 12727 }
ATTENTE_EQUIPE_MS = 120000
TP_ATTENTE_MS = 90000
TP_RELANCE_MS = 10000
PASSEUR_EN_AVANCE = true
CARTE_HAVRE_SAC = "162791424"
charger("Settings.lua", false)
charger("lib\\paquets.lua", true)
charger("lib\\larves_donnees.lua", true)
charger("lib\\deblocage.lua", true)
charger("lib\\ia_sacri_koulosse.lua", true)
charger("lib\\ia_sacri_ratnoir.lua", true)
charger("lib\\ia_sacri_royalmouth.lua", true)
charger("lib\\rm_bain_de_sang.lua", true)
charger("lib\\ia_sacri_mansot.lua", true)
charger("lib\\ia_sacri_scara.lua", true)
charger("lib\\ia_sacri_elements.lua", true)
charger("lib\\ia_sacri_tofu.lua", true)
function dire(m) pcall(function() global:printSuccess("[RUN] " .. tostring(m)) end) end
function sur(f, defaut)
    local ok, v = pcall(f)
    if ok and v ~= nil then return v end
    return defaut
end

DC_TOUR, DC_BLOQUE = DC_TOUR or -1, DC_BLOQUE or {}
function alerte(m) pcall(function() global:printError("[RUN] " .. tostring(m)) end) end
function deplacerCombat(c)
    c = tonumber(c)
    if c == nil then return false end
    local tour = tonumber(sur(function() return fightAction:getCurrentTurn() end, 0)) or 0
    if tour ~= DC_TOUR then DC_TOUR, DC_BLOQUE = tour, {} end
    local function case() return tonumber(sur(function() return fightCharacter:getCellId() end, -1)) or -1 end
    local ici = case()
    if c == ici then return true end
    if DC_BLOQUE[ici] then return false end
    pcall(function() fightAction:moveToWardCell(c) end)
    for _ = 1, 50 do if case() ~= ici then break end global:delay(20) end
    if case() == ici then
        DC_BLOQUE[ici] = true
        dire("combat : deplacement vers " .. c .. " impossible depuis " .. ici .. " (tacle ?) -> plus de deplacement ce tour")
        return false
    end
    return case() == c
end

DERNIER_BATTEMENT = DERNIER_BATTEMENT or 0
function estSur(m)
    m = tostring(m)
    if m == carte() then return true end
    return sur(function() return map:onMap(m) end, false) == true
end
function cheminEtat(id) return tostring(DOSSIER) .. "\\etat\\" .. tostring(id) .. ".txt" end
function moiId() return tostring(sur(function() return character:id() end, "0")) end
function parler(pnj, reponses, opts)
    opts = opts or {}
    local avantCarte = carte()
    local avantDlg = dernierDialogue()
    pcall(function() npc:npc(pnj, 3) end)
    attendre(function() return dernierDialogue() ~= avantDlg end, opts.ouverture or 3000)
    if avantDlg ~= nil and dernierDialogue() == avantDlg then
        pcall(function() global:leaveDialog() end)
        return
    end
    for _, r in ipairs(reponses or {}) do
        local avant = signatureRepliques()
        if REPRISE_DONJON then
            local o = optionsDuMenu()
            if o then for k, t in pairs(o) do if t:find("reprendre", 1, true) then r = -k end end end
        end
        pcall(function() npc:reply(r) end)
        attendre(function() return signatureRepliques() ~= avant or carte() ~= avantCarte end, 2500)
        if carte() ~= avantCarte then break end
    end
    if opts.changeCarte then
        attendre(function() return carte() ~= avantCarte end, opts.changeCarte)
    end
    pcall(function() global:leaveDialog() end)
end
function moiNom() return tostring(sur(function() return character:name() end, "?")) end
function signatureRepliques()
    local r = sur(function() return global:getReplies() end, nil)
    if r == nil then return "" end
    local t = {}
    pcall(function() for _, x in ipairs(r) do t[#t + 1] = tostring(x) end end)
    if #t == 0 then pcall(function() for i = 0, r.Count - 1 do t[#t + 1] = tostring(r[i]) end end) end
    return table.concat(t, ",")
end
function battement()
    local t = os.time()
    if t == DERNIER_BATTEMENT then return end
    DERNIER_BATTEMENT = t
    pcall(function()
        local cle = "RS_VU_" .. tostring(global:thisAccountController():getUsername())
        if developer:getInGlobalMemory(cle) ~= nil then developer:editInGlobalMemory(cle, tostring(t))
        else developer:addInGlobalMemory(cle, tostring(t)) end
    end)
end
function enCombat() return sur(function() return character:isInFight() end, false) end
function lireMem(cle) return sur(function() return developer:getInGlobalMemory(cle) end, nil) end
function dernierDialogue()
    local L = sur(function() return global:consoleLines() end, nil)
    if type(L) ~= "table" then return nil end
    for i = #L, 1, -1 do local x = tostring(L[i] or "") if x:find("Dialogue avec le PNJ", 1, true) then return x end end
    return ""
end
function attendre(cond, maxMs, pas)
    pas = pas or SONDAGE_MS
    local t = 0
    while t <= maxMs do
        battement()
        local ok, r = pcall(cond)
        if ok and r then return true end
        global:delay(pas)
        t = t + pas
    end
    return false
end
function ecrireMem(cle, v)
    pcall(function()
        if developer:getInGlobalMemory(cle) ~= nil then developer:editInGlobalMemory(cle, v)
        else developer:addInGlobalMemory(cle, v) end
    end)
end
function carte() return tostring(sur(function() return map:currentMapId() end, "")) end

ETAT = ETAT or nil
function lireTableEtat(id)
    local c = cheminEtat(id)
    return lireFichierEtat(c) or lireFichierEtat(c .. ".tmp") or lireFichierEtat(c .. ".bak") or {}
end
local function lireFichierEtat(chemin)
    local t, n = {}, 0
    local f = io.open(chemin, "r")
    if f == nil then return nil end
    for l in f:lines() do
        local k, v = l:match("^([^=]+)=(.*)$")
        if k then t[k] = v n = n + 1 end
    end
    f:close()
    if n == 0 then return nil end
    return t
end
function ecrireTableEtat(id, t)
    pcall(function() os.execute('mkdir "' .. tostring(DOSSIER) .. '\\etat" 2>nul') end)
    local c = cheminEtat(id)
    local f = io.open(c .. ".tmp", "w")
    if f == nil then alerte("etat non ecrit : " .. c) return false end
    local n = 0
    for kk, vv in pairs(t) do f:write(kk .. "=" .. tostring(vv) .. "\n") n = n + 1 end
    f:close()
    if n == 0 then return false end
    pcall(function() os.remove(c) end)
    local ok = os.rename(c .. ".tmp", c)
    if not ok then
        local g = io.open(c, "w")
        if g ~= nil then for kk, vv in pairs(t) do g:write(kk .. "=" .. tostring(vv) .. "\n") end g:close() end
    end
    local b = io.open(c .. ".bak", "w")
    if b ~= nil then for kk, vv in pairs(t) do b:write(kk .. "=" .. tostring(vv) .. "\n") end b:close() end
    return true
end
ETAT_LU_A = ETAT_LU_A or 0
function estLeader()
    local l = comptesEquipe()
    return sur(function() return l[1]:getUsername() end, "") == sur(function() return global:thisAccountController():getUsername() end, "-")
end
function enGroupe() return sur(function() return global:thisAccountController():isItATeam() end, false) == true end
function chargerEtat()
    ETAT = lireTableEtat(moiId())
    ETAT_LU_A = os.time()
end
function lireEtat(k)
    if ETAT == nil or os.time() - (ETAT_LU_A or 0) >= 2 then
        local t = lireTableEtat(moiId())
        if next(t) ~= nil or ETAT == nil then ETAT = t end
        ETAT_LU_A = os.time()
    end
    return ETAT[k]
end
function ecrireEtatDe(id, k, v)
    if tostring(id) == moiId() then return ecrireEtat(k, v) end
    local t = lireTableEtat(id)
    if next(t) == nil then alerte("etat de " .. tostring(id) .. " illisible : marque " .. tostring(k) .. " NON ecrite (pas d ecrasement)") return end
    t[k] = tostring(v)
    ecrireTableEtat(id, t)
end
function lireEtatDe(id, k)
    if tostring(id) == moiId() then return lireEtat(k) end
    return lireTableEtat(id)[k]
end
function ecrireEtat(k, v)
    local t = lireTableEtat(moiId())
    if next(t) == nil and ETAT ~= nil then for kk, vv in pairs(ETAT) do t[kk] = vv end end
    t[k] = tostring(v)
    ecrireTableEtat(moiId(), t)
    ETAT, ETAT_LU_A = t, os.time()
end
function comptesEquipe()
    local liste = {}
    local moi = global:thisAccountController()
    local enGroupe = sur(function() return moi:isItATeam() end, false)
    if enGroupe then
        local chef = sur(function() return global:leaderAccountController() end, moi)
        local membres = sur(function() return chef:getTeamAccounts() end, nil)
        liste[1] = chef
        local nomChef = sur(function() return chef:getUsername() end, "")
        pcall(function()
            for _, a in ipairs(membres) do
                if sur(function() return a:getUsername() end, "") ~= nomChef then liste[#liste + 1] = a end
            end
        end)
        return liste
    end
    local publie = lireMem("RS_EQUIPE_DE_" .. sur(function() return moi:getUsername() end, ""))
    if publie ~= nil then
        for nom in tostring(publie):gmatch("[^,]+") do
            local a = sur(function() return ankabotController:getAccount(nom) end, nil)
            if a ~= nil then liste[#liste + 1] = a end
        end
    end
    if #liste == 0 then liste[1] = moi end
    return liste
end
function monRang()
    local moi = sur(function() return global:thisAccountController():getUsername() end, "")
    for i, a in ipairs(comptesEquipe()) do
        if sur(function() return a:getUsername() end, "") == moi then return i end
    end
    return 1
end
IDS_CACHE = IDS_CACHE or {}
function mulesEnHavreSac()
    local n = 0
    for i, a in ipairs(comptesEquipe()) do
        if i > 1 and carteDe(a) == CARTE_HAVRE_SAC then n = n + 1 end
    end
    return n
end
function idDe(a)
    local n = tostring(sur(function() return a:getUsername() end, ""))
    local id = tostring(sur(function() return a.character:id() end, "?"))
    if id ~= "?" and id ~= "0" and id ~= "" and id ~= "nil" then
        if n ~= "" then IDS_CACHE[n] = id end
        return id
    end
    if n ~= "" then
        if IDS_CACHE[n] ~= nil then return IDS_CACHE[n] end
        local m = tostring(lireMem("RS_ID_" .. n) or "")
        if m ~= "" then IDS_CACHE[n] = m return m end
    end
    return id
end
function carteDe(a) return tostring(sur(function() return a.map:currentMapId() end, "")) end
function cleEquipe() return "RS_" .. idDe(comptesEquipe()[1]) .. "_" end
function equipeSur(c, saufMoi)
    local moi = moiId()
    for _, a in ipairs(comptesEquipe()) do
        if not (saufMoi and idDe(a) == moi) and carteDe(a) ~= tostring(c) and not (idDe(a) == moi and estSur(c)) then return false end
    end
    return true
end

CATEGORIES_SUCCES = CATEGORIES_SUCCES or { 11, 12, 13, 14, 18, 50 }
SUCCES_VALIDE = SUCCES_VALIDE or {}
SUCCES_PAQUETS = SUCCES_PAQUETS or {}
SUCCES_ANALYSES = SUCCES_ANALYSES or 0
SUCCES_CLOS_DES_BLOPS = 36
function traiterSucces()
    while SUCCES_ANALYSES < #SUCCES_PAQUETS do
        SUCCES_ANALYSES = SUCCES_ANALYSES + 1
        local m = SUCCES_PAQUETS[SUCCES_ANALYSES]
        local ok1, l1 = pcall(function() return analyserPaquetSucces(m, 1) end)
        if not ok1 or (l1 or 0) == 0 then pcall(function() analyserPaquetSucces(m, 0) end) end
    end
end
function surSuccesDetailles(message) if message ~= nil then SUCCES_PAQUETS[#SUCCES_PAQUETS + 1] = message end end
function lireLesSucces()
    enregistrerMessage("AchievementsDetailedEvent", surSuccesDetailles, "succes de donjon")
    envoyerPaquetBrut("ouvrirLePanneauDesSucces", {}, "panneau des succes")
    for _, c in ipairs(CATEGORIES_SUCCES) do
        envoyerPaquetBrut("demanderCategorieDeSucces", { categorie = tostring(c) }, "categorie " .. c)
    end
    local t = 0
    while #SUCCES_PAQUETS < #CATEGORIES_SUCCES and t < 6000 do
        pcall(function() developer:suspendScriptUntil("AchievementsDetailedEvent", "", false, 1500, false, 50) end)
        t = t + 1500
    end
    traiterSucces()
    dire("succes lus : " .. #SUCCES_PAQUETS .. "/" .. #CATEGORIES_SUCCES .. " categories")
    return #SUCCES_PAQUETS > 0
end
function analyserPaquetSucces(message, base)
    local succes = message.Achievements
    local n = longueurCollection(succes)
    local lus = 0
    for i = base, base + n - 1 do
        local s = succes[i]
        if s ~= nil and s.AchievementId ~= nil then
            local obj = s.AchievementObjectives
            local enCours, acheves = 0, 0
            for j = base, base + longueurCollection(obj) - 1 do
                local o = obj[j]
                if o ~= nil then
                    if o.HasCurrentValue == true then enCours = enCours + 1
                    elseif o.HasCurrentValue == false then acheves = acheves + 1 end
                end
            end
            if s.AchievementId == SUCCES_CLOS_DES_BLOPS then SUCCES_VALIDE[s.AchievementId] = (acheves >= 2)
            else SUCCES_VALIDE[s.AchievementId] = (enCours == 0) end
            lus = lus + 1
        end
    end
    return lus
end

ETAPES = {}
charger("etapes\\ordre.lua", true)
for _, f in ipairs(ETAPES_FICHIERS or {}) do charger("etapes\\" .. f, true) end
function etapeValideePour(a, n)
    local id = idDe(a)
    local e = ETAPES[n]
    if e ~= nil and lireEtatDe(id, "FAIT_" .. e.cle) == "1" then return true end
    local v = lireMem(cleEquipe() .. "VAL_" .. id) or lireEtatDe(id, "VAL")
    return v ~= nil and tostring(v):find("," .. n .. ",", 1, true) ~= nil
end
function leaderPasseur(n)
    if not PASSEUR_EN_AVANCE then return false end
    return etapeValideePour(comptesEquipe()[1], n)
end
function effacerMem(cle) pcall(function() developer:deleteFromGlobalMemory(cle) end) end
function deciderEtapeEquipe()
    local equipe = comptesEquipe()
    local attendus = 0
    pcall(function()
        local moiNom = sur(function() return global:thisAccountController():getUsername() end, "")
        for _ in tostring(lireMem("RS_EQUIPE_DE_" .. moiNom) or ""):gmatch("[^,]+") do attendus = attendus + 1 end
    end)
    if attendus > #equipe then
        attendre(function() return #comptesEquipe() >= attendus end, 60000, 1000)
        equipe = comptesEquipe()
        if attendus > #equipe then
            alerte("etape de l equipe NON decidee : " .. #equipe .. "/" .. attendus .. " comptes de l equipe charges (j attends les mules)")
            return etapeEquipe()
        end
    end
    local illisible = function()
        for i, a in ipairs(equipe) do
            local id = tostring(idDe(a) or "?")
            if i > 1 and (id == "?" or id == "0" or id == "" or id == "nil") then return true end
        end
        return false
    end
    if illisible() then
        attendre(function() equipe = comptesEquipe() return not illisible() end, 60000, 1000)
        if illisible() then
            alerte("etape de l equipe NON decidee : un compte de l equipe sans perso lisible (deconnecte ?) -> attente")
            return etapeEquipe()
        end
    end
    if not enGroupe() then
        attendre(function()
            for _, a in ipairs(equipe) do
                if lireMem(cleEquipe() .. "PREM_" .. idDe(a)) == nil then return false end
            end
            return true
        end, 20000, 200)
    end
    local n = #ETAPES + 1
    for k = 1, #ETAPES do
        local toutes = true
        for i, a in ipairs(equipe) do
            if (i > 1 or #equipe == 1) and not etapeValideePour(a, k) then toutes = false break end
        end
        if not toutes then n = k break end
    end
    if #equipe == 1 and estLeader() then
        local avant = etapeEquipe()
        if avant ~= nil then n = avant end
    end
    ecrireMem(cleEquipe() .. "ETAPE", n)
    if estLeader() and #equipe >= 2 and n <= #ETAPES and tostring(lireMem(cleEquipe() .. "FINI") or "") == "1" then
        ecrireMem(cleEquipe() .. "FINI", 0)
        dire("marque FINI d une run precedente remise a 0 (etape d equipe " .. n .. "/" .. #ETAPES .. ")")
    end
    dire("etape de l equipe : " .. n .. (ETAPES[n] and (" (" .. ETAPES[n].nom .. ")") or " (fin)"))
    pcall(function() arretApresRoyalmouth(n) end)
    return n
end
function arretApresRoyalmouth(n)
    local r = nil
    for k, e in ipairs(ETAPES) do if e.cle == "donjons_royalmouth" then r = k end end
    if r == nil or n <= r then return end
    local nb = 0
    pcall(function() nb = #comptesEquipe() end)
    if nb < 2 then return end
    local moi = tostring(sur(function() return global:thisAccountController():getUsername() end, ""))
    if moi == "" then return end
    local liste = ""
    pcall(function()
        local f = io.open(DOSSIER .. "\\etat\\arret-apres-royalmouth.txt", "r")
        if f then liste = f:read("*a") f:close() end
    end)
    if not liste:find(moi, 1, true) then return end
    ecrireMem("PAUSE_SACRI_" .. moi, 1)
    ecrireMem("RS_ARRET_TEST_" .. moi, os.time())
    global:printSuccess("[ARRET-TEST] Royalmouth termine : team de " .. moi .. " ARRETEE pour les tests (etape suivante " .. n .. ")")
    pcall(function() global:finishScript() end)
end
function publierMaProgression()
    local avant = tostring(lireEtat("VAL") or "")
    for n = 1, #ETAPES do
        local e = ETAPES[n]
        if e ~= nil and lireEtat("FAIT_" .. e.cle) ~= "1" then
            if avant:find("," .. n .. ",", 1, true) or etapeValideePourMoi(n) then ecrireEtat("FAIT_" .. e.cle, 1) end
        end
    end
    local premiere = #ETAPES + 1
    for n = 1, #ETAPES do
        if not etapeValideePourMoi(n) then premiere = n break end
    end
    ecrireMem(cleEquipe() .. "PREM_" .. moiId(), premiere)
    local passees = {}
    for n = 1, #ETAPES do if etapeValideePourMoi(n) then passees[#passees + 1] = n end end
    ecrireMem(cleEquipe() .. "VAL_" .. moiId(), "," .. table.concat(passees, ",") .. ",")
    ecrireEtat("VAL", "," .. table.concat(passees, ",") .. ",")
    return premiere
end
function etapeValideePourMoi(n)
    local e = ETAPES[n]
    if e == nil then return true end
    if lireEtat("FAIT_" .. e.cle) == "1" then return true end
    if e.succes ~= nil and #e.succes > 0 then
        for _, id in ipairs(e.succes) do
            if SUCCES_VALIDE[id] ~= true then return false end
        end
        return true
    end
    if e.validee ~= nil then return sur(e.validee, false) end
    return false
end
function etapeEquipe() return tonumber(lireMem(cleEquipe() .. "ETAPE")) end
function queteFaitePourMoi(e)
    if e.quete == nil then return true end
    return lireEtat("QUETE_" .. e.cle) == "1" or etapeValideePourMoi(e.n)
end

PHASES = { "quete", "aller", "entree", "donjon", "apres" }
ETAT_ETAPE = ETAT_ETAPE or { n = nil, phase = nil, idx = 1 }
function tpImpossible(e)
    return e ~= nil and e.n ~= nil and tostring(lireMem(cleEquipe() .. "TP_ECHEC_" .. e.n) or "") == "1"
end
function phaseSuivante(e, phase)
    local i = 0
    for k, p in ipairs(PHASES) do if p == phase then i = k end end
    for k = i + 1, #PHASES do
        local p = PHASES[k]
        if phaseApplicable(e, p) then return p end
    end
    return "fini"
end
function phaseDe(a) return tostring(lireMem(cleEquipe() .. "PHASE_" .. idDe(a)) or "") end
function etapeSansCombat(e)
    if e == nil or (e.donjon ~= nil and #e.donjon > 0) then return false end
    if e.queteAvecLeader then return false end
    for _, x in ipairs(e.quete or {}) do if x.fight or x.forcefight then return false end end
    for _, x in ipairs(e.aller or {}) do if x.fight or x.forcefight then return false end end
    return true
end
function muleAttendTp(e)
    if (not estLeader()) and type(membresDansDonjon) == "function" and sur(function() return membresDansDonjon(e) end, 0) > 0 then return false end
    return (not estLeader()) and (not enGroupe()) and modeTp(e)
end
function changerPhase(p)
    ETAT_ETAPE.phase = p
    ETAT_ETAPE.idx = 1
    local e = ETAPES[ETAT_ETAPE.n or 0]
    if p == "quete" and e ~= nil and type(e.debutQuete) == "function" then
        ETAT_ETAPE.idx = tonumber(sur(e.debutQuete, 1)) or 1
    end
    ecrireMem(cleEquipe() .. "PHASE_" .. moiId(), tostring(ETAT_ETAPE.n) .. ":" .. p)
    dire("etape " .. ETAT_ETAPE.n .. " (" .. tostring(ETAPES[ETAT_ETAPE.n] and ETAPES[ETAT_ETAPE.n].nom) .. ") -> " .. p)
end
function mulesOntFini(n)
    for i, a in ipairs(comptesEquipe()) do
        if i > 1 and phaseDe(a) ~= tostring(n) .. ":fini" then return false end
    end
    return true
end
function modeTp(e)
    return PASSEUR_EN_AVANCE and e.acces == "tp" and e.entree ~= nil and e.entree.pnj ~= nil and not tpImpossible(e)
        and not etapeFaitePourLesMules(e)
end
function prochaineEtapeTp(n)
    for k = n + 1, #ETAPES do
        local x = ETAPES[k]
        if x ~= nil and modeTp(x) and leaderPasseur(k) then return k end
        if x ~= nil and not etapeSansCombat(x) then return nil end
    end
    return nil
end
function phaseApplicable(e, p)
    if p == "quete" then
        if e.quete == nil then return false end
        if enGroupe() then
            for _, a in ipairs(comptesEquipe()) do
                if lireEtatDe(idDe(a), "QUETE_" .. e.cle) ~= "1" and not etapeValideePour(a, e.n) then return true end
            end
            return false
        end
        local queteACombat = e.queteAvecLeader
        for _, x in ipairs(e.quete) do if x.fight or x.forcefight then queteACombat = true end end
        if estLeader() and queteACombat then
            for i, a in ipairs(comptesEquipe()) do
                if i > 1 and lireEtatDe(idDe(a), "QUETE_" .. e.cle) ~= "1" and not etapeValideePour(a, e.n) then return true end
            end
            return false
        end
        return not queteFaitePourMoi(e) and not (estLeader() and leaderPasseur(e.n))
    end
    if p == "aller" then return e.aller ~= nil end
    if p == "entree" then return e.entree ~= nil end
    if p == "donjon" then return e.donjon ~= nil end
    if p == "apres" then return e.apres ~= nil end
    return false
end
function etapeFaitePourLesMules(e)
    if e == nil or e.n == nil then return false end
    for i, a in ipairs(comptesEquipe()) do
        if i > 1 and not etapeValideePour(a, e.n) and phaseDe(a) ~= tostring(e.n) .. ":fini" then return false end
    end
    return true
end

DERNIERE_ACTION = DERNIERE_ACTION or nil
function preparer(e)
    if e.pathFn ~= nil then e.path = e.pathFn() end

    if e.doorFn ~= nil then
        e.door = e.doorFn()
        if e.door ~= nil then e.custom = nil end
    end
    return e
end
SEUIL_ZAAP = SEUIL_ZAAP or 8
HAVRE_IMPOSSIBLE = HAVRE_IMPOSSIBLE or {}
DERNIER_HAVRE = DERNIER_HAVRE or nil
function allerParLeZaap(cm, cible)
    local tid = tonumber(cible)
    if tid == nil then return nil end
    if surIleOtomai(cm) then return nil end
    if cm == CARTE_HAVRE_SAC then
        if tid == tonumber(CARTE_HAVRE_SAC) then return nil end
        ZAAP_PRIS_POUR = ZAAP_PRIS_POUR or {}
        ZAAP_PRIS_POUR[tid] = os.time()
        return { { map = cm, custom = function() sortirParLeZaap(tid) end } }
    end
    if ZAAP_PRIS_POUR ~= nil and ZAAP_PRIS_POUR[tid] ~= nil and os.time() - ZAAP_PRIS_POUR[tid] < 600 then
        return nil
    end
    if DERNIER_HAVRE ~= nil and DERNIER_HAVRE == cm then HAVRE_IMPOSSIBLE[cm] = true end
    if HAVRE_IMPOSSIBLE[cm] then return nil end
    local d = tonumber(sur(function() return map:GetPathDistance(tonumber(cm), tid) end, 0)) or 0
    if d > SEUIL_ZAAP then
        ZAAP_PRIS_POUR = ZAAP_PRIS_POUR or {}
        ZAAP_PRIS_POUR[tid] = os.time()
        DERNIER_HAVRE = cm
        dire("objectif " .. tid .. " a " .. d .. " cartes -> havre-sac puis zaap")
        return { { map = cm, path = "havenbag" } }
    end
    DERNIER_HAVRE = nil
    return nil
end
function avancerVers(cible, y)
    local avant = carte()
    local function pas()
        if y ~= nil then pcall(function() map:moveToward(tonumber(cible), tonumber(y)) end)
        else pcall(function() map:moveToward(tonumber(cible)) end) end
    end
    pas()
    if carte() ~= avant then return true end
    fermerInterfaces()
    attendre(function() return sur(function() return character:isBusy() end, false) ~= true end, 800, 50)
    pas()
    if carte() ~= avant then return true end
    local cellules = sur(function() return map:getWalkableCells() end, nil)
    local liste = {}
    pcall(function() for _, c in pairs(cellules) do local n = tonumber(c) if n then liste[#liste + 1] = n end end end)
    if #liste > 0 then
        local c0 = sur(function() return map:currentCell() end, -1)
        pcall(function() map:moveToCell(liste[math.random(1, #liste)]) end)
        attendre(function() return sur(function() return map:currentCell() end, -1) ~= c0 end, 1200, 50)
        pas()
    end
    return carte() ~= avant
end
function fermerInterfaces()
    pcall(function() exchange:leave() end)
    pcall(function() global:leaveDialog() end)
end
function surIleOtomai(x) x = tonumber(x) or 0 return x > 0 and (x < 1000000 or (x >= 63000000 and x < 64500000)) end
function attendreEnEcoutant(cond, maxMs, noms)
    local t = 0
    while t <= maxMs do
        if sur(cond, false) then return true end
        if noms ~= nil and #noms > 0 then
            for _, nom in ipairs(noms) do
                pcall(function() developer:suspendScriptUntil(nom, "", false, 300, false, 30) end)
                t = t + 300
                if sur(cond, false) then return true end
            end
        else
            global:delay(SONDAGE_MS)
            t = t + SONDAGE_MS
        end
    end
    return false
end
function sortirParLeZaap(cibleId)
    local z = tonumber(sur(function() return map:closestZaapV2(cibleId) end, 0)) or 0
    if z > 0 then
        local avant = carte()
        pcall(function() map:toZaap(z, 3) end)
        if attendre(function() return carte() ~= avant end, 6000) then
            dire("zaap " .. z .. " (le plus proche de " .. cibleId .. ")")
            return
        end
    end
    pcall(function() global:leaveDialog() end)
    alerte("pas de zaap utilisable vers " .. tostring(cibleId) .. " -> zaap d Astrub")
    pcall(function() map:closestZaapV2(191105026) end)
    pcall(function() map:toZaap(191105026, 3) end)
end
function marcher(liste)
    local cm = carte()
    local cleEviter = "RS_EVITER_" .. tostring(sur(function() return global:thisAccountController():getUsername() end, ""))
    local eviter = lireMem(cleEviter)
    if eviter ~= nil and tostring(eviter) ~= "" then
        if tostring(eviter) ~= tostring(cm) then
            effacerMem(cleEviter)
        else
            local cible = nil
            for i = (ETAT_ETAPE.idx or 1), #liste do
                local m = tostring(liste[i].map or "")
                if m:match("^%d+$") and not estSur(m) then cible = m ETAT_ETAPE.idx = i break end
            end
            if cible == nil then
                local e = ETAPES[ETAT_ETAPE.n or 0]
                if e ~= nil and e.entree ~= nil and e.entree.carte ~= nil then cible = tostring(e.entree.carte) end
            end
            if cible ~= nil then
                dire("carte " .. cm .. " a eviter (direction impossible) : autopilote vers " .. cible)
                local az = allerParLeZaap(cm, cible)
                if az ~= nil then return az end
                return { { map = cm, custom = function() avancerVers(cible) end } }
            end
        end
    end
    if global:afterFight() and DERNIERE_ACTION ~= nil and estSur(DERNIERE_ACTION.map) then
        return { preparer(DERNIERE_ACTION) }
    end
    local idx = ETAT_ETAPE.idx

    local pr = liste[idx - 1]
    if pr ~= nil and pr.doorFn ~= nil and pr.map ~= "*" and estSur(pr.map) then
        local plusLoin = false
        for i = idx, #liste do
            if liste[i].map ~= "*" and estSur(liste[i].map) then plusLoin = true break end
        end
        if not plusLoin then
            dire("carte " .. tostring(cm) .. " : porte pas encore passee -> nouvel essai")
            local e = {}
            for k, v in pairs(pr) do e[k] = v end
            e.map = cm
            DERNIERE_ACTION = e
            return { preparer(e) }
        end
    end
    if idx > #liste then return nil end
    local trouve = nil
    local prec = liste[idx - 1]

    if prec ~= nil and prec.map ~= "*" and estSur(prec.map) and (prec.doorFn ~= nil or (prec.custom == nil
        and (prec.door ~= nil or (prec.path ~= nil and not tostring(prec.path):match("^%d+$"))))) then
        for i = idx, #liste do
            if liste[i].map ~= "*" and estSur(liste[i].map) then
                if i > idx then trouve = idx - 1 end
                break
            end
        end
    end
    for i = idx, #liste do
        if trouve ~= nil then break end
        if liste[i].map ~= "*" and estSur(liste[i].map) then trouve = i break end
        if liste[i].barriere then break end
    end
    if trouve == nil then
        for i = idx - 2, 1, -1 do
            if liste[i].map ~= "*" and estSur(liste[i].map) then trouve = i break end
        end
    end
    if trouve ~= nil then
        local x = liste[trouve]
        if x.path == nil and x.door == nil and x.custom == nil and x.fight == nil
            and x.forcefight == nil and x.gather == nil and x.pathFn == nil and x.doorFn == nil then
            ETAT_ETAPE.idx = trouve + 1
            if ETAT_ETAPE.idx > #liste then return nil end
            return { { map = cm, custom = function() end } }
        end
    end
    if trouve ~= nil then
        ETAT_ETAPE.idx = trouve + 1
        local e = {}
        for k, v in pairs(liste[trouve]) do e[k] = v end
        if ETAT_ETAPE.phase == "quete" and trouve == #liste then e.finQuete = ETAT_ETAPE.n end
        e.map = cm
        DERNIERE_ACTION = e
        return { preparer(e) }
    end
    if idx > #liste then return nil end
    if liste[idx].map == "*" then
        local e = {}
        for k, v in pairs(liste[idx]) do e[k] = v end
        e.map = cm
        ETAT_ETAPE.idx = idx + 1
        DERNIERE_ACTION = e
        return { preparer(e) }
    end
    if surIleOtomai(cm) and ETAT_ETAPE.phase ~= "quete" then
        for i = #liste, 1, -1 do
            if liste[i].map ~= "*" and surIleOtomai(liste[i].map) then
                local cibleIle = tostring(liste[i].map)
                ETAT_ETAPE.idx = i
                return { { map = cm, custom = function() avancerVers(cibleIle) end } }
            end
        end
    end
    local cible = tostring(liste[idx].map)
    if cible == tostring(CARTE_HAVRE_SAC) then return { { map = cm, path = "havenbag" } } end
    local actionZaap = allerParLeZaap(cm, cible)
    if actionZaap ~= nil then return actionZaap end
    return { { map = cm, custom = function()
        dire("carte " .. tostring(cm) .. " hors trajet (etape " .. tostring(ETAT_ETAPE.n) .. ", pas " .. tostring(idx) .. ") -> vers " .. tostring(cible))
        local x, y = cible:match("^(%-?%d+),(%-?%d+)$")
        if x ~= nil then avancerVers(x, y)
        else avancerVers(cible) end
    end } }
end

NOMS_INVITATION = PAQUETS_INVITATION or { "PartyInvitationEvent" }
INVIT_ECOUTE, INVIT_ACCEPTEE = INVIT_ECOUTE or false, INVIT_ACCEPTEE or false
function ecouterInvitations()
    if INVIT_ECOUTE then return end
    INVIT_ECOUTE = true
    local function surInvitation(m)
        local id = champPaquet(m, nomsDeChamp({ "frkg", "PartyId", "fptn", "partyId", "party_id" }, "partyId"))
        local de = champPaquet(m, nomsDeChamp({ "frke", "fromId", "inviterId", "fromName", "inviterName" }, "fromId"))
        if id ~= nil and de ~= nil then
            local chef = deuxGroupes() and chefDuCote(coteDeRang(monRang())) or comptesEquipe()[1]
            local idChef = idDe(chef)
            local nomChef = sur(function() return chef.character:name() end, "")
            local chefCote = sur(function() return chefDuCote(coteDeRang(monRang())) end, nil)
            local okCote = false
            if chefCote ~= nil then
                local idC = idDe(chefCote)
                local nomC = sur(function() return chefCote.character:name() end, "")
                okCote = (tostring(de) == idC or tostring(de) == nomC)
            end
            if tostring(de) ~= idChef and tostring(de) ~= nomChef and not okCote then
                dire("invitation de " .. tostring(de) .. " refusee : mon chef est " .. tostring(nomChef))
                id = nil
            end
        end
        if id ~= nil then
            envoyerPaquetBrut("accepterInvitation", { partyId = tostring(id) }, "acceptation du groupe")
            INVIT_ACCEPTEE = true
            INVIT_ACCEPTEE_T = tonumber((tostring(os.time()):gsub(",", "."))) or 0
            AUTOPRET_FAIT = false
            ecrireMem(cleEquipe() .. "AUTOPRET_" .. moiId(), "")
            ecouterGroupe()
        end
    end
    for _, nom in ipairs(NOMS_INVITATION) do enregistrerMessage(nom, surInvitation, "invitation de groupe") end
end
PAQUETS_PARTY_ID = nomsDePaquets({ "PartyRestrictedEvent", "PartyJoinEvent", "PartyNewMemberEvent" },
                                 (PAQUETS_RECEPTION and PAQUETS_RECEPTION.partyId) or {}, { "ilz", "imp" })
ID_GROUPE = nil
function surIdGroupe(m)
    local id = tonumber((champPaquet(m, nomsDeChamp({ "PartyId", "partyId", "party_id", "fqig", "fqdk", "frkg", "frii", "frlw", "frjy" }, "partyId"))))
    if id ~= nil and id > 0 then
        ID_GROUPE = id
        ecrireMem("RS_PARTY_" .. moiId(), tostring(id))
    end
end
GROUPE_ECOUTE = GROUPE_ECOUTE or false
function quitterMonGroupe()
    ecouterGroupe()
    ID_GROUPE = tonumber(lireMem("RS_PARTY_" .. moiId()))
    if ID_GROUPE == nil then
        envoyerPaquetBrut("demanderIdentifiantGroupe", {}, "identifiant de groupe")
        attendreEnEcoutant(function() return ID_GROUPE ~= nil end, 3000, PAQUETS_PARTY_ID)
    end
    if ID_GROUPE == nil then return false end
    envoyerPaquetBrut("quitterLeGroupe", { partyId = tostring(ID_GROUPE) }, "sortie du groupe")
    dire("groupe en jeu " .. ID_GROUPE .. " quitte (purge des membres fantomes)")
    ID_GROUPE = nil
    ecrireMem("RS_PARTY_" .. moiId(), "")
    return true
end
function inviterLesMules()
    for i, a in ipairs(comptesEquipe()) do
        local nom = sur(function() return a.character:name() end, nil)
        if i > 1 and nom ~= nil then pcall(function() global:invitePlayerByName(nom) end) end
    end
end
function ecouterGroupe()
    if GROUPE_ECOUTE then return end
    GROUPE_ECOUTE = true
    for _, nom in ipairs(PAQUETS_PARTY_ID) do enregistrerMessage(nom, surIdGroupe, "identifiant de groupe") end
end
function demanderMonGroupe()
    if monGroupe() ~= nil or os.time() - (ID_DEMANDE or 0) < 10 then return end
    ID_DEMANDE = os.time()
    ecouterGroupe()
    ID_GROUPE = nil
    envoyerPaquetBrut("demanderIdentifiantGroupe", {}, "identifiant de groupe")
    attendreEnEcoutant(function() return ID_GROUPE ~= nil end, 3000, PAQUETS_PARTY_ID)
end

DEBUT_SESSION = DEBUT_SESSION or os.time()
function grouperEnJeu()
    if enGroupe() then return end
    quitterMonGroupe()
    if estLeader() then
        attendre(function()
            for i, a in ipairs(comptesEquipe()) do
                if i > 1 and (tonumber(lireMem(cleEquipe() .. "PRET_" .. idDe(a))) or 0) < DEBUT_SESSION - 5 then return false end
            end
            return true
        end, 30000, 200)
        for i, a in ipairs(comptesEquipe()) do
            local nom = sur(function() return a.character:name() end, nil)
            if i > 1 and nom ~= nil then pcall(function() global:invitePlayerByName(nom) end) end
        end
        dire("groupe en jeu : invitations envoyees")
        ecouterGroupe()
        attendreEnEcoutant(function() return ID_GROUPE ~= nil end, 3000, PAQUETS_PARTY_ID)
    else
        ecouterInvitations()
        ecrireMem(cleEquipe() .. "PRET_" .. moiId(), os.time())
        if attendreEnEcoutant(function() return INVIT_ACCEPTEE end, 40000, NOMS_INVITATION) then
            dire("invitation du leader acceptee")
        else
            alerte("pas d invitation du leader recue")
        end
    end
end
TP_ECOUTE = TP_ECOUTE or false
function ecouterTeleport()
    if TP_ECOUTE then return end
    TP_ECOUTE = true
    enregistrerMessage("TeleportToBuddyOfferEvent", function()
        envoyerPaquetJson("TeleportToBuddyAnswerRequest", '{"Accept":true}', "acceptation du teleport")
    end, "offre de teleport")
    for _, nom in ipairs((PAQUETS_RECEPTION and PAQUETS_RECEPTION.offreTeleport) or {}) do
        enregistrerMessage(nom, function()
            envoyerPaquetJson("TeleportToBuddyAnswerRequest", '{"Accept":true}', "acceptation du teleport")
        end, "offre de teleport (forme du jour)")
    end
end
REPONSES_TELEPORT_GROUPE = { 38239, 11172 }
function texteReponse(id)
    local t = nil
    pcall(function() t = d2data:text(tonumber(id)) end)
    return tostring(t or "")
end
function demanderTeleport(e)
    local rep = e.entree.reponsesTp or {}
    pcall(function() npc:npc(e.entree.pnj, 3) end)
    attendre(function() return signatureRepliques() ~= "" end, 3000)
    local trouve = false
    local essaisRep = 0
    for _ = 1, 20 do
        local brut = signatureRepliques()
        if brut == "" then break end
        local sig = "," .. brut .. ","
        local choix = nil
        for _, id in ipairs(REPONSES_TELEPORT_GROUPE) do
            if sig:find("," .. id .. ",", 1, true) then choix = id end
        end
        if choix ~= nil then
            trouve = true
            pcall(function() npc:reply(choix) end)
            break
        end
        local nbRep = 0
        for _ in brut:gmatch("[^,]+") do nbRep = nbRep + 1 end
        if nbRep <= 1 then
            choix = -1
        else
            local ids = {}
            for x in brut:gmatch("[^,]+") do ids[#ids + 1] = x end
            local apres = nil
            for i, x in ipairs(ids) do if x == "8359" then apres = i end end
            if apres == nil then for i, x in ipairs(ids) do if x == "8358" then apres = i end end end
            local parTexte, vus = reponseParTexte(ids, "porter les membres")
            dire("teleportation : reponses du gardien -> " .. tostring(vus))
            local opts = optionsDuMenu()
            local posTp = nil
            if opts then for k, t in pairs(opts) do if t:find("porter les membres", 1, true) then posTp = k end end end
            if parTexte == nil and opts ~= nil and posTp == nil then
                local av = nil
                for k, t in pairs(opts) do if t:find("entrer", 1, true) or t:find("pr", 1, true) == 1 then av = k end end
                choix = -(av or nbRep)
                pcall(function() npc:reply(choix) end)
                attendre(function() return signatureRepliques() ~= brut end, 2500)
                goto suite_tp
            end
            if posTp ~= nil then choix = -posTp
            elseif parTexte ~= nil then choix = parTexte
            elseif e.entree.positionTp ~= nil then choix = -e.entree.positionTp
            elseif apres ~= nil and ids[apres + 1] ~= nil then choix = tonumber(ids[apres + 1]) or -(apres + 1)
            else choix = -nbRep end
            trouve = true
            pcall(function() npc:reply(choix) end)
            break
        end
        pcall(function() npc:reply(choix) end)
        attendre(function() return signatureRepliques() ~= brut end, 1500)
        ::suite_tp::
    end
    if not trouve then alerte("option « Teleporter les membres du groupe » non trouvee chez le PNJ " .. tostring(e.entree.pnj)) end
    envoyerPaquetBrut("confirmerTeleportationDesMembres", {}, "teleportation des membres")
    pcall(function() global:leaveDialog() end)
end
function reponseParTexte(ids, motif)
    local vus = {}
    for _, x in ipairs(ids) do
        local t = texteReponse(x)
        vus[#vus + 1] = x .. "=" .. t
        local n = string.lower(t)
        if n:find(motif, 1, true) then return tonumber(x), table.concat(vus, " | ") end
    end
    return nil, table.concat(vus, " | ")
end
function optionsDuMenu()
    local L = sur(function() return global:consoleLines() end, nil)
    if type(L) ~= "table" then return nil end
    local opts, vu = {}, false
    for i = #L, math.max(1, #L - 25), -1 do
        local l = tostring(L[i] or "")
        local n, txt = l:match("%s%s+%[(%d+)%]%s+(.+)$")
        if n then opts[tonumber(n)] = string.lower(txt) vu = true
        elseif vu then break end
    end
    if not vu then return nil end
    return opts
end

IDS_COOLDOWN_TP = { [318] = true }
TP_REPRISE = TP_REPRISE or 0
INFOS_ECOUTE = INFOS_ECOUTE or false
function ecouterInfos()
    if INFOS_ECOUTE then return end
    INFOS_ECOUTE = true
    for _, nom in ipairs(PAQUETS_INFO_TEXTE or { "TextInformationEvent" }) do enregistrerMessage(nom, surInfoTexte, "messages serveur") end
end
function surInfoTexte(m)
    local id = tonumber((champPaquet(m, { "MessageId", "gctg", "gcqv" })))
    if id ~= nil and IDS_COOLDOWN_TP[id] then
        local minutes = tonumber(premierParam(m)) or 1
        TP_REPRISE = os.time() + minutes * 60 + 2
        alerte("message " .. id .. " : point de rencontre indisponible " .. minutes .. " min -> attente")
    end
end
function premierParam(m)
    local p = champPaquet(m, { "Parameters", "gcti", "gcqx" })
    if p == nil then return nil end
    local v = nil
    pcall(function() v = p[0] end)
    if v == nil then pcall(function() v = p[1] end) end
    return v
end

CAPTURE_CARTES = { ["96995841"] = true, ["96996865"] = true, ["96994821"] = true, ["96995845"] = true }
CAPTURE_NOMS = { "StatedElementUpdatedEvent", "InteractiveElementUpdatedEvent", "InteractiveUsedEvent", "MapMovementEvent" }
function teleporterLesMules(e)
    dire("passeur : attente des mules en havre-sac")
    ecouterInfos()
    pcall(ecouterLeviers)
    ecouterGroupe()
    local nbMules = #comptesEquipe() - 1
    attendre(function()
        local n = 0
        for i, a in ipairs(comptesEquipe()) do
            if i > 1 and (carteDe(a) == CARTE_HAVRE_SAC or carteDe(a) == carte()) then n = n + 1 end
        end
        return n >= nbMules
    end, ATTENTE_EQUIPE_MS, 200)
    local hors = mulesHorsGroupe()
    local tour = 0
    while #hors > 0 and tour < 6 do
        tour = tour + 1
        dire(#hors .. " mule(s) hors du groupe en jeu -> invitation (" .. tour .. ")")
        for _, a in ipairs(hors) do
            local nom = sur(function() return a.character:name() end, nil)
            if nom ~= nil then pcall(function() global:invitePlayerByName(nom) end) end
        end
        attendreEnEcoutant(function() return #mulesHorsGroupe() == 0 end, 5000, PAQUETS_PARTY_ID)
        hors = mulesHorsGroupe()
    end
    local debut, derniere = os.time(), -999
    local essais, avantTp = 0, mulesEnHavreSac()
    while os.time() - debut < 300 and mulesEnHavreSac() > 0 do
        if essais >= 2 and mulesEnHavreSac() >= avantTp and os.time() >= TP_REPRISE then
            ecrireMem(cleEquipe() .. "TP_ECHEC_" .. tostring(e.n), "1")
            alerte("teleportation impossible pour l etape " .. tostring(e.n) .. " -> les mules viennent par le trajet normal")
            return
        end
        if os.time() < TP_REPRISE then
            attendreEnEcoutant(function() return os.time() >= TP_REPRISE end, (TP_REPRISE - os.time() + 1) * 1000, PAQUETS_INFO_TEXTE)
        elseif os.time() - derniere >= 12 then
            derniere = os.time()
            essais = essais + 1
            demanderTeleport(e)
            attendreEnEcoutant(function() return mulesEnHavreSac() == 0 or os.time() < TP_REPRISE end, 4000, PAQUETS_INFO_TEXTE)
        else
            attendre(function() return mulesEnHavreSac() == 0 end, 1000, 200)
        end
    end
    if mulesEnHavreSac() > 0 then alerte(mulesEnHavreSac() .. " mule(s) encore en havre-sac apres 5 min") end
end
function captureEcrire(nom, msg)
    local c = tostring(sur(function() return map:currentMapId() end, ""))
    if not CAPTURE_CARTES[c] then return end
    pcall(function()
        local js = tostring(sur(function() return developer:toJson(msg) end, ""))
        local cell = tostring(sur(function() return map:currentCell() end, "?"))
        local moi = tostring(sur(function() return character:name() end, "?"))
        local f = io.open(DOSSIER .. "\\etat\\capture-leviers\\lua-" .. moi .. ".log", "a")
        if f then
            f:write(os.date("%H:%M:%S") .. " clk=" .. string.format("%.3f", os.clock()) .. " carte=" .. c .. " cell=" .. cell
                .. " " .. nom .. " " .. js .. "\n")
            f:close()
        end
    end)
end
function mulesHorsGroupe()
    local ref = groupeDeReference()
    local hors = {}
    for i, a in ipairs(comptesEquipe()) do
        if i > 1 and carteDe(a) == CARTE_HAVRE_SAC then
            local g = tonumber(lireMem("RS_PARTY_" .. idDe(a)))
            if ref == nil or g ~= ref then hors[#hors + 1] = a end
        end
    end
    return hors, ref
end
function entrerDansLeDonjon(e)
    local avant = carte()
    pcall(function() npc:npc(e.entree.pnj, 3) end)
    attendre(function() return signatureRepliques() ~= "" end, 3000)
    local menuFait = false
    TROUSSEAU_TENTE = false
    local vus = {}
    for _ = 1, 20 do
        local brut = signatureRepliques()
        if brut == "" or carte() ~= avant then break end
        if vus[brut] then
            pcall(function() global:leaveDialog() end)
            alerte("entree " .. tostring(e.cle) .. " : le gardien " .. tostring(e.entree.pnj) .. " ne propose ni clef ni trousseau -> CLEF MANQUANTE")
            ecrireMem("RS_CLEF_MANQUANTE_" .. moiId(), tostring(e.cle))
            if TROUSSEAU_TENTE then ecrireMem("RS_SANS_TROUSSEAU_" .. moiId() .. "_" .. tostring(e.cle), "1") end
            attendre(function() return false end, 60000, 1000)
            return
        end
        vus[brut] = true
        local sig = "," .. brut .. ","
        local nbRep = 0
        for _ in brut:gmatch("[^,]+") do nbRep = nbRep + 1 end
        local choix
        local opts = optionsDuMenu()
        local posCle, posTrousseau = nil, nil
        if opts then
            for k, t in pairs(opts) do
                if t:find("trousseau", 1, true) then posTrousseau = k
                elseif t:find("donner la cl", 1, true) or t:find("utiliser la cl", 1, true) then posCle = k end
            end
        end
        local posReprise = nil
        if REPRISE_DONJON and opts then for k, t in pairs(opts) do if t:find("reprendre", 1, true) then posReprise = k end end end
        local sansTrousseau = tostring(lireMem("RS_SANS_TROUSSEAU_" .. moiId() .. "_" .. tostring(e.cle)) or "") == "1"
        if posReprise then choix = -posReprise; menuFait = true
        elseif sansTrousseau and sig:find(",8358,", 1, true) then choix = 8358; menuFait = true
        elseif sansTrousseau and posCle then choix = -posCle; menuFait = true
        elseif sig:find(",8359,", 1, true) then choix = 8359; menuFait = true; TROUSSEAU_TENTE = true
        elseif sig:find(",8358,", 1, true) then choix = 8358; menuFait = true
        elseif posTrousseau then choix = -posTrousseau; menuFait = true; TROUSSEAU_TENTE = true
        elseif posCle then choix = -posCle; menuFait = true
        elseif nbRep <= 1 then choix = -1
        elseif not menuFait and nbRep >= 3 then choix = -2; menuFait = true
        else choix = -1; menuFait = true end
        pcall(function() npc:reply(choix) end)
        attendre(function() return signatureRepliques() ~= brut or carte() ~= avant end, 2500)
    end
    attendre(function() return carte() ~= avant end, 5000)
    pcall(function() global:leaveDialog() end)
end
function ecouterLeviers()
    if LEVIERS_ECOUTE then return end
    LEVIERS_ECOUTE = true
    for _, nom in ipairs(CAPTURE_NOMS) do
        local n = nom
        pcall(function() developer:registerMessage(n, function(msg) captureEcrire(n, msg) end) end)
    end
end
function groupeDeReference()
    if deuxGroupes() then
        return tonumber(lireMem("RS_PARTY_" .. idDe(chefDuCote(coteDeRang(monRang())))))
    end
    return tonumber(lireMem("RS_PARTY_" .. moiId()))
end

REPRISE_DONJON = REPRISE_DONJON or false
function finirEtape(e)
    if enGroupe() then
        if estLeader() then
            for _, a in ipairs(comptesEquipe()) do
                ecrireEtatDe(idDe(a), "FAIT_" .. e.cle, 1)
                if e.quete ~= nil then ecrireEtatDe(idDe(a), "QUETE_" .. e.cle, 1) end
            end
            dire("etape " .. e.n .. " (" .. e.nom .. ") terminee")
            deciderEtapeEquipe()
        end
        return
    end
    ecrireEtat("FAIT_" .. e.cle, 1)
    if e.quete ~= nil then ecrireEtat("QUETE_" .. e.cle, 1) end
    publierMaProgression()
    if estLeader() and PASSEUR_EN_AVANCE and AVANCE_LEADER ~= false and e.leaderAttendSuivante
       and not mulesOntFini(e.n) and ETAPES[e.n + 1] ~= nil and ETAPES[e.n + 1].entree ~= nil then
        local m = e.n + 1
        ecrireMem(cleEquipe() .. "AVANCE", e.n .. ":" .. m .. ":1")
        dire("avance : etape " .. e.n .. " jouee par les mules seules -> j attends a l entree de l etape " .. m .. " (" .. ETAPES[m].nom .. ")")
        return
    end
    if estLeader() and PASSEUR_EN_AVANCE and AVANCE_LEADER ~= false and etapeSansCombat(e) and not mulesOntFini(e.n) then
        local m = prochaineEtapeTp(e.n)
        if m ~= nil then
            ecrireMem(cleEquipe() .. "AVANCE", e.n .. ":" .. m .. ":1")
            dire("avance : etape " .. e.n .. " sans combat pour moi -> je pars au gardien de l etape " .. m .. " (" .. ETAPES[m].nom .. ")")
            return
        end
    end
    if estLeader() then
        attendre(function() return mulesOntFini(e.n) end, ATTENTE_EQUIPE_MS, 200)
        deciderEtapeEquipe()
    else
        attendre(function() return etapeEquipe() ~= e.n end, ATTENTE_EQUIPE_MS * 3, 200)
    end
end
function membresDansDonjon(e)
    if type(e.donjon) ~= "table" then return 0 end
    local cartesDj = {}
    local nDj = #e.donjon
    for i, x in ipairs(e.donjon) do
        if x.map and not (i == nDj and not x.fight) then cartesDj[tostring(x.map)] = true end
    end
    local n = 0
    for _, a in ipairs(comptesEquipe()) do
        if tostring(idDe(a)) ~= tostring(moiId()) and cartesDj[tostring(carteDe(a))] then n = n + 1 end
    end
    return n
end
function phaseEntree(e)
    local c = tostring(e.entree.carte)
    if not estSur(c) then
        if muleAttendTp(e) then
            if carte() ~= CARTE_HAVRE_SAC then return { { map = carte(), path = "havenbag" } } end
            return { { map = carte(), custom = function()
                ecouterTeleport()
                local chefId = idDe(comptesEquipe()[1])
                local gChef, gMoi = tonumber(lireMem("RS_PARTY_" .. chefId)), tonumber(lireMem("RS_PARTY_" .. moiId()))
                if not INVIT_ACCEPTEE or (gChef ~= nil and gMoi ~= gChef) then quitterMonGroupe(); INVIT_ACCEPTEE = false end
                ecouterInvitations()
                local noms = { "TeleportToBuddyOfferEvent" }
                for _, nom in ipairs(NOMS_INVITATION) do noms[#noms + 1] = nom end
                for _, nom in ipairs((PAQUETS_RECEPTION and PAQUETS_RECEPTION.offreTeleport) or {}) do noms[#noms + 1] = nom end
                attendreEnEcoutant(function() return carte() ~= CARTE_HAVRE_SAC or tpImpossible(e) end, ATTENTE_EQUIPE_MS, noms)
            end } }
        end
        return marcher(e.aller or { { map = c } })
    end
    if not enGroupe() then
        return { { map = carte(), custom = function()
            if rejoindreDonjonEnCours(e) then return end
            local vSolo = tostring(lireMem(cleEquipe() .. "ENTREE_SOLO") or "")
            local nSolo, tSolo = vSolo:match("^(%d+)[^:]*:(%d+)")
            local soloLance = donjonSolo(e) and tonumber(nSolo) == tonumber(e.n) and os.time() - (tonumber(tSolo) or 0) < 900
            if estLeader() and not soloLance and donjonSolo(e) and type(e.donjon) == "table" then
                local cartesDj = {}
                for _, x in ipairs(e.donjon) do if x.map then cartesDj[tostring(x.map)] = true end end
                local dedans = 0
                for i, a in ipairs(comptesEquipe()) do if i > 1 and cartesDj[tostring(carteDe(a))] then dedans = dedans + 1 end end
                if dedans > 0 then
                    ecrireMem(cleEquipe() .. "ENTREE_SOLO", e.n .. ":" .. math.floor(os.time()))
                    soloLance = true
                    dire("entree " .. e.n .. " : " .. dedans .. " mule(s) deja dans le donjon -> feu vert renouvele, j entre")
                end
            end
            if estLeader() and soloLance then dire("entree solo deja lancee pour l etape " .. e.n .. " -> j entre aussi") end
            if estLeader() and not soloLance then
                if modeTp(e) then
                    for serie = 1, 3 do
                        teleporterLesMules(e)
                        if mulesEnHavreSac() == 0 or tpImpossible(e) then break end
                        alerte("TP partiel (" .. mulesEnHavreSac() .. " mule(s) au havre-sac) -> nouvelle serie " .. (serie + 1))
                    end
                end
                if not attendre(function() return equipeSur(carte()) end, ATTENTE_EQUIPE_MS, 100) then
                    local absents = {}
                    for i, a in ipairs(comptesEquipe()) do
                        if i > 1 and carteDe(a) ~= carte() then absents[#absents + 1] = sur(function() return a.character:name() end, "?") .. "@" .. carteDe(a) end
                    end
                    alerte("entree " .. e.n .. " : j attends encore " .. table.concat(absents, ", ") .. " -> PAS d entree")
                    return
                end
                if donjonSolo(e) then
                    ecrireMem(cleEquipe() .. "ENTREE_SOLO", e.n .. ":" .. math.floor(os.time()))
                    dire("devant le donjon, les 8 reunis -> entree en SOLO (donjon a trous/passages)")
                else
                    ecrireMem(cleEquipe() .. "DEMANDE", "equipe:" .. e.n)
                    dire("devant le donjon, les 8 reunis -> regroupement demande au controller")
                end
            end
            if donjonSolo(e) then
                local function feuVert()
                    local v = tostring(lireMem(cleEquipe() .. "ENTREE_SOLO") or "")
                    local n, t = v:match("^(%d+)[^:]*:(%d+)")
                    return tonumber(n) == tonumber(e.n) and os.time() - (tonumber(t) or 0) < 900
                        and etapeEquipe() == e.n
                end
                dire("entree solo : attente du feu vert (" .. tostring(lireMem(cleEquipe() .. "ENTREE_SOLO")) .. ")")
                attendre(function() return feuVert() or etapeEquipe() ~= e.n end, 120000, 300)
                if etapeEquipe() ~= e.n then ETAT_ETAPE.n = nil return end
                if not feuVert() then alerte("entree solo : pas de feu vert") return end
                dire("entree solo : feu vert -> dialogue " .. tostring(e.entree.pnj))
                if not estLeader() then autoPretAJour() end
                local avant = carte()
                if e.entree.custom ~= nil then e.entree.custom() else entrerDansLeDonjon(e) end
                if carte() ~= avant then changerPhase(phaseSuivante(e, "entree")) end
                return
            end
            attendre(function() return etapeEquipe() ~= e.n end, ATTENTE_EQUIPE_MS * 5, 500)
        end } }
    end
    return { { map = carte(), custom = function()
        if rejoindreDonjonEnCours(e) then return end
        if estLeader() and modeTp(e) and not enGroupe() then teleporterLesMules(e) end
        if not attendre(function() return equipeSur(carte()) end, ATTENTE_EQUIPE_MS, 100) then
            alerte("entree " .. e.n .. " : equipe incomplete -> PAS d entree")
            return
        end
        if e.entree.custom ~= nil then e.entree.custom() else entrerDansLeDonjon(e) end
        changerPhase(phaseSuivante(e, "entree"))
    end } }
end
function rejoindreDonjonEnCours(e)
    local n = membresDansDonjon(e)
    if n == 0 then return false end
    dire("entree " .. e.n .. " : " .. n .. " membre(s) de l equipe deja dans le donjon -> je rentre (reprise du donjon)")
    local avant = carte()
    local premiere = (e.donjon and e.donjon[1] and e.donjon[1].map) and tostring(e.donjon[1].map) or nil
    local tousEnSalle1 = premiere ~= nil
    local cartesDj = {}
    local nDj2 = #(e.donjon or {})
    for i, x in ipairs(e.donjon or {}) do
        if x.map and not (i == nDj2 and not x.fight) then cartesDj[tostring(x.map)] = true end
    end
    for _, a in ipairs(comptesEquipe()) do
        local c = tostring(carteDe(a))
        if tostring(idDe(a)) ~= tostring(moiId()) and cartesDj[c] and c ~= premiere then tousEnSalle1 = false end
    end
    REPRISE_DONJON = not tousEnSalle1
    if tousEnSalle1 then dire("entree " .. e.n .. " : equipe en salle 1 -> entree normale (pas de reprise)") end
    pcall(function() if e.entree.custom ~= nil then e.entree.custom() else entrerDansLeDonjon(e) end end)
    REPRISE_DONJON = false
    if carte() ~= avant then changerPhase(phaseSuivante(e, "entree")) end
    return true
end

SEUIL_PODS = SEUIL_PODS or 85
GIDS_A_GARDER = GIDS_A_GARDER or { 10207, 7423, 7425, 996, 15990, 8343, 7927, 12073, 8151, 6965 }
CARTE_BANQUE_ASTRUB = "192415750"
BUILD_LEADER = {
    { gid = 8262,  pos = 0,  nom = "La Meulette" },
    { gid = 16169, pos = 1,  nom = "Vieille Branche du Chene Mou" },
    { gid = 8263,  pos = 2,  nom = "Anneau du Meulou" },
    { gid = 13851, pos = 3,  nom = "Ceinture du Frelon Noir" },
    { gid = 8470,  pos = 4,  nom = "Anneau du Chene Mou" },
    { gid = 8471,  pos = 5,  nom = "Tongues du dimanche du Chene Mou" },
    { gid = 8847,  pos = 6,  nom = "Casque du Guerrier Zoth" },
    { gid = 8265,  pos = 7,  nom = "Cape du Meulou" },
    { gid = 33044, pos = 8,  nom = "Dragodinde Ivoire et Pourpre (niv 200)" },
    { gid = 737,   pos = 9,  nom = "Dofus Emeraude" },
    { gid = 694,   pos = 10, nom = "Dofus Pourpre" },
    { gid = 17078, pos = 11, nom = "Dokoko" },
    { gid = 12724, pos = 12, nom = "Furibond majeur" },
    { gid = 13759, pos = 13, nom = "Forcene majeur" },
    { gid = 13829, pos = 14, nom = "Turbulent" },
    { gid = 18686, pos = 15, nom = "Bouclier Ventaille" },
}
BUILD_MULE_RUN = {
    { gid = 8465,  pos = 0,  nom = "Torque Ancestral" },
    { gid = 250,   pos = 1,  nom = "Ares" },
    { gid = 8466,  pos = 2,  nom = "Anneau Ancestral" },
    { gid = 8468,  pos = 3,  nom = "Abrature Ancestrale" },
    { gid = 1499,  pos = 4,  nom = "L Enutrofion" },
    { gid = 8467,  pos = 5,  nom = "Protege-Tibias Ancestraux" },
    { gid = 8463,  pos = 6,  nom = "Abracaska Ancestral" },
    { gid = 8464,  pos = 7,  nom = "Abracapa Ancestrale" },
    { gid = 18687, pos = 15, nom = "Bouclier Akwadala" },
}
for _, b in ipairs(BUILD_MULE_RUN) do GIDS_A_GARDER[#GIDS_A_GARDER + 1] = b.gid end
DESEQUIPE_VOLONTAIRE = { [1019] = true, [1021] = true, [15990] = true }
BUILD_PAUSE = BUILD_PAUSE or false
BUILD_ABSENT_SIGNALE = BUILD_ABSENT_SIGNALE or {}
BUILD_DERNIER = BUILD_DERNIER or 0
for _, b in ipairs(BUILD_LEADER) do GIDS_A_GARDER[#GIDS_A_GARDER + 1] = b.gid end
GIDS_A_GARDER[#GIDS_A_GARDER + 1] = 14848
local function horlogeS() return tonumber((tostring(os.time()):gsub(",", "."))) or 0 end
function podsDe(a) return tonumber(sur(function() return a.inventory:podsP() end, 0)) or 0 end
function surcharge()
    if enGroupe() and estLeader() then
        for _, a in ipairs(comptesEquipe()) do
            local p = podsDe(a)
            if p >= SEUIL_PODS then return true, sur(function() return a.character:name() end, "?"), p end
        end
        return false
    end
    local p = tonumber(sur(function() return inventory:podsP() end, 0)) or 0
    return p >= SEUIL_PODS, moiNom(), p
end
function reequiperBuildLeader()
    if BUILD_PAUSE or enCombat() then return end
    if sur(function() return character:isBusy() end, false) == true then return end
    local t = horlogeS()
    if t - BUILD_DERNIER < 15 then return end
    BUILD_DERNIER = t
    local porte, enSac = {}, {}
    local ok = pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local g, p = tonumber(it.Item.Gid), tonumber(it.Position)
            if g ~= nil and p ~= nil then
                if p == 63 then enSac[g] = true else porte[p] = g porte["g" .. g] = true end
            end
        end
    end)
    if not ok then return end
    local aLeBuild, aLeSet = 0, 0
    for _, b in ipairs(BUILD_LEADER) do if porte["g" .. b.gid] then aLeBuild = aLeBuild + 1 end end
    for _, b in ipairs(BUILD_MULE_RUN) do if porte["g" .. b.gid] or enSac[b.gid] then aLeSet = aLeSet + 1 end end
    local BUILD, quoi = nil, nil
    if aLeBuild >= 8 then BUILD, quoi = BUILD_LEADER, "build leader"
    elseif not estLeader() and aLeSet >= 4 then BUILD, quoi = BUILD_MULE_RUN, "set de run"
    elseif estLeader() and not enGroupe() and aLeSet >= 4 then BUILD, quoi = BUILD_MULE_RUN, "set de run" end
    if BUILD == nil then return end
    local cLaby = tonumber(sur(function() return map:currentMapId() end, 0)) or 0
    local dansLaby = cLaby >= 72089000 and cLaby <= 72096000
    for _, b in ipairs(BUILD) do
        if b.gid == 33044 and dansLaby then
        elseif not porte["g" .. b.gid] then
            local occupant = porte[b.pos]
            if not enSac[b.gid] then
                if not BUILD_ABSENT_SIGNALE[b.gid] then
                    BUILD_ABSENT_SIGNALE[b.gid] = true
                    alerte(quoi .. " : " .. b.nom .. " (" .. b.gid .. ") ni porte ni au sac")
                end
            elseif occupant ~= nil and DESEQUIPE_VOLONTAIRE[occupant] then
            else
                pcall(function() inventory:equipItem(b.gid, b.pos) end)
                if attendre(function() return sur(function() return inventory:itemPosition(b.gid) end, -1) == b.pos end, 2500, 150) then
                    dire(quoi .. " : " .. b.nom .. " equipe en " .. b.pos)
                else
                    alerte(quoi .. " : " .. b.nom .. " PAS equipe en " .. b.pos)
                end
            end
        end
    end
end

TYPES_A_GARDER = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true,
                   [9] = true, [10] = true, [11] = true, [16] = true, [17] = true, [19] = true, [20] = true,
                   [21] = true, [22] = true, [82] = true, [114] = true, [84] = true, [24] = true, [23] = true, [151] = true, [121] = true }
function deposerALaBanque()
    if enGroupe() and estLeader() then
        attendre(function() return equipeSur(carte()) end, 30000, 100)
        for _, a in ipairs(comptesEquipe()) do deposerPour(a) end
    elseif not enGroupe() then
        deposerPour(global:thisAccountController())
    end
    BANQUE_FAITE = true
end
function gidsAGarder(inv)
    local g = {}
    for _, x in ipairs(GIDS_A_GARDER) do g[#g + 1] = x end
    pcall(function()
        for _, it in ipairs(inv:inventoryContent()) do
            local gid = tonumber(it.Item.Gid)
            if gid ~= nil and tonumber(it.Position) == 63 then
                local tn = string.lower(tostring(sur(function() return inv:getTypeName(gid) end, "")))
                local ty = tonumber(sur(function() return inv:getTypeId(gid) end, nil))
                if tn:find("qu.-te") or tn:find("clef") or tn:find("familier") or tn:find("montilier")
                   or (ty ~= nil and TYPES_A_GARDER[ty]) then
                    g[#g + 1] = gid
                end
            end
        end
    end)
    return g
end
function deposerPour(a)
    local avant = podsDe(a)
    pcall(function() a.npc:npcBank(-1) end)
    if not attendre(function() return sur(function() return a.exchange:storageKamas() end, nil) ~= nil end, 5000) then
        pcall(function() a.npc:reply(-1) end)
        attendre(function() return sur(function() return a.exchange:storageKamas() end, nil) ~= nil end, 3000)
    end
    pcall(function() a.exchange:putAllItemsExcept(gidsAGarder(a.inventory)) end)
    attendre(function() return podsDe(a) < avant end, 5000)
    pcall(function() a.exchange:leave() end)
    pcall(function() a.global:leaveDialog() end)
    dire("[BANQUE] " .. sur(function() return a.character:name() end, "?") .. " : " .. avant .. " % -> " .. podsDe(a) .. " %")
end

BANQUE_TRAJET = {
    { map = "*", path = "havenbag" },
    { map = CARTE_HAVRE_SAC, path = "zaap(191105026)" },
    { map = "191105026", path = "left" },
    { map = "191104002", door = "288" },
    { map = CARTE_BANQUE_ASTRUB, custom = function() deposerALaBanque() end },
}
VITA_CIBLE_RUN = VITA_CIBLE_RUN or 650
function caracteristiquesRun()
    if estLeader() then return end
    local function base(f) return tonumber(sur(f, 0)) or 0 end
    local sagesse = base(function() return character:getWisdomBase() end)
    local force = base(function() return character:getStrenghtBase() end)
    local vitaTrop = base(function() return character:getVitalityBase() end) > VITA_CIBLE_RUN
    if (sagesse > 0 or force > 0 or vitaTrop) and lireEtat("RESTAT_EAU") ~= "1" then
        dire("restat : sagesse " .. sagesse .. ", force " .. force .. " -> vitalite + chance")
        envoyerPaquetBrut("reinitialiserCaracteristiques", {}, "restat")
        attendre(function() return base(function() return character:getWisdomBase() end) == 0 end, 5000)
        ecrireEtat("RESTAT_EAU", 1)
    end
    local points = base(function() return character:statsPoint() end)
    if points <= 0 then return end
    local vita = base(function() return character:getVitalityBase() end)
    if vita < VITA_CIBLE_RUN then
        pcall(function() character:upgradeVitality(math.min(points, VITA_CIBLE_RUN - vita)) end)
        attendre(function() return base(function() return character:statsPoint() end) < points end, 2000)
    end
    points = base(function() return character:statsPoint() end)
    if points > 0 and base(function() return character:getVitalityBase() end) >= VITA_CIBLE_RUN then
        pcall(function() character:upgradeChance(points) end)
    end
end
VARIANTES_LEADER = { 12729, 12731, 12732, 12746 }
XML_MULE_TERRE = "xml\\SACRI CROCA 300 VITA FORCE.xml"
function xmlTerre()
    if estLeader() then return XML_LEADER_RUN end
    if MULES_TERRE == true or lireEtat("TERRE_DONJON") == "1" then return XML_MULE_TERRE end
    return XML_LEADER_RUN
end
VARIANTES_EAU    = { 12727, 12728, 12745 }
function restatTerre()
    local function base(f) return tonumber(sur(f, 0)) or 0 end
    dire("restat TERRE : config terre d abord (elle repartit 300 vita puis force), puis restat")
    pcall(function() global:loadConfigurationWithoutScript(tostring(DOSSIER) .. "\\" .. xmlTerre()) end)
    envoyerPaquetBrut("reinitialiserCaracteristiques", {}, "restat")
    attendre(function() return base(function() return character:getVitalityBase() end) == 0 end, 5000)
    pcall(function() character:upgradeVitality(300) end)
    attendre(function() return base(function() return character:getVitalityBase() end) >= 300 end, 3000)
    local pts = base(function() return character:statsPoint() end)
    if pts > 0 then pcall(function() character:upgradeStrenght(pts) end) end
    attendre(function() return base(function() return character:statsPoint() end) < pts end, 2000)
    pts = base(function() return character:statsPoint() end)
    if pts > 0 then pcall(function() character:upgradeStrength(pts) end) end
    attendre(function() return base(function() return character:statsPoint() end) == 0 end, 3000)
    pcall(function() global:loadConfigurationWithoutScript(tostring(DOSSIER) .. "\\" .. xmlTerre()) end)
    for _, id in ipairs(VARIANTES_LEADER) do pcall(function() character:getSpellVariant(id) end) end
    ecrireEtat("RESTAT_TERRE", 1)
    ecrireEtat("RESTAT_EAU", 1)
end
function restatEauRetour()
    local function base(f) return tonumber(sur(f, 0)) or 0 end
    dire("retour en EAU apres la salle du boss : " .. VITA_CIBLE_RUN .. " vitalite + chance, config eau")
    envoyerPaquetBrut("reinitialiserCaracteristiques", {}, "restat")
    attendre(function() return base(function() return character:getChanceBase() end) == 0
        and base(function() return character:statsPoint() end) > 0 end, 8000)
    pcall(function() character:upgradeVitality(VITA_CIBLE_RUN) end)
    attendre(function() return base(function() return character:getVitalityBase() end) >= VITA_CIBLE_RUN end, 3000)
    local pts = base(function() return character:statsPoint() end)
    if pts > 0 then pcall(function() character:upgradeChance(pts) end) end
    pcall(function() global:loadConfigurationWithoutScript(tostring(DOSSIER) .. "\\" .. XML_MULE_RUN) end)
    for _, id in ipairs(VARIANTES_EAU) do pcall(function() character:getSpellVariant(id) end) end
    ecrireEtat("RESTAT_TERRE", 0)
    ecrireEtat("TERRE_DONJON", 0)
    CONFIG_IA = nil
end
DONJONS_ELEMENT = {
    { nom = "Scarafeuilles", min = 94109696, max = 94116864, rangs = { [2] = true, [3] = true, [4] = true },
      raison = "Bleus immunises a l eau" },
    { nom = "Nid du Kwakwa", cartes = { [64749568] = true, [64750592] = true }, rangs = { [2] = true, [3] = true, [4] = true },
      raison = "Kwaks de Glace 75-100 % eau, Kwaks de Vent -50 % terre" },
}
function donjonTerreIci(c)
    c = tonumber(c) or 0
    for _, d in ipairs(DONJONS_ELEMENT) do
        if (d.cartes and d.cartes[c]) or (d.min and c >= d.min and c <= d.max) then return d end
    end
    return nil
end
BOSS_PASSE_TOURS = { [113] = { intervalle = 12, tours = 2 } }
function bossAMecaniqueVivant()
    local ok, ents = pcall(function() return fightAction:getAllEntities() end)
    if not ok or type(ents) ~= "table" then return nil end
    for _, e in ipairs(ents) do
        local r = BOSS_PASSE_TOURS[tonumber(e.CreatureGenericId) or -1]
        if r ~= nil and e.Team == true and (tonumber(e.LifePoints) or 0) > 0 then return r end
    end
    return nil
end
SORT_ATTIRANCE = 12735
function fightManagement()
    local monTour = false
    pcall(function() monTour = fightCharacter:isItMyTurn() == true end)
    if not monTour then return end
    if ABANDON_VU ~= nil and tostring(lireMem(cleEquipe() .. "ABANDON_N") or "0") ~= ABANDON_VU then
        ABANDON_VU = tostring(lireMem(cleEquipe() .. "ABANDON_N") or "0")
        abandonnerCombatManquant()
        return
    end
    if elPresent and iaSacriElements and elPresent() then
        local ok, err = pcall(function() iaSacriElements(estLeader()) end)
        if not ok then alerte("IA elements : " .. tostring(err)) pcall(function() fightBasic:playTurn(1) end) end
        return
    end
    if elPresent == nil and scPresent and SC_SALLES and SC_SALLES[carte()] and scPresent() then
        local ok, err = pcall(function() iaSacriScara(estLeader()) end)
        if not ok then alerte("IA Scarafeuilles : " .. tostring(err)) pcall(function() fightBasic:playTurn(1) end) end
        return
    end
    if trPresent and trPresent() then
        local ok, err = pcall(function() iaSacriTofu(estLeader()) end)
        if not ok then alerte("IA Tofu Royal : " .. tostring(err)) pcall(function() fightBasic:playTurn(1) end) end
        return
    end
    if msPresent and msPresent() then
        local ok, err = pcall(function() iaSacriMansot(estLeader()) end)
        if not ok then alerte("IA Mansot : " .. tostring(err)) pcall(function() fightBasic:playTurn(1) end) end
        return
    end
    if rmPresent and rmPresent() then
        local ok, err = pcall(function() iaSacriRoyalmouth(estLeader()) end)
        if not ok then alerte("IA Royalmouth : " .. tostring(err)) pcall(function() fightBasic:playTurn(1) end) end
        return
    end
    if rnPresent and rnPresent() then
        local ok, err = pcall(function() iaSacriRatNoir(estLeader()) end)
        if not ok then alerte("IA Rat Noir : " .. tostring(err)) pcall(function() fightBasic:playTurn(1) end) end
        return
    end
    if ksKoulossePresent and ksKoulossePresent() then
        local ok, err = pcall(function() iaSacriKoulosse(estLeader()) end)
        if not ok then alerte("IA Koulosse : " .. tostring(err)) pcall(function() fightBasic:playTurn(1) end) end
        return
    end
    local regle = bossAMecaniqueVivant()
    if regle ~= nil then
        local tour = tonumber(sur(function() return fightAction:getCurrentTurn() end, 0)) or 0
        if tour >= 1 and ((tour - 1) % regle.intervalle) < regle.tours then
            pcall(function()
                local ennemis = {}
                for _, e in ipairs(fightAction:getAllEntities() or {}) do
                    if e.Team == true and (tonumber(e.LifePoints) or 0) > 0 then ennemis[#ennemis + 1] = tonumber(e.CellId) end
                end
                local function marge(c)
                    local m = 999
                    for _, ce in ipairs(ennemis) do m = math.min(m, tonumber(fightAction:getDistance(c, ce)) or 999) end
                    return m
                end
                local ici = fightCharacter:getCellId()
                local meilleure, mm = ici, marge(ici)
                for _, c in ipairs(fightAction:getReachableCells() or {}) do
                    local v = marge(c)
                    if v > mm then meilleure, mm = c, v end
                end
                if meilleure ~= ici then deplacerCombat(meilleure) end
            end)
            dire("boss : tour " .. tour .. " sous poison (PA = degats) -> je m eloigne et je passe")
            return
        end
    end
    pcall(attirancePrioritaire)
    local ok, err = pcall(function() fightBasic:playTurn(1) end)
    if not ok then alerte("IA : playTurn " .. tostring(err)) end
end
function configIA(active)
    if CONFIG_IA == active then return end
    local base = estLeader() and XML_LEADER_RUN or (lireEtat("RESTAT_TERRE") == "1" and xmlTerre() or XML_MULE_RUN)
    local xml = active and base:gsub("%.xml$", " IA.xml") or base
    pcall(function() global:loadConfigurationWithoutScript(tostring(DOSSIER) .. "\\" .. xml) end)
    CONFIG_IA = active
    dire("config de combat : " .. xml)
end
function attirancePrioritaire()
    local moi = tonumber(sur(function() return fightCharacter:getCellId() end, -1)) or -1
    if moi < 0 then return end
    local cible, dmin = nil, 999
    for _, e in ipairs(sur(function() return fightAction:getAllEntities() end, {}) or {}) do
        if e.Team == true and (tonumber(e.LifePoints) or 0) > 0 then
            local d = tonumber(sur(function() return fightAction:getDistance(moi, tonumber(e.CellId)) end, 999)) or 999
            if d < dmin then cible, dmin = tonumber(e.CellId), d end
        end
    end
    if cible == nil or dmin < 2 then return end
    if sur(function() return fightAction:canCastSpellOnCell(SORT_ATTIRANCE, cible) end, false) == true then
        pcall(function() fightAction:castSpellOnCell(SORT_ATTIRANCE, cible) end)
        dire("Attirance sur la cellule " .. cible .. " (ennemi a " .. dmin .. " cases)")
    end
end

INIT = INIT or false
function lvT() return math.floor((tonumber((tostring(os.time()):gsub(",", "."))) or 0) * 1000) end
function filtrerPourMule(actions)
    if type(actions) ~= "table" or not enGroupe() or estLeader() then return actions end
    local ici = carte()
    local r = {}
    for _, e in ipairs(actions) do
        if e.custom ~= nil then
            local x = {}
            for k, v in pairs(e) do x[k] = v end
            x.path, x.door, x.fight, x.forcefight, x.gather, x.pathFn = nil, nil, nil, nil, nil, nil
            x.map = ici
            r[#r + 1] = x
        end
    end
    local act = tostring(lireMem(cleEquipe() .. "ACT_" .. ici) or "")
    local genre, valeur, quand = act:match("^(%a+)|(.-)|(%d+)$")
    if genre ~= nil and os.time() - tonumber(quand) < 120 then
        local x = r[1] or { map = ici }
        if genre == "path" then x.path = valeur else x.door = valeur end
        r[1] = x
    end
    if #r == 0 then
        r[1] = { map = ici, custom = function() attendre(function() return carte() ~= ici end, 5000, 100) end }
    end
    return r
end
function autoPret()
    if estLeader() then return end
    local g = monGroupe()
    if g == nil then return end
    pcall(envoyerAutoReady)
    pcall(envoyerAutoJoin)
    AUTOPRET_FAIT, AUTOPRET_GROUPE, AUTOPRET_QUAND = true, g, os.time()
    ecrireMem(cleEquipe() .. "AUTOPRET_" .. moiId(), tostring(g))
end
function donjonSolo(e) return DONJON_SOLO_PARTOUT ~= false or (e ~= nil and e.donjonSolo == true) end
function dernierMessageOccupe()
    local L = sur(function() return global:consoleLines() end, nil)
    if type(L) ~= "table" then return false end
    local n = #L
    for i = n, math.max(1, n - 3), -1 do
        local l = tostring(L[i] or "")
        if l:find("tes occup", 1, true) then return true end
    end
    return false
end
function autoPretAJour()
    if estLeader() then return end
    pcall(demanderMonGroupe)
    if not AUTOPRET_FAIT or AUTOPRET_GROUPE ~= monGroupe() or os.time() - (AUTOPRET_QUAND or 0) >= 20 then
        autoPret()
    end
    local g = monGroupe()
    if g ~= nil and AUTOPRET_FAIT and AUTOPRET_GROUPE == g and not enCombat() then
        ecrireMem(cleEquipe() .. "PREUVE_" .. moiId(), g .. ":" .. carte() .. ":" .. math.floor(os.time()))
    end
end
function monGroupe() return tonumber(lireMem("RS_PARTY_" .. moiId())) end
function havreSacSur()
    local avant = carte()
    if sur(function() return character:isBusy() end, false) then debloquerOccupe("avant havre-sac") end
    if dernierMessageOccupe() then debloquerOccupe("message occupe") end
    for essai = 1, 3 do
        pcall(function() map:changeMap("havenbag") end)
        if attendre(function() return carte() ~= avant end, 4000, 150) then return end
        debloquerOccupe("havre-sac refuse, essai " .. essai)
    end
    if carte() == avant and not enCombat() then pcall(function() global:restartScript(false) end) end
end
function debloquerOccupe(raison)
    alerte("occupe (" .. tostring(raison) .. ") -> leaveDialog + exchange:leave + petit pas")
    pcall(function() global:leaveDialog() end)
    pcall(function() exchange:leave() end)
    pcall(function() npc:leaveDialog() end)
    attendre(function() return not sur(function() return character:isBusy() end, false) end, 1500, 100)
    local c = tonumber(sur(function() return map:currentCell() end, -1)) or -1
    if c >= 0 then
        for _, d in ipairs({ 1, -1, 14, -14, 15, -15, 28, -28 }) do
            pcall(function() map:moveToCell(c + d) end)
            if attendre(function() return (tonumber(sur(function() return map:currentCell() end, -1)) or -1) ~= c end, 1500, 100) then break end
        end
    end
end
function envelopper(actions)
    if type(actions) ~= "table" then return actions end
    for _, e in ipairs(actions) do
        if e.path == "havenbag" and e.custom == nil and e.door == nil and not e.enveloppe then
            e.path, e.enveloppe = nil, true
            e.custom = havreSacSur
        end
        if e.custom ~= nil and e.path == nil and e.door == nil and not e.enveloppe then
            local f = e.custom
            e.enveloppe = true
            local finQuete = e.finQuete
            e.custom = function()
                local avant = carte()
                f()
                if carte() == avant and not enCombat() and dernierMessageOccupe() then
                    debloquerOccupe("action refusee")
                    f()
                end
                if finQuete ~= nil then marquerQuete(finQuete) end
                if carte() == avant and not enCombat() and (estLeader() or not enGroupe()) then
                    pcall(function() global:restartScript(false) end)
                end
            end
        end
    end
    return actions
end
function publierActionLeader(actions)
    if type(actions) ~= "table" or not enGroupe() or not estLeader() then return end
    for _, e in ipairs(actions) do
        local p = e.path
        if p == nil and e.pathFn ~= nil then p = sur(e.pathFn, nil) end
        if p ~= nil then ecrireMem(cleEquipe() .. "ACT_" .. tostring(e.map), "path|" .. tostring(p) .. "|" .. os.time())
        elseif e.door ~= nil then ecrireMem(cleEquipe() .. "ACT_" .. tostring(e.map), "door|" .. tostring(e.door) .. "|" .. os.time()) end
    end
end
function marquerQuete(n)
    local etape = ETAPES[n]
    if etape == nil then return end
    if enGroupe() and estLeader() then
        for _, a in ipairs(comptesEquipe()) do ecrireEtatDe(idDe(a), "QUETE_" .. etape.cle, 1) end
    else
        ecrireEtat("QUETE_" .. etape.cle, 1)
    end
end
function preuveFraiche(a, ref, ici)
    local v = tostring(lireMem(cleEquipe() .. "PREUVE_" .. idDe(a)) or "")
    local g, c, t = v:match("^(%d+):(%d+):(%d+)$")
    return tonumber(g) == tonumber(ref) and c == tostring(ici) and os.time() - (tonumber(t) or 0) <= 5
end
function initialiser()
    INIT = true
    dire("RUN SACRI 8 — " .. moiNom() .. " rang " .. monRang() .. (estLeader() and " (leader)" or ""))
    chargerEtat()
    local xml = tostring(DOSSIER) .. "\\" .. (estLeader() and XML_LEADER_RUN or ((lireEtat("RESTAT_TERRE") == "1" or MULES_TERRE == true) and xmlTerre() or XML_MULE_RUN))
    if sur(function() return global:fileExists(xml) end, false) then
        pcall(function() global:loadConfigurationWithoutScript(xml) end)
    end
    if not estLeader() and MULES_TERRE == true and lireEtat("RESTAT_TERRE") ~= "1" then
        pcall(restatTerre)
    end
    if not estLeader() then
        pcall(caracteristiquesRun)
        local vars = (lireEtat("RESTAT_TERRE") == "1") and VARIANTES_LEADER or VARIANTES_EAU
        for _, id in ipairs(vars) do pcall(function() character:getSpellVariant(id) end) end
    else
        for _, id in ipairs(VARIANTES_LEADER) do pcall(function() character:getSpellVariant(id) end) end
        pcall(function() character:getSpellVariant(12735) end)
    end
    ecouterTeleport()
    lireLesSucces()
    pcall(publierSuccesLarves)
    pcall(function() ecrireMem("RS_ID_" .. lvMoi(), moiId()) end)
    publierMaProgression()
    local moiCompte = sur(function() return global:thisAccountController():getUsername() end, "")
    if lireMem("RS_RELEVE_" .. moiCompte) == "1" then
        ecrireMem("RS_RELEVE_FAIT_" .. moiCompte, os.time())
        dire("releve fait (succes + progression), arret")
        RELEVE_FINI = true
        return
    end
    if remettreCoiffeEtCape ~= nil then
        local vide = function(p)
            local occupe = false
            pcall(function() for _, it in ipairs(inventory:inventoryContent()) do if tonumber(it.Position) == p then occupe = true end end end)
            return not occupe
        end
        if vide(6) or vide(7) then pcall(remettreCoiffeEtCape) end
    end
    if not estLeader() then ecrireMem(cleEquipe() .. "AUTOPRET_" .. moiId(), "") end
    local lmInit = (larvesMode ~= nil) and sur(larvesMode, "hors") or "hors"
    if lmInit ~= "hors" then
        dire("larves v2 : demarrage en mode " .. tostring(lmInit) .. " -> groupe en jeu conserve (ni purge, ni invitation des 7)")
    else
        grouperEnJeu()
    end
    if not estLeader() then autoPret() end
    if estLeader() then deciderEtapeEquipe()
    else attendre(function() return etapeEquipe() ~= nil end, ATTENTE_EQUIPE_MS, 200) end
end
function lvS() return math.floor(tonumber((tostring(os.time()):gsub(",", "."))) or 0) end

LV_VERSION_SCRIPT = 3
LV_RAPPEL_ATTENTE_MS = 20000
function lvOeufs()
    return (tonumber(sur(function() return inventory:itemCount(LARVES_D.OEUF) end, 0)) or 0)
         + (tonumber(sur(function() return inventory:itemCount(LARVES_D.CLEF) end, 0)) or 0)
end
function lvPhase() return lvLireGen("PHASE") end
function lvMoi() return tostring(sur(function() return global:thisAccountController():getUsername() end, "")) end
function lvChefCompte()
    if LV_CHEF == nil or LV_CHEF == "" then
        LV_CHEF = tostring(lireMem("RS_EQUIPE_DE_" .. lvMoi()) or ""):match("^([^,]+)")
            or tostring(sur(function() return comptesEquipe()[1]:getUsername() end, ""))
    end
    return LV_CHEF
end
function entretienGroupeLarves()
    if monRang() >= 5 then
        local gChef = tonumber(lireMem("RS_PARTY_" .. idDe(comptesEquipe()[1])))
        local recente = INVIT_ACCEPTEE_T ~= nil and ((tonumber((tostring(os.time()):gsub(",", "."))) or 0) - INVIT_ACCEPTEE_T) < 15
        if gChef ~= nil and monGroupe() == gChef and not recente then
            dire("larves : je quitte le groupe du leader (cote 2, chef rang 5)")
            quitterMonGroupe()
            INVIT_ACCEPTEE, AUTOPRET_FAIT = false, false
        end
    end
    if not suisChefDeCote() then
        local chefC = chefDuCote(coteDeRang(monRang()))
        local gChef = tonumber(lireMem("RS_PARTY_" .. idDe(chefC)))
        local g = monGroupe()
        if gChef ~= nil and g ~= nil and g ~= gChef and lvT() - (LV_QUITTE_T or 0) > 30000 then
            LV_QUITTE_T = lvT()
            dire("larves : mon groupe " .. g .. " n est pas celui de mon chef (" .. gChef .. ") -> je le quitte pour etre reinvite")
            quitterMonGroupe()
            INVIT_ACCEPTEE, AUTOPRET_FAIT = false, false
        end
    end
    pcall(reinviterAbsents)
    if not estLeader() then pcall(autoPretAJour) end
end
function publierVuLarves(mode)
    local c = math.floor(tonumber(sur(function() return map:currentCell() end, -1)) or -1)
    local nbc = math.floor(tonumber(sur(function() return global:getCountFight() end, 0)) or 0)
    local o = math.floor(tonumber(sur(function() return inventory:itemCount(LARVES_D.OEUF) end, 0)) or 0)
    local k = math.floor(tonumber(sur(function() return inventory:itemCount(LARVES_D.CLEF) end, 0)) or 0)
    local v = "V2:" .. tostring(math.floor(lvGen())) .. ":" .. tostring(lvS()) .. ":" .. carte() .. ":" .. tostring(c)
        .. ":" .. (enCombat() and "1" or "0") .. ":" .. tostring(nbc) .. ":" .. tostring(o) .. ":" .. tostring(k)
        .. ":" .. tostring(mode or "")
    ecrireMem(lvP() .. "VU_" .. lvMoi(), v)
    if LV_VER_ECRITE ~= lvP() then LV_VER_ECRITE = lvP() ; ecrireMem(lvP() .. "VER_" .. lvMoi(), LV_VERSION_SCRIPT) end
end
function larvesMode()
    if LARVES_D == nil then return "hors" end
    local ici = carte()
    local dedans = LARVES_D.dedans(ici)
    if etapeLarvesCourante() == nil then
        if dedans and (LV_ETAPE_LUE == nil or etapeEquipe() == nil) then return "pilote" end
        return dedans and "sortirHors" or "hors"
    end
    local ph, md = lvPhase(), lvMonMode()
    if ph == "alerte" or md == "stop" then return "stop" end
    if ph == "fini" or md == "fin" then
        if dedans and ici ~= LARVES_D.SORTIE then return "sortir" end
        return "fin"
    end
    if dedans then return (md == "sortir") and "sortir" or "pilote" end
    if ph == nil then return "veille" end
    if md == "repos" then return "repos" end
    if ici == LARVES_D.ENTREE then
        if lvOeufs() > 0 then LV_OEUF_T = lvT() return "attente" end
        if lvT() - (LV_OEUF_T or -1e12) < 20000 then return "attente" end
    end
    return "libre"
end
function lvMonMode() return lvLireGen("MODE_" .. lvMoi()) end
function publierSuccesLarves()
    if LARVES_D == nil then return end
    local ok = SUCCES_VALIDE[LARVES_D.SUCCES] == true
    if not ok and #(SUCCES_PAQUETS or {}) == 0 and lireEtat("FAIT_larves") == "1" then ok = true end
    ecrireMem(lvP() .. "SUCCES_" .. lvMoi(), ok and "1" or "0")
end
function larvesEnCours() local m = larvesMode() return m == "pilote" or m == "attente" end
function etapeLarvesCourante()
    local lue = etapeEquipe()
    if lue ~= nil then LV_ETAPE_LUE = lue end
    local n = lue or LV_ETAPE_LUE or ETAT_ETAPE.n
    local e = (n ~= nil) and ETAPES[n] or nil
    if e ~= nil and e.cle == "larves" then e.n = n return e end
    return nil
end
function lvGen() return tonumber(lireMem(lvP() .. "GEN")) or 0 end
function traiterRegroupe()
    local v = tostring(lireMem(lvP() .. "REGROUPE_" .. lvMoi()) or "")
    if v == "" or v == LV_REGROUPE_FAIT then return end
    LV_REGROUPE_FAIT = v
    local g, n = v:match("^(%d+):(%d+)")
    if tonumber(g) ~= lvGen() then return end
    if tonumber(n) == 1 then
        AUTOPRET_FAIT = false
        pcall(autoPret)
        dire("larves : combat non rejoint -> auto join rearme")
    else
        dire("larves : combat non rejoint deux fois -> je quitte mon groupe pour etre reinvite")
        quitterMonGroupe()
        INVIT_ACCEPTEE, AUTOPRET_FAIT = false, false
    end
end
local function lvLireGen(cle)
    local g, v = tostring(lireMem(lvP() .. cle) or ""):match("^(%d+):(%a+)$")
    if g == nil or tonumber(g) ~= lvGen() then return nil end
    return v
end
function lvP() return "RSL_" .. tostring(lvChefCompte()) .. "_" end
function lvSilence(ici)
    local g, a, r = tostring(lireMem(lvP() .. "SILENCE") or ""):match("^(%d+):(%d+):(%d+)$")
    return tonumber(g) == lvGen() and (ici == a or ici == r)
end
function rappelAttenteLarves(mode, ici, force)
    local t = lvT()
    if not force and t - (LV_ATTENTE_DITE or 0) < LV_RAPPEL_ATTENTE_MS then return end
    LV_ATTENTE_DITE = t
    dire("larves v2 : attente pilotee (" .. tostring(mode) .. " sur " .. tostring(ici) .. ", tentative " .. lvGen()
        .. ", phase " .. tostring(lvPhase()) .. ")")
end

LV_CASES_INTERDITES = { [220] = true, [164] = true, [367] = true, [203] = true, [323] = true, [268] = true,
    [379] = true, [469] = true, [500] = true, [404] = true, [277] = true, [290] = true }
function equipeSortieComplete(ici)
    ici = tostring(ici or carte())
    local e = ETAPES[ETAT_ETAPE.n or 0]
    local dedans = {}
    for _, x in ipairs((e and e.donjon) or {}) do dedans[tostring(x.map)] = true end
    local function encoreDedans(a)
        local m = tostring(carteDe(a))
        local id = tonumber(m) or 0
        return dedans[m] or (id >= 72089000 and id <= 72096000)
    end
    if attendre(function()
        for _, a in ipairs(comptesEquipe()) do
            if carteDe(a) ~= ici and encoreDedans(a) then return false end
        end
        return true
    end, ATTENTE_EQUIPE_MS, 200) then return true end
    rejouerCetteEntree()
    return false
end
function messagesGroupePlein(nom)
    local L = sur(function() return global:consoleLines() end, nil)
    if type(L) ~= "table" then return false end
    for i = #L, math.max(1, #L - 4), -1 do
        local l = tostring(L[i] or "")
        if l:find("plein, impossible d", 1, true) and l:find(tostring(nom), 1, true) then return true end
    end
    return false
end
function reinviterAbsents()
    if not suisChefDeCote() or enGroupe() then return end
    if os.time() - (CTRL_GROUPE or 0) < 10 then return end
    CTRL_GROUPE = os.time()
    pcall(demanderMonGroupe)
    local ref = groupeDeReference()
    if deuxGroupes() and not estLeader() then
        local gChef = tonumber(lireMem("RS_PARTY_" .. idDe(comptesEquipe()[1])))
        if ref ~= nil and gChef ~= nil and ref == gChef then return end
    end
    for _, a in ipairs(membresAInviter()) do
        local enQuatre = false
        do local e = ETAPES[ETAT_ETAPE.n or 0]
           if e ~= nil and type(e.quatreTout) == "table" and e.quatreTout[tostring(carteDe(a))] and carteDe(a) ~= carte() then enQuatre = true end end
        if not enQuatre and (ref == nil or tonumber(lireMem("RS_PARTY_" .. idDe(a))) ~= ref) then
            local nom = sur(function() return a.character:name() end, nil)
            INVIT_ESSAIS = INVIT_ESSAIS or {}
            INVIT_ESSAIS[idDe(a)] = (INVIT_ESSAIS[idDe(a)] or 0) + 1
            if estLeader() and INVIT_ESSAIS[idDe(a)] > 3 and os.time() - (GROUPE_REFAIT or 0) > 120 then
                GROUPE_REFAIT = os.time()
                INVIT_ESSAIS = {}
                dire("groupe en jeu : membres non confirmes apres 3 invitations -> je refais le groupe")
                quitterMonGroupe()
                ecrireMem("RS_PARTY_" .. moiId(), "")
                return
            end
            if nom ~= nil then
                dire("groupe en jeu : " .. nom .. " absent -> invitation")
                pcall(function() global:invitePlayerByName(nom) end)
            end
        end
    end
end
function membresAInviter()
    local l, r = {}, monRang()
    for i, a in ipairs(comptesEquipe()) do
        if i ~= r then
            if larvesEnCours() then
                if coteDeRang(i) == coteDeRang(r) then l[#l + 1] = a end
            elseif quatreFixe() then
                if coteDeRang(i) == coteDeRang(r) and not (trouSansLeader() and i == 1) then l[#l + 1] = a end
            elseif quatreEnCours() then
                if coteDeRang(i) == coteDeRang(r) and carteDe(a) == carte() then l[#l + 1] = a end
            else
                l[#l + 1] = a
            end
        end
    end
    return l
end
function accepterInvitationEnAttente()
    if not estLeader() and enGroupe() then ecrireMem(cleEquipe() .. "INVIT_TENTATIVES_" .. moiId(), "0") end
    if estLeader() or enGroupe() then return end
    local cle = cleEquipe() .. "INVIT_EN_ATTENTE_" .. moiId()
    local pid = lireMem(cle)
    if pid == nil or pid == "" then return end
    ecrireMem(cle, "")
    local chef = deuxGroupes() and chefDuCote(coteDeRang(monRang())) or comptesEquipe()[1]
    local id = tonumber(lireMem("RS_PARTY_" .. idDe(chef))) or tonumber(pid)
    if id == nil then return end
    ecouterGroupe()
    ID_GROUPE = nil
    envoyerPaquetBrut("demanderIdentifiantGroupe", {}, "identifiant de groupe (verification)")
    attendreEnEcoutant(function() return ID_GROUPE ~= nil end, 3000, PAQUETS_PARTY_ID)
    if ID_GROUPE ~= nil and ID_GROUPE == id then
        ecrireMem("RS_PARTY_" .. moiId(), tostring(ID_GROUPE))
        ecrireMem(cleEquipe() .. "INVIT_TENTATIVES_" .. moiId(), "0")
        dire("deja dans le groupe " .. id .. " du chef -> memoire corrigee, aucune action")
        return
    end
    local cleN = cleEquipe() .. "INVIT_TENTATIVES_" .. moiId()
    local n = (tonumber(lireMem(cleN)) or 0) + 1
    ecrireMem(cleN, tostring(n))
    if n >= 2 then
        ecrireMem(cleN, "0")
        alerte("invitation toujours en attente apres acceptation -> deconnexion / reconnexion")
        pcall(function() global:reconnectSec(5) end)
        return
    end
    dire("invitation en attente (groupe " .. id .. ") -> acceptation")
    pcall(function() global:leaveDialog() end)
    envoyerPaquetBrut("accepterInvitation", { partyId = tostring(id) }, "acceptation du groupe (invitation en attente)")
    INVIT_ACCEPTEE = true
end
function quatreEnCours()
    if quatreFixe() then return true end
    local c = carte()
    if not salleQuatre(c) then return false end
    local cle = cleEquipe() .. "QUATRE_" .. c
    local v = tonumber(lireMem(cle))
    if v ~= nil and os.time() - v < 600 then return true end
    local n = 0
    for _, a in ipairs(comptesEquipe()) do if carteDe(a) == c then n = n + 1 end end
    if n > 4 then ecrireMem(cle, tostring(math.floor(os.time()))) return true end
    return false
end
function rejouerCetteEntree()
    if ETAT_ETAPE ~= nil and (ETAT_ETAPE.idx or 1) > 1 then ETAT_ETAPE.idx = ETAT_ETAPE.idx - 1 end
    DERNIERE_ACTION = nil
end
function muleDevantDansLeDonjon(a, ici)
    local e = ETAPES[ETAT_ETAPE.n or 0]
    local l = e and e[ETAT_ETAPE.phase or ""] or nil
    if type(l) ~= "table" then return false end
    local rm = nil
    for i, x in ipairs(l) do if tostring(x.map) == tostring(ici) then rm = i break end end
    if rm == nil then return false end
    local cm = tostring(carteDe(a))
    for i = rm + 1, #l do
        if tostring(l[i].map) == cm then return true end
        if l[i].barriere then break end
    end
    return false
end
function lvVoisinePraticable(c)
    local ok = {}
    pcall(function() for _, v in ipairs(map:getWalkableCells(true)) do ok[tonumber(v)] = true end end)
    for _, d in ipairs({ 1, -1, 14, -14, 13, -13, 15, -15, 28, -28 }) do
        local v = c + d
        local lig, col = math.floor(v / 14), v % 14
        if ok[v] and not LV_CASES_INTERDITES[v] and lig >= 2 and lig <= 37 and col >= 1 and col <= 12
           and tonumber(sur(function() return map:cellDistance(c, v) end, 9)) == 1 then return v end
    end
    return nil
end
function deuxGroupes() return larvesEnCours() or quatreEnCours() end
function equipeAuComplet(ici, ms, rejouer)
    ici = tostring(ici or carte())
    if attendre(function() return equipeSur(ici) end, ms or ATTENTE_EQUIPE_MS, 200) then return true end
    if rejouer then rejouerCetteEntree() end
    local absents = {}
    for _, a in ipairs(comptesEquipe()) do
        if carteDe(a) ~= ici then absents[#absents + 1] = sur(function() return a.character:name() end, "?") .. "@" .. carteDe(a) end
    end
    alerte("carte " .. ici .. " : j attends encore " .. table.concat(absents, ", ") .. " -> je ne continue pas sans les 8")
    return false
end
function quatreFixe()
    local e = ETAPES[ETAT_ETAPE.n or 0]
    return e ~= nil and type(e.quatreTout) == "table" and e.quatreTout[tostring(carte())] == true
end
function salleQuatre(c)
    local e = ETAPES[ETAT_ETAPE.n or 0]
    local l = e and e[ETAT_ETAPE.phase or ""] or nil
    if type(l) ~= "table" then return false end
    for _, x in ipairs(l) do if tostring(x.map) == tostring(c) and x.quatre then return true end end
    return false
end
function trouSansLeader()
    local e = ETAPES[ETAT_ETAPE.n or 0]
    if e == nil or type(e.trou) ~= "table" or not e.trou[tostring(carte())] then return false end
    return carteDe(comptesEquipe()[1]) ~= carte()
end
function coteDeRang(r) return (r >= 5) and 2 or 1 end
function chefDuCote(cote)
    local l = comptesEquipe()
    if cote == 2 and not larvesEnCours() and not quatreFixe() and quatreEnCours() then
        for i = 5, #l do if carteDe(l[i]) == carte() then return l[i] end end
    end
    return (cote == 2) and l[5] or l[1]
end
function equipePrete()
    local ici = carte()
    local quatre, monCote = quatreEnCours(), coteDeRang(monRang())
    local function concerne(i, a)
        if idDe(a) == moiId() then return false end
        if quatre and coteDeRang(i) ~= monCote then return false end
        return true
    end
    for i, a in ipairs(comptesEquipe()) do
        if concerne(i, a) and carteDe(a) ~= ici and not muleDevantDansLeDonjon(a, ici) then
            if not (quatre and monCote == 2 and not quatreFixe()) then return false end
        end
    end
    local ref = groupeDeReference()
    if ref == nil then return false end
    if quatre then
        for i, a in ipairs(comptesEquipe()) do
            if idDe(a) ~= moiId() and coteDeRang(i) ~= monCote and carteDe(a) == ici
                and tonumber(lireMem("RS_PARTY_" .. idDe(a))) == ref then return false end
        end
    end
    for i, a in ipairs(comptesEquipe()) do
        if concerne(i, a) and carteDe(a) == ici then
            local id = idDe(a)
            if tonumber(lireMem("RS_PARTY_" .. id)) ~= ref then return false end
            if tonumber(lireMem(cleEquipe() .. "AUTOPRET_" .. id)) ~= ref then return false end
            if not preuveFraiche(a, ref, ici) then return false end
        end
    end
    return true
end
function suisChefDeCote()
    if not deuxGroupes() then return estLeader() end
    local r = monRang()
    if larvesEnCours() then return r == 1 or r == 5 end
    return r == 1 or idDe(chefDuCote(1)) == moiId() or idDe(chefDuCote(2)) == moiId()
end
function rangDe(a)
    for i, x in ipairs(comptesEquipe()) do if idDe(x) == idDe(a) then return i end end
    return 0
end
function finLarves()
    if carte() == LARVES_D.SORTIE then return { { map = carte(), door = tostring(LARVES_D.PORTE_FIN) } } end
    local e, g = etapeLarvesCourante(), lvGen()
    if e ~= nil and LV_FIN_GEN ~= g then
        LV_FIN_GEN = g
        if monRang() >= 5 then
            local gChef = tonumber(lireMem("RS_PARTY_" .. idDe(comptesEquipe()[1])))
            if monGroupe() ~= nil and monGroupe() ~= gChef then
                dire("larves finies : je quitte le groupe du cote 2 -> retour dans le groupe du leader")
                quitterMonGroupe()
                INVIT_ACCEPTEE, AUTOPRET_FAIT = false, false
            end
        end
        dire("larves v2 : tentative " .. g .. " reussie -> etape " .. tostring(e.n) .. " finie")
        ETAT_ETAPE.n = e.n
        DERNIERE_ACTION = nil
        changerPhase("fini")
        ecrireMem(lvP() .. "FIN_FAITE_" .. lvMoi(), tostring(g))
    end
    return nil
end
function sortirDuDonjonLarves()
    local g, ici = lvGen(), carte()
    if LV_SORTIE_GEN ~= g then LV_SORTIE_GEN, LV_SORTIE_ESSAIS = g, 0 end
    if LV_SORTIE_ESSAIS >= 3 then
        publierVuLarves("sortir")
        rappelAttenteLarves("sortir : attente de l outil de sortie du controller", ici, true)
        attendre(function() return carte() ~= ici or lvGen() ~= g or larvesMode() ~= "sortir" end, 30000, 500)
        if carte() == ici and not enCombat() then pcall(function() global:restartScript(false) end) end
        return
    end
    LV_SORTIE_ESSAIS = LV_SORTIE_ESSAIS + 1
    ecrireMem(lvP() .. "SORTIE_FAITE_" .. lvMoi(), g .. ":" .. LV_SORTIE_ESSAIS)
    publierVuLarves("sortir")
    dire("larves : sortie du donjon (tentative " .. g .. ", essai " .. LV_SORTIE_ESSAIS .. ") -> DungeonQuitRequest")
    pcall(function() global:leaveDialog() end)
    pcall(function() developer:sendMessage(developer:createMessage("DungeonQuitRequest")) end)
    attendre(function() return carte() ~= ici end, 8000, 50)
    if carte() == ici and not enCombat() then pcall(function() global:restartScript(false) end) end
end
function pasAntiInactivite(derCase, depuis)
    local c = tonumber(sur(function() return map:currentCell() end, -1)) or -1
    local t = lvT()
    if c ~= derCase or depuis == nil then return c, t end
    local lim = (tonumber(LARVES_PAS_INACTIVITE_MIN) or 10) * 60000
    if t - depuis < lim or enCombat() then return derCase, depuis end
    local v = lvVoisinePraticable(c)
    if v ~= nil then
        dire("larves : immobile depuis " .. math.floor(lim / 60000) .. " min -> un pas (anti-inactivite) vers " .. v)
        pcall(function() map:moveToCell(v) end)
    end
    return derCase, t
end
function bouclePilotee()
    ecouterInvitations() ; ecouterGroupe()
    local ici, m0 = carte(), larvesMode()
    if LV_TRACE ~= ici .. ":" .. m0 .. ":" .. lvGen() then
        LV_TRACE = ici .. ":" .. m0 .. ":" .. lvGen()
        rappelAttenteLarves(m0, ici, true)
    end
    local derEntretien, derMode, mode = 0, 0, m0
    local derCase, depuis = nil, nil
    while carte() == ici and not enCombat() and mode == m0 do
        battement()
        local t = lvT()
        if t - (LV_VU_T or 0) >= 500 then LV_VU_T = t ; publierVuLarves(m0) end
        rappelAttenteLarves(m0, ici)
        if not lvSilence(ici) and sur(function() return character:isBusy() end, false) then
            pcall(function() global:leaveDialog() end) ; pcall(function() exchange:leave() end)
        end
        if m0 == "pilote" or m0 == "attente" then traiterRegroupe() end
        if (m0 == "pilote" or m0 == "attente") and not lvSilence(ici) and t - derEntretien >= 2000 then
            derEntretien = t
            entretienGroupeLarves()
            LV_VU_T = lvT() ; publierVuLarves(m0)
            attendreEnEcoutant(function() return carte() ~= ici or enCombat() end, 300, { NOMS_INVITATION[1] })
        else
            global:delay(100)
        end
        if not LARVES_D.dedans(ici) then derCase, depuis = pasAntiInactivite(derCase, depuis) end
        if lvT() - derMode >= 500 then derMode = lvT() ; mode = larvesMode() end
    end
    if carte() == ici and not enCombat() then pcall(function() global:restartScript(false) end) end
end

RN_PLACEMENT_DANGER = { [245] = { 216, 243 } }
function placementMansot(nosCases, leursCases)
    local boss = nil
    pcall(function()
        for _, e in ipairs(fightAction:getAllEntities()) do
            if tonumber(e.CreatureGenericId) == (MS_GID or 2848) then boss = tonumber(e.CellId) end
        end
    end)
    if boss == nil then return end
    local function d(a, b) return tonumber(sur(function() return fightAction:getDistance(a, b) end, 99)) or 99 end
    local ici = tonumber(sur(function() return fightCharacter:getCellId() end, -1))
    local chef = estLeader()
    local leaderCase = tonumber(lireMem("MS_PLACEMENT_LEADER") or "")
    local best, bestSc = nil, -1e9
    for k, id in pairs(nosCases or {}) do
        local c = tonumber(k)
        if c and (tonumber(id) == -1 or c == ici) then
            local dc = d(c, boss)
            local sc
            if chef then sc = -dc
            else
                sc = -math.abs(dc - 3)
                if leaderCase and d(c, leaderCase) <= 1 then sc = sc - 50 end
            end
            if sc > bestSc then best, bestSc = c, sc end
        end
    end
    if best then
        if best ~= ici then pcall(function() fightAction:chooseCell(best) end) end
        if chef then ecrireMem("MS_PLACEMENT_LEADER", best) end
        dire("placement Mansot : case " .. best .. " (boss a " .. d(best, boss) .. ")" .. (chef and " [porteur]" or ""))
    end
end
function fightManagementPositionCorps(challengers, defenders)
    if carte() == SALLE_RAT_NOIR or (rnPresent and rnPresent())
        or carte() == SALLE_ROYALMOUTH or (rmPresent and rmPresent())
        then pcall(placementLoinDesMonstres, challengers, defenders) end
    if carte() == SALLE_MANSOT or (msPresent and msPresent()) then pcall(placementMansot, challengers, defenders) end
    ABANDON_VU = tostring(lireMem(cleEquipe() .. "ABANDON_N") or "0")
    if not suisChefDeCote() then
        return
    end
    if enGroupe() or LANCEMENT == nil then return end
    local l = LANCEMENT
    LANCEMENT = nil
    if os.time() - l.t > 30 then return end
    local function absents()
        local r = {}
        for i, a in ipairs(comptesEquipe()) do
            if idDe(a) ~= moiId() and carteDe(a) == l.carte and not sur(function() return a.character:isInFight() end, false)
                and not (l.quatre and coteDeRang(i) ~= coteDeRang(monRang())) then r[#r + 1] = a end
        end
        return r
    end
    attendre(function() return #absents() == 0 end, 10000, 200)
    for _, a in ipairs(absents()) do
        local id = idDe(a)
        ecrireMem("RS_PARTY_" .. id, "")
        ecrireMem(cleEquipe() .. "AUTOPRET_" .. id, "")
        alerte(sur(function() return a.character:name() end, "?") .. " n a PAS rejoint le combat -> hors groupe, reinvitation")
    end
    if #absents() > 0 then
        ecrireMem(cleEquipe() .. "ABANDON_N", tostring((tonumber(ABANDON_VU) or 0) + 1))
        abandonnerCombatManquant()
    end
end
function placementRatNoir(nosCases, ennemis)
    local rnCase = nil
    pcall(function()
        for _, e in ipairs(fightAction:getAllEntities() or {}) do
            if tonumber(e.CreatureGenericId) == 939 then rnCase = tonumber(e.CellId) end
        end
    end)
    if rnCase == nil then for _, c in ipairs(ennemis) do if c == 245 then rnCase = 245 end end end
    local danger = {}
    if rnCase then
        danger[#danger + 1] = rnCase
        for _, c in ipairs(RN_PLACEMENT_DANGER[rnCase] or {}) do danger[#danger + 1] = c end
    end
    local function d(a, b) return tonumber(sur(function() return fightAction:getDistance(a, b) end, 99)) or 99 end
    local L = {}
    for k, _ in pairs(nosCases or {}) do
        local c = tonumber(k)
        if c then
            local dr, dm = 99, 99
            for _, x in ipairs(danger) do dr = math.min(dr, d(c, x)) end
            for _, e in ipairs(ennemis) do dm = math.min(dm, d(c, e)) end
            L[#L + 1] = { c = c, dr = dr, dm = dm, sc = math.min(dr, 14) * 10 + math.min(dm, 6) * 3 }
        end
    end
    table.sort(L, function(a, b) if a.sc ~= b.sc then return a.sc > b.sc end return a.c < b.c end)
    if #L == 0 then return end
    local n = #comptesEquipe()
    local rang = monRang()
    local idx = estLeader() and math.min(n, #L) or math.max(1, math.min(rang - 1, #L))
    if estLeader() then
        for k = idx, #L do if L[k].dr > 6 then idx = k break end end
    end
    local ici = tonumber(sur(function() return fightCharacter:getCellId() end, -1))
    local function occupees()
        local o = {}
        pcall(function()
            for _, e in ipairs(fightAction:getAllEntities() or {}) do o[tonumber(e.CellId) or -1] = true end
        end)
        return o
    end
    local ordre = {}
    for k = idx, #L do ordre[#ordre + 1] = k end
    for k = idx - 1, 1, -1 do ordre[#ordre + 1] = k end
    table.sort(ordre, function(a, b)
        if a == b then return false end
        if a == idx or b == idx then return a == idx end
        local sa, sb = L[a].dr > 6, L[b].dr > 6
        if sa ~= sb then return sa end
        if L[a].sc ~= L[b].sc then return L[a].sc > L[b].sc end
        return a < b
    end)
    local scIci = nil
    for _, x in ipairs(L) do if x.c == ici then scIci = x.sc end end
    local essais = 0
    for _, k in ipairs(ordre) do
        if essais >= 10 then break end
        local c = L[k].c
        if c == ici then dire("placement Rat Noir (rang " .. rang .. ") : deja sur " .. c) return end
        local pasMieux = scIci and L[k].sc <= scIci and L[k].dr <= 6
        local libre = not pasMieux and not occupees()[c]
        if libre or (k == idx and not pasMieux) then
            essais = essais + 1
            pcall(function() fightAction:chooseCell(c) end)
            if attendre(function() return tonumber(fightCharacter:getCellId()) == c end, 1500, 50) then
                dire("placement Rat Noir (rang " .. rang .. ") : case " .. c .. " (Rat Noir a " .. L[k].dr .. ", monstre le plus proche a " .. L[k].dm .. ")")
                return
            end
            dire("placement Rat Noir : case " .. c .. " refusee (prise ?), suivante")
        end
    end
    dire("placement Rat Noir (rang " .. rang .. ") : AUCUNE case acceptee, reste en " .. tostring(ici)
        .. " (Rat Noir a " .. tostring(rnCase and d(ici, rnCase) or "?") .. ")")
end
function abandonnerCombatManquant()
    alerte("membre manquant au placement -> ABANDON du combat (ContextQuitRequest)")
    pcall(function() developer:sendMessage(developer:createMessage("ContextQuitRequest")) end)
end
function placementLoinDesMonstres(nosCases, leursCases)
    local ennemis = {}
    for c, id in pairs(leursCases or {}) do if tonumber(id) and tonumber(id) ~= -1 then ennemis[#ennemis + 1] = tonumber(c) end end
    if #ennemis == 0 then return end
    if carte() == SALLE_RAT_NOIR or (rnPresent and rnPresent()) then
        local ok, err = pcall(placementRatNoir, nosCases, ennemis)
        if ok then return end
        alerte("placement Rat Noir : " .. tostring(err))
    end
    local ici = tonumber(sur(function() return fightCharacter:getCellId() end, -1))
    local best, bestD = nil, -1
    for k, id in pairs(nosCases or {}) do
        local c = tonumber(k)
        if c and (tonumber(id) == -1 or c == ici) then
            local m = 99
            for _, e in ipairs(ennemis) do m = math.min(m, tonumber(sur(function() return fightAction:getDistance(c, e) end, 99)) or 99) end
            if m > bestD then best, bestD = c, m end
        end
    end
    if best and best ~= ici then
        pcall(function() fightAction:chooseCell(best) end)
        dire("placement loin des monstres : case " .. best .. " (monstre le plus proche a " .. bestD .. ")")
    end
end
function fightManagementPosition(challengers, defenders)
    local ok, err = pcall(fightManagementPositionCorps, challengers, defenders)
    if not ok then pcall(function() dire("placement : erreur ignoree (" .. tostring(err):sub(1, 120) .. ")") end) end
end

SALLES_REGEN_BOSS = {}
SALLES_TOFU = { ["96209926"] = true, ["96211980"] = true }
function quitterDonjonUneFois()
    local jeton = QUITTER_DONJON_UNE_FOIS
    if jeton == nil or jeton == "" or lireEtat("QUIT_" .. jeton) == "1" then return nil end
    ecrireEtat("QUIT_" .. jeton, 1)
    local dedans = false
    for _, x in ipairs(ETAPES) do
        for _, d in ipairs(x.donjon or {}) do if d.map ~= "*" and estSur(d.map) then dedans = true end end
    end
    if not dedans then return nil end
    ETAT_ETAPE.n = nil
    dire("sortie unique du donjon (" .. jeton .. ") -> DungeonQuitRequest, on refait l etape")
    return { { map = carte(), custom = function()
        local ici = carte()
        pcall(function() global:leaveDialog() end)
        pcall(function() developer:sendMessage(developer:createMessage("DungeonQuitRequest")) end)
        attendre(function() return carte() ~= ici end, 8000)
    end } }
end
function configSalleTofu()
    local dedans = SALLES_TOFU[carte()] == true
    if dedans and CONFIG_IA ~= true then
        dire("salle du Tofu Royal : configs IA + Fluctuation (enfermer le boss, epees, Attirance)")
        pcall(function() character:getSpellVariant(12763) end)
        CONFIG_IA = nil configIA(true)
        ecrireEtat("CONFIG_TOFU", 1)
    elseif not dedans and lireEtat("CONFIG_TOFU") == "1" then
        dire("sortie de la salle du Tofu Royal : configs normales + Transposition")
        pcall(function() character:getSpellVariant(12736) end)
        CONFIG_IA = nil configIA(false)
        ecrireEtat("CONFIG_TOFU", 0)
    end
end
function combatsDonjonSolo(actions, idxAvant)
    if type(actions) ~= "table" then return actions end
    local aCombat = false
    for _, x in ipairs(actions) do if x.fight or x.forcefight then aCombat = true end end
    if not aCombat then return actions end
    local ici = carte()
    local idxApres = ETAT_ETAPE.idx
    if trouSansLeader() then
        if TROU_DIT ~= ici then TROU_DIT = ici dire("trou " .. ici .. " sans le leader : combat contre le gardien pour remonter") end
        if not estLeader() and lireEtat("RESTAT_TERRE") ~= "1" then
            ETAT_ETAPE.idx, DERNIERE_ACTION = idxAvant, nil
            return { { map = ici, custom = function() restatTerre() end } }
        end
        local presents, lanceur = {}, nil
        local carteChef = carteDe(comptesEquipe()[1])
        for i, a in ipairs(comptesEquipe()) do
            local m = tostring(carteDe(a))
            if i > 1 and m ~= carteChef then
                presents[#presents + 1] = a
                if lanceur == nil then lanceur = a end
            end
        end
        local function tousLibres()
            for _, a in ipairs(presents) do
                if sur(function() return a.character:isInFight() end, false) or carteDe(a) ~= ici then return false end
            end
            return true
        end
        ETAT_ETAPE.idx, DERNIERE_ACTION = idxAvant, nil
        if lanceur ~= nil and idDe(lanceur) == moiId() then
            if tousLibres() and os.time() - (TROU_PRET or 0) >= 3 and TROU_PRET ~= nil then
                TROU_PRET = nil
                ETAT_ETAPE.idx, DERNIERE_ACTION = idxApres, actions[1]
                dire("trou : " .. #presents .. " present(s) -> je lance le gardien, les autres rejoignent")
                return actions
            end
            return { { map = ici, custom = function()
                attendre(tousLibres, 60000, 300)
                TROU_PRET = TROU_PRET or os.time()
                attendre(function() return false end, 3000, 300)
            end } }
        end
        return { { map = ici, custom = function()
            attendreEnEcoutant(function() autoPretAJour() return enCombat() or carte() ~= ici end, 60000, NOMS_INVITATION)
        end } }
    end
    local quatre = quatreEnCours()
    if quatre and not estLeader() and (coteDeRang(monRang()) == 2 or trouSansLeader()) then
        local gChef = tonumber(lireMem("RS_PARTY_" .. idDe(comptesEquipe()[1])))
        local inconnu = monGroupe() == nil and QUATRE_SORTIE_FORCEE ~= ici
        if inconnu then QUATRE_SORTIE_FORCEE = ici end
        if inconnu or (gChef ~= nil and monGroupe() == gChef) then
            dire("salle 4x4 " .. ici .. " : je quitte le groupe du leader (chef de mon cote : " .. sur(function() return chefDuCote(coteDeRang(monRang())).character:name() end, "?") .. ")")
            quitterMonGroupe()
            ecrireMem("RS_PARTY_" .. moiId(), "")
            INVIT_ACCEPTEE, AUTOPRET_FAIT = false, false
        end
        QUATRE_QUITTE = true
    end
    if estLeader() or (quatre and suisChefDeCote()) then
        local pret = equipePrete()
        if pret and quatre then
            PRET_DEPUIS = (PRET_CARTE == ici and PRET_DEPUIS) or os.time()
            PRET_CARTE = ici
            pret = os.time() - PRET_DEPUIS >= 2
        elseif not pret then
            PRET_CARTE = nil
        end
        if pret then PRET_CARTE = nil LANCEMENT = { carte = ici, t = os.time(), quatre = quatre } return actions end
        ETAT_ETAPE.idx, DERNIERE_ACTION = idxAvant, nil
        return { { map = ici, custom = function()
            if not attendre(function() reinviterAbsents() return equipePrete() end, 60000, 200) then
                local absents = {}
                for i, a in ipairs(comptesEquipe()) do
                    if i > 1 and carteDe(a) ~= ici then absents[#absents + 1] = sur(function() return a.character:name() end, "?") .. "@" .. carteDe(a) end
                end
                alerte("salle " .. ici .. " : j attends encore " .. table.concat(absents, ", "))
            end
        end } }
    end
    local chef = quatre and chefDuCote(coteDeRang(monRang())) or comptesEquipe()[1]
    local chefParti = nil
    local function rangDans(c)
        local e = ETAPES[ETAT_ETAPE.n or 0]
        local l = e and e[ETAT_ETAPE.phase or ""] or nil
        if type(l) ~= "table" then return nil end
        for i, x in ipairs(l) do if tostring(x.map) == tostring(c) then return i end end
        return nil
    end
    local function chefAilleurs()
        if carteDe(chef) == ici or sur(function() return chef.character:isInFight() end, false) then chefParti = nil return false end
        local rc, rm = rangDans(carteDe(chef)), rangDans(ici)
        if rc == nil or rm == nil or rc <= rm then chefParti = nil return false end
        chefParti = chefParti or os.time()
        return os.time() - chefParti > 120
    end
    ETAT_ETAPE.idx, DERNIERE_ACTION = idxAvant, nil
    if CHEF_PARTI_SALLE == ici then
        CHEF_PARTI_SALLE = nil
        alerte("salle " .. ici .. " : le chef n est pas avec moi (" .. tostring(carteDe(chef)) .. ") -> J ATTENDS, pas de combat seul")
    end
    return { { map = ici, custom = function()
        autoPretAJour()
        local chefEnCombatDepuis = nil
        attendreEnEcoutant(function()
            autoPretAJour()
            if not enCombat() and carteDe(chef) == ici and sur(function() return chef.character:isInFight() end, false) then
                chefEnCombatDepuis = chefEnCombatDepuis or os.time()
                if os.time() - chefEnCombatDepuis >= 5 and tostring(lireMem("RS_PARTY_" .. moiId()) or "") ~= "" then
                    dire("le chef combat sans moi -> je ne suis pas dans son groupe : je quitte et j attends l invitation")
                    ecrireMem("RS_PARTY_" .. moiId(), "")
                    quitterMonGroupe()
                    INVIT_ACCEPTEE, AUTOPRET_FAIT = false, false
                end
            else
                chefEnCombatDepuis = nil
            end
            return enCombat() or carte() ~= ici or chefAilleurs()
        end, 180000, NOMS_INVITATION)
        if not enCombat() and carte() == ici and chefAilleurs() then CHEF_PARTI_SALLE = ici end
    end } }
end
function attenteRegenMansot(actions, idxAvant)
    if true then return actions end
    if type(actions) ~= "table" then return actions end
    local aCombat = false
    for _, x in ipairs(actions) do if x.fight or x.forcefight then aCombat = true end end
    if not aCombat then return actions end
    local ici = carte()
    if ici == SALLE_MANSOT or SALLES_REGEN_BOSS[ici] then
        local function pct(ch)
            local v = tonumber(sur(function() return ch:lifePoints() end, 0)) or 0
            local m = tonumber(sur(function() return ch:maxLifePoints() end, 1)) or 1
            return m > 0 and v / m or 1
        end
        local function prets()
            if estLeader() then
                for _, a in ipairs(comptesEquipe()) do
                    if carteDe(a) == ici and pct(a.character) < 0.99 then return false end
                end
                return true
            end
            return pct(character) >= 0.99
        end
        if not prets() then
            ETAT_ETAPE.idx, DERNIERE_ACTION = idxAvant, nil
            return { { map = ici, enveloppe = true, custom = function()
                if BLOCAGE then BLOCAGE.n, BLOCAGE.essais = 0, 0 end
                dire("boss : attente de 100 % de PV avant le combat (" .. math.floor(pct(character) * 100) .. " %)")
                attendre(function() return prets() or enCombat() end, 20000, 1000)
            end } }
        end
    end
    return actions
end
function move()
    local actions = moveInterne()
    pcall(publierActionLeader, actions)
    return envelopper(filtrerPourMule(actions))
end
SALLE_KOULOSSE = "107227136"
local function restatLeader(sagesseVoulue, vitaVoulue)
    local function pts() return tonumber(sur(function() return character:statsPoint() end, 0)) or 0 end
    local function attendreChange(avant) attendre(function() return pts() ~= avant end, 3000, 150) end
    local avant = pts()
    envoyerPaquetBrut("reinitialiserCaracteristiques", {}, "restat")
    attendre(function() return pts() > avant end, 8000, 200)
    for _ = 1, 12 do
        local manque = (sagesseVoulue or 0) - (tonumber(sur(function() return character:getWisdomBase() end, 0)) or 0)
        if manque <= 0 or pts() <= 0 then break end
        local p = pts() pcall(function() character:upgradeWisdom(math.min(p, manque)) end) attendreChange(p)
    end
    if (vitaVoulue or 0) > 0 and pts() > 0 then
        local p = pts() pcall(function() character:upgradeVitality(math.min(p, vitaVoulue)) end) attendreChange(p)
    end
    local r = pts()
    if r > 0 then pcall(function() character:upgradeStrenght(r) end) attendreChange(r) end
    if pts() == r and r > 0 then pcall(function() character:upgradeStrength(r) end) end
    dire("restat leader : sagesse " .. tostring(sur(function() return character:getWisdomBase() end, "?"))
        .. ", vitalite " .. tostring(sur(function() return character:getVitalityBase() end, "?"))
        .. ", force " .. tostring(sur(function() return character:getStrenghtBase() end, "?")))
end
SALLE_RAT_NOIR = "218894336"
function variantesRatNoir(entree)
    local ids
    if entree then
        ids = estLeader() and { 12763, 12762, 12735, 12756, 12746, 12731, 12732 }
            or { 12762, 12736, 12756, 12735, 12728, 12727, 12745 }
    else
        ids = estLeader() and { 12736, 12737 } or { 12737 }
    end
    for _, id in ipairs(ids) do pcall(function() character:getSpellVariant(id) end) end
    dire("salle du Rat Noir : variantes " .. (entree and "prises" or "rendues") .. " (" .. table.concat(ids, ", ") .. ")")
end
function configSalleRatNoir()
    local dedans = carte() == SALLE_RAT_NOIR
    if dedans and CONFIG_IA ~= true then
        dire("salle du Rat Noir : configs IA + variantes de fuite (IA v2)")
        CONFIG_IA = nil configIA(true)
        pcall(variantesRatNoir, true)
        ecrireEtat("CONFIG_RATNOIR", 1)
    elseif not dedans and lireEtat("CONFIG_RATNOIR") == "1" then
        dire("sortie de la salle du Rat Noir : configs normales + Transposition / Mutilation")
        CONFIG_IA = nil configIA(false)
        pcall(variantesRatNoir, false)
        ecrireEtat("CONFIG_RATNOIR", 0)
    end
    if not estLeader() and not enCombat() and lireEtat("RESTAT_RN") == "1" then
        restatMule(VITA_CIBLE_RUN or 300)
        ecrireEtat("RESTAT_RN", 0)
    end
end
function restatMule(vita)
    local function pts() return tonumber(sur(function() return character:statsPoint() end, 0)) or 0 end
    local avant = pts()
    envoyerPaquetBrut("reinitialiserCaracteristiques", {}, "restat")
    attendre(function() return pts() > avant end, 8000, 200)
    local p = pts()
    if p > 0 then pcall(function() character:upgradeVitality(math.min(p, vita)) end) attendre(function() return pts() ~= p end, 3000, 100) end
    local r = pts()
    if r > 0 then pcall(function() character:upgradeChance(r) end) attendre(function() return pts() ~= r end, 3000, 100) end
    dire("restat mule : vitalite " .. tostring(sur(function() return character:getVitalityBase() end, "?"))
        .. ", chance " .. tostring(sur(function() return character:getChanceBase() end, "?")))
end
SALLE_ROYALMOUTH = "55053312"
function configSalleRoyalmouth()
    local dedans = carte() == SALLE_ROYALMOUTH or (rmGroupeSurCarte and rmGroupeSurCarte()) == true
    if dedans and CONFIG_IA ~= true then
        dire("salle du Royalmouth : configs IA + variante Aversion (poussee nette)")
        if (tonumber(sur(function() return character:level() end, 0)) or 0) >= 135 then
            pcall(function() character:getSpellVariant(RM_AVERSION or 12749) end)
        end
        CONFIG_IA = nil configIA(true)
        ecrireEtat("CONFIG_ROYALMOUTH", 1)
    elseif not dedans and lireEtat("CONFIG_ROYALMOUTH") == "1" then
        dire("sortie de la salle du Royalmouth : configs normales")
        CONFIG_IA = nil configIA(false)
        ecrireEtat("CONFIG_ROYALMOUTH", 0)
    end
end
SALLE_MANSOT = "56102912"
function banned() end
function moveInterne()
    battement()
    if enCombat() then return nil end
    if not INIT then initialiser() end
    local lm = RELEVE_FINI and "hors" or larvesMode()
    if lm == "pilote" or lm == "attente" or lm == "repos" or lm == "stop" or lm == "veille" then
        if estLeader() then effacerMem(cleEquipe() .. "AVANCE") end
        return { { map = carte(), custom = bouclePilotee, enveloppe = true } }
    end
    if lm == "sortirHors" and carte() == LARVES_D.SORTIE then
        return { { map = carte(), door = tostring(LARVES_D.PORTE_FIN) } }
    end
    if lm == "sortir" or lm == "sortirHors" then
        return { { map = carte(), custom = sortirDuDonjonLarves, enveloppe = true } }
    end
    if lm == "fin" then
        local r = finLarves()
        if r ~= nil then return r end
    end
    if lm == "libre" then
        pcall(publierVuLarves, "libre")
        if LV_SUCCES_GEN ~= lvGen() then
            LV_SUCCES_GEN = lvGen()
            pcall(lireLesSucces)
            pcall(publierSuccesLarves)
        end
        if estLeader() and lvGen() > 0 then effacerMem(cleEquipe() .. "AVANCE") end
    end
    pcall(configSalleKoulosse)
    pcall(reequiperBuildLeader)
    if estLeader() then
        local av = tostring(lireMem(cleEquipe() .. "AVANCE") or "")
        local depuis, vers, idx = av:match("^(%d+):(%d+):(%d+)$")
        depuis, vers, idx = tonumber(depuis), tonumber(vers), tonumber(idx)
        if depuis ~= nil then
            local em = ETAPES[vers]
            if em == nil or etapeEquipe() ~= depuis then
                effacerMem(cleEquipe() .. "AVANCE")
            elseif not estSur(tostring(em.entree.carte)) then
                local sauve = ETAT_ETAPE
                ETAT_ETAPE = { n = vers, phase = "aller", idx = idx }
                local liste = em.aller or { { map = tostring(em.entree.carte) } }
                if liste[1] ~= nil and liste[1].map ~= "*" then
                    local l2 = { { map = "*", path = "havenbag" } }
                    for _, x in ipairs(liste) do l2[#l2 + 1] = x end
                    liste = l2
                end
                local acts = marcher(liste)
                local nidx = ETAT_ETAPE.idx
                ETAT_ETAPE = sauve
                ecrireMem(cleEquipe() .. "AVANCE", depuis .. ":" .. vers .. ":" .. nidx)
                if acts ~= nil then return acts end
            else
                return { { map = carte(), custom = function()
                    dire("avance : devant le gardien de l etape " .. vers .. ", j attends que les mules finissent l etape " .. depuis)
                    attendre(function() return mulesOntFini(depuis) end, ATTENTE_EQUIPE_MS * 5, 500)
                    if mulesOntFini(depuis) then
                        deciderEtapeEquipe()
                        effacerMem(cleEquipe() .. "AVANCE")
                    end
                end } }
            end
        end
    end
    if carte() == "192415750" and not (ETAT_ETAPE and ETAT_ETAPE.phase == "banque" and not BANQUE_FAITE) then
        return { { map = "192415750", path = "424" } }
    end
    local eCroca = ETAPES[(ETAT_ETAPE and ETAT_ETAPE.n) or 0]
    local runCroca = eCroca ~= nil and eCroca.cle == "donjons_crocabulia"
    if not runCroca then
        local ee = ETAPES[tonumber(sur(function() return etapeEquipe() end, 0)) or 0]
        runCroca = ee ~= nil and ee.cle == "donjons_crocabulia"
    end
    if carte() == "198972418" and not runCroca then
        return { { map = carte(), custom = function()
            dire("salle de sortie du Croca : PNJ 789 (sortir)")
            pcall(function() npc:npc(789, 3) end)
            pcall(function() npc:reply(-1) end)
            attendre(function() return carte() ~= "198972418" end, 5000, 100)
            if carte() == "198972418" then pcall(function() global:restartScript(false) end) end
        end } }
    end
    if enGroupe() and not estLeader() then
        local chef = comptesEquipe()[1]
        local carteChef = carteDe(chef)
        if carteChef ~= "" and carteChef ~= carte() and not (CB_dansBibliotheque and CB_dansBibliotheque())
            and not (MINO_dansLabyrinthe and MINO_dansLabyrinthe())
            and not sur(function() return chef.character:isInFight() end, false) then
            local ici = carte()
            return { { map = ici, custom = function() attendre(function() return carte() ~= ici end, 5000, 200) end } }
        end
    end
    if (estLeader() or not enGroupe()) and ETAT_ETAPE.phase ~= "donjon" and not larvesEnCours() then
        local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end
    end
    if RELEVE_FINI then pcall(function() global:finishScript() end) return nil end
    if not estLeader() then autoPretAJour() end
    pcall(reinviterAbsents)
    if remettreCoiffeEtCape ~= nil and not enCombat() and (RHABILLAGES or 0) < 5
        and os.time() - (DERNIER_RHABILLAGE or 0) >= 60
        and not sur(function() return character:isBusy() end, false) then
        local vide = function(p)
            local occupe = false
            pcall(function() for _, it in ipairs(inventory:inventoryContent()) do if tonumber(it.Position) == p then occupe = true end end end)
            return not occupe
        end
        if (besoinRhabillage ~= nil and besoinRhabillage()) or vide(6) or vide(7) then
            DERNIER_RHABILLAGE, RHABILLAGES = os.time(), (RHABILLAGES or 0) + 1
            pcall(remettreCoiffeEtCape)
        end
    end
    if not enGroupe() then
        local q = quitterDonjonUneFois()
        if q ~= nil then return q end
    end
    local n = etapeEquipe()
    if n == nil then
        if estLeader() then
            n = deciderEtapeEquipe()
            if n == nil then
                local ici = carte()
                return { { map = ici, custom = function() attendre(function() return false end, 15000, 500) end } }
            end
        else
            local ici = carte()
            return { { map = ici, custom = function()
                attendre(function() return etapeEquipe() ~= nil end, 30000, 300)
            end } }
        end
    end
    if not enGroupe() then
        for k, x in ipairs(ETAPES) do
            if k ~= n and x.donjon ~= nil and #x.donjon > 0 then
                local derniere = x.donjon[#x.donjon]
                local entreeX = x.entree ~= nil and tostring(x.entree.carte) or nil
                for _, d in ipairs(x.donjon) do
                    if d.map ~= "*" and d.map ~= entreeX and d.path == nil and estSur(d.map) then
                        if d == derniere and derniere.custom ~= nil then
                            dire("encore dans le donjon de l etape " .. k .. " -> sortie par son PNJ")
                            return { { map = carte(), custom = derniere.custom } }
                        end
                        dire("encore dans le donjon de l etape " .. k .. " -> sortie (DungeonQuitRequest)")
                        return { { map = carte(), custom = function()
                            local ici = carte()
                            pcall(function() developer:sendMessage(developer:createMessage("DungeonQuitRequest")) end)
                            attendre(function() return carte() ~= ici end, 5000)
                        end } }
                    end
                end
            end
        end
    end
    if n > #ETAPES then
        if estLeader() and #ETAPES >= 30 and #comptesEquipe() >= 2 then
            ecrireMem(cleEquipe() .. "FINI", 1)
            dire("RUN TERMINEE")
            return nil
        end
        alerte("etape " .. tostring(n) .. " > " .. tostring(#ETAPES) .. " etapes chargees : PAS de fin de run (seul le leader conclut) -> attente")
        local ici = carte()
        return { { map = ici, custom = function() attendre(function() return false end, 15000, 500) end } }
    end
    local e = ETAPES[n]
    e.n = n
    if ETAT_ETAPE.n ~= n then
        ETAT_ETAPE.n = n
        DERNIERE_ACTION = nil
        local p = phaseApplicable(e, "quete") and "quete" or phaseSuivante(e, "quete")
        if e.donjon ~= nil then
            local surEntree = e.entree ~= nil and estSur(e.entree.carte)
            for _, x in ipairs(e.donjon) do if not surEntree and x.map ~= "*" and estSur(x.map) then p = "donjon" end end
            if not surEntree and type(e.dansDonjon) == "function" and sur(e.dansDonjon, false) == true then p = "donjon" end
        end
        if p ~= "donjon" and e.entree ~= nil and estSur(e.entree.carte) and (p == "quete" or p == "aller") and not phaseApplicable(e, "quete") then p = "entree" end
        if p ~= "donjon" and (estLeader() or not enGroupe()) then
            local trop, qui, pc = surcharge()
            if trop then
                dire(tostring(qui) .. " a " .. tostring(pc) .. " % de pods -> depot a la banque avant l etape " .. n)
                BANQUE_FAITE = false
                changerPhase("banque")
                return marcher(BANQUE_TRAJET)
            end
        end
        changerPhase(p)
    end
    local cScara = tonumber(carte()) or 0
    local djTerre = donjonTerreIci(cScara)
    local dansScara = djTerre ~= nil
    local rangScara = tonumber(sur(function() return monRang() end, 0)) or 0
    if djTerre and not estLeader() and not enCombat() and djTerre.rangs[rangScara]
       and lireEtat("RESTAT_TERRE") ~= "1" then
        local c = tostring(carte())
        return { { map = c, custom = function()
            ecrireEtat("TERRE_DONJON", 1)
            restatTerre()
            CONFIG_IA = nil
            if (SC_SALLES and SC_SALLES[c]) or (EL_SALLES and EL_SALLES[c]) then
                configIA(true)
                ecrireEtat("CONFIG_SCARA", 1)
            end
            pcall(function() character:getSpellVariant(12735) end)
            pcall(function() character:getSpellVariant(12744) end)
            dire(djTerre.nom .. " : rang " .. rangScara .. " en TERRE (" .. djTerre.raison .. ")")
        end } }
    end
    if not estLeader() and not enCombat() and lireEtat("RESTAT_TERRE") == "1" and MULES_TERRE ~= true and not dansScara then
        local c = tostring(carte())
        if c == "106960896" or c == "106961920" or not c:match("^1069") then
            return { { map = c, custom = function() restatEauRetour() end } }
        end
    end
    if QUATRE_QUITTE and not enCombat() and not quatreEnCours() then
        QUATRE_QUITTE = false
        local gChef = tonumber(lireMem("RS_PARTY_" .. idDe(comptesEquipe()[1])))
        if monGroupe() ~= nil and monGroupe() ~= gChef then
            dire("salle 4x4 finie : je quitte le groupe du cote 2 -> retour dans le groupe du leader")
            quitterMonGroupe()
            ecrireMem("RS_PARTY_" .. moiId(), "")
            INVIT_ACCEPTEE, AUTOPRET_FAIT = false, false
        end
    end
    if e.cle == "larves" and larvesMode() == "libre" and besoinOeufLarve ~= nil and besoinOeufLarve() then
        local c = carte()
        if c == "191102976" then
            return { { map = c, custom = function() acheterOeufLarve() end, path = "havenbag" } }
        elseif c == tostring(CARTE_HAVRE_SAC) then
            return { { map = c, path = "zaap(191105026)" } }
        end
        local d = tonumber(sur(function() return map:GetPathDistance(tonumber(c), 191102976) end, 99)) or 99
        if d <= 8 then
            return { { map = c, custom = function() avancerVers(191102976) end } }
        end
        return { { map = c, path = "havenbag" } }
    end
    if e.donjon ~= nil and ETAT_ETAPE.phase ~= "donjon" and ETAT_ETAPE.phase ~= "apres" and ETAT_ETAPE.phase ~= "fini" then
        local surEntree = e.entree ~= nil and estSur(e.entree.carte)
        for _, x in ipairs(e.donjon) do
            if not surEntree and x.map ~= "*" and estSur(x.map) then changerPhase("donjon") break end
        end
        if ETAT_ETAPE.phase ~= "donjon" and not surEntree and type(e.dansDonjon) == "function" and sur(e.dansDonjon, false) == true then
            changerPhase("donjon")
        end
    end
    if type(e.detour) == "function" then
        local d = sur(e.detour, nil)
        if d ~= nil then return d end
    end
    local phase = ETAT_ETAPE.phase
    if phase == "banque" then
        local actions = (not BANQUE_FAITE) and marcher(BANQUE_TRAJET) or nil
        if actions ~= nil then return actions end
        ETAT_ETAPE.n = nil
        return moveInterne()
    end
    if phase == "donjon" and e.donjon ~= nil and lireEtat("FAIT_" .. e.cle) ~= "1" then
        for _, x in ipairs(e.donjon) do
            if x.barriere and x.map ~= "*" and estSur(x.map) and not (e.entree ~= nil and tostring(e.entree.carte) == tostring(x.map)) then
                ecrireEtat("FAIT_" .. e.cle, 1)
                if e.quete ~= nil then ecrireEtat("QUETE_" .. e.cle, 1) end
                dire("etape " .. e.n .. " : carte de sortie " .. x.map .. " (apres le boss) -> etape marquee faite")
                break
            end
        end
    end
    if phase == "fini" then
        return { { map = carte(), custom = function() finirEtape(e) end } }
    end
    local enDonjon = (phase == "donjon" or phase == "apres" or phase == "fini")
        or (phase == "entree" and e.entree ~= nil and equipeSur(e.entree.carte))
    if enGroupe() and estLeader() and not enDonjon and not equipeSur(carte()) then
        local ici = carte()
        return { { map = ici, custom = function() attendre(function() return equipeSur(carte()) end, 20000, 300) end } }
    end
    if enGroupe() and estLeader() and donjonSolo(e) then
        enDonjon = false
    end
    if enGroupe() and estLeader() and not enDonjon then
        ecrireMem(cleEquipe() .. "DEMANDE", "solo:" .. n)
        dire("etape " .. n .. " (" .. phase .. ") : hors donjon -> solo + groupe en jeu (degroupage demande)")
        return { { map = carte(), custom = function() attendre(function() return false end, ATTENTE_EQUIPE_MS * 5, 500) end } }
    end
    if phase == "entree" or (phase == "aller" and muleAttendTp(e)) then
        if phase == "aller" then changerPhase("entree") end
        return phaseEntree(e)
    end
    local liste = e[phase]
    local idxAvant = ETAT_ETAPE.idx
    local actions = marcher(liste)
    if actions ~= nil and phase == "donjon" then actions = attenteRegenMansot(actions, idxAvant) end
    if actions ~= nil and (phase == "donjon" or phase == "quete" or phase == "aller") and donjonSolo(e) and not enGroupe() then
        actions = combatsDonjonSolo(actions, idxAvant)
    end
    if actions == nil then
        if phase == "quete" then
            if enGroupe() and estLeader() then
                for _, a in ipairs(comptesEquipe()) do ecrireEtatDe(idDe(a), "QUETE_" .. e.cle, 1) end
            else
                ecrireEtat("QUETE_" .. e.cle, 1)
            end
        end
        changerPhase(phaseSuivante(e, phase))
        return moveInterne()
    end
    return actions
end
function bank() return {} end
function configSalleMansot()
    local dedans = carte() == SALLE_MANSOT
    if dedans and CONFIG_IA ~= true then
        dire("salle du Mansot Royal : configs IA + variante Perfusion (soin en melee du boss)")
        if not estLeader() and lireEtat("MANSOT_VITA") ~= "200" then
            dire("salle du Mansot Royal : restat mule 200 vitalite + chance")
            restatMule(200)
            ecrireEtat("MANSOT_VITA", "200")
        end
        if estLeader() then
            pcall(function() character:getSpellVariant(12735) end)
            pcall(function() character:getSpellVariant(12744) end)
        else
            pcall(function() character:getSpellVariant(12758) end)
        end
        CONFIG_IA = nil configIA(true)
        ecrireEtat("CONFIG_MANSOT", 1)
    elseif not dedans and lireEtat("CONFIG_MANSOT") == "1" then
        dire("sortie de la salle du Mansot Royal : configs normales + Attirance")
        if not estLeader() and (lireEtat("MANSOT_VITA") == "1" or lireEtat("MANSOT_VITA") == "200") then
            pcall(restatEauRetour)
            ecrireEtat("MANSOT_VITA", 0)
        end
        pcall(function() character:getSpellVariant(12735) end)
        CONFIG_IA = nil configIA(false)
        ecrireEtat("CONFIG_MANSOT", 0)
    end
end
function configSalleKoulosse()
    pcall(configSalleScara)
    pcall(configSalleRatNoir)
    pcall(configSalleRoyalmouth)
    pcall(configSalleMansot)
    pcall(configSalleTofu)
    local dedans = carte() == SALLE_KOULOSSE
    local actif = lireEtat("CONFIG_KOULOSSE") == "1"
    if dedans and actif and CONFIG_IA ~= true then
        CONFIG_IA = nil configIA(true)
        pcall(variantesKoulosse)
    end
    if dedans and not actif then
        dire("salle du Koulosse : configs IA" .. (estLeader() and " + restat 200 sagesse / force" or ""))
        CONFIG_IA = nil configIA(true)
        pcall(variantesKoulosse)
        pcall(reequiperToutSalle)
        if estLeader() then restatLeader(300, 2000) end
        ecrireEtat("CONFIG_KOULOSSE", 1)
    elseif not dedans and actif then
        dire("sortie de la salle du Koulosse : configs normales" .. (estLeader() and " + restat 650 vitalite / force" or ""))
        CONFIG_IA = nil configIA(false)
        if estLeader() then restatLeader(0, 650) end
        ecrireEtat("CONFIG_KOULOSSE", 0)
    end
end
function reequiperToutSalle()
    local L = estLeader()
        and { { 8262, 0 }, { 16169, 1 }, { 8263, 2 }, { 13851, 3 }, { 8470, 4 }, { 8471, 5 }, { 8847, 6 }, { 8265, 7 },
              { 33044, 8 }, { 737, 9 }, { 694, 10 }, { 17078, 11 }, { 12724, 12 }, { 13759, 13 }, { 13829, 14 }, { 18686, 15 } }
        or { { 8465, 0 }, { 250, 1 }, { 8466, 2 }, { 8468, 3 }, { 1499, 4 }, { 8467, 5 }, { 8463, 6 }, { 8464, 7 },
             { 972, 10 }, { 34615, 12 }, { 18687, 15 } }
    for _, b in ipairs(L) do
        local g, p = b[1], b[2]
        local n = tonumber(sur(function() return inventory:itemCount(g) end, 0)) or 0
        local pos = tonumber(sur(function() return inventory:itemPosition(g) end, -1)) or -1
        if n > 0 or pos >= 0 then
            if g == 33044 then
                pcall(function() inventory:equipItem(g, 63) end)
                attendre(function() return tonumber(sur(function() return inventory:itemPosition(g) end, -1)) == 63 end, 600, 50)
            end
            pcall(function() inventory:equipItem(g, p) end)
            attendre(function() return tonumber(sur(function() return inventory:itemPosition(g) end, -1)) == p end, 400, 50)
        end
    end
    dire("salle du Koulosse : build reequipe (" .. #L .. " objets)")
end
function phenix() return {} end
function variantesKoulosse()
    local ids = estLeader()
        and { 12732, 12746, 12725, 12731, 12729, 12761, 12737, 12744, 12735 }
        or { 12728, 12727, 12745, 12761, 12737, 12744, 12735 }
    for _, id in ipairs(ids) do pcall(function() character:getSpellVariant(id) end) end
    dire("salle du Koulosse : variantes de l IA prises (" .. #ids .. ")")
end
function configSalleScara()
    local c = tostring(carte())
    local dedans = (EL_SALLES ~= nil and EL_SALLES[c] ~= nil) or (SC_SALLES ~= nil and SC_SALLES[c] == true)
    if dedans and CONFIG_IA ~= true then
        local dj = (EL_SALLES and EL_SALLES[c]) or "scara"
        dire((dj == "kwakwa" and "Nid du Kwakwa" or dj == "blops" and "Clos des Blops" or "Scarafeuilles")
            .. (dj == "blops" and " : configs IA + variantes (aucun sort de zone sur un allie, sans changement d element)"
                or " : configs IA + variantes (jamais un monstre immunise, zones sans allie)"))
        local vars = (estLeader() or lireEtat("RESTAT_TERRE") == "1") and VARIANTES_LEADER or VARIANTES_EAU
        for _, id in ipairs(vars) do pcall(function() character:getSpellVariant(id) end) end
        for _, id in ipairs({ 12735, 12744 }) do pcall(function() character:getSpellVariant(id) end) end
        CONFIG_IA = nil configIA(true)
        ecrireEtat("CONFIG_SCARA", 1)
    elseif not dedans and lireEtat("CONFIG_SCARA") == "1" then
        dire("sortie des salles Scarafeuilles / Kwakwa / Blops : configs normales")
        CONFIG_IA = nil configIA(false)
        ecrireEtat("CONFIG_SCARA", 0)
    end
end
function stopped() end

pcall(function() ecouterLeviers() end)

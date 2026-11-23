
DOSSIER = DOSSIER or global:getCurrentScriptDirectory()
SCRIPT_RUN = "Run_Sacri.lua"
SCRIPT_PL = "pl\\pl-croca.lua"
SCRIPT_DEPART = "pl\\depart-mule.lua"
SCRIPT_ZAAP = "pl\\all-zaap.lua"
SCRIPT_CROCA = "pl\\vers-croca.lua"
SCRIPT_DEPOT = "pl\\depot-banque.lua"
SCRIPT_REJOINDRE = "pl\\rejoindre.lua"
SCRIPT_PREPA_RUN = "outils\\prepa-run.lua"
SCRIPT_SORTIE_CROCA = "pl\\sortie-croca.lua"
SEUIL_PODS = 85
CIBLE_PREMIER_PERSO = 120
CIBLE_AUTRES_PERSOS = 120
CARTES_CROCA = { ["198967296"] = true, ["198968320"] = true, ["198969344"] = true, ["198970368"] = true,
                 ["198971392"] = true, ["198972416"] = true, ["198972418"] = true }
ENTREE_LARVES = "96993793"
SORTIE_LARVES = "96998919"
CYCLE_MS = 500
RELANCES_PAR_HEURE = 3
ATTENTE_CONNEXION_MS = 30000
pcall(function() dofile(DOSSIER .. "\\Settings.lua") end)
function log(m) global:printSuccess("[CTRL] " .. tostring(m)) end
function enCombat(a) return sur(function() return a.character:isInFight() end, false) end
function niveauDe(a) return tonumber(sur(function() return a.character:level() end, 0)) or 0 end
function joueReel(a) return sur(function() return a:isScriptPlaying() end, false) end
function sur(f, d) local ok, v = pcall(f); if ok and v ~= nil then return v end; return d end
function nomDe(a) return sur(function() return a:getUsername() end, nil) end
function chemin(rel) return DOSSIER .. "\\" .. rel end
function mem(cle) return sur(function() return developer:getInGlobalMemory(cle) end, nil) end
function frais(n) return sur(function() return ankabotController:getAccount(n) end, nil) end
function joue(a)
    if joueReel(a) then return true end
    local n = nomDe(a)
    return n ~= nil and LANCEMENTS ~= nil and LANCEMENTS[n] ~= nil
end
function fichierExiste(c)
    local f = io.open(c, "r")
    if f == nil then return false end
    f:close()
    return true
end
function attendre(cond, maxMs, pas)
    pas = pas or 200
    local t = 0
    while t <= maxMs do
        local ok, r = pcall(cond)
        if ok and r then return true end
        global:delay(pas); t = t + pas
    end
    return false
end
function idDe(a) return tostring(sur(function() return a.character:id() end, "")) end
function mapDe(a) return tostring(sur(function() return a.map:currentMapId() end, "")) end
function connecte(a) return sur(function() return a:isAccountFullyConnected() end, false) end
function memEcrire(cle, v)
    pcall(function()
        if developer:getInGlobalMemory(cle) ~= nil then developer:editInGlobalMemory(cle, tostring(v))
        else developer:addInGlobalMemory(cle, tostring(v)) end
    end)
end

EQUIPES = EQUIPES or {}
function equipePausee(eq)
    if _G ~= nil and _G["PAUSE_SACRI_" .. tostring(eq.nomChef)] == true then return true end
    return tostring(mem("PAUSE_SACRI_" .. tostring(eq.nomChef))) == "1"
end
function tousConnectes(eq)
    for _, n in ipairs(eq.noms) do
        local a = frais(n)
        if a == nil or not connecte(a) or mapDe(a) == "" or mapDe(a) == "0" then return false end
    end
    return true
end
function arreterScripts(eq)
    for _, a in ipairs(comptes(eq)) do pcall(function() a:stopScript() end) end
    for _, n in ipairs(eq.noms) do if LANCEMENTS ~= nil then LANCEMENTS[n] = nil end end
end

function cleActive(cle, eq)
    if tostring(mem(cle)) == "1" then return true end
    return eq ~= nil and tostring(mem(cle .. "_" .. tostring(eq.nomChef))) == "1"
end
function publierEquipe(eq)
    local liste = table.concat(eq.noms, ",")
    for _, n in ipairs(eq.noms) do memEcrire("RS_EQUIPE_DE_" .. n, liste) end
end
function detecterEquipes()

    if type(TEAMS) == "table" and #TEAMS > 0 then
        for _, t in ipairs(TEAMS) do
            local n = t.chef
            if n ~= nil and EQUIPES[n] == nil then
                local noms = { n }
                for _, nm in ipairs(t.mules or {}) do
                    if nm ~= nil and nm ~= n and tostring(sur(function() return developer:getInGlobalMemory("RS_EXCLU_" .. nm) end, "") or "") ~= "1" then noms[#noms + 1] = nm end
                end
                EQUIPES[n] = { nomChef = n, noms = noms, etat = "analyse", mode = "equipe", relances = {}, passeurSolo = true, explicite = true }
                log("equipe configuree (Settings) : chef " .. n .. " + " .. (#noms - 1) .. " mule(s)")
            end
        end
        return
    end

    for _, a in ipairs(sur(function() return ankabotController:getLoadedAccounts() end, {})) do
        local chef = sur(function() return a:isItATeam() and a:isTeamLeader() end, false)
        local n = nomDe(a)
        if chef and n ~= nil and EQUIPES[n] == nil then
            local noms = { n }
            for _, m in ipairs(sur(function() return a:getTeamAccounts() end, {})) do
                local nm = nomDe(m)
                if nm ~= nil and nm ~= n and tostring(sur(function() return developer:getInGlobalMemory("RS_EXCLU_" .. nm) end, "") or "") ~= "1" then noms[#noms + 1] = nm end
            end
            EQUIPES[n] = { nomChef = n, noms = noms, etat = "analyse", mode = "equipe", relances = {}, passeurSolo = true }
            log("equipe detectee : chef " .. n .. " + " .. (#noms - 1) .. " mule(s)")
        end
    end
end
function chef(eq) return frais(eq.nomChef) end
function verifierTransition(eq)
    local T = eq.transition
    if T == nil then return false end
    local ok = tousConnectes(eq)
    if not ok and os.time() < T.fin then return true end
    if not ok then
        if T.mode == "solo" then log(eq.nomChef .. " : connexion solo incomplete apres " .. (ATTENTE_CONNEXION_MS / 1000) .. " s")
        else log(eq.nomChef .. " : connexion de l equipe incomplete apres " .. (ATTENTE_CONNEXION_MS / 1000) .. " s") end
    end
    if T.mode == "equipe" then arreterScripts(eq) end
    eq.mode = T.mode
    eq.transition = nil
    if T.suite == "tous_run" then lancerTous(comptes(eq), SCRIPT_RUN)
    elseif T.suite == "chef_run" then lancer(chef(eq), SCRIPT_RUN) end
    return false
end
function passerEnEquipe(eq, suite)
    log(eq.nomChef .. " : regroupement en EQUIPE")
    arreterScripts(eq)
    deconnecterAvantDecharger(eq)
    for _, n in ipairs(eq.noms) do pcall(function() ankabotController:unloadAccountByUsername(n) end) end
    pcall(function() ankabotController:loadTeamAccount(eq.noms, eq.nomChef, true) end)
    eq.transition = { mode = "equipe", fin = os.time() + ATTENTE_CONNEXION_MS / 1000, suite = suite }
end
function mules(eq)
    local l = {}
    for i, n in ipairs(eq.noms) do
        if i > 1 then local a = frais(n) if a ~= nil then l[#l + 1] = a end end
    end
    return l
end
function comptes(eq)
    local l = {}
    for _, n in ipairs(eq.noms) do
        local a = frais(n)
        if a ~= nil then l[#l + 1] = a end
    end
    return l
end
function relanceAutorisee(eq, nom)
    if cleActive("RS_PAUSE_RELANCE", eq) then return false end
    local maintenant = os.time()
    local recentes, miennes = {}, 0
    for _, t in ipairs(eq.relances) do
        local quand, qui = t, nil
        if type(t) == "table" then quand, qui = t[1], t[2] end
        if maintenant - quand < 3600 then
            recentes[#recentes + 1] = t
            if qui == nom then miennes = miennes + 1 end
        end
    end
    eq.relances = recentes
    if nom ~= nil then return miennes < RELANCES_PAR_HEURE * 3 end
    return #recentes < RELANCES_PAR_HEURE * 8
end
function passerEnSolo(eq, suite)
    log(eq.nomChef .. " : passage en SOLO (" .. #eq.noms .. " comptes, en parallele)")
    publierEquipe(eq)
    arreterScripts(eq)
    deconnecterAvantDecharger(eq)
    for _, n in ipairs(eq.noms) do pcall(function() ankabotController:unloadAccountByUsername(n) end) end
    for _, n in ipairs(eq.noms) do pcall(function() ankabotController:loadAccount(n, true) end) end
    eq.transition = { mode = "solo", fin = os.time() + ATTENTE_CONNEXION_MS / 1000, suite = suite }
end
function deconnecterAvantDecharger(eq)
    for _, a in ipairs(comptes(eq)) do pcall(function() a:disconnect() end) end
    attendre(function()
        for _, a in ipairs(comptes(eq)) do
            if connecte(a) or sur(function() return a:isAccountConnected() end, false) then return false end
        end
        return true
    end, 8000, 200)
end

LANCEMENTS = LANCEMENTS or {}
function demarrageVu(liste, ms)
    local t = 0
    while true do
        local tous = true
        for _, a in ipairs(liste) do if not joueReel(a) then tous = false break end end
        if tous then return true end
        if t >= ms then return false end
        global:delay(50); t = t + 50
    end
end
function lancerTous(liste, rel)
    for _, a in ipairs(liste) do pcall(function() a:loadScript(chemin(rel)) end) end
    for _, a in ipairs(liste) do pcall(function() a:startScript() end) end
    demarrageVu(liste, 1000)
    for _, a in ipairs(liste) do if not joueReel(a) then inscrireLancement(a, rel, 15, 1) end end
end
function lancer(a, rel)
    if a == nil then return false end
    pcall(function() a:loadScript(chemin(rel)) end)
    pcall(function() a:startScript() end)
    if demarrageVu({ a }, 1000) then return true end
    inscrireLancement(a, rel, 10, 2)
    return true
end
function verifierLancements()
    for n, L in pairs(LANCEMENTS) do
        local a = frais(n)
        if a == nil or joueReel(a) then LANCEMENTS[n] = nil
        elseif os.time() - L.t >= L.delai then
            if L.essais < L.essaisMax then
                L.essais, L.t = L.essais + 1, os.time()
                pcall(function() a:loadScript(chemin(L.rel)) end)
                pcall(function() a:startScript() end)
            else
                LANCEMENTS[n] = nil
            end
        end
    end
end
function inscrireLancement(a, rel, delai, essaisMax)
    local n = nomDe(a)
    if n ~= nil then LANCEMENTS[n] = { rel = rel, t = os.time(), delai = delai, essais = 1, essaisMax = essaisMax } end
end

NB_PERSOS_FICHIER = NB_PERSOS_FICHIER or {}
function kitRecu(a)
    return tostring(mem("RS_SASA_OK_" .. idDe(a))) == "1"
end
function journal(qui, symptome, cause, correctif)
    pcall(function()
        local f = io.open(DOSSIER .. "\\JOURNAL-BLOCAGES.md", "a")
        if f == nil then return end
        local function net(s) return (tostring(s or ""):gsub("|", "/"):gsub("[\r\n]", " ")) end
        local quand = "?"
        pcall(function() quand = os.date("%d/%m %H:%M") end)
        f:write("| " .. quand .. " | " .. net(symptome) .. " | " .. net(cause) .. " | " .. net(correctif)
            .. " | automatique (controller, " .. net(qui) .. ") |\n")
        f:close()
    end)
end
function lireNbPersos(a)
    local id = idDe(a)
    if mem("RS_NB_PERSOS_" .. id) ~= nil then return end

    if cycPersos ~= nil then
        local l = cycPersos(a)
        local avecClasse, nbSacri = false, 0
        for _, p in ipairs(l or {}) do
            if p.classe ~= nil then avecClasse = true end
            if p.classe == 11 then nbSacri = nbSacri + 1 end
        end
        if avecClasse then
            if nbSacri > 0 then memEcrire("RS_NB_PERSOS_" .. id, nbSacri) end
            return
        end
    end
    local liste = sur(function() return a.global:charactersList() end, nil)
    local n = 0
    pcall(function() for _ in ipairs(liste) do n = n + 1 end end)
    if n == 0 then pcall(function() n = liste.Count or 0 end) end
    if n == 0 then pcall(function() n = #liste.Characters end) end
    if n > 0 then memEcrire("RS_NB_PERSOS_" .. id, n) end
end
function groupeEclate(eq)
    local c = nil
    for _, a in ipairs(comptes(eq)) do
        if connecte(a) then
            local m = mapDe(a)
            if c == nil then c = m elseif m ~= c then return true end
        end
    end
    return false
end
function auCroca(a) return CARTES_CROCA[mapDe(a)] == true or dansSalleCroca(a) end
function cibleDe(a)
    local id = idDe(a)
    local nb = tonumber(mem("RS_NB_PERSOS_" .. id))
    if nb == nil then
        nb = nbPersosFichier(id)
        if nb ~= nil then memEcrire("RS_NB_PERSOS_" .. id, nb) end
    end
    if nb == nil and tostring(mem("RS_PREMIER_PERSO_" .. id)) ~= "1" and niveauDe(a) >= CIBLE_AUTRES_PERSOS then nb = 2 end
    nbPersosSauver(id, nb)
    local premier = tostring(mem("RS_PREMIER_PERSO_" .. id)) == "1" or nb == nil or nb <= 1
    local cible = premier and CIBLE_PREMIER_PERSO or CIBLE_AUTRES_PERSOS
    memEcrire("RS_CIBLE_PL_" .. id, cible)
    return cible
end
function dansSalleCroca(a) local m = tonumber(mapDe(a)) or 0 return m >= 198968000 and m <= 198972999 end
function nbPersosFichier(id)
    local v = nil
    pcall(function()
        local f = io.open(DOSSIER .. "\\etat\\nb_persos_" .. id .. ".txt", "r")
        if f then v = tonumber((f:read("*a") or ""):match("%d+")) f:close() end
    end)
    return v
end
function nbPersosSauver(id, nb)
    if nb == nil or NB_PERSOS_FICHIER[id] == nb then return end
    pcall(function()
        local f = io.open(DOSSIER .. "\\etat\\nb_persos_" .. id .. ".txt", "w")
        if f then f:write(tostring(nb)) f:close() NB_PERSOS_FICHIER[id] = nb end
    end)
end
function zaapFait(a)
    local id = idDe(a)
    return tostring(mem("RS_ZAAP_FAIT_" .. id)) == "1" or fichierExiste(chemin("etat\\zaap_" .. id .. ".txt"))
        or fichierExiste(chemin("etat\\zaap_compte_" .. tostring(nomDe(a)) .. ".txt"))
end


BREED_SACRI = 11
ATTENTE_SANS_PERSO_S = ATTENTE_SANS_PERSO_S or 45
function sacrisDe(liste)
    local l = {}
    for _, p in ipairs(liste or {}) do if p.classe == BREED_SACRI then l[#l + 1] = p end end
    return l
end
function creaTs() return math.floor(tonumber((tostring(os.time()):gsub(",", "."))) or 0) end
function classeDe(a) return tonumber(sur(function() return a.character:breed() end, 0)) or 0 end
function aUnPerso(a) local id = idDe(a) return id ~= "" and id ~= "0" end


FICHIER_COMPTES_SACRI = DOSSIER .. "\\comptes-sacri-connus.txt"
COMPTES_SACRI = nil
function compteSacriNoter(n, quoi)
    comptesSacriCharger()
    local k = tostring(n):lower()
    if COMPTES_SACRI[k] then return end
    COMPTES_SACRI[k] = true
    pcall(function()
        local f = io.open(FICHIER_COMPTES_SACRI, "a")
        if f then f:write(tostring(n) .. "|" .. tostring(quoi or "") .. "\n") f:close() end
    end)
end
function compteSacriConnu(n)
    comptesSacriCharger()
    local k = tostring(n):lower()
    if COMPTES_SACRI[k] then return true end
    if tostring(mem("RS_CREA_V2_" .. n) or "") ~= "" or fichierExiste(chemin("etat\\zaap_compte_" .. tostring(n) .. ".txt")) then
        COMPTES_SACRI[k] = true
        return true
    end
    return false
end
function comptesSacriCharger()
    if COMPTES_SACRI ~= nil then return end
    COMPTES_SACRI = {}
    pcall(function()
        local f = io.open(FICHIER_COMPTES_SACRI, "r")
        if f then
            for l in f:lines() do l = (l or ""):gsub("[\r\n]", ""):match("^([^|]+)") if l and l ~= "" then COMPTES_SACRI[l:lower()] = true end end
            f:close()
        end
    end)
end
function planCreation(eq, n, a)
    local liste = cycPersos and cycPersos(a) or nil
    if aUnPerso(a) then
        if not connecte(a) then return nil end
        local classe = classeDe(a)
        if classe == BREED_SACRI or classe == 0 then return nil end

        local meilleur = nil
        for _, p in ipairs(sacrisDe(liste)) do
            if p.nom ~= nil and (meilleur == nil or (p.niveau or 0) > (meilleur.niveau or 0)) then meilleur = p end
        end
        if meilleur ~= nil then
            return { action = "choisir", nom = meilleur.nom, raison = "perso actif de classe " .. classe .. ", Sacrieur " .. meilleur.nom .. " sur le compte" }
        end
        return { action = "creer", raison = "perso actif de classe " .. classe .. ", aucun Sacrieur sur le compte"
            .. (liste == nil and " (liste illisible)" or "") }
    end
    if liste ~= nil and #liste == 0 then return { action = "creer", vide = true, raison = "aucun personnage sur le compte" } end
    if connecte(a) then return nil end
    eq.sansPerso[n] = eq.sansPerso[n] or creaTs()
    if creaTs() - eq.sansPerso[n] < ATTENTE_SANS_PERSO_S then return nil end

    if liste == nil then return nil end
    local s = sacrisDe(liste)
    if #s > 0 and s[1].nom ~= nil then
        return { action = "choisir", nom = s[1].nom, raison = "aucun perso actif, Sacrieur " .. s[1].nom .. " sur le compte" }
    end
    if #liste > 0 then return nil end
    return { action = "creer", vide = true, raison = "aucun personnage actif depuis " .. ATTENTE_SANS_PERSO_S .. " s" }
end
function creerSurCompteVide(n)
    local coul = COULEURS_A_CREER or {}
    local texte = type(coul) == "table" and table.concat(coul, ",") or tostring(coul)
    for _, cc in ipairs({ coul, texte }) do
        local ok, r = pcall(function() return ankabotController:createCharacter(n, SERVEUR, BREED_SACRI, false, 0, cc) end)
        if ok and r ~= false then return true end
    end
    log("ALERTE " .. n .. " : createCharacter refuse (compte vide)")
    return false
end
function creationInitiale(eq)
    eq.crea = eq.crea or {}
    eq.sansPerso = eq.sansPerso or {}
    local enCours = false
    for _, n in ipairs(eq.noms) do
        local a = frais(n)
        local c = eq.crea[n]

        if a ~= nil and c == nil and connecte(a) and aUnPerso(a) and classeDe(a) == BREED_SACRI then
            compteSacriNoter(n, tostring(sur(function() return a.character:name() end, "")))
        end
        if a ~= nil and c == nil and not compteSacriConnu(n) then
            if aUnPerso(a) then eq.sansPerso[n] = nil end
            local plan = planCreation(eq, n, a)
            if plan ~= nil then
                if tostring(SERVEUR or "") == "" or SERVEUR == "NomDuServeur" then
                    if not eq.sansPerso["alerte_" .. n] then
                        eq.sansPerso["alerte_" .. n] = true
                        log("ALERTE " .. eq.nomChef .. " : " .. n .. " : " .. plan.raison .. ", mais SERVEUR non renseigne dans Settings.lua (creation impossible)")
                    end
                else
                    log(eq.nomChef .. " : " .. n .. " : " .. plan.raison .. " -> "
                        .. (plan.action == "creer" and ("creation d'un Sacrieur sur " .. SERVEUR) or ("connexion du Sacrieur " .. plan.nom)))
                    pcall(function() a:stopScript() end)
                    pcall(function() a:disconnect() end)
                    c = { s = "deco", t = creaTs(), plan = plan, ancienId = idDe(a) }
                    eq.crea[n] = c
                end
            end
        end
        if a ~= nil and c ~= nil and c.s ~= "fini" then
            enCours = true
            if c.s == "deco" then
                local enLigne = connecte(a) or sur(function() return a:isAccountConnected() end, false)
                if not enLigne or creaTs() - c.t > 45 then
                    pcall(function() a:forceServer(SERVEUR) end)
                    local ok = true
                    if c.plan.action == "creer" and c.plan.vide then

                        ok = creerSurCompteVide(n)
                        if not ok then pcall(function() ok = (a:forceCreate(BREED_SACRI, false, 0, COULEURS_A_CREER) ~= false) end) end
                    elseif c.plan.action == "creer" then
                        ok = false
                        pcall(function() ok = (a:forceCreate(BREED_SACRI, false, 0, COULEURS_A_CREER) ~= false) end)
                    else
                        pcall(function() a:forceChoose(c.plan.nom) end)
                    end
                    if not ok then
                        log("ALERTE " .. eq.nomChef .. " : " .. n .. " : forceCreate refuse (creation a faire a la main)")
                        memEcrire("RS_CREA_V2_" .. n, "echec")
                        compteSacriNoter(n, "echec")
                        c.s = "fini"
                    else
                        pcall(function() a:connect() end)
                        c.s, c.t = "connexion", creaTs()
                    end
                end
            elseif c.s == "connexion" then
                if connecte(a) and aUnPerso(a) and classeDe(a) == BREED_SACRI and idDe(a) ~= c.ancienId then
                    local id = idDe(a)
                    log(eq.nomChef .. " : " .. n .. " : Sacrieur " .. (c.plan.action == "creer" and "cree" or "connecte")
                        .. " (" .. tostring(sur(function() return a.character:name() end, "?")) .. ")")
                    memEcrire("RS_CREA_V2_" .. n, 1)
                    compteSacriNoter(n, c.plan.action)
                    if c.plan.action == "creer" then

                        memEcrire("RS_PREMIER_PERSO_" .. id, 1)
                        memEcrire("RS_NB_PERSOS_" .. id, 1)
                        nbPersosSauver(id, 1)
                    end
                    c.s = "fini"
                elseif creaTs() - c.t > 300 then
                    log("ALERTE " .. eq.nomChef .. " : " .. n .. " : pas de Sacrieur actif 300 s apres "
                        .. (c.plan.action == "creer" and "la creation" or "le choix") .. " (verifier la console du compte)")
                    memEcrire("RS_CREA_V2_" .. n, "echec")
                    compteSacriNoter(n, "echec")
                    c.s = "fini"
                end
            end
        end
    end
    if enCours then
        for _, c in pairs(eq.crea) do if c.s ~= "fini" then return true end end

        pcall(function() ankabotController:clearCreations() end)
        eq.crea = {}
        if eq.explicite then passerEnEquipe(eq) end
        return true
    end
    return false
end

BANQUE_DERNIER = BANQUE_DERNIER or 0
function podsDe(a) return tonumber(sur(function() return a.inventory:podsP() end, 0)) or 0 end
function releve(eq)
    if eq.mode ~= "solo" then return passerEnSolo(eq) end
    if eq.releveLance == nil then
        for _, n in ipairs(eq.noms) do memEcrire("RS_RELEVE_" .. n, 1); memEcrire("RS_RELEVE_FAIT_" .. n, 0) end
        log(eq.nomChef .. " : releve des succes et de la progression (solo)")
        lancerTous(comptes(eq), SCRIPT_RUN)
        eq.releveLance = os.time()
    end
    local tous = true
    for _, n in ipairs(eq.noms) do if (tonumber(mem("RS_RELEVE_FAIT_" .. n)) or 0) == 0 then tous = false end end
    if tous or os.time() - eq.releveLance > 150 then
        for _, n in ipairs(eq.noms) do memEcrire("RS_RELEVE_" .. n, 0) end
        arreterScripts(eq)
        eq.releveFait = true
        for i, a in ipairs(comptes(eq)) do
            local xml = (i == 1) and "xml\\SACRI CROCA 650 VITA0FORCE.xml" or "xml\\sacri-eau.xml"
            pcall(function() a:loadConfig(chemin(xml)) end)
        end
        log(eq.nomChef .. " : releve " .. (tous and "complet" or "incomplet (delai depasse)"))
        if eq.passeurSolo then lancerTous(comptes(eq), SCRIPT_RUN); eq.runLance = true end
    end
end
function stuffRun(eq)
    if eq.mode ~= "solo" then return passerEnSolo(eq) end
    local cle = "RS_STUFF_RUN_" .. eq.nomChef
    if tostring(mem(cle) or "") ~= "encours" then
        for i, n in ipairs(eq.noms) do
            if i > 1 then
                memEcrire("RS_PREPA_RUN_" .. n, 0)
                memEcrire("RS_PREPA_ROLE_" .. n, "mule")
                local a = frais(n)
                local id = a ~= nil and idDe(a) or ""
                if id ~= "" and id ~= "0" then memEcrire("RS_PREPA_COFFRE_" .. id, "") end
            end
        end
        memEcrire(cle, "encours")
        eq.prepaLance, eq.prepaAlerte = {}, {}
        log(eq.nomChef .. " : fin de PL -> reprise du stuff de run au coffre (" .. (#eq.noms - 1) .. " mule(s), solo)")
    end
    eq.prepaLance, eq.prepaAlerte = eq.prepaLance or {}, eq.prepaAlerte or {}
    local reste = 0
    for i, n in ipairs(eq.noms) do
        if i > 1 then
            local etat = tostring(mem("RS_PREPA_RUN_" .. n) or "")
            local a = frais(n)
            if etat ~= "1" then
                reste = reste + 1
                if etat == "echec" then
                    if not eq.prepaAlerte[n] then
                        eq.prepaAlerte[n] = true
                        log("ALERTE " .. eq.nomChef .. " : " .. n .. " prepa-run en ECHEC (coffre) -> intervention ; mettre RS_PREPA_RUN_"
                            .. n .. " = 1 une fois le stuff de run repris")
                        journal(eq.nomChef, n .. " : stuff de run non repris (prepa-run echec)", "coffre non ouvert ou deja tente",
                            "intervention : reprendre le stuff au coffre puis RS_PREPA_RUN_" .. n .. " = 1")
                    end
                elseif a ~= nil and not connecte(a) then
                    pcall(function() a:connect() end)
                elseif a ~= nil and not joue(a) and not enCombat(a) then
                    if not eq.prepaLance[n] or relanceAutorisee(eq, n) then
                        if eq.prepaLance[n] then eq.relances[#eq.relances + 1] = { os.time(), n } end
                        eq.prepaLance[n] = true
                        log(eq.nomChef .. " : " .. n .. " -> " .. SCRIPT_PREPA_RUN)
                        lancer(a, SCRIPT_PREPA_RUN)
                    end
                end
            end
        end
    end
    if reste == 0 then
        memEcrire(cle, 1)
        log(eq.nomChef .. " : stuff de run repris par toutes les mules -> analyse")
        eq.etat = "analyse"
    end
end
function banqueConfiguree()
    return tostring(COMPTE_BANQUE or "") ~= "" and COMPTE_BANQUE ~= "compte-banque@exemple.com"
end
function assurerBanque()
    if tostring(COMPTE_BANQUE or "") == "" or COMPTE_BANQUE == "compte-banque@exemple.com" then return end
    local besoin = false
    for _, eq in pairs(EQUIPES or {}) do
        if eq.etat == "preparation" or eq.etat == "analyse" then
            for _, a in ipairs(mules(eq)) do
                if idDe(a) ~= "" and not kitRecu(a) and niveauDe(a) < cibleDe(a) then besoin = true end
            end
        end
        if eq.etat == "preparation" then
            for _, a in ipairs(comptes(eq)) do
                if idDe(a) ~= "" and clefsDe(a) == 0 then besoin = true end
            end
        end
    end
    if not besoin then return end
    if creaTs() - BANQUE_DERNIER < 30 then return end
    local b = frais(COMPTE_BANQUE)
    if b == nil then
        BANQUE_DERNIER = creaTs()
        log("compte banque " .. COMPTE_BANQUE .. " non charge -> chargement (kits des mules)")
        pcall(function() ankabotController:loadAccount(COMPTE_BANQUE, true) end)
    elseif not connecte(b) then
        BANQUE_DERNIER = creaTs()
        log("compte banque " .. COMPTE_BANQUE .. " deconnecte -> connexion (kits des mules)")
        pcall(function() b:connect() end)
    elseif not joue(b) then
        BANQUE_DERNIER = creaTs()
        log("compte banque inactif -> pl\\banque-sasa.lua (kits des mules)")
        lancer(b, "pl\\banque-sasa.lua")
    end
end
function pl(eq)
    if eq.mode ~= "equipe" then return passerEnEquipe(eq) end
    local c = chef(eq)
    if c == nil then return end
    for _, a in ipairs(mules(eq)) do cibleDe(a) end
    local fini = true
    for _, a in ipairs(mules(eq)) do if niveauDe(a) < cibleDe(a) then fini = false end end
    if fini or tostring(mem("RS_PL_FINI_" .. idDe(c))) == "1" then
        memEcrire("RS_PL_FINI_" .. idDe(c), 0)
        arreterScripts(eq)
        memEcrire("RS_STUFF_RUN_" .. eq.nomChef, "afaire")
        log(eq.nomChef .. " : PL termine (stuff de run a reprendre au coffre)")
        eq.etat = "analyse"
        return
    end
    local trop, dehors = nil, true
    for _, a in ipairs(comptes(eq)) do
        if podsDe(a) >= SEUIL_PODS then trop = nomDe(a) end
        if enCombat(a) then dehors = false end
    end
    if trop ~= nil and dehors then
        log(eq.nomChef .. " : " .. trop .. " au-dessus de " .. SEUIL_PODS .. " % de pods -> depot en banque, puis retour au Croca")
        arreterScripts(eq)
        eq.plLance = false
        eq.etat = "preparation"
        return
    end
    eq.clefsVues = eq.clefsVues or {}
    local sansClef = nil
    for _, a in ipairs(comptes(eq)) do
        if connecte(a) then
            local k = tonumber(sur(function() return a.inventory:itemCount(8342) end, nil))
            if k ~= nil then eq.clefsVues[nomDe(a)] = k end
        end
        if eq.clefsVues[nomDe(a)] == 0 and not enCombat(a) and not dansSalleCroca(a) then sansClef = nomDe(a) end
    end
    if sansClef ~= nil and banqueConfiguree() then

        log(eq.nomChef .. " : " .. sansClef .. " n a plus de clef du Croca -> passage au compte banque pour des clefs, puis retour au Croca")
        arreterScripts(eq)
        eq.clefsVues = {}
        eq.plLance = false
        eq.etat = "preparation"
        return
    end
    if sansClef ~= nil then
        log(eq.nomChef .. " : " .. sansClef .. " n a plus de clef du Croca -> PL arrete, equipe en attente (attente_clefs)")
        journal(eq.nomChef, "plus de clef du Croca (" .. sansClef .. ")", "80 clefs par perso consommees avant le niveau cible",
            "PL arrete, etat attente_clefs : reapprovisionner en clefs ou baisser la cible, puis RS_CTRL_RAZ_<chef> = 1")
        arreterScripts(eq)
        eq.etat = "attente_clefs"
        return
    end
    local combat = false
    for _, a in ipairs(comptes(eq)) do if enCombat(a) then combat = true end end
    if not combat and groupeEclate(eq) then
        eq.eclateDepuis = eq.eclateDepuis or os.time()
        if os.time() - eq.eclateDepuis >= 60 then
            log(eq.nomChef .. " : groupe eclate dans le Croca -> sortie de tous et regroupement a l entree")
            journal(eq.nomChef, "groupe eclate au Croca", "membres sur des cartes differentes (depot, reconnexion, progression enregistree)",
                "sortie de tous (pl/sortie-croca.lua) puis regroupement a l entree")
            eq.eclateDepuis = nil
            arreterScripts(eq)
            eq.plLance = false
            eq.etat = "preparation"
            return
        end
    else
        eq.eclateDepuis = nil
    end
    if not joue(c) and not enCombat(c) then
        if eq.plLance and not relanceAutorisee(eq) then return end
        if eq.plLance then eq.relances[#eq.relances + 1] = os.time() end
        eq.plLance = true
        log(eq.nomChef .. " : PL au Croca")
        lancer(c, SCRIPT_PL)
    end
end
function attenteLarves(eq, quoi, pourquoi)
    eq.larvesLogs = eq.larvesLogs or {}
    if os.time() - (eq.larvesLogs[quoi] or 0) >= 15 then
        eq.larvesLogs[quoi] = os.time()
        log("[LARVES] " .. quoi .. " : attente (" .. tostring(pourquoi) .. ")")
    end
end
function zaap(eq)
    if eq.mode ~= "solo" then return passerEnSolo(eq) end
    local reste = false
    for _, a in ipairs(comptes(eq)) do
        if not zaapFait(a) then
            reste = true
            if connecte(a) and not joue(a) and not enCombat(a) then
                eq.zaapRelances = eq.zaapRelances or {}
                local n = nomDe(a)
                local l = {}
                for _, t in ipairs(eq.zaapRelances[n] or {}) do if os.time() - t < 3600 then l[#l + 1] = t end end
                local pods = tonumber(sur(function() return a.inventory:podsP() end, 0)) or 0
                if pods >= SEUIL_PODS then
                    l = {}
                    log(eq.nomChef .. " : " .. n .. " a " .. pods .. " % de pods -> depot en banque avant ALL ZAAP")
                    lancer(a, SCRIPT_DEPOT)
                elseif #l < RELANCES_PAR_HEURE + 1 then
                    l[#l + 1] = os.time()
                    log(eq.nomChef .. " : " .. n .. " -> ALL ZAAP (" .. #l .. ")")
                    lancer(a, SCRIPT_ZAAP)
                elseif not (eq.zaapBloque or {})[n] then
                    eq.zaapBloque = eq.zaapBloque or {}
                    eq.zaapBloque[n] = true
                    log(eq.nomChef .. " : " .. n .. " ALL ZAAP arrete trop souvent -> en attente (intervention)")
                end
                eq.zaapRelances[n] = l
            end
        end
    end
    if not reste then eq.etat = "run" end
end
function prochainScriptPrep(a, estChef)
    if podsDe(a) >= SEUIL_PODS then return SCRIPT_DEPOT end
    if dansSalleCroca(a) then return SCRIPT_SORTIE_CROCA end

    if clefsDe(a) == 0 and banqueConfiguree() then
        memEcrire("RS_MODE_CLEFS_" .. idDe(a), (estChef or kitRecu(a)) and 1 or 0)
        return SCRIPT_DEPART
    end
    if auCroca(a) then return nil end
    if not estChef then
        if not kitRecu(a) and not zaapFait(a) then return SCRIPT_DEPART end
        if not zaapFait(a) then return SCRIPT_ZAAP end
    end
    return SCRIPT_CROCA
end
function nbGroupes(a)
    local v = sur(function() return a.map:monsterGroups() end, nil)
    if v == nil then return nil end
    local n = 0
    pcall(function() for _ in pairs(v) do n = n + 1 end end)
    return n
end
function run(eq)
    local c = chef(eq)
    if c == nil then return end
    if lvAActiver ~= nil and lvAActiver(eq) then
        eq.releveFait = true
        eq.etat = "larves"
        log(eq.nomChef .. " : etape des Larves -> pilotage v2 (tentatives, moities, reprise automatique)")
        return
    end
    if not eq.releveFait then return releve(eq) end
    local cle = "RS_" .. idDe(c) .. "_"
    if enCombat(c) or not joue(c) then
        eq.figeSig = nil
    elseif connecte(c) then
        local etape = tostring(mem(cle .. "ETAPE") or "")
        local sig = mapDe(c) .. "|" .. etape
        local lim = tonumber(FIGE_LEADER_S) or 180
        if eq.figeSig ~= sig then
            eq.figeSig, eq.figeDepuis, eq.figeRelance, eq.figeAlerte = sig, os.time(), false, false
        elseif os.time() - (eq.figeDepuis or os.time()) >= lim then
            if not eq.figeRelance then
                if relanceAutorisee(eq) then
                    eq.figeRelance, eq.figeDepuis = true, os.time()
                    eq.relances[#eq.relances + 1] = os.time()
                    log(eq.nomChef .. " : leader FIGE depuis " .. lim .. " s (carte " .. mapDe(c) .. ", etape " .. etape .. ") -> relance du script")
                    pcall(function() c:stopScript() end)
                    lancer(c, SCRIPT_RUN)
                    return
                end
            elseif not eq.figeAlerte then
                eq.figeAlerte = true
                log("ALERTE " .. eq.nomChef .. " : leader TOUJOURS FIGE apres relance (carte " .. mapDe(c) .. ", etape " .. etape .. ") -> intervention")
            end
        end
    end
    local demande = tostring(mem(cle .. "DEMANDE") or "")
    if demande:find("^solo") then
        memEcrire(cle .. "DEMANDE", "")
        log(eq.nomChef .. " : passeur (" .. demande .. ") -> degroupage")
        eq.passeurSolo = true
        passerEnSolo(eq, "tous_run")
        eq.runLance = true
        return
    end
    if demande:find("^equipe") and SOLO_PARTOUT then
        memEcrire(cle .. "DEMANDE", "")
        log(eq.nomChef .. " : regroupement demande (" .. demande .. ") ignore : run en solo partout")
        return
    end
    if demande:find("^equipe") then
        memEcrire(cle .. "DEMANDE", "")
        log(eq.nomChef .. " : mules teleportees (" .. demande .. ") -> regroupement")
        eq.passeurSolo = false
        passerEnEquipe(eq, "chef_run")
        eq.runLance = true
        return
    end
    if tostring(mem(cle .. "FINI")) == "1" then
        local nEt = #(ETAPES_FICHIERS or {})
        local eEq = tonumber(mem(cle .. "ETAPE")) or 0
        if nEt > 0 and eEq < nEt then
            log(eq.nomChef .. " : FINI ignore (etape d equipe " .. eEq .. "/" .. nEt .. ") -> cle remise a 0, la run continue")
            memEcrire(cle .. "FINI", 0)
            return
        end
        log(eq.nomChef .. " : RUN TERMINEE")
        eq.etat = "fini"
        return
    end
    if eq.mode == "solo" and not eq.passeurSolo then
        passerEnEquipe(eq, "chef_run")
        eq.runLance = true
        return
    end
    if eq.mode == "solo" then
        eq.arretSolo = eq.arretSolo or {}
        for _, a in ipairs(comptes(eq)) do
            local n = nomDe(a)
            if joue(a) or enCombat(a) then eq.arretSolo[n] = nil end
            if connecte(a) and not joue(a) and not enCombat(a) then
                eq.arretSolo[n] = eq.arretSolo[n] or os.time()
            end
            if connecte(a) and not joue(a) and not enCombat(a) and os.time() - eq.arretSolo[n] >= 6 and relanceAutorisee(eq, n)
                and not (EXCLUS_RELANCE or {})[n] then
                eq.arretSolo[n] = nil
                eq.relances[#eq.relances + 1] = { os.time(), n }
                log(eq.nomChef .. " : " .. nomDe(a) .. " arrete en solo -> relance")
                lancer(a, SCRIPT_RUN)
            end
        end
        return
    end
    local carteChef = mapDe(c)
    local loin, combat = {}, enCombat(c)
    for _, a in ipairs(mules(eq)) do
        if enCombat(a) then combat = true end
        if connecte(a) and mapDe(a) ~= carteChef then loin[#loin + 1] = a end
    end
    if #loin > 0 and not combat and carteChef ~= "" and eq.mode == "equipe" then
        eq.disperseDepuis = eq.disperseDepuis or os.time()
        if os.time() - eq.disperseDepuis >= 30 then
            eq.disperseDepuis = nil
            log(eq.nomChef .. " : " .. #loin .. " membre(s) sur une autre carte que le chef depuis 30 s -> solo pour que chacun finisse sa phase")
            eq.passeurSolo = true
            passerEnSolo(eq, "tous_run")
            return
        end
    else
        eq.disperseDepuis = nil
    end
    if joue(c) and not enCombat(c) then
        local vu = tonumber(mem("RS_VU_" .. eq.nomChef)) or 0
        if vu > 0 and os.time() - vu > 60 and relanceAutorisee(eq) then
            eq.relances[#eq.relances + 1] = os.time()
            log(eq.nomChef .. " : aucun signe de vie du script depuis " .. (os.time() - vu) .. " s -> relance")
            memEcrire("RS_VU_" .. eq.nomChef, os.time())
            pcall(function() c:stopScript() end)
            lancer(c, SCRIPT_RUN)
            return
        end
    end
    if joue(c) or enCombat(c) then eq.arretDepuis = nil end
    if not joue(c) and not enCombat(c) then
        eq.arretDepuis = eq.arretDepuis or os.time()
        if os.time() - eq.arretDepuis < 6 then return end
        eq.arretDepuis = nil
        if eq.runLance and not relanceAutorisee(eq) then return end
        if eq.runLance then
            eq.relances[#eq.relances + 1] = os.time()
            log(eq.nomChef .. " : script de run arrete -> relance (" .. #eq.relances .. "/" .. RELANCES_PAR_HEURE .. " cette heure)")
        end
        eq.runLance = true
        lancer(c, SCRIPT_RUN)
    end
end
function analyser(eq)
    if creationInitiale(eq) then return end
    if not tousConnectes(eq) then

        if eq.explicite and eq.transition == nil and os.time() - (eq.dernierRegroupement or 0) >= 180 then
            eq.dernierRegroupement = os.time()
            passerEnEquipe(eq)
        end
        return
    end
    local besoinPL, besoinPrep, besoinZaap = false, false, false
    for _, a in ipairs(mules(eq)) do
        lireNbPersos(a)
        local cible = cibleDe(a)
        if niveauDe(a) < cible and not PL_DESACTIVE then
            besoinPL = true
            if not auCroca(a) then besoinPrep = true end
        elseif not zaapFait(a) then
            besoinZaap = true
        end
        log(eq.nomChef .. " : " .. nomDe(a) .. " niveau " .. niveauDe(a) .. "/" .. cible
            .. (zaapFait(a) and "" or ", sans zaaps") .. (kitRecu(a) and "" or ", sans kit"))
    end
    if chef(eq) ~= nil and not zaapFait(chef(eq)) then
        besoinZaap = true
        log(eq.nomChef .. " : leader sans zaaps")
    end
    if besoinPL and groupeEclate(eq) then besoinPrep = true end
    if besoinPL and (besoinPrep or not auCroca(chef(eq))) then eq.etat = "preparation"
    elseif besoinPL then eq.etat = "pl"
    elseif tostring(mem("RS_STUFF_RUN_" .. eq.nomChef) or "") == "afaire"
        or tostring(mem("RS_STUFF_RUN_" .. eq.nomChef) or "") == "encours" then eq.etat = "stuff_run"
    elseif besoinZaap then eq.etat = "zaap"
    else eq.etat = "run" end
    log(eq.nomChef .. " -> " .. eq.etat)
end
function clefsDe(a)
    if not connecte(a) then return nil end
    return tonumber(sur(function() return a.inventory:itemCount(8342) end, nil))
end
function preparation(eq)
    if eq.mode ~= "solo" then return passerEnSolo(eq) end
    local tousLa = true
    for i, n in ipairs(eq.noms) do
        local a = frais(n)
        if a ~= nil and connecte(a) then
            local s = prochainScriptPrep(a, i == 1)
            if s ~= nil then
                tousLa = false
                if not joue(a) then
                    log(eq.nomChef .. " : " .. n .. " -> " .. s)
                    lancer(a, s)
                end
            end
        else
            tousLa = false
            if a ~= nil and not connecte(a) then pcall(function() a:connect() end) end
        end
    end
    if tousLa then
        passerEnEquipe(eq)
        eq.etat = "pl"
    end
end
function rejoindre(eq)
    if eq.mode ~= "solo" then return passerEnSolo(eq) end
    local cible = eq.carteRejoindre
    local reste = 0
    for _, a in ipairs(mules(eq)) do
        if mapDe(a) ~= cible then
            reste = reste + 1
            memEcrire("RS_REJOINDRE_" .. nomDe(a), cible)
            if connecte(a) and not joue(a) and not enCombat(a) then lancer(a, SCRIPT_REJOINDRE) end
        end
    end
    if reste == 0 then
        log(eq.nomChef .. " : equipe reunie sur " .. tostring(cible) .. " -> regroupement")
        passerEnEquipe(eq, "chef_run")
        eq.etat = "run"
    end
end

LARVES_D = nil
pcall(function() dofile(DOSSIER .. "\\lib\\larves_donnees.lua") end)
pcall(function() dofile(DOSSIER .. "\\etapes\\ordre.lua") end)
LARVES_N = nil
for i, f in ipairs(ETAPES_FICHIERS or {}) do if f == "13_larves.lua" then LARVES_N = i end end
if LARVES_D ~= nil then ENTREE_LARVES, SORTIE_LARVES = LARVES_D.ENTREE, LARVES_D.SORTIE end
TICK_OUV = 120
LV_ACTIVATION_MS = 150
LV_REPOS_MS = 6000
LV_FENETRE_MS = 9500
LV_MOTIF_VU = "^V2:(%d+):(%d+):(%d*):(%-?%d+):(%d):(%d+):(%d+):(%d+):(%a*)$"
LV_VERSION_SCRIPT_MIN = 3
function lvEquipeNative(eq)
    for _, a in ipairs(comptes(eq)) do if sur(function() return a:isItATeam() end, false) == true then return true end end
    return false
end
function lvT() return math.floor((tonumber((tostring(os.time()):gsub(",", "."))) or 0) * 1000) end
function lvEcrire(eq, cle, v) memEcrire(lvP(eq) .. cle, v) end
function lvP(eq) return "RSL_" .. tostring(eq.nomChef) .. "_" end
function lvNom(x) return tostring((x and (x.perso or x.n)) or "?") end
function lvTrouver(liste, n)
    for _, x in ipairs(liste or {}) do if x.n == n then return x end end
    return nil
end
function lvJournal(eq, symptome, cause, correctif)
    if LARVES_JOURNAL == false then return end
    pcall(function()
        local f = io.open(DOSSIER .. "\\JOURNAL-BLOCAGES.md", "a")
        if f == nil then return end
        local function net(s) return (tostring(s or ""):gsub("|", "/"):gsub("[\r\n]", " ")) end
        local quand = "?"
        pcall(function() quand = os.date("%d/%m %H:%M") end)
        f:write("| " .. quand .. " | " .. net(symptome) .. " | " .. net(cause) .. " | " .. net(correctif)
            .. " | automatique (Larves v2, equipe " .. net(eq.nomChef) .. ") |\n")
        f:close()
    end)
end
function lvNoms(l)
    local t = {}
    for _, x in ipairs(l or {}) do t[#t + 1] = lvNom(x) end
    return table.concat(t, ", ")
end
function lvDans(liste, v)
    for _, x in ipairs(liste or {}) do if x == v then return true end end
    return false
end
function lvActif()
    local t = lvS()
    if LV_ACTIF_LU == nil or t - LV_ACTIF_LU >= 5 then
        LV_ACTIF_LU = t
        pcall(function()
            local f = io.open(DOSSIER .. "\\Settings.lua", "r")
            if f == nil then return end
            local s = "\n" .. tostring(f:read("*a"))
            f:close()
            local v = s:match("\n[ \t]*LARVES_V2_ACTIF[ \t]*=[ \t]*(%a+)")
            if v ~= nil then LARVES_V2_ACTIF = (v == "true") end
        end)
    end
    return LARVES_V2_ACTIF == true and LARVES_D ~= nil
end
function lvMem(eq, cle) return tostring(mem(lvP(eq) .. cle) or "") end
function lvS() return math.floor(lvT() / 1000) end
function lvEtapeEquipe(eq)
    local id = lvIdLeader(eq)
    if id == "" then return nil end
    return tonumber(mem("RS_" .. id .. "_ETAPE"))
end
function lvLireGen(eq, cle)
    local g, v = lvMem(eq, cle):match("^(%d+):(.*)$")
    if g == nil or tonumber(g) ~= eq.lv.gen then return nil end
    return v
end
function lvIdLeader(eq)
    local id = idDe(chef(eq))
    if id ~= "" and id ~= "0" then
        if eq.idLeader ~= id then eq.idLeader = id ; memEcrire("RS_ID_LEADER_" .. eq.nomChef, id) end
        return id
    end
    if eq.idLeader ~= nil and eq.idLeader ~= "" then return eq.idLeader end
    for _, cle in ipairs({ "RS_ID_LEADER_", "RS_ID_" }) do
        local m = tostring(mem(cle .. eq.nomChef) or "")
        if m ~= "" and m ~= "0" then eq.idLeader = m return m end
    end
    return ""
end

LV_INDISPO_MIN = 10
function lvPreuveGroupeTexte(eq, X)
    if LARVES_PREUVE_TEXTE_GROUPE == false then return end
    for _, ch in ipairs(X) do
        if ch.chef and ch.co and not ch.perdu and ch.id ~= "" then
            local ref = tonumber(mem("RS_PARTY_" .. ch.id))
            local L = sur(function() return ch.a.global:consoleLines() end, nil)
            if ref ~= nil and type(L) == "table" then
                local n = #L
                local vu = eq.lv.consoleVu[ch.n]
                local debut = math.max(1, n - 9)
                if vu ~= nil then
                    for i = n, debut, -1 do if tostring(L[i]) == vu then debut = i + 1 break end end
                end
                for i = debut, n do
                    local l = tostring(L[i] or "")
                    if l:find("dans votre groupe", 1, true) and l:find("est d", 1, true) then
                        for _, x in ipairs(X) do
                            if x.cote == ch.cote and x.n ~= ch.n and x.id ~= "" and x.perso ~= nil and x.carte == ch.carte
                               and not x.combat and l:find(x.perso, 1, true) and tonumber(mem("RS_PARTY_" .. x.id)) ~= ref then
                                memEcrire("RS_PARTY_" .. x.id, ref)
                                log("[LARVES] " .. lvNom(x) .. " : « deja dans votre groupe » (serveur) -> groupe " .. ref .. " inscrit")
                            end
                        end
                    end
                end
                if n > 0 then eq.lv.consoleVu[ch.n] = tostring(L[n]) end
            end
        end
    end
end
function lvTireur(eq, Hh, actuel, dalle)
    local cur = lvTrouver(Hh, actuel)
    if cur ~= nil and ((cur.co and not cur.perdu) or #Hh == 1) then return actuel end
    local best, bestScore = nil, nil
    for _, x in ipairs(Hh) do
        if x.co and not x.perdu then
            local prio = (x.jetable and not x.chef) and 0 or ((not x.chef) and 1 or 2)
            local d = tonumber(sur(function() return x.a.map:cellDistance(x.cell, dalle) end, nil)) or 50
            local score = prio * 1000 + d
            if bestScore == nil or score < bestScore then best, bestScore = x.n, score end
        end
    end
    return best or actuel
end
function lvLire(eq, n, i)
    local x = { n = n, i = i, cote = (i <= 4) and 1 or 2, chef = (i == 1 or i == 5) }
    local a = frais(n)
    x.a = a
    x.co = a ~= nil and connecte(a) == true
    x.combat = a ~= nil and enCombat(a) == true
    x.joue = a ~= nil and joue(a) == true
    x.busy = a ~= nil and sur(function() return a.character:isBusy() end, false) == true
    local carte = (a ~= nil) and mapDe(a) or ""
    local cell = (a ~= nil) and tonumber(sur(function() return a.map:currentCell() end, nil)) or nil
    local v1, v2, v3, v4, v5, v6, v7, v8, v9 = lvMem(eq, "VU_" .. n):match(LV_MOTIF_VU)
    if v1 ~= nil then
        x.vu = { g = tonumber(v1), t = tonumber(v2), carte = v3, case = tonumber(v4), combat = v5 == "1",
                 nbc = tonumber(v6), oeuf = tonumber(v7), clef = tonumber(v8), mode = v9 }
    end
    if not x.co or carte == "" or carte == "0" then
        local d = eq.lv.der[n] or {}
        x.carte, x.cell, x.perdu = tostring(d.carte or ""), d.cell, true
        if x.vu ~= nil and x.vu.carte ~= "" and (x.vu.t or 0) > (d.t or 0) then x.carte, x.cell = x.vu.carte, x.vu.case end
    else
        x.carte, x.cell, x.perdu = carte, cell, false
        eq.lv.der[n] = { carte = carte, cell = cell, t = lvS() }
    end
    x.r = LARVES_D.RANG[x.carte]
    x.dedans = (x.r or 0) >= 2
    eq.lv.derDedans = eq.lv.derDedans or {}
    if x.dedans then
        eq.lv.derDedans[n] = { t = lvS(), carte = x.carte, cell = x.cell }
    elseif x.carte ~= "" and x.carte ~= LARVES_D.ENTREE and not (LARVES_D.APPROCHE or {})[x.carte] then
        local dd = eq.lv.derDedans[n]
        if dd ~= nil and lvS() - dd.t < 15 then
            x.carte, x.cell = dd.carte, dd.cell
            x.r = LARVES_D.RANG[x.carte]
            x.dedans = true
        end
    end
    x.fini = x.carte == LARVES_D.SORTIE
    eq.ids = eq.ids or {}
    if a ~= nil and (eq.ids[n] == nil or eq.ids[n] == "") then
        local id = idDe(a)
        if id ~= "" and id ~= "0" then eq.ids[n] = id ; memEcrire("RS_ID_" .. n, id) end
    end
    if (eq.ids[n] or "") == "" then
        local m = tostring(mem("RS_ID_" .. n) or "")
        if m ~= "" and m ~= "0" then eq.ids[n] = m end
    end
    x.id = eq.ids[n] or ""
    eq.persos = eq.persos or {}
    if a ~= nil and eq.persos[n] == nil then eq.persos[n] = sur(function() return a.character:name() end, nil) end
    x.perso = eq.persos[n]
    x.v2 = x.vu ~= nil
    x.vivant = x.v2 and x.joue and lvS() - (x.vu.t or 0) <= 10
    x.oeuf = tonumber(a ~= nil and sur(function() return a.inventory:itemCount(LARVES_D.OEUF) end, nil) or nil)
        or (x.vu and x.vu.oeuf) or 0
    x.clef = tonumber(a ~= nil and sur(function() return a.inventory:itemCount(LARVES_D.CLEF) end, nil) or nil)
        or (x.vu and x.vu.clef) or 0
    x.nbc = tonumber(a ~= nil and sur(function() return a.global:getCountFight() end, nil) or nil)
    if x.nbc == nil and x.vu ~= nil then x.nbc = x.vu.nbc end
    x.jetable = (LARVES_JETABLES ~= false) and lvMem(eq, "SUCCES_" .. n) == "1"
    x.sorti = tonumber(lvMem(eq, "SORTI_" .. n)) == eq.lv.gen
    x.mode = lvLireGen(eq, "MODE_" .. n)
    x.sortant = x.mode == "sortir"
    x.actif = not x.sorti and not x.fini and not x.sortant
    local k, lieu = LARVES_D.levierDe(x.carte)
    x.levier, x.lieuLevier = k, lieu
    if lieu == "salle" then
        local h = LARVES_D.moitieDe(x.carte, x.cell)
        if h ~= nil and not x.perdu then eq.lv.moitie[n] = { carte = x.carte, h = h } end
        local m = eq.lv.moitie[n]
        x.moitie = (m ~= nil and m.carte == x.carte) and m.h or nil
    end
    return x
end
function lvFinale(eq, X, k, K, L, H)
    local x1, x2 = H[1][1], H[2][1]
    local mode = lvModeLevier(eq, k, L)
    local pol
    if x1.jetable and x2.jetable then pol = "libre"
    elseif x1.jetable then pol = "procheDabord"
    elseif x2.jetable then pol = "loinDabord"
    else pol = "libre" end
    LV_OUVERTURE = { k = k, final = true, politique = pol, tireurs = { x1.n, x2.n } }
    local tLev = lvT()
    lvTirer(eq, K, mode, x1, x2)
    local tTire = lvT()
    local p = { { x = x1, h = 1, case0 = x1.cell }, { x = x2, h = 2, case0 = x2.cell } }
    if pol == "libre" then
        for h = 1, 2 do
            local m = p[h]
            if m.x.a ~= nil and not m.x.combat and not m.x.perdu then
                local ok = sur(function() return m.x.a.map:moveToCell(K[h].sortie) end, nil)
                m.tEnvoi, m.okEnvoi = lvT(), ok
                eq.lv.marche[m.x.n] = { cible = K[h].sortie, carte = m.x.carte, envoi = m.tEnvoi, case = m.x.cell, bouge = 0,
                    essais = 1, refus = (ok == false) and 1 or 0, dernier = ok }
            end
        end
    end
    local tOuv, tFerme, premier, tDep1, bouge = nil, nil, nil, nil, false
    while true do
        local t = lvT()
        for h = 1, 2 do
            local m = p[h]
            if not m.passe then
                m.y = lvRelirePos(eq, m.x)
                if m.y.perdu then p.perdus = true end
                if m.y.cell ~= m.case0 then bouge = true end
                if m.y.carte ~= K.carte and m.y.carte ~= "" then
                    m.passe = t ; tOuv = tOuv or (t - 300) ; premier = premier or h
                end
            end
        end
        if pol == "synchro" and tDep1 == nil and p[1].envoiCase ~= nil and p[1].y ~= nil and p[1].y.cell ~= p[1].envoiCase then tDep1 = t end
        local function peut(h)
            if t - tLev < LV_ACTIVATION_MS then return false end
            if pol == "libre" then return true end
            if pol == "procheDabord" then return h == 2 or p[2].passe ~= nil end
            if pol == "loinDabord" then return h == 1 or p[1].passe ~= nil end
            if h == 1 or p[1].passe ~= nil then return true end
            if tDep1 == nil then return false end
            local d1 = tonumber(sur(function() return x1.a.map:cellDistance(p[1].y.cell, K[1].sortie) end, nil))
            if d1 ~= nil and d1 <= K[2].pas + 1 then return true end
            return t - tDep1 >= (K[1].pas - K[2].pas - 1) * (L.vCase or 300)
        end
        for h = 1, 2 do
            local m = p[h]
            if not m.passe and peut(h) then
                local r = lvAllerVers(eq, m.y, K[h].sortie, 600)
                if h == 1 and r == "envoye" and p[1].envoiCase == nil then p[1].envoiCase = m.y.cell end
                if r == "refuse" and tOuv ~= nil and t - tOuv > 300 then tFerme = tFerme or t end
            end
        end
        if (p[1].passe and p[2].passe) or (tOuv == nil and not bouge and t - tLev > 5000) or t - tLev > LV_FENETRE_MS then break end
        global:delay(100)
    end
    LV_OUVERTURE = nil
    local n = (p[1].passe and 1 or 0) + (p[2].passe and 1 or 0)
    local function ms(v) return v and ("+" .. math.floor(v - tLev) .. " ms") or "-" end
    log("[LARVES] mesure levier " .. k .. " (finale) : door() " .. math.floor(tTire - tLev) .. " ms ; envoi "
        .. lvNom(x1) .. " " .. ms(p[1].tEnvoi) .. " (" .. tostring(p[1].okEnvoi) .. "), " .. lvNom(x2) .. " " .. ms(p[2].tEnvoi)
        .. " (" .. tostring(p[2].okEnvoi) .. ") ; passage " .. lvNom(x1) .. " " .. ms(p[1].passe) .. ", " .. lvNom(x2) .. " " .. ms(p[2].passe))
    lvBilanOuverture(eq, k, L, mode, tLev, tOuv, tFerme, n, 2, true, p.perdus)
    log("[LARVES] g=" .. eq.lv.gen .. " levier " .. k .. " finale (" .. pol .. ") : " .. lvNom(x1) .. (p[1].passe and " passe" or " reste")
        .. ", " .. lvNom(x2) .. (p[2].passe and " passe" or " reste"))
    if n == 2 then return end
    if n == 0 then
        if p.perdus then return end
        L.nulles = (L.nulles or 0) + 1
        if L.nulles >= 6 then L.r2 = "levier " .. k .. " : 6 ouvertures finales nulles" end
        return
    end
    local reste = p[1].passe and x2 or x1
    if p[(reste == x1) and 1 or 2].y ~= nil and p[(reste == x1) and 1 or 2].y.perdu then return end
    if reste.jetable then
        return lvSortieSeule(eq, X, { reste }, "levier " .. k .. " : " .. lvNom(reste) .. " (deja le succes) seul apres l ouverture finale -> sort")
    end
    L.r1 = "levier " .. k .. " : " .. lvNom(reste) .. " (sans le succes) seul apres l ouverture finale (" .. pol .. ")"
end
function lvSortieSeule(eq, X, liste, detail)
    for _, x in ipairs(liste) do
        if x.mode ~= "sortir" then
            lvEcrire(eq, "MODE_" .. x.n, eq.lv.gen .. ":sortir")
            x.mode, x.sortant, x.actif = "sortir", true, false
            log("[LARVES] g=" .. eq.lv.gen .. " SORTIE SEULE : " .. tostring(detail))
            lvJournal(eq, "Larves : " .. lvNom(x) .. " seul (" .. tostring(detail) .. ")", "perso jetable (succes 34 deja obtenu)",
                "sortie seule (DungeonQuitRequest), son cote continue sans lui")
        end
    end
end
function lvPoserPhase(eq, ph, detail)
    lvEcrire(eq, "PHASE", eq.lv.gen .. ":" .. ph)
    eq.lv.phase, eq.lv.tPhase = ph, lvT()
    log("[LARVES] g=" .. eq.lv.gen .. " -> " .. ph .. ((detail ~= nil and detail ~= "") and (" (" .. detail .. ")") or ""))
end
function lvLancerTransit(eq, X, c, S, Q, M, sansCombat)
    eq.lv.decolleGen = (eq.lv.decolleGen or 0) + 1
    S.etat, S.tTransit, S.sansCombat = "transit", lvT(), sansCombat
    S.cyclesSansProgres, S.signTransit, S.envoiT = 0, nil, {}
    S.partants, S.refus, S.decolle = {}, {}, {}
    for _, x in ipairs(Q) do S.partants[#S.partants + 1] = x.n end
    log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : transit en bloc depuis " .. M .. (sansCombat and " (sans combat)" or "")
        .. " : " .. lvNoms(Q))
    return lvSuiteTransit(eq, X, c, S, Q, M)
end
function lvMarquerSorti(eq, x)
    lvEcrire(eq, "SORTI_" .. x.n, eq.lv.gen)
    lvEcrire(eq, "MODE_" .. x.n, eq.lv.gen .. ":repos")
    x.sorti, x.mode, x.sortant, x.actif = true, "repos", false, false
    log("[LARVES] g=" .. eq.lv.gen .. " " .. lvNom(x) .. " sorti du donjon (jetable) -> repos jusqu a la fin")
end
function lvIndisponibles(eq, X)
    eq.lvIndispo = eq.lvIndispo or {}
    local t, l = lvT(), {}
    for _, x in ipairs(X) do
        if x.co and not x.perdu then eq.lvIndispo[x.n] = nil
        else
            local d = eq.lvIndispo[x.n]
            if d == nil then d = { t = t, lu = 0 } ; eq.lvIndispo[x.n] = d end
            if t - d.lu >= 5000 then d.lu = t ; d.raison = lvRaisonRefus(x) end
            local min = math.floor((t - d.t) / 60000)
            if d.raison ~= nil then
                l[#l + 1] = { x = x, raison = d.raison, texte = lvNom(x) .. " ne peut plus se connecter (" .. lvTexteRaison(d.raison)
                    .. ", deconnecte depuis " .. min .. " min)" }
            elseif t - d.t >= LV_INDISPO_MIN * 60000 then
                l[#l + 1] = { x = x, raison = nil, texte = lvNom(x) .. " deconnecte depuis " .. min .. " min" }
            end
        end
    end
    eq.lvIndispoListe = l
    return l
end
function lvImpasse(eq, X)
    local t = lvT()
    local imp, vus = eq.lv.imp, {}
    local function confirme(code, ms)
        vus[code] = true
        imp[code] = imp[code] or t
        return t - imp[code] >= ms
    end
    local function fin(code, detail, liste)
        for c in pairs(imp) do if not vus[c] then imp[c] = nil end end
        return code, detail, liste
    end
    local function tousJetables(l)
        if #l == 0 then return false end
        for _, x in ipairs(l) do if not x.jetable then return false end end
        return true
    end
    for _, x in ipairs(X) do
        if x.actif and not x.perdu and x.lieuLevier == "salle" and x.moitie ~= nil and x.moitie ~= x.cote then
            return fin("R10", lvNom(x) .. " dans la moitie " .. x.moitie .. " au lieu de " .. x.cote .. " (levier " .. tostring(x.levier) .. ")")
        end
    end
    local incertain0 = false
    for _, x in ipairs(X) do if x.actif and x.perdu then incertain0 = true end end
    for k = 1, 2 do
        local L = eq.lv.L[k]
        if L ~= nil and L.r2 ~= nil then return fin("R2", L.r2) end
        if L ~= nil and L.r1 ~= nil and not incertain0 then return fin("R1", L.r1) end
        if L ~= nil and L.r7 ~= nil and not incertain0 then
            local K = LARVES_D.LEVIER[k]
            local surA, H, inc = lvOccupants(eq, X, K)
            local l = {}
            for _, x in ipairs(surA) do l[#l + 1] = x end
            for h = 1, 2 do for _, x in ipairs(H[h]) do l[#l + 1] = x end end
            for _, x in ipairs(inc) do l[#l + 1] = x end
            local motif = L.r7
            if tousJetables(l) then L.r7 = nil return fin("SEULE", motif, l) end
            return fin("R7", motif)
        end
    end
    local incertain = false
    for _, x in ipairs(X) do if x.actif and x.perdu then incertain = true end end
    for _, x in ipairs(X) do if x.actif and x.combat then incertain = true end end
    for k = 1, 2 do
      if not incertain then
        local K = LARVES_D.LEVIER[k]
        local rR = LARVES_D.RANG[K.carte]
        local L = eq.lv.L[k]
        if L == nil or L.etat ~= "fini" then
            local _, H = lvOccupants(eq, X, K)
            for h = 1, 2 do
                local o = 3 - h
                if #H[h] > 0 and #H[o] == 0 then
                    local renfort = false
                    for _, x in ipairs(X) do if x.actif and x.dedans and x.cote == o and (x.r or 0) < rR then renfort = true end end
                    if not renfort and confirme("R1_" .. k, 1000) then
                        local d = "levier " .. k .. " : moitie " .. h .. " occupee (" .. lvNoms(H[h]) .. "), moitie " .. o .. " vide sans renfort possible"
                        if tousJetables(H[h]) then return fin("SEULE", d, H[h]) end
                        return fin("R1", d)
                    end
                end
            end
        end
      end
    end
    for c = 1, 2 do
      if not incertain then
        local actifs, nonJ = {}, false
        for _, x in ipairs(X) do if x.cote == c and x.actif then actifs[#actifs + 1] = x ; if not x.jetable then nonJ = true end end end
        if nonJ and #actifs == 1 and lvDoitEncoreCombattre(eq, actifs[1]) and confirme("R8a_" .. c, 3000) then
            return fin("R8", "cote " .. c .. " reduit a " .. lvNom(actifs[1]) .. " (sans le succes) alors qu il reste des combats")
        end
      end
    end
    for k = 1, 2 do
        local L = eq.lv.L[k]
        if (L == nil or L.etat ~= "fini") and not incertain then
            local rR = LARVES_D.RANG[LARVES_D.LEVIER[k].carte]
            for c = 1, 2 do
                local besoin, autre = nil, false
                for _, x in ipairs(X) do
                    if x.actif and x.dedans and (x.r or 0) <= rR then
                        if x.cote == c and not x.jetable then besoin = x end
                        if x.cote ~= c then autre = true end
                    end
                end
                if besoin ~= nil and not autre and confirme("R8b_" .. k .. "_" .. c, 3000) then
                    return fin("R8", "levier " .. k .. " : " .. lvNom(besoin) .. " (cote " .. c .. ") doit le passer et plus personne de l autre cote ne peut l ouvrir")
                end
            end
        end
    end
    for c = 1, 2 do
      if not incertain then
        local S = eq.lv.S[c] or {}
        local motif, code = nil, "R7"
        if S.r7 ~= nil then motif = S.r7
        elseif S.sansChef ~= nil and t - S.sansChef >= 60000 then
            motif = "cote " .. c .. " sans son chef sur " .. tostring(S.M)
            local ch = lvTrouver(X, eq.noms[(c == 1) and 1 or 5])
            if ch == nil or not ch.actif then code = "R5" end
        elseif S.seul ~= nil and t - S.seul >= 60000 then motif = "cote " .. c .. " : moins de 2 membres pour combattre sur " .. tostring(S.M) end
        if motif ~= nil then
            local _, Q = lvQueue(eq, X, c)
            if tousJetables(Q) then S.r7, S.sansChef, S.seul = nil, nil, nil return fin("SEULE", motif, Q) end
            return fin(code, motif)
        end
      end
    end
    for _, x in ipairs(X) do
        if x.actif and not x.dedans and not x.perdu and not x.combat and confirme("R3_" .. x.n, 60000) then
            return fin("R3", lvNom(x) .. " hors du donjon (" .. x.carte .. ") pendant la tentative")
        end
    end
    local deco = false
    for _, x in ipairs(X) do
        if x.actif and x.perdu then
            deco = true
            local d = eq.lv.deco[x.n]
            if d == nil then
                local delai = 10 * 60000
                local L = sur(function() return x.a.global:consoleLines() end, nil)
                if type(L) == "table" then
                    for i = #L, math.max(1, #L - 30), -1 do
                        local nm = tostring(L[i] or ""):match("Reconnexion automatique dans (%d+) minute")
                        if nm ~= nil then delai = (tonumber(nm) + 5) * 60000 break end
                    end
                end
                d = { t = t, delai = delai }
                eq.lv.deco[x.n] = d
                log("[LARVES] " .. lvNom(x) .. " deconnecte : attente (" .. math.floor(delai / 60000) .. " min avant reprise, jamais de reconnexion forcee)")
            end
            vus["R6_" .. x.n] = true
            imp["R6_" .. x.n] = imp["R6_" .. x.n] or d.t
            if t - d.t >= d.delai then
                local i = lvIndispoDe(eq, x.n)
                eq.lv.nonCompte = i ~= nil and i.raison ~= nil
                return fin("R6", lvNom(x) .. " deconnecte depuis " .. math.floor((t - d.t) / 60000) .. " min"
                    .. (eq.lv.nonCompte and (" (" .. lvTexteRaison(i.raison) .. ", reprise non comptee)") or ""))
            end
        else
            eq.lv.deco[x.n] = nil
        end
    end
    local sig = lvSignature(eq, X)
    if sig ~= eq.lv.sign then eq.lv.sign, eq.lv.signT = sig, t end
    if not deco and t - (eq.lv.signT or t) >= 15 * 60000 then
        eq.lv.signT = t
        return fin("R4", "aucune progression depuis 15 min")
    end
    return fin(nil)
end
function lvL(eq, k)
    eq.lv.L[k] = eq.lv.L[k] or { etat = "attente", echecs = 0, nulles = 0, ouvertures = 0, echecsConsec = 0, vCase = 300 }
    return eq.lv.L[k]
end
function lvNouvelEtat(g, ancien)
    ancien = ancien or {}
    return { gen = g, phase = nil, tPhase = lvT(), marche = {}, S = { {}, {} }, L = {}, imp = {}, verrou = {},
             der = ancien.der or {}, moitie = ancien.moitie or {}, essaisEntree = {}, regroupe = {}, sortieOutil = {},
             sortieDepuis = {}, deco = {}, immobile = {}, ouvertures = 0, nValide = 0, sign = "", signT = lvT(),
             rassOk = nil, groupesT = nil, consoleVu = {} }
end
function lvTirer(eq, K, mode, x1, x2)
    if (mode == "deux" or mode == "loin") and x1 ~= nil then sur(function() return x1.a.map:door(K[1].levier) end, nil) end
    if (mode == "deux" or mode == "proche") and x2 ~= nil then sur(function() return x2.a.map:door(K[2].levier) end, nil) end
    if mode == "proche" and x2 == nil and x1 ~= nil then sur(function() return x1.a.map:door(K[1].levier) end, nil) end
end
function lvRelirePos(eq, x)
    local a = x.a
    local y = { n = x.n, i = x.i, cote = x.cote, a = a, jetable = x.jetable, perso = x.perso, busy = false }
    y.co = a ~= nil and connecte(a) == true
    y.combat = a ~= nil and enCombat(a) == true
    y.carte = (a ~= nil) and mapDe(a) or ""
    y.cell = (a ~= nil) and tonumber(sur(function() return a.map:currentCell() end, nil)) or nil
    y.perdu = (not y.co) or y.carte == "" or y.carte == "0"
    if y.perdu then
        local d = eq.lv.der[x.n] or {}
        y.carte, y.cell = tostring(d.carte or x.carte or ""), d.cell or x.cell
        local v1, v2, v3, v4 = lvMem(eq, "VU_" .. x.n):match(LV_MOTIF_VU)
        if v1 ~= nil and v3 ~= "" and (tonumber(v2) or 0) > (d.t or 0) then y.carte, y.cell = v3, tonumber(v4) end
    else
        eq.lv.der[x.n] = { carte = y.carte, cell = y.cell, t = lvS() }
    end
    return y
end
function lvBarriere(eq, X, k)
    local K = LARVES_D.LEVIER[k]
    local rR = LARVES_D.RANG[K.carte]
    local n = 0
    for _, x in ipairs(X) do
        if x.actif then
            local r = x.r or 0
            if r < rR - 1 then return false, lvNom(x) .. " pas encore arrive (" .. tostring(x.carte) .. ")" end
            if r == rR - 1 or r == rR then
                if not x.co or x.perdu then return false, lvNom(x) .. " deconnecte" end
                if x.combat then return false, lvNom(x) .. " en combat" end
                if x.busy then return false, lvNom(x) .. " occupe" end
                if r == rR - 1 then
                    local S = eq.lv.S[x.cote] or {}
                    if not (S.M == K.avant and S.etat == "barriere") then return false, "cote " .. x.cote .. " pas pret sur l antichambre" end
                end
                n = n + 1
            end
        end
    end
    if n == 0 then return false, "personne" end
    return true
end
function lvOccupants(eq, X, K)
    local surA, H, inconnus = {}, { {}, {} }, {}
    for _, x in ipairs(X) do
        if x.actif then
            if x.carte == K.avant then surA[#surA + 1] = x
            elseif x.carte == K.carte then
                if x.moitie == 1 or x.moitie == 2 then table.insert(H[x.moitie], x) else inconnus[#inconnus + 1] = x end
            end
        end
    end
    return surA, H, inconnus
end
function lvRelancerScripts(eq, X)
    eq.arretLarves = eq.arretLarves or {}
    local t = lvT()
    for _, x in ipairs(X) do
        if x.joue or x.combat or not x.co or x.perdu then eq.arretLarves[x.n] = nil
        else
            eq.arretLarves[x.n] = eq.arretLarves[x.n] or t
            local outil = eq.lv.sortieOutil[x.n]
            if t - eq.arretLarves[x.n] >= 6000 and not lvEnSalleDeLevierActive(eq, x)
               and not (outil ~= nil and t - outil < 30000) and relanceAutorisee(eq, x.n) then
                eq.arretLarves[x.n] = nil
                eq.relances[#eq.relances + 1] = { os.time(), x.n }
                log("[LARVES] " .. lvNom(x) .. " : script arrete -> relance")
                lancer(x.a, SCRIPT_RUN)
            end
        end
    end
end
function lvModeSuivant(eq, k, L, mode)
    local modes = LARVES_D.MODES[k]
    local idx = 0
    for i, m in ipairs(modes) do if m == mode then idx = i end end
    L.modeIdx = idx % #modes
    lvEcrire(eq, "L_MODE_" .. k, "")
    log("[LARVES] g=" .. eq.lv.gen .. " levier " .. k .. " : mode « " .. tostring(mode) .. " » sans ouverture 2 fois -> mode « " .. modes[L.modeIdx + 1] .. " »")
end
function lvSuiteCombat(eq, X, c, S, Q, M)
    local parNom = {}
    for _, x in ipairs(X) do parNom[x.n] = x end
    local enC = 0
    for _, n in ipairs(S.membres or {}) do
        local x = parNom[n]
        if x ~= nil and x.combat then S.vus[n] = true ; enC = enC + 1 end
    end
    local t = lvT()
    if enC > 0 then S.finT = nil return end
    local function participe(n)
        local x = parNom[n]
        return S.vus[n] == true or (x ~= nil and x.nbc ~= nil and S.nbc0[n] ~= nil and x.nbc > S.nbc0[n])
    end
    local un = false
    for _, n in ipairs(S.membres or {}) do if participe(n) then un = true end end
    if not un then
        if t - (S.tLance or t) < 10000 then return end
        eq.lv.verrou[M] = nil
        S.etat, S.unT = "arrivee", nil
        if (S.essaisCombat or 0) >= 3 then S.r7 = "combat lance 3 fois sans effet sur " .. M end
        return log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : lancement sans effet sur " .. M .. " -> nouvel essai")
    end
    if S.finT == nil then S.finT = t return end
    if t - S.finT < 1000 then return end
    eq.lv.verrou[M] = nil
    local absents, dehors = {}, {}
    for _, n in ipairs(S.membres or {}) do
        local x = parNom[n]
        if x ~= nil and not x.dedans and not x.perdu then dehors[#dehors + 1] = x
        elseif not participe(n) then absents[#absents + 1] = x or { n = n } end
    end
    if #dehors > 0 then
        S.etat, S.unT = "arrivee", nil
        return log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : " .. lvNoms(dehors) .. " hors du donjon apres le combat sur " .. M .. " (defaite ?) -> l impasse R3 tranche")
    end
    if #absents == 0 then
        lvEcrire(eq, "VALIDE_" .. c .. "_" .. M, eq.lv.gen)
        eq.lv.nValide = (eq.lv.nValide or 0) + 1
        S.etat = LARVES_D.CARTE[M].antichambre and "barriere" or "valide"
        return log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : combat PROUVE sur " .. M .. " (" .. #S.membres .. " participants)"
            .. (S.etat == "barriere" and " -> barriere du levier" or " -> transit en bloc"))
    end
    local chefC = lvTrouver(X, eq.noms[(c == 1) and 1 or 5])
    for _, x in ipairs(absents) do
        local cle = x.n .. "@" .. M
        eq.lv.regroupe[cle] = (eq.lv.regroupe[cle] or 0) + 1
        local k = eq.lv.regroupe[cle]
        lvEcrire(eq, "REGROUPE_" .. x.n, eq.lv.gen .. ":" .. math.min(k, 2) .. ":" .. k .. M)
        log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : " .. lvNom(x) .. " n a PAS rejoint le combat sur " .. M
            .. " -> regroupement " .. math.min(k, 2) .. " (" .. (k == 1 and "auto join rearme" or "quitte son groupe, reinvite") .. "), le cote refait le combat")
        if k >= 2 and chefC ~= nil and chefC.id ~= "" then memEcrire("RS_PARTY_" .. chefC.id, "") end
    end
    S.etat, S.unT, S.zeroT, S.sansCombatEchoue = "arrivee", nil, nil, true
    if (S.essaisCombat or 0) >= 3 then S.r7 = "combat refait 3 fois sur " .. M .. " (membres qui ne rejoignent pas : " .. lvNoms(absents) .. ")" end
end
function lvTexteRaison(r)
    if r == "SubscriberOnly" then return "abonnement expire (SubscriberOnly)" end
    return "refus du serveur : " .. tostring(r)
end
function lvDonjon(eq, X)
    local actifs, surSortie, arrives = 0, 0, 0
    for _, x in ipairs(X) do
        if x.mode == "sortir" and not x.dedans and not x.perdu and not x.sorti then lvMarquerSorti(eq, x) end
        if x.sortant and x.dedans then lvSecoursSortie(eq, x) end
        if not x.sorti and not x.sortant then
            actifs = actifs + 1
            if x.fini and not x.combat then surSortie = surSortie + 1 end
        end
        if x.fini then arrives = arrives + 1 end
    end
    if actifs > 0 and surSortie == actifs then return lvPoserPhase(eq, "fini", "tous les restants sur 96998919") end
    if actifs == 0 then
        if arrives > 0 then return lvPoserPhase(eq, "fini", "les restants sont sortis") end
        return lvDeclencherReprise(eq, X, "R7", "plus aucun perso actif dans le donjon", true)
    end
    local code, detail, liste = lvImpasse(eq, X)
    if code == "SEULE" then lvSortieSeule(eq, X, liste, detail)
    elseif code ~= nil then return lvDeclencherReprise(eq, X, code, detail, eq.lv.nonCompte ~= true) end
    for k = 1, 2 do if lvLevierActif(eq, X, k) then return lvMachineLevier(eq, X, k) end end
    lvMachineCote(eq, X, 1)
    lvMachineCote(eq, X, 2)
    lvAntiInactivite(eq, X)
end
function lvSauverLevier(eq, k)
    local L = lvL(eq, k)
    lvEcrire(eq, "LEV_" .. k, eq.lv.gen .. ":" .. L.etat .. ":" .. tostring(L.t1 or "") .. ":" .. tostring(L.t2 or "")
        .. ":" .. (L.echecs or 0) .. ":" .. (L.nulles or 0))
end
function lvSignature(eq, X)
    local t = {}
    for _, x in ipairs(X) do t[#t + 1] = x.carte .. (x.combat and "c" or "") .. (x.actif and "" or "s") end
    return table.concat(t, ",") .. "|" .. (eq.lv.ouvertures or 0) .. "|" .. (eq.lv.nValide or 0)
end
function lvFin(eq, X)
    local g, t = eq.lv.gen, lvT()
    if eq.lv.finModes ~= g then
        eq.lv.finModes, eq.lv.finT = g, t
        for _, n in ipairs(eq.noms) do lvEcrire(eq, "MODE_" .. n, g .. ":fin") end
    end
    local attente = {}
    for _, x in ipairs(X) do
        if x.dedans then attente[#attente + 1] = lvNom(x) .. " dans le donjon"
        elseif tonumber(lvMem(eq, "FIN_FAITE_" .. x.n)) ~= g and x.co then attente[#attente + 1] = lvNom(x) .. " etape pas encore close" end
    end
    if #attente > 0 and t - (eq.lv.finT or t) < 5 * 60000 then return attenteLarves(eq, "fin", table.concat(attente, " ; ")) end
    if eq.lv.finClos ~= g then
        eq.lv.finClos = g
        lvEcrire(eq, "TENT", 0)
        lvEcrire(eq, "ACHAT_OEUF", 0)
        local idL = lvIdLeader(eq)
        if idL ~= "" then memEcrire("RS_" .. idL .. "_LARVES_FINI", 1) ; memEcrire("RS_" .. idL .. "_LARVES_EN_COURS", 0) end
        log("[LARVES] g=" .. g .. " : LARVES REUSSIES" .. ((#attente > 0) and (" (sans attendre : " .. table.concat(attente, " ; ") .. ")") or ""))
        lvJournal(eq, "Larves reussies (tentative " .. g .. ")", "-", "protocole Larves v2")
    end
    eq.etat, eq.runLance = "run", false
end
function lvIntermediaire(eq, X, k, K, L, H)
    local mode = lvModeLevier(eq, k, L)
    local x1, x2 = lvTrouver(H[1], L.t1), lvTrouver(H[2], L.t2)
    local marcheurs = {}
    for h = 1, 2 do
        for _, x in ipairs(H[h]) do
            if x.n ~= L.t1 and x.n ~= L.t2 then marcheurs[#marcheurs + 1] = { x = x, h = h } end
        end
    end
    LV_OUVERTURE = { k = k, final = false, tireurs = { L.t1, L.t2 } }
    local tLev = lvT()
    lvTirer(eq, K, mode, x1, x2)
    local tTire = lvT()
    for h = 1, 2 do
        for _, m in ipairs(marcheurs) do
            if m.h == h and m.x.a ~= nil and not m.x.combat and not m.x.perdu then
                local ok = sur(function() return m.x.a.map:moveToCell(K[h].sortie) end, nil)
                m.tEnvoi = lvT()
                eq.lv.marche[m.x.n] = { cible = K[h].sortie, carte = m.x.carte, envoi = m.tEnvoi, case = m.x.cell, bouge = 0,
                    essais = 1, refus = (ok == false) and 1 or 0, dernier = ok }
            end
        end
    end
    local tOuv, tFerme, passes, perdus, bouge = nil, nil, 0, false, false
    for _, m in ipairs(marcheurs) do m.case0 = m.x.cell end
    while true do
        local reste = 0
        for _, m in ipairs(marcheurs) do
            if not m.passe then
                local y = lvRelirePos(eq, m.x)
                if y.perdu then perdus = true end
                if y.cell ~= m.case0 then bouge = true end
                if y.carte ~= K.carte and y.carte ~= "" then
                    m.passe = lvT() ; passes = passes + 1 ; tOuv = tOuv or (m.passe - 300)
                else
                    reste = reste + 1
                    if lvT() - tLev >= 150 then
                        local r = lvAllerVers(eq, y, K[m.h].sortie, 600)
                        if LV_RETOUR_DIT ~= true and tOuv == nil and (r == "refuse" or r == "envoye") then
                            LV_RETOUR_DIT = true
                            log("[LARVES] info : moveToCell vers la sortie " .. K[m.h].sortie .. " juste apres le levier (porte sans doute encore fermee) a rendu "
                                .. ((r == "refuse") and "false (refus : sondage rapide)" or "true (variante U1 : renvoi apres 600 ms d immobilite)"))
                        end
                        if r == "refuse" and tOuv ~= nil and lvT() - tOuv > 300 then tFerme = tFerme or lvT() end
                    end
                end
            end
        end
        local t = lvT()
        if reste == 0 or (tOuv == nil and not bouge and t - tLev > 5000) or t - tLev > LV_FENETRE_MS then break end
        global:delay(TICK_OUV)
    end
    LV_OUVERTURE = nil
    pcall(function()
        local d = {}
        for _, m in ipairs(marcheurs) do
            d[#d + 1] = lvNom(m.x) .. " envoi " .. (m.tEnvoi and ("+" .. math.floor(m.tEnvoi - tLev)) or "-")
                .. " passe " .. (m.passe and ("+" .. math.floor(m.passe - tLev)) or "-")
        end
        log("[LARVES] mesure levier " .. k .. " (intermediaire) : door() " .. math.floor(tTire - tLev) .. " ms ; " .. table.concat(d, ", "))
    end)
    lvBilanOuverture(eq, k, L, mode, tLev, tOuv, tFerme, passes, #marcheurs, false, perdus)
end
function lvModeLevier(eq, k, L)
    if true then return "proche" end
    local appris = lvMem(eq, "L_MODE_" .. k)
    if appris ~= "" then return appris end
    local modes = LARVES_D.MODES[k]
    return modes[((L.modeIdx or 0) % #modes) + 1]
end
function lvAntiInactivite(eq, X)
    local lim = (tonumber(LARVES_PAS_INACTIVITE_MIN) or 10) * 60000
    local t = lvT()
    for _, x in ipairs(X) do
        if x.actif and x.dedans and x.co and not x.perdu and not x.combat and x.cell ~= nil then
            local im = eq.lv.immobile[x.n]
            if im == nil or im.carte ~= x.carte or im.cell ~= x.cell then
                eq.lv.immobile[x.n] = { carte = x.carte, cell = x.cell, t = t }
            elseif t - im.t >= lim and not lvEnSalleDeLevierActive(eq, x) and x.lieuLevier ~= "salle"
                   and (eq.lv.S[x.cote].etat ~= "transit") then
                local v = lvVoisine(eq, x)
                im.t = t
                if v ~= nil then
                    log("[LARVES] " .. lvNom(x) .. " immobile depuis " .. math.floor(lim / 60000) .. " min -> un pas (anti-inactivite)")
                    lvAllerVers(eq, x, v)
                end
            end
        end
    end
end
function lvMigration(eq, X)
    if eq.lvMigre then return true end
    local anciens, connectes = {}, {}
    for _, x in ipairs(X) do
        if x.co and not x.perdu then
            connectes[#connectes + 1] = x.a
            if lvMem(eq, "VU_" .. x.n):sub(1, 3) ~= "V2:" or (tonumber(lvMem(eq, "VER_" .. x.n)) or 0) < LV_VERSION_SCRIPT_MIN then
                anciens[#anciens + 1] = x
            end
        end
    end
    local t = lvT()
    eq.lvMigrationT = eq.lvMigrationT or t
    if #anciens == 0 then
        eq.lvMigre = true
        local idL = lvIdLeader(eq)
        if idL ~= "" then
            memEcrire("RS_" .. idL .. "_LARVES_EN_COURS", 0)
            memEcrire("RS_" .. idL .. "_LARVES_FINI", 0)
        end
        for _, x in ipairs(X) do if x.id ~= "" then memEcrire("RS_LARVES_EXCLU_" .. x.id, 0) end end
        log("[LARVES] scripts Run_Sacri en version v2 sur les comptes connectes : protocole Larves v2 actif")
        return true
    end
    local depuis = t - eq.lvMigrationT
    if depuis >= 600000 then
        lvAlerte(eq, "scripts jamais passes en v2 : " .. lvNoms(anciens))
        return false
    end
    if depuis >= 20000 and not eq.lvMigrationFaite then
        for _, x in ipairs(X) do
            if x.combat then attenteLarves(eq, "migration", lvNom(x) .. " en combat : relance des scripts apres le combat") return false end
        end
        eq.lvMigrationFaite = true
        log("[LARVES] scripts d ancienne version (" .. lvNoms(anciens) .. ") : UNE relance groupee des " .. #connectes
            .. " comptes connectes (Run_Sacri v2, version " .. LV_VERSION_SCRIPT_MIN .. ")")
        for _, a in ipairs(connectes) do pcall(function() a:stopScript() end) end
        lancerTous(connectes, SCRIPT_RUN)
        return false
    end
    if depuis >= 180000 then
        eq.lvRelanceAncien = eq.lvRelanceAncien or {}
        for _, x in ipairs(anciens) do
            if not x.combat and t - (eq.lvRelanceAncien[x.n] or 0) > 60000 and relanceAutorisee(eq, x.n) then
                eq.lvRelanceAncien[x.n] = t
                eq.relances[#eq.relances + 1] = { os.time(), x.n }
                log("[LARVES] " .. lvNom(x) .. " : toujours en ancienne version -> relance du script")
                pcall(function() x.a:stopScript() end)
                lancer(x.a, SCRIPT_RUN)
            end
        end
    end
    attenteLarves(eq, "migration", "attente des scripts v2 (" .. lvNoms(anciens) .. ")")
    return false
end
function lvCibles(eq, K, H, L)
    local cibles = {}
    L.exclu = L.exclu or {}
    for h = 1, 2 do
        local t = (h == 1) and L.t1 or L.t2
        local anneau = {}
        for _, c in ipairs(K[h].anneau1) do anneau[#anneau + 1] = c end
        for _, c in ipairs(K[h].anneau2) do anneau[#anneau + 1] = c end
        local prises = { [K[h].dalle] = true }
        local function libre(x, c) return not prises[c] and not (L.exclu[x.n] or {})[c] end
        for _, x in ipairs(H[h]) do if x.n == t then cibles[x.n] = K[h].dalle end end
        for _, x in ipairs(H[h]) do
            if cibles[x.n] == nil and lvDans(anneau, x.cell) and libre(x, x.cell) then cibles[x.n] = x.cell ; prises[x.cell] = true end
        end
        for _, x in ipairs(H[h]) do
            if cibles[x.n] == nil then
                local deja = (L.cible or {})[x.n]
                if deja ~= nil and lvDans(anneau, deja) and libre(x, deja) then cibles[x.n] = deja ; prises[deja] = true
                else
                    for _, c in ipairs(anneau) do
                        if libre(x, c) then cibles[x.n] = c ; prises[c] = true break end
                    end
                end
            end
        end
    end
    L.cible = cibles
    return cibles
end
function lvDemarrer(eq, X)
    for _, x in ipairs(X) do
        if x.dedans then
            lvJournal(eq, "Larves : etat anterieur inconnu (" .. lvNom(x) .. " dans le donjon " .. x.carte .. ")",
                "pas de tentative v2 en cours", "reprise de demarrage (non comptee) : sortie, oeuf, entree a 8")
            return lvNouvelleGeneration(eq, "reprise", "DEMARRAGE", "etat anterieur inconnu (" .. lvNom(x) .. " sur " .. x.carte .. ")", false)
        end
    end
    return lvNouvelleGeneration(eq, "rassemblement", "DEPART", "", false)
end
function lvNouvelleGeneration(eq, phase, code, detail, compter)
    local g = (tonumber(lvMem(eq, "GEN")) or 0) + 1
    if compter then lvEcrire(eq, "TENT", (tonumber(lvMem(eq, "TENT")) or 0) + 1) end
    lvEcrire(eq, "GEN", g)
    eq.lv = lvNouvelEtat(g, eq.lv)
    lvEcrire(eq, "ACHAT_OEUF", g)
    lvEcrire(eq, "SILENCE", "")
    lvEcrire(eq, "DERNIER_CODE", g .. ":" .. tostring(code))
    publierEquipe(eq)
    for _, n in ipairs(eq.noms) do
        local id = (eq.ids or {})[n] or idDe(frais(n))
        if id ~= nil and id ~= "" then memEcrire("RS_LARVES_EXCLU_" .. id, 0) end
    end
    if eq.lvMigre then
        local idL = lvIdLeader(eq)
        if idL ~= "" then memEcrire("RS_" .. idL .. "_LARVES_EN_COURS", 0) ; memEcrire("RS_" .. idL .. "_LARVES_FINI", 0) end
    end
    eq.lv.tent = tonumber(lvMem(eq, "TENT")) or 0
    lvPoserPhase(eq, phase, tostring(code) .. ((detail ~= nil and detail ~= "") and (" " .. detail) or "")
        .. ", tentatives ratees " .. eq.lv.tent .. "/" .. (LARVES_TENTATIVES_MAX or 3))
end
function lvQueue(eq, X, c)
    local M, rM = nil, nil
    for _, x in ipairs(X) do
        if x.cote == c and x.actif and x.dedans then
            local r = x.r or 0
            if rM == nil or r < rM then M, rM = x.carte, r end
        end
    end
    local Q, avance = {}, {}
    for _, x in ipairs(X) do
        if x.cote == c and x.actif and x.dedans then
            if x.carte == M then Q[#Q + 1] = x else avance[#avance + 1] = x end
        end
    end
    return M, Q, avance, rM
end
function lvEnSalleDeLevierActive(eq, x)
    if x.levier == nil then return false end
    local L = eq.lv.L[x.levier]
    return L ~= nil and (L.etat == "moities" or L.etat == "placement" or L.etat == "ouverture")
end
function lvCombatRequis(eq, X, S, Q, M, c)
    local C = LARVES_D.CARTE[M]
    if C.sansCombat then return "non" end
    for _, x in ipairs(X) do
        if x.cote ~= c and x.carte == M and x.combat then S.zeroT, S.nZero = nil, 0 return "oui" end
    end
    local n = nil
    for k, x in ipairs(Q) do
        if k <= 2 and x.a ~= nil then
            local v = nbGroupesLv(x.a)
            if v ~= nil then n = math.max(n or 0, v) end
        end
    end
    if n == nil then return "attente" end
    local t = lvT()
    if n >= 1 then
        S.zeroT, S.nZero = nil, 0
        if S.unT ~= nil and t - S.unT >= 1000 then return "oui" end
        S.unT = S.unT or t
        return "attente"
    end
    S.unT = nil
    S.zeroT = S.zeroT or t
    S.nZero = (S.nZero or 0) + 1
    if S.sansCombatEchoue then return "attente" end
    if C.boss then return "attente" end
    if eq.lv.verrou[M] ~= nil and eq.lv.verrou[M] ~= c then return "attente" end
    if t - S.zeroT >= 3000 and S.nZero >= 3 then return "non" end
    return "attente"
end
function lvVoisine(eq, x)
    if x.a == nil or x.cell == nil then return nil end
    local ok = {}
    pcall(function() for _, v in ipairs(x.a.map:getWalkableCells(true)) do ok[tonumber(v)] = true end end)
    local interdit = { [220] = true, [164] = true }
    local C = LARVES_D.CARTE[x.carte]
    if C ~= nil then
        for _, l in ipairs({ C.sortie or {}, C.secours or {} }) do for c = 1, 2 do if l[c] ~= nil then interdit[l[c]] = true end end end
    end
    for _, K in ipairs(LARVES_D.LEVIER) do
        for h = 1, 2 do interdit[K[h].sortie] = true ; interdit[K[h].porteAvant] = true ; interdit[K[h].levier] = true end
    end
    for _, d in ipairs({ 1, -1, 14, -14, 13, -13, 15, -15, 28, -28 }) do
        local v = x.cell + d
        local lig, col = math.floor(v / 14), v % 14
        if ok[v] and not interdit[v] and lig >= 2 and lig <= 37 and col >= 1 and col <= 12
           and tonumber(sur(function() return x.a.map:cellDistance(x.cell, v) end, 9)) == 1 then return v end
    end
    return nil
end
function lvLevierActif(eq, X, k)
    local L = lvL(eq, k)
    if L.etat == "fini" then return false end
    if L.etat == "moities" or L.etat == "placement" or L.etat == "ouverture" then return true end
    return (lvBarriere(eq, X, k))
end
function lvMachineLevier(eq, X, k)
    local K = LARVES_D.LEVIER[k]
    local L = lvL(eq, k)
    local g = eq.lv.gen
    local surA, H, inconnus = lvOccupants(eq, X, K)
    if L.etat == "attente" then
        local ok, pq = lvBarriere(eq, X, k)
        if not ok then return attenteLarves(eq, "levier " .. k, pq) end
        lvEcrire(eq, "SILENCE", g .. ":" .. K.avant .. ":" .. K.carte)
        log("[LARVES] g=" .. g .. " levier " .. k .. " : barriere atteinte (antichambre " .. #surA .. ", moitie 1 : " .. #H[1]
            .. ", moitie 2 : " .. #H[2] .. ") -> chacun dans la moitie de son cote")
        L.etat, L.tEtat = "moities", lvT()
        eq.lv.decolleGen = (eq.lv.decolleGen or 0) + 1
        lvSauverLevier(eq, k)
    end
    if L.etat == "moities" then
        if #surA == 0 and #inconnus == 0 then
            L.etat, L.tEtat, L.tPlace = "placement", lvT(), lvT()
            lvSauverLevier(eq, k)
        else
            local sign = tostring(#surA)
            local perdu = false
            for _, x in ipairs(surA) do sign = sign .. ":" .. tostring(x.cell) ; if x.perdu then perdu = true end end
            if sign ~= L.signMoities or perdu then L.signMoities, L.cyclesMoities = sign, 0 else L.cyclesMoities = (L.cyclesMoities or 0) + 1 end
            if (L.cyclesMoities or 0) * CYCLE_MS > 20000 then
                local refait = false
                local Cav = LARVES_D.CARTE[K.avant] or {}
                L.refaits = L.refaits or 0
                for c = 1, 2 do
                    local S = eq.lv.S[c] or {}
                    local reste = false
                    for _, x in ipairs(surA) do if x.cote == c then reste = true end end
                    if reste and S.M == K.avant and not Cav.sansCombat and L.refaits < 2 then
                        lvEcrire(eq, "VALIDE_" .. c .. "_" .. K.avant, "")
                        eq.lv.S[c] = { M = K.avant, etat = "arrivee", t = lvT(), essaisCombat = 0, sansCombatEchoue = true }
                        refait = true
                        log("[LARVES] g=" .. g .. " levier " .. k .. " : le cote " .. c .. " ne passe pas sa porte de moitie sans combat -> il attend les monstres et combat")
                    end
                end
                if refait then
                    L.refaits = L.refaits + 1
                    L.etat, L.cyclesMoities, L.signMoities = "attente", 0, nil
                    lvEcrire(eq, "SILENCE", "")
                    lvSauverLevier(eq, k)
                    return
                end
                L.r7 = L.r7 or ("levier " .. k .. " : antichambre encore occupee apres 20 s sans progres (" .. lvNoms(surA) .. lvNoms(inconnus) .. ")")
                return
            end
            for _, x in ipairs(surA) do lvVersDeclencheur(eq, x, K[x.cote].porteAvant) end
            return attenteLarves(eq, "levier " .. k, "passage dans les moities (" .. lvNoms(surA) .. ")")
        end
    end
    if L.etat == "placement" or L.etat == "ouverture" then
        if #H[1] == 0 and #H[2] == 0 and #surA == 0 and #inconnus == 0 then
            L.etat = "fini"
            lvEcrire(eq, "SILENCE", "")
            lvSauverLevier(eq, k)
            return log("[LARVES] g=" .. g .. " levier " .. k .. " : salle vide, tout le monde est passe (" .. (L.ouvertures or 0) .. " ouvertures)")
        end
        if #surA > 0 then L.etat, L.tEtat = "moities", lvT() return end
        if #H[1] == 0 or #H[2] == 0 then
            return attenteLarves(eq, "levier " .. k, "une moitie vide (moitie 1 : " .. #H[1] .. ", moitie 2 : " .. #H[2] .. ") : l impasse tranche")
        end
        L.etat = "placement"
        for h = 1, 2 do
            for _, x in ipairs(H[h]) do
                if not x.co or x.perdu then L.pretsN = 0 return attenteLarves(eq, "levier " .. k, lvNom(x) .. " deconnecte dans la salle : aucune ouverture (R6 tranche)") end
                if x.combat then L.pretsN = 0 return attenteLarves(eq, "levier " .. k, lvNom(x) .. " en combat dans la salle") end
            end
        end
        L.t1 = lvTireur(eq, H[1], L.t1, K[1].dalle)
        L.t2 = lvTireur(eq, H[2], L.t2, K[2].dalle)
        local cibles = lvCibles(eq, K, H, L)
        local prets = true
        for h = 1, 2 do
            for _, x in ipairs(H[h]) do
                local c = cibles[x.n]
                if c == nil or x.cell ~= c then
                    prets = false
                    if c ~= nil then lvAllerVers(eq, x, c) end
                end
            end
        end
        if not prets then
            L.pretsN = 0
            L.tPlace = L.tPlace or lvT()
            if lvT() - L.tPlace > 25000 then
                L.tPlace = lvT()
                L.echecsPlace = (L.echecsPlace or 0) + 1
                for h = 1, 2 do
                    for _, x in ipairs(H[h]) do
                        local c = cibles[x.n]
                        if c ~= nil and x.cell ~= c and x.n ~= L.t1 and x.n ~= L.t2 then
                            L.exclu[x.n] = L.exclu[x.n] or {}
                            L.exclu[x.n][c] = true
                        end
                    end
                end
                log("[LARVES] g=" .. g .. " levier " .. k .. " : placement non atteint en 25 s -> autres cases (" .. L.echecsPlace .. ")")
                if L.echecsPlace >= 3 then L.r7 = "levier " .. k .. " : placement impossible (3 fois 25 s)" end
            end
            return attenteLarves(eq, "levier " .. k, "placement (tireurs " .. tostring(L.t1) .. " + " .. tostring(L.t2) .. ")")
        end
        L.pretsN = (L.pretsN or 0) + 1
        if L.pretsN < 2 then return end
        if lvT() < (L.reposJusque or 0) then return attenteLarves(eq, "levier " .. k, "porte de l ouverture precedente pas encore refermee") end
        L.pretsN, L.tPlace = 0, nil
        if not lvSurDalles(eq, K, L, H) then return end
        L.etat = "ouverture"
        lvSauverLevier(eq, k)
        if #H[1] == 1 and #H[2] == 1 then lvFinale(eq, X, k, K, L, H) else lvIntermediaire(eq, X, k, K, L, H) end
        if L.etat == "ouverture" then L.etat, L.tEtat = "placement", lvT() end
        lvSauverLevier(eq, k)
    end
end
function lvGroupeProuve(eq, X, c, Q, chefX)
    if chefX == nil or chefX.id == "" then return false, "chef du cote inconnu" end
    local ref = tonumber(mem("RS_PARTY_" .. chefX.id))
    if ref == nil then return false, "groupe du chef " .. lvNom(chefX) .. " inconnu" end
    local idL = lvIdLeader(eq)
    for _, x in ipairs(Q) do
        if x.n ~= chefX.n then
            if x.id == "" or tonumber(mem("RS_PARTY_" .. x.id)) ~= ref then return false, lvNom(x) .. " hors groupe" end
            if tonumber(mem("RS_" .. idL .. "_AUTOPRET_" .. x.id)) ~= ref then return false, lvNom(x) .. " auto join non arme" end
        end
    end
    return true
end
function lvBilanOuverture(eq, k, L, mode, tLev, tOuv, tFerme, passes, total, final, perdus)
    L.ouvertures = (L.ouvertures or 0) + 1
    eq.lv.ouvertures = (eq.lv.ouvertures or 0) + 1
    local t = lvT()
    L.reposJusque = tOuv and math.max(t + 2000, tLev + 10300) or (t + 2000)
    if tOuv == nil and perdus then
        log("[LARVES] g=" .. eq.lv.gen .. " levier " .. k .. " : un perso s est deconnecte pendant l ouverture -> essai non compte")
    elseif tOuv == nil then
        L.echecs = (L.echecs or 0) + 1
        L.echecsConsec = (L.echecsConsec or 0) + 1
        if L.echecsConsec % 2 == 0 then lvModeSuivant(eq, k, L, mode) end
        if L.echecsConsec >= 6 then L.r2 = "levier " .. k .. " muet (" .. L.echecsConsec .. " essais de suite sans ouverture, les 3 modes)" end
    else
        L.echecsConsec = 0
        lvEcrire(eq, "L_MODE_" .. k, mode)
        lvEcrire(eq, "L_LAT_" .. k, tOuv - tLev)
        lvEcrire(eq, "L_W_" .. k, (tFerme or t) - tOuv)
    end
    log("[LARVES] g=" .. eq.lv.gen .. " levier " .. k .. " ouverture #" .. L.ouvertures .. " (" .. (final and "finale" or "intermediaire")
        .. ", mode " .. tostring(mode) .. ") : " .. (tOuv and ("lat " .. (tOuv - tLev) .. " ms, fenetre " .. ((tFerme or t) - tOuv) .. " ms") or "AUCUNE ouverture")
        .. ", passes " .. passes .. "/" .. total .. ", tireurs " .. tostring(L.t1) .. " + " .. tostring(L.t2))
end
function lvReprise(eq, X)
    local g = eq.lv.gen
    local dedans = {}
    for _, x in ipairs(X) do
        if x.dedans then
            dedans[#dedans + 1] = x
            if x.mode ~= "sortir" then lvEcrire(eq, "MODE_" .. x.n, g .. ":sortir") end
            lvSecoursSortie(eq, x)
        elseif x.mode == "sortir" and not x.perdu then
            lvEcrire(eq, "MODE_" .. x.n, "")
        end
    end
    if #dedans > 0 then
        local t = lvT()
        eq.lv.coDedans = eq.lv.coDedans or {}
        for _, x in ipairs(dedans) do
            local d = eq.lv.coDedans[x.n] or { co = 0, deco = 0, t = t }
            local dt = t - d.t
            if x.co and not x.perdu then d.co = d.co + dt else d.deco = d.deco + dt end
            d.t = t
            eq.lv.coDedans[x.n] = d
            if lvRefusServeur(eq, x.n) and not x.co then d.deco = 0 end
            if d.co > 10 * 60000 or d.deco > 45 * 60000 then
                return lvAlerte(eq, "sortie du donjon impossible : " .. lvNom(x) .. " (connecte " .. math.floor(d.co / 60000) .. " min, deconnecte " .. math.floor(d.deco / 60000) .. " min)")
            end
        end
        local h = lvTexteHumain(eq)
        return attenteLarves(eq, "reprise", "sortie du donjon : " .. lvNoms(dedans) .. ((h ~= "") and (" | INTERVENTION HUMAINE : " .. h) or ""))
    end
    if eq.lv.tent >= (LARVES_TENTATIVES_MAX or 3) then return lvAlerte(eq, "plafond de tentatives (" .. eq.lv.tent .. " ratees)") end
    return lvPoserPhase(eq, "rassemblement", "tout le monde est dehors : oeuf, route, entree a 8")
end
function lvRassemblement(eq, X)
    local g, t = eq.lv.gen, lvT()
    local manque, dedans = {}, {}
    for _, x in ipairs(X) do
        if tonumber(lvMem(eq, "ACHAT_ECHEC_" .. x.n)) == g then
            return lvAlerte(eq, "achat d oeuf impossible pour " .. lvNom(x) .. " (pas de tentative a 7)")
        end
        local pb = nil
        if x.dedans then dedans[#dedans + 1] = x ; pb = "dans le donjon"
        elseif x.carte ~= LARVES_D.ENTREE or not x.co or x.perdu then pb = "pas sur l entree"
        elseif x.combat or x.busy then pb = "occupe"
        elseif x.oeuf + x.clef < 1 then pb = "sans oeuf"
        elseif not x.vivant or x.vu.g ~= g or x.vu.mode ~= "attente" then pb = "script pas en attente" end
        if pb ~= nil then manque[#manque + 1] = lvNom(x) .. " " .. pb end
    end
    if #dedans > 0 then
        eq.lv.dedansT = eq.lv.dedansT or t
        if t - eq.lv.dedansT >= 60000 then return lvDeclencherReprise(eq, X, "R9", lvNoms(dedans) .. " dans le donjon pendant le rassemblement", true) end
    else
        eq.lv.dedansT = nil
    end
    if eq.lv.tent >= (LARVES_TENTATIVES_MAX or 3) then return lvAlerte(eq, "plafond de tentatives (" .. eq.lv.tent .. ")") end
    if #(eq.lvIndispoListe or {}) > 0 then
        eq.lv.rassOk, eq.lv.groupesT = nil, nil
        return attenteLarves(eq, "rassemblement", "INTERVENTION HUMAINE : " .. lvTexteHumain(eq) .. " | reste : " .. table.concat(manque, " ; "))
    end
    if #manque > 0 then
        eq.lv.rassOk, eq.lv.groupesT = nil, nil
        if t - eq.lv.tPhase >= 30 * 60000 and eq.lv.journalRass ~= g then
            eq.lv.journalRass = g
            lvJournal(eq, "Larves : rassemblement depuis 30 min (" .. table.concat(manque, " ; ") .. ")", "attente", "aucun arret ; voir les consoles")
        end
        return attenteLarves(eq, "rassemblement", table.concat(manque, " ; "))
    end
    eq.lv.groupesT = eq.lv.groupesT or t
    local Q1, Q2 = {}, {}
    for _, x in ipairs(X) do if x.cote == 1 then Q1[#Q1 + 1] = x else Q2[#Q2 + 1] = x end end
    local ok1, p1 = lvGroupeProuve(eq, X, 1, Q1, lvTrouver(X, eq.noms[1]))
    local ok2, p2 = lvGroupeProuve(eq, X, 2, Q2, lvTrouver(X, eq.noms[5]))
    if not (ok1 and ok2) and t - eq.lv.groupesT < 180000 then
        eq.lv.rassOk = nil
        return attenteLarves(eq, "rassemblement", "groupes en jeu : " .. (ok1 and "" or ("cote 1 " .. tostring(p1) .. " ")) .. (ok2 and "" or ("cote 2 " .. tostring(p2))))
    end
    if eq.lv.rassOk == nil then eq.lv.rassOk = t return end
    if t - eq.lv.rassOk < 2000 then return end
    if not (ok1 and ok2) then log("[LARVES] g=" .. g .. " : groupes en jeu non prouves apres 180 s -> entree quand meme (ils se reforment en salle 1, aucun combat sans preuve)") end
    lvPoserPhase(eq, "entree", "les 8 sur l entree avec un oeuf")
    return lvEntree(eq, lvLireTous(eq))
end
function lvLireTous(eq)
    local X = {}
    for i, n in ipairs(eq.noms) do X[#X + 1] = lvLire(eq, n, i) end
    eq.lv.X = X
    return X
end
function lvMachineCote(eq, X, c)
    local M, Q = lvQueue(eq, X, c)
    local S = eq.lv.S[c]
    if M == nil then eq.lv.S[c] = {} return end
    if S.M ~= M then S = { M = M, etat = "arrivee", t = lvT(), essaisCombat = 0 } ; eq.lv.S[c] = S end
    if M == LARVES_D.ENTREE or M == LARVES_D.SORTIE then return end
    local C = LARVES_D.CARTE[M]
    if C == nil or C.levier ~= nil then return end
    if S.etat == "transit" then return lvSuiteTransit(eq, X, c, S, Q, M) end
    if S.etat == "combat" then return lvSuiteCombat(eq, X, c, S, Q, M) end
    if S.etat == "barriere" then return end
    for _, x in ipairs(X) do
        if x.cote == c and x.actif and not x.dedans then return attenteLarves(eq, "cote " .. c, lvNom(x) .. " hors du donjon (" .. tostring(x.carte) .. ")") end
    end
    local chefX = nil
    for _, x in ipairs(Q) do
        if x.chef then chefX = x end
        if not x.co or x.perdu then return attenteLarves(eq, "cote " .. c, lvNom(x) .. " deconnecte (" .. M .. ")") end
        if x.combat then return attenteLarves(eq, "cote " .. c, lvNom(x) .. " en combat (" .. M .. ")") end
        if not x.vivant then return attenteLarves(eq, "cote " .. c, lvNom(x) .. " : script pas pret (" .. M .. ")") end
    end
    if tonumber(lvMem(eq, "VALIDE_" .. c .. "_" .. M)) == eq.lv.gen then
        if C.antichambre then S.etat = "barriere" return end
        if chefX == nil then S.sansChef = S.sansChef or lvT() ; return attenteLarves(eq, "cote " .. c, "chef du cote absent de " .. M) end
        S.sansChef = nil
        return lvLancerTransit(eq, X, c, S, Q, M, false)
    end
    local req = lvCombatRequis(eq, X, S, Q, M, c)
    if req == "non" then
        if C.antichambre then
            log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : antichambre " .. M .. " sans combat -> barriere du levier")
            S.etat = "barriere"
            S.barriereSansCombat = not C.sansCombat
            return
        end
        if chefX == nil then S.sansChef = S.sansChef or lvT() ; return attenteLarves(eq, "cote " .. c, "chef du cote absent de " .. M) end
        S.sansChef = nil
        return lvLancerTransit(eq, X, c, S, Q, M, true)
    end
    if req ~= "oui" then return attenteLarves(eq, "cote " .. c .. " " .. M, "lecture des groupes de monstres") end
    if chefX == nil then S.sansChef = S.sansChef or lvT() ; return attenteLarves(eq, "cote " .. c, "chef du cote absent de " .. M .. " (pas de combat sans lui)") end
    S.sansChef = nil
    if C.commune then
        local autre = 3 - c
        local So = eq.lv.S[autre] or {}
        if So.M == M and So.etat == "combat" then return attenteLarves(eq, "cote " .. c .. " " .. M, "l autre cote combat sur cette carte") end
        for _, x in ipairs(X) do
            if x.cote == autre and x.carte == M and x.combat then return attenteLarves(eq, "cote " .. c .. " " .. M, "l autre cote est en combat") end
        end
        if c == 2 and tonumber(lvMem(eq, "VALIDE_1_" .. M)) ~= eq.lv.gen then
            for _, x in ipairs(X) do
                if x.cote == 1 and x.actif and x.carte == M then return attenteLarves(eq, "cote 2 " .. M, "le cote 1 combat d abord") end
            end
        end
    end
    local etatAutre = (eq.lv.S[3 - c] or {}).etat
    if FIGHT_BLOQUANT == true and (etatAutre == "transit" or etatAutre == "combat" or etatAutre == "valide") then
        return attenteLarves(eq, "cote " .. c .. " " .. M, "combat bloquant differe : l autre cote finit son combat / son transit")
    end
    if #Q < 2 then S.seul = S.seul or lvT() ; return attenteLarves(eq, "cote " .. c, "pas de combat seul sur " .. M) end
    S.seul = nil
    local okG, pq = lvGroupeProuve(eq, X, c, Q, chefX)
    if not okG then return attenteLarves(eq, "cote " .. c .. " " .. M, "groupe : " .. tostring(pq)) end
    return lvLancerCombat(eq, X, c, S, Q, M, chefX)
end
function lvLancerCombat(eq, X, c, S, Q, M, chefX)
    S.membres, S.nbc0, S.vus = {}, {}, {}
    for _, x in ipairs(Q) do S.membres[#S.membres + 1] = x.n ; S.nbc0[x.n] = x.nbc end
    local t0 = lvT()
    local ok = sur(function() return chefX.a.map:fight() end, nil)
    local duree = lvT() - t0
    if duree > 4000 and FIGHT_BLOQUANT ~= true then
        FIGHT_BLOQUANT = true
        log("[LARVES] map:fight() appele par le controller a bloque " .. duree .. " ms : participation prouvee par les compteurs de combats")
    end
    S.etat, S.tLance, S.finT = "combat", lvT(), nil
    S.essaisCombat = (S.essaisCombat or 0) + 1
    eq.lv.verrou[M] = c
    log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : combat sur " .. M .. " lance par " .. lvNom(chefX) .. " (" .. #Q
        .. " membres : " .. lvNoms(Q) .. ", essai " .. S.essaisCombat .. ", fight=" .. tostring(ok) .. ")")
end
function lvEntree(eq, X)
    local t = lvT()
    local reste = {}
    for _, x in ipairs(X) do if not x.dedans then reste[#reste + 1] = x end end
    if #reste == 0 then return lvPoserPhase(eq, "donjon", "les 8 dans le donjon") end
    if t - eq.lv.tPhase > 15 * 60000 then
        local compter = true
        for _, x in ipairs(reste) do if lvRefusServeur(eq, x.n) then compter = false end end
        return lvDeclencherReprise(eq, X, "R9", "entree incomplete apres 15 min (" .. lvNoms(reste) .. ")"
            .. (compter and "" or " ; compte indisponible (serveur) : non comptee"), compter)
    end
    for _, x in ipairs(reste) do
        local e = eq.lv.essaisEntree[x.n]
        local sig = x.oeuf .. ":" .. x.clef
        if e == nil or e.sig ~= sig then e = { n = 0, t = 0, sig = sig } ; eq.lv.essaisEntree[x.n] = e end
        local ici = (x.a ~= nil) and mapDe(x.a) or ""
        if ici == LARVES_D.ENTREE and x.co and not x.combat and not x.busy and (x.oeuf + x.clef) > 0
           and e.n < 3 and t - e.t >= 4000 then
            e.n, e.t = e.n + 1, t
            if x.oeuf > 0 and not (e.n >= 3 and x.clef > 0) then
                sur(function() return x.a.inventory:useItem(LARVES_D.OEUF) end, nil)
                log("[LARVES] g=" .. eq.lv.gen .. " entree : " .. lvNom(x) .. " -> oeuf 7423 (essai " .. e.n .. ")")
            else
                sur(function() return x.a.map:door(LARVES_D.PORTE_ENTREE) end, nil)
                log("[LARVES] g=" .. eq.lv.gen .. " entree : " .. lvNom(x) .. " -> porte 220 avec la clef (essai " .. e.n .. ")")
            end
        end
    end
    return attenteLarves(eq, "entree", "pas encore dans le donjon : " .. lvNoms(reste))
end
function lvChargerEtat(eq)
    local g = tonumber(lvMem(eq, "GEN")) or 0
    if eq.lv == nil or eq.lv.gen ~= g then
        local recharge = (eq.lv == nil)
        eq.lv = lvNouvelEtat(g, eq.lv)
        if recharge then eq.lv.observerJusque = lvT() + 1500 end
        for k = 1, 2 do
            local lg, et, t1, t2, ech, nul = lvMem(eq, "LEV_" .. k):match("^(%d+):(%a+):([^:]*):([^:]*):(%d+):(%d+)$")
            if tonumber(lg) == g and et ~= nil then
                local L = lvL(eq, k)
                L.etat = (et == "ouverture") and "placement" or et
                L.t1 = (t1 ~= "") and t1 or nil
                L.t2 = (t2 ~= "") and t2 or nil
                L.echecs, L.nulles = tonumber(ech) or 0, tonumber(nul) or 0
                L.tEtat = lvT()
            end
        end
    end
    local gp, ph = lvMem(eq, "PHASE"):match("^(%d+):(%a+)$")
    if tonumber(gp) ~= g then ph = nil end
    if eq.lv.phase ~= ph then eq.lv.phase, eq.lv.tPhase = ph, lvT() end
    eq.lv.tent = tonumber(lvMem(eq, "TENT")) or 0
end
function lvAllerVers(eq, x, cible, seuil)
    if cible == nil or x.a == nil then return "bloque" end
    if x.combat or not x.co or x.perdu then return "bloque" end
    local m = eq.lv.marche[x.n]
    if m == nil or m.cible ~= cible or m.carte ~= x.carte then
        m = { cible = cible, carte = x.carte, envoi = 0, case = x.cell, bouge = 0, essais = 0, refus = 0, dernier = nil }
        eq.lv.marche[x.n] = m
    end
    if x.cell == cible then return "arrive" end
    local t = lvT()
    if x.cell ~= m.case then m.case, m.bouge = x.cell, t end
    if eq.lv.observerJusque ~= nil and t < eq.lv.observerJusque then return "en_route" end
    if m.bouge > 0 and t - m.bouge < 900 then return "en_route" end
    if m.envoi > 0 then
        if m.dernier == false then
            if t - m.envoi < 150 then return "refuse" end
        else
            local d = tonumber(sur(function() return x.a.map:cellDistance(x.cell, cible) end, nil)) or 10
            local s = seuil or math.max(1500, 350 * d + 800)
            if t - math.max(m.envoi, m.bouge) < s then return "en_route" end
        end
    end
    if x.busy then return "bloque" end
    local ok = sur(function() return x.a.map:moveToCell(cible) end, nil)
    m.envoi, m.dernier, m.essais = t, ok, m.essais + 1
    if ok == false then m.refus = m.refus + 1 ; return "refuse" end
    return "envoye"
end
function lvSignalerHumain(eq, l)
    local cle, textes = "", {}
    for _, i in ipairs(l or {}) do cle = cle .. i.x.n .. ":" .. tostring(i.raison) .. ";" ; textes[#textes + 1] = i.texte end
    local g = (eq.lv and eq.lv.gen) or 0
    if cle == "" then
        if eq.lvHumain ~= nil then
            eq.lvHumain = nil
            lvEcrire(eq, "ATTENTE_HUMAINE", "")
            log("[LARVES] g=" .. g .. " : intervention humaine levee (compte de nouveau connecte) -> reprise automatique")
            lvJournal(eq, "Larves : intervention humaine levee", "compte de nouveau connecte", "reprise automatique du protocole")
        end
        return false
    end
    if eq.lvHumain ~= cle then
        eq.lvHumain = cle
        local texte = table.concat(textes, " ; ")
        lvEcrire(eq, "ATTENTE_HUMAINE", g .. ":" .. texte)
        log("[LARVES] ALERTE g=" .. g .. " : INTERVENTION HUMAINE : " .. texte .. " -> aucune action sur ce compte (jamais de"
            .. " reconnexion forcee), aucune tentative comptee pour ce motif ; le controller repart SEUL des sa reconnexion")
        lvJournal(eq, "Larves : " .. texte, "compte indisponible (phase " .. tostring(eq.lv and eq.lv.phase) .. ")",
            "intervention humaine (abonnement / compte) ; attente sans tentative comptee, reprise automatique a la reconnexion")
    end
    return true
end
function lvRaisonRefus(x)
    if x == nil or x.a == nil then return nil end
    local L = sur(function() return x.a.global:consoleLines() end, nil)
    if type(L) ~= "table" then return nil end
    local n = 0
    pcall(function() n = #L end)
    local abonnementVide = false
    for i = n, math.max(1, n - 40), -1 do
        local l = tostring(L[i] or "")
        if l:find("[RUN]", 1, true) or l:find("[CTRL]", 1, true) then break end
        local r = l:match("Impossible de se connecter au serveur %(Raison : ([%w_%-]+)%)")
        if r ~= nil then return r end
        if l:match("Abonnement: %-%s*$") then abonnementVide = true end
    end
    if abonnementVide then return "SubscriberOnly" end
    return nil
end
function lvSuiteTransit(eq, X, c, S, Q, M)
    local C = LARVES_D.CARTE[M]
    local passes, restes = 0, {}
    for _, n in ipairs(S.partants or {}) do
        local x = lvTrouver(X, n)
        if x ~= nil and x.carte ~= M and not x.perdu then passes = passes + 1
        elseif x ~= nil then restes[#restes + 1] = x end
    end
    if #restes == 0 then
        eq.lv.S[c] = {}
        return log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : transit fini depuis " .. M .. " (" .. passes .. " passes)")
    end
    local t = lvT()
    local sign = tostring(passes)
    local perdu = false
    for _, x in ipairs(restes) do sign = sign .. ":" .. tostring(x.cell) ; if x.perdu or not x.co then perdu = true end end
    if sign ~= S.signTransit or perdu then S.signTransit, S.cyclesSansProgres = sign, 0
    else S.cyclesSansProgres = (S.cyclesSansProgres or 0) + 1 end
    local chefReste = false
    for _, x in ipairs(restes) do if x.chef then chefReste = true end end
    if (S.cyclesSansProgres or 0) * CYCLE_MS > 20000 then
        if passes == 0 and S.sansCombat then
            S.etat, S.sansCombatEchoue, S.unT, S.zeroT = "arrivee", true, nil, nil
            return log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : sortie de " .. M .. " refusee sans combat -> on attend les monstres")
        end
        S.partiels = (S.partiels or 0) + 1
        if chefReste and #restes >= 2 and S.partiels <= 3 then
            lvEcrire(eq, "VALIDE_" .. c .. "_" .. M, "")
            local np = S.partiels
            eq.lv.S[c] = { M = M, etat = "arrivee", t = t, essaisCombat = 0, sansCombatEchoue = true, partiels = np }
            return log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : transit partiel depuis " .. M .. " (" .. passes .. "/" .. #S.partants
                .. ") -> les restants (" .. lvNoms(restes) .. ", avec le chef) refont le combat")
        end
        if S.r7 == nil then S.r7 = "transit partiel depuis " .. M .. " (" .. passes .. "/" .. #S.partants .. " passes, restent " .. lvNoms(restes) .. ")" end
        return
    end
    local attendre = false
    for _, x in ipairs(restes) do
        if not x.chef then
            S.envoiT[x.n] = S.envoiT[x.n] or t
            if t - S.envoiT[x.n] < 1000 then attendre = true end
        end
    end
    for _, x in ipairs(restes) do
      if not (x.chef and attendre) then
        local sortie = C.sortie[c]
        LV_SECOURS = LV_SECOURS or {}
        if C.secours ~= nil and C.secours[c] ~= nil and (S.secours or LV_SECOURS[M .. ":" .. c] or (S.refus[x.n] or 0) >= 2) then
            sortie = C.secours[c]
            if not S.secours then
                S.secours = true
                LV_SECOURS[M .. ":" .. c] = true
                log("[LARVES] g=" .. eq.lv.gen .. " cote " .. c .. " : sortie " .. tostring(C.sortie[c]) .. " de " .. M .. " impraticable -> sortie de secours " .. sortie .. " pour tout le cote")
            end
        end
        local r = lvVersDeclencheur(eq, x, sortie)
        local mm = eq.lv.marche[x.n] or {}
        if mm.cible == sortie and (r == "refuse" or (r == "envoye" and (mm.essais or 0) >= 2)) then S.refus[x.n] = (S.refus[x.n] or 0) + 1 end
      end
    end
end
function lvSurDalles(eq, K, L, H)
    for essai = 1, 2 do
        for h = 1, 2 do
            local x = lvTrouver(H[h], (h == 1) and L.t1 or L.t2)
            if x == nil then return false end
            local y = lvRelirePos(eq, x)
            if y.cell ~= K[h].dalle or y.combat or y.perdu then return false end
            if sur(function() return x.a.character:isBusy() end, false) == true then return false end
        end
        if essai == 1 then global:delay(300) end
    end
    return true
end
function lvIndispoDe(eq, n)
    for _, i in ipairs(eq.lvIndispoListe or {}) do if i.x.n == n then return i end end
    return nil
end
function lvTexteHumain(eq)
    local t = {}
    for _, i in ipairs(eq.lvIndispoListe or {}) do t[#t + 1] = i.texte end
    return table.concat(t, " ; ")
end
function lvVersDeclencheur(eq, x, cell)
    eq.lv.decolle = eq.lv.decolle or {}
    local d = eq.lv.decolle[x.n]
    if d ~= nil and (d.carte ~= x.carte or d.cell ~= cell or d.gen ~= eq.lv.decolleGen) then d = nil ; eq.lv.decolle[x.n] = nil end
    if x.cell == cell then
        if d == nil then
            local v = lvVoisine(eq, x)
            d = { carte = x.carte, cell = cell, v = v or false, gen = eq.lv.decolleGen }
            eq.lv.decolle[x.n] = d
            if v then return lvAllerVers(eq, x, v) end
            return "bloque"
        elseif d.v and not d.fait then
            return lvAllerVers(eq, x, d.v)
        end
        return "arrive"
    end
    if d ~= nil and d.v and x.cell == d.v then d.fait = true end
    if d ~= nil and d.v and not d.fait then return lvAllerVers(eq, x, d.v) end
    return lvAllerVers(eq, x, cell)
end
function lvDeclencherReprise(eq, X, code, detail, compter)
    for _, x in ipairs(X) do
        if x.combat then
            return attenteLarves(eq, "reprise", "fin du combat de " .. lvNom(x) .. " attendue avant la reprise (" .. tostring(code) .. " : " .. tostring(detail) .. ")")
        end
    end
    if code == "R10" then
        local pg, pc = lvMem(eq, "DERNIER_CODE"):match("^(%d+):(.*)$")
        if pc == "R10" and tonumber(pg) == eq.lv.gen then return lvAlerte(eq, "R10 deux tentatives de suite : " .. tostring(detail)) end
    end
    log("[LARVES] REPRISE g=" .. eq.lv.gen .. " cause=" .. tostring(code) .. " " .. tostring(detail))
    lvJournal(eq, "Larves : " .. tostring(detail), tostring(code), "reprise automatique (sortie de tous ceux qui sont dedans, oeuf, entree a 8)")
    return lvNouvelleGeneration(eq, "reprise", code, detail, compter)
end
function lvSurveillerAlerte(eq)
    local P = lvP(eq)
    eq.lvAlerteDepuis = eq.lvAlerteDepuis or lvMaintenant()
    eq.lvAutoReprises = eq.lvAutoReprises or {}
    if lvMaintenant() - eq.lvAlerteDepuis >= 300 then
        local recentes = {}
        for _, t in ipairs(eq.lvAutoReprises) do if lvMaintenant() - t < 7200 then recentes[#recentes + 1] = t end end
        eq.lvAutoReprises = recentes
        if #recentes < 3 then
            eq.lvAutoReprises[#eq.lvAutoReprises + 1] = lvMaintenant()
            eq.lvAlerteDepuis = nil
            memEcrire(P .. "TENT", 0)
            pcall(function() developer:deleteFromGlobalMemory(P .. "PHASE") end)
            eq.etat = "larves"
            log("[LARVES] alerte levee AUTOMATIQUEMENT pour " .. eq.nomChef .. " (reprise auto " .. #eq.lvAutoReprises .. "/3 sur 2 h)")
            lvJournal(eq, "Larves : alerte levee automatiquement", "plafond de tentatives ou blocage", "TENT = 0, PHASE videe, nouvelles tentatives")
            return
        end
    end
    local g = tonumber(mem(P .. "GEN")) or 0
    local gp, ph = tostring(mem(P .. "PHASE") or ""):match("^(%d+):(%a+)$")
    if tonumber(gp) ~= g or ph ~= "alerte" then
        eq.lvAlerteDepuis = nil
        eq.etat = "larves"
        log(eq.nomChef .. " : alerte Larves levee (phase " .. tostring(ph) .. ") -> pilotage v2")
    end
end
function lvDoitEncoreCombattre(eq, x)
    local r = x.r or 0
    if r < 12 then return true end
    return r == 12 and tonumber(lvMem(eq, "VALIDE_" .. x.cote .. "_96998917")) ~= eq.lv.gen
end
function nbGroupesLv(a)
    local v = sur(function() return a.map:monsterGroups() end, nil)
    if v == nil then return nil end
    local n1, n2 = 0, 0
    pcall(function() for _ in ipairs(v) do n1 = n1 + 1 end end)
    pcall(function() for _ in pairs(v) do n2 = n2 + 1 end end)
    return math.max(n1, n2)
end
function lvRefusServeur(eq, n)
    local i = lvIndispoDe(eq, n)
    return i ~= nil and i.raison ~= nil
end
function lvAlerte(eq, cause)
    local g = eq.lv.gen
    for _, n in ipairs(eq.noms) do lvEcrire(eq, "MODE_" .. n, g .. ":stop") end
    lvPoserPhase(eq, "alerte", cause)
    pcall(function() lvVerrouRendre(eq) end)
    eq.etat = "larves_alerte"
    log("[LARVES] ALERTE g=" .. g .. " : " .. tostring(cause) .. " -> plus aucune action automatique. Pour reprendre : RSL_"
        .. eq.nomChef .. "_TENT = 0 et RSL_" .. eq.nomChef .. "_PHASE vide (le controller repart seul)")
    lvJournal(eq, "Larves : ALERTE (" .. tostring(cause) .. ")", tostring(cause),
        "aucune action automatique ; pour reprendre : RSL_<chef>_TENT = 0 et RSL_<chef>_PHASE vide")
end
function lvSecoursSortie(eq, x)
    local g, t = eq.lv.gen, lvT()
    eq.lv.sortieDepuis[x.n] = eq.lv.sortieDepuis[x.n] or t
    local sg, sn = lvMem(eq, "SORTIE_FAITE_" .. x.n):match("^(%d+):(%d+)$")
    local essaye = tonumber(sg) == g and (tonumber(sn) or 0) >= 1
    if t - eq.lv.sortieDepuis[x.n] > 60000 and (eq.lv.sortieOutil[x.n] == nil or t - eq.lv.sortieOutil[x.n] > 90000)
       and x.co and not x.perdu and not x.combat then
        eq.lv.sortieOutil[x.n] = t
        log("[LARVES] " .. lvNom(x) .. " toujours dans le donjon apres 60 s -> outil de sortie (outils\\sortir-donjon.lua)")
        pcall(function() x.a:stopScript() end)
        lancer(x.a, "outils\\sortir-donjon.lua")
    end
end

LV_VERROU_FICHIER = DOSSIER .. "\\etat\\larves-verrou.txt"
LV_VERROU_PERIME_S = 2400
LV_VERROU_ACTIF = false
function lvAActiver(eq)
    if not lvActif() then return false end
    local P = lvP(eq)
    local g = tonumber(mem(P .. "GEN")) or 0
    local gp, ph = tostring(mem(P .. "PHASE") or ""):match("^(%d+):(%a+)$")
    if tonumber(gp) ~= g then ph = nil end
    local etape = lvEtapeEquipe(eq)
    if ph == "fini" then
        if etape ~= nil and LARVES_N ~= nil and etape > LARVES_N then
            memEcrire(P .. "GEN", g + 1)
            memEcrire(P .. "PHASE", "")
            log(eq.nomChef .. " : Larves finies et etape " .. etape .. " atteinte -> tentative " .. g .. " close")
        end
        return false
    end
    if ph == "alerte" then return false end
    if LARVES_N ~= nil and etape == LARVES_N then return true end
    if etape == nil or etape == LARVES_N then
        for _, a in ipairs(comptes(eq)) do if LARVES_D.dedans(mapDe(a)) then return true end end
    end
    for _, n in ipairs(eq.noms) do
        if tostring(mem(P .. "VU_" .. n) or ""):match(":veille$") then return true end
    end
    return false
end
function larves(eq)
    if not lvActif() then
        return attenteLarves(eq, "v2", "protocole Larves v2 installe, en attente de mise en service (LARVES_V2_ACTIF = true dans Settings.lua)")
    end
    if eq.mode ~= "solo" then
        if lvEquipeNative(eq) then return passerEnSolo(eq) else eq.mode = "solo" end
    end
    lvChargerEtat(eq)
    if lvMem(eq, "PAUSE") == "1" then return attenteLarves(eq, "pause", "RSL_" .. eq.nomChef .. "_PAUSE = 1") end
    local X = lvLireTous(eq)
    lvSignalerHumain(eq, lvIndisponibles(eq, X))
    if not lvMigration(eq, X) then return end
    lvRelancerScripts(eq, X)
    lvPreuveGroupeTexte(eq, X)
    if lvMem(eq, "FORCER_REPRISE") == "1" then
        lvEcrire(eq, "FORCER_REPRISE", 0)
        return lvDeclencherReprise(eq, X, "MANUEL", "demande operateur (RSL_" .. eq.nomChef .. "_FORCER_REPRISE)", true)
    end
    local ph = eq.lv.phase
    local etape = lvEtapeEquipe(eq)
    if etape ~= nil and LARVES_N ~= nil and etape ~= LARVES_N and ph ~= "fini" then
        local dedans = false
        for _, x in ipairs(X) do if x.dedans then dedans = true end end
        if not dedans then
            log(eq.nomChef .. " : etape de l equipe " .. etape .. " (pas les Larves) -> retour a la run")
            lvVerrouRendre(eq)
            eq.etat, eq.runLance = "run", false
            return
        end
    end
    local dedansV = false
    for _, x in ipairs(X) do if x.dedans then dedansV = true end end
    if ph == "fini" or ph == "alerte" then lvVerrouRendre(eq)
    else
        local okV, autreV = lvVerrouPrendre(eq)
        if not okV and not dedansV and (ph == nil or ph == "rassemblement") then
            return attenteLarves(eq, "verrou", "une autre team est aux Larves (" .. tostring(autreV) .. ") : on attend notre tour devant l entree")
        end
    end
    if ph == nil then return lvDemarrer(eq, X) end
    if ph == "rassemblement" then return lvRassemblement(eq, X) end
    if ph == "entree" then return lvEntree(eq, X) end
    if ph == "donjon" then return lvDonjon(eq, X) end
    if ph == "reprise" then return lvReprise(eq, X) end
    if ph == "fini" then return lvFin(eq, X) end
    if ph == "alerte" then eq.etat = "larves_alerte" return end
end
function lvVerrouEcrire(contenu)
    pcall(function() local f = io.open(LV_VERROU_FICHIER, "w") if f then f:write(contenu) f:close() end end)
end
function lvVerrouLire()
    local chefV, tV = nil, 0
    pcall(function()
        local f = io.open(LV_VERROU_FICHIER, "r")
        if f then
            local l = f:read("*a") or "" f:close()
            local a, b = l:match("^([^|]+)|(%d+)")
            chefV, tV = a, tonumber(b) or 0
        end
    end)
    return chefV, tV
end
function lvVerrouRendre(eq)
    local chefV = lvVerrouLire()
    if chefV == eq.nomChef then lvVerrouEcrire("") log("[LARVES] verrou rendu par " .. eq.nomChef) end
end
function lvMaintenant() return math.floor(tonumber((tostring(os.time()):gsub(",", "."))) or 0) end
function restaurerEquipeLarves()
    if not lvActif() then return end
    if RESTAURATION_LARVES_T ~= nil and lvS() - RESTAURATION_LARVES_T < 30 then return end
    RESTAURATION_LARVES_T = lvS()
    for _, a in ipairs(sur(function() return ankabotController:getLoadedAccounts() end, {})) do
        local n = nomDe(a)
        if n ~= nil and EQUIPES[n] == nil then
            local liste = tostring(mem("RS_EQUIPE_DE_" .. n) or "")
            local P = "RSL_" .. n .. "_"
            local g = tonumber(mem(P .. "GEN")) or 0
            local gp, ph = tostring(mem(P .. "PHASE") or ""):match("^(%d+):(%a+)$")
            if liste:match("^([^,]+)") == n and tonumber(gp) == g
               and (ph == "rassemblement" or ph == "entree" or ph == "donjon" or ph == "reprise") then
                local noms = {}
                for nm in liste:gmatch("[^,]+") do noms[#noms + 1] = nm end
                EQUIPES[n] = { nomChef = n, noms = noms, etat = "larves", mode = "solo", relances = {}, passeurSolo = true,
                               releveFait = true, runLance = true }
                log("equipe " .. n .. " restauree depuis la memoire (Larves v2, tentative " .. g .. ", phase " .. ph .. ")")
            end
        end
    end
end
function lvVerrouPrendre(eq)
    if not LV_VERROU_ACTIF then return true end
    local chefV, tV = lvVerrouLire()
    local t = lvMaintenant()
    if chefV == nil or chefV == "" or chefV == eq.nomChef or t - tV > LV_VERROU_PERIME_S then
        if chefV ~= eq.nomChef then log("[LARVES] verrou pris par " .. eq.nomChef .. (chefV and chefV ~= "" and (" (ancien : " .. chefV .. ", perime)") or "")) end
        if chefV ~= eq.nomChef or t - tV >= 30 then lvVerrouEcrire(eq.nomChef .. "|" .. t) end
        return true
    end
    return false, chefV
end

PAUSE_SACRI = false
function stopped() end
function phenix() return {} end
function bank() return {} end
function cycle()
    if PAUSE_SACRI then global:delay(CYCLE_MS) return end
    detecterEquipes()
    if restaurerEquipeLarves ~= nil then pcall(restaurerEquipeLarves) end
    pcall(verifierLancements)
    pcall(assurerBanque)
    for _, eq in pairs(EQUIPES) do
        local ok, err = pcall(function()
            if equipePausee(eq) then return end
            if verifierTransition(eq) then return end
            if eq.etat == "analyse" then analyser(eq)
            elseif eq.etat == "preparation" then preparation(eq)
            elseif eq.etat == "stuff_run" then stuffRun(eq)
            elseif eq.etat == "pl" then pl(eq)
            elseif eq.etat == "zaap" then zaap(eq)
            elseif eq.etat == "run" then run(eq)
            elseif eq.etat == "larves" then larves(eq)
            elseif eq.etat == "larves_alerte" then lvSurveillerAlerte(eq)
            elseif eq.etat == "rejoindre" then rejoindre(eq)
            elseif (eq.etat == "fini" or tostring(eq.etat):find("^cyc_")) and cycleFin ~= nil then cycleFin(eq)
            end
        end)
        if not ok then log(eq.nomChef .. " : erreur " .. tostring(err)) end
    end
    global:delay(CYCLE_MS)
end
function banned() end
if not RELANCES_RAZ_1300 then
    RELANCES_RAZ_1300 = true
    for _, eq in pairs(EQUIPES or {}) do eq.relances = {} end
end
if not CORRECTION_REJOINDRE_1337 then
    CORRECTION_REJOINDRE_1337 = true
    for _, eq in pairs(EQUIPES or {}) do
        if eq.etat == "rejoindre" then eq.etat = "run"; eq.passeurSolo = true; eq.mode = "solo" end
    end
end
RATTRAPAGE_DISPERSION = false
if not CORRECTION_SOLO_1350 then
    CORRECTION_SOLO_1350 = true
    for _, eq in pairs(EQUIPES or {}) do
        if eq.etat == "rejoindre" then eq.etat = "run" end
        eq.passeurSolo = true
        eq.relances = {}
    end
end
EXCLUS_RELANCE = {}
SOLO_PARTOUT = true
if not CORRECTION_SOLO_1547 then
    CORRECTION_SOLO_1547 = true
    for _, eq in pairs(EQUIPES or {}) do
        if eq.etat == "run" then
            eq.passeurSolo = true
            passerEnSolo(eq, "tous_run")
            eq.runLance = true
            log(eq.nomChef .. " : correction 15:47 -> solo + relance des 8 (solo partout)")
        end
    end
end
pcall(function() dofile(DOSSIER .. "\\controller\\cycle_fin.lua") end)

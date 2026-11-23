
CYC_CHEMINS = {
    depot    = "outils\\fin-run-depot-coffre.lua",
    vidage   = "outils\\fin-run-vidage-banque.lua",
    reception = "outils\\fin-run-banque-reception.lua",
    frais    = "outils\\fin-run-kamas-frais.lua",
    reprise  = "outils\\fin-run-reprise-coffre.lua",
    clefsMule = "outils\\fin-run-clefs-mule.lua",
    clefsLeader = "outils\\fin-run-clefs-leader.lua",
    niv10    = "outils\\montee-niv10-piou.lua",
    banque   = "pl\\banque-sasa.lua",
}

function cycDepuis(eq) return cycTs() - (eq.cyc.depuis or cycTs()) end

function cycPhaseFin(eq)
    if eq.mode ~= "solo" then
        if eq.transition == nil then passerEnSolo(eq) end
        return
    end
    if not tousConnectes(eq) then return end
    for _, a in ipairs(comptes(eq)) do if enCombat(a) then return end end
    local c = eq.cyc
    c.ancien = {}
    for i, n in ipairs(eq.noms) do
        local a = frais(n)
        if i > 1 and niveauDe(a) < (tonumber(CIBLE_AUTRES_PERSOS) or 120) then
            return cycBloquer(eq, n .. " : niveau " .. niveauDe(a) .. " < " .. tostring(CIBLE_AUTRES_PERSOS) .. " : ce perso n'a pas fini sa montee")
        end
        c.ancien[n] = { id = idDe(a), nom = cycNomPerso(a) }
        memEcrire("FR_ROLE_" .. n, i == 1 and "leader" or "mule")
    end
    c.idLeader = c.ancien[eq.nomChef].id
    cycPhase(eq, "depot")
end

function cycKamas(a) return math.floor(tonumber(sur(function() return a.character:kamas() end, 0)) or 0) end

function cycPhase(eq, p, detail)
    eq.cyc.phase = p
    eq.cyc.depuis = cycTs()
    eq.cyc.sous = nil
    eq.etat = "cyc_" .. p
    log(eq.nomChef .. " : cycle de fin de run -> " .. p .. ((detail ~= nil and detail ~= "") and (" (" .. detail .. ")") or ""))
end

function cycLancer(eq, a, rel, cleLance)
    local n = nomDe(a)
    eq.cyc.lances = eq.cyc.lances or {}
    local L = eq.cyc.lances[cleLance .. n] or { n = 0, t = 0 }
    eq.cyc.lances[cleLance .. n] = L
    if joue(a) or enCombat(a) then return true end
    if L.n >= 4 then return false end
    if L.n > 0 and cycTs() - L.t < 8 then return true end
    L.n, L.t = L.n + 1, cycTs()
    log(eq.nomChef .. " : " .. n .. " -> " .. rel .. (L.n > 1 and (" (relance " .. (L.n - 1) .. ")") or ""))
    lancer(a, rel)
    return true
end

function cycPhaseVidage(eq)
    if not cycConnecteursOK(eq) then return end
    local c = eq.cyc
    local b = frais(COMPTE_BANQUE)
    if b == nil or not connecte(b) then
        if cycDepuis(eq) > 1800 then
            log("ALERTE " .. eq.nomChef .. " : compte banque " .. tostring(COMPTE_BANQUE) .. " absent ou deconnecte depuis 30 min : VIDAGE ABANDONNE, on passe a la rotation")
            return cycPhase(eq, "rotation", "vidage abandonne")
        end
        if b ~= nil then pcall(function() b:connect() end) end
        return
    end
    local noms = {}
    for _, n in ipairs(eq.noms) do noms[#noms + 1] = c.ancien[n].nom end
    local s = c.sous
    if s == nil then

        local v = tostring(mem("RS_CYCLE_BANQUE") or "")
        if v ~= "" and v ~= eq.nomChef then return end
        memEcrire("RS_CYCLE_BANQUE", eq.nomChef)
        memEcrire("FRV_BANQUE_FINI", 0)
        memEcrire("FRV_FIN", 0)
        memEcrire("FRV_RECEVEURS", table.concat(noms, ","))
        for _, nm in ipairs(noms) do
            for _, k in ipairs({ "FRV_PRET_", "FRV_MPOSE_", "FRV_POSE_", "FRV_FAIT_", "FRV_DEMANDE_" }) do memEcrire(k .. nm, 0) end
        end
        pcall(function() b:stopScript() end)
        lancer(b, CYC_CHEMINS.reception)
        c.sous = "donner"
        c.vidageDepuis = cycTs()
        log(eq.nomChef .. " : vidage -> reception lancee sur " .. tostring(COMPTE_BANQUE))
        return
    end
    if s == "donner" then
        local faits = 0
        for i, n in ipairs(eq.noms) do
            local a = frais(n)
            local v = tostring(mem("FRV_FAIT_" .. c.ancien[n].nom) or "")
            if v == "1" then faits = faits + 1
            elseif v == "echec" then
                memEcrire("FRV_FAIT_" .. c.ancien[n].nom, 0)
            elseif a ~= nil then
                if not cycLancer(eq, a, CYC_CHEMINS.vidage, "vidage") then
                    return cycBloquer(eq, n .. " : fin-run-vidage-banque.lua arrete 4 fois sans resultat")
                end
            end
        end
        if not joue(b) then lancer(b, CYC_CHEMINS.reception) end
        if faits == #eq.noms then
            memEcrire("FRV_FIN", 1)
            c.sous = "fermer"
            c.fermerDepuis = cycTs()
            log(eq.nomChef .. " : les 8 ont donne ; fin de la reception")
        elseif cycTs() - c.vidageDepuis > 5400 then
            cycBloquer(eq, "vidage non termine apres 90 min (" .. faits .. "/" .. #eq.noms .. ")")
        end
        return
    end
    if s == "fermer" then
        local fini = tostring(mem("FRV_BANQUE_FINI") or "") == "1" or not joue(b)
        if fini or cycTs() - c.fermerDepuis > 300 then
            pcall(function() b:stopScript() end)
            lancer(b, CYC_CHEMINS.banque)
            memEcrire("RS_CYCLE_BANQUE", "")
            cycPhase(eq, "rotation")
        end
    end
end

function cycMules(eq) return mules(eq) end

function cycNomPerso(a) return tostring(sur(function() return a.character:name() end, "")) end
function cycConnecteursOK(eq)
    for _, n in ipairs(eq.noms) do
        local a = frais(n)
        if a == nil then return false end
        if not connecte(a) then pcall(function() a:connect() end) return false end
    end
    return true
end

function cycPhaseKit(eq)
    if not cycConnecteursOK(eq) then return end
    local c = eq.cyc

    if tostring(COMPTE_BANQUE or "") ~= "" then
        local b = frais(COMPTE_BANQUE)
        if b ~= nil and connecte(b) and not joue(b) then
            log(eq.nomChef .. " : compte banque inactif -> pl\\banque-sasa.lua")
            lancer(b, CYC_CHEMINS.banque)
        end
    end
    c.kit = c.kit or {}
    local tous = true
    for _, a in ipairs(mules(eq)) do
        local n = nomDe(a)
        local id = c.nouveau[n].id
        local k = c.kit[n] or { etape = "frais" }
        c.kit[n] = k
        if k.etape ~= "fait" then
            tous = false
            if tostring(mem("RS_SASA_OK_" .. id) or "") == "1" then k.etape = "fait"
            elseif k.etape == "frais" then
                if cycKamas(a) >= 1500 or tostring(mem("FRK_" .. id) or "") == "1" then k.etape = "reprise"
                elseif not cycLancer(eq, a, CYC_CHEMINS.frais, "frais") then return cycBloquer(eq, n .. " : fin-run-kamas-frais.lua sans resultat") end
            elseif k.etape == "reprise" then
                local v = tostring(mem("FRR_" .. id) or "")
                if v == "1" then k.etape = "clefs"
                elseif v == "echec" then
                    if niveauDe(a) <= 10 then k.etape = "frais"; memEcrire("FRR_" .. id, 0)
                    else return cycBloquer(eq, n .. " : reprise au coffre en ECHEC (FRR_" .. id .. "), manque : " .. tostring(mem("FRR_MANQUE_" .. id) or "?")) end
                elseif not cycLancer(eq, a, CYC_CHEMINS.reprise, "reprise") then return cycBloquer(eq, n .. " : fin-run-reprise-coffre.lua sans resultat") end
            elseif k.etape == "clefs" then
                if not cycLancer(eq, a, CYC_CHEMINS.clefsMule, "clefs") then return cycBloquer(eq, n .. " : fin-run-clefs-mule.lua sans resultat (stock de clefs du Croca au compte banque ?)") end
            end
        end
    end
    local ch = chef(eq)
    local idL = c.idLeader
    local leaderFait = tostring(mem("RS_SASA_OK_" .. idL) or "") == "1"
    if not leaderFait then
        tous = false
        if not cycLancer(eq, ch, CYC_CHEMINS.clefsLeader, "clefsL") then
            local manque = tostring(mem("FRL_MANQUE_" .. idL) or "")
            if manque ~= "" and manque ~= "0" then
                log("ALERTE " .. eq.nomChef .. " : clefs de donjon manquantes au compte banque pour le leader : " .. manque .. " (on continue)")
            else
                return cycBloquer(eq, "leader : fin-run-clefs-leader.lua sans resultat (stock de clefs au compte banque ?)")
            end
        end
    end
    if tous then return cycPhase(eq, "relance") end
    if cycDepuis(eq) > 3 * 3600 then cycBloquer(eq, "kit non complet apres 3 h (clefs du Croca / kamas au compte banque ?)") end
end

function cycPhaseRelance(eq)
    local c = eq.cyc
    local s = c.sous
    if s == nil then
        if #eq.noms < 8 and not (TOLERE_MOINS_DE_8 == true) then
            return cycBloquer(eq, "l'equipe n'a que " .. #eq.noms .. " comptes : toujours 8 par equipe")
        end
        c.suivants = {}
        for i, n in ipairs(eq.noms) do
            local a = frais(n)
            if a == nil then return cycBloquer(eq, n .. " : compte non charge") end
            c.suivants[n] = (i == 1) and c.ancien[n].nom or c.nouveau[n].nom
            pcall(function() a:stopScript() end)
        end
        memEcrire("RS_" .. c.idLeader .. "_FINI", 0)
        memEcrire("RS_" .. c.idLeader .. "_ETAPE", 1)
        memEcrire("RS_STUFF_RUN_" .. eq.nomChef, "")
        for _, n in ipairs(eq.noms) do
            pcall(function() ankabotController:unloadAccountByUsername(n) end)
        end
        c.sous = "decharge"
        c.t = cycTs()
        return
    end
    if s == "decharge" then
        for _, n in ipairs(eq.noms) do
            if sur(function() return ankabotController:accountIsLoaded(n) end, false) then
                if cycTs() - c.t > 60 then return cycBloquer(eq, n .. " : toujours charge 60 s apres le dechargement") end
                return
            end
        end

        local ok = pcall(function() ankabotController:loadTeamAccount(eq.noms, eq.nomChef, false) end)
        if not ok then return cycBloquer(eq, "loadTeamAccount a echoue (groupe natif non charge)") end
        c.sous = "choix"
        c.t = cycTs()
        return
    end
    if s == "choix" then
        for _, n in ipairs(eq.noms) do
            if frais(n) == nil then
                if cycTs() - c.t > 60 then return cycBloquer(eq, n .. " : non charge apres loadTeamAccount") end
                return
            end
        end
        for _, n in ipairs(eq.noms) do
            local a = frais(n)
            pcall(function() a:forceServer(SERVEUR) end)
            pcall(function() a:forceChoose(c.suivants[n]) end)
            pcall(function() a:connect() end)
        end
        c.sous = "connexion"
        c.t = cycTs()
        return
    end
    if s == "connexion" then
        local tous = true
        for _, n in ipairs(eq.noms) do
            local a = frais(n)
            if a == nil or not connecte(a) then tous = false end
        end
        if not tous then
            if cycTs() - c.t > 300 then return cycBloquer(eq, "connexion du groupe incomplete apres 300 s") end
            return
        end
        for _, n in ipairs(eq.noms) do
            local a = frais(n)
            if cycNomPerso(a) ~= c.suivants[n] then
                return cycBloquer(eq, n .. " : joue " .. cycNomPerso(a) .. " au lieu de " .. tostring(c.suivants[n]) .. " (forceChoose non pris en compte)")
            end
        end
        log(eq.nomChef .. " : groupe recharge sur les persos suivants -> la prochaine run commence (analyse)")
        local nom = eq.nomChef
        EQUIPES[nom] = nil
        return
    end
end
function cycPersos(a)
    local msg = nil
    pcall(function() msg = a.global:charactersList() end)
    if msg == nil then pcall(function() msg = a:global():charactersList() end) end
    if msg == nil then return nil end
    local col = cycChamp(msg, { "characters", "Characters" })
    if col == nil then return nil end
    local liste = {}
    pcall(function()
        for _, e in ipairs(col) do
            local basic = cycChamp(e, { "character_basic_information", "characterBasicInformation", "CharacterBasicInformation" })
            local src = basic or e
            local nom = cycChamp(src, { "name", "Name" })
            local niv = cycChamp(src, { "level", "Level" })
            local id = cycChamp(e, { "id", "Id" })

            local classe = cycChamp(e, { "breed", "Breed", "breed_id", "BreedId" }) or cycChamp(src, { "breed", "Breed", "breed_id", "BreedId" })
            if classe == nil then
                local look = cycChamp(src, { "character_look", "characterLook", "CharacterLook", "look", "Look" })
                classe = cycChamp(look, { "breed_id", "breedId", "BreedId", "breed", "Breed" })
            end
            if id ~= nil then liste[#liste + 1] = { id = tostring(id), nom = (type(nom) == "string" and nom ~= "") and nom or nil, niveau = tonumber(niv), classe = tonumber(classe) } end
        end
    end)

    if #liste == 0 then
        local brut = 0
        pcall(function() brut = tonumber(col.Count) or 0 end)
        if brut == 0 then pcall(function() brut = #col end) end
        if (tonumber(brut) or 0) > 0 then return nil end
    end
    return liste
end

function cycPhaseDepot(eq)
    if not cycConnecteursOK(eq) then return end
    local c = eq.cyc
    local reste = 0
    for _, a in ipairs(mules(eq)) do
        local n = nomDe(a)
        local id = c.ancien[n].id
        local v = tostring(mem("FRD_" .. id) or "")
        if v == "echec" then
            return cycBloquer(eq, n .. " : depot au coffre en ECHEC (FRD_" .. id .. ") — objet protege reste sur le perso ou coffre inaccessible")
        elseif v ~= "1" then
            reste = reste + 1
            if not cycLancer(eq, a, CYC_CHEMINS.depot, "depot") then
                return cycBloquer(eq, n .. " : fin-run-depot-coffre.lua arrete 4 fois sans resultat")
            end
        end
    end
    if reste == 0 then
        if VIDAGE_ACTIF ~= false and tostring(COMPTE_BANQUE or "") ~= "" then cycPhase(eq, "vidage")
        else
            log(eq.nomChef .. " : pas de vidage (VIDAGE_ACTIF = false ou COMPTE_BANQUE vide)")
            cycPhase(eq, "rotation")
        end
    elseif cycDepuis(eq) > 3600 then
        cycBloquer(eq, "depot au coffre non termine apres 60 min")
    end
end

function cycBloquer(eq, raison)
    local c = eq.cyc
    c.bloqueeEn = c.phase
    eq.etat = "cyc_bloquee"
    log("ALERTE " .. eq.nomChef .. " : cycle de fin de run BLOQUE en phase " .. tostring(c.phase) .. " : " .. raison)
    journal(eq.nomChef, "cycle de fin de run bloque (" .. tostring(c.phase) .. ")", raison,
        "corriger puis mettre RS_CYCLE_REPRENDRE_" .. eq.nomChef .. " = 1 (la phase reprend)")
end

function cycPhaseRotation(eq)
    local c = eq.cyc
    if c.sous == nil and not cycConnecteursOK(eq) then return end
    local plafond = tonumber(MAX_PERSOS_PAR_COMPTE) or 5
    local seuil = tonumber(CIBLE_AUTRES_PERSOS) or 120
    local s = c.sous
    if s == nil then
        c.plan = {}
        for _, a in ipairs(mules(eq)) do
            local n = nomDe(a)
            local liste = cycPersos(a)
            if liste == nil then return cycBloquer(eq, n .. " : liste des personnages illisible (aucune creation a l'aveugle)") end
            local ancien = c.ancien[n]
            local meilleur = nil
            local nbFaits = 0
            for _, p in ipairs(liste) do
                if p.id ~= ancien.id and (p.classe == nil or p.classe == 11) then
                    if p.niveau ~= nil and p.niveau >= seuil then nbFaits = nbFaits + 1 end
                    if p.nom ~= nil and p.niveau ~= nil and p.niveau < seuil
                       and (meilleur == nil or p.niveau > meilleur.niveau) then meilleur = p end
                end
            end
            if meilleur ~= nil then
                c.plan[n] = { action = "choisir", nom = meilleur.nom, total = #liste, nbFaits = nbFaits + 1 }
            elseif #liste < plafond then
                c.plan[n] = { action = "creer", total = #liste, nbFaits = nbFaits + 1 }
            else
                return cycBloquer(eq, n .. " : " .. #liste .. " personnages et aucun a monter. Supprimez a la main un ancien personnage de ce compte")
            end
            log(eq.nomChef .. " : rotation " .. n .. " -> " .. (c.plan[n].action == "creer" and "nouveau Sacrieur" or ("perso existant " .. c.plan[n].nom)))
        end
        if tostring(SERVEUR or "") == "" or SERVEUR == "NomDuServeur" then
            return cycBloquer(eq, "SERVEUR non renseigne dans Settings.lua (necessaire a la creation de personnage)")
        end
        for _, a in ipairs(mules(eq)) do
            pcall(function() a:stopScript() end)
            pcall(function() a:disconnect() end)
        end
        c.sous = "deco"
        c.t = cycTs()
        return
    end
    if s == "deco" then
        for _, a in ipairs(mules(eq)) do
            if connecte(a) or sur(function() return a:isAccountConnected() end, false) then
                if cycTs() - c.t > 90 then return cycBloquer(eq, nomDe(a) .. " : toujours en ligne 90 s apres la deconnexion (reglage de prochaine connexion impossible)") end
                return
            end
        end
        for _, a in ipairs(mules(eq)) do
            local n = nomDe(a)
            local p = c.plan[n]
            pcall(function() a:forceServer(SERVEUR) end)
            if p.action == "creer" then
                local ok = false
                pcall(function() ok = (a:forceCreate(tonumber(CLASSE_A_CREER) or 11, false, 0, COULEURS_A_CREER) ~= false) end)
                if not ok then return cycBloquer(eq, n .. " : forceCreate refuse") end
            else
                pcall(function() a:forceChoose(p.nom) end)
            end
            pcall(function() a:connect() end)
        end
        c.sous = "connexion"
        c.t = cycTs()
        return
    end
    if s == "connexion" then
        local tous = true
        for _, a in ipairs(mules(eq)) do if not connecte(a) then tous = false end end
        if not tous then
            if cycTs() - c.t > 300 then return cycBloquer(eq, "connexion des mules incomplete apres 300 s (creation/choix du personnage)") end
            return
        end
        pcall(function() ankabotController:clearCreations() end)
        c.nouveau = {}
        for _, a in ipairs(mules(eq)) do
            local n = nomDe(a)
            local p = c.plan[n]
            local id, nom = idDe(a), cycNomPerso(a)
            local liste = cycPersos(a)
            local ok = false
            if p.action == "creer" then
                ok = (id ~= "" and id ~= c.ancien[n].id) and (liste ~= nil and #liste > p.total)
            else
                ok = (nom == p.nom)
            end
            if not ok then
                return cycBloquer(eq, n .. " : le personnage attendu n'est pas actif (id " .. id .. ", nom " .. nom .. ", plan " .. p.action .. ") — rien n'est relance a l'aveugle")
            end
            c.nouveau[n] = { id = id, nom = nom }
            local nb = (liste ~= nil and #liste) or (p.total + 1)
            local nFaits = p.nbFaits or 1

            memEcrire("RS_PREMIER_PERSO_" .. id, 0)
            memEcrire("RS_NB_PERSOS_" .. id, math.max(2, nb))
            memEcrire("RS_CIBLE_PL_" .. id, seuil)
            memEcrire("RS_ZAAP_FAIT_" .. id, 1)
            memEcrire("FRR_" .. id, 0)
            memEcrire("FRK_" .. id, 0)
            memEcrire("RS_SASA_OK_" .. id, 0)
            memEcrire("RS_NIV10_" .. id, 0)
            memEcrire("KIT_CROCA_" .. nom, (nFaits >= 3 and 25) or (nFaits == 2 and 35) or (nFaits == 1 and 50) or 100)
            log(eq.nomChef .. " : " .. n .. " joue maintenant " .. nom .. " (niveau " .. niveauDe(a) .. ")")
        end
        cycPhase(eq, "niv10")
    end
end

function cycChamp(obj, noms)
    if obj == nil then return nil end
    for _, nom in ipairs(noms) do
        local v = nil
        pcall(function() v = obj[nom] end)
        if v ~= nil then return v end
    end
    return nil
end

function cycTs() return math.floor(tonumber((tostring(os.time()):gsub(",", "."))) or 0) end
function cycPhaseNiv10(eq)
    if not cycConnecteursOK(eq) then return end
    local c = eq.cyc
    local cible = tonumber(NIVEAU_COFFRE) or 11
    local reste, minimum = 0, 999
    for _, a in ipairs(mules(eq)) do
        local niv = niveauDe(a)
        if niv < cible then
            reste = reste + 1
            if niv < minimum then minimum = niv end
            if not joue(a) and not enCombat(a) then
                local n = nomDe(a)
                c.nbRelances = c.nbRelances or {}
                if (c.nbRelances[n] or 0) < 12 then
                    c.nbRelances[n] = (c.nbRelances[n] or 0) + 1
                    log(eq.nomChef .. " : " .. n .. " (niveau " .. niv .. ") -> " .. CYC_CHEMINS.niv10)
                    lancer(a, CYC_CHEMINS.niv10)
                else
                    return cycBloquer(eq, n .. " : montee au niveau " .. cible .. " relancee 12 fois sans succes")
                end
            end
        end
    end
    if reste == 0 then
        for _, a in ipairs(mules(eq)) do if enCombat(a) then return end end
        for _, a in ipairs(mules(eq)) do pcall(function() a:stopScript() end) end
        return cycPhase(eq, "kit")
    end
    if cycDepuis(eq) > 4 * 3600 then cycBloquer(eq, "montee niveau " .. cible .. " non terminee apres 4 h (plus bas : " .. minimum .. ")") end
end



CYC_PHASES = {
    cyc_fin = cycPhaseFin, cyc_depot = cycPhaseDepot, cyc_vidage = cycPhaseVidage, cyc_rotation = cycPhaseRotation,
    cyc_niv10 = cycPhaseNiv10, cyc_kit = cycPhaseKit, cyc_relance = cycPhaseRelance,
}

function cycleFin(eq)
    if CYCLE_AUTO == false then
        if not eq.cycDit then eq.cycDit = true log(eq.nomChef .. " : RUN TERMINEE (CYCLE_AUTO = false : aucune rotation automatique)") end
        return
    end
    if eq.cyc == nil then
        eq.cyc = { phase = "fin", depuis = cycTs() }
        eq.etat = "cyc_fin"
        log(eq.nomChef .. " : cycle de fin de run (depot -> vidage -> rotation -> niveau 11 -> kit -> relance)")
    end
    if eq.etat == "cyc_bloquee" then
        if tostring(mem("RS_CYCLE_REPRENDRE_" .. eq.nomChef) or "") == "1" then
            memEcrire("RS_CYCLE_REPRENDRE_" .. eq.nomChef, 0)
            local p = eq.cyc.bloqueeEn or "fin"
            eq.cyc.lances = {}
            eq.cyc.sous = nil
            eq.cyc.depuis = cycTs()
            eq.cyc.phase = p
            eq.etat = "cyc_" .. p
            log(eq.nomChef .. " : cycle repris en phase " .. p)
        end
        return
    end
    local f = CYC_PHASES[eq.etat]
    if f ~= nil then f(eq) end
end

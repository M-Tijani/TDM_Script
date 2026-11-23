RN_GID = 939
RN_MOLO = 6740
RN_EPEE_GID = 434
RN_KACKITU_RELANCE = 6
RN_PM_MIN = 4
RN_PV_VOL_LEADER = 4300
RN_PACTE = false
RN_SOIGNE_PERTE = 150
RN_SORT = { fluctuation = 12763, transposition = 12736, attirance = 12735, hostilite = 12756,
            pacte = 12762, couronne = 12761 }
RN_POSSEDES = {
    chef = { [12763] = true, [12762] = true, [12756] = true, [12735] = true, [12761] = true, [12744] = true,
             [12746] = true, [12731] = true, [12732] = true },
    mule = { [12736] = true, [12762] = true, [12756] = true, [12735] = true, [12761] = true, [12744] = true,
             [12728] = true, [12727] = true, [12745] = true },
}
RN_CHEF = false
RN_PRIO = { [6739] = 100, [936] = 80, [935] = 70, [6742] = 60, [938] = 55, [937] = 40 }
RN_NOMS = { [6739] = "Rate Atinee", [936] = "Rat Li", [935] = "Rat Plapla", [6742] = "Rate Iboisee",
            [938] = "Scelee Rate", [937] = "Rat Sio", [6740] = "Rat Molo", [939] = "Rat Noir",
            [434] = "Epee Vorace" }
function rnPresent()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CreatureGenericId) == RN_GID and (tonumber(e.LifePoints) or 0) > 0 then return true end
    end
    return false
end
local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function rnPV() return tonumber(s(function() return fightCharacter:getLifePoints() end, 0)) or 0 end
function rnTour() return tonumber(s(function() return fightAction:getCurrentTurn() end, 0)) or 0 end
function rnEntite()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CreatureGenericId) == RN_GID and (tonumber(e.LifePoints) or 0) > 0 then
            local pm = math.max(tonumber(e.MP) or 0, tonumber(s(function() return e.Stats.movementPoints end, 0)) or 0, RN_PM_MIN)
            return { cell = tonumber(e.CellId), pm = pm, id = e.Id, gid = RN_GID, pv = tonumber(e.LifePoints) or 0 }
        end
    end
    return nil
end
local function nom(gid) return RN_NOMS[gid] or ("rat " .. tostring(gid)) end

RN_ETAT = RN_ETAT or { combat = nil, tour = 0, kackitu = nil, soigne = {}, interdits = {}, enCours = nil }
function rnPossede(id)
    id = tonumber(id)
    if id == nil then return false end
    if RN_ETAT.interdits and RN_ETAT.interdits[id] then return false end
    return (RN_CHEF and RN_POSSEDES.chef or RN_POSSEDES.mule)[id] == true
end
function rnNouveauCombat()
    local n = tostring(s(function() return global:getCountFight() end, "?"))
    local tour = rnTour()
    if RN_ETAT.combat ~= n or tour < (RN_ETAT.tour or 0) then
        RN_ETAT = { combat = n, tour = tour, kackitu = nil, soigne = {}, interdits = {}, enCours = nil }
    end
    RN_ETAT.interdits = RN_ETAT.interdits or {}
    local ec = RN_ETAT.enCours
    if ec ~= nil then
        if ec.tour == tour then
            RN_ETAT.interdits[ec.id] = true
            ksLog("RN : le sort " .. tostring(ec.nom) .. " (" .. ec.id .. ") a INTERROMPU le tour (sort non possede ?) -> retire pour ce combat")
        end
        RN_ETAT.enCours = nil
    end
    RN_ETAT.tour = tour
end
function rnSure(c, rn) if rn == nil then return true end return ksDist(c, rn.cell) > (rn.pm or RN_PM_MIN) + 1 end
function rnSoigne(id) return (RN_ETAT.soigne[tostring(id)] or -1) >= rnTour() end
function rnKackituPret()
    local tour = rnTour()
    local d = RN_ETAT.kackitu
    return d == nil or (tour - d) >= RN_KACKITU_RELANCE - 1, d
end
function rnAtteignables()
    local L = { ksCase() }
    for _, c in ipairs(s(function() return fightAction:getRealReachableCells() end, {}) or {}) do L[#L + 1] = tonumber(c) end
    return L
end
function rnAller(c)
    if c == nil or c == ksCase() then return c ~= nil end
    deplacerCombat(c)
    for _ = 1, 50 do if ksCase() == c then return true end global:delay(30) end
    return ksCase() == c
end
RN_FOCUS = nil
function rnScoreCase(c, rn, ennemis)
    if rn == nil then return 0 end
    local d = ksDist(c, rn.cell)
    local sc = math.min(d, (rn.pm or RN_PM_MIN) + 4) * 10
    if rnSure(c, rn) then sc = sc + 100 end
    if d <= 10 and s(function() return fightAction:inLineOfSight(rn.cell, c) end, true) ~= true then sc = sc + 15 end
    for _, e in ipairs(ennemis or {}) do
        local de = ksDist(c, e.cell)
        if e.gid ~= RN_GID and e.gid ~= RN_EPEE_GID then
            if de <= 1 then sc = sc - 8 elseif de <= 3 then sc = sc - 4 end
        end
        if e.gid == 936 and de >= 3 and de <= 6 and s(function() return fightAction:cellsAligned(c, e.cell) end, false) == true then sc = sc - 6 end
    end
    if RN_FOCUS then
        local portee = RN_CHEF and 6 or 5
        local df = ksDist(c, RN_FOCUS)
        if df <= portee then sc = sc + 20
        elseif df <= portee + 4 then sc = sc + 10
        else sc = sc - math.min(df - portee - 4, 10) * 2 end
    end
    return sc
end
RN_ECHECS = {}
function rnZoneOk(sort, centre, rn)
    if not sort.zone then return true end
    local ennemis, allies = ksListes()
    local ici = ksCase()
    local cells = zone(sort.id, centre)
    local rayon = sort.rayon or 1
    local touche = 0
    for _, e in ipairs(ennemis) do if dansZone(e.cell, centre, rayon, cells, sort.carre) then touche = touche + 1 end end
    if touche == 0 then return false end
    for _, a in ipairs(allies) do
        if (a.gid or 0) == 0 and a.cell ~= ici and dansZone(a.cell, centre, rayon, cells, sort.carre) then
            if not sort.attireSeulement then return false end
            if rn and ksDist(centre, rn.cell) < ksDist(a.cell, rn.cell) then return false end
        end
    end
    if sort.attire and rn and dansZone(rn.cell, centre, rayon, cells, sort.carre) then return false end
    return true
end
function rnLancer(sort, cible)
    if not rnPossede(sort.id) then return false end
    if (RN_ECHECS[sort.id] or 0) >= 2 then return false end
    local code = tonumber(s(function() return fightAction:canCastSpellOnCell(ksCase(), sort.id, cible) end, 99))
    if code ~= 0 then return false end
    local avant = ksPA()
    RN_ETAT.enCours = { id = sort.id, nom = sort.nom, tour = rnTour() }
    pcall(function() fightAction:castSpellOnCell(sort.id, cible) end)
    RN_ETAT.enCours = nil
    for _ = 1, 50 do if ksPA() < avant then break end global:delay(30) end
    if ksPA() >= avant then
        RN_ECHECS[sort.id] = (RN_ECHECS[sort.id] or 0) + 1
        ksLog("RN : " .. (sort.nom or sort.id) .. " sur " .. tostring(cible) .. " SANS EFFET (PA " .. ksPA() .. ", echec " .. RN_ECHECS[sort.id] .. "/2)")
        return false
    end
    ksLog((sort.nom or sort.id) .. " sur " .. tostring(cible) .. " (reste PA " .. ksPA() .. ", PM " .. ksPM() .. ")")
    return true
end
local function zone(id, centre)
    local z = s(function() return fightAction:getSpellZone(id, centre) end, nil)
    if type(z) == "table" and #z > 0 then
        local L = {}
        for _, c in ipairs(z) do L[#L + 1] = tonumber(c) end
        return L, true
    end
    return nil, false
end
local function dansZone(c, centre, rayon, cells, carre)
    if cells then for _, x in ipairs(cells) do if x == c then return true end end return false end
    local d = ksDist(c, centre)
    if d <= rayon then return true end
    return carre == true and d == 2 and s(function() return fightAction:cellsInDiagonal(c, centre) end, true) == true
end

RN_SORTS_TERRE = {
    { id = 12746, nom = "Ravage", terre = true },
    { id = 12731, nom = "Decimation", zone = true, rayon = 1, terre = true },
}
RN_SORTS_EAU = {
    { id = 12728, nom = "Stase" },
    { id = 12745, nom = "Condensation", zone = true, rayon = 2 },
}
function rnCibles(chef, ennemis, rn)
    local ici = ksCase()
    local L, molos = {}, {}
    for _, e in ipairs(ennemis) do
        if e.gid == RN_MOLO or e.gid == RN_EPEE_GID then
            if e.gid == RN_MOLO then molos[#molos + 1] = e end
        elseif e.gid ~= RN_GID then
            if not (chef and rnSoigne(e.id)) then
                e.prio = RN_PRIO[e.gid] or 30
                L[#L + 1] = e
            end
        end
    end
    table.sort(L, function(a, b)
        if a.prio ~= b.prio then return a.prio > b.prio end
        if (a.pv or 0) ~= (b.pv or 0) then return (a.pv or 0) < (b.pv or 0) end
        return tostring(a.id) < tostring(b.id)
    end)
    local R = {}
    if RN_COINCE then for _, m in ipairs(molos) do if ksDist(ici, m.cell) <= 1 then R[#R + 1] = m end end end
    for _, e in ipairs(L) do R[#R + 1] = e end
    if rn then R[#R + 1] = rn end
    for _, m in ipairs(molos) do if not (RN_COINCE and ksDist(ici, m.cell) <= 1) then R[#R + 1] = m end end
    return R
end
function rnRepousserTacleur(rn)
    if ksPA() < 2 then return false end
    local ici = ksCase()
    local ennemis = ksListes()
    table.sort(ennemis, function(a, b) return (a.gid == RN_GID and 1 or 0) > (b.gid == RN_GID and 1 or 0) end)
    for _, e in ipairs(ennemis) do
        if ksDist(ici, e.cell) <= 1 and rnLancer({ id = RN_SORT.hostilite, nom = "Hostilite (repousse " .. nom(e.gid) .. ")" }, e.cell) then
            return true
        end
    end
    return false
end
function rnSauvetage(rn)
    if rn == nil or not rnSure(ksCase(), rn) then return end
    local ici = ksCase()
    local _, allies = ksListes()
    local n = 0
    for _, a in ipairs(allies) do
        if n < 2 and ksPA() >= 2 and (a.gid or 0) == 0 and a.cell ~= ici and ksDist(a.cell, rn.cell) <= 2
            and ksDist(ici, rn.cell) > ksDist(a.cell, rn.cell)
            and ksDist(ici, a.cell) < ksDist(ici, rn.cell) then
            local avant = ksDist(a.cell, rn.cell)
            if rnLancer({ id = RN_SORT.attirance, nom = "Attirance (sauvetage d un allie colle au Rat Noir)" }, a.cell) then
                n = n + 1
                local apres = avant
                for _ = 1, 20 do
                    for _, b in ipairs(select(2, ksListes())) do if b.id == a.id then apres = ksDist(b.cell, rn.cell) end end
                    if apres ~= avant then break end
                    global:delay(30)
                end
                ksLog("RN : sauvetage -> allie a " .. avant .. " puis " .. apres .. " case(s) du Rat Noir")
            end
        end
    end
end
function rnSortPermis(sort, chef)
    if not rnPossede(sort.id) then return false end
    if sort.vol then return false end
    return true
end
function rnFuir(rn, chef, raison)
    if rn == nil or rnSure(ksCase(), rn) then return true end
    if rnMarcherAuMieux(rn, raison) then return true end
    if rnPossede(RN_SORT.fluctuation) and ksPA() >= 2 and rnLancer({ id = RN_SORT.fluctuation, nom = "Fluctuation (fuite, intaclable)" }, ksCase()) then
        if rnMarcherAuMieux(rn, raison .. " apres Fluctuation") then return true end
    end
    if not chef and rnTransposer(rn, raison) then if rnSure(ksCase(), rn) then return true end end
    if rnRepousserTacleur(rn) then
        rn = rnEntite() or rn
        if rnMarcherAuMieux(rn, raison .. " apres Hostilite") then return true end
    end
    ksLog("RN " .. raison .. " : AUCUNE fuite (case " .. ksCase() .. ", Rat Noir a " .. ksDist(ksCase(), rn.cell)
        .. ", PA " .. ksPA() .. ", PM " .. ksPM() .. ")")
    return false
end
function rnMarcherAuMieux(rn, raison)
    local ennemis = ksListes()
    local ici = ksCase()
    local best, bs = ici, rnScoreCase(ici, rn, ennemis)
    for _, c in ipairs(rnAtteignables()) do
        local sc = rnScoreCase(c, rn, ennemis)
        if sc > bs then best, bs = c, sc end
    end
    if best ~= ici then
        local ok = rnAller(best)
        ksLog("RN " .. raison .. " : " .. ici .. " -> " .. ksCase() .. (ok and "" or " (bloque : tacle ?)") .. ", Rat Noir a " .. ksDist(ksCase(), rn.cell))
    end
    return rnSure(ksCase(), rn)
end
function rnCaseAttaque(cible, sorts, rn, chef)
    local pm = ksPM()
    local ici = ksCase()
    local utiles = {}
    for _, sort in ipairs(sorts) do
        if not (RN_ECHECS[sort.id] and RN_ECHECS[sort.id] >= 2) and rnSortPermis(sort, chef) then
            if sort.soi then
                if tonumber(s(function() return fightAction:canCastSpellOnCell(ici, sort.id, ici) end, 99)) == 0
                    and dansZone(cible.cell, ici, sort.rayon or 1, (zone(sort.id, ici)), sort.carre)
                    and rnZoneOk(sort, ici, rn) then return ici end
            elseif not sort.zone or rnZoneOk(sort, cible.cell, rn) then
                utiles[#utiles + 1] = sort
            end
        end
    end
    local best, bestCout = nil, 99
    local cases = RN_COINCE and { ici } or rnAtteignables()
    for _, c in ipairs(cases) do
        local cout = ksDist(ici, c)
        if cout <= pm then
            local ok = false
            for _, sort in ipairs(utiles) do
                if not ok then
                    local code = (c == ici) and s(function() return fightAction:canCastSpellOnCell(ici, sort.id, cible.cell) end, 99)
                        or s(function() return fightAction:canCastSpellOnCellAfterMove(c, sort.id, cible.cell) end, 99)
                    if tonumber(code) == 0 then ok = true end
                end
            end
            if ok then
                local repliOk = rnSure(c, rn) or c == ici
                if repliOk and cout < bestCout then best, bestCout = c, cout end
            end
        end
    end
    return best
end
function iaSacriRatNoir(chef)
    local tour = rnTour()
    if tour ~= KS_TOUR then KS_TOUR, KS_REFUS = tour, {} end
    if tour ~= RN_TOUR_ECHECS then RN_TOUR_ECHECS, RN_ECHECS = tour, {} end
    RN_CHEF = (chef == true)
    rnNouveauCombat()
    RN_ETAT.appels = RN_ETAT.appels or {}
    RN_ETAT.appels[tour] = (RN_ETAT.appels[tour] or 0) + 1
    if RN_ETAT.appels[tour] > 3 then
        ksLog("RN tour " .. tour .. " relance " .. RN_ETAT.appels[tour] .. " fois -> ARRET des sorts ce tour, mise a l abri seulement")
        local rn0 = rnEntite()
        if rn0 and not rnSure(ksCase(), rn0) then rnMarcherAuMieux(rn0, "anti-boucle") end
        return
    end
    local pret, dernier = rnKackituPret()
    local rn = rnEntite()
    ksLog("RN tour " .. tour .. " : case " .. ksCase() .. ", PA " .. ksPA() .. ", PM " .. ksPM() .. ", PV " .. rnPV()
        .. (rn and (", Rat Noir case " .. rn.cell .. " a " .. ksDist(ksCase(), rn.cell) .. " (PV " .. rn.pv .. ")") or "")
        .. ", Kackitu " .. (pret and "peut-etre pret" or ("vu au tour " .. tostring(dernier))))
    if rn and not rnSure(ksCase(), rn) then
        rnFuir(rn, chef, "debut de tour")
        rn = rnEntite()
    end
    ksInvoquerEpee(RN_GID)
    local sorts = chef and RN_SORTS_TERRE or RN_SORTS_EAU
    for _ = 1, 10 do
        if ksPA() < 2 then break end
        rn = rnEntite()
        RN_COINCE = false
        if rn and not rnSure(ksCase(), rn) then
            local sureAtteignable = false
            for _, c in ipairs(rnAtteignables()) do if rnSure(c, rn) then sureAtteignable = true end end
            RN_COINCE = not sureAtteignable
            local reserve = chef and 2 or 3
            if not RN_COINCE and ksPA() < 3 + reserve then
                ksLog("RN : en danger, PA " .. ksPA() .. " gardes pour la fuite")
                break
            end
        end
        local ennemis = ksListes()
        local cibles = rnCibles(chef, ennemis, rn)
        RN_FOCUS = nil
        for _, e in ipairs(cibles) do
            if RN_FOCUS == nil and e.gid ~= RN_GID and e.gid ~= RN_MOLO then RN_FOCUS = e.cell end
        end
        local fait = false
        for _, cible in ipairs(cibles) do
            if not fait then
                local c = rnCaseAttaque(cible, sorts, rn, chef)
                if c then
                    rnAller(c)
                    for _, sort in ipairs(sorts) do
                        if not fait and rnFrapper(sort, cible, chef) then
                            fait = true
                            ksLog("RN : " .. sort.nom .. " sur " .. nom(cible.gid) .. " (PV " .. tostring(cible.pv) .. ")")
                        end
                    end
                end
            end
        end
        if not fait then
            local codes = {}
            local c1 = cibles[1]
            if c1 then
                for _, sort in ipairs(sorts) do
                    local t = sort.soi and ksCase() or c1.cell
                    codes[#codes + 1] = sort.nom .. "=" .. tostring(s(function() return fightAction:canCastSpellOnCell(ksCase(), sort.id, t) end, "?"))
                        .. ((RN_ECHECS[sort.id] or 0) > 0 and ("(echecs " .. RN_ECHECS[sort.id] .. ")") or "")
                end
            end
            ksLog("RN : plus rien ne passe (PA " .. ksPA() .. ", PM " .. ksPM() .. ", " .. #cibles .. " cibles"
                .. (c1 and (", 1re " .. nom(c1.gid) .. " a " .. ksDist(ksCase(), c1.cell)) or "") .. " ; " .. table.concat(codes, ", ") .. ")")
            break
        end
    end
    rn = rnEntite()
    do
        local cf = rnCibles(chef, (ksListes()), rn)
        RN_FOCUS = nil
        for _, e in ipairs(cf) do
            if RN_FOCUS == nil and e.gid ~= RN_GID and e.gid ~= RN_MOLO then RN_FOCUS = e.cell end
        end
    end
    if rn then
        if rnSure(ksCase(), rn) then
            local ennemis = ksListes()
            local ici, best, bs = ksCase(), ksCase(), rnScoreCase(ksCase(), rn, ennemis) + 5
            for _, c in ipairs(rnAtteignables()) do
                local sc = rnScoreCase(c, rn, ennemis)
                if sc > bs then best, bs = c, sc end
            end
            if best ~= ici then rnAller(best) end
        else
            rnFuir(rn, chef, "fin de tour")
        end
        ksLog("RN fin de tour : case " .. ksCase() .. ", Rat Noir a " .. ksDist(ksCase(), rn.cell)
            .. (rnSure(ksCase(), rn) and " (sur)" or " (DANGER)") .. ", PA " .. ksPA() .. ", PM " .. ksPM())
        rnSauvetage(rn)
    end
    if ksPA() >= 2 then rnLancer({ id = RN_SORT.couronne, nom = "Couronne d Epines" }, ksCase()) end
    if RN_PACTE and ksPA() >= 2 then rnLancer({ id = RN_SORT.pacte, nom = "Pacte de Sang (PA restants)" }, ksCase()) end
    if rn then
        local _, allies = ksListes()
        for _, a in ipairs(allies) do
            if ksDist(a.cell, rn.cell) <= 1 and pret then
                RN_ETAT.kackitu = tour
                ksLog("RN : " .. ((a.gid or 0) == 0 and "perso" or "Epee") .. " colle au Rat Noir (case " .. a.cell .. ") -> Kackitu probable ce tour")
                break
            end
        end
    end
end
function rnFrapper(sort, cible, chef)
    local t = sort.soi and ksCase() or cible.cell
    if not rnSortPermis(sort, chef) then return false end
    if sort.zone and not rnZoneOk(sort, t, rnEntite()) then return false end
    local pvAvant = cible.pv
    if not rnLancer(sort, t) then return false end
    if sort.terre and cible.gid ~= RN_GID and pvAvant then
        local function lirePV()
            for _, e in ipairs((ksListes())) do if e.id == cible.id then return e.pv end end
            return nil
        end
        local pvApres, pvMin, mort = pvAvant, pvAvant, false
        local vu, stable = false, 0
        for _ = 1, 40 do
            local v = lirePV()
            if v == nil then mort = true break end
            if v < pvMin then pvMin = v end
            if v ~= pvApres then stable = 0 else stable = stable + 1 end
            pvApres = v
            if v ~= pvAvant then vu = true end
            if vu and (stable >= 8 or pvApres > pvMin) then break end
            global:delay(30)
        end
        local perte = pvAvant - pvApres
        local soigne = (not mort) and vu and (pvApres > pvMin + 20 or perte < RN_SOIGNE_PERTE)
        ksLog("RN : " .. sort.nom .. " -> " .. nom(cible.gid) .. " " .. pvAvant .. " -> min " .. pvMin .. " -> " .. tostring(pvApres)
            .. " PV (perte nette " .. perte .. ")" .. (mort and " MORT" or ""))
        if soigne then
            RN_ETAT.soigne[tostring(cible.id)] = rnTour() + 3
            ksLog("RN : " .. nom(cible.gid) .. " SOIGNE (Kackisoigne) -> plus de terre sur lui jusqu au tour " .. (rnTour() + 3))
        end
    end
    return true
end
function rnTransposer(rn, raison)
    if ksPA() < 3 or not rnPossede(RN_SORT.transposition) then return false end
    local ennemis, allies = ksListes()
    local ici = ksCase()
    local cand = {}
    for _, a in ipairs(allies) do if (a.gid or 0) ~= 0 and a.cell ~= ici then cand[#cand + 1] = a end end
    for _, e in ipairs(ennemis) do if e.gid ~= RN_GID then cand[#cand + 1] = e end end
    local avec = {}
    for _, x in ipairs(cand) do if rnSure(x.cell, rn) then x.sc = rnScoreCase(x.cell, rn, ennemis) avec[#avec + 1] = x end end
    table.sort(avec, function(a, b) return a.sc > b.sc end)
    for _, x in ipairs(avec) do
        if rnLancer({ id = RN_SORT.transposition, nom = "Transposition (" .. raison .. ")" }, x.cell) then
            for _ = 1, 30 do if ksCase() ~= ici then break end global:delay(30) end
            if ksCase() ~= ici then
                ksLog("RN : TRANSPOSITION " .. ici .. " -> " .. ksCase() .. " avec " .. nom(x.gid) .. " (Rat Noir a " .. ksDist(ksCase(), rn.cell) .. ")")
                return true
            end
        end
    end
    return false
end

RM_GID = 2854
RM_INVOCS = { [2850] = true, [2851] = true, [2852] = true, [2853] = true }
RM_AVERSION = 12749
RM_PM_BASE = 5
RM_PM_POUSSE = 4
RM_REGROUP_RELANCE = 3
RM_CLE_POUSSE = "RM_POUSSE_TOUR"
RM_CLE_REGROUP = "RM_REGROUP_TOUR"
function rmCell(x, y)
    local c = (x - y) * 14 + y + math.floor((x - y) / 2)
    if c < 0 or c > 559 then return nil end
    local x2, y2 = rmXY(c)
    if x2 ~= x or y2 ~= y then return nil end
    return c
end
local function ecrireMemRM(k, v)
    pcall(function() developer:deleteFromGlobalMemory(k) end)
    pcall(function() developer:addInGlobalMemory(k, tostring(v)) end)
end
function rmEntite()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CreatureGenericId) == RM_GID and (tonumber(e.LifePoints) or 0) > 0 then
            return { cell = tonumber(e.CellId), pm = tonumber(e.MP) or RM_PM_BASE, pv = tonumber(e.LifePoints) or 0,
                     id = e.Id, gid = RM_GID }
        end
    end
    return nil
end
local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function rmXY(c)
    local b, r = math.floor(c / 28), c % 28
    if r < 14 then return b + r, r - b end
    return b + 1 + (r - 14), (r - 14) - b
end
local function lireMemRM(k) return tonumber(s(function() return developer:getInGlobalMemory(k) end, nil)) end
function rmGroupeSurCarte()
    local brut = s(function() return map:monsterGroups() end, nil)
    if type(brut) ~= "table" then return false end
    for _, g in ipairs(brut) do
        for _, m in ipairs(g.monsters or {}) do
            if tonumber(m.id) == RM_GID or tonumber(m.genericId) == RM_GID then return true end
        end
    end
    return false
end
function rmTour() return tonumber(s(function() return fightAction:getCurrentTurn() end, 0)) or 0 end
function rmPresent()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CreatureGenericId) == RM_GID and (tonumber(e.LifePoints) or 0) > 0 then return true end
    end
    return false
end

RM_DIRS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
function rmAligne(a, b)
    local ax, ay = rmXY(a) local bx, by = rmXY(b)
    return ax == bx or ay == by
end
function rmAller(c)
    if c == nil or c == ksCase() then return end
    deplacerCombat(c)
    for _ = 1, 100 do if ksCase() == c then break end global:delay(20) end
end
function rmAtteignables()
    local L = { ksCase() }
    for _, c in ipairs(s(function() return fightAction:getRealReachableCells() end, {}) or {}) do L[#L + 1] = tonumber(c) end
    return L
end

RM_DERNIER_TOUR_VU = RM_DERNIER_TOUR_VU or 0
RM_INVUL_CONSTATE = RM_INVUL_CONSTATE or -1
function rmPoussees(rm)
    local ennemis, allies = ksListes()
    local occupe, quiAllie, quiEnnemi = {}, {}, {}
    for _, e in ipairs(ennemis) do occupe[e.cell] = true quiEnnemi[e.cell] = e end
    for _, a in ipairs(allies) do occupe[a.cell] = true quiAllie[a.cell] = a end
    local moi = ksCase()
    local bx, by = rmXY(rm.cell)
    local res = {}
    for _, d in ipairs(RM_DIRS) do
        local C = rmCell(bx - d[1], by - d[2])
        local dest = rmCell(bx + d[1], by + d[2])
        local ok = C ~= nil and dest ~= nil and C ~= moi
        if ok then
            ok = ksDist(rm.cell, C) == 1 and ksDist(rm.cell, dest) == 1 and ksDist(C, dest) == 2
                and rmCaseLibre(dest, occupe)
                and s(function() return fightAction:isWalkable(C) end, false) == true
        end
        if ok then
            local cx, cy = rmXY(C)
            for _, d2 in ipairs(RM_DIRS) do
                local n = rmCell(cx + d2[1], cy + d2[2])
                if n and n ~= rm.cell then
                    if quiAllie[n] and n ~= moi then ok = false end
                    if quiEnnemi[n] and not rmCaseLibre(rmCell(cx + 2 * d2[1], cy + 2 * d2[2]), occupe) then ok = false end
                end
            end
        end
        if ok then
            local m = 99
            for _, a in ipairs(allies) do if a.cell ~= dest then m = math.min(m, ksDist(dest, a.cell)) end end
            res[#res + 1] = { C = C, dest = dest, score = m }
        end
    end
    table.sort(res, function(a, b) return a.score > b.score end)
    return res
end
function rmLancerAversion(rm, o)
    local avant = rm.cell
    if not ksLancer({ id = RM_AVERSION, nom = "Aversion (poussee 1 case)" }, o.C) then return false end
    for _ = 1, 50 do
        local r = rmEntite()
        if r == nil or r.cell ~= avant then break end
        global:delay(20)
    end
    local r = rmEntite()
    ecrireMemRM(RM_CLE_POUSSE, rmTour())
    RM_INVUL_CONSTATE = -1
    ksLog("RM : POUSSEE " .. avant .. " -> " .. tostring(r and r.cell or "?") .. " (attendu " .. o.dest .. ", cible " .. o.C
        .. ", PM boss " .. tostring(r and r.pm or "?") .. ") -> vulnerable jusqu a son tour")
    return true
end
function rmRegroupPret()
    local d = lireMemRM(RM_CLE_REGROUP)
    if d == nil then return true, nil end
    return (rmTour() + 1 - d) >= RM_REGROUP_RELANCE, d
end
function rmCaseLibre(c, occupe)
    if c == nil or occupe[c] then return false end
    if s(function() return fightAction:isWalkable(c) end, false) ~= true then return false end
    if s(function() return fightAction:isFreeCell(c) end, true) == false then return false end
    return true
end
function rmDetecterRegroup(rm)
    local pm = ksPM()
    if RM_PM_MAX == nil or pm > RM_PM_MAX then RM_PM_MAX = pm end
    if rm and pm < (RM_PM_MAX or pm) and rmAligne(ksCase(), rm.cell) and ksDist(ksCase(), rm.cell) <= 3 then
        local tour = rmTour()
        local d = lireMemRM(RM_CLE_REGROUP)
        if d == nil or d < tour - 1 then
            ecrireMemRM(RM_CLE_REGROUP, tour - 1)
            ksLog("RM : Regroupmouth detecte (PM " .. pm .. "/" .. RM_PM_MAX .. ", aligne a " .. ksDist(ksCase(), rm.cell)
                .. ") -> de nouveau pret au tour " .. (tour - 1 + RM_REGROUP_RELANCE))
        end
    end
end
function rmVulnerable(rm)
    if rm == nil then return false end
    local tour = rmTour()
    if RM_INVUL_CONSTATE == tour then return false end
    if (rm.pm or 0) >= RM_PM_BASE + RM_PM_POUSSE then return true end
    return lireMemRM(RM_CLE_POUSSE) == tour
end
function rmNouveauCombat()
    local tour = rmTour()
    if tour < RM_DERNIER_TOUR_VU then
        ecrireMemRM(RM_CLE_POUSSE, "") ecrireMemRM(RM_CLE_REGROUP, "")
        RM_INVUL_CONSTATE, RM_PM_MAX = -1, nil
    end
    RM_DERNIER_TOUR_VU = tour
    for _, k in ipairs({ RM_CLE_POUSSE, RM_CLE_REGROUP }) do
        local v = lireMemRM(k)
        if v ~= nil and v > tour then ecrireMemRM(k, "") end
    end
end
function rmPousser(rm)
    if rm == nil or KS_REFUS[RM_AVERSION] or ksPA() < 2 then return false end
    local options = rmPoussees(rm)
    if #options == 0 then ksLog("RM : aucune poussee nette possible (case derriere le boss bloquee)") return false end
    local ici = ksCase()
    for _, o in ipairs(options) do
        if ksPeut(RM_AVERSION, o.C) then
            return rmLancerAversion(rm, o)
        end
    end
    local best, bestCout, bestO = nil, 99, nil
    for _, c in ipairs(rmAtteignables()) do
        local cout = ksDist(ici, c)
        if c ~= ici and cout <= ksPM() and cout < bestCout then
            for _, o in ipairs(options) do
                if c ~= o.dest and c ~= o.C and tonumber(s(function() return fightAction:canCastSpellOnCellAfterMove(c, RM_AVERSION, o.C) end, 99)) == 0 then
                    best, bestCout, bestO = c, cout, o
                    break
                end
            end
        end
    end
    if best then
        rmAller(best)
        rm = rmEntite()
        if rm == nil then return false end
        for _, o in ipairs(rmPoussees(rm)) do
            if ksPeut(RM_AVERSION, o.C) then return rmLancerAversion(rm, o) end
        end
    end
    ksLog("RM : Aversion hors de portee (code " .. tostring(s(function() return fightAction:canCastSpellOnCell(ksCase(), RM_AVERSION, options[1].C) end, "?"))
        .. ") — variante equipee ?")
    return false
end

RM_SORTS_TERRE = {
    { id = 12732, nom = "Bain de Sang", zone = true, soi = true },
    { id = 12725, nom = "Supplice" },
    { id = 12731, nom = "Decimation", zone = true },
    { id = 12746, nom = "Ravage" },
}
RM_SORTS_EAU = {
    { id = 12728, nom = "Stase" },
    { id = 12745, nom = "Condensation", zone = true },
}
function rmInvoquerEpee(rm)
    if KS_REFUS[KS_EPEE] then return end
    local ici = ksCase()
    local ennemis, allies = ksListes()
    local occupe = {}
    for _, e in ipairs(ennemis) do occupe[e.cell] = true end
    for _, a in ipairs(allies) do occupe[a.cell] = true end
    local cases = s(function() return fightAction:getCells_lozenge(ici, 1, 3) end, {}) or {}
    table.sort(cases, function(a, b)
        a, b = tonumber(a), tonumber(b)
        if rm then return ksDist(a, rm.cell) < ksDist(b, rm.cell) end
        return ksDist(ici, a) < ksDist(ici, b)
    end)
    for _, c in ipairs(cases) do
        c = tonumber(c)
        local genante = rm and ksDist(c, rm.cell) <= 2 and rmAligne(c, rm.cell)
        if c and not occupe[c] and not genante and ksPeut(KS_EPEE, c) then
            if ksLancer({ id = KS_EPEE, nom = "Epee Vorace (invocation)" }, c) then return end
        end
    end
end
function rmBouchons(rm)
    local _, allies = ksListes()
    local inv = {}
    for _, a in ipairs(allies) do if a.gid ~= 0 then inv[a.cell] = a end end
    local bx, by = rmXY(rm.cell)
    local L = {}
    for _, d in ipairs(RM_DIRS) do
        local C = rmCell(bx - d[1], by - d[2])
        local dest = rmCell(bx + d[1], by + d[2])
        if C and dest and inv[dest] and s(function() return fightAction:isWalkable(C) end, false) == true then
            L[#L + 1] = inv[dest]
        end
    end
    return L
end
function rmCibles(rm, vuln)
    local ennemis = ksListes()
    local ici = ksCase()
    local L = {}
    if rm and vuln then L[#L + 1] = rm end
    local inv = {}
    for _, e in ipairs(ennemis) do if e.gid ~= RM_GID then inv[#inv + 1] = e end end
    table.sort(inv, function(a, b)
        local pa, pb = RM_INVOCS[a.gid] and 0 or 1, RM_INVOCS[b.gid] and 0 or 1
        if pa ~= pb then return pa < pb end
        if a.pv ~= b.pv then return a.pv < b.pv end
        return ksDist(ici, a.cell) < ksDist(ici, b.cell)
    end)
    for _, e in ipairs(inv) do L[#L + 1] = e end
    return L
end
function rmFinDeTour(rm, regroupPret)
    if rm == nil then return end
    local ici = ksCase()
    local scIci = rmScoreCase(ici, rm, regroupPret)
    local best, bestSc = ici, scIci
    for _, c in ipairs(rmAtteignables()) do
        local sc = rmScoreCase(c, rm, regroupPret)
        if sc > bestSc then best, bestSc = c, sc end
    end
    if best ~= ici then rmAller(best) end
    local fin = ksCase()
    ksLog("RM fin de tour : case " .. fin .. ", boss a " .. ksDist(fin, rm.cell) .. " (PM boss " .. tostring(rm.pm)
        .. "), aligne " .. tostring(rmAligne(fin, rm.cell)) .. ", Regroupmouth " .. (regroupPret and "PRET" or "en recharge"))
    if ksDist(fin, rm.cell) <= 1 and rmAligne(fin, rm.cell) then
        local _, allies = ksListes()
        table.sort(allies, function(a, b) return rmScoreCase(a.cell, rm, regroupPret) > rmScoreCase(b.cell, rm, regroupPret) end)
        for _, a in ipairs(allies) do
            if a.gid ~= 0 and a.cell ~= fin and rmScoreCase(a.cell, rm, regroupPret) > rmScoreCase(fin, rm, regroupPret)
                and ksLancer({ id = 12736, nom = "Transposition (fuite)" }, a.cell) then
                ksLog("RM fin de tour : TRANSPOSITION " .. fin .. " -> " .. ksCase())
                return
            end
        end
    end
end
function iaSacriRoyalmouth(chef)
    local tour = rmTour()
    if tour ~= KS_TOUR then KS_TOUR, KS_REFUS = tour, {} end
    rmNouveauCombat()
    local rm = rmEntite()
    rmDetecterRegroup(rm)
    local regroupPret, dernierRegroup = rmRegroupPret()
    local vuln = rmVulnerable(rm)
    RM_BESOIN_POUSSEE = (rm ~= nil and not vuln)
    ksLog("RM tour " .. tour .. " : boss " .. (rm and ("case " .. rm.cell .. " PM " .. rm.pm .. " PV " .. rm.pv) or "absent")
        .. ", " .. (vuln and "VULNERABLE" or "invulnerable") .. ", Regroupmouth "
        .. (regroupPret and "pret" or ("en recharge (lance au tour " .. tostring(dernierRegroup) .. ")")))
    rmInvoquerEpee(rm)
    ksLancer({ id = 12761, nom = "Couronne d Epines" }, ksCase())
    if rm and not vuln then
        if rmPousser(rm) then vuln = true end
        rm = rmEntite()
    end
    local sorts = chef and RM_SORTS_TERRE or RM_SORTS_EAU
    for _ = 1, 8 do
        if ksPA() < 2 then break end
        local fait = false
        for _, cible in ipairs(rmCibles(rm, vuln)) do
            if not fait then
                local c = rmCaseAttaque(cible, sorts, rm)
                if c then
                    rmAller(c)
                    for _, sort in ipairs(sorts) do
                        if not fait then
                            local t = sort.soi and ksCase() or cible.cell
                            local pvAvant = rm and rm.pv or 0
                            if ksLancer(sort, t) then
                                fait = true
                                local surBoss = cible.gid == RM_GID or (sort.soi and rm and ksDist(ksCase(), rm.cell) <= 1)
                                local apres = rmEntite()
                                if surBoss and rm then
                                    for _ = 1, 50 do
                                        apres = rmEntite()
                                        if apres == nil or apres.pv < pvAvant then break end
                                        global:delay(20)
                                    end
                                end
                                if surBoss and apres and rm and apres.pv >= pvAvant and RM_REPOUSSE_TOUR ~= tour then
                                    RM_INVUL_CONSTATE, vuln, RM_REPOUSSE_TOUR = tour, false, tour
                                    ksLog("RM : " .. sort.nom .. " sans effet sur le boss -> invulnerable, nouvelle poussee")
                                    if rmPousser(apres) then vuln = true end
                                    apres = rmEntite()
                                end
                                rm = apres
                                ksLog("RM : " .. sort.nom .. " sur " .. (cible.gid == RM_GID and "le Royalmouth" or ("monstre " .. cible.gid)))
                            end
                        end
                    end
                end
            end
        end
        if not fait then break end
    end
    rmFinDeTour(rmEntite() or rm, regroupPret)
end
function rmScoreCase(c, rm, regroupPret)
    local d = ksDist(c, rm.cell)
    local p = rm.pm or RM_PM_BASE
    local aligne = rmAligne(c, rm.cell)
    local sc = 0
    if RM_BESOIN_POUSSEE then
        if d >= 2 and d <= 7 then sc = sc + 1000 - math.abs(d - 5) * 20
        else sc = sc + 400 - d end
    elseif d > p + 1 then sc = sc + 1000 - d
    else sc = sc + d * 10 end
    if not (aligne and d <= 3) then sc = sc + 300 end
    if not aligne then sc = sc + (regroupPret and 200 or 50) end
    return sc
end
function rmCaseAttaque(cible, sorts, rm)
    local pm, ici = ksPM(), ksCase()
    local best, bestCout = nil, 99
    for _, c in ipairs(rmAtteignables()) do
        local cout = ksDist(ici, c)
        if cout <= pm then
            local ok = false
            for _, sort in ipairs(sorts) do
                if not ok and not sort.soi and not KS_REFUS[sort.id] then
                    local code = (c == ici) and s(function() return fightAction:canCastSpellOnCell(ici, sort.id, cible.cell) end, 99)
                        or s(function() return fightAction:canCastSpellOnCellAfterMove(c, sort.id, cible.cell) end, 99)
                    if tonumber(code) == 0 then ok = true end
                end
            end
            if ok then
                local pen = cout
                if rm and ksDist(c, rm.cell) <= 1 and rmAligne(c, rm.cell) then pen = pen + 2 end
                if pen < bestCout then best, bestCout = c, pen end
            end
        end
    end
    return best
end
function rmPoussees(rm)
    local ennemis, allies = ksListes()
    local occupe, joueur = {}, {}
    for _, e in ipairs(ennemis) do occupe[e.cell] = true end
    for _, a in ipairs(allies) do occupe[a.cell] = true if a.gid == 0 then joueur[a.cell] = true end end
    local moi = ksCase()
    local bx, by = rmXY(rm.cell)
    local res = {}
    for _, d in ipairs(RM_DIRS) do
        local C = rmCell(bx - d[1], by - d[2])
        local dest = rmCell(bx + d[1], by + d[2])
        local ok = C ~= nil and dest ~= nil and C ~= moi
        if ok then
            ok = ksDist(rm.cell, C) == 1 and ksDist(rm.cell, dest) == 1 and ksDist(C, dest) == 2
                and rmCaseLibre(dest, occupe)
                and s(function() return fightAction:isWalkable(C) end, false) == true
                and not joueur[C]
        end
        if ok then
            local cx, cy = rmXY(C)
            for _, d2 in ipairs(RM_DIRS) do
                local n = rmCell(cx + d2[1], cy + d2[2])
                if n and n ~= rm.cell and joueur[n] and n ~= moi then ok = false end
            end
        end
        if ok then
            local m = 99
            for _, a in ipairs(allies) do if a.cell ~= dest and a.gid == 0 then m = math.min(m, ksDist(dest, a.cell)) end end
            res[#res + 1] = { C = C, dest = dest, score = m }
        end
    end
    table.sort(res, function(a, b) return a.score > b.score end)
    return res
end
function rmInvoquerEpee(rm) end
function rmLibererAxe(rm, chef)
    local sorts = chef and { { id = 12725, nom = "Supplice" }, { id = 12746, nom = "Ravage" } } or RM_SORTS_EAU
    local fait = false
    for _ = 1, 6 do
        if ksPA() < 2 then break end
        local cur = rmEntite() or rm
        local b = rmBouchons(cur)[1]
        if b == nil then break end
        local c = rmCaseAttaque(b, sorts, cur)
        if c == nil then break end
        rmAller(c)
        local tire = false
        for _, sort in ipairs(sorts) do
            if not tire and not sort.soi and not sort.zone and ksLancer(sort, b.cell) then
                tire = true fait = true
                ksLog("RM : " .. sort.nom .. " sur NOTRE invocation " .. b.gid .. " (" .. b.cell .. ") qui bouche l axe de poussee")
            end
        end
        if not tire then break end
    end
    return fait
end
RM_POUSSER_ORIG = RM_POUSSER_ORIG or rmPousser
function rmPousser(rm)
    if rm == nil then return false end
    if #rmPoussees(rm) == 0 and #rmBouchons(rm) > 0 then
        rmLibererAxe(rm, RM_CHEF_COURANT)
        rm = rmEntite() or rm
    end
    return RM_POUSSER_ORIG(rm)
end
RM_IA_ORIG = RM_IA_ORIG or iaSacriRoyalmouth
function iaSacriRoyalmouth(chef)
    RM_CHEF_COURANT = chef
    return RM_IA_ORIG(chef)
end
RM_NIVEAU_AVERSION = 135
function rmAAversion()
    return (tonumber(s(function() return character:level() end, 0)) or 0) >= RM_NIVEAU_AVERSION
end
RM_POUSSER_SANS_NIVEAU = RM_POUSSER_SANS_NIVEAU or rmPousser
RM_ATTIRANCE = 12735
function rmPousser(rm)
    if rmAAversion() then return RM_POUSSER_SANS_NIVEAU(rm) end
    if rm == nil or KS_REFUS[RM_ATTIRANCE] or RM_ESSAI_ATTIRANCE == rmTour() or ksPA() < 2 then return false end
    if not ksPeut(RM_ATTIRANCE, rm.cell) then return false end
    RM_ESSAI_ATTIRANCE = rmTour()
    local avant, pm0 = rm.cell, rm.pm or 0
    if not ksLancer({ id = RM_ATTIRANCE, nom = "Attirance (deplacer le Royalmouth)" }, rm.cell) then return false end
    for _ = 1, 50 do
        local r = rmEntite()
        if r == nil or r.cell ~= avant then break end
        global:delay(20)
    end
    local r = rmEntite()
    local bouge = r ~= nil and r.cell ~= avant
    local desactive = r ~= nil and (r.pm or 0) >= RM_PM_BASE + RM_PM_POUSSE
    ksLog("RM ESSAI ATTIRANCE : boss " .. avant .. " -> " .. tostring(r and r.cell or "?") .. ", PM " .. pm0 .. " -> "
        .. tostring(r and r.pm or "?") .. (desactive and " => INIMOUTH DESACTIVE (attirer marche)" or (bouge and " => deplace mais PAS de preuve de vulnerabilite" or " => pas deplace")))
    if desactive then
        ecrireMemRM(RM_CLE_POUSSE, rmTour())
        RM_INVUL_CONSTATE = -1
        return true
    end
    return false
end

TR_GIDS = { [7852] = true, [382] = true }
TR_TOFUBINE = { }
TR_ATTIRANCE, TR_FLUCTUATION, TR_EPEE = 12735, 12763, 12744
local function trOccupees()
    local occ = {}
    for _, e in ipairs(ksEntites()) do
        if (tonumber(e.LifePoints) or 0) > 0 then occ[tonumber(e.CellId)] = true end
    end
    return occ
end
function trSeColler(b)
    local ici = ksCase()
    if ksDist(ici, b.cell) == 1 then return true end
    local occ = trOccupees()
    local best, bestCout = nil, 99
    local voisines = {}
    for _, c in ipairs(trVoisines(b)) do if not occ[c] then voisines[c] = true end end
    for _, c in ipairs(rmAtteignables()) do
        if voisines[c] then
            local cout = ksDist(ici, c)
            if cout <= ksPM() and cout < bestCout then best, bestCout = c, cout end
        end
    end
    if best then rmAller(best) return ksDist(ksCase(), b.cell) == 1 end
    local trChef = type(estLeader) == "function" and sur(function() return estLeader() end, false) == true
    if trChef and not KS_REFUS[TR_FLUCTUATION] and ksPA() >= 4 and next(voisines) ~= nil then
        if ksLancer({ id = TR_FLUCTUATION, nom = "Fluctuation (intaclable + PM)" }, ici) then
            for _, c in ipairs(rmAtteignables()) do
                if voisines[c] and ksDist(ksCase(), c) <= ksPM() then rmAller(c) break end
            end
            if ksDist(ksCase(), b.cell) == 1 then return true end
        end
    end
    if not KS_REFUS[TR_ATTIRANCE] and ksPA() >= 2 and ksPeut(TR_ATTIRANCE, b.cell) then
        ksLancer({ id = TR_ATTIRANCE, nom = "Attirance sur le Tofu Royal" }, b.cell)
        local b2 = trBoss()
        if b2 and ksDist(ksCase(), b2.cell) == 1 then return true end
    end
    return false
end
function trVoisines(b)
    local L = {}
    local x, y = rmXY(b.cell)
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local c = rmCell(x + d[1], y + d[2])
        if c and s(function() return fightAction:isWalkable(c) end, false) == true then L[#L + 1] = c end
    end
    return L
end
function trPresent()
    for _, e in ipairs(ksEntites()) do
        if TR_GIDS[tonumber(e.CreatureGenericId)] and (tonumber(e.LifePoints) or 0) > 0 then return true end
    end
    return false
end
function trBloque(b)
    local occ = trOccupees()
    local libres = 0
    for _, c in ipairs(trVoisines(b)) do if not occ[c] then libres = libres + 1 end end
    return libres == 0, libres
end
function trBoss()
    for _, e in ipairs(ksEntites()) do
        if TR_GIDS[tonumber(e.CreatureGenericId)] and (tonumber(e.LifePoints) or 0) > 0 then
            return { cell = tonumber(e.CellId), pv = tonumber(e.LifePoints) or 0, pm = tonumber(e.MP) or 0,
                     gid = tonumber(e.CreatureGenericId) }
        end
    end
    return nil
end
local function trNom(e)
    return string.lower(tostring(s(function() return e.Name end, "") or ""))
end
local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function trEpee(b)
    if KS_REFUS[TR_EPEE] or ksPA() < 3 then return false end
    local occ = trOccupees()
    local voisines = {}
    for _, c in ipairs(trVoisines(b)) do if not occ[c] then voisines[#voisines + 1] = c end end
    for _, c in ipairs(voisines) do
        if ksPeut(TR_EPEE, c) and ksLancer({ id = TR_EPEE, nom = "Epee Vorace (collee au boss)" }, c) then return true end
    end
    local ici = ksCase()
    for _, m in ipairs(rmAtteignables()) do
        if m ~= ici and ksDist(ici, m) <= ksPM() then
            for _, c in ipairs(voisines) do
                if tonumber(s(function() return fightAction:canCastSpellOnCellAfterMove(m, TR_EPEE, c) end, 99)) == 0 then
                    rmAller(m)
                    if ksPeut(TR_EPEE, c) and ksLancer({ id = TR_EPEE, nom = "Epee Vorace (collee au boss)" }, c) then return true end
                end
            end
        end
    end
    local cases = s(function() return fightAction:getCells_lozenge(ksCase(), 1, 3) end, {}) or {}
    table.sort(cases, function(x, y) return ksDist(tonumber(x), b.cell) < ksDist(tonumber(y), b.cell) end)
    for _, c in ipairs(cases) do
        c = tonumber(c)
        if c and not occ[c] and ksPeut(TR_EPEE, c) then
            if ksLancer({ id = TR_EPEE, nom = "Epee Vorace (vers le boss)" }, c) then return true end
        end
    end
    ksLog("TR : epee impossible (PA " .. ksPA() .. ", refus " .. tostring(KS_REFUS[TR_EPEE]) .. ")")
    return false
end

TR_SORTS_TERRE = {
    { id = 12732, nom = "Bain de Sang", zone = true, soi = true },
    { id = 12725, nom = "Supplice" },
    { id = 12746, nom = "Ravage" },
}
TR_SORTS_EAU = {
    { id = 12728, nom = "Stase" },
    { id = 12745, nom = "Condensation" },
}
function iaSacriTofu(chef)
    local tour = rmTour()
    if tour ~= KS_TOUR then KS_TOUR, KS_REFUS = tour, {} end
    local b = trBoss()
    local bloque, libres = false, -1
    if b then bloque, libres = trBloque(b) end
    ksLog("TR tour " .. tour .. " : boss " .. (b and ("case " .. b.cell .. " PV " .. b.pv .. " PM " .. b.pm) or "absent")
        .. ", sorties libres " .. tostring(libres))
    ksLancer({ id = 12761, nom = "Couronne d Epines" }, ksCase())
    if b then
        trEpee(b)
        b = trBoss() or b
        if trSeColler(b) then ksLog("TR : colle au boss en " .. ksCase()) end
        b = trBoss() or b
        trEpee(b)
    end
    local sorts = chef and TR_SORTS_TERRE or TR_SORTS_EAU
    for _ = 1, 8 do
        if ksPA() < 2 then break end
        local fait = false
        for _, cible in ipairs(trCibles(trBoss())) do
            if not fait then
                local colle = b and TR_GIDS[cible.gid] and ksDist(ksCase(), cible.cell) == 1
                local c = colle and ksCase() or rmCaseAttaque(cible, sorts, nil)
                if c then
                    if c ~= ksCase() and not (b and ksDist(ksCase(), (trBoss() or b).cell) == 1) then rmAller(c) end
                    for _, sort in ipairs(sorts) do
                        if not fait then
                            local t = sort.soi and ksCase() or cible.cell
                            if ksLancer(sort, t) then
                                fait = true
                                ksLog("TR : " .. sort.nom .. " sur " .. (TR_GIDS[cible.gid] and "le Tofu Royal" or ("monstre " .. cible.gid)))
                            end
                        end
                    end
                end
            end
        end
        if not fait then break end
    end
    local b2 = trBoss()
    if b2 and ksDist(ksCase(), b2.cell) ~= 1 then trSeColler(b2) end
end
function trCibles(b)
    local ennemis = ksListes()
    local ici = ksCase()
    local L = {}
    if b then
        for _, e in ipairs(ennemis) do if TR_GIDS[e.gid] then L[#L + 1] = e end end
    end
    local autres = {}
    for _, e in ipairs(ennemis) do if not TR_GIDS[e.gid] then autres[#autres + 1] = e end end
    local noms = {}
    for _, e in ipairs(ksEntites()) do noms[tonumber(e.CellId)] = string.lower(tostring(s(function() return e.Name end, "") or "")) end
    table.sort(autres, function(a, c)
        local sa = (noms[a.cell] or ""):find("tofubine") and 0 or 1
        local sc = (noms[c.cell] or ""):find("tofubine") and 0 or 1
        if sa ~= sc then return sa < sc end
        if a.pv ~= c.pv then return a.pv < c.pv end
        return ksDist(ici, a.cell) < ksDist(ici, c.cell)
    end)
    for _, e in ipairs(autres) do L[#L + 1] = e end
    return L
end

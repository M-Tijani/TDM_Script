EL_RESIST = {
    [198] = { eau = 100, terre = 0 },
    [240] = { eau = 0, terre = 100 },
    [241] = { eau = 0, terre = -50 },
    [194] = { eau = -50, terre = 0 },
    [795] = { eau = 24, terre = 24 },
    [798] = { eau = -10, terre = -10 },
    [797] = { eau = 24, terre = 24 },
    [84]   = { eau = 75, terre = 10 },
    [271]  = { eau = 100, terre = 25 },
    [3282] = { eau = 50, terre = 0 },
    [235]  = { eau = 10, terre = 75 },
    [270]  = { eau = 25, terre = 100 },
    [3284] = { eau = 0, terre = 50 },
    [83]   = { eau = -50, terre = 10 },
    [269]  = { eau = -25, terre = 25 },
    [81]   = { eau = 10, terre = -50 },
    [272]  = { eau = 25, terre = -25 },
    [2995] = { eau = 80, terre = 80 },
    [273]  = { eau = 23, terre = -50 },
    [274]  = { eau = 62, terre = 23 },
    [275]  = { eau = -50, terre = 23 },
    [276]  = { eau = 23, terre = 62 },
    [1182] = { eau = 0, terre = -15 },
    [1183] = { eau = -5, terre = 45 },
    [1184] = { eau = -12, terre = -12 },
    [1185] = { eau = -12, terre = -12 },
    [1186] = { eau = 94, terre = -12 },
    [1187] = { eau = -12, terre = 94 },
    [1188] = { eau = 15, terre = 15 },
}
EL_DERNIER = { [2995] = true }
EL_DERNIER_ELEM = { [1186] = "eau", [1187] = "terre" }
EL_SANS_ELEMENT = { blops = true }
EL_SALLES = {
    ["94110720"] = "scara", ["94112768"] = "scara", ["94113792"] = "scara", ["94114816"] = "scara",
    ["64749568"] = "kwakwa", ["64750592"] = "kwakwa", ["64751616"] = "kwakwa", ["64752640"] = "kwakwa",
    ["64753664"] = "kwakwa",
    ["166985728"] = "blops",
    ["166986752"] = "blops", ["166987776"] = "blops", ["166988800"] = "blops", ["166989824"] = "blops",
    ["166990848"] = "blops",
    ["166985730"] = "blops", ["166986754"] = "blops", ["166987778"] = "blops", ["166988802"] = "blops",
    ["166985736"] = "blops", ["166985987"] = "blops", ["166986758"] = "blops", ["166986760"] = "blops",
    ["166987782"] = "blops", ["166987784"] = "blops", ["166988806"] = "blops", ["166988808"] = "blops",
    ["166989830"] = "blops",
    ["166989826"] = "blops",
    ["166990850"] = "blops", ["166990856"] = "blops",
    ["205786370"] = "blops", ["205787394"] = "blops", ["205788418"] = "blops", ["205915136"] = "blops",
    ["205916160"] = "blops",
}
EL_DECLENCHEURS = {
    scara  = { [198] = true, [241] = true },
    kwakwa = { [84] = true, [271] = true, [3282] = true },
    blops  = "tous",
}
EL_EPEE_PRES_DE = {
    scara = { 198 }, kwakwa = { 271 },
    blops = { 1185, 1184, 1187, 1186, 1188 },
}
function elDonjon() return EL_SALLES[carteIci()] end
local function elScore(e, elem, allies, occupe, atteint)
    local autre = (elem == "terre") and "eau" or "terre"
    local r = resist(e.gid, elem)
    local sansElement = EL_SANS_ELEMENT[elDonjon() or ""] == true
    if r >= 100 and not sansElement then return nil end
    if r > 100 then r = 100 end
    local sc = (100 - r) * 2
    if resist(e.gid, autre) >= 100 and not sansElement then sc = sc + 120 end
    if EL_DERNIER[e.gid] then sc = sc - 400 end
    if EL_DERNIER_ELEM[e.gid] == elem then sc = sc - 600 end
    sc = sc - (e.pv or 0) / 50
    local ici = ksCase()
    local d = ksDist(ici, e.cell)
    sc = sc - d * 4
    local autour, libre = 0, false
    for _, v in ipairs(voisines(e.cell)) do
        for _, a in ipairs(allies) do if a.cell == v and v ~= ici then autour = autour + 1 end end
        if not occupe[v] and atteint[v] then libre = true end
    end
    if d > 1 and autour >= 2 then sc = sc - 30 end
    e.libre = (d <= 1) or libre
    return sc
end
local function voisines(c)
    local l = s(function() return fightAction:getCells_lozenge(c, 1, 1) end, nil)
    local r = {}
    if type(l) == "table" then for _, x in ipairs(l) do r[#r + 1] = tonumber(x) end end
    return r
end
local function monPVpct()
    local ici = ksCase()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CellId) == ici then
            local pv, mx = tonumber(e.LifePoints) or 0, tonumber(e.MaxLifePoints) or 0
            if mx > 0 then return pv * 100 / mx end
        end
    end
    return 100
end
local function resist(gid, elem)
    local r = EL_RESIST[gid]
    if r == nil then return 0 end
    return r[elem] or 0
end
local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function iaSacriElements(estChef)
    local tour = tonumber(s(function() return fightAction:getCurrentTurn() end, 0)) or 0
    if tour ~= KS_TOUR then KS_TOUR, KS_REFUS = tour, {} end
    local terre = estChef or (lireEtat ~= nil and tostring(lireEtat("RESTAT_TERRE")) == "1")
    local elem = terre and "terre" or "eau"
    local sorts = terre and KS_SORTS_TERRE or KS_SORTS_EAU
    local dj = elDonjon() or "?"
    ksInvoquerEpee(gidEpee(dj))
    ksLancer({ id = 12761, nom = "Couronne d Epines" }, ksCase())
    if dj ~= "blops" and ksPA() >= 8 and monPVpct() > 60 then ksLancer({ id = 12737, nom = "Mutilation" }, ksCase()) end
    for _ = 1, 8 do
        if ksPA() < 2 then break end
        local cibles = elCibles(elem)
        if #cibles == 0 then ksLog(dj .. " : aucune cible utile en " .. elem) break end
        local fait = false
        for _, e in ipairs(cibles) do
            if fait then break end
            if taper(sorts, e) then fait = true end
        end
        if not fait then
            local choisie = nil
            for _, e in ipairs(cibles) do if e.libre then choisie = e break end end
            if choisie then
                if not attirer(choisie) then marcherVers(choisie) end
                fait = taper(sorts, choisie)
            else
                for _, e in ipairs(cibles) do
                    if not fait and attirer(e) then fait = taper(sorts, e) end
                end
            end
        end
        if not fait then
            marcherVers(cibles[1])
            for _, e in ipairs(elCibles(elem)) do
                if fait then break end
                if taper(sorts, e) then fait = true end
            end
        end
        if not fait then ksLog(dj .. " : aucun sort ne passe (" .. elem .. ", PA " .. ksPA() .. ")") break end
    end
end
local function terrain()
    local ennemis, allies = ksListes()
    local occupe = {}
    for _, e in ipairs(ennemis) do occupe[e.cell] = true end
    for _, a in ipairs(allies) do occupe[a.cell] = true end
    local atteint = {}
    for _, c in ipairs(s(function() return fightAction:getRealReachableCells() end, {}) or {}) do
        atteint[tonumber(c)] = true
    end
    return ennemis, allies, occupe, atteint
end
local function taper(sorts, e)
    for _, sort in ipairs(sorts) do
        local x = sort.soi and ksCase() or e.cell
        if ksLancer(sort, x) then return true end
    end
    return false
end
local function gidEpee(dj)
    local ennemis = ksListes()
    for _, g in ipairs(EL_EPEE_PRES_DE[dj] or {}) do
        for _, e in ipairs(ennemis) do if e.gid == g then return g end end
    end
    return (EL_EPEE_PRES_DE[dj] or { 271 })[1]
end
function elCibles(elem)
    local ennemis, allies, occupe, atteint = terrain()
    local l = {}
    for _, e in ipairs(ennemis) do
        local sc = elScore(e, elem, allies, occupe, atteint)
        if sc ~= nil then e.sc = sc l[#l + 1] = e end
    end
    table.sort(l, function(a, b) return a.sc > b.sc end)
    return l
end
function elPresent()
    local dj = elDonjon()
    if dj == nil then return false end
    local decl = EL_DECLENCHEURS[dj] or {}
    if decl == "tous" then
        local ennemis = ksListes()
        return #ennemis > 0
    end
    for _, e in ipairs(ksEntites()) do
        if decl[tonumber(e.CreatureGenericId) or 0] and (tonumber(e.LifePoints) or 0) > 0 then return true end
    end
    return false
end
local function attirer(e)
    if ksDist(ksCase(), e.cell) < 2 then return false end
    if not ksLancer({ id = KS_ATTIRANCE, nom = "Attirance" }, e.cell) then return false end
    for _, x in ipairs((ksListes())) do if x.id == e.id then e.cell = x.cell end end
    return ksDist(ksCase(), e.cell) <= 1
end
local function marcherVers(e)
    if ksPM() <= 0 then return false end
    local ici = ksCase()
    local reach = s(function() return fightAction:getRealReachableCells() end, {}) or {}
    local meilleure, md = nil, 99
    for _, c in ipairs(reach) do
        c = tonumber(c)
        if ksDist(c, e.cell) == 1 and ksDist(ici, c) < md then meilleure, md = c, ksDist(ici, c) end
    end
    if meilleure == nil then
        for _, c in ipairs(reach) do
            c = tonumber(c)
            if meilleure == nil or ksDist(c, e.cell) < ksDist(meilleure, e.cell) then meilleure = c end
        end
    end
    if meilleure and meilleure ~= ici and ksDist(meilleure, e.cell) < ksDist(ici, e.cell) then
        deplacerCombat(meilleure)
        for _ = 1, 100 do if ksCase() == meilleure then break end global:delay(20) end
    end
    return ksDist(ksCase(), e.cell) <= 1
end
local function carteIci()
    if carte then return tostring(s(carte, "")) end
    return tostring(s(function() return map:currentMapId() end, ""))
end

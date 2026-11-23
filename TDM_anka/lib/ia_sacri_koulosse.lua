KS_KOULOSSE, KS_BOUFTOU, KS_BOUFCOUL = 670, 671, 672
KS_DELAI = 0
KS_SOUFFLE_PO = 5
KS_BUFFS = { 12761, 12737 }
KS_ATTIRANCE = 12735
KS_SORTS_EAU = {
    { id = 12728, nom = "Stase" },
    { id = 12745, nom = "Condensation", zone = true },
}
KS_SORTS_TERRE = {
    { id = 12732, nom = "Bain de Sang", zone = true, soi = true, prioritaire = true },
    { id = 12746, nom = "Ravage" },
    { id = 12725, nom = "Supplice" },
    { id = 12731, nom = "Decimation", zone = true },
    { id = 12729, nom = "Afflux", zone = true, soi = true },
}
function ksCase() return tonumber(s(function() return fightCharacter:getCellId() end, -1)) or -1 end
local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
function ksLog(m) pcall(function() global:printSuccess("[IA SACRI] " .. tostring(m)) end) end
function ksPM() return tonumber(s(function() return fightCharacter:getMP() end, 0)) or 0 end
function ksKoulossePresent()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CreatureGenericId) == KS_KOULOSSE and (tonumber(e.LifePoints) or 0) > 0 then return true end
    end
    return false
end
function ksListes()
    local camp = ksMonCamp()
    local ennemis, allies = {}, {}
    for _, e in ipairs(ksEntites()) do
        if (tonumber(e.LifePoints) or 0) > 0 then
            local allie
            if camp ~= nil then allie = (e.Team == camp) else allie = (e.Team ~= true) end
            local x = { cell = tonumber(e.CellId), id = e.Id, gid = tonumber(e.CreatureGenericId) or 0,
                        pv = tonumber(e.LifePoints) or 0 }
            if allie then allies[#allies + 1] = x else ennemis[#ennemis + 1] = x end
        end
    end
    return ennemis, allies
end
function ksDist(a, b) return tonumber(s(function() return fightAction:getDistance(a, b) end, 99)) or 99 end
function ksPA() return tonumber(s(function() return fightCharacter:getAP() end, 0)) or 0 end
function ksEntites() return s(function() return fightAction:getAllEntities() end, {}) or {} end
function ksMonCamp()
    local ici = ksCase()
    for _, e in ipairs(ksEntites()) do if tonumber(e.CellId) == ici then return e.Team end end
    return nil
end

KS_REFUS, KS_TOUR = {}, -1
function ksLancer(sort, cible)
    if not ksPeut(sort.id, cible) then return false end
    if sort.zone and not ksZoneSure(sort.id, cible, sort.soi) then return false end
    local avant = ksPA()
    pcall(function() fightAction:castSpellOnCell(sort.id, cible) end)
    if KS_DELAI > 0 then global:delay(KS_DELAI) end
    for _ = 1, 30 do if ksPA() < avant then break end global:delay(20) end
    if ksPA() >= avant then KS_REFUS[sort.id] = true return false end
    ksLog((sort.nom or sort.id) .. " sur " .. tostring(cible))
    return true
end
function ksCible(ennemis)
    local ici = ksCase()
    local best, score = nil, -1
    for _, e in ipairs(ennemis) do
        local sc = 1
        if e.gid == KS_KOULOSSE then sc = 200
        elseif e.gid == KS_BOUFCOUL then sc = 100
        elseif e.gid == KS_BOUFTOU and ksDist(ici, e.cell) <= 1 then sc = 80
        elseif e.gid == KS_KOULOSSE then sc = 50
        elseif e.gid == KS_BOUFTOU then sc = 10 end
        sc = sc - ksDist(ici, e.cell) * 0.1
        if sc > score then best, score = e, sc end
    end
    return best
end
function ksSeMettreHorsSouffle()
    local kc = nil
    for _, e in ipairs((ksListes())) do if e.gid == KS_KOULOSSE then kc = e.cell end end
    if kc == nil then return end
    local ici = ksCase()
    ksLog("fin de tour : case " .. ici .. ", Koulosse " .. kc .. ", dist " .. ksDist(ici, kc)
        .. ", aligne " .. tostring(s(function() return fightAction:cellsAligned(ici, kc) end, "?"))
        .. ", ldv " .. tostring(s(function() return fightAction:inLineOfSight(kc, ici) end, "?")))
    if ksHorsSouffle(ici, kc) then return end
    if ksPM() <= 0 then ksLog("en ligne du Koulosse mais plus de PM") return end
    local meilleure, md = nil, 99
    for _, c in ipairs(s(function() return fightAction:getRealReachableCells() end, {}) or {}) do
        c = tonumber(c)
        if ksHorsSouffle(c, kc) then
            local d = ksDist(c, kc)
            if d < md then meilleure, md = c, d end
        end
    end
    if meilleure then
        deplacerCombat(meilleure)
        for _ = 1, 100 do if ksCase() == meilleure then break end global:delay(20) end
        ksLog("fin de tour hors du Souffle : case " .. meilleure .. " (Koulosse a " .. md .. ")")
    else
        ksLog("aucune case hors du Souffle atteignable")
    end
end
function ksSeColler(cible)
    local ici = ksCase()
    if ksDist(ici, cible.cell) <= 1 then return true end
    if cible.gid ~= KS_KOULOSSE or true then
        if ksLancer({ id = KS_ATTIRANCE, nom = "Attirance" }, cible.cell) then
            local e2 = nil
            for _, e in ipairs((ksListes())) do if e.id == cible.id then e2 = e end end
            if e2 then cible.cell = e2.cell end
            if ksDist(ksCase(), cible.cell) <= 1 then return true end
        end
    end
    if ksPM() <= 0 then return false end
    local meilleure, md = nil, 99
    for _, c in ipairs(s(function() return fightAction:getRealReachableCells() end, {}) or {}) do
        c = tonumber(c)
        local d = ksDist(c, cible.cell)
        if d == 1 and (meilleure == nil or ksDist(ici, c) < md) then meilleure, md = c, ksDist(ici, c) end
    end
    if meilleure == nil then
        for _, c in ipairs(s(function() return fightAction:getRealReachableCells() end, {}) or {}) do
            c = tonumber(c)
            if meilleure == nil or ksDist(c, cible.cell) < ksDist(meilleure, cible.cell) then meilleure = c end
        end
    end
    if meilleure and meilleure ~= ici then
        deplacerCombat(meilleure)
        for _ = 1, 100 do if ksCase() == meilleure then break end global:delay(20) end
    end
    return ksDist(ksCase(), cible.cell) <= 1
end
function ksPeut(id, cible)
    if KS_REFUS[id] then return false end
    return tonumber(s(function() return fightAction:canCastSpellOnCell(ksCase(), id, cible) end, 99)) == 0
end
function ksHorsSouffle(c, kc)
    if kc == nil then return true end
    if ksDist(c, kc) > KS_SOUFFLE_PO then return true end
    if s(function() return fightAction:cellsAligned(c, kc) end, true) ~= true then return true end
    if s(function() return fightAction:inLineOfSight(kc, c) end, true) ~= true then return true end
    return false
end
function ksZoneSure(id, cible, exigerEnnemi)
    local cells = s(function() return fightAction:getSpellZone(id, cible) end, nil)
    if type(cells) ~= "table" then return false end
    local ennemis, allies = ksListes()
    local ici = ksCase()
    local touche = 0
    for _, c in ipairs(cells) do
        c = tonumber(c)
        for _, a in ipairs(allies) do
            if a.cell == c and c ~= ici and (a.gid or 0) == 0 then return false end
        end
        for _, e in ipairs(ennemis) do if e.cell == c then touche = touche + 1 end end
    end
    if exigerEnnemi and touche == 0 then return false end
    return true
end

KS_EPEE = 12744
KS_EPEE_COMBAT = KS_EPEE_COMBAT or nil
function ksPremierTour()
    local t = tonumber(s(function() return fightAction:getCurrentTurn() end, 0)) or 0
    return t <= 1
end
function iaSacriKoulosse(estChef)
    local tour = tonumber(s(function() return fightAction:getCurrentTurn() end, 0)) or 0
    if tour ~= KS_TOUR then KS_TOUR, KS_REFUS = tour, {} end
    local ici = ksCase()
    ksInvoquerEpee()
    ksLancer({ id = 12761, nom = "Couronne d Epines" }, ksCase())
    if ksPA() >= 8 then ksLancer({ id = 12737, nom = "Mutilation" }, ksCase()) end
    local sorts = estChef and KS_SORTS_TERRE or KS_SORTS_EAU
    for _ = 1, 8 do
        if ksPA() < 2 then break end
        local ennemis = ksListes()
        local cible = ksCible(ennemis)
        if cible == nil then ksLog("aucune cible (" .. #ennemis .. " ennemis vus)") break end
        ksLog("cible " .. cible.gid .. " case " .. tostring(cible.cell) .. " dist " .. ksDist(ksCase(), cible.cell) .. " PA " .. ksPA() .. " PM " .. ksPM())
        ksSeColler(cible)
        ksLog("apres approche : case " .. ksCase() .. " dist " .. ksDist(ksCase(), cible.cell))
        local fait = false
        for _, sort in ipairs(sorts) do
            if not fait then
                local c = sort.soi and ksCase() or cible.cell
                if ksLancer(sort, c) then fait = true end
            end
        end
        if not fait then
            for _, e in ipairs(ennemis) do
                for _, sort in ipairs(sorts) do
                    if not fait and not sort.soi and ksLancer(sort, e.cell) then fait = true end
                end
            end
        end
        if not fait then
            local codes = {}
            for _, sort in ipairs(sorts) do
                local c = sort.soi and ksCase() or cible.cell
                codes[#codes + 1] = (sort.nom or sort.id) .. "=" .. tostring(s(function() return fightAction:canCastSpellOnCell(ksCase(), sort.id, c) end, "?"))
                    .. (KS_REFUS[sort.id] and "(refus)" or "")
            end
            ksLog("aucun sort ne passe : " .. table.concat(codes, ", "))
            break
        end
    end
    ksSeMettreHorsSouffle()
end
function ksInvoquerEpee(gidBoss)
    if KS_REFUS[KS_EPEE] and not ksPremierTour() then return end
    local ici = ksCase()
    local ennemis, allies = ksListes()
    local kc = nil
    for _, e in ipairs(ennemis) do if e.gid == (gidBoss or KS_KOULOSSE) then kc = e.cell end end
    local occupe = {}
    for _, e in ipairs(ennemis) do occupe[e.cell] = true end
    for _, a in ipairs(allies) do occupe[a.cell] = true end
    local cases = s(function() return fightAction:getCells_lozenge(ici, 1, 3) end, {}) or {}
    table.sort(cases, function(a, b)
        a, b = tonumber(a), tonumber(b)
        if kc then return ksDist(a, kc) < ksDist(b, kc) end
        return ksDist(ici, a) < ksDist(ici, b)
    end)
    for _, c in ipairs(cases) do
        c = tonumber(c)
        if c and not occupe[c] and ksPeut(KS_EPEE, c) then
            if ksLancer({ id = KS_EPEE, nom = "Epee Vorace (invocation)" }, c) then return end
        end
    end
    if ksPremierTour() then KS_REFUS[KS_EPEE] = nil ksInvoquerEpeeLibre("1er tour") end
end
function ksInvoquerEpeeLibre(tag)
    local ici = ksCase()
    local ennemis, allies = ksListes()
    local occupe = {}
    for _, e in ipairs(ennemis) do occupe[e.cell] = true end
    for _, a in ipairs(allies) do occupe[a.cell] = true end
    local cases = s(function() return fightAction:getCells_lozenge(ici, 1, 3) end, {}) or {}
    local codes = {}
    for _, c in ipairs(cases) do
        c = tonumber(c)
        if c and not occupe[c] then
            if ksPeut(KS_EPEE, c) then
                if ksLancer({ id = KS_EPEE, nom = "Epee Vorace (invocation, " .. tag .. ")" }, c) then return true end
            elseif #codes < 4 then
                codes[#codes + 1] = c .. "=" .. tostring(s(function() return fightAction:canCastSpellOnCell(ici, KS_EPEE, c) end, "?"))
            end
        end
    end
    ksLog("Epee Vorace IMPOSSIBLE au 1er tour (" .. #cases .. " cases ; " .. table.concat(codes, ", ") .. ")")
    return false
end

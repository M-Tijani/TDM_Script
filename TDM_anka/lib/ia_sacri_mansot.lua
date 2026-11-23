MS_GID = 2848
MS_PERFUSION = 12758
MS_SUPPLICE = 12725
MS_DUREE_VULN = 6
MS_CLE_VULN = "MS_VULN_TOUR"
MS_CLE_PERF = "MS_PERF_TOUR"
local function ecrireMemMS(k, v)
    pcall(function() developer:deleteFromGlobalMemory(k) end)
    pcall(function() developer:addInGlobalMemory(k, tostring(v)) end)
end
function msPresent()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CreatureGenericId) == MS_GID and (tonumber(e.LifePoints) or 0) > 0 then return true end
    end
    return false
end
function msCasePorteur() return lireMemMS("MS_PORTEUR_CASE") end
function msVulnerable()
    local t = lireMemMS(MS_CLE_VULN)
    if t == nil then return false end
    local tour = rmTour()
    if MS_INVUL_CONSTATE == tour then return false end
    return tour >= t and tour < t + MS_DUREE_VULN
end
local function lireMemMS(k) return tonumber(s(function() return developer:getInGlobalMemory(k) end, nil)) end
function msBoss()
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CreatureGenericId) == MS_GID and (tonumber(e.LifePoints) or 0) > 0 then
            return { cell = tonumber(e.CellId), gid = MS_GID, pv = tonumber(e.LifePoints) or 0, pm = tonumber(e.MP) or 4, id = e.Id }
        end
    end
    return nil
end
local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end

MS_INVUL_CONSTATE = MS_INVUL_CONSTATE or -1
MS_DERNIER_COMBAT = MS_DERNIER_COMBAT or nil
function msNouveauCombat()
    local tour = rmTour()
    if MS_DERNIER_TOUR_VU and tour < MS_DERNIER_TOUR_VU then
        ecrireMemMS(MS_CLE_VULN, -100) ecrireMemMS(MS_CLE_PERF, -100) MS_INVUL_CONSTATE = -1
    end
    MS_DERNIER_TOUR_VU = tour
end
function msPerfusionSurPorteur(boss)
    if boss == nil or msVulnerable() then return false end
    if lireMemMS(MS_CLE_PERF) == rmTour() then return false end
    local p = msCasePorteur()
    if p == nil or ksDist(p, boss.cell) ~= 1 then return false end
    local _, allies = ksListes()
    local present = false
    for _, a in ipairs(allies) do if a.cell == p then present = true end end
    if not present then return false end
    local function essayer()
        if ksPeut(MS_PERFUSION, p) and ksLancer({ id = MS_PERFUSION, nom = "Perfusion sur le porteur" }, p) then
            ecrireMemMS(MS_CLE_PERF, rmTour())
            msDeclenche("Perfusion d une mule")
            return true
        end
        return false
    end
    if essayer() then return true end
    local ici = ksCase()
    local best, bestCout = nil, 99
    for _, c in ipairs(rmAtteignables()) do
        local cout = ksDist(ici, c)
        if cout <= ksPM() and ksDist(c, p) >= 2 and ksDist(c, boss.cell) >= 3 and cout < bestCout
            and tonumber(s(function() return fightAction:canCastSpellOnCellAfterMove(c, MS_PERFUSION, p) end, 99)) == 0 then
            best, bestCout = c, cout
        end
    end
    if best then rmAller(best) return essayer() end
    return false
end
local function msTaper(sort, cible, boss)
    local pvAvant = boss and boss.pv or 0
    if not ksLancer(sort, cible) then return false end
    if boss and cible == boss.cell then
        local apres = msBoss()
        for _ = 1, 50 do
            apres = msBoss()
            if apres == nil or apres.pv < pvAvant then break end
            global:delay(20)
        end
        if apres and apres.pv >= pvAvant then
            MS_INVUL_CONSTATE = rmTour()
            ecrireMemMS(MS_CLE_VULN, -100)
            ksLog("MS : " .. (sort.nom or sort.id) .. " sans effet -> boss encore invulnerable")
        else
            ksLog("MS : " .. (sort.nom or sort.id) .. " sur le Mansot Royal (PV " .. pvAvant .. " -> " .. tostring(apres and apres.pv or 0) .. ")")
        end
    end
    return true
end
local function msDeclenche(source)
    ecrireMemMS(MS_CLE_VULN, rmTour())
    MS_INVUL_CONSTATE = -1
    ksLog("MS : soin en melee du boss (" .. source .. ") -> vulnerable " .. MS_DUREE_VULN .. " tours (a verifier aux PV)")
end
function msPorteur(boss)
    if boss == nil then return end
    local ici = ksCase()
    local function coller()
        local best, bd = nil, 99
        for _, c in ipairs(rmAtteignables()) do
            if ksDist(c, boss.cell) == 1 and ksDist(ksCase(), c) <= ksPM() and ksDist(ksCase(), c) < bd then best, bd = c, ksDist(ksCase(), c) end
        end
        if best and best ~= ksCase() then rmAller(best) end
    end
    coller()
    if ksDist(ksCase(), boss.cell) ~= 1 and not msVulnerable() then
        if ksLancer({ id = KS_ATTIRANCE or 12735, nom = "Attirance sur le Mansot" }, boss.cell) then
            boss = msBoss() or boss
            coller()
        end
    end
    ecrireMemMS("MS_PORTEUR_CASE", ksCase())
    if ksDist(ksCase(), boss.cell) ~= 1 then
        ksLog("MS porteur : impossible de se coller au boss ce tour (meme apres Attirance)")
        return
    end
    if msVulnerable() then return end
    local pv, mx = 0, 0
    for _, e in ipairs(ksEntites()) do
        if tonumber(e.CellId) == ksCase() then pv, mx = tonumber(e.LifePoints) or 0, tonumber(e.MaxLifePoints) or 0 end
    end
    if mx > 0 and pv >= mx then ksLancer({ id = 12737, nom = "Mutilation (PV manquants pour le vol de vie)" }, ksCase()) end
    local occupe = {}
    for _, e in ipairs(ksEntites()) do occupe[tonumber(e.CellId)] = true end
    local epee = false
    local zone = s(function() return fightAction:getSpellZone(12732, ksCase()) end, nil)
    local ennemiZone = false
    if type(zone) == "table" then
        local dans = {}
        for _, c in ipairs(zone) do dans[tonumber(c)] = true end
        for _, e in ipairs(ksListes()) do if dans[e.cell] then ennemiZone = true end end
    end
    if ennemiZone and ksLancer({ id = 12732, nom = "Bain de Sang (vol de vie au contact du boss)" }, ksCase()) then
        msDeclenche("Bain de Sang du porteur" .. (epee and " sur l Epee Vorace" or ""))
        return
    end
    for _, e in ipairs(ksListes()) do
        if e.gid ~= MS_GID and ksDist(ksCase(), e.cell) == 1 and ksPA() >= 3 then
            if ksLancer({ id = MS_SUPPLICE, nom = "Supplice (soin en melee du boss)" }, e.cell) then
                msDeclenche("Supplice du porteur")
                return
            end
        end
    end
    ksLog("MS porteur : colle au boss en " .. ksCase() .. ", Bain de Sang impossible -> Perfusion attendue des mules")
end

MS_SORTS_TERRE = {
    { id = 12725, nom = "Supplice" },
    { id = 12746, nom = "Ravage" },
    { id = 12731, nom = "Decimation", zone = true },
}
MS_SORTS_EAU = {
    { id = 12728, nom = "Stase" },
    { id = 12745, nom = "Condensation" },
}
function msCibles(boss, vuln)
    local ennemis = ksListes()
    local ici = ksCase()
    if boss and vuln then return { boss } end
    local inv = {}
    for _, e in ipairs(ennemis) do if e.gid ~= MS_GID and e.pv >= 700 then inv[#inv + 1] = e end end
    table.sort(inv, function(a, b)
        if a.pv ~= b.pv then return a.pv > b.pv end
        return ksDist(ici, a.cell) < ksDist(ici, b.cell)
    end)
    local focusId = s(function() return developer:getInGlobalMemory("MS_FOCUS") end, nil)
    local focus = nil
    for _, e in ipairs(inv) do if tostring(e.id) == tostring(focusId) then focus = e end end
    if focus == nil and #inv > 0 then
        focus = inv[1]
        ecrireMemMS("MS_FOCUS", tostring(focus.id))
    end
    local L = {}
    if focus then L[#L + 1] = focus end
    for _, e in ipairs(inv) do if e ~= focus then L[#L + 1] = e end end
    return L
end
function msFinDeTour(boss, chef)
    if boss == nil or chef then return end
    local p = msCasePorteur()
    if msVulnerable() then
        local ici, best, bestD = ksCase(), ksCase(), 99
        for _, c in ipairs(rmAtteignables()) do
            local d = ksDist(c, boss.cell)
            if d >= 2 and (p == nil or ksDist(c, p) >= 2) and math.abs(d - 3) < math.abs(bestD - 3) then best, bestD = c, d end
        end
        if best ~= ici then rmAller(best) end
        ksLog("MS fin de tour (boss VULNERABLE) : case " .. ksCase() .. ", boss a " .. ksDist(ksCase(), boss.cell))
        return
    end
    local ennemis = ksListes()
    local function score(c)
        local d = ksDist(c, boss.cell)
        local sc = math.min(d, (boss.pm or 4) + 3) * 10
        if p and ksDist(c, p) <= 1 then sc = sc - 500 end
        local m = 99
        for _, e in ipairs(ennemis) do if e.gid ~= MS_GID then m = math.min(m, ksDist(c, e.cell)) end end
        sc = sc + math.min(m, 6) * 3
        return sc
    end
    local ici = ksCase()
    local best, bestSc = ici, score(ici)
    for _, c in ipairs(rmAtteignables()) do
        local sc = score(c)
        if sc > bestSc then best, bestSc = c, sc end
    end
    if best ~= ici then rmAller(best) end
    ksLog("MS fin de tour : case " .. ksCase() .. ", boss a " .. ksDist(ksCase(), boss.cell))
end
function iaSacriMansot(chef)
    local tour = rmTour()
    if tour ~= KS_TOUR then KS_TOUR, KS_REFUS = tour, {} end
    msNouveauCombat()
    local boss = msBoss()
    local vuln = msVulnerable()
    ksLog("MS tour " .. tour .. " : boss " .. (boss and ("case " .. boss.cell .. " PV " .. boss.pv .. " PM " .. tostring(boss.pm)) or "absent")
        .. ", " .. (vuln and "VULNERABLE" or "invulnerable") .. (chef and " (porteur)" or ""))
    ksLancer({ id = 12761, nom = "Couronne d Epines" }, ksCase())
    local function ennemiProche()
        local zone = s(function() return fightAction:getSpellZone(12732, ksCase()) end, nil)
        if type(zone) ~= "table" then return false end
        local dans = {}
        for _, c in ipairs(zone) do dans[tonumber(c)] = true end
        for _, e in ipairs((ksListes())) do if dans[e.cell] then return true end end
        return false
    end
    local function bainDeSang(quand)
        if not chef then return end
        for _ = 1, 3 do
            if ksPA() < 4 or not ennemiProche() then return end
            if not ksLancer({ id = 12732, nom = "Bain de Sang (sur soi)" }, ksCase()) then return end
            ksLog("MS : Bain de Sang sur moi (" .. quand .. ")")
        end
    end
    bainDeSang("debut de tour")
    if chef then
        msPorteur(boss)
    else
        msPerfusionSurPorteur(boss)
    end
    boss = msBoss() or boss
    vuln = msVulnerable()
    bainDeSang("apres porteur")
    local sorts = chef and MS_SORTS_TERRE or MS_SORTS_EAU
    for _ = 1, 8 do
        if ksPA() < 2 then break end
        bainDeSang("avant chaque attaque")
        if ksPA() < 2 then break end
        local fait = false
        for _, cible in ipairs(msCibles(boss, vuln)) do
            if not fait then
                local c
                if chef and boss and ksDist(ksCase(), boss.cell) == 1 then c = ksCase()
                else c = rmCaseAttaque(cible, sorts, nil) end
                if c == nil and vuln and cible.gid == MS_GID and not chef then
                    local p, best, bestD = msCasePorteur(), nil, ksDist(ksCase(), cible.cell)
                    for _, cc in ipairs(rmAtteignables()) do
                        local d = ksDist(cc, cible.cell)
                        if d < bestD and (p == nil or ksDist(cc, p) >= 2) then best, bestD = cc, d end
                    end
                    if best then rmAller(best) end
                    c = ksCase()
                end
                if c then
                    if c ~= ksCase() then
                        local p = msCasePorteur()
                        if chef or p == nil or ksDist(c, p) >= 2 or (vuln and cible.gid == MS_GID) then rmAller(c) end
                    end
                    for _, sort in ipairs(sorts) do
                        if not fait and msTaper(sort, cible.cell, (cible.gid == MS_GID) and boss or nil) then
                            fait = true
                            if cible.gid == MS_GID and MS_INVUL_CONSTATE == tour then vuln = false end
                            boss = msBoss() or boss
                        end
                    end
                end
            end
        end
        if not fait then break end
    end
    msFinDeTour(msBoss() or boss, chef)
end

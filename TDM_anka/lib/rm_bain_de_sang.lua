local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
RM_BAIN = 12732
function rmBainDeSang(rm, vuln)
    for _ = 1, 3 do
        if KS_REFUS[RM_BAIN] or ksPA() < 2 then return end
        local ennemis, allies = ksListes()
        local ici = ksCase()
        local best, bestU, bestCout = nil, 0, 99
        local cands = { ici }
        for _, c in ipairs(s(function() return fightAction:getRealReachableCells() end, {}) or {}) do cands[#cands + 1] = tonumber(c) end
        for _, c in ipairs(cands) do
            local cout = ksDist(ici, c)
            local lich = rm and ksDist(c, rm.cell) <= 1 and rmAligne(c, rm.cell)
            if cout <= ksPM() and not lich then
                local u = rmBainScore(c, rm, vuln, ennemis, allies, ici)
                if u > bestU or (u == bestU and u > 0 and cout < bestCout) then best, bestU, bestCout = c, u, cout end
            end
        end
        if best == nil then return end
        if best ~= ici then rmAller(best) end
        if not ksLancer({ id = RM_BAIN, nom = "Bain de Sang", zone = true, soi = true }, ksCase()) then return end
        ksLog("RM : Bain de Sang sur moi (" .. bestU .. " monstre(s) utile(s), aucun allie)")
    end
end
function rmBainScore(c, rm, vuln, ennemis, allies, ici)
    local zone = s(function() return fightAction:getSpellZone(RM_BAIN, c) end, nil)
    if type(zone) ~= "table" then return -1 end
    local utiles = 0
    for _, z in ipairs(zone) do
        z = tonumber(z)
        for _, a in ipairs(allies) do if a.cell == z and a.cell ~= ici then return -1 end end
        for _, e in ipairs(ennemis) do
            if e.cell == z and (e.gid ~= RM_GID or vuln) then utiles = utiles + 1 end
        end
    end
    return utiles
end

RM_CIBLES_ORIG = RM_CIBLES_ORIG or rmCibles
function rmCibles(rm, vuln)
    if RM_CHEF_COURANT and RM_BAIN_TOUR ~= KS_TOUR then
        RM_BAIN_TOUR = KS_TOUR
        rmBainDeSang(rm, vuln)
        rm = rmEntite() or rm
    end
    return RM_CIBLES_ORIG(rm, vuln)
end

SC_BLEU, SC_BLANC, SC_ROUGE, SC_VERT = 198, 241, 194, 240
SC_SALLES = { ["94110720"] = true, ["94112768"] = true, ["94113792"] = true, ["94114816"] = true }
local function s(f, d) local ok, v = pcall(f) if ok and v ~= nil then return v end return d end
local function scScore(e, chef)
    local sc
    if chef then
        if e.gid == SC_VERT then return nil end
        if e.gid == SC_BLEU then sc = 300 elseif e.gid == SC_BLANC then sc = 200 else sc = 100 end
    else
        if e.gid == SC_BLEU then return nil end
        if e.gid == SC_ROUGE then sc = 300 elseif e.gid == SC_BLANC then sc = 200 else sc = 150 end
    end
    return sc - ksDist(ksCase(), e.cell) * 4 - (e.pv or 0) / 50
end
function iaSacriScara(estChef)
    local tour = tonumber(s(function() return fightAction:getCurrentTurn() end, 0)) or 0
    if tour ~= KS_TOUR then KS_TOUR, KS_REFUS = tour, {} end
    ksInvoquerEpee(SC_BLEU)
    ksLancer({ id = 12761, nom = "Couronne d Epines" }, ksCase())
    if ksPA() >= 8 then ksLancer({ id = 12737, nom = "Mutilation" }, ksCase()) end
    local terre = estChef or (lireEtat ~= nil and tostring(lireEtat("RESTAT_TERRE")) == "1")
    local sorts = terre and KS_SORTS_TERRE or KS_SORTS_EAU
    for _ = 1, 8 do
        if ksPA() < 2 then break end
        local cibles = scCibles(terre)
        if #cibles == 0 then ksLog("Scarafeuilles : aucune cible utile (Bleus immunises a l eau)") break end
        local fait = false
        for _, e in ipairs(cibles) do
            if fait then break end
            for _, sort in ipairs(sorts) do
                if not fait and not sort.soi and ksLancer(sort, e.cell) then fait = true end
            end
        end
        if not fait then
            local c = cibles[1]
            ksSeColler(c)
            for _, sort in ipairs(sorts) do
                if not fait then
                    local x = sort.soi and ksCase() or c.cell
                    if ksLancer(sort, x) then fait = true end
                end
            end
        end
        if not fait then ksLog("Scarafeuilles : aucun sort ne passe (PA " .. ksPA() .. ")") break end
    end
end
function scPresent()
    for _, e in ipairs(ksEntites()) do
        local g = tonumber(e.CreatureGenericId) or 0
        if (g == SC_BLEU or g == SC_BLANC) and (tonumber(e.LifePoints) or 0) > 0 then return true end
    end
    return false
end
function scCibles(chef)
    local l = {}
    for _, e in ipairs((ksListes())) do
        local sc = scScore(e, chef)
        if sc ~= nil then e.sc = sc l[#l + 1] = e end
    end
    table.sort(l, function(a, b) return a.sc > b.sc end)
    return l
end

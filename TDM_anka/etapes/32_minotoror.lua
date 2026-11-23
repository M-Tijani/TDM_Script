charger("etapes\\lib_donjons.lua", true)
MINO_MAP_ENTREE = "34476296"
MINO_LIMITE_GROUPE = 8
MINO_MOBS = { { id = 831, nom = "Mominotor" }, { id = 832, nom = "Deminoboule" } }
MINO_NPC_LORKOS = 783
MINO_PHENIX = { map = "34476296", levier = 429, trig = { 444, 431 } }
MINO_MAP_BOSS = "34473474"
MINO_MAP_APRES_BOSS = "34473476"
MINO_MAP_SORTIE = "34476294"
MINO_TRIG_SORTIE = 436
MINO_MAP_DEHORS = "152849"
MINO_SALLES = {
    [1] = { coords = "-40,-17", map = "34475272",
             lev  = { haut = nil, bas = 457, gauche = nil, droite = 332 },
             trig = { haut = { }, bas = {455 }, gauche = { }, droite = {305 } } },
    [2] = { coords = "-39,-17", map = "34474248",
             lev  = { haut = nil, bas = 541, gauche = nil, droite = 429 },
             trig = { haut = { }, bas = { 539}, gauche = {365 }, droite = {403 } } },
    [3] = { coords = "-38,-17", map = "34473224",
             lev  = { haut = nil, bas = 525, gauche = 423, droite = 470 },
             trig = { haut = { }, bas = {509 }, gauche = {393 }, droite = {444 } } },
    [4] = { coords = "-37,-17", map = "34341128",
             lev  = { haut = nil, bas = 526, gauche = 382, droite = 345 },
             trig = { haut = { }, bas = { 524}, gauche = { 408 }, droite = { 347 } } },
    [5] = { coords = "-36,-17", map = "34342152",
             lev  = { haut = nil, bas = 499, gauche = 422, droite = nil },
             trig = { haut = { }, bas = {501}, gauche = { 406}, droite = { } } },
    [6] = { coords = "-40,-16", map = "34475270",
             lev  = { haut = nil, bas = 454, gauche = nil, droite = 416 },
             trig = { haut = {105 }, bas = { 452}, gauche = { }, droite = { 404} } },
    [7] = { coords = "-39,-16", map = "34474246",
             lev  = { haut = 130, bas = 555, gauche =  381, droite = 402 },
             trig = { haut = {147 }, bas = {539 }, gauche = { 379}, droite = { 404 } } },
    [8] = { coords = "-38,-16", map = "34473222",
             lev  = { haut = 160, bas = 494, gauche = 464, droite = 470 },
             trig = { haut = { 134}, bas = { 551}, gauche = { 421}, droite = {472 } } },
    [9] = { coords = "-37,-16", map = "34341126",
             lev  = { haut = 132, bas = 498, gauche = 382, droite = 500 },
             trig = { haut = { 130}, bas = {496 }, gauche = {380 }, droite = {489} } },
    [10] = { coords = "-36,-16", map = "34342150",
             lev  = { haut = 232, bas = 373, gauche = 408, droite = nil },
             trig = { haut = { 202}, bas = { 375}, gauche = { 393}, droite = { } } },
    [11] = { coords = "-40,-15", map = "34475268",
             lev  = { haut = 173, bas = 410, gauche = nil, droite = 387 },
             trig = { haut = { 175}, bas = { 394}, gauche = { }, droite = {376 } } },
    [12] = { coords = "-39,-15", map = "34474244",
             lev  = { haut = 159, bas = 498, gauche = 410, droite = 359 },
             trig = { haut = { 161}, bas = {496 }, gauche = {380 }, droite = {333 } } },
    [13] = { coords = "-38,-15", map = "34473220",
             lev  = { haut = 190, bas = 484, gauche = 396, droite = 262 },
             trig = { haut = {188 }, bas = { 482}, gauche = { 380}, droite = { 292} } },
    [14] = { coords = "-37,-15", map = "34341124",
             lev  = { haut = 187, bas = 440, gauche = 297, droite = 331 },
             trig = { haut = {117 }, bas = {466 }, gauche = { 310}, droite = { 320} } },
    [15] = { coords = "-36,-15", map = "34342148",
             lev  = { haut = 176, bas = 455, gauche = 352, droite = nil },
             trig = { haut = { 174}, bas = {453 }, gauche = { 322}, droite = { } } },
    [16] = { coords = "-40,-14", map = "34475266",
             lev  = { haut = 203, bas = 453, gauche = nil, droite = 318 },
             trig = { haut = {133 }, bas = {482 }, gauche = { }, droite = {333 } } },
    [17] = { coords = "-39,-14", map = "34474242",
             lev  = { haut = 205, bas = 498, gauche = 396, droite = 374 },
             trig = { haut = { 179}, bas = {496 }, gauche = { 366}, droite = {348 } } },
    [18] = { coords = "-38,-14", map = "34473218",
             lev  = { haut = 130, bas = 457, gauche = 354, droite = 388 },
             trig = { haut = {132 }, bas = { 440}, gauche = {339 }, droite = { 376} } },
    [19] = { coords = "-37,-14", map = "34341122",
             lev  = { haut = 276, bas = 498, gauche = 353, droite = 443 },
             trig = { haut = { 206}, bas = {496 }, gauche = {366 }, droite = { 417} } },
    [20] = { coords = "-36,-14", map = "34342146",
             lev  = { haut = 161, bas = 426, gauche = 409, droite = nil },
             trig = { haut = { 163}, bas = {455 }, gauche = { 379}, droite = { } } },
    [21] = { coords = "-40,-13", map = "34475008",
             lev  = { haut = 189, bas = nil, gauche = nil, droite = 457 },
             trig = { haut = {206 }, bas = { }, gauche = { }, droite = {445 } } },
    [22] = { coords = "-39,-13", map = "34473984",
             lev  = { haut = 147, bas = nil, gauche = 438, droite = 470 },
             trig = { haut = { 121}, bas = { }, gauche = { 422}, droite = { 459} } },
    [23] = { coords = "-38,-13", map = "34472960",
             lev  = { haut = 146, bas = nil, gauche = 465, droite = 446 },
             trig = { haut = {148 }, bas = { }, gauche = {449 }, droite = { 516} } },
    [24] = { coords = "-37,-13", map = "34340864",
             lev  = { haut = 130, bas = nil, gauche = 324, droite = 430 },
             trig = { haut = { 132}, bas = { }, gauche = {294 }, droite = { 389} } },
    [25] = { coords = "-36,-13", map = "34341888",
             lev  = { haut = 160, bas = nil, gauche = 438, droite = nil },
             trig = { haut = {162 }, bas = { }, gauche = {408 }, droite = { } } },
}
MINO_SALLE_DE_MAP = {}
for n = 1, 25 do MINO_SALLE_DE_MAP[MINO_SALLES[n].map] = n end
MINO_DIRS = { "haut", "bas", "gauche", "droite" }
MINO_OPP  = { haut = "bas", bas = "haut", gauche = "droite", droite = "gauche" }
MINO_PERP = { haut = { "gauche", "droite" }, bas = { "gauche", "droite" },
              gauche = { "haut", "bas" }, droite = { "haut", "bas" } }
function minoLeviersQuiOuvrent(de, d)
    local vers = minoVoisin(de, d)
    local res = {}
    for _, e in ipairs(MINO_PERP[d]) do
        for _, cible in ipairs({ de, vers }) do
            local r = minoVoisin(cible, MINO_OPP[e])
            if r ~= nil and MINO_SALLES[r].lev[e] ~= nil then
                table.insert(res, { salle = r, levier = e })
            end
        end
    end
    return res
end
function minoVoisin(n, d)
    if n == nil then return nil end
    local r, c = math.floor((n - 1) / 5), (n - 1) % 5
    if d == "haut" then r = r - 1 elseif d == "bas" then r = r + 1
    elseif d == "gauche" then c = c - 1 elseif d == "droite" then c = c + 1 end
    if r < 0 or r > 4 or c < 0 or c > 4 then return nil end
    return r * 5 + c + 1
end
function minoDir(a, b)
    for _, d in ipairs(MINO_DIRS) do if minoVoisin(a, d) == b then return d end end
    return nil
end

MINO_ROUTE = {
    { "A", "go", "droite" },
    { "B", "lev", "bas" }, { "B", "go", "bas" }, { "B", "go", "droite" },
    { "B", "lev", "haut" }, { "A", "go", "droite" },
    { "A", "lev", "bas" }, { "B", "go", "droite" }, { "B", "go", "droite" },
    { "B", "lev", "haut" }, { "B", "lev", "droite" },
    { "A", "go", "droite" }, { "A", "go", "droite" }, { "A", "go", "bas" }, { "A", "go", "bas" },
    { "A", "lev", "gauche" }, { "B", "go", "bas" }, { "B", "go", "bas" },
    { "B", "lev", "droite" }, { "B", "lev", "bas" },
    { "A", "go", "bas" }, { "A", "go", "bas" }, { "A", "go", "gauche" }, { "A", "go", "gauche" },
    { "A", "lev", "haut" }, { "B", "go", "gauche" }, { "B", "go", "gauche" },
    { "B", "lev", "bas" }, { "B", "lev", "gauche" },
    { "A", "go", "gauche" }, { "A", "go", "gauche" }, { "A", "go", "haut" }, { "A", "go", "haut" },
    { "A", "lev", "droite" }, { "B", "go", "haut" },
}
MINO_CENTRE = {
    { "A", "go", "droite" }, { "A", "lev", "bas" }, { "A", "go", "gauche" },
    { "A", "go", "bas" }, { "A", "go", "droite" },
    { "B", "go", "bas" }, { "B", "go", "droite" }, { "B", "go", "droite" },
    { "A", "lev", "bas" }, { "A", "lev", "droite" },
    { "B", "lev", "gauche" },
    { "B", "go", "bas" },
    { "A", "go", "bas" }, { "A", "go", "droite" },
}
MN_GO = MN_GO or {}
MN_PARLE = MN_PARLE or {}
local function mnT()
    local t = sur(function() return os.time() end, 0)
    local n = tonumber(t)
    if n == nil then n = tonumber((string.gsub(tostring(t), ",", "."))) end
    return math.floor(n or 0)
end
local function mnMembres(G)
    if G == "*" then return MN_EQ.tous end
    return MN_EQ[G] or {}
end
local function mnSalleDepart(G, d)
    local n = mnSalleG(G)
    local salles = {}
    for _, a in ipairs(mnMembres(G)) do
        local r = mnSalleDe(a)
        if r ~= nil then salles[r] = true end
    end
    for r1 in pairs(salles) do
        for r2 in pairs(salles) do
            if r1 ~= r2 and minoVoisin(r1, d) == r2 then n = r1 end
        end
    end
    return n
end
local function mnNom(a) return tostring(sur(function() return a.character:name() end, "?")) end
local function mnNbCombats() return tonumber(sur(function() return global:getCountFight() end, -1)) or -1 end
local function mnActeur(G, salle)
    for _, a in ipairs(mnMembres(G)) do
        if mnSalleDe(a) == salle then return a end
    end
    return mnMembres(G)[1]
end
local function mnAutre(G) if G == "A" then return "B" end return "A" end
local function mnSalleDe(a) return MINO_SALLE_DE_MAP[carteDe(a)] end
local function mnCellule() return tonumber(sur(function() return map:currentCell() end, -1)) or -1 end
function mnAutreABesoin(G, ids)
    for _, a in ipairs(mnMembres(mnAutre(G))) do
        for _, mob in ipairs(ids or {}) do
            if tostring(lireMem(mnK("FAIT_" .. tostring(idDe(a)) .. "_" .. tostring(mob))) or "") ~= "1" then return true end
            local g = MINO_RELIQUES and MINO_RELIQUES[mob]
            if g ~= nil then
                local q = tonumber(sur(function() return a.inventory:itemCount(g) end, -1)) or -1
                if q == 0 then return true end
            end
        end
    end
    return false
end
local function mnFait(id, mob) return tostring(lireMem(mnK("FAIT_" .. tostring(id) .. "_" .. tostring(mob))) or "") == "1" end
local function mnTousSur(m)
    for _, a in ipairs(MN_EQ.tous) do if carteDe(a) ~= tostring(m) then return false end end
    return true
end
local function mnEquipe()
    local l = comptesEquipe()
    local n = #l
    local nA = 4
    if n < 8 then nA = math.ceil(n / 2) end
    local eq = { tous = l, A = {}, B = {}, groupeDe = {} }
    for i, a in ipairs(l) do
        local g = (i <= nA) and "A" or "B"
        eq[g][#eq[g] + 1] = a
        eq.groupeDe[idDe(a)] = g
    end
    return eq
end
local function mnSalleG(G)
    local m = mnMembres(G)
    for _, a in ipairs(m) do
        local r = mnSalleDe(a)
        if r ~= nil then return r end
    end
    return nil
end
local function mnK(k) return tostring(MN_PREFIXE or "RS_?_MINO_") .. k end
local function mnGroupeSur(G, m)
    local l = mnMembres(G)
    if #l == 0 then return false end
    for _, a in ipairs(l) do if carteDe(a) ~= m then return false end end
    return true
end

MINO_RELIQUES = { [831] = 8305, [832] = 8306 }
local function mnExecuter(o, cm)
    if o == nil then return end
    if tostring(o.gen) ~= tostring(lireMem(mnK("GEN")) or "") then return end
    local ici = MINO_SALLE_DE_MAP[cm]
    local surPhenix = cm == MINO_PHENIX.map
    local monG = MN_EQ.groupeDe[moiId()]
    local t = o.type
    if t == "retour" then
        if ici == 13 then mnLorkos({ -2, -1 }, o.cle, "centre : quitter le labyrinthe")
        elseif ici ~= nil then mnLorkos({ -1 }, o.cle, "retour a l entree") end
    elseif t == "lev" or t == "phlev" then
        mnTirer(o, cm)
    elseif t == "go" or t == "phgo" then
        if (o.G == "*" or o.G == monG) and ((t == "phgo" and surPhenix) or (ici ~= nil and ici == o.de)) then
            mnPasser(o, cm)
        end
    elseif t == "combat" then
        if ici ~= nil and ici == o.de and (MN_SUIVI == nil or MN_SUIVI.cle ~= o.cle) then
            local ctx, ids = string.match(tostring(o.x), "^(-?%d+):([%d%+]+)$")
            local l = {}
            for id in string.gmatch(tostring(ids or ""), "%d+") do l[#l + 1] = tonumber(id) end
            MN_SUIVI = { cle = o.cle, nb = mnNbCombats(), carte = cm, ctx = tostring(ctx), ids = l }
        end
    elseif t == "boss" then
        if ici == 13 then mnLorkos({ -3, -1, -1 }, o.cle, "centre : montrer les reliques -> boss") end
    end
    mnReleve(o, carte())
end
local function moSuiviCombat(cm)
    local O = MINO_O
    local L = O.lance
    local bm = MINO_SALLES[O.cible.salle].map
    if L ~= nil then
        if mnNbCombats() > L.nb then
            L.fin = L.fin or mnT()
            local tous = true
            for _, id in ipairs(L.presents) do
                if not mnPrefixe(lireMem(mnK("BILAN_" .. id)), L.cle) then tous = false end
            end
            if not tous and mnT() - L.fin <= 10 then return nil end
            O.lance = nil
            local t = {}
            for _, a in ipairs(MN_EQ.tous) do t[#t + 1] = mnNom(a) .. " " .. mnCompteur(idDe(a)) end
            dire("[MINO] bilan : " .. table.concat(t, " ; "))
            if mnToutFait() then moMode("RETOUR", "CENTRE") else moMode("RETOUR", "FOUILLE") end
            return nil
        end
        if enCombat() or mnT() - L.t <= 12 then return nil end
        O.lance = nil
        O.essaisCombat = (O.essaisCombat or 0) + 1
        alerte("[MINO] le combat n a pas demarre (essai " .. O.essaisCombat .. ")")
        if O.essaisCombat >= 3 then moMode("RETOUR", "FOUILLE") return nil end
    end
    if cm ~= bm then moMode("REJOINDRE") return nil end
    if not mnTousSur(bm) and not mnGroupeSur(O.cible.G, bm) then
        O.absentDepuis = O.absentDepuis or mnT()
        if mnT() - O.absentDepuis > 8 then moMode("REJOINDRE") end
        return nil
    end
    O.absentDepuis = nil
    if equipePrete() or not mnTousSur(bm) then return "sortir" end
    return nil
end
local function mnToutFait()
    for _, m in ipairs(MINO_MOBS) do if mnUtile(m.id) then return false end end
    return true
end
local function mnUtile(mob)
    for _, a in ipairs(MN_EQ.tous) do
        local r = mnRelique(a, mob)
        if r == false or (r == nil and not mnFait(idDe(a), mob)) then return true end
    end
    return false
end
local function mnNomsMobs(ids)
    local t = {}
    for _, id in ipairs(ids) do
        for _, m in ipairs(MINO_MOBS) do if m.id == tonumber(id) then t[#t + 1] = m.nom end end
    end
    return table.concat(t, " + ")
end
local function mnTirer(o, cm)
    if o.acteur ~= moiId() or MN_LEV == o.cle then return end
    MN_LEV = o.cle
    local ici = MINO_SALLE_DE_MAP[cm]
    local cell = nil
    if o.type == "phlev" then cell = MINO_PHENIX.levier
    elseif ici ~= nil then cell = MINO_SALLES[ici].lev[o.d] end
    if cell == nil then
        alerte("[MINO] pas de levier " .. tostring(o.d) .. " en salle " .. tostring(ici))
        ecrireMem(mnK("ACK"), o.cle .. "|sans")
        return
    end
    if sur(function() return character:isBusy() end, false) then debloquerOccupe("avant levier") end
    pcall(function() map:door(cell) end)
    if dernierMessageOccupe() then
        debloquerOccupe("levier refuse")
        pcall(function() map:door(cell) end)
    end
    attendre(function() return carte() ~= cm end, 1000, 100)
    ecrireMem(mnK("ACK"), o.cle .. "|ok")
    dire("[MINO] levier " .. (o.type == "phlev" and "du phenix" or tostring(o.d)) .. " (case " .. cell .. ") tire")
end
function MINO_dansLabyrinthe(c)
    c = tostring(c or carte())
    return c == MINO_PHENIX.map or MINO_SALLE_DE_MAP[c] ~= nil
end
local function moFinPlan()
    local O = MINO_O
    if O.mode == "PHENIX" then
        moMode((O.apres == "CENTRE") and "CENTRE" or "FOUILLE")
    elseif O.mode == "FOUILLE" then
        if mnToutFait() then
            dire("[MINO] route finie : toutes les cibles faites -> centre")
            moMode("RETOUR", "CENTRE")
            return
        end
        dire("[MINO] route finie sans cible -> nouvelle fouille")
        moMode("RETOUR", "FOUILLE")
    elseif O.mode == "CENTRE" then
        if mnTousSur(MINO_SALLES[13].map) then moMode("BOSS") return end
        O.centre = (O.centre or 0) + 1
        alerte("[MINO] centre pas atteint (" .. O.centre .. "), nouvel essai")
        moMode("RETOUR", "CENTRE")
    elseif O.mode == "REJOINDRE" then
        O.plan[#O.plan + 1] = { type = "rejoindre", essai = 2 }
    end
end
local function moMode(mode, apres)
    local O = MINO_O
    O.mode, O.plan, O.cur, O.t = mode, {}, nil, mnT()
    if apres ~= nil then O.apres = apres end
    if mode == "RETOUR" then
        ecrireMem(mnK("ACTIF"), "1")
        dire("[MINO] tous a l entree par Lorkos (ensuite : " .. tostring(O.apres) .. ")")
        moPublier({ type = "retour", G = "*" })
    elseif mode == "PHENIX" then
        O.plan = { { type = "phlev" }, { type = "phgo", G = "*", combats = (O.apres ~= "CENTRE") } }
    elseif mode == "FOUILLE" then
        O.tour = (O.tour or 0) + 1
        local t = {}
        for _, a in ipairs(MN_EQ.tous) do t[#t + 1] = mnNom(a) .. " " .. mnCompteur(idDe(a)) end
        dire("[MINO] --- fouille n" .. O.tour .. " --- " .. table.concat(t, " ; "))
        if O.tour > 10 and O.tour % 5 == 1 then alerte("[MINO] deja " .. O.tour .. " fouilles sans finir les cibles") end
        O.plan = mnPlan(MINO_ROUTE, true)
    elseif mode == "CENTRE" then
        dire("[MINO] tout le monde a ses 2 cibles -> route du centre (salle 13)")
        O.plan = mnPlan(MINO_CENTRE, false)
    elseif mode == "REJOINDRE" then
        O.plan = { { type = "rejoindre", essai = 1 } }
    elseif mode == "COMBAT" then
        O.lance, O.essaisCombat, O.absentDepuis = nil, 0, nil
        local c = O.cible
        moPublier({ type = "combat", G = "*", de = c.salle, vers = c.salle, x = c.ctx .. ":" .. table.concat(c.ids, "+") })
    elseif mode == "BOSS" then
        ecrireMem(mnK("ACTIF"), "0")
        dire("[MINO] les " .. #MN_EQ.tous .. " au centre -> Lorkos { -3, -1, -1 } (boss)")
        moPublier({ type = "boss", G = "*", de = 13, vers = 13 })
    end
end
local function mnCompteur(id)
    local t, f = {}, 0
    for _, m in ipairs(MINO_MOBS) do
        local ok = mnFait(id, m.id)
        if ok then f = f + 1 end
        t[#t + 1] = m.nom .. " " .. (ok and "1" or "0") .. "/1"
    end
    return table.concat(t, " | ") .. " - " .. f .. "/" .. #MINO_MOBS
end
local function mnLorkos(reponses, cle, quoi)
    local n = MN_PARLE[cle] or 0
    if n >= 4 then return end
    MN_PARLE[cle] = n + 1
    local avant = carte()
    if sur(function() return character:isBusy() end, false) then debloquerOccupe("avant Lorkos") end
    dire("[MINO] Lorkos " .. quoi .. " (essai " .. (n + 1) .. ")")
    parler(MINO_NPC_LORKOS, reponses, { changeCarte = 6000 })
    if carte() == avant then
        if dernierMessageOccupe() or sur(function() return character:isBusy() end, false) then debloquerOccupe("Lorkos") end
        if n + 1 >= 4 then alerte("[MINO] Lorkos " .. quoi .. " : 4 essais sans changement de carte (" .. avant .. ")") end
    end
end
local function moLancerCombat(cm)
    local O = MINO_O
    if O == nil or O.mode ~= "COMBAT" or O.lance ~= nil then return nil end
    local bm = MINO_SALLES[O.cible.salle].map
    if cm ~= bm or not (mnTousSur(bm) or mnGroupeSur(O.cible.G, bm)) or (mnTousSur(bm) and not equipePrete()) then return nil end
    local g = mnLireGroupes()
    if g == nil then return nil end
    local present = false
    for _, x in ipairs(g) do if x.ctx == O.cible.ctx then present = true end end
    if not present then
        local c = mnChoisirCible(mnCoder(g))
        if c == nil and mnT() - (O.t or 0) < 6 then return nil end
        if c == nil then
            alerte("[MINO] la cible a disparu de la salle " .. O.cible.salle .. " -> nouvelle fouille")
            moMode("RETOUR", "FOUILLE")
            return nil
        end
        O.cible.ctx, O.cible.ids = c.ctx, c.ids
    end
    local presents = {}
    for _, a in ipairs(MN_EQ.tous) do presents[#presents + 1] = idDe(a) end
    local cle = O.cur and O.cur.cle or (O.gen .. "|0")
    MN_FORCE = { f = FORCE_MONSTERS, m = MAX_MONSTERS }
    FORCE_MONSTERS = { tonumber(O.cible.ctx) }
    MAX_MONSTERS = MINO_LIMITE_GROUPE
    LANCEMENT = { carte = bm, t = os.time(), quatre = false }
    O.lance = { t = mnT(), nb = mnNbCombats(), cle = cle, presents = presents }
    MN_SUIVI = { cle = cle, nb = mnNbCombats(), carte = bm, ctx = O.cible.ctx, ids = O.cible.ids }
    dire("[MINO] les " .. #presents .. " en salle " .. O.cible.salle .. " -> combat contre " .. mnNomsMobs(O.cible.ids))
    return { { map = bm, fight = true } }
end
local function mnRelique(a, mob)
    local g = MINO_RELIQUES[mob]
    if g == nil then return true end
    local q = tonumber(sur(function() return a.inventory:itemCount(g) end, -1)) or -1
    if q < 0 then return nil end
    return q > 0
end
function detourMinotoror()
    local cm = carte()
    MN_PREFIXE = cleEquipe() .. "MINO_"
    if MN_FORCE ~= nil and not enCombat() then
        FORCE_MONSTERS, MAX_MONSTERS = MN_FORCE.f or {}, MN_FORCE.m
        MN_FORCE = nil
    end
    local dehors = cm == MINO_MAP_DEHORS and tostring(lireMem(mnK("ACTIF")) or "") == "1"
    if not MINO_dansLabyrinthe(cm) and not dehors then
        if MN_SUIVI ~= nil then mnBilan() end
        return nil
    end
    if enCombat() then return nil end
    if BLOCAGE then BLOCAGE.n, BLOCAGE.essais = 0, 0 end
    MN_EQ = mnEquipe()
    mnBilan()
    if dehors then
        return { { map = cm, custom = function()
            dire("[MINO] dehors, labyrinthe en cours -> Lorkos { -1, -1 }")
            parler(MINO_NPC_LORKOS, { -1, -1 }, { changeCarte = 6000 })
            if carte() == cm and dernierMessageOccupe() then debloquerOccupe("Lorkos dehors") end
        end } }
    end
    local chef = estLeader()
    if chef then
        local a = moLancerCombat(cm)
        if a ~= nil then return a end
    end
    return { { map = cm, enveloppe = true, custom = function() mnBoucle(cm, chef) end } }
end
local function mnLireOrdre()
    local s = tostring(lireMem(mnK("ORDRE")) or "")
    local f = {}
    for x in string.gmatch(s, "[^|]+") do f[#f + 1] = x end
    if #f < 9 then return nil end
    return { gen = f[1], seq = tonumber(f[2]), type = f[3], G = f[4], d = f[5], de = tonumber(f[6]),
             vers = tonumber(f[7]), acteur = f[8], x = f[9], cle = f[1] .. "|" .. f[2] }
end
local function mnItem(src, extra)
    local r = { type = src.type, G = src.G, d = src.d, aide = src.aide, combats = src.combats,
                rejoindre = src.rejoindre, aideFaite = src.aideFaite, reessai = src.reessai }
    for k, v in pairs(extra or {}) do r[k] = v end
    return r
end
local function moLancer(it)
    local O = MINO_O
    local t = it.type
    if t == "rejoindre" then moRejoindre(it) return end
    if t == "lev" then
        local de = mnSalleG(it.G)
        local cell = (de ~= nil) and MINO_SALLES[de].lev[it.d] or nil
        if cell == nil then
            dire("[MINO] groupe " .. it.G .. " : pas de levier " .. tostring(it.d) .. " en salle " .. tostring(de) .. " (ignore)")
            return
        end
        it.de, it.vers = de, de
        it.acteur = idDe(mnActeur(it.G, de))
        moPublier(it)
        return
    end
    if t == "phlev" then
        it.G, it.de, it.vers, it.acteur = "A", 0, 0, idDe(MN_EQ.A[1])
        moPublier(it)
        return
    end
    if t == "phgo" then
        it.G, it.de, it.vers = "*", 0, 1
        moPublier(it)
        return
    end
    if t == "go" then
        local de = mnSalleDepart(it.G, it.d)
        local vers = (de ~= nil) and minoVoisin(de, it.d) or nil
        it.de, it.vers = de, vers
        if vers == nil then moEchecGo(it, true) return end
        moPublier(it)
    end
end
local function mnCoder(groupes)
    local t = {}
    for _, g in ipairs(groupes) do t[#t + 1] = g.ctx .. ":" .. g.taille .. ":" .. table.concat(g.ids, "+") end
    if #t == 0 then return "aucun" end
    return table.concat(t, ";")
end
local function moSuivre(cur)
    local O = MINO_O
    local now = mnT()
    if cur.type == "retour" then
        local manquent = {}
        for _, a in ipairs(MN_EQ.tous) do
            if carteDe(a) ~= MINO_PHENIX.map then manquent[#manquent + 1] = mnNom(a) .. "@" .. carteDe(a) end
        end
        if #manquent == 0 then moMode("PHENIX") return end
        if now - cur.t >= 30 then
            alerte("[MINO] entree du labyrinthe : j attends encore " .. table.concat(manquent, ", "))
            moPublier({ type = "retour", G = "*" })
        end
        return
    end
    if cur.type == "lev" or cur.type == "phlev" then
        local ok = mnPrefixe(lireMem(mnK("ACK")), cur.cle)
        if ok then O.cur = nil return end
        if now - cur.t > 4 then
            alerte("[MINO] levier " .. tostring(cur.d) .. " du groupe " .. tostring(cur.G) .. " : pas d accuse, on continue")
            O.cur = nil
        end
        return
    end
    if cur.type == "go" or cur.type == "phgo" then
        local versMap = MINO_SALLES[cur.vers].map
        local restants = {}
        for _, a in ipairs(mnMembres(cur.G)) do if carteDe(a) ~= versMap then restants[#restants + 1] = a end end
        if #restants == 0 then
            cur.arrive = cur.arrive or now
            if cur.combats then
                local ok, vu = mnPrefixe(lireMem(mnK("VU_" .. cur.vers)), cur.cle)
                if not ok and now - cur.arrive < 1.5 then return end
                local c = ok and mnChoisirCible(vu) or nil
                if c ~= nil then
                    O.cible = { salle = cur.vers, G = (cur.G == "*") and "A" or cur.G, ctx = c.ctx, ids = c.ids }
                    dire("[MINO] groupe " .. O.cible.G .. " trouve " .. mnNomsMobs(c.ids) .. " en salle " .. cur.vers .. " !")
                    if carte() == MINO_SALLES[cur.vers].map and not mnAutreABesoin(O.cible.G, c.ids) then moMode("COMBAT") else moMode("REJOINDRE") end
                    return
                end
                if not ok then alerte("[MINO] pas de releve des monstres en salle " .. cur.vers) end
            end
            dire("[MINO] groupe " .. tostring(cur.G) .. " : salle " .. tostring(cur.de) .. " -> " .. cur.vers)
            if cur.type == "phgo" then O.phEssais = 0 end
            O.cur = nil
            return
        end
        local echec = now - cur.t > 8
        if not echec then
            echec = true
            for _, a in ipairs(restants) do
                local v = tostring(lireMem(mnK("GO_" .. idDe(a))) or "")
                local c, n = string.match(v, "^(%d+|%d+)|(%d+)$")
                if not (c == cur.cle and (tonumber(n) or 0) >= 2) then echec = false end
            end
        end
        if not echec then return end
        if cur.type == "phgo" then
            O.phEssais = (O.phEssais or 0) + 1
            alerte("[MINO] salle du phenix : " .. #restants .. " pas passes -> levier 429 de nouveau (essai " .. O.phEssais .. ")")
            O.cur = nil
            table.insert(O.plan, 1, { type = "phgo", G = "*", combats = cur.combats })
            table.insert(O.plan, 1, { type = "phlev" })
            return
        end
        moEchecGo(cur)
    end
end
local function moTick(cm)
    local O = MINO_O
    if O == nil then
        local gen = (tonumber(lireMem(mnK("GEN"))) or 0) + 1
        ecrireMem(mnK("GEN"), tostring(gen))
        ecrireMem(mnK("ORDRE"), "")
        MINO_O = { gen = tostring(gen), seq = 0, tour = 0, centre = 0, phEssais = 0 }
        dire("[MINO] === LABYRINTHE DU MINOTOROR === groupe A : " .. #MN_EQ.A .. " (tete " .. mnNom(MN_EQ.A[1])
            .. "), groupe B : " .. #MN_EQ.B .. " (tete " .. (MN_EQ.B[1] and mnNom(MN_EQ.B[1]) or "-") .. ")")
        moMode("RETOUR", mnToutFait() and "CENTRE" or "FOUILLE")
        return nil
    end
    if cm == MINO_PHENIX.map and O.mode ~= "RETOUR" and O.mode ~= "PHENIX" then
        alerte("[MINO] je suis a l entree en mode " .. tostring(O.mode) .. " -> tout le monde revient au debut")
        moMode("RETOUR", O.apres or "FOUILLE")
        return nil
    end
    if O.mode == "COMBAT" then return moSuiviCombat(cm) end
    if O.mode == "BOSS" then return nil end
    if O.cur == nil then
        if #O.plan == 0 then moFinPlan() return nil end
        moLancer(table.remove(O.plan, 1))
        return nil
    end
    moSuivre(O.cur)
    return nil
end
local function mnChoisirCible(s)
    if s == nil or s == "aucun" then return nil end
    local best = nil
    for part in string.gmatch(s, "[^;]+") do
        local ctx, taille, ids = string.match(part, "^(-?%d+):(%d+):([%d%+]+)$")
        if ctx ~= nil and (tonumber(taille) or 99) <= MINO_LIMITE_GROUPE then
            local utiles = {}
            for id in string.gmatch(ids, "%d+") do
                if mnUtile(tonumber(id)) then utiles[#utiles + 1] = tonumber(id) end
            end
            if #utiles > 0 and (best == nil or #utiles > #best.ids) then best = { ctx = ctx, ids = utiles } end
        end
    end
    return best
end
local function mnLireGroupes()
    local ok, groupes = pcall(function() return map:monsterGroups() end)
    if not ok or groupes == nil then return nil end
    local res = {}
    pcall(function()
        for _, g in ipairs(groupes) do
            local ids, vus, n = {}, {}, 0
            for _, mob in ipairs(g.monsters or {}) do
                n = n + 1
                local id = tonumber(mob.id)
                for _, m in ipairs(MINO_MOBS) do
                    if id == m.id and not vus[id] then vus[id] = true ids[#ids + 1] = id end
                end
            end
            if #ids > 0 then res[#res + 1] = { ctx = tostring(g.contextualId), taille = n, ids = ids } end
        end
    end)
    return res
end
local function moPublier(it)
    local O = MINO_O
    O.seq = O.seq + 1
    it.seq, it.cle, it.t, it.arrive = O.seq, O.gen .. "|" .. O.seq, mnT(), nil
    ecrireMem(mnK("ORDRE"), table.concat({ O.gen, tostring(O.seq), it.type, it.G or "*", it.d or "-",
        tostring(it.de or 0), tostring(it.vers or 0), it.acteur or "-", it.x or "-" }, "|"))
    O.cur = it
end
local function mnBoucle(cm, chef)
    local k = 0
    attendre(function()
        k = k + 1
        if carte() ~= cm or enCombat() then return true end
        if chef then
            if moTick(cm) == "sortir" then return true end
        end
        mnExecuter(mnLireOrdre(), cm)
        if carte() ~= cm or enCombat() then return true end
        if not chef and k % 10 == 1 then autoPretAJour() end
        return false
    end, 3600000, 100)
    if carte() == cm and not enCombat() then pcall(function() global:restartScript(false) end) end
end
local function moRejoindre(it)
    local O = MINO_O
    local q = O.cible.G
    local mover = mnAutre(q)
    local b = O.cible.salle
    local essai = it.essai or 1
    if mnTousSur(MINO_SALLES[b].map) then
        dire("[MINO] les " .. #MN_EQ.tous .. " reunis en salle " .. b .. " -> combat")
        moMode("COMBAT")
        return
    end
    if essai > 4 then
        alerte("[MINO] le groupe " .. mover .. " n a pas pu rejoindre la salle " .. b .. " -> retour au debut du labyrinthe")
        moMode("RETOUR", "FOUILLE")
        return
    end
    local function marque(cas, alt, e) O.plan[#O.plan + 1] = { type = "rejoindre", essai = e or essai, cas = cas, alt = alt } end
    local a = mnSalleG(mover)
    if a == nil then marque(nil, 0, essai + 1) return end
    if a ~= b then
        local d = minoDir(a, b)
        if d ~= nil then
            local alt = 0
            if it.cas == "adj" then alt = it.alt or 0 end
            if alt == 0 then
                O.plan[#O.plan + 1] = { type = "go", G = mover, d = d, rejoindre = true }
                marque("adj", 1)
                return
            end
            if alt <= 2 then
                local p = MINO_PERP[d][alt]
                local ap, bp = minoVoisin(a, p), minoVoisin(b, p)
                if ap and bp and MINO_SALLES[b].lev[MINO_OPP[d]] and MINO_SALLES[b].lev[p] and MINO_SALLES[a].lev[d] then
                    dire("[MINO] groupe " .. mover .. " rejoint " .. q .. " : " .. a .. " -> " .. ap .. " -> " .. bp .. " -> " .. b)
                    local l = O.plan
                    l[#l + 1] = { type = "lev", G = q, d = MINO_OPP[d] }
                    l[#l + 1] = { type = "lev", G = q, d = p }
                    l[#l + 1] = { type = "lev", G = mover, d = d }
                    l[#l + 1] = { type = "go", G = mover, d = p, aide = true, rejoindre = true }
                    l[#l + 1] = { type = "go", G = mover, d = d, aide = true, rejoindre = true }
                    l[#l + 1] = { type = "go", G = mover, d = MINO_OPP[p], aide = true, rejoindre = true }
                end
                marque("adj", alt + 1)
                return
            end
            dire("[MINO] rejoindre : essai " .. essai .. " rate")
            marque(nil, 0, essai + 1)
            return
        end
        local k0 = 1
        if it.cas == "diag" then k0 = it.alt or 1 end
        for k = k0, #MINO_DIRS do
            local db = MINO_DIRS[k]
            local c = minoVoisin(b, db)
            if c ~= nil and minoDir(a, c) ~= nil then
                dire("[MINO] groupe " .. mover .. " passe par la salle " .. c)
                if MINO_SALLES[b].lev[db] then O.plan[#O.plan + 1] = { type = "lev", G = q, d = db } end
                O.plan[#O.plan + 1] = { type = "go", G = mover, d = minoDir(a, c), aide = true, rejoindre = true }
                marque("diag", k + 1)
                return
            end
        end
        if k0 == 1 then alerte("[MINO] groupe " .. mover .. " trop loin (salle " .. a .. ", cible salle " .. b .. ")") end
        marque(nil, 0, essai + 1)
        return
    end
    for _, G in ipairs({ mover, q }) do
        for _, m in ipairs(mnMembres(G)) do
            local r = mnSalleDe(m)
            if r ~= b then
                local d = (r ~= nil) and minoDir(r, b) or nil
                if d ~= nil then
                    dire("[MINO] " .. mnNom(m) .. " reste en salle " .. r .. " -> on le ramene en " .. b)
                    O.plan[#O.plan + 1] = { type = "go", G = G, d = d, aide = true, rejoindre = true }
                    marque(nil, 0, essai + 1)
                    return
                end
                alerte("[MINO] " .. mnNom(m) .. " est trop loin (" .. carteDe(m) .. ")")
            end
        end
    end
    marque(nil, 0, essai + 1)
end
local function mnReleve(o, cm)
    local ici = MINO_SALLE_DE_MAP[cm]
    if ici == nil or enCombat() or MN_SCAN == o.cle .. "@" .. cm then return end
    local g = mnLireGroupes()
    if g == nil then return end
    MN_SCAN = o.cle .. "@" .. cm
    ecrireMem(mnK("VU_" .. ici), o.cle .. "|" .. mnCoder(g))
end
local function mnPasDeCote()
    local c = mnCellule()
    if c < 0 then return end
    for _, d in ipairs({ 14, -14, 15, -15, 1, -1, 28, -28 }) do
        pcall(function() map:moveToCell(c + d) end)
        if attendre(function() return mnCellule() ~= c end, 1500, 100) then return end
    end
end
local function mnPasser(o, cm)
    local n = MN_GO[o.cle] or 0
    if n >= 4 then return end
    local cells
    if o.type == "phgo" then cells = MINO_PHENIX.trig
    else cells = (MINO_SALLES[o.de] and MINO_SALLES[o.de].trig[o.d]) or {} end
    if #cells == 0 then
        MN_GO[o.cle] = 99
        ecrireMem(mnK("GO_" .. moiId()), o.cle .. "|9")
        alerte("[MINO] pas de dalle " .. tostring(o.d) .. " en salle " .. tostring(o.de))
        return
    end
    local cell = cells[(n % #cells) + 1]
    MN_GO[o.cle] = n + 1
    if mnCellule() == cell then mnPasDeCote() end
    if sur(function() return character:isBusy() end, false) then debloquerOccupe("avant passage") end
    pcall(function() map:moveToCell(cell) end)
    attendre(function() return carte() ~= cm or mnCellule() == cell end, 7000, 100)
    if carte() == cm then attendre(function() return carte() ~= cm end, 800, 100) end
    if carte() == cm then
        ecrireMem(mnK("GO_" .. moiId()), o.cle .. "|" .. (n + 1))
        if dernierMessageOccupe() then debloquerOccupe("passage refuse") end
    end
end
local function moEchecGo(cur, definitif)
    local O = MINO_O
    O.cur = nil
    if not definitif and cur.aide and not cur.aideFaite then
        local autre = mnAutre(cur.G)
        local ici = mnSalleG(autre)
        if cur.de ~= nil and ici ~= nil then
            for _, o in ipairs(minoLeviersQuiOuvrent(cur.de, cur.d)) do
                if o.salle == ici then
                    dire("[MINO] grille fermee : le groupe " .. autre .. " (salle " .. ici .. ") tire son levier " .. o.levier
                        .. " pour debloquer le groupe " .. cur.G)
                    table.insert(O.plan, 1, mnItem(cur, { aideFaite = true }))
                    table.insert(O.plan, 1, { type = "lev", G = autre, d = o.levier })
                    return
                end
            end
        end
    end
    if not definitif and cur.aide and not cur.reessai then
        table.insert(O.plan, 1, mnItem(cur, { aideFaite = false, reessai = true }))
        return
    end
    alerte("[MINO] bloque : groupe " .. tostring(cur.G) .. " " .. tostring(cur.d) .. " depuis la salle " .. tostring(cur.de))
    if cur.rejoindre then
        while #O.plan > 0 and O.plan[1].type ~= "rejoindre" do table.remove(O.plan, 1) end
        return
    end
    if O.mode == "CENTRE" then
        O.centre = (O.centre or 0) + 1
        if O.centre >= 5 then alerte("[MINO] centre pas atteint apres " .. O.centre .. " essais") end
        moMode("RETOUR", "CENTRE")
    else
        moMode("RETOUR", "FOUILLE")
    end
end
local function mnPrefixe(v, cle)
    v = tostring(v or "")
    return string.sub(v, 1, #cle + 1) == cle .. "|", string.sub(v, #cle + 2)
end
local function mnBilan()
    local s = MN_SUIVI
    if s == nil or enCombat() then return end
    if mnNbCombats() > s.nb then
        local gagne = carte() == s.carte
        if gagne then
            for _, id in ipairs(s.ids) do ecrireMem(mnK("FAIT_" .. moiId() .. "_" .. id), "1") end
            dire("[MINO] combat gagne (" .. mnNomsMobs(s.ids) .. ") -> " .. moiNom() .. " : " .. mnCompteur(moiId()))
        else
            alerte("[MINO] combat contre " .. mnNomsMobs(s.ids) .. " NON credite pour " .. moiNom() .. " (carte " .. carte() .. ")")
        end
        ecrireMem(mnK("BILAN_" .. moiId()), s.cle .. "|" .. (gagne and "1" or "0"))
        MN_SUIVI = nil
        return
    end
    local o = mnLireOrdre()
    if o == nil or o.cle ~= s.cle then MN_SUIVI = nil end
end
local function mnPlan(route, combats)
    local p = {}
    for _, e in ipairs(route) do
        if e[2] == "lev" then p[#p + 1] = { type = "lev", G = e[1], d = e[3] }
        else p[#p + 1] = { type = "go", G = e[1], d = e[3], aide = true, combats = combats } end
    end
    return p
end

local ETAPE = {
    cle    = "donjons_minotoror",
    nom    = "Kal Vissi puis Minotoror",
    succes = {},
    acces  = "pied",
    detour = detourMinotoror,
}
ETAPE.quete = trajetVersKal(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(164364304)" },
    { map = "-20,-20", path = "bottom" }, { map = "-20,-19", path = "bottom" }, { map = "-20,-18", path = "bottom" },
    { map = "-20,-17", path = "bottom" }, { map = "-20,-16", path = "bottom" }, { map = "-20,-15", path = "bottom" },
    { map = "-20,-14", path = "bottom" },
    { map = "-20,-13", path = "left" }, { map = "-21,-13", path = "left" }, { map = "-22,-13", path = "left" },
    { map = "-23,-13", path = "left" }, { map = "-24,-13", path = "left" }, { map = "-25,-13", path = "left" },
    { map = "-26,-13", path = "bottom" }, { map = "-26,-12", path = "bottom" },
    { map = "-26,-11", path = "left" }, { map = "-27,-11", path = "left" }, { map = "-28,-11", path = "left" },
    { map = "-29,-11", path = "top" },
    { map = "-29,-12", path = "left" },
    { map = "-30,-12", path = "bottom" },
    { map = "-30,-11", path = "left" }, { map = "-31,-11", path = "left" }, { map = "-32,-11", path = "left" },
    { map = "-33,-11", path = "bottom" },
    { map = "-33,-10", path = "left" }, { map = "-34,-10", path = "left" }, { map = "-35,-10", path = "left" },
    { map = "167381514", custom = function() parler(770, { -1, -1, -1 }, { changeCarte = 8000 }) end },
    { map = "153360", path = "top" },
    { map = "-43,-17", path = "top" },
    { map = "-43,-18", path = "right" },
    { map = "-42,-18", path = "bottom" },
}
ETAPE.entree = {
    carte = MINO_MAP_DEHORS,
    pnj = MINO_NPC_LORKOS,
    reponses = { -1, -1 },
    custom = function()
        if estLeader() then
            MINO_O = nil
            ecrireMem(cleEquipe() .. "MINO_ORDRE", "")
        end
        parler(MINO_NPC_LORKOS, { -1, -1 }, { changeCarte = 6000 })
    end,
}
ETAPE.donjon = {
    { map = MINO_MAP_BOSS, fight = true },
    { map = MINO_MAP_APRES_BOSS, barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(MINO_NPC_LORKOS, { -3, -1 }, { changeCarte = 5000 })
    end },
    { map = MINO_MAP_SORTIE, path = tostring(MINO_TRIG_SORTIE) },
}
ETAPES[#ETAPES + 1] = ETAPE

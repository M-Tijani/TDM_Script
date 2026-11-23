charger("etapes\\lib_juge.lua", true)
local ETAPE = {
    cle    = "juge_dragon_cochon",
    nom    = "Chris de Naire puis Antre du Dragon Cochon (labyrinthe)",
    succes = { 22 },
    acces  = "pied",
}
ETAPE.quete = trajetVersChris(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(88212481)" },
    { map = "-1,24", path = "right" },
    { map = "0,24", path = "bottom" }, { map = "0,25", path = "bottom" }, { map = "0,26", path = "bottom" },
    { map = "0,27", path = "bottom" }, { map = "0,28", path = "bottom" }, { map = "0,29", path = "bottom" },
    { map = "0,30", path = "right" },
    { map = "1,30", path = "bottom" }, { map = "1,31", path = "bottom" }, { map = "1,32", path = "left" },
    { map = "0,32", path = "left" }, { map = "-1,32", path = "bottom" },
    { map = "72618499", door = "231" },
    { map = "72222720", door = "260" },
    { map = "72221696" },
}
ETAPE.entree = {
    carte = "72221696",
    pnj = 784,
    reponses = { -2, -1 },
    custom = function()
        parler(784, { -2, -1 }, { changeCarte = 5000 })
    end,
}
local CENTRE, DALLES = "72092676", "72089600"
local LABY_BASE = 72090624
local SORTIE = { H = 157, D = 164, B = 416, G = 407 }
local DIRS = { "H", "D", "B", "G" }
local OPPOSE = { H = "B", B = "H", G = "D", D = "G" }
local DELTA = { H = { 0, -1 }, B = { 0, 1 }, G = { -1, 0 }, D = { 1, 0 } }
local DALLES_CELLULES = { 385, 372, 358, 345, 331 }
local DALLE_SALLE = { [385] = "72090632", [372] = "72091656", [358] = "72092680", [345] = "72093704", [331] = "72094728" }
local function dansLabyrinthe()
    local id = tonumber(carte()) or 0
    local t = tostring(id)
    return t ~= CENTRE and t ~= DALLES and id >= 72089000 and id <= 72096000
end
local function distTore(x, y)
    local dx, dy = math.abs(x - 4), math.abs(y - 35)
    return math.min(dx, 5 - dx) + math.min(dy, 5 - dy)
end
local function voisine(x, y, s)
    local nx, ny = x + DELTA[s][1], y + DELTA[s][2]
    if nx < 2 then nx = 6 elseif nx > 6 then nx = 2 end
    if ny < 33 then ny = 37 elseif ny > 37 then ny = 33 end
    return nx, ny
end
local function ici_xy() local c = carte() local x, y = labyXY(c) return c, x, y end
local function lzT() return lvT() end
local function lzS() return lvS() end
local function signalLaby() ecrireMem("RS_" .. moiId() .. "_LABY", tostring(lzS())) end
local function celluleIci() return tonumber(sur(function() return map:currentCell() end, -1)) or -1 end
local function etatS(k) return tostring(lireEtat(k) or "") end
local function salleXY(x, y) return tostring(LABY_BASE + (x - 2) * 1024 + (y - 33) * 2) end
local function labyXY(id)
    id = tonumber(id)
    if id == nil then return nil end
    local d = id - LABY_BASE
    if d < 0 then return nil end
    local x, r = 2 + math.floor(d / 1024), d % 1024
    if r % 2 ~= 0 then return nil end
    local y = 33 + math.floor(r / 2)
    if x < 2 or x > 6 or y < 33 or y > 37 then return nil end
    return x, y
end
local function majEtat(t)
    local tb = lireTableEtat(moiId())
    if next(tb) == nil and ETAT ~= nil then for k, v in pairs(ETAT) do tb[k] = v end end
    for k, v in pairs(t) do tb[k] = tostring(v) end
    ecrireTableEtat(moiId(), tb)
    ETAT, ETAT_LU_A = tb, os.time()
end

local DERNIER_DIRE_LABY = 0
local function voisinsCellule(c)
    local v = { c - 14, c + 14, c - 28, c + 28 }
    if c % 14 ~= 0 then v[#v + 1] = c - 1 end
    if c % 14 ~= 13 then v[#v + 1] = c + 1 end
    if math.floor(c / 14) % 2 == 0 then v[#v + 1] = c - 15 v[#v + 1] = c + 13
    else v[#v + 1] = c - 13 v[#v + 1] = c + 15 end
    return v
end
local function prendreDalle(d, suit, pourquoi)
    local ordre = { d }
    for _, x in ipairs(DALLES_CELLULES) do if x ~= d then ordre[#ordre + 1] = x end end
    for _, dd in ipairs(ordre) do
        majEtat({ LABY_T = DALLES .. "|DALLE|" .. dd .. "|" .. celluleIci() .. "|" .. lzT(), LABY_PHASE = suit and "SUIT" or "EXPLORE",
            LABY_IDX = 0, LABY_TRACE = dd .. "||", LABY_VUES = "", LABY_PRIS = "", LABY_ETATS = "", LABY_SALLE = "", LABY_DIR = "", LABY_TP = "", LABY_ECL = lzS() })
        if suit then ecrireMem("RS_" .. moiId() .. "_LABYSUIT", "0|" .. lzS()) end
        signalLaby()
        dire("labyrinthe : dalle " .. dd .. " (" .. tostring(pourquoi) .. ")")
        pcall(function() map:moveToCell(dd) end)
        if attendre(function() return carte() ~= DALLES end, 3000, 100) then return end
        if suit then echecChemin("dalle " .. dd .. " sans effet") end
        suit = false
        pourquoi = "dalle precedente sans effet"
    end
    reconnexionLaby(DALLES, "aucune dalle ne teleporte")
end
local function essayerSortie(ici, x, y, dirIn, s)
    majEtat({ LABY_T = ici .. "|" .. dirIn .. "|" .. s .. "|" .. celluleIci() .. "|" .. lzT() })
    signalLaby()
    local r = nil
    pcall(function() r = map:moveToCell(SORTIE[s]) end)
    if r == false then
        noterArete(x, y, dirIn, s, false)
        return "sanschemin"
    end
    local fin, c0, tc0 = lzT() + 12000, celluleIci(), lzT()
    while lzT() < fin do
        if carte() ~= ici then return "change" end
        local c = celluleIci()
        if c ~= c0 then c0, tc0 = c, lzT()
        elseif lzT() - tc0 >= 1500 then break end
        attendre(function() return carte() ~= ici end, 300, 100)
    end
    if carte() ~= ici then return "change" end
    noterArete(x, y, dirIn, s, false)
    return "echec"
end
local function fichierGraphe() return tostring(DOSSIER) .. "\\etat\\laby-graphe.txt" end
local function positionSurChemin(ch, ici, dirIn)
    for k = 1, #ch.s do
        local dIn = (k == 1) and "DALLE" or ch.s[k - 1]
        if ch.r[k] == ici and dirIn == dIn then return k end
    end
    return nil
end
local function protege(f, nom)
    return function()
        local ok, err = pcall(f)
        if not ok then
            alerte("labyrinthe (" .. nom .. ") : erreur " .. tostring(err))
            attendre(function() return false end, 10000, 500)
        end
    end
end
local function fwouedVersDalles(ici, raison, volontaire)
    if volontaire then
        local l = {}
        for t in etatS("LABY_FWV"):gmatch("%d+") do if lzS() - tonumber(t) < 900 then l[#l + 1] = t end end
        l[#l + 1] = tostring(lzS())
        majEtat({ LABY_FWV = table.concat(l, ",") })
    else
        local fc, fts = etatS("LABY_FW"):match("^(%d+)|(%d+)$")
        if fc == ici and lzS() - (tonumber(fts) or 0) < 180 then return false end
    end
    majEtat({ LABY_TP = ici .. "|" .. lzS(), LABY_FW = ici .. "|" .. lzS(), LABY_T = "", LABY_TRACE = "X" })
    ecrireMem("RS_" .. moiId() .. "_LABY_TP", tostring(lzS()))
    dire("labyrinthe : " .. tostring(raison) .. " -> Fwoued, retour a la salle des dalles (depuis " .. ici .. ")")
    parler(784, { -1 }, { changeCarte = 8000 })
    if carte() == ici and not enCombat() then reconnexionLaby(ici, "Fwoued sans teleportation") end
    return true
end
local function cellXY(c) local r = math.floor(c / 14) return (c % 14) * 2 + (r % 2), r end
local function composante()
    local W = sur(function() return map:getWalkableCells(false) end, nil)
    if W == nil then W = sur(function() return map:getWalkableCells() end, nil) end
    if W == nil then return nil end
    local ok, n = {}, 0
    pcall(function() for _, c in ipairs(W) do local k = tonumber(c) if k then ok[k] = true n = n + 1 end end end)
    if n == 0 then pcall(function() for _, c in pairs(W) do local k = tonumber(c) if k then ok[k] = true n = n + 1 end end end) end
    if n == 0 then return nil end
    local c0 = celluleIci()
    if c0 < 0 then return nil end
    local comp, file, i, nc = { [c0] = true }, { c0 }, 1, 1
    while file[i] ~= nil do
        for _, v in ipairs(voisinsCellule(file[i])) do
            if v >= 0 and v < 560 and ok[v] and not comp[v] then comp[v] = true nc = nc + 1 file[#file + 1] = v end
        end
        i = i + 1
    end
    local joignable = {}
    for s, cs in pairs(SORTIE) do
        if comp[cs] then joignable[s] = true
        else for _, v in ipairs(voisinsCellule(cs)) do if comp[v] then joignable[s] = true end end end
    end
    return { comp = comp, nc = nc, n = n, joignable = joignable }
end
local function attendreStabilite(ici)
    local moi = moiId()
    ecrireMem("RS_" .. moi .. "_LABYPOS", ici .. "|" .. lzT())
    local attente = 0
    pcall(function()
        for _, a in ipairs(comptesEquipe()) do
            local id = tostring(idDe(a))
            if id ~= moi then
                local c, t = tostring(lireMem("RS_" .. id .. "_LABYPOS") or ""):match("^(%d+)|(%d+)$")
                if c == ici then
                    local reste = 3000 - (lzT() - (tonumber(t) or 0))
                    if reste > attente then attente = reste end
                end
            end
        end
    end)
    if attente > 0 then attendre(function() return false end, math.min(attente, 3000), 100) end
end
local function lireArete(x, y, dirIn, s)
    local v = tostring(lireMem(cleArete(x, y, dirIn, s)) or "")
    local e, arr, nok, nko, ts = v:match("^(%u+)|([^|]*)|(%d*)|(%d*)|(%d*)$")
    if e == nil then return nil end
    return { etat = e, arr = arr, nok = tonumber(nok) or 0, nko = tonumber(nko) or 0, ts = tonumber(ts) or 0 }
end
local function entrerParDalle()
    chargerGraphe()
    if carte() ~= DALLES then return end
    local tpc = etatS("LABY_TP"):match("^(%d+)|")
    if tpc ~= nil then majEtat({ LABY_TP = "" }) end
    local att0 = tonumber(etatS("LABY_ATT"))
    if att0 == nil or lzS() - att0 > 1800 then att0 = lzS() majEtat({ LABY_ATT = att0 }) end
    local rang = monRang()
    local debut = lzS()
    while lzS() - debut < 100 do
        local ch = cheminPublie()
        if ch ~= nil then
            if monTour(att0) then return prendreDalle(ch.dalle, true, "chemin publie, " .. #ch.s .. " salles") end
            signeDeVie("file indienne : j attends que le precedent ait 2 salles d avance (rang " .. rang .. ")")
        elseif rang <= 3 or lzS() - att0 >= 480 + math.max(0, rang - 4) * 20
            or lzS() - (tonumber(etatS("LABY_ECL")) or 0) < 1800 then
            local d, pq = choisirDalle(rang)
            return prendreDalle(d, false, pq)
        else
            signeDeVie("aux dalles, rang " .. rang .. " : j attends le chemin des eclaireurs (" .. (lzS() - att0) .. " s / 480 s)")
        end
        attendre(function() return false end, 1000, 100)
    end
end
local function pasVersSortie(cp, s)
    local ex, ey = cellXY(SORTIE[s])
    local best, bd = nil, 999
    for c, _ in pairs(cp.comp) do
        local cx, cy = cellXY(c)
        local d = math.abs(cx - ex) + math.abs(cy - ey)
        if d < bd and c ~= SORTIE[s] then best, bd = c, d end
    end
    if best == nil or best == celluleIci() then return false end
    local c0 = celluleIci()
    pcall(function() map:moveToCell(best) end)
    attendre(function() return celluleIci() ~= c0 end, 2500, 100)
    dire("labyrinthe : pas vers la sortie " .. s .. " (case " .. best .. ")")
    return true
end
local function choisirDalle(rang)
    local best, bk = nil, 99
    for _, d in ipairs(DALLES_CELLULES) do
        local k = distConnue(DALLE_SALLE[d], "DALLE")
        if k ~= nil and k < bk then best, bk = d, k end
    end
    if best ~= nil then return best, "plus court chemin connu (" .. bk .. " salles)" end
    local n = (tonumber(lireEtat("LABY_DALLE_N")) or 0) + 1
    ecrireEtat("LABY_DALLE_N", n)
    for k = 0, #DALLES_CELLULES - 1 do
        local d = DALLES_CELLULES[((rang - 1) + n + k) % #DALLES_CELLULES + 1]
        local cleR = "LABYDR_" .. chefId() .. "_" .. d
        if lzS() - (tonumber(lireMem("LABYDM_" .. d)) or 0) >= 900 and lzS() - (tonumber(lireMem(cleR)) or 0) >= 60 then
            ecrireMem(cleR, tostring(lzS()))
            return d, "eclaireur rang " .. rang
        end
    end
    return DALLES_CELLULES[((rang - 1) + n) % #DALLES_CELLULES + 1], "eclaireur rang " .. rang .. " (toutes les dalles en impasse)"
end
local function chefId() return tostring(idDe(comptesEquipe()[1])) end
local function signeDeVie(texte)
    signalLaby()
    if lzS() - DERNIER_DIRE_LABY >= 10 then
        DERNIER_DIRE_LABY = lzS()
        dire("attente labyrinthe : " .. tostring(texte))
    end
end
local function resoudreTentative(ici)
    local tpc, tpts = etatS("LABY_TP"):match("^(%d+)|(%d+)$")
    if tpc ~= nil and tpc ~= ici then
        majEtat({ LABY_TP = "" })
        effacerMem("RS_" .. moiId() .. "_LABY_TP")
    end
    local tc, tdir, ts, tcell, tms = etatS("LABY_T"):match("^(%d+)|(%u+)|(%w+)|(%-?%d+)|(%d+)$")
    if tc == nil or tc == ici then return end
    local maj = { LABY_T = "" }
    if lzT() - (tonumber(tms) or 0) > 120000 then majEtat(maj) return end
    local cellArr = celluleIci()
    if tc == DALLES then
        ecrireMem("LABYD_" .. tostring(ts), ici)
        dire("[LABY] dalle " .. ts .. " -> " .. ici .. " cellArr=" .. cellArr .. " t=" .. (lzT() - tonumber(tms)) .. "ms")
        if labyXY(ici) ~= nil and ici ~= CENTRE then
            maj.LABY_SALLE, maj.LABY_DIR, maj.LABY_TS, maj.LABY_PREC = ici, "DALLE", lzS(), "0|0|DALLE|" .. ts
            local etats = etatS("LABY_ETATS")
            maj.LABY_ETATS = ((etats == "") and "," or etats) .. ici .. ":DALLE,"
        end
        majEtat(maj)
        return
    end
    local x, y = labyXY(tc)
    local nx, ny = labyXY(ici)
    if x == nil or nx == nil or DELTA[ts] == nil then majEtat(maj) return end
    noterArete(x, y, tdir, ts, true, ici)
    local pris = etatS("LABY_PRIS")
    local cleP = tc .. ":" .. tdir .. ":" .. ts .. ","
    if not pris:find("," .. cleP, 1, true) then pris = ((pris == "") and "," or pris) .. cleP end
    if #pris > 1500 then pris = "," .. pris:sub(-1000):gsub("^[^,]*,", "") end
    maj.LABY_PRIS = pris
    local etats = etatS("LABY_ETATS")
    etats = ((etats == "") and "," or etats) .. ici .. ":" .. ts .. ","
    if #etats > 1500 then etats = "," .. etats:sub(-1000):gsub("^[^,]*,", "") end
    maj.LABY_ETATS = etats
    dire("[LABY] (" .. x .. "," .. y .. ") dirIn=" .. tdir .. " cellDep=" .. tcell .. " sortie=" .. ts .. " -> (" .. nx .. "," .. ny
        .. ") cellArr=" .. cellArr .. " t=" .. (lzT() - tonumber(tms)) .. "ms")
    maj.LABY_SALLE, maj.LABY_DIR, maj.LABY_TS, maj.LABY_PREC = ici, ts, lzS(), x .. "|" .. y .. "|" .. tdir .. "|" .. ts
    local tr = etatS("LABY_TRACE")
    local td, tss, trr = tr:match("^(%d+)|([%u,]*)|([%d,]*)$")
    if td ~= nil and tdir ~= "INCONNU" then
        tss = (tss == "" and ts) or (tss .. "," .. ts)
        trr = (trr == "" and tc) or (trr .. "," .. tc)
        maj.LABY_TRACE = td .. "|" .. tss .. "|" .. trr
    else
        maj.LABY_TRACE = "X"
    end
    if etatS("LABY_PHASE") == "SUIT" then
        local ch = cheminPublie()
        local idx = tonumber(etatS("LABY_IDX")) or 0
        if ch ~= nil and ch.r[idx + 1] == tc and ch.s[idx + 1] == ts then
            maj.LABY_IDX = idx + 1
            ecrireMem("RS_" .. moiId() .. "_LABYSUIT", (idx + 1) .. "|" .. lzS())
        else
            maj.LABY_PHASE = "EXPLORE"
        end
    end
    if ici == CENTRE then
        maj.LABY_PHASE = "CENTRE"
        ecrireMem("RS_" .. moiId() .. "_LABYSUIT", "99|" .. lzS())
        if cheminPublie() == nil and maj.LABY_TRACE ~= "X" then
            ecrireMem("LABYP_" .. chefId(), maj.LABY_TRACE .. "|" .. lzS())
            effacerMem("LABYP_KO_" .. chefId())
            dire("labyrinthe : CENTRE atteint -> chemin publie pour l equipe : " .. maj.LABY_TRACE)
        end
    end
    majEtat(maj)
end
local function monTour(depuis)
    if lzS() - depuis >= 240 then return true end
    local moi, rang = moiId(), monRang()
    for i, a in ipairs(comptesEquipe()) do
        local id = tostring(idDe(a))
        if id ~= moi then
            local c = carteDe(a)
            if i < rang and c == DALLES then return false end
            local k, t = tostring(lireMem("RS_" .. id .. "_LABYSUIT") or ""):match("^(%d+)|(%d+)$")
            if k ~= nil and tonumber(k) < 2 and lzS() - (tonumber(t) or 0) < 90 and labyXY(c) ~= nil and c ~= CENTRE then return false end
        end
    end
    return true
end
local function distConnue(salle, dirIn)
    local file, vu, i = { { tostring(salle), dirIn, 0 } }, {}, 1
    while file[i] ~= nil and i <= 80 do
        local s0, d0, k = file[i][1], file[i][2], file[i][3]
        i = i + 1
        if s0 == CENTRE then return k end
        if not vu[s0 .. d0] and k < 10 then
            vu[s0 .. d0] = true
            local x, y = labyXY(s0)
            if x ~= nil then
                for _, s in ipairs(DIRS) do
                    local a = arete(x, y, d0, s)
                    if a ~= nil and a.etat == "OK" and a.arr ~= "" then file[#file + 1] = { a.arr, s, k + 1 } end
                end
            end
        end
    end
    return nil
end
local function cheminPublie()
    local v = tostring(lireMem("LABYP_" .. chefId()) or "")
    local d, ss, rr, ts = v:match("^(%d+)|([%u,]*)|([%d,]*)|(%d+)$")
    if d == nil or lzS() - (tonumber(ts) or 0) > 10800 then return nil end
    local ch = { dalle = tonumber(d), s = {}, r = {} }
    for x in ss:gmatch("%u") do ch.s[#ch.s + 1] = x end
    for x in rr:gmatch("%d+") do ch.r[#ch.r + 1] = x end
    if #ch.s == 0 or #ch.s ~= #ch.r then return nil end
    return ch
end
local function reconnexionLaby(ici, raison)
    local l = {}
    for t in etatS("LABY_RECO"):gmatch("%d+") do if lzS() - tonumber(t) < 600 then l[#l + 1] = t end end
    if #l >= 2 then
        if lzS() - (tonumber(etatS("LABY_R3")) or 0) >= 300 then
            majEtat({ LABY_R3 = lzS() })
            alerte("labyrinthe : INTERVENTION — 2 reconnexions en 10 min, toujours bloque sur " .. tostring(ici) .. " (" .. tostring(raison) .. ")")
        end
        patienter(40000, "bloque sur " .. tostring(ici) .. ", reconnexions epuisees (alerte envoyee)")
        return false
    end
    l[#l + 1] = tostring(lzS())
    majEtat({ LABY_RECO = table.concat(l, ","), LABY_SALLE = "", LABY_DIR = "", LABY_T = "", LABY_TPR = lzS() })
    alerte("labyrinthe : " .. tostring(raison) .. " sur " .. tostring(ici) .. " -> reconnexion immediate (resynchronisation)")
    pcall(function() global:reconnectSec(5) end)
    attendre(function() return false end, 20000, 500)
    return true
end
local function noterMort(prec)
    local px, py, pd, ps = tostring(prec or ""):match("^(%d)|(%d+)|(%u+)|(%w+)$")
    if px == nil then return end
    if pd == "DALLE" and px == "0" then
        ecrireMem("LABYDM_" .. ps, tostring(lzS()))
        dire("labyrinthe : dalle " .. ps .. " -> impasse, evitee 15 min")
        return
    end
    local a = lireArete(px, py, pd, ps)
    if a == nil or a.etat ~= "OK" then return end
    ecrireMem(cleArete(px, py, pd, ps), "MORT|" .. a.arr .. "|" .. a.nok .. "|" .. a.nko .. "|" .. lzS())
    dire("labyrinthe : passage (" .. px .. "," .. py .. ") dirIn=" .. pd .. " sortie=" .. ps .. " -> impasse, evite 15 min")
end
local function noterArete(x, y, dirIn, s, ok, arr)
    local a = lireArete(x, y, dirIn, s) or { etat = "?", arr = "", nok = 0, nko = 0, ts = 0 }
    if ok then
        a.etat, a.arr, a.nok, a.nko = "OK", tostring(arr), a.nok + 1, 0
    else
        a.nko = a.nko + 1
        if a.etat ~= "OK" or a.nko >= 2 then a.etat = "KO" end
    end
    a.ts = lzS()
    ecrireMem(cleArete(x, y, dirIn, s), a.etat .. "|" .. a.arr .. "|" .. a.nok .. "|" .. a.nko .. "|" .. a.ts)
    if ok then
        pcall(function()
            local f = io.open(fichierGraphe(), "a")
            if f ~= nil then f:write("OK " .. x .. " " .. y .. " " .. dirIn .. " " .. s .. " " .. tostring(arr) .. " " .. a.ts .. "\n") f:close() end
        end)
    end
end
local function fwouedVolontairePermis()
    local n = 0
    for t in etatS("LABY_FWV"):gmatch("%d+") do if lzS() - tonumber(t) < 900 then n = n + 1 end end
    return n < 3
end
local function patienter(ms, texte)
    local fin = lzT() + ms
    while lzT() < fin do
        signeDeVie(texte)
        attendre(function() return false end, 500, 100)
    end
end
local function echecChemin(raison)
    local cle = "LABYP_KO_" .. chefId()
    local n = (tonumber(lireMem(cle)) or 0) + 1
    if n >= 2 then
        effacerMem("LABYP_" .. chefId())
        effacerMem(cle)
        alerte("labyrinthe : chemin publie en echec 2 fois (" .. tostring(raison) .. ") -> retire, exploration")
    else
        ecrireMem(cle, tostring(n))
        alerte("labyrinthe : chemin publie en echec (" .. tostring(raison) .. ") " .. n .. "/2")
    end
end
local function cleArete(x, y, dirIn, s) return "LABYG_" .. x .. "_" .. y .. "_" .. dirIn .. "_" .. s end
local function ordreSorties(x, y, dirIn, attendu)
    local d0 = distTore(x, y)
    local vues = etatS("LABY_VUES")
    local l = {}
    for _, s in ipairs(DIRS) do
        local nx, ny = voisine(x, y, s)
        local cible = salleXY(nx, ny)
        local dn = distTore(nx, ny)
        local a = arete(x, y, dirIn, s)
        local sc
        if attendu == s then sc = 0
        elseif a ~= nil and a.etat == "OK" then
            local k = (a.arr == CENTRE) and 0 or distConnue(a.arr, s)
            if k ~= nil then sc = 1 + k / 100 else sc = ((dn < d0) and 2 or 3) - 0.05 + dn / 100 end
        elseif a ~= nil and a.etat == "KO" then sc = 6
        elseif a ~= nil and a.etat == "MORT" then sc = 7
        else sc = ((dn < d0) and 2 or 3) + dn / 100 end
        if s ~= attendu then
            if cible == CENTRE and not ((x == 3 and s == "D") or (x == 5 and s == "G")) then sc = sc + 0.5 end
            if DELTA[dirIn] ~= nil then
                if s == OPPOSE[dirIn] then sc = sc + 4 elseif s == dirIn then sc = sc + 0.9 end
            end
            if cible ~= CENTRE and vues:find("," .. cible .. ",", 1, true) then sc = sc + 1.5 end
        end
        l[#l + 1] = { s = s, sc = sc }
    end
    table.sort(l, function(a, b) return a.sc < b.sc end)
    return l
end
local function pasLabyrinthe()
    chargerGraphe()
    local ici, x, y = ici_xy()
    signalLaby()
    local tpc, tpts = etatS("LABY_TP"):match("^(%d+)|(%d+)$")
    if tpc == ici and lzS() - (tonumber(tpts) or 0) < 60 then
        if (tonumber(etatS("LABY_TPR")) or 0) < (tonumber(tpts) or 0) then
            reconnexionLaby(ici, "relance juste apres un Fwoued sans teleportation")
            return
        end
        majEtat({ LABY_TP = "" })
    end
    if x == nil then
        if not fwouedVersDalles(ici, "carte hors grille du labyrinthe", false) then reconnexionLaby(ici, "hors grille") end
        return
    end
    attendreStabilite(ici)
    local dirIn = "INCONNU"
    if etatS("LABY_SALLE") == ici and lzS() - (tonumber(etatS("LABY_TS")) or 0) < 900 then
        dirIn = etatS("LABY_DIR")
        if dirIn == "" then dirIn = "INCONNU" end
    end
    local maj = {}
    local vues = etatS("LABY_VUES")
    if not vues:find("," .. ici .. ",", 1, true) then maj.LABY_VUES = ((vues == "") and "," or vues) .. ici .. "," end
    if dirIn == "INCONNU" then maj.LABY_TRACE = "X" end
    local etats = etatS("LABY_ETATS")
    local cleEt = "," .. ici .. ":" .. dirIn .. ","
    local nVisites = 0
    do local i0 = 1 while true do local a0 = etats:find(cleEt, i0, true) if a0 == nil then break end nVisites = nVisites + 1 i0 = a0 + 1 end end
    if nVisites < 1 then nVisites = 1 end
    local ch = cheminPublie()
    local phase = etatS("LABY_PHASE")
    local idx = tonumber(etatS("LABY_IDX")) or 0
    local attendu = nil
    if ch ~= nil then
        if phase == "SUIT" and ch.r[idx + 1] == ici then
            attendu = ch.s[idx + 1]
        else
            local k = positionSurChemin(ch, ici, dirIn)
            if k ~= nil then
                attendu = ch.s[k]
                maj.LABY_PHASE, maj.LABY_IDX = "SUIT", k - 1
            elseif phase == "SUIT" then
                maj.LABY_PHASE = "EXPLORE"
                echecChemin("salle " .. ici .. " hors du chemin")
            elseif distTore(x, y) > 1 and fwouedVolontairePermis() then
                if next(maj) ~= nil then majEtat(maj) end
                fwouedVersDalles(ici, "chemin publie par l equipe, je n y suis pas", true)
                return
            end
        end
    end
    if next(maj) ~= nil then majEtat(maj) end
    dire("labyrinthe : salle (" .. x .. "," .. y .. ") dirIn=" .. dirIn .. (attendu and (" chemin -> " .. attendu) or ""))
    local r1Fait, poche, toutesFermees = false, false, false
    for tour = 1, 2 do
        local sansChemin = {}
        for _, c in ipairs(ordreSorties(x, y, dirIn, attendu)) do
            local a = (c.s ~= attendu) and arete(x, y, dirIn, c.s) or nil
            local boucle = c.s ~= attendu and dirIn ~= "INCONNU"
                and etatS("LABY_PRIS"):find("," .. ici .. ":" .. dirIn .. ":" .. c.s .. ",", 1, true) ~= nil
            if boucle and tour == 1 then dire("labyrinthe : sortie " .. c.s .. " deja prise depuis cette salle et cette entree (boucle) -> en dernier") end
            local permis
            if tour == 1 then permis = (a == nil or a.etat ~= "MORT") and not boucle
            else permis = (a == nil or a.etat ~= "MORT") and (not boucle or nVisites < 3) end
            if permis then
                local r = essayerSortie(ici, x, y, dirIn, c.s)
                if r == "change" or carte() ~= ici then return end
                if r == "sanschemin" then sansChemin[c.s] = true end
                if c.s == attendu then
                    echecChemin("sortie " .. c.s .. " de " .. ici .. " : " .. r)
                    attendu = nil
                    majEtat({ LABY_PHASE = "EXPLORE" })
                end
            end
        end
        if tour == 2 then
            local nf = 0
            for _, s in ipairs(DIRS) do if sansChemin[s] then nf = nf + 1 end end
            toutesFermees = (nf == 4)
            break
        end
        local cp = composante()
        if cp ~= nil then
            local unJoignable = nil
            for s, _ in pairs(cp.joignable) do if sansChemin[s] then unJoignable = s end end
            if next(cp.joignable) == nil and cp.nc < cp.n then
                poche = true
                dire("labyrinthe : poche (" .. cp.nc .. "/" .. cp.n .. " cases) sans sortie sur " .. ici)
                break
            end
            if unJoignable ~= nil and not r1Fait then r1Fait = pasVersSortie(cp, unJoignable) end
            if carte() ~= ici then return end
        end
        patienter(3000, "portes fermees sur (" .. x .. "," .. y .. "), nouvel essai")
    end
    if dirIn ~= "INCONNU" and toutesFermees and not poche then noterMort(etatS("LABY_PREC")) end
    if not fwouedVersDalles(ici, poche and "poche sans sortie" or "aucune sortie praticable", false) then
        patienter(20000, "aucune sortie sur (" .. x .. "," .. y .. "), Fwoued deja utilise ici il y a moins de 3 min")
    end
end
local function arete(x, y, dirIn, s)
    local a = lireArete(x, y, dirIn, s)
    if a == nil then return nil end
    if a.etat == "KO" and lzS() - a.ts > 600 then return nil end
    if a.etat == "OK" and lzS() - a.ts > 10800 then return nil end
    if a.etat == "MORT" and lzS() - a.ts > 900 then a.etat = "OK" end
    return a
end
local function chargerGraphe()
    if lireMem("LABYG_CHARGE") ~= nil then return end
    ecrireMem("LABYG_CHARGE", tostring(lzS()))
    pcall(function()
        local f = io.open(fichierGraphe(), "r")
        if f == nil then return end
        local n = 0
        for l in f:lines() do
            local x, y, d, s, arr, ts = l:match("^OK (%d) (%d+) (%u+) (%u) (%d+) (%d+)")
            if x ~= nil and lzS() - (tonumber(ts) or 0) < 10800 and lireMem(cleArete(x, y, d, s)) == nil then
                ecrireMem(cleArete(x, y, d, s), "OK|" .. arr .. "|1|0|" .. ts)
                n = n + 1
            end
        end
        f:close()
        if n > 0 then dire("labyrinthe : " .. n .. " passage(s) connus recharges depuis laby-graphe.txt") end
    end)
end

ETAPE.dansDonjon = function()
    local id = tonumber(carte()) or 0
    return id >= 72089000 and id <= 72096000
end
ETAPE.detour = function()
    if not enCombat() then pcall(configIA, carte() == "72361984") end
    local ici = carte()
    local id = tonumber(ici) or 0
    if id < 72089000 or id > 72096000 then return nil end
    pcall(resoudreTentative, ici)
    if ETAT_ETAPE ~= nil and ETAT_ETAPE.phase == "donjon" then ETAT_ETAPE.idx = 2 end
    if dansLabyrinthe() then return { { map = ici, custom = protege(pasLabyrinthe, "salle") } } end
    if ici == DALLES then return { { map = ici, custom = protege(entrerParDalle, "dalles") } } end
    return nil
end
ETAPE.donjon = {
    { map = DALLES, custom = protege(entrerParDalle, "dalles") },
    { map = CENTRE, custom = function()
        local ici = carte()
        pcall(resoudreTentative, ici)
        signalLaby()
        local n = #comptesEquipe()
        local noms = 0
        pcall(function()
            local moiNom = sur(function() return global:thisAccountController():getUsername() end, "")
            for _ in tostring(lireMem("RS_EQUIPE_DE_" .. moiNom) or ""):gmatch("[^,]+") do noms = noms + 1 end
        end)
        if (noms == 0 and n < 7) or (noms > 0 and n < noms) then
            alerte("salle centrale : equipe lue a " .. n .. "/" .. noms .. " compte(s) seulement -> pas d entree dans l antre")
            patienter(20000, "salle centrale, liste d equipe incomplete")
            rejouerCetteEntree()
            return
        end
        local chefDedans = false
        pcall(function()
            local cc = tonumber(carteDe(comptesEquipe()[1])) or 0
            chefDedans = cc >= 72351744 and cc <= 72363008
        end)
        if not chefDedans and not equipeAuComplet(ici, nil, true) then return end
        if chefDedans then dire("salle centrale : le leader est deja dans l antre -> j entre pour le rejoindre") end
        parler(784, { -1, -1 }, { changeCarte = 5000 })
    end },
    { map = "72351744", path = "right" },
    { map = "72352768", door = "306" },
    { map = "72353792", fight = true },
    { map = "72354816", custom = function()
        for _, c in ipairs({ 267, 485, 431 }) do
            pcall(function() map:moveToCell(c) end)
            attendre(function() return tonumber(sur(function() return map:currentCell() end, -1)) == c end, 3000, 100)
        end
    end, door = "403" },
    { map = "72355840", fight = true },
    { map = "72356864", path = "488" },
    { map = "72357888", fight = true },
    { map = "72358146", path = "474" },
    { map = "72358912", fight = true },
    { map = "72359170", path = "487" },
    { map = "72359936", fight = true },
    { map = "72360960", path = "501" },
    { map = "72361984", fight = true },
    { map = "72363008", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(784, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

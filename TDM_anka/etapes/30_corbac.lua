charger("etapes\\lib_donjons.lua", true)
local function kc(k)
    local p = ""
    pcall(function() p = tostring(cleEquipe()) end)
    return p .. k
end
CB_NPC_VIRGIL = 774
CB_MAP_VIRGIL = "158334976"
CB_MAP_ENTREE = "159121408"
CB_PORTE_ENTREE = 124
CB_LIMITE_GROUPE = 8
CB_MOBS = { { id = 823, nom = "Rono le Renarbo" }, { id = 824, nom = "Horace le Corbac Apprivoise" },
            { id = 825, nom = "Kapotie le Buveur" } }
CB_LABY = { { -12, -61 }, { -13, -61 }, { -14, -61 }, { -15, -61 }, { -15, -60 }, { -14, -60 }, { -13, -60 },
            { -12, -60 }, { -12, -59 }, { -13, -59 }, { -14, -59 }, { -15, -59 }, { -15, -58 }, { -14, -58 },
            { -13, -58 }, { -12, -58 } }
local function cbDansLaby(x, y)
    for i, c in ipairs(CB_LABY) do if c[1] == x and c[2] == y then return i end end
    return nil
end
local function cbCle(x, y) return tostring(x) .. "," .. tostring(y) end
local function cbCoords()
    local ok, x, y = pcall(function() local id = map:currentMapId() return map:getX(id), map:getY(id) end)
    if ok then return x, y end
    return nil, nil
end

local CB_CARTES_DONJON = { ["159121666"] = true, ["159125512"] = true, ["159124488"] = true }
local function cbFait(id) return lireMem(kc("CORBAC_FAIT_") .. id) == "1" end
local function cbCompteur()
    local t = {}
    for _, m in ipairs(CB_MOBS) do t[#t + 1] = m.nom .. " " .. (cbFait(m.id) and "1" or "0") .. "/1" end
    return table.concat(t, " | ")
end
local function equipeLabySur(c)
    for _, a in ipairs(comptesEquipe()) do
        local m = tostring(carteDe(a))
        if idDe(a) ~= moiId() and m ~= tostring(c) and not CB_CARTES_DONJON[m] then return false end
    end
    return true
end
local function cbRestants()
    local r = {}
    for _, m in ipairs(CB_MOBS) do if not cbFait(m.id) then r[#r + 1] = m end end
    return r
end

CB_MUR, CB_RATISSEE, CB_CIBLE_IDX, CB_ESSAIS, CB_MEME_CARTE, CB_DERNIERE = {}, {}, nil, 0, 0, nil
local DIRS = { { dx = 1, dy = 0, nom = "right" }, { dx = -1, dy = 0, nom = "left" },
               { dx = 0, dy = -1, nom = "top" }, { dx = 0, dy = 1, nom = "bottom" } }
function CB_dansBibliotheque()
    local n = tonumber(carte()) or 0
    return n >= 159000000 and n < 160000000
end
local function cbChemin(sx, sy, but)
    local file, vu, parent, i = { { sx, sy } }, { [cbCle(sx, sy)] = true }, {}, 1
    while i <= #file do
        local x, y = file[i][1], file[i][2]
        i = i + 1
        for _, d in ipairs(DIRS) do
            local nx, ny = x + d.dx, y + d.dy
            local k = cbCle(nx, ny)
            if cbDansLaby(nx, ny) and not vu[k] and not CB_MUR[cbCle(x, y) .. ">" .. d.nom] then
                vu[k] = true
                parent[k] = { x, y, d.nom }
                file[#file + 1] = { nx, ny }
                if but(nx, ny) then
                    local ch, c = {}, k
                    while parent[c] do
                        table.insert(ch, 1, { nx, ny, parent[c][3] })
                        nx, ny = parent[c][1], parent[c][2]
                        c = cbCle(nx, ny)
                    end
                    return ch
                end
            end
        end
    end
    return nil
end
local function cbProchaine(ici)
    local x0, y0 = CB_LABY[ici][1], CB_LABY[ici][2]
    for _ = 1, 2 do
        local ch = cbChemin(x0, y0, function(x, y) return not CB_RATISSEE[cbCle(x, y)] end)
        if ch then
            local f = ch[#ch]
            return cbDansLaby(f[1], f[2])
        end
        CB_RATISSEE = { [cbCle(x0, y0)] = true }
        CB_MUR = {}
    end
    return ici % #CB_LABY + 1
end
function detourCorbac()
    local cm = carte()
    local x, y = cbCoords()
    local n = tonumber(cm) or 0
    local interieur = n >= 159000000 and n < 160000000
    local dansLaby = interieur and (x ~= nil and cbDansLaby(x, y) ~= nil)
    if cm ~= CB_MAP_ENTREE and not dansLaby then return nil end
    if ETAT_ETAPE.phase ~= "entree" and ETAT_ETAPE.phase ~= "aller" then return nil end
    if not estLeader() then
        local chef = comptesEquipe()[1]
        local carteChef = tostring(carteDe(chef))
        if cm == CB_MAP_ENTREE and (carteChef == "159121666" or carteChef == "159125512") then
            return { { map = cm, custom = function()
                dire("[CORBAC] le chef est dans le donjon -> Virgil")
                parler(CB_NPC_VIRGIL, { -2, -1 }, { changeCarte = 6000 })
            end } }
        end
        local cx, cy = string.match(tostring(lireMem(kc("CORBAC_CIBLE")) or ""), "^(-?%d+),(-?%d+)$")
        cx, cy = tonumber(cx), tonumber(cy)
        if #cbRestants() == 0 or cm == CB_MAP_ENTREE or carteChef == CB_MAP_ENTREE then cx = nil end
        if cx and dansLaby and carteChef == cm and (cx ~= x or cy ~= y) and not sur(function() return chef.character:isInFight() end, false) then
            return { { map = cm, custom = function() pcall(function() map:moveToward(cx, cy) end)
                attendre(function() return carte() ~= cm end, 6000, 150) end } }
        end
        if carteChef ~= "" and carteChef ~= cm and not sur(function() return chef.character:isInFight() end, false) then
            return { { map = cm, custom = function()
                local lx, ly = nil, nil
                pcall(function() lx, ly = map:getX(tonumber(carteChef)), map:getY(tonumber(carteChef)) end)
                if lx ~= nil then pcall(function() map:moveToward(lx, ly) end)
                else pcall(function() map:moveToward(tonumber(carteChef)) end) end
                attendre(function() return carte() ~= cm end, 6000, 150)
            end } }
        end
        return { { map = cm, custom = function() attendre(function() return carte() ~= cm or enCombat() or tostring(lireMem(kc("CORBAC_CIBLE")) or "") ~= "" and tostring(lireMem(kc("CORBAC_CIBLE"))) ~= tostring(x) .. "," .. tostring(y) end, 2500, 150) end } }
    end
    cbSuiviCombat()
    FORCE_MONSTERS = {}
    MAX_MONSTERS = CB_LIMITE_GROUPE
    local restants = cbRestants()
    if cm == CB_MAP_ENTREE then
        ecrireMem(kc("CORBAC_CIBLE"), "")
        if #restants == 0 then
            return { { map = cm, custom = function()
                if not equipeLabySur(cm) then attendre(function() return equipeLabySur(cm) end, 15000, 300) return end
                dire("[CORBAC] 3/3 -> Virgil : entree du donjon")
                parler(CB_NPC_VIRGIL, { -2, -1 }, { changeCarte = 6000 })
            end } }
        end
        return { { map = cm, door = tostring(CB_PORTE_ENTREE) } }
    end
    if #restants == 0 then
        return { { map = cm, custom = function() pcall(function() map:moveToward(tonumber(CB_MAP_ENTREE)) end) end } }
    end
    local ici = cbDansLaby(x, y)
    CB_RATISSEE[cbCle(x, y)] = true
    local g, cibles = cbGroupeCible()
    if g ~= nil then
        if not equipeLabySur(cm) then
            ecrireMem(kc("CORBAC_CIBLE"), tostring(x) .. "," .. tostring(y))
            dire("[CORBAC] cible sur cette carte : on attend l equipe pour engager")
            return { { map = cm, custom = function() attendre(function() return equipeLabySur(cm) end, 45000, 300) end } }
        end
        local ids, noms = {}, {}
        for _, c in ipairs(cibles) do ids[#ids + 1] = tostring(c.id) noms[#noms + 1] = c.nom end
        dire("[CORBAC] cible(s) : " .. table.concat(noms, " + ") .. " -> combat (" .. cbCompteur() .. ")")
        FORCE_MONSTERS = { g.contextualId }
        ecrireMem(kc("CORBAC_VISE"), table.concat(ids, ","))
        ecrireMem(kc("CORBAC_NB_COMBATS"), tostring(sur(function() return global:getCountFight() end, -1)))
        return { { map = cm, fight = true } }
    end
    if cm == CB_DERNIERE then CB_MEME_CARTE = CB_MEME_CARTE + 1 else CB_MEME_CARTE = 0 end
    CB_DERNIERE = cm
    if CB_CIBLE_IDX == nil or CB_CIBLE_IDX == ici or CB_RATISSEE[cbCle(CB_LABY[CB_CIBLE_IDX][1], CB_LABY[CB_CIBLE_IDX][2])] then
        CB_CIBLE_IDX = cbProchaine(ici)
        CB_ESSAIS = 0
    end
    CB_ESSAIS = CB_ESSAIS + 1
    if CB_ESSAIS > 3 and CB_MEME_CARTE >= 2 then
        local c = CB_LABY[CB_CIBLE_IDX]
        CB_RATISSEE[cbCle(c[1], c[2])] = true
        CB_CIBLE_IDX = cbProchaine(ici)
        CB_ESSAIS = 1
    end
    local c = CB_LABY[CB_CIBLE_IDX]
    dire("[CORBAC] pas de cible ici -> (" .. c[1] .. "," .. c[2] .. ")  -  " .. cbCompteur())
    return cbAller(cm, c[1], c[2])
end
local function cbAller(cm, x, y)
    return { { map = cm, custom = function()
        local cx, cy = cbCoords()
        if cx == nil or not cbDansLaby(cx, cy) then
            pcall(function() map:moveToward(x, y) end)
            return
        end
        local ch = cbChemin(cx, cy, function(px, py) return px == x and py == y end)
        if ch == nil then CB_MUR = {} ch = cbChemin(cx, cy, function(px, py) return px == x and py == y end) end
        if ch == nil then alerte("[CORBAC] aucun chemin vers (" .. x .. "," .. y .. ")") return end
        local dir, nx, ny = ch[1][3], ch[1][1], ch[1][2]
        local depart = carte()
        ecrireMem(kc("CORBAC_CIBLE"), nx .. "," .. ny)
        pcall(function() map:moveToward(nx, ny) end)
        if not attendre(function() return carte() ~= depart end, 8000, 200) then
            pcall(function() map:moveToward(nx, ny) end)
        end
        if not attendre(function() return carte() ~= depart end, 8000, 200) then
            CB_MUR[cbCle(cx, cy) .. ">" .. dir] = true
            alerte("[CORBAC] passage " .. dir .. " refuse en (" .. cx .. "," .. cy .. ")")
        end
    end } }
end
local function cbGroupeCible()
    local ok, groupes = pcall(function() return map:monsterGroups() end)
    if not ok or groupes == nil then return nil, nil end
    local restants = cbRestants()
    local best, bestCibles = nil, nil
    local vus = {}
    for _, g in ipairs(groupes) do
        pcall(function() for _, mob in ipairs(g.monsters or {}) do vus[#vus + 1] = tostring(mob.id) end end)
    end
    dire("[CORBAC] groupes sur la carte : " .. #groupes .. " -> monstres " .. (#vus > 0 and table.concat(vus, " ") or "aucun lu"))
    for _, g in ipairs(groupes) do
        local cibles = {}
        for _, c in ipairs(restants) do
            for _, mob in ipairs(g.monsters or {}) do
                if tonumber(mob.id) == c.id then cibles[#cibles + 1] = c break end
            end
        end
        if #cibles > 0 and #(g.monsters or {}) <= CB_LIMITE_GROUPE and (best == nil or #cibles > #bestCibles) then
            best, bestCibles = g, cibles
        end
    end
    return best, bestCibles
end
local function cbSuiviCombat()
    local vise = lireMem(kc("CORBAC_VISE")) or ""
    if vise == "" then return end
    local avant = tonumber(lireMem(kc("CORBAC_NB_COMBATS")) or "-1") or -1
    local nb = tonumber(sur(function() return global:getCountFight() end, -1)) or -1
    if not enCombat() and avant >= 0 and nb > avant then
        for id in string.gmatch(vise, "%d+") do ecrireMem(kc("CORBAC_FAIT_") .. id, "1") end
        ecrireMem(kc("CORBAC_VISE"), "")
        dire("[CORBAC] combat gagne : " .. cbCompteur())
    end
end

local ETAPE = {
    cle    = "donjons_corbac",
    nom    = "Kal Vissi puis Bibliotheque du Maitre Corbac",
    succes = {},
    acces  = "pied",
    detour = detourCorbac,
}
ETAPE.quete = trajetVersKal(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(147590153)" },
    { map = "-17,-47", path = "right" },
    { map = "-16,-47", path = "top" }, { map = "-16,-48", path = "top" }, { map = "-16,-49", path = "top" },
    { map = "-16,-50", path = "top" }, { map = "-16,-51", path = "top" }, { map = "-16,-52", path = "top" },
    { map = "-16,-53", path = "top" }, { map = "-16,-54", path = "top" }, { map = "-16,-55", path = "top" },
    { map = "-16,-56", path = "top" }, { map = "-16,-57", path = "top" }, { map = "-16,-58", path = "top" },
    { map = "-16,-59", path = "top" }, { map = "-16,-60", path = "top" },
    { map = "-16,-61", path = "right" },
    { map = "-15,-61", path = "top" },
}
ETAPE.entree = {
    carte = CB_MAP_VIRGIL,
    pnj = CB_NPC_VIRGIL,
    reponses = { -2 },
    custom = function()
        for _, m in ipairs(CB_MOBS) do ecrireMem(kc("CORBAC_FAIT_") .. m.id, "0") end
        local avant = carte()
        pcall(function() npc:npc(CB_NPC_VIRGIL, 3) end)
        attendre(function() return optionsDuMenu ~= nil and optionsDuMenu() ~= nil end, 3000)
        local choix = -2
        local o = optionsDuMenu and optionsDuMenu() or nil
        if o then for k, t in pairs(o) do if t:find("entrer dans la biblioth", 1, true) then choix = -k end end end
        pcall(function() npc:reply(choix) end)
        attendre(function() return carte() ~= avant end, 6000)
        if carte() == avant then pcall(function() global:leaveDialog() end) end
    end,
}
ETAPE.donjon = {
    { map = "159121666", fight = true },
    { map = "159125512", fight = true },
    { map = "159124488", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(CB_NPC_VIRGIL, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

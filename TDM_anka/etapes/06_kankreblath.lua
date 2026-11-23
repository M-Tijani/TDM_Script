local BAGUETTE = 15990
local SLOT_ARME = 1
local PRIX_MAX = BAGUETTE_PRIX_MAX or 50000
local CARTE_DEVANT_BANQUE = "191104002"
local CARTE_BANQUE = "192415750"
local PORTE_BANQUE = 288
local CELLULE_SORTIE_BANQUE = 424
local CARTE_HDV = "191106052"
local PNJ_HDV = 515221
local ACTION_HDV_ACHAT = 6
local function remettreArme()
    local gid = tonumber(lireEtat("ARME_AVANT_RIKIKI") or "")
    if gid == nil then return end
    if positionDe(gid) ~= SLOT_ARME then
        if nombreDe(gid) > 0 then
            pcall(function() inventory:equipItem(gid, SLOT_ARME) end)
            if attendre(function() return positionDe(gid) == SLOT_ARME end, 3000) then
                dire("arme d avant la baguette remise (" .. gid .. ")")
            else
                alerte("arme " .. gid .. " non remise en slot " .. SLOT_ARME)
                return
            end
        else
            alerte("arme " .. gid .. " absente de l inventaire, rien a remettre")
        end
    end
    ecrireEtat("ARME_AVANT_RIKIKI", "")
end
local function positionDe(gid) return tonumber(sur(function() return inventory:itemPosition(gid) end, -1)) end
local function equiperBaguette()
    if baguettePortee() then return true end
    if not aLaBaguette() then
        alerte("pas de baguette Rikiki (" .. BAGUETTE .. ") : la porte 242 ne s ouvrira pas")
        return false
    end
    local avant = gidEnSlotArme()
    if (lireEtat("ARME_AVANT_RIKIKI") or "") == "" and avant ~= nil and avant ~= BAGUETTE then
        ecrireEtat("ARME_AVANT_RIKIKI", avant)
    end
    pcall(function() inventory:equipItem(BAGUETTE, SLOT_ARME) end)
    if attendre(baguettePortee, 3000) then dire("baguette Rikiki portee") return true end
    alerte("la baguette Rikiki n est pas en slot " .. SLOT_ARME)
    return false
end
local function trace(ou, action)
    dire("[K6] " .. ou .. " carte " .. tostring(carte()) .. " baguette=" .. tostring(aLaBaguette())
        .. " coffreVu=" .. tostring(coffreVu()) .. " -> " .. action)
end
local function baguettePortee() return positionDe(BAGUETTE) == SLOT_ARME end
local function porteBanque()
    if not aLaBaguette() and not coffreVu() then
        trace("devant banque", "porte banque " .. PORTE_BANQUE .. " (action seule)")
        return tostring(PORTE_BANQUE)
    end
    return nil
end
local function nombreDe(gid) return tonumber(sur(function() return inventory:itemCount(gid) end, 0)) or 0 end
local function gidEnSlotArme()
    local gid = nil
    pcall(function()
        for _, it in ipairs(inventory:inventoryContent()) do
            local pos = it.Position
            if pos == nil then pos = it.position end
            if tonumber(pos) == SLOT_ARME then
                gid = (it.Item and it.Item.Gid) or it.objectGID or it.ObjectGID
                break
            end
        end
    end)
    return tonumber(gid)
end
local function acheterALHdv()
    trace("HDV", "achat")
    for essai = 1, 3 do
        if aLaBaguette() then break end
        dire("HDV : achat de la baguette Rikiki, essai " .. essai .. "/3")
        pcall(function() npc:npc(PNJ_HDV, ACTION_HDV_ACHAT) end)
        attendre(function() return sur(function() return character:isBusy() end, false) == true end, 3000)
        pcall(function() sale:buyItem(BAGUETTE, 1, PRIX_MAX) end)
        attendre(function() return nombreDe(BAGUETTE) >= 1 end, 4000)
        pcall(function() global:leaveDialog() end)
        attendre(function() return sur(function() return character:isBusy() end, false) ~= true end, 2000)
    end
    if not aLaBaguette() then
        alerte("baguette Rikiki (" .. BAGUETTE .. ") introuvable sous " .. PRIX_MAX
            .. " kamas : la porte 242 du Kankreblath ne peut pas s ouvrir -> arret du script")
        pcall(function() global:finishScript() end)
        return
    end
    equiperBaguette()
    avancerVers(CARTE_DEVANT_BANQUE)
end

local function prendreAuCoffre()
    if not aLaBaguette() then
        pcall(function() npc:npcBank(-1) end)
        if not attendre(coffreOuvert, 4000) then
            pcall(function() npc:reply(-1) end)
            attendre(coffreOuvert, 3000)
        end
        if coffreOuvert() then
            local enCoffre = tonumber(sur(function() return exchange:storageItemQuantity(BAGUETTE) end, 0)) or 0
            if enCoffre > 0 then
                pcall(function() exchange:getItem(BAGUETTE, 1) end)
                attendre(function() return nombreDe(BAGUETTE) >= 1 end, 3000)
            end
            dire("coffre : baguette Rikiki " .. (aLaBaguette() and "reprise" or "absente -> HDV"))
            ecrireEtat("RIKIKI_COFFRE_VU", 1)
        else
            alerte("le coffre ne s ouvre pas")
            local n = (tonumber(lireEtat("RIKIKI_COFFRE_ESSAIS") or "0") or 0) + 1
            ecrireEtat("RIKIKI_COFFRE_ESSAIS", n)
            if n >= 2 then ecrireEtat("RIKIKI_COFFRE_VU", 1) end
        end
        pcall(function() exchange:leave() end)
        attendre(function() return not coffreOuvert() end, 2000)
        pcall(function() global:leaveDialog() end)
    end
    if aLaBaguette() then equiperBaguette() end

end
local function coffreOuvert()
    if sur(function() return exchange:isInExchange() end, false) == true then return true end
    return sur(function() return exchange:storageKamas() end, nil) ~= nil
end
local function devantLaBanque()

    if aLaBaguette() then trace("devant banque", "vers 3,-18") avancerVers(3, -18) return end

    if not coffreVu() then trace("devant banque", "porte banque " .. PORTE_BANQUE) return end
    trace("devant banque", "vers HDV")
    avancerVers(CARTE_HDV)
    attendre(function() return carte() ~= CARTE_DEVANT_BANQUE end, 5000)
end
local function aLaBaguette() return baguettePortee() or nombreDe(BAGUETTE) >= 1 end
local function coffreVu() return lireEtat("RIKIKI_COFFRE_VU") == "1" end
local function versBanqueOuHdv()
    if not aLaBaguette() and coffreVu() then trace("passage", "vers HDV " .. CARTE_HDV) avancerVers(CARTE_HDV)
    else trace("passage", "vers banque") avancerVers(CARTE_DEVANT_BANQUE) end
    dire("[K6] arrive carte " .. tostring(carte()))
end
local ETAPE = {
    cle    = "kankreblath",
    nom    = "Baguette Rikiki puis Cache de Kankreblath",
    succes = { 1184 },
    donjonSolo = true,
    acces  = "tp",
    quete  = nil,
    aller  = {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(191105026)" },
        { map = "191105026", custom = function() versBanqueOuHdv() end },

        { map = "6,-18", custom = function() versBanqueOuHdv() end },
        { map = "5,-17", custom = function() versBanqueOuHdv() end },
        { map = CARTE_DEVANT_BANQUE, custom = devantLaBanque, doorFn = porteBanque },
        { map = CARTE_HDV, custom = acheterALHdv },

        { map = CARTE_BANQUE, custom = prendreAuCoffre },
        { map = CARTE_BANQUE, pathFn = function() trace("banque", "sortie cellule " .. CELLULE_SORTIE_BANQUE) return tostring(CELLULE_SORTIE_BANQUE) end },
        { map = "3,-18", path = "bottom" },
        { map = "191102980", door = "290" },
        { map = "103547392", door = "298" },
        { map = "103548416", door = "298" },

        { map = "103549440", doorFn = function() equiperBaguette() return "242" end },
    },
    entree = {
        carte = "146676736",
        pnj = 2766,
        reponses = { -1, -1 },
        reponsesTp = { -2 },
        custom = nil,
    },
    donjon = {
        { map = "146675712", fight = true },
        { map = "146674688", fight = true },
        { map = "146673664", fight = true },
        { map = "146672640", door = "205" },
        { map = "146671616", fight = true },
        { map = "146670592", fight = true },
        { map = "146538496", custom = function()
            remettreArme()
            parler(2767, { -1 }, { changeCarte = 5000 })
        end },
    },
    apres  = nil,
}
ETAPE.entree.custom = function()
    remettreArme()
    entrerDansLeDonjon(ETAPE)
end
ETAPES[#ETAPES + 1] = ETAPE

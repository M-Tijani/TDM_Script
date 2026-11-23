charger("etapes\\lib_donjons.lua", true)
local ETAPE = {
    cle    = "donjons_royalmouth",
    nom    = "Kal Vissi puis Serre du Royalmouth",
    succes = {},
    acces  = "pied",
}
ETAPE.quete = trajetVersKal(ETAPE.cle)
ETAPE.aller = {
    { map = "*", path = "havenbag" },
    { map = "162791424", path = "zaap(164364304)" },
    { map = "-20,-20", path = "bottom" }, { map = "-20,-19", path = "bottom" }, { map = "-20,-18", path = "bottom" },
    { map = "-20,-17", path = "bottom" }, { map = "-20,-16", path = "bottom" },
    { map = "-20,-15", path = "left" }, { map = "-21,-15", path = "left" }, { map = "-22,-15", path = "left" },
    { map = "-23,-15", path = "left" }, { map = "-24,-15", path = "left" },
    { map = "-25,-15", path = "top" },
    { map = "-25,-16", path = "left" }, { map = "-26,-16", path = "left" }, { map = "-27,-16", path = "left" },
    { map = "-28,-16", path = "left" }, { map = "-29,-16", path = "left" }, { map = "-30,-16", path = "left" },
    { map = "-31,-16", path = "bottom" },
    { map = "-31,-15", path = "left" }, { map = "-32,-15", path = "left" }, { map = "-33,-15", path = "left" },
    { map = "167380484", custom = function() parler(1236, { -1, -1 }, { changeCarte = 5000 }) end },
    { map = "56623104",  custom = function() parler(1236, { -1, -1, -1 }, { changeCarte = 5000 }) end },
    { map = "56624128",  custom = function() parler(1236, { -1, -1 }, { changeCarte = 5000 }) end },
    { map = "56625152",  custom = function() parler(1236, { -1, -1, -1 }, { changeCarte = 5000 }) end },
    { map = "54175012",  custom = function()
        local function dialogueTexte(pnj)
            pcall(function() global:leaveDialog() end)
            pcall(function() npc:npc(pnj, 3) end)
            attendre(function() return signatureRepliques() ~= "" end, 3000, 100)
            for _ = 1, 8 do
                if signatureRepliques() == "" then break end
                local o, choix = optionsDuMenu() or {}, nil
                for k, t in pairs(o) do
                    if not t:find("retourner", 1, true) and not t:find("continent", 1, true) then
                        if choix == nil or k < -choix then choix = -k end
                    end
                end
                if choix == nil then break end
                local avant = signatureRepliques()
                pcall(function() npc:reply(choix) end)
                if not attendre(function() return signatureRepliques() ~= avant end, 2500, 100) then break end
            end
            pcall(function() global:leaveDialog() end)
        end
        if lireEtat("ARDIER_FAIT") ~= "1" then
            dire("Frigost : dialogue avec Ardier (1236) -> fin de « La terre banquise »")
            dialogueTexte(1236)
            ecrireEtat("ARDIER_FAIT", 1)
        end
        if lireEtat("HAKA_FAIT") ~= "1" then
            dire("Frigost : dialogue avec Haka (1264) -> « La maire de glace »")
            dialogueTexte(1264)
            ecrireEtat("HAKA_FAIT", 1)
        end
        pcall(function() map:changeMap("right") end)
    end },
    { map = "-80,-38", path = "right" }, { map = "-79,-38", path = "right" },
    { map = "-78,-38", path = "top" }, { map = "-78,-39", path = "top" }, { map = "-78,-40", path = "top" },
    { map = "-78,-41", path = "left" },
    { map = "-79,-41", path = "top" }, { map = "-79,-42", path = "top" },
    { map = "-79,-43", path = "left" }, { map = "-80,-43", path = "left" }, { map = "-81,-43", path = "left" },
    { map = "-82,-43", path = "left" }, { map = "-83,-43", path = "left" }, { map = "-84,-43", path = "left" },
    { map = "-85,-43", path = "top" }, { map = "-85,-44", path = "top" }, { map = "-85,-45", path = "top" },
    { map = "-85,-46", path = "top" },
    { map = "-85,-47", path = "right" },
    { map = "-84,-47", path = "top" }, { map = "-84,-48", path = "top" },
}
ETAPE.entree = {
    carte = "54176049",
    pnj = 1285,
    reponses = { -1, -1 },
}
ETAPE.donjon = {
    { map = "55050240", fight = true },
    { map = "55050242", fight = true },
    { map = "55052290", fight = true },
    { map = "55052288", fight = true },
    { map = "54175536", path = "179" },
    { map = "55053312", fight = true },
    { map = "55054336", barriere = true, custom = function()
        local ici = carte()
        if not equipeSortieComplete(ici) then return end
        parler(1285, { -1, -1 }, { changeCarte = 5000 })
    end },
}
ETAPES[#ETAPES + 1] = ETAPE

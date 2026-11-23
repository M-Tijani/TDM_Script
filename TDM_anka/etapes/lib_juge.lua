JUGE_CARTE_CHRIS = "142086659"
JUGE_PNJ_CHRIS = 815
function trajetVersChris(cle)
    return {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(147590153)" },
        { map = "-17,-47", path = "left" },
        { map = "-18,-47", path = "left" },
        { map = "-19,-47", path = "left" },
        { map = "-20,-47", path = "left" },
        { map = "-21,-47", path = "left" },
        { map = "-22,-47", path = "left" },
        { map = "-23,-47", path = "bottom" },
        { map = "-23,-46", path = "left" },
        { map = "-24,-46", path = "left" },
        { map = "-25,-46", path = "top" },
        { map = "-25,-47", path = "left" },
        { map = "-26,-47", path = "left" },
        { map = "-27,-47", path = "left" },
        { map = "-28,-47", path = "left" },
        { map = JUGE_CARTE_CHRIS, custom = function()
            parler(JUGE_PNJ_CHRIS, { -1 })
            ecrireEtat("QUETE_" .. cle, 1)
        end },
    }
end

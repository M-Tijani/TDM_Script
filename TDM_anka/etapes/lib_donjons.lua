DONJONS_CARTE_KAL = "172752904"
DONJONS_PNJ_KAL = 817
function trajetVersKal(cle, sansMarque)
    return {
        { map = "*", path = "havenbag" },
        { map = "162791424", path = "zaap(212861955)" },
        { map = "-26,37", path = "right" },
        { map = "-25,37", path = "top" },
        { map = "-25,36", path = "right" },
        { map = "-23,35", path = "right" },
        { map = "-22,35", path = "bottom" },
        { map = "-22,36", path = "right" },
        { map = "-21,36", path = "right" },
        { map = "-19,37", path = "right" },
        { map = "-18,37", path = "top" },
        { map = "-18,36", path = "top" },
        { map = "-18,35", path = "top" },
        { map = "-18,34", path = "top" },
        { map = "-18,33", path = "top" },
        { map = "-18,32", path = "top" },
        { map = "-18,31", path = "top" },
        { map = "-18,30", path = "left" },
        { map = DONJONS_CARTE_KAL, custom = function()
            parler(DONJONS_PNJ_KAL, { -1, -1 })
            if not sansMarque then ecrireEtat("QUETE_" .. cle, 1) end
        end },
    }
end

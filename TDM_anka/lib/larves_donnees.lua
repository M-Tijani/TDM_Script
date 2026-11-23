LARVES_D = {
    ENTREE = "96993793", SORTIE = "96998919", OEUF = 7423, CLEF = 7425,
    PORTE_ENTREE = 220, PORTE_FIN = 164, SUCCES = 34,
    RANG = {
        ["96993793"] = 1, ["96994817"] = 2, ["96995841"] = 3, ["96996865"] = 4,
        ["96997891"] = 5, ["96997889"] = 5, ["96998915"] = 6, ["96998913"] = 6,
        ["96993797"] = 7, ["96994821"] = 8, ["96995845"] = 9,
        ["96996871"] = 10, ["96996869"] = 10, ["96997895"] = 11, ["96997893"] = 11,
        ["96998917"] = 12, ["96998919"] = 13 },
    APPROCHE = { ["185862148"] = true, ["97255951"] = true, ["97256975"] = true, ["97257999"] = true,
        ["97260047"] = true, ["97261071"] = true, ["97255953"] = true, ["97256977"] = true,
        ["97258001"] = true, ["97259025"] = true },
    CARTE = {
        ["96994817"] = { sortie = { 257, 257 }, commune = true },
        ["96995841"] = { sortie = { 263, 159 }, commune = true, antichambre = 1, sansCombat = true },
        ["96996865"] = { levier = 1 },
        ["96997891"] = { sortie = { 455, nil } }, ["96998915"] = { sortie = { 395, nil } },
        ["96997889"] = { sortie = { nil, 525 } }, ["96998913"] = { sortie = { nil, 338 } },
        ["96993797"] = { sortie = { 227, 332 }, secours = { 227, 227 }, commune = true },
        ["96994821"] = { sortie = { 332, 227 }, commune = true, antichambre = 2 },
        ["96995845"] = { levier = 2 },
        ["96996871"] = { sortie = { 464, nil } }, ["96997895"] = { sortie = { 397, nil } },
        ["96996869"] = { sortie = { nil, 353 } }, ["96997893"] = { sortie = { nil, 466 } },
        ["96998917"] = { sortie = { 469, 469 }, commune = true, boss = true },
    },
    LEVIER = {
        [1] = { carte = "96996865", avant = "96995841",
            [1] = { porteAvant = 263, dalle = 438, levier = 425, sortie = 333, pas = 12,
                    anneau1 = { 347, 332, 361 }, anneau2 = { 318, 331, 346, 360, 375, 376, 389 } },
            [2] = { porteAvant = 159, dalle = 175, levier = 160, sortie = 199, pas = 5,
                    anneau1 = { 213, 200, 227 }, anneau2 = { 201, 214, 228, 240, 241, 255 } } },
        [2] = { carte = "96995845", avant = "96994821",
            [1] = { porteAvant = 332, dalle = 467, levier = 453, sortie = 305, pas = 12,
                    anneau1 = { 319, 304, 333 }, anneau2 = { 318, 332, 347, 348, 361 } },
            [2] = { porteAvant = 227, dalle = 148, levier = 133, sortie = 173, pas = 4,
                    anneau1 = { 187, 174, 201 }, anneau2 = { 175, 188, 202, 215, 229 } } },
    },
    MODES = { [1] = { "proche", "deux", "loin" }, [2] = { "deux", "loin", "proche" } },
    MOITIE_TXT = {
        ["96996865"] = {
            [1] = "303,318,331-332,345-347,357-361,372-373,375-376,387-390,400-405,413,415-416,418,428-432,438,441-445,452-459,466-472,481-483,485-487,494-496,499-500,508-511,513,515,522-526,536-539,550-553",
            [2] = "174-175,187-189,200-203,213-216,227-229,231,240-244,255-259,268-273,282-287,296-300,311-314" },
        ["96995845"] = {
            [1] = "304,317-319,330-333,344-348,357-362,372,374-376,385-389,401-403,412-416,426-430,440-443,454-457,467,469-470,482,484-485,498,513",
            [2] = "148,161-162,174-177,187-190,201-204,215-218,229-233,242-246,257-260,270-273,284-288,297-301,311-315,324-327,338-341,352-354,366-368,381" },
    },
}
function LARVES_D.dedans(c) return (LARVES_D.RANG[tostring(c)] or 0) >= 2 end
function LARVES_D.rang(c) return LARVES_D.RANG[tostring(c)] end
function LARVES_D.levierDe(c)
    c = tostring(c)
    for k, K in ipairs(LARVES_D.LEVIER) do
        if K.carte == c then return k, "salle" end
        if K.avant == c then return k, "avant" end
    end
    return nil, nil
end
function LARVES_D.moitieDe(carte, cell)
    carte = tostring(carte)
    LARVES_D.MOITIE = LARVES_D.MOITIE or {}
    local txt = LARVES_D.MOITIE_TXT[carte]
    if txt == nil then return nil end
    if LARVES_D.MOITIE[carte] == nil then
        local t = {}
        for h = 1, 2 do
            for a, b in txt[h]:gmatch("(%d+)%-?(%d*)") do
                for x = tonumber(a), tonumber(b ~= "" and b or a) do t[x] = h end
            end
        end
        LARVES_D.MOITIE[carte] = t
    end
    return LARVES_D.MOITIE[carte][tonumber(cell) or -1]
end

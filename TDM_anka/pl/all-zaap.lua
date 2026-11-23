FIGHT_KICK = 0
pcall(function() dofile(global:getCurrentScriptDirectory() .. "/../lib/deblocage.lua") end)
ETAPE = 1
OPTION = 1
EN_ROUTE_ASTRUB = true
ID_BOT_BANQUE = 0
function tournee()
    if ETAPE == 1 and EN_ROUTE_ASTRUB then
        local m = tostring(map:currentMapId())
        if m == "192415750" then return { { map = m, path = "424" } } end
        if m == "198972418" then
            return { { map = m, custom = function() pcall(function() npc:npc(789, 3) end); pcall(function() npc:reply(-1) end) end } }
        end
        if m == "198968320" or m == "198969344" or m == "198970368" or m == "198971392" or m == "198972416" then
            return { { map = m, custom = function()
                pcall(function() developer:sendMessage(developer:createMessageFromJson("kgy", '{"fzcf":false}')) end)
                global:delay(1500)
            end } }
        end
        if m == "162791424" then return { { map = m, path = "zaap(191105026)" } } end
        local zone = ""
        pcall(function() zone = tostring(map:currentArea()) end)
        if zone ~= "Astrub" and zone ~= "Cité d'Astrub" and not map:onMap("5,-19") and not map:onMap("5,-18") then
            return { { map = m, path = "havenbag" } }
        end
        if map:onMap("5,-19") or map:onMap("5,-18") then EN_ROUTE_ASTRUB = false
        else return { { map = m, custom = function() pcall(function() map:moveToward(5, -19) end) end } } end
    end
    if ETAPE == 0 then
        if OPTION == 1 then
            if character:kamas() < 1000 then
                return{
                    { map = "153092354", door = "409" },
                    { map = "152044547", path = "right" },
                    { map = "152043521", path = "right" },
                    { map = "152045573", path = "right" },
                    { map = "152046593", path = "right" },
                    { map = "152046599", path = "right" },
                    { map = "152044553", path = "right" },
                    { map = "152043523", path = "right" },
                    { map = "152046595", path = "right" },
                    { map = "152044545", path = "right" },
                    { map = "152045575", path = "right" },
                    { map = "152045571", path = "right" },
                    { map = "152043529", path = "right" },
                    { map = "152043527", path = "right" },
                    { map = "152043525", path = "right" },
                    { map = "152045569", path = "right" },
                    { map = "152046597", path = "right" },
                    { map = "152044549", path = "right" },
                    { map = "152044551", path = "right" },
                    { map = "154010883", path = "top" },
                    { map = "-2,-4", path = "right|top", fight = true },
                    { map = "-2,-5", path = "left|right|top|bottom", fight = true },
                    { map = "-3,-5", path = "right|top", fight = true },
                    { map = "-3,-6", path = "right|bottom", fight = true },
                    { map = "-2,-6", path = "right|left|bottom", fight = true },
                    { map = "-1,-6", path = "left|bottom", fight = true },
                    { map = "-1,-5", path = "right|top|left|bottom", fight = false },
                    { map = "-1,-4", path = "top|left", fight = true },
                    { map = "0,-4", path = "top|left", fight = true },
                    { map = "0,-5", path = "left|bottom", fight = true },
                }
            elseif character:kamas() >= 1000 then
                return{
                    { map = "153092354", door = "409" },
                    { map = "152044547", path = "right" },
                    { map = "152043521", path = "right" },
                    { map = "152045573", path = "right" },
                    { map = "152046593", path = "right" },
                    { map = "152046599", path = "right" },
                    { map = "152044553", path = "right" },
                    { map = "152043523", path = "right" },
                    { map = "152046595", path = "right" },
                    { map = "152044545", path = "right" },
                    { map = "152045575", path = "right" },
                    { map = "152045571", path = "right" },
                    { map = "152043529", path = "right" },
                    { map = "152043527", path = "right" },
                    { map = "152043525", path = "right" },
                    { map = "152045569", path = "right" },
                    { map = "152046597", path = "right" },
                    { map = "152044549", path = "right" },
                    { map = "152044551", path = "right" },
                    { map = "0,-4", path = "bottom"},
                    { map = "-3,-5", path = "right"},
                    { map = "-3,-6", path = "right"},
                    { map = "-2,-5", path = "bottom"},
                    { map = "-2,-6", path = "bottom"},
                    { map = "-1,-6", path = "bottom"},
                    { map = "-1,-5", path = "bottom"},
                    { map = "0,-5", path = "bottom"},
                    { map = "-1,-4", path = "bottom"},
                    { map = "-2,-4", path = "right"},
                    { map = "154010883", path = "right", custom = increment },
                }
            end
        elseif OPTION == 2 then
            return{
                { map = "153092354", door = "409" },
                { map = "152044547", path = "right" },
                { map = "152043521", path = "right" },
                { map = "152045573", path = "right" },
                { map = "152046593", path = "right" },
                { map = "152046599", path = "right" },
                { map = "152044553", path = "right" },
                { map = "152043523", path = "right" },
                { map = "152046595", path = "right" },
                { map = "152044545", path = "right" },
                { map = "152045575", path = "right" },
                { map = "152045571", path = "right" },
                { map = "152043529", path = "right" },
                { map = "152043527", path = "right" },
                { map = "152043525", path = "right" },
                { map = "152045569", path = "right" },
                { map = "152046597", path = "right" },
                { map = "152044549", path = "right" },
                { map = "152044551", path = "right" },
                { map = "0,-4", path = "bottom"},
                { map = "-3,-5", path = "right"},
                { map = "-3,-6", path = "right"},
                { map = "-2,-5", path = "bottom"},
                { map = "-2,-6", path = "bottom"},
                { map = "-1,-6", path = "bottom"},
                { map = "-1,-5", path = "bottom"},
                { map = "0,-5", path = "bottom"},
                { map = "-1,-4", path = "bottom"},
                { map = "-2,-4", path = "right"},
                { map = "154010883", path = "right", custom = increment },
            }
        elseif OPTION == 3 then
            return{
                { map = "153092354", door = "409" },
                { map = "152044547", path = "right" },
                { map = "152043521", path = "right" },
                { map = "152045573", path = "right" },
                { map = "152046593", path = "right" },
                { map = "152046599", path = "right" },
                { map = "152044553", path = "right" },
                { map = "152043523", path = "right" },
                { map = "152046595", path = "right" },
                { map = "152044545", path = "right" },
                { map = "152045575", path = "right" },
                { map = "152045571", path = "right" },
                { map = "152043529", path = "right" },
                { map = "152043527", path = "right" },
                { map = "152043525", path = "right" },
                { map = "152045569", path = "right" },
                { map = "152046597", path = "right" },
                { map = "152044549", path = "right" },
                { map = "152044551", path = "right" },
                { map = "0,-4", path = "bottom"},
                { map = "-3,-5", path = "right"},
                { map = "-3,-6", path = "right"},
                { map = "-2,-5", path = "bottom"},
                { map = "-2,-6", path = "bottom"},
                { map = "-1,-6", path = "bottom"},
                { map = "-1,-5", path = "bottom"},
                { map = "0,-5", path = "bottom"},
                { map = "-1,-4", path = "bottom"},
                { map = "-2,-4", path = "right"},
                { map = "154010883", path = "right"},
                { map = "-1,-3", path = "right" },
                { map = "0,-3", path = "right" },
                { map = "1,-3", path = "right" },
                { map = "2,-3", path = "right" },
                { map = "3,-3", path = "right" },
                { map = "4,-3", custom = pnjastrub },
                { map = "192416776", custom = arrive_astrub },
                { map = "191106048", path = "left" },
                { map = "5,-19", path = "bottom" },
                { map = "5,-18", path = "left" },
                { map = "191104002", door = "288" },
                { map = "192415750", custom = recuperation_kamas },
            }
        end
    elseif ETAPE == 1 then
       return {
        { map = "-1,-3", path = "right" },
        { map = "0,-3", path = "right" },
        { map = "1,-3", path = "right" },
        { map = "2,-3", path = "right" },
        { map = "3,-3", path = "right" },
        { map = "4,-3", custom = pnjastrub },
        { map = "192416776", custom = arrive_astrub },
        { map = "191106048", path = "left" },
        { map = "5,-19", path = "bottom" },
        { map = "5,-18", path = "left" },
        { map = "4,-18", path = "left" },
        { map = "3,-18", path = "left" },
        { map = "2,-18", path = "left" },
        { map = "1,-18", path = "left" },
        { map = "0,-18", path = "left" },
        { map = "-1,-18", path = "left" },
        { map = "-2,-18", path = "left" },
        { map = "-3,-18", path = "left" },
        { map = "-4,-18", path = "left" },
        { map = "-5,-18", path = "top" },
        { map = "-5,-19", path = "top" },
        { map = "-5,-20", path = "top" },
        { map = "-5,-21", path = "top" },
        { map = "-5,-22", custom = increment, path = "top" },
       }
    elseif ETAPE == 2 then
       return {
        { map = "-5,-23", path = "top" },
        { map = "-5,-24", path = "top" },
        { map = "-5,-25", path = "top" },
        { map = "-5,-26", path = "top" },
        { map = "-5,-27", path = "top" },
        { map = "-5,-28", path = "top" },
        { map = "-5,-29", path = "right" },
        { map = "-4,-29", path = "right" },
        { map = "-3,-29", path = "right" },
        { map = "-2,-29", path = "right" },
        { map = "-1,-29", path = "right" },
        { map = "0,-29", path = "right" },
        { map = "1,-29", path = "top" },
        { map = "1,-30", path = "top" },
        { map = "1,-31", custom = increment, path = "top" },
       }
    elseif ETAPE == 3 then
       return {
        { map = "1,-32", path = "bottom" },
        { map = "1,-31", path = "bottom" },
        { map = "1,-30", path = "bottom" },
        { map = "1,-29", path = "left" },
        { map = "0,-29", path = "left" },
        { map = "-1,-29", path = "left" },
        { map = "-2,-29", path = "left" },
        { map = "-3,-29", path = "top" },
        { map = "-3,-30", path = "top" },
        { map = "-3,-31", path = "top" },
        { map = "-3,-32", path = "top" },
        { map = "-3,-33", path = "top" },
        { map = "-3,-34", path = "top" },
        { map = "-3,-35", path = "top" },
        { map = "-3,-36", path = "top" },
        { map = "-3,-37", path = "top" },
        { map = "-3,-38", path = "top" },
        { map = "-3,-39", path = "top" },
        { map = "-3,-40", path = "top" },
        { map = "-3,-41", custom = increment, path = "top" },
       }
    elseif ETAPE == 4 then
       return {
        { map = "-3,-42", path = "top" },
        { map = "-3,-43", path = "top" },
        { map = "-3,-44", path = "top" },
        { map = "-3,-45", path = "top" },
        { map = "-3,-46", path = "top" },
        { map = "-3,-47", path = "left" },
        { map = "-4,-47", path = "left" },
        { map = "-5,-47", path = "left" },
        { map = "-6,-47", path = "left" },
        { map = "-7,-47", path = "left" },
        { map = "-8,-47", path = "left" },
        { map = "-9,-47", path = "left" },
        { map = "-10,-47", path = "left" },
        { map = "-11,-47", path = "left" },
        { map = "-12,-47", path = "left" },
        { map = "-13,-47", path = "left" },
        { map = "-14,-47", path = "left" },
        { map = "-15,-47", path = "left" },
        { map = "-16,-47", custom = increment, path = "left" },
       }
    elseif ETAPE == 5 then
       return {
        { map = "-17,-47", path = "left" },
        { map = "-18,-47", path = "left" },
        { map = "-19,-47", path = "left" },
        { map = "-20,-47", path = "left" },
        { map = "-21,-47", path = "left" },
        { map = "-22,-47", path = "left" },
        { map = "-23,-47", path = "bottom" },
        { map = "-23,-46", path = "left" },
        { map = "-24,-46", path = "top" },
        { map = "-24,-47", path = "left" },
        { map = "-25,-47", path = "top" },
        { map = "-25,-48", path = "top" },
       { map = "159649808", path = "left(168)", done = false },
       { map = "212603916", path = "left(126)", done = false },
       { map = "212603914", path = "left(140)", done = false },
       { map = "212602890", path = "left(196)", done = false },
       { map = "212602376", path = "left(196)", done = false },
       { map = "212601864", path = "top(8)", done = false },
       { map = "212601350", path = "top(4)", done = false },
       { map = "212601349", path = "top(2)", done = false },
       { map = "212601348", door = "437", done = false },
    { map = "-31,-56", custom = increment, path = "bottom" },
       }
    elseif ETAPE == 6 then
       return {
       { map = "212600837", path = "right(419)", done = false },
       { map = "212601349", path = "bottom(550)", done = false },
       { map = "212601350", path = "bottom(542)", done = false },
       { map = "212601864", path = "right", done = false },
       { map = "212602376", path = "bottom", done = false },
       { map = "212602890", path = "bottom", done = false },
       { map = "212603914", path = "right", done = false },
       { map = "212603916", path = "right", done = false },
       { map = "159649808", path = "bottom(541)", done = false },
       { map = "159649809", path = "bottom(555)", done = false },
       { map = "142088707", path = "bottom(539)", done = false },
       { map = "142088708", path = "bottom(539)", done = false },
       { map = "142088709", path = "bottom(539)", done = false },
       { map = "142088710", path = "bottom(539)", done = false },
       { map = "142088711", path = "left(308)", done = false },
       { map = "142088199", path = "bottom(554)", done = false },
       { map = "142088200", path = "bottom(554)", done = false },
       { map = "142088201", path = "bottom(552)", done = false },
       { map = "142088202", path = "bottom(554)", done = false },
       { map = "142088203", path = "bottom(540)", done = false },
       { map = "142088204", path = "bottom(540)", done = false },
       { map = "142088205", path = "bottom(555)", done = false },
       { map = "142088206", custom = increment,  path = "left(112)"},
       }
    elseif ETAPE == 7 then
       return {
        { map = "-27,-36", path = "right" },
        { map = "-26,-36", path = "right" },
        { map = "-25,-36", path = "right" },
        { map = "-24,-36", path = "right" },
        { map = "-23,-36", path = "right" },
        { map = "-22,-36", path = "right" },
        { map = "-21,-36", path = "right" },
        { map = "-20,-36", path = "bottom" },
        { map = "-20,-35", path = "bottom" },
        { map = "-20,-34", path = "bottom" },
        { map = "-20,-33", path = "bottom" },
        { map = "-20,-32", path = "bottom" },
        { map = "-20,-31", path = "bottom" },
        { map = "-20,-30", path = "bottom" },
        { map = "-20,-29", path = "bottom" },
        { map = "-20,-28", path = "bottom" },
        { map = "-20,-27", path = "bottom" },
        { map = "-20,-26", path = "bottom" },
        { map = "-20,-25", path = "bottom" },
        { map = "-20,-24", path = "bottom" },
        { map = "-20,-23", path = "bottom" },
        { map = "-20,-22", path = "bottom" },
        { map = "-20,-21", custom = increment, path = "bottom" },
       }
    elseif ETAPE == 8 then
       return {
        { map = "-20,-20", path = "right" },
        { map = "-19,-20", path = "right" },
        { map = "-18,-20", path = "right" },
        { map = "-17,-20", path = "right" },
        { map = "-16,-20", path = "right" },
        { map = "-15,-20", path = "right" },
        { map = "-14,-20", path = "right" },
        { map = "-13,-20", path = "top" },
        { map = "-13,-21", path = "top" },
        { map = "-13,-22", path = "top" },
        { map = "-13,-23", path = "top" },
        { map = "-13,-24", path = "top" },
        { map = "-13,-25", path = "top" },
        { map = "-13,-26", path = "top" },
        { map = "-13,-27", custom = increment, path = "top" },
       }
    elseif ETAPE == 9 then
       return {
        { map = "-13,-28", path = "bottom" },
        { map = "-13,-27", path = "bottom" },
        { map = "-13,-26", path = "bottom" },
        { map = "-13,-25", path = "bottom" },
        { map = "-13,-24", path = "bottom" },
        { map = "-13,-23", path = "bottom" },
        { map = "-13,-22", path = "bottom" },
        { map = "-13,-21", path = "bottom" },
        { map = "-13,-20", path = "left" },
        { map = "-14,-20", path = "left" },
        { map = "-15,-20", path = "left" },
        { map = "-16,-20", path = "left" },
        { map = "-17,-20", path = "left" },
        { map = "-18,-20", path = "left" },
        { map = "-19,-20", path = "left" },
        { map = "-20,-20", path = "right" },
        { map = "-19,-20", path = "right" },
        { map = "-18,-20", path = "right" },
        { map = "-17,-20", path = "right" },
        { map = "-16,-20", path = "bottom" },
        { map = "-16,-19", path = "bottom" },
        { map = "-16,-18", path = "bottom" },
        { map = "-16,-17", path = "bottom" },
        { map = "-16,-16", path = "bottom" },
        { map = "-16,-15", path = "bottom" },
        { map = "-16,-14", path = "bottom" },
        { map = "-16,-13", path = "bottom" },
        { map = "-16,-12", path = "bottom" },
        { map = "-16,-11", path = "bottom" },
        { map = "-16,-10", path = "right" },
        { map = "-15,-10", path = "right" },
        { map = "-14,-10", path = "right" },
        { map = "-13,-10", path = "bottom" },
        { map = "-13,-9", path = "bottom" },
        { map = "-13,-8", path = "bottom" },
        { map = "-13,-7", path = "bottom" },
        { map = "-13,-6", path = "bottom" },
        { map = "-13,-5", path = "bottom" },
        { map = "-13,-4", path = "bottom" },
        { map = "-13,-3", path = "bottom" },
        { map = "-13,-2", path = "bottom" },
        { map = "-13,-1", path = "bottom" },
        { map = "-13,0", path = "bottom" },
        { map = "-13,1", path = "left" },
        { map = "-14,1", path = "left" },
        { map = "-15,1", custom = increment, path = "left" },
       }
    elseif ETAPE == 10 then
       return {
        { map = "-16,1", path = "top" },
        { map = "-16,0", path = "left" },
        { map = "-17,0", path = "left" },
        { map = "-18,0", path = "left" },
        { map = "-19,0", path = "top" },
        { map = "-19,-1", path = "left" },
        { map = "-20,-1", path = "bottom" },
        { map = "-20,0", path = "left" },
        { map = "-21,0", path = "left" },
        { map = "-22,0", path = "top" },
        { map = "-22,-1", path = "left" },
        { map = "-23,-1", path = "left" },
        { map = "-24,-1", path = "left(280)" },
        { map = "-25,-1", path = "bottom" },
        { map = "-25,0", path = "bottom" },
        { map = "-25,1", path = "bottom" },
        { map = "-25,2", path = "bottom" },
        { map = "-25,3", path = "bottom" },
        { map = "-25,4", path = "bottom" },
        { map = "-25,5", path = "bottom" },
        { map = "-25,6", path = "bottom" },
        { map = "-25,7", path = "bottom" },
        { map = "-25,8", path = "bottom" },
        { map = "-25,9", path = "bottom" },
        { map = "-25,10", path = "bottom" },
        { map = "-25,11", custom = increment, path = "bottom" },
       }
    elseif ETAPE == 11 then
       return {
        { map = "-25,12", path = "right" },
        { map = "-24,12", path = "right" },
        { map = "-23,12", path = "right" },
        { map = "-22,12", path = "bottom" },
        { map = "-22,13", path = "right" },
        { map = "-21,13", path = "bottom" },
        { map = "-21,14", path = "bottom" },
        { map = "-21,15", path = "bottom" },
        { map = "-21,16", path = "bottom" },
        { map = "-21,17", path = "bottom" },
        { map = "-21,18", path = "bottom" },
        { map = "-21,19", path = "bottom" },
        { map = "-21,20", path = "bottom" },
        { map = "-21,21", path = "bottom" },
        { map = "-21,22", path = "bottom" },
        { map = "-21,23", path = "bottom" },
        { map = "-21,24", path = "bottom" },
        { map = "-21,25", path = "bottom" },
        { map = "-21,26", path = "bottom" },
        { map = "-21,27", path = "bottom" },
        { map = "-21,28", path = "bottom" },
        { map = "-21,29", path = "left" },
        { map = "-22,29", path = "left" },
        { map = "-23,29", path = "left" },
        { map = "-24,29", path = "bottom" },
        { map = "-24,30", path = "left" },
        { map = "-25,30", path = "bottom" },
        { map = "-26,31", path = "bottom" },
        { map = "-26,32", path = "bottom" },
        { map = "-26,33", path = "bottom" },
        { map = "-26,34", path = "bottom" },
        { map = "-26,35", path = "bottom"},
        { map = "-26,36", custom = increment, path = "bottom" },
       }
    elseif ETAPE == 12 then
       return {
        { map = "212861955", path = "top(2)", done = false },
        { map = "-26,36", path = "left", done = false },
        { map = "-27,36", path = "top", done = false },
        { map = "-27,35", path = "left", done = false },
        { map = "212860930", path = "top(5)", done = false },
        { map = "212860929", path = "top(22)", done = false },
        { map = "212860928", path = "top(22)", done = false },
        { map = "212861185", path = "right(475)", done = false },
        { map = "212861697", path = "right(167)", done = false },
        { map = "212862209", path = "top(7)", done = false },
        { map = "212862210", path = "right(251)", done = false },
        { map = "172232193", path = "right(307)", done = false },
        { map = "172232705", path = "right(223)", done = false },
        { map = "172233217", path = "right(251)", done = false },
        { map = "172233729", path = "right(167)", done = false },
        { map = "172234241", path = "right(153)", done = false },
        { map = "172234753", path = "top(24)", done = false },
        { map = "172234752", path = "right(363)", done = false },
        { map = "172752903", path = "right(433)", done = false },
        { map = "172753415", path = "bottom(555)", done = false },
        { map = "172753416", path = "right(195)", done = false },
        { map = "172753928", path = "right(419)", done = false },
        { map = "172754440", path = "right(195)", done = false },
        { map = "172754952", path = "top(20)", done = false },
        { map = "172754951", path = "top(20)", done = false },
        { map = "172754950", path = "left(140)", done = false },
        { map = "-16,28", door = "332" },
        { map = "-16,29", path = "left" },
        { map = "-17,29", door = "11" },
        { map = "-17,28", path = "top" },
        { map = "-17,27", path = "right" },
        { map = "-16,27", path = "top" },
        { map = "-16,26", path = "right" },
        { map = "-15,26", custom = increment, door = "187" },
       }
    elseif ETAPE == 13 then
       return {
        { map = "-15,25", path = "left" },
        { map = "-16,25", path = "bottom" },
        { map = "-16,26", path = "bottom" },
        { map = "-16,27", path = "left" },
        { map = "-17,27", path = "bottom" },
        { map = "-17,28", path = "left(532)" },
        { map = "-17,29", path = "right" },
        { map = "-16,29", door = "147" },
        { map = "-16,28", path = "right" },
        { map = "-15,28", path = "right" },
        { map = "-14,28", path = "right" },
        { map = "-13,28", path = "right" },
        { map = "-12,28", path = "right" },
        { map = "-11,28", path = "right" },
        { map = "-10,28", path = "right" },
        { map = "-9,28", path = "top" },
        { map = "-9,27", path = "top" },
        { map = "-9,26", path = "right" },
        { map = "-8,26", door = "530" },
        { map = "-7,26", path = "right" },
        { map = "-6,26", path = "right" },
        { map = "-5,26", path = "right" },
        { map = "-4,26", path = "right" },
        { map = "-3,26", path = "right" },
        { map = "-2,26", path = "top" },
        { map = "-2,25", path = "top" },
        { map = "-2,24", custom = increment, path = "right" },
       }
    elseif ETAPE == 14 then
       return {
        { map = "-1,24", path = "right" },
        { map = "0,24", path = "right" },
        { map = "1,24", path = "right" },
        { map = "2,24", path = "right" },
        { map = "3,24", path = "right" },
        { map = "4,24", path = "top" },
        { map = "4,23", path = "top" },
        { map = "4,22", path = "right" },
        { map = "5,22", path = "right" },
        { map = "6,22", path = "right" },
        { map = "7,22", path = "right" },
        { map = "8,22", path = "right" },
        { map = "9,22", custom = increment, path = "right" },
       }
    elseif ETAPE == 15 then
       return {
        { map = "10,22", path = "right" },
        { map = "11,22", path = "right" },
        { map = "12,22", path = "right" },
        { map = "13,22", path = "right" },
        { map = "14,22", path = "right" },
        { map = "15,22", path = "right" },
        { map = "16,22", path = "bottom" },
        { map = "16,23", path = "left" },
        { map = "15,23", path = "bottom" },
        { map = "15,24", path = "bottom" },
        { map = "15,25", path = "left" },
        { map = "14,25", path = "left" },
        { map = "13,25", path = "bottom", custom = increment },
       }
    elseif ETAPE == 16 then
       return {
        { map = "13,26", path = "right" },
        { map = "14,26", path = "right" },
        { map = "15,26", path = "right" },
        { map = "16,26", path = "bottom" },
        { map = "16,27", path = "right" },
        { map = "17,27", path = "bottom" },
        { map = "17,28", path = "left" },
        { map = "16,28", path = "bottom" },
        { map = "16,29", door = "355" },
        { map = "115081729", path = "left" },
        { map = "115082753", custom = increment, path = "143" },
       }
    elseif ETAPE == 17 then
       return {
        { map = "115083777", path = "475" },
        { map = "115082753", path = "right" },
        { map = "115081729", door = "289" },
        { map = "16,29", path = "top" },
        { map = "16,28", path = "right" },
        { map = "17,28", path = "top" },
        { map = "17,27", path = "left" },
        { map = "16,27", path = "top" },
        { map = "16,26", path = "top" },
        { map = "16,25", path = "left" },
        { map = "15,25", path = "top" },
        { map = "16,24", path = "left" },
        { map = "15,24", path = "top" },
        { map = "15,23", path = "right" },
        { map = "16,23", path = "top" },
        { map = "16,22", path = "left" },
        { map = "15,22", path = "left" },
        { map = "14,22", path = "left" },
        { map = "13,22", path = "left" },
        { map = "12,22", path = "left" },
        { map = "11,22", path = "left" },
        { map = "10,22", path = "left" },
        { map = "9,22", path = "left" },
        { map = "8,22", path = "left" },
        { map = "7,22", path = "left" },
        { map = "6,22", path = "left" },
        { map = "5,22", path = "left" },
        { map = "4,22", path = "left" },
        { map = "3,22", path = "left" },
        { map = "2,22", path = "left" },
        { map = "1,22", path = "top" },
        { map = "1,21", path = "top" },
        { map = "1,20", path = "top" },
        { map = "1,19", path = "top" },
        { map = "1,18", path = "top" },
        { map = "1,17", path = "top" },
        { map = "1,16", path = "top" },
        { map = "1,15", path = "top" },
        { map = "1,14", path = "top" },
        { map = "1,13", path = "left" },
        { map = "0,13", custom = increment, path = "left" },
       }
    elseif ETAPE == 18 then
       return {
        { map = "-1,13", path = "right" },
        { map = "0,13", path = "right" },
        { map = "1,13", path = "right" },
        { map = "2,13", path = "right" },
        { map = "3,13", path = "right" },
        { map = "4,13", path = "right" },
        { map = "5,13", path = "top" },
        { map = "5,12", path = "top" },
        { map = "5,11", path = "top" },
        { map = "5,10", path = "top" },
        { map = "5,9", path = "top" },
        { map = "5,8", custom = increment, path = "top" },
       }
    elseif ETAPE == 19 then
       return {
        { map = "5,7", path = "top" },
        { map = "5,6", path = "top" },
        { map = "5,5", path = "top" },
        { map = "5,4", path = "top" },
        { map = "5,3", path = "top" },
        { map = "5,2", path = "top" },
        { map = "5,1", path = "top" },
        { map = "5,0", path = "top" },
        { map = "5,-1", path = "top" },
        { map = "5,-2", path = "top" },
        { map = "5,-3", path = "right" },
        { map = "6,-3", path = "right" },
        { map = "7,-3", custom = increment, path = "top" },
       }
    elseif ETAPE == 20 then
       return {
        { map = "7,-4", path = "top" },
        { map = "7,-5", path = "right" },
        { map = "8,-5", path = "top" },
        { map = "8,-6", path = "left" },
        { map = "7,-6", path = "left" },
        { map = "6,-6", path = "left" },
        { map = "5,-6", path = "left" },
        { map = "4,-6", path = "left" },
        { map = "3,-6", custom = increment, path = "bottom" },
       }
    elseif ETAPE == 21 then
       return {
        { map = "3,-5", path = "right" },
        { map = "4,-5", path = "top" },
        { map = "4,-6", path = "top" },
        { map = "4,-7", path = "top" },
        { map = "4,-8", path = "left" },
        { map = "4,-9", path = "left" },
        { map = "3,-9", path = "left" },
        { map = "2,-9", path = "left" },
        { map = "1,-9", path = "left" },
        { map = "0,-9", path = "left" },
        { map = "-1,-9", path = "top" },
        { map = "-1,-10", path = "left" },
        { map = "-2,-10", path = "bottom" },
        { map = "-2,-9", path = "left" },
        { map = "-3,-9", path = "left" },
        { map = "-4,-9", path = "left" },
        { map = "-5,-9", custom = increment, path = "bottom" },
       }
    elseif ETAPE == 22 then
       return {
        { map = "-5,-8", path = "top" },
        { map = "-5,-9", path = "left" },
        { map = "-6,-9", path = "bottom" },
        { map = "-6,-8", path = "bottom" },
        { map = "-6,-7", path = "right" },
        { map = "-5,-7", path = "right" },
        { map = "-4,-7", path = "bottom" },
        { map = "-4,-6", path = "right(55)" },
        { map = "-3,-6", path = "right" },
        { map = "-2,-6", path = "bottom" },
        { map = "-2,-5", path = "right" },
        { map = "-1,-5", path = "right" },
        { map = "0,-5", path = "bottom" },
        { map = "0,-4", path = "bottom" },
        { map = "0,-3", path = "bottom" },
        { map = "0,-2", path = "bottom" },
        { map = "0,-1", path = "bottom" },
        { map = "0,0", path = "left" },
        { map = "-1,0", custom = increment, path = "left" },
       }
    elseif ETAPE == 23 then
       return {
        { map = "-2,0", path = "right" },
        { map = "-1,0", path = "right" },
        { map = "0,0", path = "right" },
        { map = "1,0", path = "right" },
        { map = "2,0", path = "right" },
        { map = "3,0", path = "right" },
        { map = "4,0", path = "right" },
        { map = "5,0", path = "right" },
        { map = "6,0", path = "right" },
        { map = "7,0", path = "top" },
        { map = "7,-1", path = "top" },
        { map = "7,-2", path = "top" },
        { map = "7,-3", path = "right" },
        { map = "8,-3", path = "right" },
        { map = "9,-3", path = "bottom" },
        { map = "9,-2", custom = bateau1 },
        { map = "24,-2", path = "top" },
        { map = "24,-3", path = "top" },
        { map = "24,-4", custom = final, path = "right" },
       }
    elseif ETAPE == 24 then
       return {
        { map = "25,-4", path = "left" },
        { map = "24,-4", path = "bottom" },
        { map = "24,-3", path = "bottom" },
        { map = "24,-2", custom = bateau2 },
        { map = "9,-2", path = "top" },
        { map = "9,-3", path = "top" },
        { map = "9,-4", path = "top" },
        { map = "9,-5", path = "right" },
        { map = "10,-5", path = "right" },
        { map = "11,-5", path = "top" },
        { map = "11,-6", path = "right" },
        { map = "12,-6", custom = bateau3 },
        { map = "14,-55", path = "top" },
        { map = "14,-56", path = "top" },
        { map = "14,-57", path = "right" },
        { map = "15,-57", custom = final, path = "top" },
       }
    end
end
function increment()
    ETAPE = ETAPE + 1
    sauverReprise()
    global:printSuccess("ETAPE "..ETAPE.." !")
end
function recuperation_kamas()
    increment()
    while character:kamas() < 1000 do
        exchange:launchExchangeWithPlayer(ID_BOT_BANQUE)
        if exchange:launchExchangeWithPlayer(ID_BOT_BANQUE) == true then
            global:delay(10000)
            exchange:ready()
            map:moveToCell(424)
        end
    end
end
function pnjastrub()
    npc:npc(4398, 3)
    npc:reply(-1)
    npc:reply(-1)
end
function sauverReprise()
    pcall(function()
        os.execute('mkdir "' .. global:getCurrentScriptDirectory() .. '/../etat" 2>nul')
        local f = io.open(fichierReprise(), "w")
        if f then f:write(tostring(ETAPE) .. ";" .. tostring(map:currentMapId())) f:close() end
    end)
end
function fichierReprise()
    return global:getCurrentScriptDirectory() .. "/../etat/zaap_etape_" .. tostring(character:id()) .. ".txt"
end
function bateau1()
    final()
end
function final()
    global:printSuccess("[ZAAP] ALL ZAAP TERMINE")
    pcall(function()
        local id = tostring(character:id())
        local dossier = global:getCurrentScriptDirectory() .. "\\..\\etat"
        os.execute('mkdir "' .. dossier .. '" 2>nul')
        local f = io.open(dossier .. "\\zaap_" .. id .. ".txt", "w")
        if f then f:write("ZAAP=1\n") f:close() end
        local compte = tostring(global:thisAccountController():getUsername())
        local g = io.open(dossier .. "\\zaap_compte_" .. compte .. ".txt", "w")
        if g then g:write("ZAAP=1\n") g:close() end
        if developer:getInGlobalMemory("RS_ZAAP_FAIT_" .. id) == nil then developer:addInGlobalMemory("RS_ZAAP_FAIT_" .. id, "1")
        else developer:editInGlobalMemory("RS_ZAAP_FAIT_" .. id, "1") end
    end)
    global:finishScript()
end
function arrive_astrub()
    map:changeMap("bottom")
end
function bateau3()
    npc:npc(3464,3)
    npc:reply(-1)
end
function bateau2()
    npc:npc(136,3)
    npc:reply(-1)
end

REPRISE = nil
pcall(function()
    local f = io.open(fichierReprise(), "r")
    if f then
        local l = f:read("*l") or ""
        f:close()
        local e, m = l:match("^(%d+);(%d+)")
        if e then ETAPE = tonumber(e); REPRISE = tonumber(m); EN_ROUTE_ASTRUB = (ETAPE == 1) end
    end
end)
if ETAPE > 1 then global:printSuccess("[ZAAP] reprise a l etape " .. ETAPE .. " (carte " .. tostring(REPRISE) .. ")") end
function surLaListe(liste)
    for _, e in ipairs(liste or {}) do
        local ok, sur = pcall(function() return map:onMap(e.map) end)
        if ok and sur then return true end
        if tostring(e.map) == tostring(map:currentMapId()) then return true end
    end
    return false
end
function move()
    do local _b = nil; pcall(function() _b = surveillerBlocage() end); if _b then return _b end end
    local liste = tournee()
    if liste == nil or ETAPE <= 1 or surLaListe(liste) then return liste end
    local m = tonumber(map:currentMapId())
    local cible = REPRISE
    if cible == nil or m == cible then
        local x, y = tostring(liste[1].map):match("^(%-?%d+),(%-?%d+)$")
        return { { map = tostring(m), custom = function()
            if x then pcall(function() map:moveToward(tonumber(x), tonumber(y)) end)
            else pcall(function() map:moveToward(tonumber(liste[1].map)) end) end
        end } }
    end
    if m == 162791424 then
        return { { map = tostring(m), custom = function()
            local z = tonumber(map:closestZaapV2(cible)) or 0
            if z > 0 then pcall(function() map:toZaap(z, 3) end) else pcall(function() global:leaveDialog() end) end
        end } }
    end
    local d = 0
    pcall(function() d = tonumber(map:GetPathDistance(m, cible)) or 0 end)
    if d > 8 then return { { map = tostring(m), path = "havenbag" } } end
    return { { map = tostring(m), custom = function() pcall(function() map:moveToward(cible) end) end } }
end

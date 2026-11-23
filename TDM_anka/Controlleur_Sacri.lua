if DOSSIER == nil then
    pcall(function() DOSSIER = global:getCurrentScriptDirectory() end)
end
if charger == nil then
    function charger(rel, obligatoire)
        local base = DOSSIER or (global and global:getCurrentScriptDirectory()) or "."
        local path = tostring(base) .. "\\" .. tostring(rel)
        local ok, err = pcall(function() dofile(path) end)
        if not ok and obligatoire then
            pcall(function() global:printError("[CHARGER] " .. tostring(rel) .. " : " .. tostring(err)) end)
        end
        return ok
    end
end

DOSSIER = global:getCurrentScriptDirectory()
LOGIQUE = DOSSIER .. "\\controller\\logique.lua"
function phenix() return {} end
function move()
    if DEJA_LANCE then return end
    DEJA_LANCE = true
    global:printSuccess("[CTRL] === CONTROLLER RUN SACRI 8 (chargeur, logique rechargee a chaud) ===")
    local sig = nil
    while true do
        local s = "fixe"
        if s ~= sig then
            sig = s
            local ok, err = pcall(function() charger("controller\\logique.lua", true) end)
            global:printSuccess("[CTRL] logique " .. (ok and "chargee" or ("ERREUR : " .. tostring(err))))
        end
        local ok, err = pcall(function() cycle() end)
        if not ok then
            global:printSuccess("[CTRL] erreur de cycle : " .. tostring(err))
            global:delay(2000)
        end
    end
end
function bank() return {} end
function stopped() end
function signatureLogique()
    local f = io.open(LOGIQUE, "r")
    if f == nil then return "" end
    local s = f:read("*a")
    f:close()
    return tostring(#s) .. "|" .. s:sub(-300) .. "|" .. s:sub(1, 300)
end
function banned() end

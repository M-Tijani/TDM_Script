local ETAPE = {
    cle    = "corailleur",
    nom    = "Donjon du Corailleur Magistral",
    succes = { 62 },
    acces  = "pied",
}
ETAPE.quete = nil
ETAPE.aller = {
    { map = "162791424", path = "zaap(95422468)" },
    { map = "95420420", custom = function() parler(925, { -1, -1, -1 }, { changeCarte = 5000 }) end },
    { map = "26214400", custom = function() pcall(function() map:fight() end) end },
    { map = "26215424", custom = function() pcall(function() map:fight() end) end },
    { map = "26216448", custom = function() pcall(function() map:fight() end) end },
    { map = "26217472", custom = function() parler(925, { -1 }, { changeCarte = 5000 }) end },
    { map = "161295" },
}
ETAPE.entree = {
    carte = "161295",
    pnj = 941,
    reponses = { -1, -1 },
    reponsesTp = { -2 },
}
ETAPE.donjon = {
    { map = "5243139", fight = true },
    { map = "5244416", fight = true },
    { map = "5242883", fight = true },
    { map = "5244419", fight = true },
    { map = "5242886", fight = true },
    { map = "5244422", custom = function()
        parler(941, { -1 }, { changeCarte = 5000 })
    end },
}
ETAPE.apres = nil
ETAPES[#ETAPES + 1] = ETAPE

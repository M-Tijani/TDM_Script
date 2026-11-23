-- ============================================================
--  Settings.lua - RUN SACRI : VOS REGLAGES
--  Vous ne configurez QUE : le serveur, le compte banque, vos teams
--  (comptes) et votre stuff. Tout le reste est automatique.
--  ATTENTION : une faute de syntaxe fait ignorer le fichier.
-- ============================================================

-- Charge les reglages internes (NE PAS RETIRER cette ligne) :
pcall(function() dofile(global:getCurrentScriptDirectory() .. "\\Settings_defaut.lua") end)

-- ── A RENSEIGNER ─────────────────────────────────────────────────────────────
SERVEUR       = "NomDuServeur"                 -- nom EXACT du serveur de jeu
COMPTE_BANQUE = "compte-banque@exemple.com"    -- email du compte banque ("" = pas de compte banque)

-- ── VOS TEAMS ────────────────────────────────────────────────────────────────
-- Chaque team : le CHEF (1er) + ses mules, par email de compte AnkaBot.
-- Plusieurs teams possibles (elles tournent en parallele sur une instance).
--
 TEAMS = {
-  { chef = "chef1@mail.com", mules = { "mule2@mail.com", "mule3@mail.com", "mule4@mail.com",
                                        "mule5@mail.com", "mule6@mail.com", "mule7@mail.com", "mule8@mail.com" } },
  { chef = "chef2@mail.com", mules = { "muleB@mail.com", "muleC@mail.com" } },
 }

-- Laissez TEAMS = nil pour utiliser l'auto-detection (teams groupees dans AnkaBot).
TEAMS = nil

-- ── COULEURS DES PERSOS CREES (optionnel) ────────────────────────────────────
COULEURS_A_CREER = { "#7B241C", "#F5B7B1", "#CD6155", "#CD6155", "#922B21" }

-- ── VOTRE STUFF (kit remis aux mules / au leader) ────────────────────────────
KAMAS_MULE = 40000
KIT_SASA = {
    { gid = 732, q = 1 }, { gid = 835, q = 1 }, { gid = 712, q = 1 }, { gid = 2390, q = 1 },
    { gid = 1487, q = 1 }, { gid = 2532, q = 1 }, { gid = 7131, q = 1 }, { gid = 1665, q = 1 },
    { gid = 18667, q = 1 }, { gid = 972, q = 1 }, { gid = 34615, q = 1 },
    { gid = 8342, q = 80 },    -- clefs du Croca
}
-- stuff de run des mules (reste au sac pendant le PL, repris en fin de PL)
SET_RUN_MULE = { 8463, 8464, 8465, 8466, 8467, 8468, 250, 1499, 18687 }
-- coiffe et cape (mules / leader)
KIT_COIFFE_CAPE = { 8463, 8464 }
KIT_COIFFE_CAPE_LEADER = { 8847, 8265 }

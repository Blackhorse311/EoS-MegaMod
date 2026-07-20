_namespace = "FACTION"
_id = "SALTIS_MCERLANE" -- TODO -- RENAME TO THE_SALTIS_GANG

_includes = "GANG_BASE"
stringsKey = "$Factions_SaltisMcErlane"
playable = true

bossId = "CHARACTER.BOSS.SALTIS_BOSS"
missionBossId = "NPC.MISSION_SALTIS_MCERLANE_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.JOSEPH_SALTIS"
safehouseName = "$SaltisSafehouseName" --$ Saltis Gang's Safehouse

icon = "Sprites/Images/Characters/Profile/Cast/JosephSaltis_Profile"
factionIcon = "SaltisGang"
primaryColor = "SaltisMcErlane_Primary"
secondaryColor = "SaltisMcErlane_Secondary"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/JosephSaltis_Pose"

audio =
{
    onSelect = { "AUDIO.BOSSES.SALTIS.INTRO_1", "AUDIO.BOSSES.SALTIS.INTRO_2", "AUDIO.BOSSES.SALTIS.INTRO_3", "AUDIO.BOSSES.SALTIS.INTRO_4", "AUDIO.BOSSES.SALTIS.INTRO_5", },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_Hungarian_01", --$ Central Bazaar
    "$DepotName_Hungarian_02", --$ Hotel László
    "$DepotName_Hungarian_03", --$ Novák & Sons Abbatoir
    "$DepotName_Hungarian_04", --$ Malom Hús
    "$DepotName_Hungarian_05", --$ Pallai Place
    "$DepotName_Hungarian_06", --$ Miklós Library
    "$DepotName_Hungarian_07", --$ Bulga Tér
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]
sweetHomeChicagoEvent = "SaltisMcErlaneSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_Hungarian"

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "SALTIS_MCERLANE_FACTION_INFO"
_abstract = true
faction = "SALTIS_MCERLANE"

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

local roles = {
    -- "UNDERBOSS",
    -- "LIEUTENANT",
    "HIREDGUN",
    "CONARTIST",
    "ENFORCER",
    "DEMOLITIONIST",
    "DOCTOR",
}

---------------------------------------------
--             CONFIGURE START             --
---------------------------------------------
-- Ok, so the way this works is that the number for each variant acts as a ratio
-- So, if you have two variants with the value of 1, it will be a 50/50 split, or if you have one with value of 4 and another with 1, it will be 80/20
-- It is best if you use lowest possible number to get the ratio you want.  Ex: Two values of 1 will get same as two values of 5, but 5 may take more memory on your computer.
-- I may optimize this in future so the numbers will be reduced automatically if you make them too high.
-- You should make at least one of these for each role be non-zero, or it might explode.
local variant_weights = {
    ["HIREDGUN"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 0,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["CONARTIST"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 0,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["ENFORCER"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 0,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["DEMOLITIONIST"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 0,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["DOCTOR"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 0,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
}
---------------------------------------------
--             CONFIGURE END               --
---------------------------------------------

-- Some corrective logic to avoid errors
for j = 1,5,1 do
    variant_weights[roles[j]][1] = variant_weights[roles[j]][1] + variant_weights[roles[j]][0]
    variant_weights[roles[j]][0] = 0
end

-- Add up total weights so we know how many variants we have
local variant_total_weights = { -- Each starts at -1 to offset the hidden variant 0
    ["HIREDGUN"] = -1,
    ["CONARTIST"] = -1,
    ["ENFORCER"] = -1,
    ["DEMOLITIONIST"] = -1,
    ["DOCTOR"] = -1,
}
for j = 1,5,1 do
    for i = 0,8,1 do variant_total_weights[roles[j]] = variant_total_weights[roles[j]] + variant_weights[roles[j]][i] end
    -- print(roles[j] .. ": " .. variant_total_weights[roles[j]])
end

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_MELEE"
telemetryId = "SALT1"
name = "$NPC_SALTIS_MCERLANE_WEAK_MELEE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_1", -- Character Variant Data
    "SALTIS_MCERLANE_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Average Melee
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_MELEE"
telemetryId = "SALT2"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_MELEE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Strong Melee
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_MELEE"
telemetryId = "SALT3"
name = "$NPC_SALTIS_MCERLANE_STRONG_MELEE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Elite Melee
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_MELEE"
telemetryId = "SALT4"
name = "$NPC_SALTIS_MCERLANE_ELITE_MELEE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_MELEE"
telemetryId = "SALT5"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_MELEE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE Weak Handgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_HANDGUN"
telemetryId = "SALT6"
name = "$NPC_SALTIS_MCERLANE_WEAK_HANDGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Average Handgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_HANDGUN"
telemetryId = "SALT7"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_HANDGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Strong Handgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_HANDGUN"
telemetryId = "SALT8"
name = "$NPC_SALTIS_MCERLANE_STRONG_HANDGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Elite Handgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_HANDGUN"
telemetryId = "SALT9"
name = "$NPC_SALTIS_MCERLANE_ELITE_HANDGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_HANDGUN"
telemetryId = "SALT10"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_HANDGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_SHOTGUN"
telemetryId = "SALT11"
name = "$NPC_SALTIS_MCERLANE_WEAK_SHOTGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Average Shotgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_SHOTGUN"
telemetryId = "SALT12"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_SHOTGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_SHOTGUN"
telemetryId = "SALT13"
name = "$NPC_SALTIS_MCERLANE_STRONG_SHOTGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_SHOTGUN"
telemetryId = "SALT14"
name = "$NPC_SALTIS_MCERLANE_ELITE_SHOTGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_SHOTGUN"
telemetryId = "SALT15"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_SHOTGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE Weak Rifle
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_RIFLE"
telemetryId = "SALT16"
name = "$NPC_SALTIS_MCERLANE_WEAK_RIFLE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_RIFLE"
telemetryId = "SALT17"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_RIFLE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_RIFLE"
telemetryId = "SALT18"
name = "$NPC_SALTIS_MCERLANE_STRONG_RIFLE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_RIFLE"
telemetryId = "SALT19"
name = "$NPC_SALTIS_MCERLANE_ELITE_RIFLE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_RIFLE"
telemetryId = "SALT20"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_RIFLE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
SALTIS MCERLANE WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_SUBGUN"
telemetryId = "SALT21"
name = "$NPC_SALTIS_MCERLANE_WEAK_SUBGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_SUBGUN"
telemetryId = "SALT22"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_SUBGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_SUBGUN"
telemetryId = "SALT23"
name = "$NPC_SALTIS_MCERLANE_STRONG_SUBGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_SUBGUN"
telemetryId = "SALT24"
name = "$NPC_SALTIS_MCERLANE_ELITE_SUBGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_SUBGUN"
telemetryId = "SALT25"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_SUBGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_HIREDGUN_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_MACHINEGUN"
telemetryId = "SALT26"
name = "$NPC_SALTIS_MCERLANE_WEAK_MACHINEGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_MACHINEGUN"
telemetryId = "SALT27"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_MACHINEGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_MACHINEGUN"
telemetryId = "SALT28"
name = "$NPC_SALTIS_MCERLANE_STRONG_MACHINEGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_MACHINEGUN"
telemetryId = "SALT29"
name = "$NPC_SALTIS_MCERLANE_ELITE_MACHINEGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_MACHINEGUN"
telemetryId = "SALT30"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_MACHINEGUN_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_SNIPER"
telemetryId = "SALT31"
name = "$NPC_SALTIS_MCERLANE_WEAK_SNIPER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_SNIPER"
telemetryId = "SALT32"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_SNIPER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Strong Sniper
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_SNIPER"
telemetryId = "SALT33"
name = "$NPC_SALTIS_MCERLANE_STRONG_SNIPER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_SNIPER"
telemetryId = "SALT34"
name = "$NPC_SALTIS_MCERLANE_ELITE_SNIPER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_SNIPER"
telemetryId = "SALT35"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_SNIPER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_DOCTOR"
telemetryId = "SALT36"
name = "$NPC_SALTIS_MCERLANE_WEAK_DOCTOR_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DOCTOR_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_DOCTOR"
telemetryId = "SALT37"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_DOCTOR_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DOCTOR_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_DOCTOR"
telemetryId = "SALT38"
name = "$NPC_SALTIS_MCERLANE_STRONG_DOCTOR_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DOCTOR_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_DOCTOR"
telemetryId = "SALT39"
name = "$NPC_SALTIS_MCERLANE_ELITE_DOCTOR_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DOCTOR_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_DOCTOR"
telemetryId = "SALT40"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_DOCTOR_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DOCTOR_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_GRENADE"
telemetryId = "SALT41"
name = "$NPC_SALTIS_MCERLANE_WEAK_GRENADE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DEMOLITIONIST_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_GRENADE"
telemetryId = "SALT42"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_GRENADE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DEMOLITIONIST_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_GRENADE"
telemetryId = "SALT43"
name = "$NPC_SALTIS_MCERLANE_STRONG_GRENADE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DEMOLITIONIST_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_GRENADE"
telemetryId = "SALT44"
name = "$NPC_SALTIS_MCERLANE_ELITE_GRENADE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DEMOLITIONIST_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_GRENADE"
telemetryId = "SALT45"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_GRENADE_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_DEMOLITIONIST_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE Weak Conartist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_CONARTIST"
telemetryId = "SALT46"
name = "$NPC_SALTIS_MCERLANE_WEAK_CONARTIST_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Average Conartist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_CONARTIST"
telemetryId = "SALT47"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_CONARTIST_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Strong Conartist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_CONARTIST"
telemetryId = "SALT48"
name = "$NPC_SALTIS_MCERLANE_STRONG_CONARTIST_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Elite Conartist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_CONARTIST"
telemetryId = "SALT49"
name = "$NPC_SALTIS_MCERLANE_ELITE_CONARTIST_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_CONARTIST"
telemetryId = "SALT50"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_CONARTIST_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_CONARTIST_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
SALTIS_MCERLANE ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
SALTIS MCERLANE WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_WEAK_ENFORCER"
telemetryId = "SALT51"
name = "$NPC_SALTIS_MCERLANE_WEAK_ENFORCER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_1",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_AVERAGE_ENFORCER"
telemetryId = "SALT52"
name = "$NPC_SALTIS_MCERLANE_AVERAGE_ENFORCER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_2",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_STRONG_ENFORCER"
telemetryId = "SALT53"
name = "$NPC_SALTIS_MCERLANE_STRONG_ENFORCER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_3",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_ELITE_ENFORCER"
telemetryId = "SALT54"
name = "$NPC_SALTIS_MCERLANE_ELITE_ENFORCER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_4",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT_ENFORCER"
telemetryId = "SALT55"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_ENFORCER_name" --$ Saltis Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "SALTIS_MCERLANE_ENFORCER_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
SALTIS MCERLANE Lieutenant
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_LIEUTENANT"
telemetryId = "SALT56"
name = "$NPC_SALTIS_MCERLANE_LIEUTENANT_name" --$ Saltis Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "SALTIS_MCERLANE_LIEUTENANT_RANK_5",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
SALTIS_MCERLANE UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
SALTIS MCERLANE UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "SALTIS_MCERLANE_UNDERBOSS"
telemetryId = "SALT57"
name = "$NPC_SALTIS_MCERLANE_UNDERBOSS_name" --$ Saltis Underboss
_variants = {numVariants = 8}
_includes =
{
    "SALTIS_MCERLANE_UNDERBOSS_RANK_6",
    "SALTIS_MCERLANE_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
SALTIS MCERLANE -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
SALTIS MCERLANE SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6" -- SALTIS MCERLANE UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_1" -- SALTIS_MCERLANE MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_2" -- SALTIS_MCERLANE MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_3" -- SALTIS_MCERLANE MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_4" -- SALTIS_MCERLANE MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_5" -- SALTIS_MCERLANE FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_6" -- SALTIS_MCERLANE FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_7" -- SALTIS_MCERLANE FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "SALTIS_MCERLANE_UNDERBOSS_RANK_6_VARIANT_8" -- SALTIS_MCERLANE FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
SALTIS MCERLANE LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5" -- SALTIS MCERLANE LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_1" -- SALTIS_MCERLANE MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_2" -- SALTIS_MCERLANE MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_3" -- SALTIS_MCERLANE MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_4" -- SALTIS_MCERLANE MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_5" -- SALTIS_MCERLANE FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_6" -- SALTIS_MCERLANE FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_7" -- SALTIS_MCERLANE FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "SALTIS_MCERLANE_LIEUTENANT_RANK_5_VARIANT_8" -- SALTIS_MCERLANE FEMALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

local most_popular_variants = {
    ["HIREDGUN"] = 0,
    ["CONARTIST"] = 0,
    ["ENFORCER"] = 0,
    ["DEMOLITIONIST"] = 0,
    ["DOCTOR"] = 0,
}

for j = 1,5,1 do -- Iterate over roles
    for i = 0,8,1 do -- Iterate over variants
        if (variant_weights[roles[j]][i] > variant_weights[roles[j]][most_popular_variants[roles[j]]]) then most_popular_variants[roles[j]] = i end
    end
    variant_weights[roles[j]][most_popular_variants[roles[j]]] = variant_weights[roles[j]][most_popular_variants[roles[j]]] - 1 -- Subtract one to offset default becoming this
    if (most_popular_variants[roles[j]] >= 5) then
        most_popular_variants[roles[j]] = most_popular_variants[roles[j]] - 4 -- Offset for gender
    end
end


for k = 1,5,1 do -- Iterate over ranks
    for j = 1,5,1 do -- Iterate over roles
        -- For some reason this needs to be declared as some sort of base unnumbered Variant...
        -- This is a poorly labeled variant 0 it seems
        _id = "SALTIS_MCERLANE_" .. roles[j] .. "_RANK_" .. k
        if (most_popular_variants[roles[j]] == 0) then
            _includes = {"NPC.SQUAD_MALE_" .. roles[j] .. "_RANK_" .. k, "AUDIO.GUARD.PACKS.GUARD_MALE"}
        else
            local most_popular_variant_gender = "MALE"
            if (most_popular_variants[roles[j]] >= 5) then
                most_popular_variant_gender = "FEMALE"
            end
            _includes = {"NPC.SQUAD_" .. most_popular_variant_gender .. "_" .. most_popular_variants[roles[j]] .. "_" .. roles[j] .. "_RANK_" .. k, "AUDIO.GUARD.PACKS.GUARD_" .. most_popular_variant_gender}
        end
        _abstract = true

        local var_num = 0
        for i = 1,8,1 -- Iterate over non-zero variants
        do
            for _ = 1,variant_weights[roles[j]][i],1 do
                var_num = var_num + 1
                _id = "SALTIS_MCERLANE_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
                if i >= 5 then
                    _includes = {"NPC.SQUAD_FEMALE_" .. (i - 4) .. "_" .. roles[j] .. "_RANK_" .. k, "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
                else
                    _includes = {"NPC.SQUAD_MALE_" .. i .. "_" .. roles[j] .. "_RANK_" .. k, "AUDIO.GUARD.PACKS.GUARD_MALE"}
                end
                -- print(i .. ": " .. variant_weights[roles[j]][i] .. " (" .. _includes[1] .. ")")
                _abstract = true
            end
        end
    end
end
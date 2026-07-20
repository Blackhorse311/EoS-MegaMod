_namespace = "FACTION"
_id = "RAGENS_COLTS"

_includes = "GANG_BASE"
stringsKey = "$Factions_RagensColts"
locked=false
bossId = "CHARACTER.BOSS.RAGENCOLTS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.FRANK_RAGEN"
safehouseName = "$RagenColtsSafehouseName" --$ Ragen's Colts' Safehouse
missionBossId = "NPC.MISSION_RAGENS_COLTS_BOSS"

factionIcon = "RagensColts"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/FrankRagen_Pose"

playable = true

icon = "Sprites/Images/Characters/Profile/Cast/FrankRagen_Profile"
primaryColor = "RagensColts_Primary"
secondaryColor = "RagensColts_Secondary"

audio =
{
    onSelect = { "AUDIO.BOSSES.RAGEN.INTRO_1", "AUDIO.BOSSES.RAGEN.INTRO_2", "AUDIO.BOSSES.RAGEN.INTRO_3", "AUDIO.BOSSES.RAGEN.INTRO_4",
    "AUDIO.BOSSES.RAGEN.INTRO_5", "AUDIO.BOSSES.RAGEN.INTRO_6", "AUDIO.BOSSES.RAGEN.INTRO_7", },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_IrishAmerican_01",
    "$DepotName_IrishAmerican_02",
    "$DepotName_IrishAmerican_03",
    "$DepotName_IrishAmerican_04",
    "$DepotName_IrishAmerican_05",
    "$DepotName_IrishAmerican_06",
    "$DepotName_IrishAmerican_07",
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "RagensColtsSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_IrishAmerican"

--[[------------------------------------------------------------------------------
RAGENS_COLTS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "RAGENS_COLTS_FACTION_INFO"
_abstract = true
faction = "RAGENS_COLTS"

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
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
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
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
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
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
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
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
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
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
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
RAGENS_COLTS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
RAGENS COLTS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_MELEE"
telemetryId = "RC1"
name = "$NPC_RAGENS_COLTS_WEAK_MELEE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_1", -- Character Variant Data
    "RAGENS_COLTS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Average Melee
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_MELEE"
telemetryId = "RC2"
name = "$NPC_RAGENS_COLTS_AVERAGE_MELEE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Strong Melee
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_MELEE"
telemetryId = "RC3"
name = "$NPC_RAGENS_COLTS_STRONG_MELEE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Elite Melee
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_MELEE"
telemetryId = "RC4"
name = "$NPC_RAGENS_COLTS_ELITE_MELEE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_MELEE"
telemetryId = "RC5"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_MELEE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
RAGENS COLTS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_HANDGUN"
telemetryId = "RC6"
name = "$NPC_RAGENS_COLTS_WEAK_HANDGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Average Handgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_HANDGUN"
telemetryId = "RC7"
name = "$NPC_RAGENS_COLTS_AVERAGE_HANDGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_HANDGUN"
telemetryId = "RC8"
name = "$NPC_RAGENS_COLTS_STRONG_HANDGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_HANDGUN"
telemetryId = "RC9"
name = "$NPC_RAGENS_COLTS_ELITE_HANDGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_HANDGUN"
telemetryId = "RC10"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_HANDGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
RAGENS COLTS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_SHOTGUN"
telemetryId = "RC11"
name = "$NPC_RAGENS_COLTS_WEAK_SHOTGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_SHOTGUN"
telemetryId = "RC12"
name = "$NPC_RAGENS_COLTS_AVERAGE_SHOTGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_SHOTGUN"
telemetryId = "RC13"
name = "$NPC_RAGENS_COLTS_STRONG_SHOTGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_SHOTGUN"
telemetryId = "RC14"
name = "$NPC_RAGENS_COLTS_ELITE_SHOTGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_SHOTGUN"
telemetryId = "RC15"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_SHOTGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
RAGENS COLTS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_RIFLE"
telemetryId = "RC16"
name = "$NPC_RAGENS_COLTS_WEAK_RIFLE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_RIFLE"
telemetryId = "RC17"
name = "$NPC_RAGENS_COLTS_AVERAGE_RIFLE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_RIFLE"
telemetryId = "RC18"
name = "$NPC_RAGENS_COLTS_STRONG_RIFLE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_RIFLE"
telemetryId = "RC19"
name = "$NPC_RAGENS_COLTS_ELITE_RIFLE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_RIFLE"
telemetryId = "RC20"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_RIFLE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
RAGENS COLTS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_SUBGUN"
telemetryId = "RC21"
name = "$NPC_RAGENS_COLTS_WEAK_SUBGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_SUBGUN"
telemetryId = "RC22"
name = "$NPC_RAGENS_COLTS_AVERAGE_SUBGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_SUBGUN"
telemetryId = "RC23"
name = "$NPC_RAGENS_COLTS_STRONG_SUBGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_SUBGUN"
telemetryId = "RC24"
name = "$NPC_RAGENS_COLTS_ELITE_SUBGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_SUBGUN"
telemetryId = "RC25"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_SUBGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_HIREDGUN_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
RAGENS COLTS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_MACHINEGUN"
telemetryId = "RC26"
name = "$NPC_RAGENS_COLTS_WEAK_MACHINEGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_MACHINEGUN"
telemetryId = "RC27"
name = "$NPC_RAGENS_COLTS_AVERAGE_MACHINEGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_MACHINEGUN"
telemetryId = "RC28"
name = "$NPC_RAGENS_COLTS_STRONG_MACHINEGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_MACHINEGUN"
telemetryId = "RC29"
name = "$NPC_RAGENS_COLTS_ELITE_MACHINEGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_MACHINEGUN"
telemetryId = "RC30"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_MACHINEGUN_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
RAGENS COLTS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_SNIPER"
telemetryId = "RC31"
name = "$NPC_RAGENS_COLTS_WEAK_SNIPER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_SNIPER"
telemetryId = "RC32"
name = "$NPC_RAGENS_COLTS_AVERAGE_SNIPER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_SNIPER"
telemetryId = "RC33"
name = "$NPC_RAGENS_COLTS_STRONG_SNIPER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_SNIPER"
telemetryId = "RC34"
name = "$NPC_RAGENS_COLTS_ELITE_SNIPER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_SNIPER"
telemetryId = "RC35"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_SNIPER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
RAGENS COLTS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_DOCTOR"
telemetryId = "RC36"
name = "$NPC_RAGENS_COLTS_WEAK_DOCTOR_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DOCTOR_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_DOCTOR"
telemetryId = "RC37"
name = "$NPC_RAGENS_COLTS_AVERAGE_DOCTOR_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DOCTOR_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_DOCTOR"
telemetryId = "RC38"
name = "$NPC_RAGENS_COLTS_STRONG_DOCTOR_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DOCTOR_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_DOCTOR"
telemetryId = "RC39"
name = "$NPC_RAGENS_COLTS_ELITE_DOCTOR_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DOCTOR_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_DOCTOR"
telemetryId = "RC40"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_DOCTOR_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DOCTOR_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
RAGENS COLTS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_GRENADE"
telemetryId = "RC41"
name = "$NPC_RAGENS_COLTS_WEAK_GRENADE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DEMOLITIONIST_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_GRENADE"
telemetryId = "RC42"
name = "$NPC_RAGENS_COLTS_AVERAGE_GRENADE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DEMOLITIONIST_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_GRENADE"
telemetryId = "RC43"
name = "$NPC_RAGENS_COLTS_STRONG_GRENADE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DEMOLITIONIST_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_GRENADE"
telemetryId = "RC44"
name = "$NPC_RAGENS_COLTS_ELITE_GRENADE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DEMOLITIONIST_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_GRENADE"
telemetryId = "RC45"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_GRENADE_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_DEMOLITIONIST_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
RAGENS COLTS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_CONARTIST"
telemetryId = "RC46"
name = "$NPC_RAGENS_COLTS_WEAK_CONARTIST_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Average Conartist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_CONARTIST"
telemetryId = "RC47"
name = "$NPC_RAGENS_COLTS_AVERAGE_CONARTIST_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_CONARTIST"
telemetryId = "RC48"
name = "$NPC_RAGENS_COLTS_STRONG_CONARTIST_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_CONARTIST"
telemetryId = "RC49"
name = "$NPC_RAGENS_COLTS_ELITE_CONARTIST_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_CONARTIST"
telemetryId = "RC50"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_CONARTIST_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_CONARTIST_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
RAGENS_COLTS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
RAGENS COLTS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_WEAK_ENFORCER"
telemetryId = "RC51"
name = "$NPC_RAGENS_COLTS_WEAK_ENFORCER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_1",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_AVERAGE_ENFORCER"
telemetryId = "RC52"
name = "$NPC_RAGENS_COLTS_AVERAGE_ENFORCER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_2",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_STRONG_ENFORCER"
telemetryId = "RC53"
name = "$NPC_RAGENS_COLTS_STRONG_ENFORCER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_3",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_ELITE_ENFORCER"
telemetryId = "RC54"
name = "$NPC_RAGENS_COLTS_ELITE_ENFORCER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_4",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT_ENFORCER"
telemetryId = "RC55"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_ENFORCER_name" --$ Ragen Colt Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "RAGENS_COLTS_ENFORCER_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
RAGENS COLTS Lieutenant
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_LIEUTENANT"
telemetryId = "RC56"
name = "$NPC_RAGENS_COLTS_LIEUTENANT_name" --$ Ragen Colt Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "RAGENS_COLTS_LIEUTENANT_RANK_5",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
RAGENS_COLTS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
RAGENS COLTS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "RAGENS_COLTS_UNDERBOSS"
telemetryId = "RC57"
name = "$NPC_RAGENS_COLTS_UNDERBOSS_name" --$ Ragen Colt Underboss
_variants = {numVariants = 8}
_includes =
{
    "RAGENS_COLTS_UNDERBOSS_RANK_6",
    "RAGENS_COLTS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
RAGENS COLTS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
RAGENS COLTS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6" -- RAGENS COLTS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_1" -- RAGENS_COLTS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_2" -- RAGENS_COLTS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_3" -- RAGENS_COLTS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_4" -- RAGENS_COLTS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_5" -- RAGENS_COLTS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_6" -- RAGENS_COLTS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_7" -- RAGENS_COLTS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "RAGENS_COLTS_UNDERBOSS_RANK_6_VARIANT_8" -- RAGENS_COLTS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
RAGENS COLTS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5" -- RAGENS COLTS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_1" -- RAGENS_COLTS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_2" -- RAGENS_COLTS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_3" -- RAGENS_COLTS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_4" -- RAGENS_COLTS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_5" -- RAGENS_COLTS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_6" -- RAGENS_COLTS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_7" -- RAGENS_COLTS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "RAGENS_COLTS_LIEUTENANT_RANK_5_VARIANT_8" -- RAGENS_COLTS FEMALE 4 -- LIEUTENANT
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
        _id = "RAGENS_COLTS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "RAGENS_COLTS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
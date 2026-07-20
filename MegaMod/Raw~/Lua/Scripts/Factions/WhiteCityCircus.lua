_namespace = "FACTION"
_id = "WHITE_CITY_CIRCUS"

_includes = "GANG_BASE"
stringsKey = "$Factions_WhiteCityCircus"
bossId = "CHARACTER.BOSS.WHITECITY_BOSS"
missionBossId = "NPC.MISSION_WHITE_CITY_CIRCUS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.MAGGIE_DYER"

safehouseName = "$WhiteCityCircusSafehouseName" --$ White City Circus' Safehouse

factionIcon = "WhiteCityCircus"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/MaggieDyer_Pose"

playable = true

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
primaryColor = "WhiteCityCircus_Primary"
secondaryColor = "WhiteCityCircus_Secondary"

audio =
{
    onSelect = { "AUDIO.BOSSES.MAGGIE.INTRO_1", "AUDIO.BOSSES.MAGGIE.INTRO_2", "AUDIO.BOSSES.MAGGIE.INTRO_3", "AUDIO.BOSSES.MAGGIE.INTRO_4", "AUDIO.BOSSES.MAGGIE.INTRO_5", },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_American_01", --$ Longroad Market
    "$DepotName_American_02", --$ The Town Square
    "$DepotName_American_03", --$ Industrial Stationery Supplies
    "$DepotName_American_04", --$ Marvin's Indoor Market
    "$DepotName_American_05", --$ Bland Central Station
    "$DepotName_American_06", --$ The Point Depot
    "$DepotName_American_07", --$ Oldwell Crematorium
    "$DepotName_WhiteCityCircus_01", --$ The Circus Tent
}


--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]
sweetHomeChicagoEvent = "WhiteCityCircusSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_American"

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "WHITE_CITY_CIRCUS_FACTION_INFO"
_abstract = true
faction = "WHITE_CITY_CIRCUS"

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
        [1] = 1, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 1, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
        [7] = 1, -- Female Variant 3 (Asian)
        [8] = 1,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["CONARTIST"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 1, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 1, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
        [7] = 1, -- Female Variant 3 (Asian)
        [8] = 1,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["ENFORCER"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 1, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 1, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
        [7] = 1, -- Female Variant 3 (Asian)
        [8] = 1,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["DEMOLITIONIST"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 1, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 1, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
        [7] = 1, -- Female Variant 3 (Asian)
        [8] = 1,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["DOCTOR"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 1, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 1, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
        [4] = 1, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 1, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
        [7] = 1, -- Female Variant 3 (Asian)
        [8] = 1,  -- Female Variant 4 (American?/Italian?/Hispanic?)
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
WHITE_CITY_CIRCUS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_MELEE"
telemetryId = "WCC1"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_MELEE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_1", -- Character Variant Data
    "WHITE_CITY_CIRCUS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Average Melee
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_MELEE"
telemetryId = "WCC2"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_MELEE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Strong Melee
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_MELEE"
telemetryId = "WCC3"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_MELEE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Elite Melee
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_MELEE"
telemetryId = "WCC4"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_MELEE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_MELEE"
telemetryId = "WCC5"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_MELEE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_HANDGUN"
telemetryId = "WCC6"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_HANDGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Average Handgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_HANDGUN"
telemetryId = "WCC7"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_HANDGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_HANDGUN"
telemetryId = "WCC8"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_HANDGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_HANDGUN"
telemetryId = "WCC9"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_HANDGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_HANDGUN"
telemetryId = "WCC10"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_HANDGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_SHOTGUN"
telemetryId = "WCC11"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_SHOTGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_SHOTGUN"
telemetryId = "WCC12"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_SHOTGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_SHOTGUN"
telemetryId = "WCC13"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_SHOTGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_SHOTGUN"
telemetryId = "WCC14"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_SHOTGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_SHOTGUN"
telemetryId = "WCC15"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_SHOTGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_RIFLE"
telemetryId = "WCC16"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_RIFLE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_RIFLE"
telemetryId = "WCC17"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_RIFLE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_RIFLE"
telemetryId = "WCC18"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_RIFLE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_RIFLE"
telemetryId = "WCC19"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_RIFLE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RIFLE"
telemetryId = "WCC20"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_RIFLE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_SUBGUN"
telemetryId = "WCC21"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_SUBGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_SUBGUN"
telemetryId = "WCC22"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_SUBGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_SUBGUN"
telemetryId = "WCC23"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_SUBGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_SUBGUN"
telemetryId = "WCC24"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_SUBGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_SUBGUN"
telemetryId = "WCC25"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_SUBGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_HIREDGUN_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_MACHINEGUN"
telemetryId = "WCC26"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_MACHINEGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_MACHINEGUN"
telemetryId = "WCC27"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_MACHINEGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_MACHINEGUN"
telemetryId = "WCC28"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_MACHINEGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_MACHINEGUN"
telemetryId = "WCC29"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_MACHINEGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_MACHINEGUN"
telemetryId = "WCC30"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_MACHINEGUN_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_SNIPER"
telemetryId = "WCC31"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_SNIPER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_SNIPER"
telemetryId = "WCC32"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_SNIPER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_SNIPER"
telemetryId = "WCC33"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_SNIPER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_SNIPER"
telemetryId = "WCC34"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_SNIPER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_SNIPER"
telemetryId = "WCC35"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_SNIPER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_DOCTOR"
telemetryId = "WCC36"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_DOCTOR_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DOCTOR_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_DOCTOR"
telemetryId = "WCC37"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_DOCTOR_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DOCTOR_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_DOCTOR"
telemetryId = "WCC38"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_DOCTOR_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DOCTOR_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_DOCTOR"
telemetryId = "WCC39"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_DOCTOR_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DOCTOR_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_DOCTOR"
telemetryId = "WCC40"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_DOCTOR_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DOCTOR_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_GRENADE"
telemetryId = "WCC41"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_GRENADE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DEMOLITIONIST_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_GRENADE"
telemetryId = "WCC42"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_GRENADE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DEMOLITIONIST_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_GRENADE"
telemetryId = "WCC43"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_GRENADE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DEMOLITIONIST_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_GRENADE"
telemetryId = "WCC44"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_GRENADE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DEMOLITIONIST_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_GRENADE"
telemetryId = "WCC45"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_GRENADE_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_DEMOLITIONIST_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_CONARTIST"
telemetryId = "WCC46"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_CONARTIST_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Average Conartist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_CONARTIST"
telemetryId = "WCC47"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_CONARTIST_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_CONARTIST"
telemetryId = "WCC48"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_CONARTIST_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_CONARTIST"
telemetryId = "WCC49"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_CONARTIST_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_CONARTIST"
telemetryId = "WCC50"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_CONARTIST_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_CONARTIST_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_WEAK_ENFORCER"
telemetryId = "WCC51"
name = "$NPC_WHITE_CITY_CIRCUS_WEAK_ENFORCER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_1",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_AVERAGE_ENFORCER"
telemetryId = "WCC52"
name = "$NPC_WHITE_CITY_CIRCUS_AVERAGE_ENFORCER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_2",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_STRONG_ENFORCER"
telemetryId = "WCC53"
name = "$NPC_WHITE_CITY_CIRCUS_STRONG_ENFORCER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_3",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_ELITE_ENFORCER"
telemetryId = "WCC54"
name = "$NPC_WHITE_CITY_CIRCUS_ELITE_ENFORCER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_4",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT_ENFORCER"
telemetryId = "WCC55"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_ENFORCER_name" --$ White City Circus Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "WHITE_CITY_CIRCUS_ENFORCER_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS Lieutenant
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_LIEUTENANT"
telemetryId = "WCC56"
name = "$NPC_WHITE_CITY_CIRCUS_LIEUTENANT_name" --$ White City Circus Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
WHITE_CITY_CIRCUS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "WHITE_CITY_CIRCUS_UNDERBOSS"
telemetryId = "WCC57"
name = "$NPC_WHITE_CITY_CIRCUS_UNDERBOSS_name" --$ White City Circus Underboss
_variants = {numVariants = 8}
_includes =
{
    "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6",
    "WHITE_CITY_CIRCUS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6" -- WHITE CITY CIRCUS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_1" -- WHITE_CITY_CIRCUS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_2" -- WHITE_CITY_CIRCUS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_3" -- WHITE_CITY_CIRCUS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_4" -- WHITE_CITY_CIRCUS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_5" -- WHITE_CITY_CIRCUS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_6" -- WHITE_CITY_CIRCUS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_7" -- WHITE_CITY_CIRCUS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_UNDERBOSS_RANK_6_VARIANT_8" -- WHITE_CITY_CIRCUS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
WHITE CITY CIRCUS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5" -- WHITE CITY CIRCUS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_1" -- WHITE_CITY_CIRCUS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_2" -- WHITE_CITY_CIRCUS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_3" -- WHITE_CITY_CIRCUS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_4" -- WHITE_CITY_CIRCUS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_5" -- WHITE_CITY_CIRCUS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_6" -- WHITE_CITY_CIRCUS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_7" -- WHITE_CITY_CIRCUS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "WHITE_CITY_CIRCUS_LIEUTENANT_RANK_5_VARIANT_8" -- WHITE_CITY_CIRCUS FEMALE 4 -- LIEUTENANT
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
        _id = "WHITE_CITY_CIRCUS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "WHITE_CITY_CIRCUS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
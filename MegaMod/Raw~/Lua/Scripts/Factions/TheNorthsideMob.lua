_namespace = "FACTION"
_id = "THE_NORTHSIDE_MOB"

_includes = "GANG_BASE"
stringsKey = "$Factions_TheNorthsideMob"
bossId = "CHARACTER.BOSS.NORTHSIDE_BOSS"
missionBossId = "NPC.MISSION_THE_NORTHSIDE_MOB_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.DEAN_O_BANION"
safehouseName = "$TheNorthSideMobSafehouseName" --$ The Northside Mob's Safehouse

factionIcon = "TheNorthsideMob"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/DeanOBanion_Pose"
playable = true
icon = "Sprites/Images/Characters/Profile/Cast/DeanOBanion_Profile"
primaryColor = "TheNorthsideMob_Primary"
secondaryColor = "TheNorthsideMob_Secondary"
audio = {
    onSelect = { "AUDIO.BOSSES.OBANION.INTRO_1", "AUDIO.BOSSES.OBANION.INTRO_2", "AUDIO.BOSSES.OBANION.INTRO_3", "AUDIO.BOSSES.OBANION.INTRO_4",
    "AUDIO.BOSSES.OBANION.INTRO_5", "AUDIO.BOSSES.OBANION.INTRO_6","AUDIO.BOSSES.OBANION.INTRO_7","AUDIO.BOSSES.OBANION.INTRO_8", },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_IrishAmerican_01", --$ The Old Bakehouse
    "$DepotName_IrishAmerican_02", --$ Brownstone Emporium
    "$DepotName_IrishAmerican_03", --$ Flatlands Boutique
    "$DepotName_IrishAmerican_04", --$ Lakeview Wholesalers
    "$DepotName_IrishAmerican_05", --$ Freddy's Fishmongers
    "$DepotName_IrishAmerican_06", --$ Eastwall Community Centre
    "$DepotName_IrishAmerican_07", --$ Westbridge Motel
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "TheNorthsideMobSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_IrishAmerican"

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "THE_NORTHSIDE_MOB_FACTION_INFO"
_abstract = true
faction = "THE_NORTHSIDE_MOB"

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
THE_NORTHSIDE_MOB MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_MELEE"
telemetryId = "NSM1"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_MELEE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_1", -- Character Variant Data
    "THE_NORTHSIDE_MOB_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Average Melee
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_MELEE"
telemetryId = "NSM2"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_MELEE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Strong Melee
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_MELEE"
telemetryId = "NSM3"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_MELEE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Elite Melee
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_MELEE"
telemetryId = "NSM4"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_MELEE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_MELEE"
telemetryId = "NSM5"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_MELEE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Weak Handgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_HANDGUN"
telemetryId = "NSM6"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_HANDGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Average Handgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_HANDGUN"
telemetryId = "NSM7"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_HANDGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Strong Handgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_HANDGUN"
telemetryId = "NSM8"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_HANDGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Elite Handgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_HANDGUN"
telemetryId = "NSM9"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_HANDGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_HANDGUN"
telemetryId = "NSM10"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_HANDGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_SHOTGUN"
telemetryId = "NSM11"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_SHOTGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Average Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_SHOTGUN"
telemetryId = "NSM12"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_SHOTGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_SHOTGUN"
telemetryId = "NSM13"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_SHOTGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_SHOTGUN"
telemetryId = "NSM14"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_SHOTGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_SHOTGUN"
telemetryId = "NSM15"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_SHOTGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Weak Rifle
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_RIFLE"
telemetryId = "NSM16"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_RIFLE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_RIFLE"
telemetryId = "NSM17"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_RIFLE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_RIFLE"
telemetryId = "NSM18"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_RIFLE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_RIFLE"
telemetryId = "NSM19"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_RIFLE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RIFLE"
telemetryId = "NSM20"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_RIFLE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_SUBGUN"
telemetryId = "NSM21"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_SUBGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_SUBGUN"
telemetryId = "NSM22"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_SUBGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_SUBGUN"
telemetryId = "NSM23"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_SUBGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_SUBGUN"
telemetryId = "NSM24"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_SUBGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_SUBGUN"
telemetryId = "NSM25"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_SUBGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_HIREDGUN_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_MACHINEGUN"
telemetryId = "NSM26"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_MACHINEGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_MACHINEGUN"
telemetryId = "NSM27"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_MACHINEGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_MACHINEGUN"
telemetryId = "NSM28"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_MACHINEGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_MACHINEGUN"
telemetryId = "NSM29"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_MACHINEGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_MACHINEGUN"
telemetryId = "NSM30"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_MACHINEGUN_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_SNIPER"
telemetryId = "NSM31"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_SNIPER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_SNIPER"
telemetryId = "NSM32"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_SNIPER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Strong Sniper
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_SNIPER"
telemetryId = "NSM33"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_SNIPER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_SNIPER"
telemetryId = "NSM34"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_SNIPER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_SNIPER"
telemetryId = "NSM35"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_SNIPER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_DOCTOR"
telemetryId = "NSM36"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_DOCTOR_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DOCTOR_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_DOCTOR"
telemetryId = "NSM37"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_DOCTOR_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DOCTOR_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_DOCTOR"
telemetryId = "NSM38"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_DOCTOR_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DOCTOR_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_DOCTOR"
telemetryId = "NSM39"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_DOCTOR_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DOCTOR_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_DOCTOR"
telemetryId = "NSM40"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_DOCTOR_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DOCTOR_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_GRENADE"
telemetryId = "NSM41"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_GRENADE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DEMOLITIONIST_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_GRENADE"
telemetryId = "NSM42"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_GRENADE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DEMOLITIONIST_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_GRENADE"
telemetryId = "NSM43"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_GRENADE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DEMOLITIONIST_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_GRENADE"
telemetryId = "NSM44"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_GRENADE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DEMOLITIONIST_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_GRENADE"
telemetryId = "NSM45"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_GRENADE_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_DEMOLITIONIST_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Weak Conartist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_CONARTIST"
telemetryId = "NSM46"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_CONARTIST_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Average Conartist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_CONARTIST"
telemetryId = "NSM47"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_CONARTIST_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Strong Conartist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_CONARTIST"
telemetryId = "NSM48"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_CONARTIST_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Elite Conartist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_CONARTIST"
telemetryId = "NSM49"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_CONARTIST_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_CONARTIST"
telemetryId = "NSM50"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_CONARTIST_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_CONARTIST_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_WEAK_ENFORCER"
telemetryId = "NSM51"
name = "$NPC_THE_NORTHSIDE_MOB_WEAK_ENFORCER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_1",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_AVERAGE_ENFORCER"
telemetryId = "NSM52"
name = "$NPC_THE_NORTHSIDE_MOB_AVERAGE_ENFORCER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_2",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_STRONG_ENFORCER"
telemetryId = "NSM53"
name = "$NPC_THE_NORTHSIDE_MOB_STRONG_ENFORCER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_3",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_ELITE_ENFORCER"
telemetryId = "NSM54"
name = "$NPC_THE_NORTHSIDE_MOB_ELITE_ENFORCER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_4",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT_ENFORCER"
telemetryId = "NSM55"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_ENFORCER_name" --$ Northside Mob Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_NORTHSIDE_MOB_ENFORCER_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB Lieutenant
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_LIEUTENANT"
telemetryId = "NSM56"
name = "$NPC_THE_NORTHSIDE_MOB_LIEUTENANT_name" --$ Northside Mob Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
THE_NORTHSIDE_MOB UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "THE_NORTHSIDE_MOB_UNDERBOSS"
telemetryId = "NSM57"
name = "$NPC_THE_NORTHSIDE_MOB_UNDERBOSS_name" --$ Northside Mob Underboss
_variants = {numVariants = 8}
_includes =
{
    "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6",
    "THE_NORTHSIDE_MOB_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6" -- THE NORTHSIDE MOB UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_1" -- THE_NORTHSIDE_MOB MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_2" -- THE_NORTHSIDE_MOB MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_3" -- THE_NORTHSIDE_MOB MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_4" -- THE_NORTHSIDE_MOB MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_5" -- THE_NORTHSIDE_MOB FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_6" -- THE_NORTHSIDE_MOB FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_7" -- THE_NORTHSIDE_MOB FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_UNDERBOSS_RANK_6_VARIANT_8" -- THE_NORTHSIDE_MOB FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
THE NORTHSIDE MOB LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5" -- THE NORTHSIDE MOB LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_1" -- THE_NORTHSIDE_MOB MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_2" -- THE_NORTHSIDE_MOB MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_3" -- THE_NORTHSIDE_MOB MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_4" -- THE_NORTHSIDE_MOB MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_5" -- THE_NORTHSIDE_MOB FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_6" -- THE_NORTHSIDE_MOB FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_7" -- THE_NORTHSIDE_MOB FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_NORTHSIDE_MOB_LIEUTENANT_RANK_5_VARIANT_8" -- THE_NORTHSIDE_MOB FEMALE 4 -- LIEUTENANT
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
        _id = "THE_NORTHSIDE_MOB_" .. roles[j] .. "_RANK_" .. k
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
                _id = "THE_NORTHSIDE_MOB_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
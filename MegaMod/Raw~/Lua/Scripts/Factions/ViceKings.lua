_namespace = "FACTION"
_id = "VICE_KINGS"

_includes = "GANG_BASE"
stringsKey = "$Factions_ViceKings"
playable = true

bossId = "CHARACTER.BOSS.VICEKINGS_BOSS"
missionBossId = "NPC.MISSION_VICE_KINGS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.DANIEL_MKEE_JACKSON"

safehouseName = "$ViceKingsSafehouseName" --$ Vice Kings' Safehouse

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_02_Profile"
factionIcon = "ViceKings"
primaryColor = "ViceKings_Primary"
secondaryColor = "ViceKings_Secondary"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/DanielMcKeeJackson_Pose"

audio = {
    onSelect = { "AUDIO.BOSSES.MCKEE.INTRO_1", "AUDIO.BOSSES.MCKEE.INTRO_2", "AUDIO.BOSSES.MCKEE.INTRO_3", "AUDIO.BOSSES.MCKEE.INTRO_4",
    "AUDIO.BOSSES.MCKEE.INTRO_5", "AUDIO.BOSSES.MCKEE.INTRO_6", "AUDIO.BOSSES.MCKEE.INTRO_7",  },
}

aiDiplomaticInventory =
{
    -- Weapons for Diplomatic Trade
    -- "ITEM.WEAPON.RARE_HANDGUN_01",
    "ITEM.WEAPON.RARE_HANDGUN_02",
    "ITEM.WEAPON.RARE_HANDGUN_03",
    "ITEM.WEAPON.RARE_HANDGUN_04",
    -- "ITEM.WEAPON.EPIC_HANDGUN_01",
    -- "ITEM.WEAPON.EPIC_HANDGUN_02",
    "ITEM.WEAPON.EPIC_HANDGUN_03",
    -- "ITEM.WEAPON.EPIC_HANDGUN_04",
    -- "ITEM.WEAPON.RARE_SHOTGUN_01",
    -- "ITEM.WEAPON.RARE_SHOTGUN_02",
    "ITEM.WEAPON.RARE_SHOTGUN_03",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_01",
    "ITEM.WEAPON.EPIC_SHOTGUN_02",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_03",
    -- "ITEM.WEAPON.RARE_SUBGUN_01",
    -- "ITEM.WEAPON.RARE_SUBGUN_02",
    -- "ITEM.WEAPON.RARE_SUBGUN_04",
    -- "ITEM.WEAPON.EPIC_SUBGUN_01",
    -- "ITEM.WEAPON.EPIC_SUBGUN_02",
    -- "ITEM.WEAPON.EPIC_SUBGUN_04",
    -- "ITEM.WEAPON.RARE_RIFLE_01",
    "ITEM.WEAPON.RARE_RIFLE_02",
    -- "ITEM.WEAPON.RARE_RIFLE_03",
    -- "ITEM.WEAPON.EPIC_RIFLE_01",
    "ITEM.WEAPON.EPIC_RIFLE_02",
    -- "ITEM.WEAPON.EPIC_RIFLE_03",
    -- "ITEM.WEAPON.RARE_SNIPER_02",
    "ITEM.WEAPON.RARE_SNIPER_04",
    -- "ITEM.WEAPON.EPIC_SNIPER_02",
    -- "ITEM.WEAPON.EPIC_SNIPER_04",
    -- "ITEM.WEAPON.RARE_MACHINEGUN_01",
    -- "ITEM.WEAPON.EPIC_MACHINEGUN_01",

    -- Items for Diplomatic Trade
    "ITEM.WEAPON.EXPLOSIVE_02",
    "ITEM.WEAPON.EXPLOSIVE_06",
    "ITEM.UTILITY.HEALING_ITEM_02",
    "ITEM.UTILITY.HEALING_ITEM_04",
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_American_01",
    "$DepotName_American_02",
    "$DepotName_American_03",
    "$DepotName_American_04",
    "$DepotName_American_05",
    "$DepotName_American_06",
    "$DepotName_American_07",
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "ViceKingsSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_American"

--[[------------------------------------------------------------------------------
VICE_KINGS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "VICE_KINGS_FACTION_INFO"
_abstract = true
faction = "VICE_KINGS"

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
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
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
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
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
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
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
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
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
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
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
VICE_KINGS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
VICE KINGS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_MELEE"
telemetryId = "VK1"
name = "$NPC_VICE_KINGS_WEAK_MELEE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_1", -- Character Variant Data
    "VICE_KINGS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
VICE KINGS Average Melee
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_MELEE"
telemetryId = "VK2"
name = "$NPC_VICE_KINGS_AVERAGE_MELEE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS Strong Melee
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_MELEE"
telemetryId = "VK3"
name = "$NPC_VICE_KINGS_STRONG_MELEE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS Elite Melee
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_MELEE"
telemetryId = "VK4"
name = "$NPC_VICE_KINGS_ELITE_MELEE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_MELEE"
telemetryId = "VK5"
name = "$NPC_VICE_KINGS_LIEUTENANT_MELEE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
VICE KINGS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_HANDGUN"
telemetryId = "VK6"
name = "$NPC_VICE_KINGS_WEAK_HANDGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS Average Handgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_HANDGUN"
telemetryId = "VK7"
name = "$NPC_VICE_KINGS_AVERAGE_HANDGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_HANDGUN"
telemetryId = "VK8"
name = "$NPC_VICE_KINGS_STRONG_HANDGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_HANDGUN"
telemetryId = "VK9"
name = "$NPC_VICE_KINGS_ELITE_HANDGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_HANDGUN"
telemetryId = "VK10"
name = "$NPC_VICE_KINGS_LIEUTENANT_HANDGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
VICE KINGS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_SHOTGUN"
telemetryId = "VK11"
name = "$NPC_VICE_KINGS_WEAK_SHOTGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_SHOTGUN"
telemetryId = "VK12"
name = "$NPC_VICE_KINGS_AVERAGE_SHOTGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_SHOTGUN"
telemetryId = "VK13"
name = "$NPC_VICE_KINGS_STRONG_SHOTGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_SHOTGUN"
telemetryId = "VK14"
name = "$NPC_VICE_KINGS_ELITE_SHOTGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_SHOTGUN"
telemetryId = "VK15"
name = "$NPC_VICE_KINGS_LIEUTENANT_SHOTGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
VICE KINGS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_RIFLE"
telemetryId = "VK16"
name = "$NPC_VICE_KINGS_WEAK_RIFLE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_RIFLE"
telemetryId = "VK17"
name = "$NPC_VICE_KINGS_AVERAGE_RIFLE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_RIFLE"
telemetryId = "VK18"
name = "$NPC_VICE_KINGS_STRONG_RIFLE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_RIFLE"
telemetryId = "VK19"
name = "$NPC_VICE_KINGS_ELITE_RIFLE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_RIFLE"
telemetryId = "VK20"
name = "$NPC_VICE_KINGS_LIEUTENANT_RIFLE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
VICE KINGS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_SUBGUN"
telemetryId = "VK21"
name = "$NPC_VICE_KINGS_WEAK_SUBGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_SUBGUN"
telemetryId = "VK22"
name = "$NPC_VICE_KINGS_AVERAGE_SUBGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_SUBGUN"
telemetryId = "VK23"
name = "$NPC_VICE_KINGS_STRONG_SUBGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_SUBGUN"
telemetryId = "VK24"
name = "$NPC_VICE_KINGS_ELITE_SUBGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_SUBGUN"
telemetryId = "VK25"
name = "$NPC_VICE_KINGS_LIEUTENANT_SUBGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_HIREDGUN_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
VICE KINGS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_MACHINEGUN"
telemetryId = "VK26"
name = "$NPC_VICE_KINGS_WEAK_MACHINEGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_MACHINEGUN"
telemetryId = "VK27"
name = "$NPC_VICE_KINGS_AVERAGE_MACHINEGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_MACHINEGUN"
telemetryId = "VK28"
name = "$NPC_VICE_KINGS_STRONG_MACHINEGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_MACHINEGUN"
telemetryId = "VK29"
name = "$NPC_VICE_KINGS_ELITE_MACHINEGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_MACHINEGUN"
telemetryId = "VK30"
name = "$NPC_VICE_KINGS_LIEUTENANT_MACHINEGUN_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
VICE KINGS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_SNIPER"
telemetryId = "VK31"
name = "$NPC_VICE_KINGS_WEAK_SNIPER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_SNIPER"
telemetryId = "VK32"
name = "$NPC_VICE_KINGS_AVERAGE_SNIPER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_SNIPER"
telemetryId = "VK33"
name = "$NPC_VICE_KINGS_STRONG_SNIPER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_SNIPER"
telemetryId = "VK34"
name = "$NPC_VICE_KINGS_ELITE_SNIPER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_SNIPER"
telemetryId = "VK35"
name = "$NPC_VICE_KINGS_LIEUTENANT_SNIPER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
VICE KINGS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_DOCTOR"
telemetryId = "VK36"
name = "$NPC_VICE_KINGS_WEAK_DOCTOR_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DOCTOR_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_DOCTOR"
telemetryId = "VK37"
name = "$NPC_VICE_KINGS_AVERAGE_DOCTOR_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DOCTOR_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_DOCTOR"
telemetryId = "VK38"
name = "$NPC_VICE_KINGS_STRONG_DOCTOR_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DOCTOR_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_DOCTOR"
telemetryId = "VK39"
name = "$NPC_VICE_KINGS_ELITE_DOCTOR_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DOCTOR_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_DOCTOR"
telemetryId = "VK40"
name = "$NPC_VICE_KINGS_LIEUTENANT_DOCTOR_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DOCTOR_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
VICE KINGS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_GRENADE"
telemetryId = "VK41"
name = "$NPC_VICE_KINGS_WEAK_GRENADE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DEMOLITIONIST_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_GRENADE"
telemetryId = "VK42"
name = "$NPC_VICE_KINGS_AVERAGE_GRENADE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DEMOLITIONIST_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_GRENADE"
telemetryId = "VK43"
name = "$NPC_VICE_KINGS_STRONG_GRENADE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DEMOLITIONIST_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_GRENADE"
telemetryId = "VK44"
name = "$NPC_VICE_KINGS_ELITE_GRENADE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DEMOLITIONIST_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_GRENADE"
telemetryId = "VK45"
name = "$NPC_VICE_KINGS_LIEUTENANT_GRENADE_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_DEMOLITIONIST_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
VICE KINGS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_CONARTIST"
telemetryId = "VK46"
name = "$NPC_VICE_KINGS_WEAK_CONARTIST_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS Average Conartist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_CONARTIST"
telemetryId = "VK47"
name = "$NPC_VICE_KINGS_AVERAGE_CONARTIST_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_CONARTIST"
telemetryId = "VK48"
name = "$NPC_VICE_KINGS_STRONG_CONARTIST_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_CONARTIST"
telemetryId = "VK49"
name = "$NPC_VICE_KINGS_ELITE_CONARTIST_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_CONARTIST"
telemetryId = "VK50"
name = "$NPC_VICE_KINGS_LIEUTENANT_CONARTIST_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_CONARTIST_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
VICE_KINGS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
VICE KINGS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_WEAK_ENFORCER"
telemetryId = "VK51"
name = "$NPC_VICE_KINGS_WEAK_ENFORCER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_1",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
VICE KINGS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_AVERAGE_ENFORCER"
telemetryId = "VK52"
name = "$NPC_VICE_KINGS_AVERAGE_ENFORCER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_2",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
VICE KINGS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_STRONG_ENFORCER"
telemetryId = "VK53"
name = "$NPC_VICE_KINGS_STRONG_ENFORCER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_3",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
VICE KINGS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_ELITE_ENFORCER"
telemetryId = "VK54"
name = "$NPC_VICE_KINGS_ELITE_ENFORCER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_4",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT_ENFORCER"
telemetryId = "VK55"
name = "$NPC_VICE_KINGS_LIEUTENANT_ENFORCER_name" --$ Vice Kings Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "VICE_KINGS_ENFORCER_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
VICE_KINGS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
VICE KINGS Lieutenant
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_LIEUTENANT"
telemetryId = "VK56"
name = "$NPC_VICE_KINGS_LIEUTENANT_name" --$ Vice Kings Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "VICE_KINGS_LIEUTENANT_RANK_5",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
VICE_KINGS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
VICE KINGS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "VICE_KINGS_UNDERBOSS"
telemetryId = "VK57"
name = "$NPC_VICE_KINGS_UNDERBOSS_name" --$ Vice Kings Underboss
_variants = {numVariants = 8}
_includes =
{
    "VICE_KINGS_UNDERBOSS_RANK_6",
    "VICE_KINGS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
VICE KINGS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
VICE KINGS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "VICE_KINGS_UNDERBOSS_RANK_6" -- VICE KINGS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_1" -- VICE_KINGS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_2" -- VICE_KINGS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_3" -- VICE_KINGS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_4" -- VICE_KINGS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_5" -- VICE_KINGS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_6" -- VICE_KINGS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_7" -- VICE_KINGS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "VICE_KINGS_UNDERBOSS_RANK_6_VARIANT_8" -- VICE_KINGS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
VICE KINGS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "VICE_KINGS_LIEUTENANT_RANK_5" -- VICE KINGS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_1" -- VICE_KINGS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_2" -- VICE_KINGS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_3" -- VICE_KINGS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_4" -- VICE_KINGS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_5" -- VICE_KINGS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_6" -- VICE_KINGS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_7" -- VICE_KINGS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "VICE_KINGS_LIEUTENANT_RANK_5_VARIANT_8" -- VICE_KINGS FEMALE 4 -- LIEUTENANT
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
        _id = "VICE_KINGS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "VICE_KINGS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
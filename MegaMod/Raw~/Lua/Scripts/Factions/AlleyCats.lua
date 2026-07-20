_namespace = "FACTION"
_id = "ALLEY_CATS"

_includes = "GANG_BASE"
stringsKey = "$Factions_AlleyCats"
playable = true

bossId = "CHARACTER.BOSS.ALLEYCATS_BOSS"
missionBossId = "NPC.MISSION_ALLEY_CATS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.MABEL_RYLEY"

safehouseName = "$AlleyCatsSafehouseName" --$ Alley Cats Safehouse
description = "$AlleyCatsDescription" --$ Placeholder Text.

factionIcon = "AlleyCats"

primaryColor = "AlleyCats_Primary"
secondaryColor = "AlleyCats_Secondary"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/MabelRyley_Pose"

audio =
{
    onSelect = { "AUDIO.BOSSES.MABEL.INTRO_1", "AUDIO.BOSSES.MABEL.INTRO_2", "AUDIO.BOSSES.MABEL.INTRO_3", "AUDIO.BOSSES.MABEL.INTRO_4",
    "AUDIO.BOSSES.MABEL.INTRO_5", "AUDIO.BOSSES.MABEL.INTRO_6", "AUDIO.BOSSES.MABEL.INTRO_7", "AUDIO.BOSSES.MABEL.INTRO_8", "AUDIO.BOSSES.MABEL.INTRO_9", "AUDIO.BOSSES.MABEL.INTRO_10", },
}

aiDiplomaticInventory =
{
    -- Weapons for Diplomatic Trade
    "ITEM.WEAPON.RARE_HANDGUN_01",
    -- "ITEM.WEAPON.RARE_HANDGUN_02",
    "ITEM.WEAPON.RARE_HANDGUN_03",
    -- "ITEM.WEAPON.RARE_HANDGUN_04",
    -- "ITEM.WEAPON.EPIC_HANDGUN_01",
    "ITEM.WEAPON.EPIC_HANDGUN_02",
    -- "ITEM.WEAPON.EPIC_HANDGUN_03",
    "ITEM.WEAPON.EPIC_HANDGUN_04",
    -- "ITEM.WEAPON.RARE_SHOTGUN_01",
    -- "ITEM.WEAPON.RARE_SHOTGUN_02",
    -- "ITEM.WEAPON.RARE_SHOTGUN_03",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_01",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_02",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_03",
    "ITEM.WEAPON.RARE_SUBGUN_01",
    -- "ITEM.WEAPON.RARE_SUBGUN_02",
    "ITEM.WEAPON.RARE_SUBGUN_04",
    -- "ITEM.WEAPON.EPIC_SUBGUN_01",
    -- "ITEM.WEAPON.EPIC_SUBGUN_02",
    -- "ITEM.WEAPON.EPIC_SUBGUN_04",
    -- "ITEM.WEAPON.RARE_RIFLE_01",
    "ITEM.WEAPON.RARE_RIFLE_02",
    "ITEM.WEAPON.RARE_RIFLE_03",
    -- "ITEM.WEAPON.EPIC_RIFLE_01",
    -- "ITEM.WEAPON.EPIC_RIFLE_02",
    -- "ITEM.WEAPON.EPIC_RIFLE_03",
    -- "ITEM.WEAPON.RARE_SNIPER_02",
    -- "ITEM.WEAPON.RARE_SNIPER_04",
    -- "ITEM.WEAPON.EPIC_SNIPER_02",
    -- "ITEM.WEAPON.EPIC_SNIPER_04",
    -- "ITEM.WEAPON.RARE_MACHINEGUN_01",
    "ITEM.WEAPON.EPIC_MACHINEGUN_01",

    -- Items for Diplomatic Trade
    "ITEM.WEAPON.EXPLOSIVE_02",
    "ITEM.WEAPON.EXPLOSIVE_06",
    "ITEM.UTILITY.HEALING_ITEM_02",
    "ITEM.UTILITY.HEALING_ITEM_04",
}

startingInventory =
{
}

racketPreferences =
{
    {70, "BUILDING_DATA.BAR"},
    {0, "BUILDING_DATA.BREWERY"},
    {30, "BUILDING_DATA.CASINO"},
    {0, "BUILDING_DATA.BROTHEL"},
}

depotNames =
{
    "$DepotName_Irish_01", --$ The Mart
    "$DepotName_Irish_02", --$ Dolan’s Exchange
    "$DepotName_Irish_03", --$ Boland’s Textile Factory
    "$DepotName_Irish_04", --$ Walsh Brothers Linen Mill
    "$DepotName_Irish_05", --$ Malbay Engineers Ltd.
    "$DepotName_Irish_06", --$ Fahy’s Printing Works
    "$DepotName_Irish_07", --$ Eyre Square Hall
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]
sweetHomeChicagoEvent = "AlleyCatsSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_Irish"

--[[------------------------------------------------------------------------------
ALLEY_CATS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "ALLEY_CATS_FACTION_INFO"
_abstract = true
faction = "ALLEY_CATS"

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
        [0] = 4, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 1, -- Female Variant 1 (American?/Irish?)
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
        [5] = 2, -- Female Variant 1 (American?/Irish?)
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
ALLEY_CATS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_MELEE"
telemetryId = "AC1"
name = "$NPC_ALLEY_CATS_WEAK_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_1", -- Character Variant Data
    "ALLEY_CATS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Melee
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_MELEE"
telemetryId = "AC2"
name = "$NPC_ALLEY_CATS_AVERAGE_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Melee
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_MELEE"
telemetryId = "AC3"
name = "$NPC_ALLEY_CATS_STRONG_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Melee
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_MELEE"
telemetryId = "AC4"
name = "$NPC_ALLEY_CATS_ELITE_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_MELEE"
telemetryId = "AC5"
name = "$NPC_ALLEY_CATS_LIEUTENANT_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_HANDGUN"
telemetryId = "AC6"
name = "$NPC_ALLEY_CATS_WEAK_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Handgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_HANDGUN"
telemetryId = "AC7"
name = "$NPC_ALLEY_CATS_AVERAGE_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_HANDGUN"
telemetryId = "AC8"
name = "$NPC_ALLEY_CATS_STRONG_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_HANDGUN"
telemetryId = "AC9"
name = "$NPC_ALLEY_CATS_ELITE_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_HANDGUN"
telemetryId = "AC10"
name = "$NPC_ALLEY_CATS_LIEUTENANT_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_SHOTGUN"
telemetryId = "AC11"
name = "$NPC_ALLEY_CATS_WEAK_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_SHOTGUN"
telemetryId = "AC12"
name = "$NPC_ALLEY_CATS_AVERAGE_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_SHOTGUN"
telemetryId = "AC13"
name = "$NPC_ALLEY_CATS_STRONG_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_SHOTGUN"
telemetryId = "AC14"
name = "$NPC_ALLEY_CATS_ELITE_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_SHOTGUN"
telemetryId = "AC15"
name = "$NPC_ALLEY_CATS_LIEUTENANT_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_RIFLE"
telemetryId = "AC16"
name = "$NPC_ALLEY_CATS_WEAK_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_RIFLE"
telemetryId = "AC17"
name = "$NPC_ALLEY_CATS_AVERAGE_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_RIFLE"
telemetryId = "AC18"
name = "$NPC_ALLEY_CATS_STRONG_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_RIFLE"
telemetryId = "AC19"
name = "$NPC_ALLEY_CATS_ELITE_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_RIFLE"
telemetryId = "AC20"
name = "$NPC_ALLEY_CATS_LIEUTENANT_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_SUBGUN"
telemetryId = "AC21"
name = "$NPC_ALLEY_CATS_WEAK_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_SUBGUN"
telemetryId = "AC22"
name = "$NPC_ALLEY_CATS_AVERAGE_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_SUBGUN"
telemetryId = "AC23"
name = "$NPC_ALLEY_CATS_STRONG_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_SUBGUN"
telemetryId = "AC24"
name = "$NPC_ALLEY_CATS_ELITE_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_SUBGUN"
telemetryId = "AC25"
name = "$NPC_ALLEY_CATS_LIEUTENANT_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_HIREDGUN_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_MACHINEGUN"
telemetryId = "AC26"
name = "$NPC_ALLEY_CATS_WEAK_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_MACHINEGUN"
telemetryId = "AC27"
name = "$NPC_ALLEY_CATS_AVERAGE_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_MACHINEGUN"
telemetryId = "AC28"
name = "$NPC_ALLEY_CATS_STRONG_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_MACHINEGUN"
telemetryId = "AC29"
name = "$NPC_ALLEY_CATS_ELITE_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_MACHINEGUN"
telemetryId = "AC30"
name = "$NPC_ALLEY_CATS_LIEUTENANT_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_SNIPER"
telemetryId = "AC31"
name = "$NPC_ALLEY_CATS_WEAK_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_SNIPER"
telemetryId = "AC32"
name = "$NPC_ALLEY_CATS_AVERAGE_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_SNIPER"
telemetryId = "AC33"
name = "$NPC_ALLEY_CATS_STRONG_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_SNIPER"
telemetryId = "AC34"
name = "$NPC_ALLEY_CATS_ELITE_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_SNIPER"
telemetryId = "AC35"
name = "$NPC_ALLEY_CATS_LIEUTENANT_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_DOCTOR"
telemetryId = "AC36"
name = "$NPC_ALLEY_CATS_WEAK_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DOCTOR_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_DOCTOR"
telemetryId = "AC37"
name = "$NPC_ALLEY_CATS_AVERAGE_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DOCTOR_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_DOCTOR"
telemetryId = "AC38"
name = "$NPC_ALLEY_CATS_STRONG_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DOCTOR_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_DOCTOR"
telemetryId = "AC39"
name = "$NPC_ALLEY_CATS_ELITE_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DOCTOR_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_DOCTOR"
telemetryId = "AC40"
name = "$NPC_ALLEY_CATS_LIEUTENANT_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DOCTOR_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_GRENADE"
telemetryId = "AC41"
name = "$NPC_ALLEY_CATS_WEAK_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DEMOLITIONIST_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_GRENADE"
telemetryId = "AC42"
name = "$NPC_ALLEY_CATS_AVERAGE_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DEMOLITIONIST_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_GRENADE"
telemetryId = "AC43"
name = "$NPC_ALLEY_CATS_STRONG_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DEMOLITIONIST_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_GRENADE"
telemetryId = "AC44"
name = "$NPC_ALLEY_CATS_ELITE_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DEMOLITIONIST_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_GRENADE"
telemetryId = "AC45"
name = "$NPC_ALLEY_CATS_LIEUTENANT_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_DEMOLITIONIST_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_CONARTIST"
telemetryId = "AC46"
name = "$NPC_ALLEY_CATS_WEAK_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Conartist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_CONARTIST"
telemetryId = "AC47"
name = "$NPC_ALLEY_CATS_AVERAGE_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_CONARTIST"
telemetryId = "AC48"
name = "$NPC_ALLEY_CATS_STRONG_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_CONARTIST"
telemetryId = "AC49"
name = "$NPC_ALLEY_CATS_ELITE_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_CONARTIST"
telemetryId = "AC50"
name = "$NPC_ALLEY_CATS_LIEUTENANT_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_CONARTIST_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
ALLEY_CATS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_WEAK_ENFORCER"
telemetryId = "AC51"
name = "$NPC_ALLEY_CATS_WEAK_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_1",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_AVERAGE_ENFORCER"
telemetryId = "AC52"
name = "$NPC_ALLEY_CATS_AVERAGE_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_2",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_STRONG_ENFORCER"
telemetryId = "AC53"
name = "$NPC_ALLEY_CATS_STRONG_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_3",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_ELITE_ENFORCER"
telemetryId = "AC54"
name = "$NPC_ALLEY_CATS_ELITE_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_4",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT_ENFORCER"
telemetryId = "AC55"
name = "$NPC_ALLEY_CATS_LIEUTENANT_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "ALLEY_CATS_ENFORCER_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS Lieutenant
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_LIEUTENANT"
telemetryId = "AC56"
name = "$NPC_ALLEY_CATS_LIEUTENANT_name" --$ Alley Cat Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "ALLEY_CATS_LIEUTENANT_RANK_5",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
ALLEY_CATS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "ALLEY_CATS_UNDERBOSS"
telemetryId = "AC57"
name = "$NPC_ALLEY_CATS_UNDERBOSS_name" --$ Alley Cat Underboss
_variants = {numVariants = 8}
_includes =
{
    "ALLEY_CATS_UNDERBOSS_RANK_6",
    "ALLEY_CATS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "ALLEY_CATS_UNDERBOSS_RANK_6" -- ALLEY CATS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_1" -- ALLEY_CATS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_2" -- ALLEY_CATS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_3" -- ALLEY_CATS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_4" -- ALLEY_CATS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_5" -- ALLEY_CATS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_6" -- ALLEY_CATS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_7" -- ALLEY_CATS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "ALLEY_CATS_UNDERBOSS_RANK_6_VARIANT_8" -- ALLEY_CATS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "ALLEY_CATS_LIEUTENANT_RANK_5" -- ALLEY CATS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_1" -- ALLEY_CATS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_2" -- ALLEY_CATS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_3" -- ALLEY_CATS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_4" -- ALLEY_CATS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_5" -- ALLEY_CATS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_6" -- ALLEY_CATS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_7" -- ALLEY_CATS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "ALLEY_CATS_LIEUTENANT_RANK_5_VARIANT_8" -- ALLEY_CATS FEMALE 4 -- LIEUTENANT
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
        _id = "ALLEY_CATS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "ALLEY_CATS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
_namespace = "FACTION"
_id = "GENNA_CRIME_FAMILY"

_includes = "GANG_BASE"
stringsKey = "$Factions_GennaCrimeFamily"
playable = true

bossId = "CHARACTER.BOSS.GENNA_BOSS"
missionBossId = "NPC.MISSION_GENNA_CRIME_FAMILY_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.ANGELO_GENNA"
safehouseName = "$GennaCrimeFamilySafehouseName" --$ Genna Crime Family Safehouse

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
factionIcon = "GennaCrimeFamily"
primaryColor = "GennaCrimeFamily_Primary"
secondaryColor = "GennaCrimeFamily_Secondary"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/AngeloGenna_Pose"

audio =
{
    onSelect = { "AUDIO.BOSSES.GENNA.INTRO_1", "AUDIO.BOSSES.GENNA.INTRO_2", "AUDIO.BOSSES.GENNA.INTRO_3", "AUDIO.BOSSES.GENNA.INTRO_4",
    "AUDIO.BOSSES.GENNA.INTRO_5", "AUDIO.BOSSES.GENNA.INTRO_6",  },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_Italian_01",
    "$DepotName_Italian_02",
    "$DepotName_Italian_03",
    "$DepotName_Italian_04",
    "$DepotName_Italian_05",
    "$DepotName_Italian_06",
    "$DepotName_Italian_07",
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "GennaCrimeFamilySweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_Italian"

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "GENNA_CRIME_FAMILY_FACTION_INFO"
_abstract = true
faction = "GENNA_CRIME_FAMILY"

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
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
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
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
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
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 2, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
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
GENNA_CRIME_FAMILY MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_MELEE"
telemetryId = "GCF1"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_MELEE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_1", -- Character Variant Data
    "GENNA_CRIME_FAMILY_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Average Melee
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_MELEE"
telemetryId = "GCF2"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_MELEE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Strong Melee
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_MELEE"
telemetryId = "GCF3"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_MELEE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Elite Melee
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_MELEE"
telemetryId = "GCF4"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_MELEE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_MELEE"
telemetryId = "GCF5"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_MELEE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Weak Handgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_HANDGUN"
telemetryId = "GCF6"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_HANDGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Average Handgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_HANDGUN"
telemetryId = "GCF7"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_HANDGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Strong Handgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_HANDGUN"
telemetryId = "GCF8"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_HANDGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Elite Handgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_HANDGUN"
telemetryId = "GCF9"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_HANDGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_HANDGUN"
telemetryId = "GCF10"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_HANDGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_SHOTGUN"
telemetryId = "GCF11"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_SHOTGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Average Shotgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_SHOTGUN"
telemetryId = "GCF12"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_SHOTGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_SHOTGUN"
telemetryId = "GCF13"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_SHOTGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_SHOTGUN"
telemetryId = "GCF14"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_SHOTGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_SHOTGUN"
telemetryId = "GCF15"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_SHOTGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Weak Rifle
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_RIFLE"
telemetryId = "GCF16"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_RIFLE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_RIFLE"
telemetryId = "GCF17"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_RIFLE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_RIFLE"
telemetryId = "GCF18"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_RIFLE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_RIFLE"
telemetryId = "GCF19"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_RIFLE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RIFLE"
telemetryId = "GCF20"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_RIFLE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_SUBGUN"
telemetryId = "GCF21"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_SUBGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_SUBGUN"
telemetryId = "GCF22"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_SUBGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_SUBGUN"
telemetryId = "GCF23"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_SUBGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_SUBGUN"
telemetryId = "GCF24"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_SUBGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_SUBGUN"
telemetryId = "GCF25"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_SUBGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_HIREDGUN_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_MACHINEGUN"
telemetryId = "GCF26"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_MACHINEGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_MACHINEGUN"
telemetryId = "GCF27"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_MACHINEGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_MACHINEGUN"
telemetryId = "GCF28"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_MACHINEGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_MACHINEGUN"
telemetryId = "GCF29"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_MACHINEGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_MACHINEGUN"
telemetryId = "GCF30"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_MACHINEGUN_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_SNIPER"
telemetryId = "GCF31"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_SNIPER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_SNIPER"
telemetryId = "GCF32"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_SNIPER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Strong Sniper
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_SNIPER"
telemetryId = "GCF33"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_SNIPER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_SNIPER"
telemetryId = "GCF34"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_SNIPER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_SNIPER"
telemetryId = "GCF35"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_SNIPER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_DOCTOR"
telemetryId = "GCF36"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_DOCTOR_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DOCTOR_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_DOCTOR"
telemetryId = "GCF37"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_DOCTOR_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DOCTOR_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_DOCTOR"
telemetryId = "GCF38"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_DOCTOR_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DOCTOR_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_DOCTOR"
telemetryId = "GCF39"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_DOCTOR_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DOCTOR_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_DOCTOR"
telemetryId = "GCF40"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_DOCTOR_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DOCTOR_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_GRENADE"
telemetryId = "GCF41"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_GRENADE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DEMOLITIONIST_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_GRENADE"
telemetryId = "GCF42"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_GRENADE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DEMOLITIONIST_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_GRENADE"
telemetryId = "GCF43"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_GRENADE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DEMOLITIONIST_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_GRENADE"
telemetryId = "GCF44"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_GRENADE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DEMOLITIONIST_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_GRENADE"
telemetryId = "GCF45"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_GRENADE_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_DEMOLITIONIST_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Weak Conartist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_CONARTIST"
telemetryId = "GCF46"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_CONARTIST_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Average Conartist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_CONARTIST"
telemetryId = "GCF47"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_CONARTIST_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Strong Conartist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_CONARTIST"
telemetryId = "GCF48"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_CONARTIST_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Elite Conartist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_CONARTIST"
telemetryId = "GCF49"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_CONARTIST_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_CONARTIST"
telemetryId = "GCF50"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_CONARTIST_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_CONARTIST_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_WEAK_ENFORCER"
telemetryId = "GCF51"
name = "$NPC_GENNA_CRIME_FAMILY_WEAK_ENFORCER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_1",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_AVERAGE_ENFORCER"
telemetryId = "GCF52"
name = "$NPC_GENNA_CRIME_FAMILY_AVERAGE_ENFORCER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_2",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_STRONG_ENFORCER"
telemetryId = "GCF53"
name = "$NPC_GENNA_CRIME_FAMILY_STRONG_ENFORCER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_3",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_ELITE_ENFORCER"
telemetryId = "GCF54"
name = "$NPC_GENNA_CRIME_FAMILY_ELITE_ENFORCER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_4",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT_ENFORCER"
telemetryId = "GCF55"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_ENFORCER_name" --$ Genna Crime Family Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "GENNA_CRIME_FAMILY_ENFORCER_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY Lieutenant
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_LIEUTENANT"
telemetryId = "GCF56"
name = "$NPC_GENNA_CRIME_FAMILY_LIEUTENANT_name" --$ Genna Crime Family Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
GENNA_CRIME_FAMILY UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "GENNA_CRIME_FAMILY_UNDERBOSS"
telemetryId = "GCF57"
name = "$NPC_GENNA_CRIME_FAMILY_UNDERBOSS_name" --$ Genna Crime Family Underboss
_variants = {numVariants = 8}
_includes =
{
    "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6",
    "GENNA_CRIME_FAMILY_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6" -- GENNA CRIME FAMILY UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_1" -- GENNA_CRIME_FAMILY MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_2" -- GENNA_CRIME_FAMILY MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_3" -- GENNA_CRIME_FAMILY MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_4" -- GENNA_CRIME_FAMILY MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_5" -- GENNA_CRIME_FAMILY FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_6" -- GENNA_CRIME_FAMILY FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_7" -- GENNA_CRIME_FAMILY FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_UNDERBOSS_RANK_6_VARIANT_8" -- GENNA_CRIME_FAMILY FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
GENNA CRIME FAMILY LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5" -- GENNA CRIME FAMILY LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_1" -- GENNA_CRIME_FAMILY MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_2" -- GENNA_CRIME_FAMILY MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_3" -- GENNA_CRIME_FAMILY MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_4" -- GENNA_CRIME_FAMILY MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_5" -- GENNA_CRIME_FAMILY FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_6" -- GENNA_CRIME_FAMILY FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_7" -- GENNA_CRIME_FAMILY FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "GENNA_CRIME_FAMILY_LIEUTENANT_RANK_5_VARIANT_8" -- GENNA_CRIME_FAMILY FEMALE 4 -- LIEUTENANT
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
        _id = "GENNA_CRIME_FAMILY_" .. roles[j] .. "_RANK_" .. k
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
                _id = "GENNA_CRIME_FAMILY_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
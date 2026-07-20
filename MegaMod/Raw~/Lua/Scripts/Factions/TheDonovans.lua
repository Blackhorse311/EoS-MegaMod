_namespace = "FACTION"
_id = "THE_DONOVANS"

_includes = "GANG_BASE"
stringsKey = "$Factions_TheDonovans"
locked=false
bossId = "CHARACTER.BOSS.DONOVANS_BOSS"
missionBossId = "NPC.MISSION_THE_DONOVANS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.FRANKIE_DONOVAN"
safehouseName = "$TheDonovansSafehouseName" --$ The Donovans' Safehouse

factionIcon = "TheDonovans"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/FrankieDonovan_Pose"
playable = true

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
primaryColor = "TheDonovans_Primary"
secondaryColor = "TheDonovans_Secondary"

audio =
{
    onSelect = { "AUDIO.BOSSES.DONOVAN.INTRO_1", "AUDIO.BOSSES.DONOVAN.INTRO_2", "AUDIO.BOSSES.DONOVAN.INTRO_3", "AUDIO.BOSSES.DONOVAN.INTRO_4",
                "AUDIO.BOSSES.DONOVAN.INTRO_5", "AUDIO.BOSSES.DONOVAN.INTRO_6", "AUDIO.BOSSES.DONOVAN.INTRO_7", "AUDIO.BOSSES.DONOVAN.INTRO_8" },
}

alwaysDropsLoot =
{
    "ITEM.WEAPON.UNIQUE_BOSS_13",
}

aiDiplomaticInventory =
{
    -- Weapons for Diplomatic Trade
    -- "ITEM.WEAPON.RARE_HANDGUN_01",
    "ITEM.WEAPON.RARE_HANDGUN_02",
    "ITEM.WEAPON.RARE_HANDGUN_03",
    -- "ITEM.WEAPON.RARE_HANDGUN_04",
    -- "ITEM.WEAPON.EPIC_HANDGUN_01",
    -- "ITEM.WEAPON.EPIC_HANDGUN_02",
    -- "ITEM.WEAPON.EPIC_HANDGUN_03",
    -- "ITEM.WEAPON.EPIC_HANDGUN_04",
    -- "ITEM.WEAPON.RARE_SHOTGUN_01",
    -- "ITEM.WEAPON.RARE_SHOTGUN_02",
    -- "ITEM.WEAPON.RARE_SHOTGUN_03",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_01",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_02",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_03",
    -- "ITEM.WEAPON.RARE_SUBGUN_01",
    -- "ITEM.WEAPON.RARE_SUBGUN_02",
    -- "ITEM.WEAPON.RARE_SUBGUN_04",
    "ITEM.WEAPON.EPIC_SUBGUN_01",
    -- "ITEM.WEAPON.EPIC_SUBGUN_02",
    -- "ITEM.WEAPON.EPIC_SUBGUN_04",
    -- "ITEM.WEAPON.RARE_RIFLE_01",
    -- "ITEM.WEAPON.RARE_RIFLE_02",
    -- "ITEM.WEAPON.RARE_RIFLE_03",
    "ITEM.WEAPON.EPIC_RIFLE_01",
    -- "ITEM.WEAPON.EPIC_RIFLE_02",
    -- "ITEM.WEAPON.EPIC_RIFLE_03",
    -- "ITEM.WEAPON.RARE_SNIPER_02",
    -- "ITEM.WEAPON.RARE_SNIPER_04",
    -- "ITEM.WEAPON.EPIC_SNIPER_02",
    "ITEM.WEAPON.EPIC_SNIPER_04",
    "ITEM.WEAPON.RARE_MACHINEGUN_01",
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
    "$DepotName_Irish_01",
    "$DepotName_Irish_02",
    "$DepotName_Irish_03",
    "$DepotName_Irish_04",
    "$DepotName_Irish_05",
    "$DepotName_Irish_06",
    "$DepotName_Irish_07",
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "TheDonovansSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_Irish"

--[[------------------------------------------------------------------------------
THE_DONOVANS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "THE_DONOVANS_FACTION_INFO"
_abstract = true
faction = "THE_DONOVANS"

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
THE_DONOVANS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE DONOVANS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_MELEE"
telemetryId = "TD1"
name = "$NPC_THE_DONOVANS_WEAK_MELEE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_1", -- Character Variant Data
    "THE_DONOVANS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
THE DONOVANS Average Melee
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_MELEE"
telemetryId = "TD2"
name = "$NPC_THE_DONOVANS_AVERAGE_MELEE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Strong Melee
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_MELEE"
telemetryId = "TD3"
name = "$NPC_THE_DONOVANS_STRONG_MELEE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Elite Melee
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_MELEE"
telemetryId = "TD4"
name = "$NPC_THE_DONOVANS_ELITE_MELEE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_MELEE"
telemetryId = "TD5"
name = "$NPC_THE_DONOVANS_LIEUTENANT_MELEE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
THE DONOVANS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_HANDGUN"
telemetryId = "TD6"
name = "$NPC_THE_DONOVANS_WEAK_HANDGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Average Handgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_HANDGUN"
telemetryId = "TD7"
name = "$NPC_THE_DONOVANS_AVERAGE_HANDGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_HANDGUN"
telemetryId = "TD8"
name = "$NPC_THE_DONOVANS_STRONG_HANDGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_HANDGUN"
telemetryId = "TD9"
name = "$NPC_THE_DONOVANS_ELITE_HANDGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_HANDGUN"
telemetryId = "TD10"
name = "$NPC_THE_DONOVANS_LIEUTENANT_HANDGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE DONOVANS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_SHOTGUN"
telemetryId = "TD11"
name = "$NPC_THE_DONOVANS_WEAK_SHOTGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_SHOTGUN"
telemetryId = "TD12"
name = "$NPC_THE_DONOVANS_AVERAGE_SHOTGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_SHOTGUN"
telemetryId = "TD13"
name = "$NPC_THE_DONOVANS_STRONG_SHOTGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_SHOTGUN"
telemetryId = "TD14"
name = "$NPC_THE_DONOVANS_ELITE_SHOTGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_SHOTGUN"
telemetryId = "TD15"
name = "$NPC_THE_DONOVANS_LIEUTENANT_SHOTGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
THE DONOVANS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_RIFLE"
telemetryId = "TD16"
name = "$NPC_THE_DONOVANS_WEAK_RIFLE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_RIFLE"
telemetryId = "TD17"
name = "$NPC_THE_DONOVANS_AVERAGE_RIFLE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_RIFLE"
telemetryId = "TD18"
name = "$NPC_THE_DONOVANS_STRONG_RIFLE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_RIFLE"
telemetryId = "TD19"
name = "$NPC_THE_DONOVANS_ELITE_RIFLE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_RIFLE"
telemetryId = "TD20"
name = "$NPC_THE_DONOVANS_LIEUTENANT_RIFLE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE DONOVANS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_SUBGUN"
telemetryId = "TD21"
name = "$NPC_THE_DONOVANS_WEAK_SUBGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_SUBGUN"
telemetryId = "TD22"
name = "$NPC_THE_DONOVANS_AVERAGE_SUBGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_SUBGUN"
telemetryId = "TD23"
name = "$NPC_THE_DONOVANS_STRONG_SUBGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_SUBGUN"
telemetryId = "TD24"
name = "$NPC_THE_DONOVANS_ELITE_SUBGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_SUBGUN"
telemetryId = "TD25"
name = "$NPC_THE_DONOVANS_LIEUTENANT_SUBGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_HIREDGUN_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE DONOVANS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_MACHINEGUN"
telemetryId = "TD26"
name = "$NPC_THE_DONOVANS_WEAK_MACHINEGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_MACHINEGUN"
telemetryId = "TD27"
name = "$NPC_THE_DONOVANS_AVERAGE_MACHINEGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_MACHINEGUN"
telemetryId = "TD28"
name = "$NPC_THE_DONOVANS_STRONG_MACHINEGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_MACHINEGUN"
telemetryId = "TD29"
name = "$NPC_THE_DONOVANS_ELITE_MACHINEGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_MACHINEGUN"
telemetryId = "TD30"
name = "$NPC_THE_DONOVANS_LIEUTENANT_MACHINEGUN_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
THE DONOVANS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_SNIPER"
telemetryId = "TD31"
name = "$NPC_THE_DONOVANS_WEAK_SNIPER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_SNIPER"
telemetryId = "TD32"
name = "$NPC_THE_DONOVANS_AVERAGE_SNIPER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_SNIPER"
telemetryId = "TD33"
name = "$NPC_THE_DONOVANS_STRONG_SNIPER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_SNIPER"
telemetryId = "TD34"
name = "$NPC_THE_DONOVANS_ELITE_SNIPER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_SNIPER"
telemetryId = "TD35"
name = "$NPC_THE_DONOVANS_LIEUTENANT_SNIPER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
THE DONOVANS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_DOCTOR"
telemetryId = "TD36"
name = "$NPC_THE_DONOVANS_WEAK_DOCTOR_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DOCTOR_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_DOCTOR"
telemetryId = "TD37"
name = "$NPC_THE_DONOVANS_AVERAGE_DOCTOR_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DOCTOR_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_DOCTOR"
telemetryId = "TD38"
name = "$NPC_THE_DONOVANS_STRONG_DOCTOR_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DOCTOR_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_DOCTOR"
telemetryId = "TD39"
name = "$NPC_THE_DONOVANS_ELITE_DOCTOR_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DOCTOR_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_DOCTOR"
telemetryId = "TD40"
name = "$NPC_THE_DONOVANS_LIEUTENANT_DOCTOR_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DOCTOR_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
THE DONOVANS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_GRENADE"
telemetryId = "TD41"
name = "$NPC_THE_DONOVANS_WEAK_GRENADE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DEMOLITIONIST_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_GRENADE"
telemetryId = "TD42"
name = "$NPC_THE_DONOVANS_AVERAGE_GRENADE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DEMOLITIONIST_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_GRENADE"
telemetryId = "TD43"
name = "$NPC_THE_DONOVANS_STRONG_GRENADE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DEMOLITIONIST_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_GRENADE"
telemetryId = "TD44"
name = "$NPC_THE_DONOVANS_ELITE_GRENADE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DEMOLITIONIST_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_GRENADE"
telemetryId = "TD45"
name = "$NPC_THE_DONOVANS_LIEUTENANT_GRENADE_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_DEMOLITIONIST_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
THE DONOVANS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_CONARTIST"
telemetryId = "TD46"
name = "$NPC_THE_DONOVANS_WEAK_CONARTIST_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Average Conartist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_CONARTIST"
telemetryId = "TD47"
name = "$NPC_THE_DONOVANS_AVERAGE_CONARTIST_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_CONARTIST"
telemetryId = "TD48"
name = "$NPC_THE_DONOVANS_STRONG_CONARTIST_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_CONARTIST"
telemetryId = "TD49"
name = "$NPC_THE_DONOVANS_ELITE_CONARTIST_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_CONARTIST"
telemetryId = "TD50"
name = "$NPC_THE_DONOVANS_LIEUTENANT_CONARTIST_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_CONARTIST_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
THE_DONOVANS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE DONOVANS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_WEAK_ENFORCER"
telemetryId = "TD51"
name = "$NPC_THE_DONOVANS_WEAK_ENFORCER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_1",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
THE DONOVANS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_AVERAGE_ENFORCER"
telemetryId = "TD52"
name = "$NPC_THE_DONOVANS_AVERAGE_ENFORCER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_2",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
THE DONOVANS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_STRONG_ENFORCER"
telemetryId = "TD53"
name = "$NPC_THE_DONOVANS_STRONG_ENFORCER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_3",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
THE DONOVANS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_ELITE_ENFORCER"
telemetryId = "TD54"
name = "$NPC_THE_DONOVANS_ELITE_ENFORCER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_4",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT_ENFORCER"
telemetryId = "TD55"
name = "$NPC_THE_DONOVANS_LIEUTENANT_ENFORCER_name" --$ The Donovans Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_DONOVANS_ENFORCER_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE DONOVANS Lieutenant
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_LIEUTENANT"
telemetryId = "TD56"
name = "$NPC_THE_DONOVANS_LIEUTENANT_name" --$ The Donovans Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "THE_DONOVANS_LIEUTENANT_RANK_5",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
THE_DONOVANS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE DONOVANS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "THE_DONOVANS_UNDERBOSS"
telemetryId = "TD57"
name = "$NPC_THE_DONOVANS_UNDERBOSS_name" --$ The Donovans Underboss
_variants = {numVariants = 8}
_includes =
{
    "THE_DONOVANS_UNDERBOSS_RANK_6",
    "THE_DONOVANS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE DONOVANS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE DONOVANS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "THE_DONOVANS_UNDERBOSS_RANK_6" -- THE DONOVANS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_1" -- THE_DONOVANS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_2" -- THE_DONOVANS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_3" -- THE_DONOVANS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_4" -- THE_DONOVANS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_5" -- THE_DONOVANS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_6" -- THE_DONOVANS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_7" -- THE_DONOVANS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_DONOVANS_UNDERBOSS_RANK_6_VARIANT_8" -- THE_DONOVANS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
THE DONOVANS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "THE_DONOVANS_LIEUTENANT_RANK_5" -- THE DONOVANS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_1" -- THE_DONOVANS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_2" -- THE_DONOVANS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_3" -- THE_DONOVANS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_4" -- THE_DONOVANS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_5" -- THE_DONOVANS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_6" -- THE_DONOVANS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_7" -- THE_DONOVANS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_DONOVANS_LIEUTENANT_RANK_5_VARIANT_8" -- THE_DONOVANS FEMALE 4 -- LIEUTENANT
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
        _id = "THE_DONOVANS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "THE_DONOVANS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
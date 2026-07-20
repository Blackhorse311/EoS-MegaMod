_namespace = "FACTION"
_id = "THE_OUTFIT"

_includes = "GANG_BASE"
stringsKey = "$Factions_TheOutfit"
bossId = "CHARACTER.BOSS.OUTFIT_BOSS"
missionBossId = "NPC.MISSION_THE_OUTFIT_BOSS"

personalityId = "FACTIONAI_PERSONALITIES.AL_CAPONE"

safehouseName = "$TheOutfitSafehouseName" --$ The Outfit's Safehouse

factionIcon = "TheOutfit"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/AlCapone_Pose"
playable = true
icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
primaryColor = "TheOutfit_Primary"
secondaryColor = "TheOutfit_Secondary"

audio =
{
    onSelect = { "AUDIO.BOSSES.CAPONE.INTRO_1", "AUDIO.BOSSES.CAPONE.INTRO_2", "AUDIO.BOSSES.CAPONE.INTRO_3", "AUDIO.BOSSES.CAPONE.INTRO_4",
    "AUDIO.BOSSES.CAPONE.INTRO_5", "AUDIO.BOSSES.CAPONE.INTRO_6", "AUDIO.BOSSES.CAPONE.INTRO_7", },
}

aiDiplomaticInventory =
{
    -- Weapons for Diplomatic Trade
    -- "ITEM.WEAPON.RARE_HANDGUN_01",
    -- "ITEM.WEAPON.RARE_HANDGUN_02",
    -- "ITEM.WEAPON.RARE_HANDGUN_03",
    "ITEM.WEAPON.RARE_HANDGUN_04",
    --"ITEM.WEAPON.EPIC_HANDGUN_01",
    "ITEM.WEAPON.EPIC_HANDGUN_02",
    -- "ITEM.WEAPON.EPIC_HANDGUN_03",
    -- "ITEM.WEAPON.EPIC_HANDGUN_04",
    -- "ITEM.WEAPON.RARE_SHOTGUN_01",
    -- "ITEM.WEAPON.RARE_SHOTGUN_02",
    -- "ITEM.WEAPON.RARE_SHOTGUN_03",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_01",
    "ITEM.WEAPON.EPIC_SHOTGUN_02",
    -- "ITEM.WEAPON.EPIC_SHOTGUN_03",
    -- "ITEM.WEAPON.RARE_SUBGUN_01",
    "ITEM.WEAPON.RARE_SUBGUN_02",
    -- "ITEM.WEAPON.RARE_SUBGUN_04",
    -- "ITEM.WEAPON.EPIC_SUBGUN_01",
    "ITEM.WEAPON.EPIC_SUBGUN_02",
    -- "ITEM.WEAPON.EPIC_SUBGUN_04",
    -- "ITEM.WEAPON.RARE_RIFLE_01",
    "ITEM.WEAPON.RARE_RIFLE_02",
    -- "ITEM.WEAPON.RARE_RIFLE_03",
    -- "ITEM.WEAPON.EPIC_RIFLE_01",
    -- "ITEM.WEAPON.EPIC_RIFLE_02",
    -- "ITEM.WEAPON.EPIC_RIFLE_03",
    -- "ITEM.WEAPON.RARE_SNIPER_02",
    -- "ITEM.WEAPON.RARE_SNIPER_04",
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
    "$DepotName_Italian_01", --$ Deano's Grill
    "$DepotName_Italian_02", --$ Gina's Townhouse
    "$DepotName_Italian_03", --$ Locatelli Ironworks
    "$DepotName_Italian_04", --$ Railroad Repairs Ltd. 
    "$DepotName_Italian_05", --$ Park Place Monastry
    "$DepotName_Italian_06", --$ West Avenue Auto Parts
    "$DepotName_Italian_07", --$ Barella Construction Ltd.
}


--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "TheOutfitSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_SalernoAmerican"

--[[------------------------------------------------------------------------------
THE_OUTFIT CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "THE_OUTFIT_FACTION_INFO"
_abstract = true
faction = "THE_OUTFIT"

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
    ["DOCTOR"] = {
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
THE_OUTFIT MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE OUTFIT WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_MELEE"
telemetryId = "OF1"
name = "$NPC_THE_OUTFIT_WEAK_MELEE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_1", -- Character Variant Data
    "THE_OUTFIT_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
THE OUTFIT Average Melee
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_MELEE"
telemetryId = "OF2"
name = "$NPC_THE_OUTFIT_AVERAGE_MELEE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Strong Melee
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_MELEE"
telemetryId = "OF3"
name = "$NPC_THE_OUTFIT_STRONG_MELEE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Elite Melee
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_MELEE"
telemetryId = "OF4"
name = "$NPC_THE_OUTFIT_ELITE_MELEE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_MELEE"
telemetryId = "OF5"
name = "$NPC_THE_OUTFIT_LIEUTENANT_MELEE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
THE OUTFIT Weak Handgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_HANDGUN"
telemetryId = "OF6"
name = "$NPC_THE_OUTFIT_WEAK_HANDGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Average Handgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_HANDGUN"
telemetryId = "OF7"
name = "$NPC_THE_OUTFIT_AVERAGE_HANDGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Strong Handgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_HANDGUN"
telemetryId = "OF8"
name = "$NPC_THE_OUTFIT_STRONG_HANDGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Elite Handgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_HANDGUN"
telemetryId = "OF9"
name = "$NPC_THE_OUTFIT_ELITE_HANDGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_HANDGUN"
telemetryId = "OF10"
name = "$NPC_THE_OUTFIT_LIEUTENANT_HANDGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE OUTFIT Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_SHOTGUN"
telemetryId = "OF11"
name = "$NPC_THE_OUTFIT_WEAK_SHOTGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Average Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_SHOTGUN"
telemetryId = "OF12"
name = "$NPC_THE_OUTFIT_AVERAGE_SHOTGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_SHOTGUN"
telemetryId = "OF13"
name = "$NPC_THE_OUTFIT_STRONG_SHOTGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_SHOTGUN"
telemetryId = "OF14"
name = "$NPC_THE_OUTFIT_ELITE_SHOTGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_SHOTGUN"
telemetryId = "OF15"
name = "$NPC_THE_OUTFIT_LIEUTENANT_SHOTGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
THE OUTFIT Weak Rifle
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_RIFLE"
telemetryId = "OF16"
name = "$NPC_THE_OUTFIT_WEAK_RIFLE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_RIFLE"
telemetryId = "OF17"
name = "$NPC_THE_OUTFIT_AVERAGE_RIFLE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_RIFLE"
telemetryId = "OF18"
name = "$NPC_THE_OUTFIT_STRONG_RIFLE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_RIFLE"
telemetryId = "OF19"
name = "$NPC_THE_OUTFIT_ELITE_RIFLE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_RIFLE"
telemetryId = "OF20"
name = "$NPC_THE_OUTFIT_LIEUTENANT_RIFLE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE OUTFIT WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_SUBGUN"
telemetryId = "OF21"
name = "$NPC_THE_OUTFIT_WEAK_SUBGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_SUBGUN"
telemetryId = "OF22"
name = "$NPC_THE_OUTFIT_AVERAGE_SUBGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_SUBGUN"
telemetryId = "OF23"
name = "$NPC_THE_OUTFIT_STRONG_SUBGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_SUBGUN"
telemetryId = "OF24"
name = "$NPC_THE_OUTFIT_ELITE_SUBGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_SUBGUN"
telemetryId = "OF25"
name = "$NPC_THE_OUTFIT_LIEUTENANT_SUBGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_HIREDGUN_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE OUTFIT WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_MACHINEGUN"
telemetryId = "OF26"
name = "$NPC_THE_OUTFIT_WEAK_MACHINEGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_MACHINEGUN"
telemetryId = "OF27"
name = "$NPC_THE_OUTFIT_AVERAGE_MACHINEGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_MACHINEGUN"
telemetryId = "OF28"
name = "$NPC_THE_OUTFIT_STRONG_MACHINEGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_MACHINEGUN"
telemetryId = "OF29"
name = "$NPC_THE_OUTFIT_ELITE_MACHINEGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_MACHINEGUN"
telemetryId = "OF30"
name = "$NPC_THE_OUTFIT_LIEUTENANT_MACHINEGUN_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
THE OUTFIT WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_SNIPER"
telemetryId = "OF31"
name = "$NPC_THE_OUTFIT_WEAK_SNIPER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_SNIPER"
telemetryId = "OF32"
name = "$NPC_THE_OUTFIT_AVERAGE_SNIPER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Strong Sniper
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_SNIPER"
telemetryId = "OF33"
name = "$NPC_THE_OUTFIT_STRONG_SNIPER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_SNIPER"
telemetryId = "OF34"
name = "$NPC_THE_OUTFIT_ELITE_SNIPER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_SNIPER"
telemetryId = "OF35"
name = "$NPC_THE_OUTFIT_LIEUTENANT_SNIPER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
THE OUTFIT WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_DOCTOR"
telemetryId = "OF36"
name = "$NPC_THE_OUTFIT_WEAK_DOCTOR_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DOCTOR_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_DOCTOR"
telemetryId = "OF37"
name = "$NPC_THE_OUTFIT_AVERAGE_DOCTOR_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DOCTOR_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_DOCTOR"
telemetryId = "OF38"
name = "$NPC_THE_OUTFIT_STRONG_DOCTOR_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DOCTOR_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_DOCTOR"
telemetryId = "OF39"
name = "$NPC_THE_OUTFIT_ELITE_DOCTOR_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DOCTOR_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_DOCTOR"
telemetryId = "OF40"
name = "$NPC_THE_OUTFIT_LIEUTENANT_DOCTOR_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DOCTOR_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
THE OUTFIT WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_GRENADE"
telemetryId = "OF41"
name = "$NPC_THE_OUTFIT_WEAK_GRENADE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DEMOLITIONIST_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_GRENADE"
telemetryId = "OF42"
name = "$NPC_THE_OUTFIT_AVERAGE_GRENADE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DEMOLITIONIST_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_GRENADE"
telemetryId = "OF43"
name = "$NPC_THE_OUTFIT_STRONG_GRENADE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DEMOLITIONIST_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_GRENADE"
telemetryId = "OF44"
name = "$NPC_THE_OUTFIT_ELITE_GRENADE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DEMOLITIONIST_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_GRENADE"
telemetryId = "OF45"
name = "$NPC_THE_OUTFIT_LIEUTENANT_GRENADE_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_DEMOLITIONIST_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
THE OUTFIT Weak Conartist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_CONARTIST"
telemetryId = "OF46"
name = "$NPC_THE_OUTFIT_WEAK_CONARTIST_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Average Conartist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_CONARTIST"
telemetryId = "OF47"
name = "$NPC_THE_OUTFIT_AVERAGE_CONARTIST_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Strong Conartist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_CONARTIST"
telemetryId = "OF48"
name = "$NPC_THE_OUTFIT_STRONG_CONARTIST_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Elite Conartist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_CONARTIST"
telemetryId = "OF49"
name = "$NPC_THE_OUTFIT_ELITE_CONARTIST_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_CONARTIST"
telemetryId = "OF50"
name = "$NPC_THE_OUTFIT_LIEUTENANT_CONARTIST_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_CONARTIST_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
THE_OUTFIT ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
THE OUTFIT WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_WEAK_ENFORCER"
telemetryId = "OF51"
name = "$NPC_THE_OUTFIT_WEAK_ENFORCER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_1",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
THE OUTFIT AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_AVERAGE_ENFORCER"
telemetryId = "OF52"
name = "$NPC_THE_OUTFIT_AVERAGE_ENFORCER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_2",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
THE OUTFIT STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_STRONG_ENFORCER"
telemetryId = "OF53"
name = "$NPC_THE_OUTFIT_STRONG_ENFORCER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_3",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
THE OUTFIT Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_ELITE_ENFORCER"
telemetryId = "OF54"
name = "$NPC_THE_OUTFIT_ELITE_ENFORCER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_4",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT_ENFORCER"
telemetryId = "OF55"
name = "$NPC_THE_OUTFIT_LIEUTENANT_ENFORCER_name" --$ The Outfit Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "THE_OUTFIT_ENFORCER_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE OUTFIT Lieutenant
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_LIEUTENANT"
telemetryId = "OF56"
name = "$NPC_THE_OUTFIT_LIEUTENANT_name" --$ The Outfit Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "THE_OUTFIT_LIEUTENANT_RANK_5",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
THE_OUTFIT UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE OUTFIT UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "THE_OUTFIT_UNDERBOSS"
telemetryId = "OF57"
name = "$NPC_THE_OUTFIT_UNDERBOSS_name" --$ The Outfit Underboss
_variants = {numVariants = 8}
_includes =
{
    "THE_OUTFIT_UNDERBOSS_RANK_6",
    "THE_OUTFIT_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE OUTFIT -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
THE OUTFIT SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "THE_OUTFIT_UNDERBOSS_RANK_6" -- THE OUTFIT UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_1" -- THE_OUTFIT MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_2" -- THE_OUTFIT MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_3" -- THE_OUTFIT MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_4" -- THE_OUTFIT MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_5" -- THE_OUTFIT FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_6" -- THE_OUTFIT FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_7" -- THE_OUTFIT FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_OUTFIT_UNDERBOSS_RANK_6_VARIANT_8" -- THE_OUTFIT FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
THE OUTFIT LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "THE_OUTFIT_LIEUTENANT_RANK_5" -- THE OUTFIT LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_1" -- THE_OUTFIT MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_2" -- THE_OUTFIT MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_3" -- THE_OUTFIT MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_4" -- THE_OUTFIT MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_5" -- THE_OUTFIT FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_6" -- THE_OUTFIT FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_7" -- THE_OUTFIT FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "THE_OUTFIT_LIEUTENANT_RANK_5_VARIANT_8" -- THE_OUTFIT FEMALE 4 -- LIEUTENANT
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
        _id = "THE_OUTFIT_" .. roles[j] .. "_RANK_" .. k
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
                _id = "THE_OUTFIT_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
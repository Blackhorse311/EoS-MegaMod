_namespace = "FACTION"
_id = "FORTUNE_TELLERS"

_includes = "GANG_BASE"
stringsKey = "$Factions_FortuneTellers"
bossId = "CHARACTER.BOSS.FORTUNETELLERS_BOSS"
missionBossId = "NPC.MISSION_FORTUNE_TELLERS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.GOLDIE_GARNEAU"
safehouseName = "$FortuneTellersSafehouseName" --$ Fortune Tellers' Safehouse

factionIcon = "FortuneTellers"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/GoldieGarneau_Pose"

playable = true

icon = "Sprites/Images/Characters/Profile/Cast/GoldieGarneau_Profile"

primaryColor = "FortuneTellers_Primary"
secondaryColor = "FortuneTellers_Secondary"

audio =
{
    onSelect = { "AUDIO.BOSSES.GOLDIE.INTRO_1", "AUDIO.BOSSES.GOLDIE.INTRO_2", "AUDIO.BOSSES.GOLDIE.INTRO_3", "AUDIO.BOSSES.GOLDIE.INTRO_4",
    "AUDIO.BOSSES.GOLDIE.INTRO_5", "AUDIO.BOSSES.GOLDIE.INTRO_6", "AUDIO.BOSSES.GOLDIE.INTRO_7" },
}

aiDiplomaticInventory =
{
    -- Weapons for Diplomatic Trade
    -- "ITEM.WEAPON.RARE_HANDGUN_01",
    -- "ITEM.WEAPON.RARE_HANDGUN_02",
    -- "ITEM.WEAPON.RARE_HANDGUN_03",
    "ITEM.WEAPON.RARE_HANDGUN_04",
    -- "ITEM.WEAPON.EPIC_HANDGUN_01",
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
    -- "ITEM.WEAPON.RARE_SUBGUN_02",
    -- "ITEM.WEAPON.RARE_SUBGUN_04",
    -- "ITEM.WEAPON.EPIC_SUBGUN_01",
    -- "ITEM.WEAPON.EPIC_SUBGUN_02",
    "ITEM.WEAPON.EPIC_SUBGUN_04",
    -- "ITEM.WEAPON.RARE_RIFLE_01",
    -- "ITEM.WEAPON.RARE_RIFLE_02",
    -- "ITEM.WEAPON.RARE_RIFLE_03",
    -- "ITEM.WEAPON.EPIC_RIFLE_01",
    "ITEM.WEAPON.EPIC_RIFLE_02",
    -- "ITEM.WEAPON.EPIC_RIFLE_03",
    -- "ITEM.WEAPON.RARE_SNIPER_02",
    -- "ITEM.WEAPON.RARE_SNIPER_04",
    "ITEM.WEAPON.EPIC_SNIPER_02",
    "ITEM.WEAPON.EPIC_SNIPER_04",
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
    "$DepotName_French_01",
    "$DepotName_French_02",
    "$DepotName_French_03",
    "$DepotName_French_04",
    "$DepotName_French_05",
    "$DepotName_French_06",
    "$DepotName_French_07",
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "FortuneTellersSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_FrenchCanadian"

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "FORTUNE_TELLERS_FACTION_INFO"
_abstract = true
faction = "FORTUNE_TELLERS"

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
        [0] = 4, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 4, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 1, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 1,  -- Female Variant 4 (American?/Italian?/Hispanic?)
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
        [5] = 2, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 2,  -- Female Variant 4 (American?/Italian?/Hispanic?)
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
FORTUNE_TELLERS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_MELEE"
telemetryId = "FT1"
name = "$NPC_FORTUNE_TELLERS_WEAK_MELEE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_1", -- Character Variant Data
    "FORTUNE_TELLERS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Average Melee
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_MELEE"
telemetryId = "FT2"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_MELEE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Strong Melee
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_MELEE"
telemetryId = "FT3"
name = "$NPC_FORTUNE_TELLERS_STRONG_MELEE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Elite Melee
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_MELEE"
telemetryId = "FT4"
name = "$NPC_FORTUNE_TELLERS_ELITE_MELEE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_MELEE"
telemetryId = "FT5"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_MELEE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_HANDGUN"
telemetryId = "FT6"
name = "$NPC_FORTUNE_TELLERS_WEAK_HANDGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Average Handgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_HANDGUN"
telemetryId = "FT7"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_HANDGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_HANDGUN"
telemetryId = "FT8"
name = "$NPC_FORTUNE_TELLERS_STRONG_HANDGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_HANDGUN"
telemetryId = "FT9"
name = "$NPC_FORTUNE_TELLERS_ELITE_HANDGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_HANDGUN"
telemetryId = "FT10"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_HANDGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_SHOTGUN"
telemetryId = "FT11"
name = "$NPC_FORTUNE_TELLERS_WEAK_SHOTGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_SHOTGUN"
telemetryId = "FT12"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_SHOTGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_SHOTGUN"
telemetryId = "FT13"
name = "$NPC_FORTUNE_TELLERS_STRONG_SHOTGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_SHOTGUN"
telemetryId = "FT14"
name = "$NPC_FORTUNE_TELLERS_ELITE_SHOTGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_SHOTGUN"
telemetryId = "FT15"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_SHOTGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_RIFLE"
telemetryId = "FT16"
name = "$NPC_FORTUNE_TELLERS_WEAK_RIFLE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_RIFLE"
telemetryId = "FT17"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_RIFLE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_RIFLE"
telemetryId = "FT18"
name = "$NPC_FORTUNE_TELLERS_STRONG_RIFLE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_RIFLE"
telemetryId = "FT19"
name = "$NPC_FORTUNE_TELLERS_ELITE_RIFLE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_RIFLE"
telemetryId = "FT20"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_RIFLE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
FORTUNE TELLERS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_SUBGUN"
telemetryId = "FT21"
name = "$NPC_FORTUNE_TELLERS_WEAK_SUBGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_SUBGUN"
telemetryId = "FT22"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_SUBGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_SUBGUN"
telemetryId = "FT23"
name = "$NPC_FORTUNE_TELLERS_STRONG_SUBGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_SUBGUN"
telemetryId = "FT24"
name = "$NPC_FORTUNE_TELLERS_ELITE_SUBGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_SUBGUN"
telemetryId = "FT25"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_SUBGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_HIREDGUN_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_MACHINEGUN"
telemetryId = "FT26"
name = "$NPC_FORTUNE_TELLERS_WEAK_MACHINEGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_MACHINEGUN"
telemetryId = "FT27"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_MACHINEGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_MACHINEGUN"
telemetryId = "FT28"
name = "$NPC_FORTUNE_TELLERS_STRONG_MACHINEGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_MACHINEGUN"
telemetryId = "FT29"
name = "$NPC_FORTUNE_TELLERS_ELITE_MACHINEGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_MACHINEGUN"
telemetryId = "FT30"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_MACHINEGUN_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_SNIPER"
telemetryId = "FT31"
name = "$NPC_FORTUNE_TELLERS_WEAK_SNIPER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_SNIPER"
telemetryId = "FT32"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_SNIPER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_SNIPER"
telemetryId = "FT33"
name = "$NPC_FORTUNE_TELLERS_STRONG_SNIPER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_SNIPER"
telemetryId = "FT34"
name = "$NPC_FORTUNE_TELLERS_ELITE_SNIPER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_SNIPER"
telemetryId = "FT35"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_SNIPER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_DOCTOR"
telemetryId = "FT36"
name = "$NPC_FORTUNE_TELLERS_WEAK_DOCTOR_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DOCTOR_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_DOCTOR"
telemetryId = "FT37"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_DOCTOR_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DOCTOR_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_DOCTOR"
telemetryId = "FT38"
name = "$NPC_FORTUNE_TELLERS_STRONG_DOCTOR_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DOCTOR_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_DOCTOR"
telemetryId = "FT39"
name = "$NPC_FORTUNE_TELLERS_ELITE_DOCTOR_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DOCTOR_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_DOCTOR"
telemetryId = "FT40"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_DOCTOR_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DOCTOR_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_GRENADE"
telemetryId = "FT41"
name = "$NPC_FORTUNE_TELLERS_WEAK_GRENADE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DEMOLITIONIST_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_GRENADE"
telemetryId = "FT42"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_GRENADE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DEMOLITIONIST_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_GRENADE"
telemetryId = "FT43"
name = "$NPC_FORTUNE_TELLERS_STRONG_GRENADE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DEMOLITIONIST_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_GRENADE"
telemetryId = "FT44"
name = "$NPC_FORTUNE_TELLERS_ELITE_GRENADE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DEMOLITIONIST_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_GRENADE"
telemetryId = "FT45"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_GRENADE_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_DEMOLITIONIST_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_CONARTIST"
telemetryId = "FT46"
name = "$NPC_FORTUNE_TELLERS_WEAK_CONARTIST_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Average Conartist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_CONARTIST"
telemetryId = "FT47"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_CONARTIST_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_CONARTIST"
telemetryId = "FT48"
name = "$NPC_FORTUNE_TELLERS_STRONG_CONARTIST_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_CONARTIST"
telemetryId = "FT49"
name = "$NPC_FORTUNE_TELLERS_ELITE_CONARTIST_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_CONARTIST"
telemetryId = "FT50"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_CONARTIST_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_CONARTIST_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
FORTUNE_TELLERS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
FORTUNE TELLERS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_WEAK_ENFORCER"
telemetryId = "FT51"
name = "$NPC_FORTUNE_TELLERS_WEAK_ENFORCER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_1",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_AVERAGE_ENFORCER"
telemetryId = "FT52"
name = "$NPC_FORTUNE_TELLERS_AVERAGE_ENFORCER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_2",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_STRONG_ENFORCER"
telemetryId = "FT53"
name = "$NPC_FORTUNE_TELLERS_STRONG_ENFORCER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_3",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_ELITE_ENFORCER"
telemetryId = "FT54"
name = "$NPC_FORTUNE_TELLERS_ELITE_ENFORCER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_4",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT_ENFORCER"
telemetryId = "FT55"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_ENFORCER_name" --$ Fortune Teller Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "FORTUNE_TELLERS_ENFORCER_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
FORTUNE TELLERS Lieutenant
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_LIEUTENANT"
telemetryId = "FT56"
name = "$NPC_FORTUNE_TELLERS_LIEUTENANT_name" --$ Fortune Teller Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "FORTUNE_TELLERS_LIEUTENANT_RANK_5",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
FORTUNE_TELLERS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
FORTUNE TELLERS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "FORTUNE_TELLERS_UNDERBOSS"
telemetryId = "FT57"
name = "$NPC_FORTUNE_TELLERS_UNDERBOSS_name" --$ Fortune Teller Underboss
_variants = {numVariants = 8}
_includes =
{
    "FORTUNE_TELLERS_UNDERBOSS_RANK_6",
    "FORTUNE_TELLERS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
FORTUNE TELLERS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
FORTUNE TELLERS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6" -- FORTUNE TELLERS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_1" -- FORTUNE_TELLERS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_2" -- FORTUNE_TELLERS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_3" -- FORTUNE_TELLERS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_4" -- FORTUNE_TELLERS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_5" -- FORTUNE_TELLERS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_6" -- FORTUNE_TELLERS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_7" -- FORTUNE_TELLERS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "FORTUNE_TELLERS_UNDERBOSS_RANK_6_VARIANT_8" -- FORTUNE_TELLERS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
FORTUNE TELLERS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5" -- FORTUNE TELLERS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_1" -- FORTUNE_TELLERS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_2" -- FORTUNE_TELLERS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_3" -- FORTUNE_TELLERS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_4" -- FORTUNE_TELLERS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_5" -- FORTUNE_TELLERS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_6" -- FORTUNE_TELLERS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_7" -- FORTUNE_TELLERS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "FORTUNE_TELLERS_LIEUTENANT_RANK_5_VARIANT_8" -- FORTUNE_TELLERS FEMALE 4 -- LIEUTENANT
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
        _id = "FORTUNE_TELLERS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "FORTUNE_TELLERS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
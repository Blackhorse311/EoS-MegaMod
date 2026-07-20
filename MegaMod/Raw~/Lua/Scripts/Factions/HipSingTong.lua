_namespace = "FACTION"
_id = "HIP_SING_TONG"

_includes = "GANG_BASE"
stringsKey = "$Factions_HipSingTong"
-- "$Factions_HipSingTong_Name" --$ Hip Sing Tong
playable = true

bossId = "CHARACTER.BOSS.HIPSINGTONG_BOSS"
missionBossId = "NPC.MISSION_HIP_SING_TONG_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.SAI_WING_MOCK"
safehouseName = "$HipSingTongSafehouseName" --$ Hip Sing Tong Safehouse

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
factionIcon = "HipSingTong"
primaryColor = "HipSingTong_Primary"
secondaryColor = "HipSingTong_Secondary"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/SaiWingMock_Pose"

audio =
{
    onSelect = { "AUDIO.BOSSES.MOCK.INTRO_1", "AUDIO.BOSSES.MOCK.INTRO_2", "AUDIO.BOSSES.MOCK.INTRO_3", "AUDIO.BOSSES.MOCK.INTRO_4",
    "AUDIO.BOSSES.MOCK.INTRO_5", "AUDIO.BOSSES.MOCK.INTRO_6", "AUDIO.BOSSES.MOCK.INTRO_7", "AUDIO.BOSSES.MOCK.INTRO_8", "AUDIO.BOSSES.MOCK.INTRO_9", },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_Chinese_01", --$ Xiao Hangzhou
    "$DepotName_Chinese_02", --$ Central Asian Market
    "$DepotName_Chinese_03", --$ Xi'an Rooms
    "$DepotName_Chinese_04", --$ Wuhan Road Station
    "$DepotName_Chinese_05", --$ Imperial Den
    "$DepotName_Chinese_06", --$ The Glass Temple
    "$DepotName_Chinese_07", --$ The Poppy Room
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]
sweetHomeChicagoEvent = "HipSingTongSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_Chinese"

--[[------------------------------------------------------------------------------
HIP_SING_TONG CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "HIP_SING_TONG_FACTION_INFO"
_abstract = true
faction = "HIP_SING_TONG"

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
        [3] = 1, -- Male Variant 3 (Asian)
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
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
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
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
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
        [2] = 0, -- Male Variant 2 (Black)
        [3] = 1, -- Male Variant 3 (Asian)
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
        [3] = 1, -- Male Variant 3 (Asian)
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 0, -- Female Variant 2 (Black/African American)
        [7] = 2, -- Female Variant 3 (Asian)
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
HIP_SING_TONG MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
HIP SING TONG WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_MELEE"
telemetryId = "HST1"
name = "$NPC_HIP_SING_TONG_WEAK_MELEE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_1", -- Character Variant Data
    "HIP_SING_TONG_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
HIP SING TONG Average Melee
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_MELEE"
telemetryId = "HST2"
name = "$NPC_HIP_SING_TONG_AVERAGE_MELEE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Strong Melee
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_MELEE"
telemetryId = "HST3"
name = "$NPC_HIP_SING_TONG_STRONG_MELEE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Elite Melee
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_MELEE"
telemetryId = "HST4"
name = "$NPC_HIP_SING_TONG_ELITE_MELEE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_MELEE"
telemetryId = "HST5"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_MELEE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
HIP SING TONG Weak Handgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_HANDGUN"
telemetryId = "HST6"
name = "$NPC_HIP_SING_TONG_WEAK_HANDGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Average Handgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_HANDGUN"
telemetryId = "HST7"
name = "$NPC_HIP_SING_TONG_AVERAGE_HANDGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Strong Handgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_HANDGUN"
telemetryId = "HST8"
name = "$NPC_HIP_SING_TONG_STRONG_HANDGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Elite Handgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_HANDGUN"
telemetryId = "HST9"
name = "$NPC_HIP_SING_TONG_ELITE_HANDGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_HANDGUN"
telemetryId = "HST10"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_HANDGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
HIP SING TONG Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_SHOTGUN"
telemetryId = "HST11"
name = "$NPC_HIP_SING_TONG_WEAK_SHOTGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Average Shotgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_SHOTGUN"
telemetryId = "HST12"
name = "$NPC_HIP_SING_TONG_AVERAGE_SHOTGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_SHOTGUN"
telemetryId = "HST13"
name = "$NPC_HIP_SING_TONG_STRONG_SHOTGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_SHOTGUN"
telemetryId = "HST14"
name = "$NPC_HIP_SING_TONG_ELITE_SHOTGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_SHOTGUN"
telemetryId = "HST15"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_SHOTGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
HIP SING TONG Weak Rifle
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_RIFLE"
telemetryId = "HST16"
name = "$NPC_HIP_SING_TONG_WEAK_RIFLE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_RIFLE"
telemetryId = "HST17"
name = "$NPC_HIP_SING_TONG_AVERAGE_RIFLE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_RIFLE"
telemetryId = "HST18"
name = "$NPC_HIP_SING_TONG_STRONG_RIFLE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_RIFLE"
telemetryId = "HST19"
name = "$NPC_HIP_SING_TONG_ELITE_RIFLE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_RIFLE"
telemetryId = "HST20"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_RIFLE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
HIP SING TONG WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_SUBGUN"
telemetryId = "HST21"
name = "$NPC_HIP_SING_TONG_WEAK_SUBGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_SUBGUN"
telemetryId = "HST22"
name = "$NPC_HIP_SING_TONG_AVERAGE_SUBGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_SUBGUN"
telemetryId = "HST23"
name = "$NPC_HIP_SING_TONG_STRONG_SUBGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_SUBGUN"
telemetryId = "HST24"
name = "$NPC_HIP_SING_TONG_ELITE_SUBGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_SUBGUN"
telemetryId = "HST25"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_SUBGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_HIREDGUN_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
HIP SING TONG WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_MACHINEGUN"
telemetryId = "HST26"
name = "$NPC_HIP_SING_TONG_WEAK_MACHINEGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_MACHINEGUN"
telemetryId = "HST27"
name = "$NPC_HIP_SING_TONG_AVERAGE_MACHINEGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_MACHINEGUN"
telemetryId = "HST28"
name = "$NPC_HIP_SING_TONG_STRONG_MACHINEGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_MACHINEGUN"
telemetryId = "HST29"
name = "$NPC_HIP_SING_TONG_ELITE_MACHINEGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_MACHINEGUN"
telemetryId = "HST30"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_MACHINEGUN_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
HIP SING TONG WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_SNIPER"
telemetryId = "HST31"
name = "$NPC_HIP_SING_TONG_WEAK_SNIPER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_SNIPER"
telemetryId = "HST32"
name = "$NPC_HIP_SING_TONG_AVERAGE_SNIPER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Strong Sniper
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_SNIPER"
telemetryId = "HST33"
name = "$NPC_HIP_SING_TONG_STRONG_SNIPER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_SNIPER"
telemetryId = "HST34"
name = "$NPC_HIP_SING_TONG_ELITE_SNIPER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_SNIPER"
telemetryId = "HST35"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_SNIPER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
HIP SING TONG WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_DOCTOR"
telemetryId = "HST36"
name = "$NPC_HIP_SING_TONG_WEAK_DOCTOR_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DOCTOR_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_DOCTOR"
telemetryId = "HST37"
name = "$NPC_HIP_SING_TONG_AVERAGE_DOCTOR_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DOCTOR_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_DOCTOR"
telemetryId = "HST38"
name = "$NPC_HIP_SING_TONG_STRONG_DOCTOR_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DOCTOR_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_DOCTOR"
telemetryId = "HST39"
name = "$NPC_HIP_SING_TONG_ELITE_DOCTOR_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DOCTOR_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_DOCTOR"
telemetryId = "HST40"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_DOCTOR_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DOCTOR_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
HIP SING TONG WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_GRENADE"
telemetryId = "HST41"
name = "$NPC_HIP_SING_TONG_WEAK_GRENADE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DEMOLITIONIST_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_GRENADE"
telemetryId = "HST42"
name = "$NPC_HIP_SING_TONG_AVERAGE_GRENADE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DEMOLITIONIST_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_GRENADE"
telemetryId = "HST43"
name = "$NPC_HIP_SING_TONG_STRONG_GRENADE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DEMOLITIONIST_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_GRENADE"
telemetryId = "HST44"
name = "$NPC_HIP_SING_TONG_ELITE_GRENADE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DEMOLITIONIST_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_GRENADE"
telemetryId = "HST45"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_GRENADE_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_DEMOLITIONIST_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
HIP SING TONG Weak Conartist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_CONARTIST"
telemetryId = "HST46"
name = "$NPC_HIP_SING_TONG_WEAK_CONARTIST_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Average Conartist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_CONARTIST"
telemetryId = "HST47"
name = "$NPC_HIP_SING_TONG_AVERAGE_CONARTIST_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Strong Conartist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_CONARTIST"
telemetryId = "HST48"
name = "$NPC_HIP_SING_TONG_STRONG_CONARTIST_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Elite Conartist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_CONARTIST"
telemetryId = "HST49"
name = "$NPC_HIP_SING_TONG_ELITE_CONARTIST_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_CONARTIST"
telemetryId = "HST50"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_CONARTIST_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_CONARTIST_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
HIP_SING_TONG ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
HIP SING TONG WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_WEAK_ENFORCER"
telemetryId = "HST51"
name = "$NPC_HIP_SING_TONG_WEAK_ENFORCER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_1",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
HIP SING TONG AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_AVERAGE_ENFORCER"
telemetryId = "HST52"
name = "$NPC_HIP_SING_TONG_AVERAGE_ENFORCER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_2",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
HIP SING TONG STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_STRONG_ENFORCER"
telemetryId = "HST53"
name = "$NPC_HIP_SING_TONG_STRONG_ENFORCER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_3",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
HIP SING TONG Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_ELITE_ENFORCER"
telemetryId = "HST54"
name = "$NPC_HIP_SING_TONG_ELITE_ENFORCER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_4",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT_ENFORCER"
telemetryId = "HST55"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_ENFORCER_name" --$ Hip Sing Tong Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "HIP_SING_TONG_ENFORCER_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
HIP SING TONG Lieutenant
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_LIEUTENANT"
telemetryId = "HST56"
name = "$NPC_HIP_SING_TONG_LIEUTENANT_name" --$ Hip Sing Tong Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "HIP_SING_TONG_LIEUTENANT_RANK_5",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
HIP_SING_TONG UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
HIP SING TONG UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "HIP_SING_TONG_UNDERBOSS"
telemetryId = "HST57"
name = "$NPC_HIP_SING_TONG_UNDERBOSS_name" --$ Hip Sing Tong Underboss
_variants = {numVariants = 8}
_includes =
{
    "HIP_SING_TONG_UNDERBOSS_RANK_6",
    "HIP_SING_TONG_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
HIP SING TONG -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
HIP SING TONG SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6" -- HIP SING TONG UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_1" -- HIP_SING_TONG MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_2" -- HIP_SING_TONG MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_3" -- HIP_SING_TONG MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_4" -- HIP_SING_TONG MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_5" -- HIP_SING_TONG FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_6" -- HIP_SING_TONG FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_7" -- HIP_SING_TONG FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "HIP_SING_TONG_UNDERBOSS_RANK_6_VARIANT_8" -- HIP_SING_TONG FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
HIP SING TONG LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5" -- HIP SING TONG LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_1" -- HIP_SING_TONG MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_2" -- HIP_SING_TONG MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_3" -- HIP_SING_TONG MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_4" -- HIP_SING_TONG MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_5" -- HIP_SING_TONG FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_6" -- HIP_SING_TONG FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_7" -- HIP_SING_TONG FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "HIP_SING_TONG_LIEUTENANT_RANK_5_VARIANT_8" -- HIP_SING_TONG FEMALE 4 -- LIEUTENANT
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
        _id = "HIP_SING_TONG_" .. roles[j] .. "_RANK_" .. k
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
                _id = "HIP_SING_TONG_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
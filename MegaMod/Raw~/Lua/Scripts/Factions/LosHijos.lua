_namespace = "FACTION"
_id = "LOS_HIJOS"

_includes = "GANG_BASE"
stringsKey = "$Factions_LosHijos"
-- "$Factions_LosHijos_Name" --$ Los Hijos de la Llorona
playable = true

bossId = "CHARACTER.BOSS.LOSHIJOS_BOSS"
missionBossId = "NPC.MISSION_LOS_HIJOS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.SALAZAR_REYNA"
safehouseName = "$LosHijosSafehouseName" --$ Los Hijos de la Llorona Safehouse

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
factionIcon = "LosHijos"
primaryColor = "LosHijos_Primary"
secondaryColor = "LosHijos_Secondary"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/SalazarReyna_Pose"

audio =
{
    onSelect = { "AUDIO.BOSSES.REYNA.INTRO_1", "AUDIO.BOSSES.REYNA.INTRO_2", "AUDIO.BOSSES.REYNA.INTRO_3", "AUDIO.BOSSES.REYNA.INTRO_4", "AUDIO.BOSSES.REYNA.INTRO_5" },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_Hispanic_01",
    "$DepotName_Hispanic_02",
    "$DepotName_Hispanic_03",
    "$DepotName_Hispanic_04",
    "$DepotName_Hispanic_05",
    "$DepotName_Hispanic_06",
    "$DepotName_Hispanic_07",
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]
sweetHomeChicagoEvent = "LosHijosSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_Mexican"

--[[------------------------------------------------------------------------------
LOS_HIJOS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "LOS_HIJOS_FACTION_INFO"
_abstract = true
faction = "LOS_HIJOS"

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
        [4] = 3, -- Male Variant 4 (Italian?/Hispanic?)
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
        [2] = 4, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 12, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
        [7] = 0, -- Female Variant 3 (Asian)
        [8] = 2,  -- Female Variant 4 (American?/Italian?/Hispanic?)
    },
    ["ENFORCER"] = {
        -- Male Variants
        -- NOTE: Male Variant 0 and 1 are the same, and ratios will act like they are added together essentially.
        [0] = 0, -- Male Variant 0 (American?/Irish?/Italian?)
        [1] = 0, -- Male Variant 1 (American?/Irish?/Italian?)
        [2] = 1, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 3, -- Male Variant 4 (Italian?/Hispanic?)
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
        [4] = 3, -- Male Variant 4 (Italian?/Hispanic?)
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
        [2] = 4, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 12, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
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
LOS_HIJOS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS HIJOS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_MELEE"
telemetryId = "LH1"
name = "$NPC_LOS_HIJOS_WEAK_MELEE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_1", -- Character Variant Data
    "LOS_HIJOS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
LOS HIJOS Average Melee
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_MELEE"
telemetryId = "LH2"
name = "$NPC_LOS_HIJOS_AVERAGE_MELEE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Strong Melee
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_MELEE"
telemetryId = "LH3"
name = "$NPC_LOS_HIJOS_STRONG_MELEE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Elite Melee
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_MELEE"
telemetryId = "LH4"
name = "$NPC_LOS_HIJOS_ELITE_MELEE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_MELEE"
telemetryId = "LH5"
name = "$NPC_LOS_HIJOS_LIEUTENANT_MELEE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
LOS HIJOS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_HANDGUN"
telemetryId = "LH6"
name = "$NPC_LOS_HIJOS_WEAK_HANDGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Average Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_HANDGUN"
telemetryId = "LH7"
name = "$NPC_LOS_HIJOS_AVERAGE_HANDGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_HANDGUN"
telemetryId = "LH8"
name = "$NPC_LOS_HIJOS_STRONG_HANDGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_HANDGUN"
telemetryId = "LH9"
name = "$NPC_LOS_HIJOS_ELITE_HANDGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_HANDGUN"
telemetryId = "LH10"
name = "$NPC_LOS_HIJOS_LIEUTENANT_HANDGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS HIJOS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_SHOTGUN"
telemetryId = "LH11"
name = "$NPC_LOS_HIJOS_WEAK_SHOTGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_SHOTGUN"
telemetryId = "LH12"
name = "$NPC_LOS_HIJOS_AVERAGE_SHOTGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_SHOTGUN"
telemetryId = "LH13"
name = "$NPC_LOS_HIJOS_STRONG_SHOTGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_SHOTGUN"
telemetryId = "LH14"
name = "$NPC_LOS_HIJOS_ELITE_SHOTGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_SHOTGUN"
telemetryId = "LH15"
name = "$NPC_LOS_HIJOS_LIEUTENANT_SHOTGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
LOS HIJOS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_RIFLE"
telemetryId = "LH16"
name = "$NPC_LOS_HIJOS_WEAK_RIFLE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_RIFLE"
telemetryId = "LH17"
name = "$NPC_LOS_HIJOS_AVERAGE_RIFLE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_RIFLE"
telemetryId = "LH18"
name = "$NPC_LOS_HIJOS_STRONG_RIFLE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_RIFLE"
telemetryId = "LH19"
name = "$NPC_LOS_HIJOS_ELITE_RIFLE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_RIFLE"
telemetryId = "LH20"
name = "$NPC_LOS_HIJOS_LIEUTENANT_RIFLE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS HIJOS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_SUBGUN"
telemetryId = "LH21"
name = "$NPC_LOS_HIJOS_WEAK_SUBGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_SUBGUN"
telemetryId = "LH22"
name = "$NPC_LOS_HIJOS_AVERAGE_SUBGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_SUBGUN"
telemetryId = "LH23"
name = "$NPC_LOS_HIJOS_STRONG_SUBGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_SUBGUN"
telemetryId = "LH24"
name = "$NPC_LOS_HIJOS_ELITE_SUBGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_SUBGUN"
telemetryId = "LH25"
name = "$NPC_LOS_HIJOS_LIEUTENANT_SUBGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_HIREDGUN_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS HIJOS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_MACHINEGUN"
telemetryId = "LH26"
name = "$NPC_LOS_HIJOS_WEAK_MACHINEGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_MACHINEGUN"
telemetryId = "LH27"
name = "$NPC_LOS_HIJOS_AVERAGE_MACHINEGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_MACHINEGUN"
telemetryId = "LH28"
name = "$NPC_LOS_HIJOS_STRONG_MACHINEGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_MACHINEGUN"
telemetryId = "LH29"
name = "$NPC_LOS_HIJOS_ELITE_MACHINEGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_MACHINEGUN"
telemetryId = "LH30"
name = "$NPC_LOS_HIJOS_LIEUTENANT_MACHINEGUN_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
LOS HIJOS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_SNIPER"
telemetryId = "LH31"
name = "$NPC_LOS_HIJOS_WEAK_SNIPER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_SNIPER"
telemetryId = "LH32"
name = "$NPC_LOS_HIJOS_AVERAGE_SNIPER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_SNIPER"
telemetryId = "LH33"
name = "$NPC_LOS_HIJOS_STRONG_SNIPER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_SNIPER"
telemetryId = "LH34"
name = "$NPC_LOS_HIJOS_ELITE_SNIPER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_SNIPER"
telemetryId = "LH35"
name = "$NPC_LOS_HIJOS_LIEUTENANT_SNIPER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
LOS HIJOS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_DOCTOR"
telemetryId = "LH36"
name = "$NPC_LOS_HIJOS_WEAK_DOCTOR_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DOCTOR_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_DOCTOR"
telemetryId = "LH37"
name = "$NPC_LOS_HIJOS_AVERAGE_DOCTOR_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DOCTOR_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_DOCTOR"
telemetryId = "LH38"
name = "$NPC_LOS_HIJOS_STRONG_DOCTOR_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DOCTOR_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_DOCTOR"
telemetryId = "LH39"
name = "$NPC_LOS_HIJOS_ELITE_DOCTOR_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DOCTOR_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_DOCTOR"
telemetryId = "LH40"
name = "$NPC_LOS_HIJOS_LIEUTENANT_DOCTOR_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DOCTOR_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
LOS HIJOS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_GRENADE"
telemetryId = "LH41"
name = "$NPC_LOS_HIJOS_WEAK_GRENADE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DEMOLITIONIST_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_GRENADE"
telemetryId = "LH42"
name = "$NPC_LOS_HIJOS_AVERAGE_GRENADE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DEMOLITIONIST_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_GRENADE"
telemetryId = "LH43"
name = "$NPC_LOS_HIJOS_STRONG_GRENADE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DEMOLITIONIST_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_GRENADE"
telemetryId = "LH44"
name = "$NPC_LOS_HIJOS_ELITE_GRENADE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DEMOLITIONIST_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_GRENADE"
telemetryId = "LH45"
name = "$NPC_LOS_HIJOS_LIEUTENANT_GRENADE_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_DEMOLITIONIST_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
LOS HIJOS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_CONARTIST"
telemetryId = "LH46"
name = "$NPC_LOS_HIJOS_WEAK_CONARTIST_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Average Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_CONARTIST"
telemetryId = "LH47"
name = "$NPC_LOS_HIJOS_AVERAGE_CONARTIST_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_CONARTIST"
telemetryId = "LH48"
name = "$NPC_LOS_HIJOS_STRONG_CONARTIST_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_CONARTIST"
telemetryId = "LH49"
name = "$NPC_LOS_HIJOS_ELITE_CONARTIST_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_CONARTIST"
telemetryId = "LH50"
name = "$NPC_LOS_HIJOS_LIEUTENANT_CONARTIST_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_CONARTIST_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
LOS_HIJOS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS HIJOS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_WEAK_ENFORCER"
telemetryId = "LH51"
name = "$NPC_LOS_HIJOS_WEAK_ENFORCER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_1",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS HIJOS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_AVERAGE_ENFORCER"
telemetryId = "LH52"
name = "$NPC_LOS_HIJOS_AVERAGE_ENFORCER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_2",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS HIJOS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_STRONG_ENFORCER"
telemetryId = "LH53"
name = "$NPC_LOS_HIJOS_STRONG_ENFORCER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_3",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS HIJOS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_ELITE_ENFORCER"
telemetryId = "LH54"
name = "$NPC_LOS_HIJOS_ELITE_ENFORCER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_4",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT_ENFORCER"
telemetryId = "LH55"
name = "$NPC_LOS_HIJOS_LIEUTENANT_ENFORCER_name" --$ Los Hijos Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_HIJOS_ENFORCER_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS HIJOS Lieutenant
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_LIEUTENANT"
telemetryId = "LH56"
name = "$NPC_LOS_HIJOS_LIEUTENANT_name" --$ Los Hijos Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "LOS_HIJOS_LIEUTENANT_RANK_5",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
LOS_HIJOS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS HIJOS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "LOS_HIJOS_UNDERBOSS"
telemetryId = "LH57"
name = "$NPC_LOS_HIJOS_UNDERBOSS_name" --$ Los Hijos Underboss
_variants = {numVariants = 8}
_includes =
{
    "LOS_HIJOS_UNDERBOSS_RANK_6",
    "LOS_HIJOS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS HIJOS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS HIJOS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "LOS_HIJOS_UNDERBOSS_RANK_6" -- LOS HIJOS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_1" -- LOS_HIJOS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_2" -- LOS_HIJOS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_3" -- LOS_HIJOS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_4" -- LOS_HIJOS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_5" -- LOS_HIJOS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_6" -- LOS_HIJOS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_7" -- LOS_HIJOS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_HIJOS_UNDERBOSS_RANK_6_VARIANT_8" -- LOS_HIJOS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
LOS HIJOS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "LOS_HIJOS_LIEUTENANT_RANK_5" -- LOS HIJOS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_1" -- LOS_HIJOS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_2" -- LOS_HIJOS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_3" -- LOS_HIJOS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_4" -- LOS_HIJOS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_5" -- LOS_HIJOS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_6" -- LOS_HIJOS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_7" -- LOS_HIJOS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_HIJOS_LIEUTENANT_RANK_5_VARIANT_8" -- LOS_HIJOS FEMALE 4 -- LIEUTENANT
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
        _id = "LOS_HIJOS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "LOS_HIJOS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
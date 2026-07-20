_namespace = "FACTION"
_id = "LOS_LUCEROS"

_includes = "GANG_BASE"
stringsKey = "$Factions_LosLuceros"
locked=false
bossId = "CHARACTER.BOSS.LOSLUCEROS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.ELVIRA_DUARTE"
safehouseName = "$LosLucerosSafehouseName" --$ Los Luceros' Safehouse
missionBossId = "NPC.MISSION_LOS_LUCEROS_BOSS"

factionIcon = "LosLuceros"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/ElviraDuarte_Pose"

audio =
{
    onSelect = { "AUDIO.BOSSES.ELVIRA.INTRO_1", "AUDIO.BOSSES.ELVIRA.INTRO_2", "AUDIO.BOSSES.ELVIRA.INTRO_3", "AUDIO.BOSSES.ELVIRA.INTRO_4",
    "AUDIO.BOSSES.ELVIRA.INTRO_5","AUDIO.BOSSES.ELVIRA.INTRO_6","AUDIO.BOSSES.ELVIRA.INTRO_7", },
}

playable = true

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
primaryColor = "LosLuceros_Primary"
secondaryColor = "LosLuceros_Secondary"
startingInventory =
{
}

depotNames =
{
    "$DepotName_Hispanic_01", --$ Tianguis Grande
    "$DepotName_Hispanic_02", --$ Hillary Arcade
    "$DepotName_Hispanic_03", --$ Plaza Tampico
    "$DepotName_Hispanic_04", --$ El Mercado Leche
    "$DepotName_Hispanic_05", --$ El Palacio
    "$DepotName_Hispanic_06", --$ Casa Villalobos
    "$DepotName_Hispanic_07", --$ Pascal Avenue Motel
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]
sweetHomeChicagoEvent = "LosLucerosSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_Mexican"

--[[------------------------------------------------------------------------------
LOS_LUCEROS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "LOS_LUCEROS_FACTION_INFO"
_abstract = true
faction = "LOS_LUCEROS"

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
LOS_LUCEROS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS LUCEROS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_MELEE"
telemetryId = "LL1"
name = "$NPC_LOS_LUCEROS_WEAK_MELEE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_1", -- Character Variant Data
    "LOS_LUCEROS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Average Melee
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_MELEE"
telemetryId = "LL2"
name = "$NPC_LOS_LUCEROS_AVERAGE_MELEE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Strong Melee
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_MELEE"
telemetryId = "LL3"
name = "$NPC_LOS_LUCEROS_STRONG_MELEE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Elite Melee
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_MELEE"
telemetryId = "LL4"
name = "$NPC_LOS_LUCEROS_ELITE_MELEE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_MELEE"
telemetryId = "LL5"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_MELEE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
LOS LUCEROS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_HANDGUN"
telemetryId = "LL6"
name = "$NPC_LOS_LUCEROS_WEAK_HANDGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Average Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_HANDGUN"
telemetryId = "LL7"
name = "$NPC_LOS_LUCEROS_AVERAGE_HANDGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_HANDGUN"
telemetryId = "LL8"
name = "$NPC_LOS_LUCEROS_STRONG_HANDGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_HANDGUN"
telemetryId = "LL9"
name = "$NPC_LOS_LUCEROS_ELITE_HANDGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_HANDGUN"
telemetryId = "LL10"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_HANDGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS LUCEROS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_SHOTGUN"
telemetryId = "LL11"
name = "$NPC_LOS_LUCEROS_WEAK_SHOTGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_SHOTGUN"
telemetryId = "LL12"
name = "$NPC_LOS_LUCEROS_AVERAGE_SHOTGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_SHOTGUN"
telemetryId = "LL13"
name = "$NPC_LOS_LUCEROS_STRONG_SHOTGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_SHOTGUN"
telemetryId = "LL14"
name = "$NPC_LOS_LUCEROS_ELITE_SHOTGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_SHOTGUN"
telemetryId = "LL15"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_SHOTGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
LOS LUCEROS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_RIFLE"
telemetryId = "LL16"
name = "$NPC_LOS_LUCEROS_WEAK_RIFLE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_RIFLE"
telemetryId = "LL17"
name = "$NPC_LOS_LUCEROS_AVERAGE_RIFLE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_RIFLE"
telemetryId = "LL18"
name = "$NPC_LOS_LUCEROS_STRONG_RIFLE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_RIFLE"
telemetryId = "LL19"
name = "$NPC_LOS_LUCEROS_ELITE_RIFLE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_RIFLE"
telemetryId = "LL20"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_RIFLE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS LUCEROS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_SUBGUN"
telemetryId = "LL21"
name = "$NPC_LOS_LUCEROS_WEAK_SUBGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_SUBGUN"
telemetryId = "LL22"
name = "$NPC_LOS_LUCEROS_AVERAGE_SUBGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_SUBGUN"
telemetryId = "LL23"
name = "$NPC_LOS_LUCEROS_STRONG_SUBGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_SUBGUN"
telemetryId = "LL24"
name = "$NPC_LOS_LUCEROS_ELITE_SUBGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_SUBGUN"
telemetryId = "LL25"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_SUBGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_HIREDGUN_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS LUCEROS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_MACHINEGUN"
telemetryId = "LL26"
name = "$NPC_LOS_LUCEROS_WEAK_MACHINEGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_MACHINEGUN"
telemetryId = "LL27"
name = "$NPC_LOS_LUCEROS_AVERAGE_MACHINEGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_MACHINEGUN"
telemetryId = "LL28"
name = "$NPC_LOS_LUCEROS_STRONG_MACHINEGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_MACHINEGUN"
telemetryId = "LL29"
name = "$NPC_LOS_LUCEROS_ELITE_MACHINEGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_MACHINEGUN"
telemetryId = "LL30"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_MACHINEGUN_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
LOS LUCEROS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_SNIPER"
telemetryId = "LL31"
name = "$NPC_LOS_LUCEROS_WEAK_SNIPER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_SNIPER"
telemetryId = "LL32"
name = "$NPC_LOS_LUCEROS_AVERAGE_SNIPER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_SNIPER"
telemetryId = "LL33"
name = "$NPC_LOS_LUCEROS_STRONG_SNIPER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_SNIPER"
telemetryId = "LL34"
name = "$NPC_LOS_LUCEROS_ELITE_SNIPER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_SNIPER"
telemetryId = "LL35"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_SNIPER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
LOS LUCEROS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_DOCTOR"
telemetryId = "LL36"
name = "$NPC_LOS_LUCEROS_WEAK_DOCTOR_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DOCTOR_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_DOCTOR"
telemetryId = "LL37"
name = "$NPC_LOS_LUCEROS_AVERAGE_DOCTOR_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DOCTOR_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_DOCTOR"
telemetryId = "LL38"
name = "$NPC_LOS_LUCEROS_STRONG_DOCTOR_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DOCTOR_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_DOCTOR"
telemetryId = "LL39"
name = "$NPC_LOS_LUCEROS_ELITE_DOCTOR_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DOCTOR_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_DOCTOR"
telemetryId = "LL40"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_DOCTOR_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DOCTOR_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
LOS LUCEROS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_GRENADE"
telemetryId = "LL41"
name = "$NPC_LOS_LUCEROS_WEAK_GRENADE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DEMOLITIONIST_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_GRENADE"
telemetryId = "LL42"
name = "$NPC_LOS_LUCEROS_AVERAGE_GRENADE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DEMOLITIONIST_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_GRENADE"
telemetryId = "LL43"
name = "$NPC_LOS_LUCEROS_STRONG_GRENADE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DEMOLITIONIST_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_GRENADE"
telemetryId = "LL44"
name = "$NPC_LOS_LUCEROS_ELITE_GRENADE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DEMOLITIONIST_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_GRENADE"
telemetryId = "LL45"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_GRENADE_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_DEMOLITIONIST_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
LOS LUCEROS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_CONARTIST"
telemetryId = "LL46"
name = "$NPC_LOS_LUCEROS_WEAK_CONARTIST_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Average Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_CONARTIST"
telemetryId = "LL47"
name = "$NPC_LOS_LUCEROS_AVERAGE_CONARTIST_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_CONARTIST"
telemetryId = "LL48"
name = "$NPC_LOS_LUCEROS_STRONG_CONARTIST_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_CONARTIST"
telemetryId = "LL49"
name = "$NPC_LOS_LUCEROS_ELITE_CONARTIST_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_CONARTIST"
telemetryId = "LL50"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_CONARTIST_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_CONARTIST_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
LOS_LUCEROS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
LOS LUCEROS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_WEAK_ENFORCER"
telemetryId = "LL51"
name = "$NPC_LOS_LUCEROS_WEAK_ENFORCER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_1",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_AVERAGE_ENFORCER"
telemetryId = "LL52"
name = "$NPC_LOS_LUCEROS_AVERAGE_ENFORCER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_2",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_STRONG_ENFORCER"
telemetryId = "LL53"
name = "$NPC_LOS_LUCEROS_STRONG_ENFORCER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_3",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_ELITE_ENFORCER"
telemetryId = "LL54"
name = "$NPC_LOS_LUCEROS_ELITE_ENFORCER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_4",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT_ENFORCER"
telemetryId = "LL55"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_ENFORCER_name" --$ Los Luceros Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "LOS_LUCEROS_ENFORCER_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS LUCEROS Lieutenant
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_LIEUTENANT"
telemetryId = "LL56"
name = "$NPC_LOS_LUCEROS_LIEUTENANT_name" --$ Los Luceros Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "LOS_LUCEROS_LIEUTENANT_RANK_5",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
LOS_LUCEROS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS LUCEROS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "LOS_LUCEROS_UNDERBOSS"
telemetryId = "LL57"
name = "$NPC_LOS_LUCEROS_UNDERBOSS_name" --$ Los Luceros Underboss
_variants = {numVariants = 8}
_includes =
{
    "LOS_LUCEROS_UNDERBOSS_RANK_6",
    "LOS_LUCEROS_FACTION_INFO",
    "NPC.BASE_UNDERBOSS",
}

--[[------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS LUCEROS -- CHARACTER VARIANT DATA
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
LOS LUCEROS SQUAD UNDERBOSS RANK 6
--------------------------------------------------------------------------------]]

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6" -- LOS LUCEROS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_1" -- LOS_LUCEROS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_2" -- LOS_LUCEROS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_3" -- LOS_LUCEROS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_4" -- LOS_LUCEROS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_5" -- LOS_LUCEROS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_6" -- LOS_LUCEROS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_7" -- LOS_LUCEROS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_LUCEROS_UNDERBOSS_RANK_6_VARIANT_8" -- LOS_LUCEROS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
LOS LUCEROS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5" -- LOS LUCEROS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_1" -- LOS_LUCEROS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_2" -- LOS_LUCEROS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_3" -- LOS_LUCEROS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_4" -- LOS_LUCEROS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_5" -- LOS_LUCEROS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_6" -- LOS_LUCEROS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_7" -- LOS_LUCEROS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "LOS_LUCEROS_LIEUTENANT_RANK_5_VARIANT_8" -- LOS_LUCEROS FEMALE 4 -- LIEUTENANT
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
        _id = "LOS_LUCEROS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "LOS_LUCEROS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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
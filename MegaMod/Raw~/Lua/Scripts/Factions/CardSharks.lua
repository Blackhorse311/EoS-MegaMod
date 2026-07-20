_namespace = "FACTION"
_id = "CARD_SHARKS"

_includes = "GANG_BASE"
stringsKey = "$Factions_CardSharks"
-- "$Factions_CardSharks_Name" --$ Card Sharks
playable = true

bossId = "CHARACTER.BOSS.CARDSHARKS_BOSS"
missionBossId = "NPC.MISSION_CARD_SHARKS_BOSS"
personalityId = "FACTIONAI_PERSONALITIES.STEPHANIE_ST_CLAIR"
safehouseName = "$CardSharksSafehouseName" --$ Card Sharks Family Safehouse

icon = "Sprites/Images/Characters/Profile/Extras/CivMale_01_Profile"
factionIcon = "CardSharks"
primaryColor = "CardSharks_Primary"
secondaryColor = "CardSharks_Secondary"

portraitImage = "Sprites/Images/Characters/FullBody/Cast/StephanieStClair_Pose"

audio =
{
    onSelect = { "AUDIO.BOSSES.STEPHANIE.INTRO_1", "AUDIO.BOSSES.STEPHANIE.INTRO_2", "AUDIO.BOSSES.STEPHANIE.INTRO_3", "AUDIO.BOSSES.STEPHANIE.INTRO_4", },
}

startingInventory =
{
}

depotNames =
{
    "$DepotName_French_01", --$ La Galarie
    "$DepotName_French_02", --$ L'Arcade du Bois
    "$DepotName_French_03", --$ Avenue Rouge
    "$DepotName_French_04", --$ Maison du Guerre
    "$DepotName_French_05", --$ La Place Clémence
    "$DepotName_French_06", --$ Depot des Vandals
    "$DepotName_French_07", --$ Café Depardieu
}

--[[------------------------------------------------------------------------------
FACTION MISSIONS
--------------------------------------------------------------------------------]]

sweetHomeChicagoEvent = "CardSharksSweetHomeChicago"
sweetHomeChicagoStartTime = 10

--[[------------------------------------------------------------------------------
BOSS SELECTION BONUS ICONS
--------------------------------------------------------------------------------]]

-- BOSS FLAG ICON
factionFlag = "Sprites/SelectFaction/Flag_French"

--[[------------------------------------------------------------------------------
CARD_SHARKS CHARACTER & SQUAD DATA
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "CARD_SHARKS_FACTION_INFO"
_abstract = true
faction = "CARD_SHARKS"

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
        [2] = 4, -- Male Variant 2 (Black)
        [3] = 0, -- Male Variant 3 (Asian)
        [4] = 0, -- Male Variant 4 (Italian?/Hispanic?)
        -- Female Variants
        [5] = 0, -- Female Variant 1 (American?/Irish?)
        [6] = 1, -- Female Variant 2 (Black/African American)
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
        [6] = 2, -- Female Variant 2 (Black/African American)
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
CARD_SHARKS MELEE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK MELEE
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_MELEE"
telemetryId = "CS1"
name = "$NPC_CARD_SHARKS_WEAK_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_1", -- Character Variant Data
    "CARD_SHARKS_FACTION_INFO", -- Faction Specific Data
    "NPC.BASE_MELEE_TIER_1", -- Character Role, Squad, Stats and Inventory Data
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Melee
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_MELEE"
telemetryId = "CS2"
name = "$NPC_CARD_SHARKS_AVERAGE_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Melee
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_MELEE"
telemetryId = "CS3"
name = "$NPC_CARD_SHARKS_STRONG_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Melee
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_MELEE"
telemetryId = "CS4"
name = "$NPC_CARD_SHARKS_ELITE_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT MELEE
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_MELEE"
telemetryId = "CS5"
name = "$NPC_CARD_SHARKS_LIEUTENANT_MELEE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MELEE_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS HANDGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Handgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_HANDGUN"
telemetryId = "CS6"
name = "$NPC_CARD_SHARKS_WEAK_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Handgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_HANDGUN"
telemetryId = "CS7"
name = "$NPC_CARD_SHARKS_AVERAGE_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Handgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_HANDGUN"
telemetryId = "CS8"
name = "$NPC_CARD_SHARKS_STRONG_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Handgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_HANDGUN"
telemetryId = "CS9"
name = "$NPC_CARD_SHARKS_ELITE_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT HANDGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_HANDGUN"
telemetryId = "CS10"
name = "$NPC_CARD_SHARKS_LIEUTENANT_HANDGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_HANDGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS SHOTGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Shotgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_SHOTGUN"
telemetryId = "CS11"
name = "$NPC_CARD_SHARKS_WEAK_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Shotgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_SHOTGUN"
telemetryId = "CS12"
name = "$NPC_CARD_SHARKS_AVERAGE_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Shotgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_SHOTGUN"
telemetryId = "CS13"
name = "$NPC_CARD_SHARKS_STRONG_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Shotgun
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_SHOTGUN"
telemetryId = "CS14"
name = "$NPC_CARD_SHARKS_ELITE_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT SHOTGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_SHOTGUN"
telemetryId = "CS15"
name = "$NPC_CARD_SHARKS_LIEUTENANT_SHOTGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SHOTGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS RIFLE ROLES
--------------------------------------------------------------------------------]]
local currentRole = "HIREDGUN"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Rifle
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_RIFLE"
telemetryId = "CS16"
name = "$NPC_CARD_SHARKS_WEAK_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE RIFLE
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_RIFLE"
telemetryId = "CS17"
name = "$NPC_CARD_SHARKS_AVERAGE_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG RIFLE
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_RIFLE"
telemetryId = "CS18"
name = "$NPC_CARD_SHARKS_STRONG_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE RIFLE
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_RIFLE"
telemetryId = "CS19"
name = "$NPC_CARD_SHARKS_ELITE_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT RIFLE
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_RIFLE"
telemetryId = "CS20"
name = "$NPC_CARD_SHARKS_LIEUTENANT_RIFLE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_RIFLE_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS SUBGUN ROLES
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS WEAK SUBGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_SUBGUN"
telemetryId = "CS21"
name = "$NPC_CARD_SHARKS_WEAK_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE SUBGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_SUBGUN"
telemetryId = "CS22"
name = "$NPC_CARD_SHARKS_AVERAGE_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong SUBGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_SUBGUN"
telemetryId = "CS23"
name = "$NPC_CARD_SHARKS_STRONG_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite SUBGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_SUBGUN"
telemetryId = "CS24"
name = "$NPC_CARD_SHARKS_ELITE_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT SUBGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_SUBGUN"
telemetryId = "CS25"
name = "$NPC_CARD_SHARKS_LIEUTENANT_SUBGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_HIREDGUN_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SUBGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS MACHINEGUN ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_MACHINEGUN"
telemetryId = "CS26"
name = "$NPC_CARD_SHARKS_WEAK_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_MACHINEGUN"
telemetryId = "CS27"
name = "$NPC_CARD_SHARKS_AVERAGE_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_MACHINEGUN"
telemetryId = "CS28"
name = "$NPC_CARD_SHARKS_STRONG_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_MACHINEGUN"
telemetryId = "CS29"
name = "$NPC_CARD_SHARKS_ELITE_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT MACHINEGUN
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_MACHINEGUN"
telemetryId = "CS30"
name = "$NPC_CARD_SHARKS_LIEUTENANT_MACHINEGUN_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_MACHINEGUN_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS SNIPER ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK SNIPER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_SNIPER"
telemetryId = "CS31"
name = "$NPC_CARD_SHARKS_WEAK_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE SNIPER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_SNIPER"
telemetryId = "CS32"
name = "$NPC_CARD_SHARKS_AVERAGE_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Sniper
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_SNIPER"
telemetryId = "CS33"
name = "$NPC_CARD_SHARKS_STRONG_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE SNIPER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_SNIPER"
telemetryId = "CS34"
name = "$NPC_CARD_SHARKS_ELITE_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT SNIPER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_SNIPER"
telemetryId = "CS35"
name = "$NPC_CARD_SHARKS_LIEUTENANT_SNIPER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_SNIPER_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS MOB DOCTOR ROLES
--------------------------------------------------------------------------------]]
currentRole = "DOCTOR"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK DOCTOR
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_DOCTOR"
telemetryId = "CS36"
name = "$NPC_CARD_SHARKS_WEAK_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DOCTOR_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE DOCTOR
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_DOCTOR"
telemetryId = "CS37"
name = "$NPC_CARD_SHARKS_AVERAGE_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DOCTOR_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG DOCTOR
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_DOCTOR"
telemetryId = "CS38"
name = "$NPC_CARD_SHARKS_STRONG_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DOCTOR_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE DOCTOR
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_DOCTOR"
telemetryId = "CS39"
name = "$NPC_CARD_SHARKS_ELITE_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DOCTOR_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT DOCTOR
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_DOCTOR"
telemetryId = "CS40"
name = "$NPC_CARD_SHARKS_LIEUTENANT_DOCTOR_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DOCTOR_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DOCTOR_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS DEMOLITIONIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "DEMOLITIONIST"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK Demolitionist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_GRENADE"
telemetryId = "CS41"
name = "$NPC_CARD_SHARKS_WEAK_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DEMOLITIONIST_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE Demolitionist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_GRENADE"
telemetryId = "CS42"
name = "$NPC_CARD_SHARKS_AVERAGE_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DEMOLITIONIST_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG Demolitionist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_GRENADE"
telemetryId = "CS43"
name = "$NPC_CARD_SHARKS_STRONG_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DEMOLITIONIST_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS ELITE DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_GRENADE"
telemetryId = "CS44"
name = "$NPC_CARD_SHARKS_ELITE_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DEMOLITIONIST_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT DEMOLITIONIST
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_GRENADE"
telemetryId = "CS45"
name = "$NPC_CARD_SHARKS_LIEUTENANT_GRENADE_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_DEMOLITIONIST_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_DEMOLITIONIST_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS CONARTIST ROLES
--------------------------------------------------------------------------------]]
currentRole = "CONARTIST"
--[[------------------------------------------------------------------------------
ALLEY CATS Weak Conartist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_CONARTIST"
telemetryId = "CS46"
name = "$NPC_CARD_SHARKS_WEAK_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Average Conartist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_CONARTIST"
telemetryId = "CS47"
name = "$NPC_CARD_SHARKS_AVERAGE_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Strong Conartist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_CONARTIST"
telemetryId = "CS48"
name = "$NPC_CARD_SHARKS_STRONG_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite Conartist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_CONARTIST"
telemetryId = "CS49"
name = "$NPC_CARD_SHARKS_ELITE_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT Conartist
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_CONARTIST"
telemetryId = "CS50"
name = "$NPC_CARD_SHARKS_LIEUTENANT_CONARTIST_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_CONARTIST_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_CONARTIST_TIER_5",
}


--[[------------------------------------------------------------------------------
CARD_SHARKS ENFORCER ROLES
--------------------------------------------------------------------------------]]
currentRole = "ENFORCER"
--[[------------------------------------------------------------------------------
ALLEY CATS WEAK ENFORCER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_WEAK_ENFORCER"
telemetryId = "CS51"
name = "$NPC_CARD_SHARKS_WEAK_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_1",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_1",
}

--[[------------------------------------------------------------------------------
ALLEY CATS AVERAGE ENFORCER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_AVERAGE_ENFORCER"
telemetryId = "CS52"
name = "$NPC_CARD_SHARKS_AVERAGE_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_2",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_2",
}

--[[------------------------------------------------------------------------------
ALLEY CATS STRONG ENFORCER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_STRONG_ENFORCER"
telemetryId = "CS53"
name = "$NPC_CARD_SHARKS_STRONG_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_3",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_3",
}

--[[------------------------------------------------------------------------------
ALLEY CATS Elite ENFORCER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_ELITE_ENFORCER"
telemetryId = "CS54"
name = "$NPC_CARD_SHARKS_ELITE_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_4",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_4",
}

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT ENFORCER
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT_ENFORCER"
telemetryId = "CS55"
name = "$NPC_CARD_SHARKS_LIEUTENANT_ENFORCER_name" --$ Alley Cat Guard
_variants = {numVariants = variant_total_weights[currentRole]}
_includes =
{
    "CARD_SHARKS_ENFORCER_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_ENFORCER_TIER_5",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS LIEUTENANT ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS Lieutenant
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_LIEUTENANT"
telemetryId = "CS56"
name = "$NPC_CARD_SHARKS_LIEUTENANT_name" --$ Alley Cat Lieutenant
_variants = {numVariants = 8}
_includes =
{
    "CARD_SHARKS_LIEUTENANT_RANK_5",
    "CARD_SHARKS_FACTION_INFO",
    "NPC.BASE_LIEUTENANT",
}

--[[------------------------------------------------------------------------------
CARD_SHARKS UNDERBOSS ROLE
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
ALLEY CATS UNDERBOSS
--------------------------------------------------------------------------------]]
_id = "CARD_SHARKS_UNDERBOSS"
telemetryId = "CS57"
name = "$NPC_CARD_SHARKS_UNDERBOSS_name" --$ Alley Cat Underboss
_variants = {numVariants = 8}
_includes =
{
    "CARD_SHARKS_UNDERBOSS_RANK_6",
    "CARD_SHARKS_FACTION_INFO",
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

_id = "CARD_SHARKS_UNDERBOSS_RANK_6" -- ALLEY CATS UNDERBOSS
_includes = {"NPC.SQUAD_MALE_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_1" -- CARD_SHARKS MALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_2" -- CARD_SHARKS MALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_3" -- CARD_SHARKS MALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_4" -- CARD_SHARKS MALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_MALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_5" -- CARD_SHARKS FEMALE 1 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_1_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_6" -- CARD_SHARKS FEMALE 2 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_2_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_7" -- CARD_SHARKS FEMALE 3 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_3_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "CARD_SHARKS_UNDERBOSS_RANK_6_VARIANT_8" -- CARD_SHARKS FEMALE 4 -- UNDERBOSS
_includes = {"NPC.SQUAD_FEMALE_4_UNDERBOSS", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

--[[------------------------------------------------------------------------------
ALLEY CATS LIEUTENANT RANK 5
--------------------------------------------------------------------------------]]

_id = "CARD_SHARKS_LIEUTENANT_RANK_5" -- ALLEY CATS LIEUTENANT
_includes = {"NPC.SQUAD_MALE_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_1" -- CARD_SHARKS MALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_2" -- CARD_SHARKS MALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_3" -- CARD_SHARKS MALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_4" -- CARD_SHARKS MALE 4 -- LIEUTENANT
_includes = {"NPC.SQUAD_MALE_4_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_MALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_5" -- CARD_SHARKS FEMALE 1 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_1_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_6" -- CARD_SHARKS FEMALE 2 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_2_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_7" -- CARD_SHARKS FEMALE 3 -- LIEUTENANT
_includes = {"NPC.SQUAD_FEMALE_3_LIEUTENANT", "AUDIO.GUARD.PACKS.GUARD_FEMALE"}
_abstract = true

_id = "CARD_SHARKS_LIEUTENANT_RANK_5_VARIANT_8" -- CARD_SHARKS FEMALE 4 -- LIEUTENANT
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
        _id = "CARD_SHARKS_" .. roles[j] .. "_RANK_" .. k
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
                _id = "CARD_SHARKS_" .. roles[j] .. "_RANK_" .. k .. "_VARIANT_" .. var_num
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

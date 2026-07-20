_namespace = "WORLD"

_id = "INIT"

maxGangsters = 60
rivalFactionRatingRange = {300, 4000}
cashPercentageOnBossDeath = 30
numMoles = 1
moleActivationYear = 1925
-- extraMoleChance = {0.5, 1, 1, 0.25, 1, 0.1, 0.1} -- 50% of 3 more moles, 25% of 2 more moles, 10% chance 1 more, 10% chance 1 more
extraMoleChance = {0}

-- The minimum number of neighborhoods that the player can select when starting a new game
minNumNeighborhoods = 7

-- The minimum number of enemies that the player can select when starting a new game
minNumEnemies = 7

-- The amount of available precincts after major factions have been assigned that should be minor factions
newGameMinorFactionRatio = 0.333

-- The num of thug rackets to create in the player starting precinct
newGameNumPlayerPrecinctThugRackets = 3

-- The minimum number of racket buildings that must be present in the player starting precinct
newGameMinPlayerPrecinctBuildings = 6  -- Bar, Brewery, 3 Thug rackets + 1 to buy

-- The minimum number of racket buildings that must be present in the secondary starting precinct
newGameMinPlayerSecondaryPrecinctBuildings = 3

-- The ratio of new game buildings that are derelict inside thug precincts
newGameThugPrecinctDerelictRatio = 0.7

-- As per design request on EOS-18147
-- this amount is to make sure that ransacking is worth it to the player
staticBaseRansackCashDrop = 200

defaultShopSellPriceRatio = 0.15 -- The percentage of an item's purchase cost that you can sell the item at

precinctBaseValue = 500 -- The base cash value of a precinct

-- Max amount of gangsters that you can hire
minCrewSize = 10
maxCrewSize = 100

factions =
  {
    -- Influence Factions
    ["FACTION.CITIZENS"] = true,
    ["FACTION.CHICAGO_POLICE"] = true,
    ["FACTION.BUREAU_OF_PROHIBITION"] = true,
    ["FACTION.BUREAU_OF_INVESTIGATION"] = true,
    ["FACTION.FIRE_DEPARTMENT"] = true,

    -- Playable Factions
    ["FACTION.THE_OUTFIT"] = true,
    ["FACTION.WHITE_CITY_CIRCUS"] = true,
    ["FACTION.VICE_KINGS"] = true,
    ["FACTION.LOS_LUCEROS"] = true,
    ["FACTION.THE_NORTHSIDE_MOB"] = true,
    ["FACTION.THE_DONOVANS"] = true,
    ["FACTION.RAGENS_COLTS"] = true,
    ["FACTION.SALTIS_MCERLANE"] = true,
    ["FACTION.FORTUNE_TELLERS"] = true,
    ["FACTION.GENNA_CRIME_FAMILY"] = true,
    ["FACTION.CARD_SHARKS"] = true,
    ["FACTION.LOS_HIJOS"] = true,
    ["FACTION.HIP_SING_TONG"] = true,
    ["FACTION.ALLEY_CATS"] = true,

    -- Non Playable Factions
    ["FACTION.THE_MEAT_PACKERS"] = true,
    ["FACTION.THUGS"] = true,
    ["FACTION.FIVE_FAMILIES"] = true,
    ["FACTION.INDEPENDENT"] = true,
    ["FACTION.CANADIAN_MAPLE_ASSOCIATION"] = true,

    --Non Playable Mission Factions
    ["FACTION.QUEST_BUILDING_OWNER"] = true,
    
    ["FACTION.THE_COLLECTORS"] = true,
    ["FACTION.THE_LODGE"] = true,
    ["FACTION.WHITE_HAND_GANG"] = true,
    ["FACTION.BOBBY_CREW"] = true,
    ["FACTION.HOFFMANS_CREW"] = true,
    ["FACTION.THE_GOLDEN_TONG"] = true,
    ["FACTION.SCHULTZ_GANG"] = true,
    ["FACTION.SPIKES_CREW"] = true,
    ["FACTION.HIGHEST_CASINO"] = true,
    ["FACTION.SCISSORS_BLADES"] = true
  }

factionSafehouses =
  {
    -- currently playable factions
    [ "FACTION.THE_OUTFIT" ]            = "BUILDING.SAFEHOUSE.CAPONE_SAFEHOUSE",
    [ "FACTION.WHITE_CITY_CIRCUS" ]     = "BUILDING.SAFEHOUSE.DYER_SAFEHOUSE",
    [ "FACTION.VICE_KINGS" ]            = "BUILDING.SAFEHOUSE.MCKEE_SAFEHOUSE",
    [ "FACTION.LOS_LUCEROS" ]           = "BUILDING.SAFEHOUSE.DUARTE_SAFEHOUSE",
    [ "FACTION.THE_NORTHSIDE_MOB" ]     = "BUILDING.SAFEHOUSE.BANION_SAFEHOUSE",
    [ "FACTION.THE_DONOVANS" ]          = "BUILDING.SAFEHOUSE.DONOVAN_SAFEHOUSE",
    [ "FACTION.RAGENS_COLTS" ]          = "BUILDING.SAFEHOUSE.RAGEN_SAFEHOUSE",
    [ "FACTION.SALTIS_MCERLANE" ]       = "BUILDING.SAFEHOUSE.SALTIS_SAFEHOUSE",
    [ "FACTION.FORTUNE_TELLERS" ]       = "BUILDING.SAFEHOUSE.ROCKAFELLA_SAFEHOUSE",
    [ "FACTION.GENNA_CRIME_FAMILY" ]    = "BUILDING.SAFEHOUSE.GENNA_SAFEHOUSE",
    [ "FACTION.CARD_SHARKS" ]           = "BUILDING.SAFEHOUSE.CARDSHARKS_SAFEHOUSE",
    [ "FACTION.LOS_HIJOS" ]             = "BUILDING.SAFEHOUSE.LOSHIJOS_SAFEHOUSE",
    [ "FACTION.HIP_SING_TONG" ]         = "BUILDING.SAFEHOUSE.TONG_SAFEHOUSE",
    [ "FACTION.ALLEY_CATS" ]            = "BUILDING.SAFEHOUSE.ALLEY_CATS_SAFEHOUSE",
    -- TODO: soon-to-be playable factions
    [ "FACTION.THE_ROOKE_GANG" ]        = "BUILDING.SAFEHOUSE.ROOKE_SAFEHOUSE",
    -- non-playable faction safehoues
    [ "FACTION.THE_MEAT_PACKERS" ]      = "BUILDING.SAFEHOUSE.LITTLE_BOSS_SAFEHOUSE",
    [ "FACTION.THUGS" ]                 = "BUILDING.SAFEHOUSE.THUGS_SAFEHOUSE",
  }

safehouseSpecialItems =
  {
    "ITEM.WEAPON.UNCOMMON_SNIPER_02",
    "ITEM.WEAPON.UNCOMMON_SNIPER_04",
    "ITEM.WEAPON.UNCOMMON_SUBGUN_04",
    "ITEM.WEAPON.UNCOMMON_SHOTGUN_03",
    "ITEM.WEAPON.UNCOMMON_HANDGUN_03",
    "ITEM.WEAPON.UNCOMMON_HANDGUN_04",
    "ITEM.WEAPON.UNCOMMON_MACHINEGUN_01",
    "ITEM.WEAPON.UNCOMMON_RIFLE_02",
    "ITEM.ARMOR.ARMOR_03",
  }

agencies =
  {
    ["AGENCY.DUNBAR_BROTHERS"] = true,
    ["AGENCY.MONKS"] = true,
    ["AGENCY.COURTS_CHOIR"] = true,
    ["AGENCY.ILBILIARDO"] = true,
    ["AGENCY.CLEANERS"] = true,
    ["AGENCY.PINKERTONS"] = true,
    ["AGENCY.PAROLE_OFFICE"] = true,
    ["AGENCY.SWEETS_PARLOUR"] = true,
    ["AGENCY.ENCORE"] = true,
    ["AGENCY.SILVER_LINING_CLUB"] = true,
    ["AGENCY.THE_LODGE"] = true,
  }

followers =
  {
  }

-- ------------------------------------------------------------------------

_id = "LOOT_CRATES"

uncommon =
  {
    actorConfigId = "DYNAMIC_PROPS.LOOT_CRATE_UNCOMMON",
    dropWeight = 30,
    canDropRandomLoot = true,
    lootTableConfigId = "LOOT_CRATE_UNCOMMON",
    rollCount = 2
  }

rare =
  {
    actorConfigId = "DYNAMIC_PROPS.LOOT_CRATE_RARE",
    dropWeight = 20,
    canDropRandomLoot = true,
    lootTableConfigId = "LOOT_CRATE_RARE",
    rollCount = 2
  }

epic =
  {
    actorConfigId = "DYNAMIC_PROPS.LOOT_CRATE_EPIC",
    dropWeight = 10,
    canDropRandomLoot = true,
    lootTableConfigId = "LOOT_CRATE_EPIC",
    rollCount = 2
  }

legendary =
  {
    actorConfigId = "DYNAMIC_PROPS.LOOT_CRATE_LEGENDARY",
    canDropRandomLoot = false
  }

-- ------------------------------------------------------------------------

_id = "STORE_RESTOCK"

blackMarketStockCountMin = 800
blackMarketStockCountMax = 900

policeStoreStockCountMin = 20
policeStoreStockCountMax = 30

-- ------------------------------------------------------------------------

_id = "DIFFICULTY"

-- Bonus damage given to members of the player's faction, per difficulty level
playerFactionDamageMod =
  {
    [1] = 1.5,
    [2] = 1.25,
    [3] = 1,
    [4] = 1,
    [5] = 1,
  }

-- Bonus damage given to members of other factions, per difficulty level
otherFactionDamageMod =
  {
    [1] = 1,
    [2] = 1,
    [3] = 1.25,
    [4] = 1.5,
    [5] = 2,
  }

 otherFactionBossHPMod =
  {
    [1] = 0,
    [2] = 0,
    [3] = "25%",
    [4] = "50%",
    [5] = "100%",
  }

passiveHealingMod =
  {
    [1] = 2,
    [2] = 2,
    [3] = 1,
    [4] = 0,
    [5] = 0,
  }

playerStartingCashModifier =
  {
    2, 1.5, 1, 0.5, 0.05
  }
playerStartingAlcoholModifier =
  {
    6, 4.5, 3, 1.5, 0
  }

-- ------------------------------------------------------------------------

_id = "PRECINCTS"

lootAndOccupyNotorietyGain =
  {
    initialGain = 2,
    perRacket = 1,
  }
sackNotorietyGain =
  {
    initialGain = 4,
    perRacket = 2,
  }
razeNotorietyGain =
  {
    initialGain = 6,
    perRacket = 0,
  }

lootAndOccupyCashMultiplier = 1
sackCashMultiplier = 0.5
razeCashMultiplier = 0.25

lootAndOccupyDepotDamageTime = 7
lootAndOccupyRacketDamageTime = 14
sackDepotDamageTime = 14
sackRacketDamageTime = 21
razeDepotDamageTime = 21

demolishTime = 5

temporaryPoliceActivityDecay = 2

customerCountGameStart = 250
customerCapacityBase = 250
customerGrowthPerWeek = 90
customerCountEffectOnGrowthStep = 270
customerCountEffectOnGrowthAmount = -10
-- ------------------------------------------------------------------------

_id = "REINFORCEMENTS"

initialReinforcementTurnCount = 2
repeatedReinforcementTurnCount = 1
reinforcementIcon = "Sprites/CombatQueue/Icon_Reinforcements"

-- ------------------------------------------------------------------------

_id = "WIN_CONDITIONS"

chiTownMogulPercent = 0.4



-- ------------------------------------------------------------------------

-- --------------------------------------------------
-- TooltipPopulation.lua
-- --------------------------------------------------
local ConfigBuilder = require("Libs.ConfigBuilder")
local Behaviour = require("Mixins.Behaviour")
local World = require("World.World")
local LateRequires = require("Libs.LateRequires")
local TimeUtils = require("Libs.TimeUtils")
local FactionAI = require("AI.Factions.FactionAI")
local Alcohol = require("World.Alcohol")
local BuildingData = require("World.BuildingData")

local TooltipPopulation = {}

local systemModfiers = {}
local appliedSynergyNames = {}
local appliedSynergyValues = {}
local inactiveSynergyNames = {}
local inactiveSynergyValues = {}

local difficultyIcons =
{
    "$Icon_1Skull",
    "$Icon_2Skull",
    "$Icon_3Skull",
    "$Icon_4Skull",
    "$Icon_5Skull",
}
local difficultyColors =
{
    "success",
    "possible",
    "possible",
    "failure",
    "failure",
}

-- --------------------------------------------------
-- Local functions
-- --------------------------------------------------

local function populateWorldModifierData(tooltip, flipStateColors, configCategory, modifiedValue, factionId, locationId, precinctId, actor, overridingValue)
    local _, percentNegatives, percentPositives, rawNegatives, rawPositives = LateRequires.getWorldLibs().getModifierComponents(configCategory, modifiedValue, factionId, locationId, precinctId, actor, overridingValue)

    local negativeColor, positiveColor
    if flipStateColors then
        negativeColor = "statePositive"
        positiveColor = "stateNegative"
    else
        positiveColor = "statePositive"
        negativeColor = "stateNegative"
    end

    for k, v in next, rawPositives do
        tooltip:addData("$Format_Color", positiveColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedNumber3DecimalPlaces", v)
    end
    for k, v in next, percentPositives do
        tooltip:addData("$Format_Color", positiveColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end
    for k, v in next, rawNegatives do
        tooltip:addData("$Format_Color", negativeColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedNumber3DecimalPlaces", v)
    end
    for k, v in next, percentNegatives do
        tooltip:addData("$Format_Color", negativeColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end
end

-- --------------------------------------------------
-- General Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateCashOverviewTooltip(tooltip, faction)
    local cash = faction.cash
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Cash", "$Format_PriceCents", cash.count)
    local netIncome = cash:getNetIncome()
    if netIncome > 0 then
        tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$WeeklyNetIncome", "$Format_Color", "statePositive", "$Format_PricePlusCents", netIncome)
    elseif netIncome < 0 then
        tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$WeeklyNetIncome", "$Format_Color", "stateNegative", "$Format_PriceMinusCents", -netIncome)
    else
        tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$WeeklyNetIncome", "$Format_PricePlusCents", 0)
    end

    local incomeCategories = cash._income.categories
    local expensesCategories = cash._expenses.categories

    for name, category in next, incomeCategories do
        local income = category.total
        local expense = 0
        if expensesCategories[name] then
            expense = expensesCategories[name].total
        end
        local v = income - expense
        if v > 0 then
            tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", name, "$Format_Color", "statePositive", "$Format_PricePlusCents", v)
        elseif v < 0 then
            tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", name, "$Format_Color", "stateNegative", "$Format_PriceMinusCents", -v)
        end
    end
    for name, category in next, expensesCategories do
        if not incomeCategories[name] then
            tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", name, "$Format_Color", "stateNegative", "$Format_PriceMinusCents", category.total)
        end
    end
    tooltip:setDescription("$TOOLTIPS_Cash_Tooltip_Description_text")
end

local function addAlcoholEntry(tooltip, name, stored, net)
    local stateColor = (net > 0 and "statePositive") or (net < 0 and "stateNegative") or "gold"
    tooltip:addData("$Format_BulletEntry", "$Format_ThreeItems", "$Format_Colon", name, "$Format_Barrels", stored, "$Format_InBrackets", "$Format_Color", stateColor, "$Format_SignedWholeNumber", net)
end

function TooltipPopulation.populateAlcoholOverviewTooltip(tooltip, faction)
    local alcohol = faction.alcohol
    local netTotal, netWhiskey, netPremium, netTopShelf, netRack, netSwill, netPoison = alcohol:getClampedNetProduction()

    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Alcohol", "$Format_Barrels", "$Format_FractionWholeNumber", alcohol.stored, alcohol._storageAmount)
    if netTotal > 0 then
        tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$WeeklyNetIncome", "$Format_Color", "statePositive", "$Format_PlusBarrels", netTotal)
    elseif netTotal < 0 then
        tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$WeeklyNetIncome", "$Format_Color", "stateNegative", "$Format_PlusBarrels", netTotal)
    else
        tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$WeeklyNetIncome", "$Format_Barrels", 0)
    end

    addAlcoholEntry(tooltip, Alcohol.getName(6), alcohol[6], netWhiskey)
    addAlcoholEntry(tooltip, Alcohol.getName(5), alcohol[5], netPremium)
    addAlcoholEntry(tooltip, Alcohol.getName(4), alcohol[4], netTopShelf)
    addAlcoholEntry(tooltip, Alcohol.getName(3), alcohol[3], netRack)
    addAlcoholEntry(tooltip, Alcohol.getName(2), alcohol[2], netSwill)
    addAlcoholEntry(tooltip, Alcohol.getName(1), alcohol[1], netPoison)

    tooltip:setDescription("$TOOLTIPS_TradeScreen_AlcoholTab_text")
end

-- --------------------------------------------------
-- Trait Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateCharacterBehaviourTooltip(tooltip, traitInterface, character)
    if traitInterface.isCompoundState or traitInterface._name == "CompoundState" then -- Shane remove: Supporting older saves
        tooltip:setTitle(traitInterface:getName())

        local handles = traitInterface.handles
        for i = #handles, 1, -1 do
            local handle = handles[i]
            local subInterface = character.behaviours:getInterface(handle)
            for text in character.behaviours:getCurrentModifiers(handle) do
                tooltip:addData(text)
            end
        end
    else
        local numStacks = character.behaviours:getNumStacks(traitInterface.handle)
        if character.behaviours:getNumStacks(traitInterface.handle) > 1 then
            tooltip:setTitle({"$Format_BehaviourStacks", traitInterface:getName(), numStacks})
        else
            tooltip:setTitle(traitInterface:getName())
        end

        local handle = traitInterface.handle
        local curDuration = character.behaviours:turnsRemainingForHandle(handle)
        if curDuration > 0 then
            tooltip:addData("$OnCooldownRoundsRemaining", curDuration)
        end

        for text in character.behaviours:getCurrentModifiers(handle) do
            tooltip:addData(text)
        end
    end
    local icon = traitInterface:getIcon()
    if icon then
        tooltip:setIcon(icon)
        tooltip:setIconColor("white")
    end
    tooltip:setDescription(traitInterface:getDescription())
end

-- --------------------------------------------------
-- Diplomatic State Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateEmpireBonusTooltip(tooltip, boss, bonusIndex)
    local bossConfigId = boss.configId
    local factionConfig = ConfigBuilder.fromId(boss.faction.configId)
    local bossConfig = ConfigBuilder.fromId(bossConfigId)
    if bonusIndex == 3 then
        local diplomaticBonus = bossConfig.bossDiplomaticBonus
        local state = boss:getState(diplomaticBonus)
        local bonusName, bonusEffects
        if state then
            bonusName = state:getName()
            bonusEffects = state:getEffectDescriptions()
        else
            bonusName, bonusEffects = LateRequires.getWorldLibs().getDiplomaticBonusEffectDescriptions(bossConfig)
        end
        tooltip:setTitle(bonusName)
        tooltip:setSubtitle("$SelectFaction_DiplomaticBonus")
        tooltip:setIcon("Sprites/AllSharedUI/Icon_Diplomacy")
        tooltip:setIconColor("gold")
        for i = 1, #bonusEffects do
            tooltip:addData("$Format_BulletEntry", bonusEffects[i])
        end
    else
        local bonus1Name, bonus1Descriptions, bonus2Name, bonus2Descriptions = LateRequires.getWorldLibs().getEmpireBonusEffectDescriptions(bossConfigId)
        local bonusConfig
        local bonusEffects
        if bonusIndex == 1 then
            tooltip:setTitle(bonus1Name)
            bonusEffects = bonus1Descriptions
            bonusConfig = ConfigBuilder.fromId(bossConfig.bossEmpireBonusOne)
        else
            tooltip:setTitle(bonus2Name)
            bonusEffects = bonus2Descriptions
            bonusConfig = ConfigBuilder.fromId(bossConfig.bossEmpireBonusTwo)
        end
        tooltip:setSubtitle("$SelectFaction_EmpireBonus")
        local behaviourConfig = ConfigBuilder.fromId(bonusConfig.bonus)
        tooltip:setIcon(behaviourConfig.iconLarge)
        tooltip:setIconColor("gold")
        for i = 1, #bonusEffects do
            tooltip:addData("$Format_BulletEntry", bonusEffects[i])
        end
        tooltip:setDescription(behaviourConfig.desc, boss)
    end
end

function TooltipPopulation.populateDiplomaticStateTooltip(tooltip, diplomaticState)
    diplomaticState:populateTooltip(tooltip)
end

function TooltipPopulation.populateDiplomaticStateTargetFaction(tooltip, diplomaticState)
    local faction = diplomaticState:getOtherFaction(World.playerFaction)
    TooltipPopulation.populateFaction(tooltip, faction)
end

function TooltipPopulation.populateDiplomaticStateYouRecieve(tooltip, state)
    if state.name == "$StandingOrder" then
        if state.productionSource.isPlayerFaction then
            local cashAmount = state:getCashAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouReceive", "$Format_PriceCents", cashAmount)
            tooltip:setDescription("$TOOLTIPS_RecieveCashStandingOrder_Description_text")
        else
            local alcoholAmount = state:getAlcoholAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouReceive", "$Format_Barrels", alcoholAmount)
            tooltip:setDescription("$TOOLTIPS_RecieveAlcoholStandingOrder_Description_text")
        end
    elseif state.nameCreditor == "$AlcoholLoanCreditor" then
        if state.productionSource.isPlayerFaction then
            return false
        else
            local alcoholAmount = state:getAlcoholAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouReceive", "$Format_Barrels", alcoholAmount)
            tooltip:setDescription("$TOOLTIPS_RecieveAlcoholLoan_Description_text")
        end
    else -- Cash loan
        if state.incomeSource.isPlayerFaction then
            return false
        else
            local cashAmount = state:getCashAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouReceive", "$Format_PriceCents", cashAmount)
            tooltip:setDescription("$TOOLTIPS_RecieveCashLoan_Description_text")
        end
    end
end

function TooltipPopulation.populateDiplomaticStateYouPay(tooltip, state)
    if state.name == "$StandingOrder" then
        if not state.productionSource.isPlayerFaction then
            local cashAmount = state:getCashAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouPay", "$Format_PriceCents", cashAmount)
            tooltip:setDescription("$TOOLTIPS_PayCashStandingOrder_Description_text")
        else
            local alcoholAmount = state:getAlcoholAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouPay", "$Format_Barrels", alcoholAmount)
            tooltip:setDescription("$TOOLTIPS_PayAlcoholStandingOrder_Description_text")
        end
    elseif state.nameCreditor == "$AlcoholLoanCreditor" then
        if not state.productionSource.isPlayerFaction then
            return false
        else
            local alcoholAmount = state:getAlcoholAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouPay", "$Format_Barrels", alcoholAmount)
            tooltip:setDescription("$TOOLTIPS_PayAlcoholLoan_Description_text")
        end
    else -- Cash loan
        if not state.incomeSource.isPlayerFaction then
            return false
        else
            local cashAmount = state:getCashAmount()
            tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$YouPay", "$Format_PriceCents", cashAmount)
            tooltip:setDescription("$TOOLTIPS_PayCashLoan_Description_text")
        end
    end
end

function TooltipPopulation.populateDiplomaticStateAlcoholType(tooltip, state)
    if not state.productionSource then
        return false
    else
        local alcoholTypeName = Alcohol.getName(state.alcoholType)
        local icon = Alcohol.getIcon(state.alcoholType)
        tooltip:setTitle("$AlcoholType")
        tooltip:setIcon(icon)
        tooltip:setSubtitle(alcoholTypeName)
    end
end

function TooltipPopulation.populateDiplomaticStateTimeout(tooltip, state)
    if not state.usesTimeout then
        return false
    else
        local timeRemaining = (state.timeout + state.startTime) - client.time.worldTime
        local daysRemaining = math.ceil(TimeUtils.convertDuration(timeRemaining, "Seconds", "Days"))
        local formatString
        if daysRemaining == 1 then
            formatString = "$Format_TimeoutDay"
        else
            formatString = "$Format_TimeoutDays"
        end
        tooltip:setTitle(formatString, daysRemaining)
        tooltip:setDescription("$TOOLTIPS_Timeout_Description_text")
    end
end

function TooltipPopulation.populateEmpireBonus(tooltip, interface, contextFaction)
    tooltip:setTitle(interface:getName())
    tooltip:setSubtitle(interface:getBonusType())
    tooltip:setIcon(interface:getIcon())
    tooltip:setIconColor("gold")
    if interface.businessPartnerFaction then
        local f = interface.businessPartnerFaction
        local color = f:getKnownIconColors()
        -- "$BusinessArrangementBonus_ProvidedBy" --$ Bonus Provided by {0}
        tooltip:addData("$Format_Color", color, "$BusinessArrangementBonus_ProvidedBy", f.name)
    end
    local effects = interface:getEffectDescriptions()
    for i = 1, #effects do
        tooltip:addData("$Format_BulletEntry", effects[i])
    end
    tooltip:setDescription(interface:getDescription(), contextFaction.boss)
end

-- --------------------------------------------------
-- Building Tooltips
-- --------------------------------------------------
-- "$Format_Security" --$ Security: {0}
function TooltipPopulation.populateSafehouseTooltip(tooltip, building, hideTitle)
    if not hideTitle then
        tooltip:setTitle(building.knownName)
    end
    if building.isKnownToPlayer then
        if not hideTitle then
            tooltip:setSubtitle("$Map_Safehouse")
            tooltip:setIcon(Config.BUILDING_DATA.SAFEHOUSE.icon)
            tooltip:setIconColor("gold")
        end
        tooltip:setFaction(building.faction)
        if building.faction.isPlayerFaction then
            tooltip:addObservedData(building.producer, "$Format_Colon2Elements", "$Building_Production", "$Format_Barrels", "amount")
            local productionAmount = building.producer.amount
            local alcoholType = building.producer.alcoholType
            local alcoholTypeName = (productionAmount == 0) and "$NothingItem" or Alcohol.getName(alcoholType)
            tooltip:addData("$Format_Colon2Elements", "$Building_Producing", alcoholTypeName)
            tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", "$Format_FractionWholeNumber", building.storage.stored, building.storage.amount)
        else
            local difficulty = building:getDifficultyRating()
            tooltip:addData("$Format_Colon2Elements", "$Settings_Difficulty", difficultyIcons[difficulty], difficultyColors[difficulty])
        end
        tooltip:setDescription("$TOOLTIPS_Safehouse_Tooltip_Description_text")
    end
end

function TooltipPopulation.populateDepotTooltip(tooltip, building, hideTitle)
    if not hideTitle then
        tooltip:setTitle(building.knownName)
    end
    if building.isKnownToPlayer then
        if not hideTitle then
            tooltip:setSubtitle("$Depot")
            tooltip:setIcon(Config.BUILDING_DATA.DEPOT.icon)
            tooltip:setIconColor("gold")
        end
        tooltip:setFaction(building.faction)
        if not building:canSupplyOwner() then
            tooltip:addData("$Format_Color", "stateNegative", "$PrecinctInfo_SupplyLineCutoff_Title")
        end
        if building.faction.isPlayerFaction then
            tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", "$Format_FractionWholeNumber", building.storage.stored, building.storage.amount)
        else
            local difficulty = building:getDifficultyRating()
            tooltip:addData("$Format_Colon2Elements", "$Settings_Difficulty", difficultyIcons[difficulty], difficultyColors[difficulty])
        end
        tooltip:setDescription("$TOOLTIPS_Depot_Tooltip_Description_text")
    end
end

function TooltipPopulation.populateBreweryTooltip(tooltip, building, hideTitle)
    if not hideTitle then
        tooltip:setTitle(building.knownName)
    end
    if building.isKnownToPlayer then
        local racketId = building.buildingData.id
        local racketConfig = ConfigBuilder.fromId( racketId )
        if not hideTitle then
            local racketIcon = racketConfig.icon
            local racketName = racketConfig.name
            tooltip:setSubtitle("$Format_BulletSeparatedStrings", racketName, building:sizeName())
            tooltip:setIcon(racketIcon)
            tooltip:setIconColor("gold")
        end
        tooltip:setFaction(building.faction)
        if not building:canSupplyOwner() then
            tooltip:addData("$Format_Color", "stateNegative", "$PrecinctInfo_SupplyLineCutoff_Title")
        end
        if building.faction.isPlayerFaction then
            tooltip:addObservedData(building.producer, "$Format_Colon2Elements", "$Building_WeeklyProduction", "$Format_Barrels", "amount")
            local productionAmount = building.producer.amount
            local alcoholType = building.producer.alcoholType
            local alcoholTypeName = (productionAmount == 0) and "$NothingItem" or Alcohol.getName(alcoholType)
            tooltip:addData("$Format_Colon2Elements", "$Building_Producing", alcoholTypeName)
            tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", "$Format_FractionWholeNumber", building.storage.stored, building.storage.amount)
        else
            local difficulty = building:getDifficultyRating()
            tooltip:addData("$Format_Colon2Elements", "$Settings_Difficulty", difficultyIcons[difficulty], difficultyColors[difficulty])
        end
        tooltip:setDescription(building.buildingData:getBaseValue("tooltipDescription"))
    end
end

-- "$Format_Value" --$ Value: {0:C0}
function TooltipPopulation.populateConsumerRacketTooltip(tooltip, building, hideTitle)
    if not hideTitle then
        tooltip:setTitle(building.knownName)
    end
    if building.isKnownToPlayer then
        local racketId = building.buildingData.id
        local racketConfig = ConfigBuilder.fromId( racketId )
        if not hideTitle then
            local racketIcon = racketConfig.icon
            local racketName = racketConfig.name
            tooltip:setSubtitle("$Format_BulletSeparatedStrings", racketName, building:sizeName())
            tooltip:setIcon(racketIcon)
            tooltip:setIconColor("gold")
        end
        tooltip:setFaction(building.faction)
        if not building:canSupplyOwner() then
            tooltip:addData("$Format_Color", "stateNegative", "$PrecinctInfo_SupplyLineCutoff_Title")
        end
        if building.faction.isPlayerFaction then
            tooltip:addObservedData(building.data, "$Format_Income", "income") --$ Income: {0:C0}
            if building.data.racketCustomerCapacity > 0 then
                tooltip:addObservedData(building.data, "$Format_Colon2Elements", "$Precinct_Customers", "$Format_FractionWholeNumber", "customerCount", "racketCustomerCapacity")
            end
            local consumptionAmount = building.data.consumption or 0
            tooltip:addData("$Format_Colon2Elements", "$Building_WeeklyConsumption", "$Format_Barrels", consumptionAmount)
        else
            local difficulty = building:getDifficultyRating()
            tooltip:addData("$Format_Colon2Elements", "$Settings_Difficulty", difficultyIcons[difficulty], difficultyColors[difficulty])
        end
        tooltip:setDescription(building.buildingData:getBaseValue("tooltipDescription"))
    end
end

function TooltipPopulation.populateVacantTooltip(tooltip, building, hideTitle)
    if building:isBuildingTime() then
        local racketId = building.buildTargetId
        local config = ConfigBuilder.fromId(racketId)
        if not hideTitle then
            tooltip:setTitle(building.knownName)
            -- "$Equipping" --$ Equipping
            tooltip:setSubtitle("$Format_Colon2Elements", "$Equipping", config.name)
            tooltip:setIcon(config.icon)
            tooltip:setIconColor("gold")
        end
        tooltip:setFaction(building.faction)
        local buildTime = building:getBuildingTimeRemaining()
        local daysRemaining = TimeUtils.convertDuration(buildTime, "Seconds", "Days")
        local timeString
        if daysRemaining == 1 then
            timeString = "$Shop_Day"
        else
            timeString = "$Shop_Days"
        end
        tooltip:addData("$Format_Colon2Elements", "$TimeRemaining", timeString, daysRemaining)
        tooltip:addData("$Building_SizeTitle", building:sizeName())
        tooltip:setDescription(config.tooltipDescription)
    else
        if not hideTitle then
            tooltip:setTitle(building.knownName)

            tooltip:setIcon("Sprites/Icons/Buildings/Icon_Racket_Sale_W")
            tooltip:setIconColor("gold")
        end
        tooltip:addData("$Building_SizeTitle", building:sizeName())
        tooltip:setDescription("$EmptyRacket_TooltipDescription") --$ Vacant buildings can be purchased and turned into Rackets.
    end
end

function TooltipPopulation.populateDerelictTooltip(tooltip, building, hideTitle)
    if building.isKnownToPlayer then
        local racketId = building.buildingData.id
        local racketConfig = ConfigBuilder.fromId( racketId )
        if not hideTitle then
            tooltip:setTitle(building.knownName)
            tooltip:setSubtitle(building:getBuildingTypeName())
            local icon = racketConfig.icon
            tooltip:setIcon(icon)
            tooltip:setIconColor("gold")
        end
        local difficulty = building:getDifficultyRating()
        tooltip:addData("$Format_Colon2Elements", "$Settings_Difficulty", difficultyIcons[difficulty], difficultyColors[difficulty])
        tooltip:addData("$Building_SizeTitle", building:sizeName())
        tooltip:setDescription(building:getBuildingTypeTooltipDescription())
    else
        tooltip:setTitle("$Private_Building_Name")
    end
end

function TooltipPopulation.populateLoanSharkRacketTooltip(tooltip, building, hideTitle)
    if not building:canSupplyOwner() then
        tooltip:addData("$Format_Color", "stateNegative", "$PrecinctInfo_SupplyLineCutoff_Title")
    end
    tooltip:addObservedData(building.data, "$Format_Income", "income")
    TooltipPopulation.populateSimpleRacketTooltip(tooltip, building, hideTitle, true)
end

function TooltipPopulation.populateSimpleRacketTooltip(tooltip, building, hideTitle, showDifficulty)
    if not hideTitle then
        tooltip:setTitle(building.knownName)
    end
    if building.isKnownToPlayer then
        local racketId = building.buildingData.id
        local racketConfig = ConfigBuilder.fromId( racketId )
        if not hideTitle then
            local racketIcon = racketConfig.icon
            local racketName = racketConfig.name
            tooltip:setSubtitle("$Format_BulletSeparatedStrings", racketName, building:sizeName())
            tooltip:setIcon(racketIcon)
            tooltip:setIconColor("gold")
        end
        tooltip:setFaction(building.faction)
        if showDifficulty then
            if not building.faction.isPlayerFaction then
                local difficulty = building:getDifficultyRating()
                tooltip:addData("$Format_Colon2Elements", "$Settings_Difficulty", difficultyIcons[difficulty], difficultyColors[difficulty])
            end
        end
        tooltip:setDescription(building.buildingData:getBaseValue("tooltipDescription"))
    end
end

local buildingTooltipFunctions =
{
    Safehouse = TooltipPopulation.populateSafehouseTooltip,
    Depot = TooltipPopulation.populateDepotTooltip,
    Bar = TooltipPopulation.populateConsumerRacketTooltip,
    Brewery = TooltipPopulation.populateBreweryTooltip,
    Brothel = TooltipPopulation.populateConsumerRacketTooltip,
    Casino = TooltipPopulation.populateConsumerRacketTooltip,
    Vacant = TooltipPopulation.populateVacantTooltip,
    Derelict = TooltipPopulation.populateDerelictTooltip,
    Hotel = TooltipPopulation.populateSimpleRacketTooltip,
    LoanShark = TooltipPopulation.populateLoanSharkRacketTooltip,
}

local levelIcons =
{
    "$Icon_1Star",
    "$Icon_2Star",
    "$Icon_3Star",
    "$Icon_4Star",
    "$Icon_5Star",
}

function TooltipPopulation.populateBuildingDemolishTooltip(tooltip, building, hideTitle)
    local racketId = building.buildingData.id
    local config = ConfigBuilder.fromId(racketId)
    if not hideTitle then
        tooltip:setTitle(building.knownName)
        -- "$Demolishing" --$ Demolishing
        tooltip:setSubtitle("$Format_Colon2Elements", "$Demolishing", config.name)
        tooltip:setIcon("Sprites/Icons/Buildings/Icon_Raze")
        tooltip:setIconColor("gold")
    end
    tooltip:setFaction(building.faction)
    local demolishTime = building:getDemolishTimeRemaining()
    local daysRemaining = TimeUtils.convertDuration(demolishTime, "Seconds", "Days")
    local timeString
    if daysRemaining == 1 then
        timeString = "$Shop_Day"
    else
        timeString = "$Shop_Days"
    end
    tooltip:addData("$Format_Colon2Elements", "$TimeRemaining", timeString, daysRemaining)
    tooltip:addData("$Building_SizeTitle", building:sizeName())
    tooltip:setDescription("$Demolish_Tooltip_Description") --$ This building is being demolished. Once complete, it will be available to equip as a racket.
end

function TooltipPopulation.populateBuildingTooltip(tooltip, building, hideTitle)
    if building:isDemolishTime() then
        TooltipPopulation.populateBuildingDemolishTooltip(tooltip, building, hideTitle)
    else
        TooltipPopulation.populateBuildingOpenClosedStatus(tooltip, building)
        local func = buildingTooltipFunctions[building.buildingType]
        if func then
            if building.upgrades and building.faction.isPlayerFaction then
                local textParams = {}
                for _, upgrade in next, building.upgrades.upgradeInterfaces do
                    local upgradeName = upgrade:getName()
                    local upgradeLevel = upgrade.level
                    local isUpgrading = upgrade:isUpgrading()
                    if isUpgrading then
                        textParams[1] = "$Format_TextAndTextInBrackets"
                    end
                    textParams[#textParams + 1] = "$Format_5ItemsNoSpace"
                    for i = 1, upgradeLevel do
                        textParams[#textParams + 1] = "$Icon_FullStar"
                    end
                    if isUpgrading then
                        textParams[#textParams + 1] = "$Icon_SemiFullStar"
                    end
                    for i = upgradeLevel + (isUpgrading and 2 or 1), 5 do
                        textParams[#textParams + 1] = "$Icon_EmptyStar"
                    end
                    if isUpgrading then
                        local daysRemaining = math.round(upgrade:getUpgradeTimeRemaining())
                        local timeString
                        if daysRemaining == 1 then
                            timeString = "$Shop_Day"
                        else
                            timeString = "$Shop_Days"
                        end
                        textParams[#textParams + 1] = "$Upgrading"
                        tooltip:addData("$Format_Colon2Elements", upgradeName, unpack(textParams))
                        tooltip:addData( "$Format_BulletEntry", "$Format_Colon2Elements", "$TimeRemaining", timeString, daysRemaining)
                    else
                        tooltip:addData("$Format_Colon2Elements", upgradeName, unpack(textParams))
                    end
                    clearTable(textParams)
                end
            end
            func(tooltip, building, hideTitle)
        end
        TooltipPopulation.populateBuildingClaimedBy(tooltip, building)
    end
end

function TooltipPopulation.populateRacketUpgradeTooltip(tooltip, upgrade)
    tooltip:clearInfo()
    tooltip:setTitle(upgrade:getName())
    local textParams = {}
    textParams[#textParams + 1] = "$Format_5ItemsNoSpace"
    local upgradeLevel = upgrade.level
    local isUpgrading = upgrade:isUpgrading()
    for i = 1, upgradeLevel do
        textParams[#textParams + 1] = "$Icon_FullStar"
    end
    if isUpgrading then
        textParams[#textParams + 1] = "$Icon_SemiFullStar"
    end
    for i = upgradeLevel + (isUpgrading and 1 or 0), 5 do
        textParams[#textParams + 1] = "$Icon_EmptyStar"
    end
    tooltip:setSubtitle(textParams)
    tooltip:setTitleIcon(upgrade:getIcon(), "gold")

    local atMaxLevel = (upgrade.level == upgrade._maxLevel)
    if not (isUpgrading or atMaxLevel) then
        tooltip:startNewAttributeGroup()
        tooltip:setAttributeTitle("$UpgradeToLevel", levelIcons[upgradeLevel], levelIcons[upgradeLevel + 1])
        local upgradeCost = upgrade:getNextCost()
        local canAfford = World.playerFaction.cash:canAfford(upgradeCost)
        local costColor = canAfford and "statePositive" or "stateNegative"
        tooltip:addAttributeData("$RPC_Review_Cost", "$Format_Color", costColor, "$Format_Price", upgradeCost)
        local upgradeTime = upgrade:getUpgradeTime(upgradeLevel + 1)
        local timeString
        if upgradeTime == 1 then
            timeString = "$Shop_Day"
        else
            timeString = "$Shop_Days"
        end
        tooltip:addAttributeData("$Missions_Time", timeString, upgradeTime)
    elseif isUpgrading then
        tooltip:startNewAttributeGroup()
        tooltip:setAttributeTitle("$Upgrading")
        local daysRemaining = upgrade:getUpgradeTimeRemaining()
        local timeString
        if math.round(daysRemaining) == 1 then
            timeString = "$Shop_Day"
        else
            timeString = "$Shop_Days"
        end
        tooltip:addAttributeData("$TimeRemaining", timeString, daysRemaining)
    end

    tooltip:startNewAttributeGroup()
    local currentLevelModifiers = upgrade:getModifiers(upgradeLevel)
    local customEffects = upgrade:getCustomEffectDescriptions()
    local nextLevelModifiers
    local nextLevelCustomEffects
    if not atMaxLevel then
        nextLevelModifiers = upgrade:getModifiers(upgradeLevel + 1)
        nextLevelCustomEffects = upgrade:getCustomEffectDescriptions(upgradeLevel + 1)
    end
    if customEffects then
        for k, v in next, customEffects do
            if nextLevelCustomEffects and nextLevelCustomEffects[k] then
                tooltip:addAttributeData(k, "$Format_UpgradeValueToValue", v, nextLevelCustomEffects[k])
            elseif nextLevelCustomEffects then
                tooltip:addAttributeData(k, "$Format_UpgradeValueToValue", v, 0)
            else
                tooltip:addAttributeData(k, "$Format_WholeNumber", v)
            end
        end
        if nextLevelCustomEffects then
            for k, v in next, nextLevelCustomEffects do
                if not customEffects[k] then
                    tooltip:addAttributeData(k, "$Format_UpgradeValueToValue", 0, v)
                end
            end
        end
    end
    local titleConfig = Config.UPGRADE_VISUALS.TITLES
    local formatConfig = Config.UPGRADE_VISUALS.VALUE_FORMAT
    if nextLevelModifiers then
        for k, v in next, nextLevelModifiers do
            if titleConfig[k] then
                if k == "maxQuality" then
                    local oldValue = currentLevelModifiers[k]
                    local oldName = Alcohol.getName(oldValue)
                    local newName = Alcohol.getName(v)
                    local oldModifier = Alcohol.getEarningsModifier(oldValue)
                    local newModifier = Alcohol.getEarningsModifier(v)
                    local oldColor = ((oldModifier < 0) and "stateNegative") or ((oldModifier > 0) and "statePositive") or "stateNeutral"
                    local newColor = ((newModifier < 0) and "stateNegative") or ((newModifier > 0) and "statePositive") or "stateNeutral"
                    tooltip:addAttributeData(titleConfig[k], "$Format_UpgradeValueToValue", oldName, newName)
                else
                    local oldValue = currentLevelModifiers[k] or 0
                    if formatConfig[k] == "$Format_PlusPercent" then
                        v = v * 100
                        oldValue = oldValue * 100
                    end
                    tooltip:addAttributeData(titleConfig[k], "$Format_UpgradeValueToValue", formatConfig[k], oldValue, formatConfig[k], v)
                end
            end
        end
    else
        for k, v in next, currentLevelModifiers do
            if titleConfig[k] then
                if formatConfig[k] == "$Format_PlusPercent" then
                    v = v * 100
                end
                if k == "maxQuality" then
                    local newName = Alcohol.getName(v)
                    local newModifier = Alcohol.getEarningsModifier(v)
                    local newColor = ((newModifier < 0) and "stateNegative") or ((newModifier > 0) and "statePositive") or "stateNeutral"
                    tooltip:addAttributeData(titleConfig[k], newName)
                else
                    tooltip:addAttributeData(titleConfig[k], formatConfig[k], v)
                end
            end
        end
    end

    tooltip:setDescriptionText(upgrade:getDescription())
    tooltip:setupBackplates(true)
end

function TooltipPopulation.populateRacketPurchaseTooltip(tooltip, building, option, takeOver)
    local precinct = building:getPrecinct()
    tooltip:clearInfo()
    local config = ConfigBuilder.fromId(option)

    local isValid = BuildingData.executeScriptBlock(option, "isValid", building, World.playerFaction)

    if isValid then
        tooltip:setTitle(config.name)
        tooltip:setSubtitle(building:sizeName())
    else
        tooltip:setTitle("$Format_Color", "stateInvalid", config.name)
        tooltip:setSubtitle("$Format_TwoItems", building:sizeName(), "$Format_Color", "stateInvalid", "$Format_InBrackets", "$Invalid")
    end
    tooltip:setTitleIcon(config.icon, isValid and "gold" or "stateInvalid")

    tooltip:startNewAttributeGroup()
    local WorldLibs = LateRequires.getWorldLibs()

    local racketCost = WorldLibs.getRacketCost(building, option, World.playerFaction, takeOver)
    local canAfford = World.playerFaction.cash:canAfford(racketCost)
    local costColor = canAfford and "statePositive" or "stateNegative"
    tooltip:addAttributeData("$RPC_Review_Cost", "$Format_Color", costColor, "$Format_Price", racketCost)

    local buildTime = WorldLibs.getRacketPurchaseTime(building, option, World.playerFaction)
    if buildTime > 0 then
        local timeString
        if buildTime == 1 then
            timeString = "$Shop_Day"
        else
            timeString = "$Shop_Days"
        end
        tooltip:addAttributeData("$Missions_Time", timeString, buildTime)
    end

    local buildings = precinct.racketBuildings
    local optionCount = 0
    for i = 1, #buildings do
        if buildings[i].buildingData.id == option then
            optionCount = optionCount + 1
        end
    end
    tooltip:addAttributeData("$CountAlreadyInPrecinct", "$Format_Count", optionCount)

    tooltip:startNewAttributeGroup()
    local level = 1
    local baseData = BuildingData.getConfig(option, building.size)
    local modifiers = WorldLibs.getTotalBuildingUpgradeModifiers(building, option, level)
    local titleConfig = Config.UPGRADE_VISUALS.TITLES
    local formatConfig = Config.UPGRADE_VISUALS.VALUE_FORMAT
    for k, v in next, modifiers do
        local name = titleConfig[k]
        if k ~= "suspicionEffect" -- Ignoring
                and k ~= "earnings" -- Ignoring on initial purchase
                and k ~= "saleValue"
        then
            if baseData[k] then
                v = v + baseData[k]
            end
            if titleConfig[k] then
                if k == "maxQuality" then
                    local newName = Alcohol.getName(v)
                    tooltip:addAttributeData(titleConfig[k], newName)
                else
                    tooltip:addAttributeData(titleConfig[k], formatConfig[k], v)
                end
            end
        end
    end

    if not isValid then
        local invalidReasons = BuildingData.executeScriptBlock(option, "getInvalidDescriptions", building, World.playerFaction)
        for i = 1, #invalidReasons do
            tooltip:addAttributeSimpleData("$Format_Color", "stateInvalid", "$Format_BulletEntry", invalidReasons[i])
        end
    end

    -- "$Pros" --$ Pros
    -- "$Cons" --$ Cons
    if config.purchaseTooltipPros then
        tooltip:addAttributeSimpleData("$Format_Color", "dullWhite", "$Format_Colon", "$Pros")
        local pros = config.purchaseTooltipPros
        for i = 1, #pros do
            tooltip:addAttributeSimpleData("$Format_Color", "statePositive", "$Format_BulletEntry", pros[i])
        end
    end
    if config.purchaseTooltipCons then
        tooltip:addAttributeSimpleData("$Format_Color", "dullWhite", "$Format_Colon", "$Cons")
        local cons = config.purchaseTooltipCons
        for i = 1, #cons do
            tooltip:addAttributeSimpleData("$Format_Color", "stateNegative", "$Format_BulletEntry", cons[i])
        end
    end
    tooltip:setDescriptionText(config.tooltipDescription)
    tooltip:setupBackplates(true)
end

function TooltipPopulation.populateRacketTypeFromBuilding(tooltip, building, hideTitle)
    local racketId = building.buildingData.id
    local racketConfig = ConfigBuilder.fromId( racketId )
    if not hideTitle then
        local racketIcon = racketConfig.icon
        local racketName = racketConfig.name
        tooltip:setTitle(racketName)
        tooltip:setSubtitle(building.knownName)
        tooltip:setIcon(racketIcon)
        tooltip:setIconColor("gold")
    end
    local description = racketConfig.tooltipDescription
    tooltip:setDescription(description)
end

function TooltipPopulation.populateBuildingOwner(tooltip, building, hideTitle)
    local faction = building:getOwnerFaction()
    TooltipPopulation.populateFaction(tooltip, faction, hideTitle)
end

function TooltipPopulation.populateBuildingIncome(tooltip, building)
    local data = building.data
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Building_Income", "$Format_PriceCents", data.income)
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Customers", "$Format_Times", data.customerCount)
    local baseAverageSpend = building._baseAverageSpend
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Building_AverageSpend", "$Format_PriceCents", baseAverageSpend)
    local incomeId = building.buildingData.getConfigValue(building.buildingData._id, "incomeId")

    -- Add the system modifiers
    if incomeId then
        local earningsModifiers = data._modifiers.earnings
        local systemModifiers, percentNegatives, percentPositives, rawNegatives, rawPositives = LateRequires.getWorldLibs().getModifierComponents("cash", incomeId, building.faction.factionId, building.locationId, building:getPrecinctId(), building)

        for k, v in next, earningsModifiers do
            if v < 0 then
                percentNegatives[k] = v
            elseif v > 0 then
                percentPositives[k] = v
            end
        end
        for k, v in next, rawPositives do
            tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_PricePlusCents", v)
        end

        for k, v in next, percentPositives do
            tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
        end

        for k, v in next, rawNegatives do
            tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_PriceMinusCents", -v)
        end
        for k, v in next, percentNegatives do
            tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
        end
    end
    tooltip:setDescription("$TOOLTIPS_Income_Description_text")
end

function TooltipPopulation.populateLoanSharkIncome(tooltip, building)
    local income = building.data.income
    local investmentAmount = building.investmentAmount
    local loanSharkWeeklyReturn = building.data.loanSharkWeeklyReturn

    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Building_Income", "$Format_PriceCents", income)
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$LoanShark_InvestmentAmount", "$Format_Price", investmentAmount)
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$LoanShark_WeeklyReturn", "$Format_Count_2DecimalPlace", loanSharkWeeklyReturn)
    tooltip:setDescription("$TOOLTIPS_LoanShark_Income_Description_text")
end

function TooltipPopulation.populateBuildingProduction(tooltip, building)
    local production = building.producer.amount
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Building_Production", "$Format_Barrels", production)

    local data = building.data

    local productionModifiers = data._modifiers.production

    -- Add the system modifiers
    local systemModifiers, percentNegatives, percentPositives, rawNegatives, rawPositives = LateRequires.getWorldLibs().getModifierComponents("generic", "PRODUCTION_OUTPUT", building.faction.factionId, building.locationId, building:getPrecinctId(), building)

    for k, v in next, productionModifiers do
        if v < 0 then
            rawNegatives[k] = v
        elseif v > 0 then
            rawPositives[k] = v
        end
    end

    for k, v in next, rawPositives do
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_Barrels", v)
    end

    for k, v in next, percentPositives do
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end

    for k, v in next, rawNegatives do
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_Barrels", -v)
    end

    for k, v in next, percentNegatives do
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end
    tooltip:setDescription("$TOOLTIPS_Production_Description_text")
end

function TooltipPopulation.populateBuildingProductionAlcoholType(tooltip, building)
    tooltip:setTitle("$AlcoholType")
    tooltip:setSubtitle(building.producer.typeName)
    tooltip:setIcon(Alcohol.getIcon(building.producer.alcoholType))
    tooltip:setDescription("$TOOLTIPS_AlcoholTypeProduced_Description_text")
end

function TooltipPopulation.populateBuildingIncomeOrProduction(tooltip, building)
    if building.buildingData.id == "BUILDING_DATA.LOAN_SHARK" then
        TooltipPopulation.populateLoanSharkIncome(tooltip, building)
    elseif building.producer then
        TooltipPopulation.populateBuildingProduction(tooltip, building)
    else
        TooltipPopulation.populateBuildingIncome(tooltip, building)
    end
end

function TooltipPopulation.populateBuildingUpkeep(tooltip, building)
    local data = building.data

    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Building_Upkeep", "$Format_PriceCents", data.upkeep)
    local upkeepModifiers = data._modifiers.upkeep
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Base_Value", "$Format_PricePlusCents", upkeepModifiers["$Base_Value"] or 0)

    -- Add the system modifiers
    local systemModifiers, percentNegatives, percentPositives, rawNegatives, rawPositives = LateRequires.getWorldLibs().getModifierComponents("cash", "RACKET_UPKEEP", building.faction.factionId, building.locationId, building:getPrecinctId(), building)

    for k, v in next, upkeepModifiers do
        if k ~= "$Base_Value" then
            if v < 0 then
                rawPositives[k] = v
            elseif v > 0 then
                rawPositives[k] = v
            end
        end
    end

    -- Flipping negative and positive visuals as this value is something we want to be low
    for k, v in next, rawNegatives do
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_PriceMinusCents", -v)
    end
    for k, v in next, percentNegatives do
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end
    for k, v in next, rawPositives do
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_PricePlusCents", v)
    end
    for k, v in next, percentPositives do
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end
    tooltip:setDescription("$TOOLTIPS_Upkeep_Description_text")
end

function TooltipPopulation.populateBuildingClaimedBy(tooltip, building)
    if  World.isMainTutorialActive() then
        return
    end

    local precinct = building:getPrecinct()
    local warIds = World.playerFaction.diplomacy._states["WAR"]
    for _, warId in next, warIds do
        local war = World.behaviours:getInterface(warId)
        local isAttacker = war:isAttacker(World.playerFaction)
        if isAttacker then
            local claims = war.precinctClaims
            local claimFactionId = claims and claims[precinct.id]
            if claimFactionId then
                local claimFaction = World.getFaction(claimFactionId)
                -- If the precinct of the building is a war claim in a war that the player is involved in
                tooltip:addData("$Format_Color", "stateNeutral", "$BuildingTooltip_ClaimedBy", claimFaction.name)
            end
        end
    end
end

function TooltipPopulation.populateBuildingOpenClosedStatus(tooltip, building)
    local faction = building.faction
    if building.canBeDepot or faction.isThugFaction or not faction.isGang then
        return false
    end
    if building.open then
        tooltip:addData("$Format_Color", "statePositive", "$open")
    else
        tooltip:addData("$Format_Color", "stateNegative", "$Closed")
        local cm = building.buildingData._closedModifiers
        for i = 1, #cm do
            local modifier = cm[i]
            if modifier.timeout then
                local timeout = math.ceil(modifier.timeout)
                local timeoutString
                if timeout == 1 then
                    timeoutString = "$Shop_Day"
                else
                    timeoutString = "$Shop_Days"
                end
                tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", modifier.name, timeoutString, timeout)
            else
                tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", modifier.name)
            end
        end
    end
end

function TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
    local level = upgrade:getLevel()
    local maxLevel = upgrade:getMaxLevel()
    if not hideTitle then
        tooltip:setTitle(upgrade:getName())
        tooltip:setIcon(upgrade:getImage())
        tooltip:setIconColor("gold")
        tooltip:setSubtitle("$Format_Colon2Elements", "$Building_Level", "$Format_FractionWholeNumber", level, maxLevel)
    end

    local modifiers = upgrade:getModifiers()
    local titleConfig = Config.UPGRADE_VISUALS.TITLES
    local formatConfig = Config.UPGRADE_VISUALS.VALUE_FORMAT
    for k, v in next, modifiers do
        if k ~= "suspicionEffect" then -- For now, ignoring suspicion Effect
            tooltip:addData("$Format_Colon2Elements", titleConfig[k], formatConfig[k], v)
        end
    end

    if upgrade:isUpgrading() then
        tooltip:addPolledData(upgrade, upgrade.getUpgradeTimeRemainingFormatted)
        -- "$RushCost" --$ Rush Cost
    elseif maxLevel > level then
        -- "$NextUpgradeCost" --$ Next Upgrade Cost
        tooltip:addData("$Format_Colon2Elements", "$NextUpgradeCost", "$Format_Price", upgrade:getNextCost())
    end

    tooltip:setDescription(upgrade:getDescription())
end

function TooltipPopulation.populateBuildingSecurityUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("security")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingDeflectUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("deflect")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingAmbienceUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("ambiance")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingWordOfMouthUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("wordOfMouth")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingGamesUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("game")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingProductionUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("production")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingQualityUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("quality")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingStorageUpgrade(tooltip, building, hideTitle)
    local upgrade = building.upgrades:getUpgradeOfType("storage")
    TooltipPopulation.populateUpgradeTooltip(tooltip, upgrade, hideTitle)
end

function TooltipPopulation.populateBuildingNeighborhood(tooltip, building, hideTitle)
    local location = World.getLocation(building.locationId)
    TooltipPopulation.populateNeighborhoodOverview(tooltip, location, hideTitle)
end

function TooltipPopulation.populateBuildingAverageSpend(tooltip, building)
    local data = building.data
    local wardProsperity = World.neighborhoodProsperities[building.locationId]
    local prosperityModifier = wardProsperity:getProsperityIncomeModifier()
    local modifiers = data.globalEarnings + (data.earnings or 0) + prosperityModifier
    local baseAverageSpend = building._baseAverageSpend
    local averageSpend = modifiers * baseAverageSpend

    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Building_AverageSpend", "$Format_PriceCents", averageSpend)
    tooltip:setIcon("Sprites/EmpireView/Icon_Spend_128_W")
    tooltip:setIconColor("gold")
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Base_Value", "$Format_PricePlusCents", baseAverageSpend)

    local earningsModifiers = data._modifiers.earnings

    -- Add the system modifiers
    local systemModifiers, percentNegatives, percentPositives, rawNegatives, rawPositives = LateRequires.getWorldLibs().getModifierComponents("cash", "SPEAKEASY_INCOME", building.faction.factionId, building.locationId, building:getPrecinctId(), building)
    for k, v in next, earningsModifiers do
        if v < 0 then
            percentNegatives[k] = v
        elseif v > 0 then
            percentPositives[k] = v
        end
    end

    for k, v in next, rawPositives do
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_PricePlusCents", v)
    end

    if prosperityModifier > 0 then
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$TOOLTIPS_prosperityTitle_text", "$Format_SignedPercent", prosperityModifier * 100)
    end

    for k, v in next, percentPositives do
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end

    for k, v in next, rawNegatives do
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_PriceMinusCents", -v)
    end
    if prosperityModifier < 0 then
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$TOOLTIPS_prosperityTitle_text", "$Format_SignedPercent", prosperityModifier * 100)
    end
    for k, v in next, percentNegatives do
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", k, "$Format_SignedPercent", v * 100)
    end

    tooltip:setDescription("$TOOLTIPS_Average_Spend_Description_text")
end
function TooltipPopulation.populateBuildingCustomerStatus(tooltip, building)
    local data = building.data
    local fillingStatus
    local fillingColor
    if building.open then
        if data.customerCount == data.maxCustomers then
            fillingStatus = "$RacketFull"
            fillingColor = "statePositive"
        else
            fillingStatus = "$RacketCompeting"
            fillingColor = "stateNeutral"
        end
    else
        fillingStatus = "$Closed"
        fillingColor = "stateNegative"
    end

    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Customers", "$Format_WholeNumber", data.customerCount)
    tooltip:setIcon("Sprites/EmpireView/Icon_CustomerDraw_R_W")
    tooltip:setIconColor("gold")
    tooltip:setSubtitle("$NEIGHBORHOOD_NICKNAME_BOYS_IN_BLUE_desc", "$Format_WholeNumber", data.maxCustomers)
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Status", "$Format_Color", fillingColor, fillingStatus)
    tooltip:setDescription("$TOOLTIPS_Customer_Count_Description_text")
end

-- "$Adjacency_Bonus" --$ Adjacency Bonus
function TooltipPopulation.populateBuildingAdjacencyBonus(tooltip, building)
    local adjacencyEffect = 0
    local drawModifiers = building.data._modifiers.draw
    if drawModifiers then
        adjacencyEffect = drawModifiers["$AdjacentRackets"] or 0
    end

    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Adjacency_Bonus", "$Format_SignedNumber3DecimalPlaces", adjacencyEffect)
    tooltip:setIcon("Sprites/EmpireView/Icon_Proximity_W")
    tooltip:setIconColor("gold")
    tooltip:setDescription("$TOOLTIPS_AdjacencyBonus_Description_text")
end

function TooltipPopulation.populateBuildingStoredWhiskey(tooltip, building)
    local alcoholType = 6
    tooltip:setTitle("$Whiskey")
    tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", building.storage.resources[alcoholType].amount)
    tooltip:setIcon(Alcohol.getIcon(alcoholType))
end

function TooltipPopulation.populateBuildingStoredPremium(tooltip, building)
    local alcoholType = 5
    tooltip:setTitle("$Alcohol_Premium")
    tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", building.storage.resources[alcoholType].amount)
    tooltip:setIcon(Alcohol.getIcon(alcoholType))
end

function TooltipPopulation.populateBuildingStoredTopShelf(tooltip, building)
    local alcoholType = 4
    tooltip:setTitle("$Alcohol_TopShelf")
    tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", building.storage.resources[alcoholType].amount)
    tooltip:setIcon(Alcohol.getIcon(alcoholType))
end

function TooltipPopulation.populateBuildingStoredRack(tooltip, building)
    local alcoholType = 3
    tooltip:setTitle("$Alcohol_Rack")
    tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", building.storage.resources[alcoholType].amount)
    tooltip:setIcon(Alcohol.getIcon(alcoholType))
end

function TooltipPopulation.populateBuildingStoredSwill(tooltip, building)
    local alcoholType = 2
    tooltip:setTitle("$Alcohol_Swill")
    tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", building.storage.resources[alcoholType].amount)
    tooltip:setIcon(Alcohol.getIcon(alcoholType))
end

function TooltipPopulation.populateBuildingStoredPoison(tooltip, building)
    local alcoholType = 1
    tooltip:setTitle("$Alcohol_Poison")
    tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", building.storage.resources[alcoholType].amount)
    tooltip:setIcon(Alcohol.getIcon(alcoholType))
end

function TooltipPopulation.populateBuildingStoredTotal(tooltip, building)
    tooltip:setTitle("$Total")
    tooltip:setSubtitle("$Format_TwoItems", "$Format_Colon", "$Building_Stored", "$Format_Barrels", building.storage.stored)
    tooltip:setIcon("Sprites/RacketView/Icon_Alcohol_Gold")
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Whiskey", "$Format_Barrels", building.storage.resources[6].amount)
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Alcohol_Premium", "$Format_Barrels", building.storage.resources[5].amount)
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Alcohol_TopShelf", "$Format_Barrels", building.storage.resources[4].amount)
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Alcohol_Rack", "$Format_Barrels", building.storage.resources[3].amount)
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Alcohol_Swill", "$Format_Barrels", building.storage.resources[2].amount)
    tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Alcohol_Poison", "$Format_Barrels", building.storage.resources[1].amount)
end

-- --------------------------------------------------
-- Neighborhood Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateNeighborhoodOverview(tooltip, location, hideTitle)
    if not hideTitle then
        tooltip:setTitle(location.name)
        if location.nickname then
            tooltip:setSubtitle("$NeighborhoodNicknameWrapper", location.nickname.name)
        end
    end
    local owner = location.owner
    if owner then
        local color = owner:getKnownIconColors()
        if World.playerFaction:knowsAbout(owner) then
            tooltip:addData("$Format_Colon2Elements", "$Building_Owner", "$Format_Color", color,  owner.boss and owner.boss.name or owner.name)
        else
            tooltip:addData("$Format_Colon2Elements", "$Building_Owner", "$Format_Color", color,  "$Unknown")
        end
    else
        tooltip:addData("$Format_Colon2Elements", "$Building_Owner", "$Nobody")
    end
end

function TooltipPopulation.populateNeighborhoodOwner(tooltip, neighborhood)
    local owner = neighborhood.owner
    if owner then
        local color = owner:getKnownIconColors()
        if owner.isPlayerFaction then
            tooltip:setTitle("$Format_Color", color, owner.name)
            tooltip:addData("$TOOLTIPS_playerOwnerSubtitle_text")
        elseif World.playerFaction:knowsAbout(owner) then
            tooltip:setTitle("$Format_Color", color, owner.name)
            tooltip:addData("$TOOLTIPS_ownerSubtitle_text", owner.boss.name, "$Format_Color", color, owner.name)
        else
            tooltip:setTitle("$Unknown")
            tooltip:addData("$TOOLTIPS_unknownOwnerSubtitle_text")
        end
    else
        tooltip:setTitle("$Nobody")
        tooltip:addData("$TOOLTIPS_noOwnerSubtitle_text")
    end
    tooltip:setSubtitle("$TOOLTIPS_ownerTitle_text")
    tooltip:setDescription("$TOOLTIPS_NeighborhoodScreen_Owner_text")
end

function TooltipPopulation.populateNeighborhoodCustomers(tooltip, neighborhood)
    local totalCustomers = 0
    local playerCustomers = 0
    local buildings = neighborhood.buildings
    for i = 1, #buildings do
        local b = buildings[i]
        if b.faction.isPlayerFaction then
            playerCustomers = playerCustomers + b.data.customerCount
        end
        totalCustomers = totalCustomers + b.data.customerCount
    end

    tooltip:setTitle("$Customers")
    tooltip:addData("$Format_Colon2Elements", "$Total", "$Format_WholeNumber", neighborhood.customerPool)
    tooltip:addData("$Format_Color", "playerOwned", "$Format_Colon2Elements", "$Yours", "$Format_WholeNumber", math.round(playerCustomers))
    tooltip:addData("$Format_Color", "otherOwnedLight", "$Format_Colon2Elements", "$Others", "$Format_WholeNumber", math.round(totalCustomers - playerCustomers))
    tooltip:addData("$Format_Colon2Elements", "$Available", "$Format_WholeNumber", neighborhood.customerPool - math.round(totalCustomers))
    tooltip:addData("$Format_Colon2Elements", "$PcOfCity", "$Format_Percent", (neighborhood.customerPool / World.behaviours:getInterface(World.stateHandle).totalCustomersInChicago) * 100)
    tooltip:addData("$Format_Colon2Elements", "$Building_AverageSpend", "$Format_Price", neighborhood.averageSpend or 0)
end

function TooltipPopulation.populateNeighborhoodEarnings(tooltip, neighborhood)

    local totalIncome = 0
    local playerIncome = 0
    local totalEarningRackets = 0
    local buildings = neighborhood.buildings
    for i = 1, #buildings do
        local b = buildings[i]
        if b.faction.isPlayerFaction then
            playerIncome = playerIncome + b.data.income
        end
        totalIncome = totalIncome + b.data.income
        if b.data.income > 0 then
            totalEarningRackets = totalEarningRackets + 1
        end
    end

    tooltip:setTitle("$Building_Earnings")
    tooltip:addData("$Format_Colon2Elements", "$Total", "$Format_Price", totalIncome)
    tooltip:addData("$Format_Color", "playerOwned", "$Format_Colon2Elements", "$Yours", "$Format_Price", playerIncome)
    tooltip:addData("$Format_Color", "otherOwnedLight", "$Format_Colon2Elements", "$Others", "$Format_Price", totalIncome - playerIncome)
    local ambianceBonus = neighborhood.averageAmbianceBonus or 0
    tooltip:addData("$Format_Colon2Elements", "$Ambiance", "$Format_Percent", ambianceBonus * 100)

    local totalCityEarnings = World.getTotalEarningsForCity()
    if totalCityEarnings > 0 then
        local earningsAsPcOfCity = math.round(((totalIncome) * 1000) / totalCityEarnings) / 10
        tooltip:addData("$Format_Colon2Elements", "$PcOfCity", "$Format_Percent", earningsAsPcOfCity)
    else
        tooltip:addData("$Format_Colon2Elements", "$PcOfCity", "$Format_Percent", 0)
    end

    if totalEarningRackets > 0 then
        local averageRacketIncomeToOneDecimalPlace = math.round(totalIncome / totalEarningRackets, 2)
        tooltip:addData("$Format_Colon2Elements", "$AverageRacketIncome", "$Format_Price", averageRacketIncomeToOneDecimalPlace)
    else
        tooltip:addData("$Format_Colon2Elements", "$AverageRacketIncome", "$Format_Price", 0)
    end
end

function TooltipPopulation.populateNeighborhoodPlayerConsumerIncome(tooltip, neighborhood)
    local playerBuildings = World.playerFaction.buildings
    local totalIncome = 0
    for i = 1, #playerBuildings do
        local building = playerBuildings[i]
        if (building.data.income > 0) and building.locationId == neighborhood.id then
            totalIncome = totalIncome + building.data.income
            tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", building.knownName, "$Format_Price", building.data.income)
        end
    end
    tooltip:setTitle("$Format_Colon2Elements", "$Building_Income", "$Format_Price", totalIncome)
end

local buildingCache = {}
function TooltipPopulation.populateNeighborhoodPlayerConsumerUpkeep(tooltip, neighborhood)

    clearTable(buildingCache)
    local totalUpkeep = 0
    local playerBuildings = World.playerFaction.buildings
    for i = 1, #playerBuildings do
        local building = playerBuildings[i]
        if building.data.consumption and building.data.consumption > 0 and building.locationId == neighborhood.id then
            buildingCache[#buildingCache + 1] = building
            totalUpkeep = totalUpkeep + building.data.upkeep
        end
    end
    tooltip:setTitle("$Format_Colon2Elements", "$Building_Upkeep", "$Format_Price", totalUpkeep)
    for i = 1, #buildingCache do
        local building = buildingCache[i]
        tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", building.knownName, "$Format_Price", building.data.upkeep)
    end
end

function TooltipPopulation.populateNeighborhoodRackets(tooltip, neighborhood)
    local racketsData = neighborhood.wardInfoActor.wardInfo.racketsData

    tooltip:setTitle("$Rackets")
    tooltip:addData("$Format_Colon2Elements", "$Total", "$Format_Number", racketsData.playerCount + racketsData.rivalCount + racketsData.availableCount)
    tooltip:addData("$Format_Color", "playerOwned", "$Format_Colon2Elements", "$Yours", "$Format_Number", racketsData.playerCount)
    tooltip:addData("$Format_Color", "otherOwnedLight", "$Format_Colon2Elements", "$Others", "$Format_Number", racketsData.rivalCount)
    tooltip:addData("$Format_Colon2Elements", "$Format_Fraction", "$Building_Derelict_Name", "$Available", "$Format_Number", racketsData.availableCount)
end

local rawIncrease = {}
local function populateSynergyData(synergyKey, synergyDefinitions, hasHotel, synergies, totalProductionBonus, totalIncomeBonus)
    local playerFaction = World.playerFaction
    local synergyConfig = synergyDefinitions[synergyKey]
    local behaviourId = synergyConfig.behaviourId
    local behaviourConfig = ConfigBuilder.fromId(behaviourId)
    local synergyModifierId
    if hasHotel then
        synergyModifierId = behaviourConfig.hotelModifierId
    else
        synergyModifierId = behaviourConfig.modifierId
    end
    local incomeIncreasePercent = Config.CASH_MODIFIERS[synergyModifierId].percent.SPEAKEASY_INCOME -- Assuming its boosting all racket income
    if synergies:factionHasSynergy(synergyKey, playerFaction) then
        appliedSynergyNames[synergyKey] = synergyConfig.name
        appliedSynergyValues[synergyKey] = incomeIncreasePercent
        local buildings = synergies:getFactionSynergyBuildings(synergyKey, playerFaction)
        for i = 1, #buildings do
            local b = buildings[i]
            if b.buildingType == "Brewery" then
                local rawProduction = 0
                local productionModifiers = b.data._modifiers.production
                for _, modifierValue in next, productionModifiers do
                    rawProduction = rawProduction + modifierValue
                end
                clearTable(systemModfiers)
                World.getAppliedModifiers("generic", "PRODUCTION_OUTPUT", playerFaction.factionId, b.locationId, b:getPrecinctId(), b, systemModfiers)
                for s = 1, #systemModfiers do
                    local key = systemModfiers[s]
                    local valueConfig = Config.GENERIC_MODIFIERS[key]
                    if valueConfig.raw then
                        local value = valueConfig.raw.PRODUCTION_OUTPUT
                        if value then
                            rawProduction = rawProduction + value
                        end
                    end
                end
                local buildingBonus = (rawProduction * incomeIncreasePercent)
                rawIncrease[b] = buildingBonus
                totalProductionBonus = totalProductionBonus + buildingBonus
            else
                local rawIncome = b._baseAverageSpend
                local incomeId = b.buildingData.getConfigValue(b.buildingData._id, "incomeId")
                if rawIncome and incomeId then
                    clearTable(systemModfiers)
                    World.getAppliedModifiers("generic", incomeId, playerFaction.factionId, b.locationId, b:getPrecinctId(), b, systemModfiers)
                    for s = 1, #systemModfiers do
                        local key = systemModfiers[s]
                        local valueConfig = Config.CASH_MODIFIERS[key]
                        if valueConfig.raw then
                            local value = valueConfig.raw[incomeId]
                            if value then
                                rawIncome = rawIncome + value
                            end
                        end
                    end
                    rawIncome = rawIncome * b.data.customerCount
                    local buildingBonus = (rawIncome * incomeIncreasePercent)
                    rawIncrease[b] = buildingBonus
                    totalIncomeBonus = totalIncomeBonus + buildingBonus
                end
            end
        end
    else
        inactiveSynergyNames[synergyKey] = synergyConfig.name
        inactiveSynergyValues[synergyKey] = incomeIncreasePercent
    end
    return totalProductionBonus, totalIncomeBonus
end

function TooltipPopulation.populateNeighborhoodSynergies(tooltip, neighborhood)
    tooltip:setTitle("$RacketSynergies")

    local synergies = World.neighborhoodSynergies[neighborhood.id]
    local synergyDefinitions = Config.BEHAVIOURS.SYNGERGY.synergyDefinitions
    local synergyPriorityList = Config.BEHAVIOURS.SYNGERGY.synergyPriority
    local hasHotel = synergies:factionHasHotel(World.playerFaction)
    local totalIncomeBonus = 0
    local totalProductionBonus = 0

    clearTable(appliedSynergyNames)
    clearTable(appliedSynergyValues)
    clearTable(inactiveSynergyNames)
    clearTable(inactiveSynergyValues)

    for index = 1, #synergyPriorityList do
        local synergyKey = synergyPriorityList[index]
        totalProductionBonus, totalIncomeBonus = populateSynergyData(synergyKey, synergyDefinitions, hasHotel, synergies, totalProductionBonus, totalIncomeBonus)
    end

    tooltip:addData("$Format_Color", "dullWhite", "$Format_Colon", "$Format_Fraction", "$Building_Income", "$UPGRADE_VECTORS_PRODUCTION_name")

    for i = #synergyPriorityList, 1, -1 do
        local k = synergyPriorityList[i]
        if appliedSynergyNames[k] then
            local appliedName = appliedSynergyNames[k]
            local appliedValue = appliedSynergyValues[k]
            tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", appliedName, "$Format_PlusPercent", appliedValue * 100)
        end
        if inactiveSynergyNames[k] then
            local appliedName = inactiveSynergyNames[k]
            local appliedValue = inactiveSynergyValues[k]
            tooltip:addData("$Format_Color", "dullGrey", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", appliedName, "$Format_PlusPercent", appliedValue * 100)
        end
    end

    if totalIncomeBonus > 0 or totalProductionBonus > 0 then
        tooltip:addData("$Format_Color", "dullWhite", "$Format_Colon", "$Total")
        if totalIncomeBonus > 0 then
            tooltip:addData("$Format_TwoItems", "$Format_CashBonus", totalIncomeBonus, "$Building_Income")
        end
        if totalProductionBonus > 0 then
            tooltip:addData("$Format_TwoItems", "$Format_PlusBarrels2DecimalPlaces", totalProductionBonus, "$Building_Production")
        end
    end
    tooltip:setDescription("$TOOLTIPS_NeighborhoodScreen_Breakdown_Synergies_text")
end

function TooltipPopulation.populateSynergyTooltip(tooltip, neighborhood, synergyKey)
    local synergies = World.neighborhoodSynergies[neighborhood.id]
    local synergyDefinitions = Config.BEHAVIOURS.SYNGERGY.synergyDefinitions
    local synergyConfig = synergyDefinitions[synergyKey]
    local hasHotel = synergies:factionHasHotel(World.playerFaction)

    tooltip:setTitle(synergyConfig.name)

    clearTable(appliedSynergyNames)
    clearTable(appliedSynergyValues)
    clearTable(inactiveSynergyNames)
    clearTable(inactiveSynergyValues)
    clearTable(rawIncrease)

    local totalProductionBonus, totalIncomeBonus = populateSynergyData(synergyKey, synergyDefinitions, hasHotel, synergies, 0, 0)

    for _, appliedValue in next, appliedSynergyValues do
        tooltip:setSubtitle("$Format_Color", "statePositive", "$Format_TwoItems", "$Format_Colon", "$Format_Fraction", "$Building_Income", "$UPGRADE_VECTORS_PRODUCTION_name", "$Format_PlusPercent", appliedValue * 100)
        tooltip:addData("$Format_Color", "dullWhite", "$Format_Colon", "$Rackets")
        local buildings = synergies:getFactionSynergyBuildings(synergyKey, World.playerFaction)
        for i = 1, #buildings do
            local b = buildings[i]
            if b.buildingType == "Brewery" then
                tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", buildings[i].name, "$Format_PlusBarrels2DecimalPlaces", rawIncrease[b])
            else
                tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", buildings[i].name, "$Format_CashBonus", rawIncrease[b])
            end
        end
        tooltip:addData("$Format_Color", "dullWhite", "$Format_Colon", "$Total")
        if totalIncomeBonus > 0 then
            tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", "$Building_Income", "$Format_CashBonus", totalIncomeBonus)
        end
        if totalProductionBonus > 0 then
            tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", "$Building_Production", "$Format_PlusBarrels2DecimalPlaces", totalProductionBonus)
        end
    end
    for _, appliedValue in next, inactiveSynergyValues do
        tooltip:setSubtitle("$Format_Color", "dullGrey", "$Format_TwoItems", "$Format_Colon", "$Format_Fraction", "$Building_Income", "$UPGRADE_VECTORS_PRODUCTION_name", "$Format_PlusPercent", appliedValue * 100)
    end
end

function TooltipPopulation.populateNeighborhoodSafehouse(tooltip, neighborhood)
    local safehouse = World.playerFaction:getSafehouseForLocationId(neighborhood.id)
    tooltip:setTitle("$Safehouse")
    if safehouse == nil then
        tooltip:setSubtitle("$NoSafehouseInNeighborhood")
    else
        local lieutenant = safehouse.assignment and safehouse.assignment.character or nil
        if lieutenant then
            tooltip:setIcon(lieutenant.characterIcon)
            tooltip:setIconColor("white")
            tooltip:setSubtitle(lieutenant.name)
            local bonuses = lieutenant:getSafehouseBonusStateNames()
            for i = 1, #bonuses do
                local configId = Behaviour.getBehaviourConfig(bonuses[i])
                local modifierConfig = ConfigBuilder.fromId(configId)
                local modifierId = modifierConfig.modifierId
                local modifierDescriptions = World.getModifierDescriptions(modifierId, lieutenant)
                if modifierDescriptions then
                    for j = 1, #modifierDescriptions do
                        tooltip:addData(modifierDescriptions[j])
                    end
                else
                    logError("no modifier descriptions for modifier", modifierId)
                end
            end
        else
            tooltip:setSubtitle("$NoCapoAssigned")
        end
    end
end

local activeMissions = {}
function TooltipPopulation.populateNeighborhoodMissions(tooltip, neighborhood)
    tooltip:setTitle("$TOOLTIPS_missionGiverTitle_text")
    clearTable(activeMissions)
    local missionsInLocation = World.missions:getActiveMissionsInLocation(neighborhood.id)
    local hasActiveMission = false
    if missionsInLocation then
        for _, mission in pairs(missionsInLocation) do
            if mission._focused then
                hasActiveMission = true
                tooltip:addData("$Format_TextAndTextInBrackets", mission._name, "$TOOLTIPS_activeMissionTitle_text")
            else
                tooltip:addData(mission._name)
            end
        end
    end
    if hasActiveMission then
        tooltip:setSubtitle("$TOOLTIPS_activeMissionSubtitle_text")
    end
end

function TooltipPopulation.populateNeighborhoodPlayerConsumptionAmount(tooltip, neighborhood)
    local playerBuildings = World.playerFaction.buildings
    local consumptionAmount = 0
    for i = 1, #playerBuildings do
        if playerBuildings[i].locationId == neighborhood.id then
            consumptionAmount = consumptionAmount + playerBuildings[i].data.consumption or 0
        end
    end
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Building_Consumption", "$Format_Barrels", consumptionAmount)
    tooltip:setDescription("$TOOLTIPS_AlcoholAmountConsumed_Description_text")
end

function TooltipPopulation.populateNeighborhoodPlayerConsumptionType(tooltip, neighborhood)
    local playerBuildings = World.playerFaction.buildings
    local consumptionTypeName
    local icon
    for i = 1, #playerBuildings do
        if playerBuildings[i].locationId == neighborhood.id and playerBuildings[i].consumer then
            consumptionTypeName = playerBuildings[i].consumer.typeName
            icon = Alcohol.getIcon(playerBuildings[i].consumer.alcoholType)
            break
        end
    end

    tooltip:setTitle("$AlcoholType")
    tooltip:setIcon(icon)
    tooltip:setSubtitle(consumptionTypeName)
    tooltip:setDescription("$TOOLTIPS_AlcoholTypeConsumed_Description_text")
end

local priorityIcons =
{
    "Sprites/EmpireView/Icon_Priority_1",
    "Sprites/EmpireView/Icon_Priority_2",
    "Sprites/EmpireView/Icon_Priority_3",
    "Sprites/EmpireView/Icon_Priority_4",
}

function TooltipPopulation.populateNeighborhoodPlayerPriority(tooltip, neighborhood)
    local playerBuildings = World.playerFaction.buildings
    local priority
    for i = 1, #playerBuildings do
        if playerBuildings[i].locationId == neighborhood.id and playerBuildings[i].consumer then
            priority = playerBuildings[i].consumer.priority
            break
        end
    end
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Priority", priority)
    tooltip:setIcon(priorityIcons[priority])
    tooltip:setIconColor("gold")
    tooltip:setDescription("$TOOLTIPS_AlcoholConsumptionPriority_Description_text")
end

-- --------------------------------------------------
-- Character Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateAdvisorTooltip(tooltip, character)
    tooltip:setTitle("$Rank_Advisor")
    tooltip:setSubtitle(character.knownName)
    tooltip:setIcon("Sprites/AllSharedUI/Icon_PromoteAdvisor_256")
    tooltip:setIconColor("gold")
    tooltip:addData("$Format_Colon2Elements", "$RPC_Review_Loyalty", "$Format_FractionWholeNumber", character.loyalty:get(), character.loyalty:getMax())
    tooltip:addData("$Format_Colon2Elements", "$RPC_Review_Morale", "$Format_FractionWholeNumber", character.morale, character.moraleMax)
    tooltip:setDescription("$TOOLTIPS_Advisor_Description_text")
end

function TooltipPopulation.populateUnderbossTooltip(tooltip, character)
    tooltip:setTitle("$Rank_Underboss")
    tooltip:setSubtitle(character.knownName)
    tooltip:setIcon("Sprites/AllSharedUI/Icon_PromoteUnderBoss_256")
    tooltip:setIconColor("gold")
    tooltip:addData("$Format_Colon2Elements", "$RPC_Review_Loyalty", "$Format_FractionWholeNumber", character.loyalty:get(), character.loyalty:getMax())
    tooltip:addData("$Format_Colon2Elements", "$RPC_Review_Morale", "$Format_FractionWholeNumber", character.morale, character.moraleMax)
    tooltip:setDescription("$TOOLTIPS_Underboss_Description_text")
end

local function populateSection(tooltip, character, behaviourTag, title)
    local createdHeader = false
    for interface in character:allWithTagSorted(behaviourTag) do
        if not createdHeader then
            tooltip:addData("$Format_Colon", title)
            createdHeader = true
        end
        if (not interface.isVisible or interface:isVisible()) and interface._name ~= "CompoundState" then
            local info, multiple = interface:getName()
            if multiple == true then
                for i = 1, #info do
                    local name = info[i]
                    tooltip:addData("$Format_BulletEntry_White", name)
                end
            else
                tooltip:addData("$Format_BulletEntry_White", info)
            end
        end
    end
end

function TooltipPopulation.populateCharacterFullInfo(tooltip, character)
    tooltip:setTitle(character.knownName)

    if character.tier and character.isRPC then
        tooltip:setSubtitle(character.professionName)
        tooltip:addData("$Format_Colon2Elements", "$Tier", "$Format_WholeNumber", character.tier)
        tooltip:addData("$Format_Colon2Elements", "$Character_Take", character:getTake(character.faction.cash.income), character.take)
        tooltip:addData("$Format_Colon2Elements", "$RPC_Review_Loyalty", "$Format_WholeNumber", character.loyalty:get())
    end

    populateSection(tooltip, character, "Trait", "$Floater_Traits")
    populateSection(tooltip, character, "Relationship", "$Floater_Relationships")
    populateSection(tooltip, character, "Effect", "$Floater_StatusEffects")
    populateSection(tooltip, character, "Weapons", "$Floater_StatusEffects")

    local inv = character.inventory
    if inv then
        local primaryWeapon = inv.primaryWeapon
        local secondaryWeapon = inv.secondaryWeapon
        local meleeWeapon = inv.meleeWeapon

        if primaryWeapon or secondaryWeapon or meleeWeapon then
            tooltip:addData("$Format_Colon", "$Inventory_EquippedWeapons")
            if primaryWeapon then
                tooltip:addData("$Format_BulletEntry_White", primaryWeapon:get("name"))
            end
            if secondaryWeapon then
                tooltip:addData("$Format_BulletEntry_White", secondaryWeapon:get("name"))
            end
            if meleeWeapon then
                tooltip:addData("$Format_BulletEntry_White", meleeWeapon:get("name"))
            end
        end
    end
end

function TooltipPopulation.populateCharacterInfo(tooltip, character, hideTitle)
    if not hideTitle then
        tooltip:setTitle(character.knownName)
        tooltip:setIcon(character.characterIcon)
        tooltip:setIconColor("white")
        tooltip:setSubtitle(character.professionName)
    end
    tooltip:addData("$Format_Colon2Elements", "$Tier", "$Format_WholeNumber", character.tier)
    if character.isRPC then
        tooltip:addData("$Format_Colon2Elements", "$Character_Take", character:getTake(character.faction.cash.income), character.take)
        tooltip:addData("$Format_Colon2Elements", "$RPC_Review_Loyalty", "$Format_WholeNumber", character.loyalty:get())
    elseif character.notorietyModifier then
        tooltip:addData("$Format_Colon2Elements", "$notoriety_noun", "$Format_PairSlash", character.notorietyModifier, character.notorietyMax)
    end
end

function TooltipPopulation.populateCharacterLocation(tooltip, character, hideTitle)
    local locationId = character:getLocationId()
    if locationId == 0 then
        tooltip:addData("$Unknown")
    else
        local location = World.getLocation(locationId)
        if location.isExterior then
            TooltipPopulation.populateNeighborhoodOverview(tooltip, location, hideTitle)
        else
            local building = location.building
            TooltipPopulation.populateBuildingTooltip(tooltip, building, hideTitle)
        end
    end
end

local function getItemColorFormatString(item, includeBullet)
    if includeBullet then
        return { "$Format_Color", item:getRarity(), "$Format_BulletEntry", item:get("name") }
    else
        return { "$Format_Color", item:getRarity(), item:get("name") }
    end
end

function TooltipPopulation.populateCharacterInventory(tooltip, character, useRealName)
    local name = useRealName and character.name or character.knownName
    tooltip:setTitle(name)
    if character.faction.isLawEnforcement then
        tooltip:setIcon("Sprites/CrewView/professionLawEnforcement")
        tooltip:setIconColor("gold")
        tooltip:setSubtitle("$Profession_LawEnforcement")
    elseif character.profession then
        local mainProfession = character.profession:getMain()
        if mainProfession.icon then
            tooltip:setIcon(mainProfession.icon)
            tooltip:setIconColor("gold")
        else
            -- logError("profession is missing an icon:", mainProfession._name)
        end
        tooltip:setSubtitle(mainProfession.stringsKey)
    end
    tooltip:setFaction(character.faction)
    tooltip:addPolledData(character, character.getHealthString)

    local inventory = character.inventory
    local primaryWeapon = inventory.primaryWeapon
    local secondaryWeapon = inventory.secondaryWeapon
    local meleeWeapon = inventory.meleeWeapon
    local equipment = inventory.equipment
    local utility1 = inventory.utility1
    local utility2 = inventory.utility2

    if primaryWeapon or secondaryWeapon or meleeWeapon then
        local numWeapons = (primaryWeapon and 1 or 0) + (secondaryWeapon and 1 or 0) + (meleeWeapon and 1 or 0)
        tooltip:addData("$Format_Colon", numWeapons == 1 and "$weapon_noun" or "$Character_Sheet_Weapons")
    end

    if primaryWeapon then
        local primaryWeaponAmmo = inventory.primaryWeaponAmmo
        if primaryWeaponAmmo and not primaryWeaponAmmo:get("isDefaultAmmo") then
            tooltip:addData("$Format_TextAndTextInBrackets", getItemColorFormatString(primaryWeapon, true), getItemColorFormatString(primaryWeaponAmmo))
        else
            tooltip:addData(getItemColorFormatString(primaryWeapon, true))
        end
    end

    if secondaryWeapon then
        local secondaryWeaponAmmo = inventory.secondaryWeaponAmmo
        if secondaryWeaponAmmo and not secondaryWeaponAmmo:get("isDefaultAmmo") then
            tooltip:addData("$Format_TextAndTextInBrackets", getItemColorFormatString(secondaryWeapon, true), getItemColorFormatString(secondaryWeaponAmmo))
        else
            tooltip:addData(getItemColorFormatString(secondaryWeapon, true))
        end
    end

    if meleeWeapon then
        tooltip:addData(getItemColorFormatString(meleeWeapon, true))
    end

    if equipment then
        tooltip:addData("$Format_Colon", "$Character_Sheet_Equipment")
        tooltip:addData(getItemColorFormatString(equipment, true))
    end

    if utility1 or utility2 then
        tooltip:addData("$Format_Colon", "$Character_Sheet_Utility")
    end

    if utility1 then
        tooltip:addData(getItemColorFormatString(utility1, true))
    end

    if utility2 then
        tooltip:addData(getItemColorFormatString(utility2, true))
    end

    populateSection(tooltip, character, "Effect", "$Floater_StatusEffects")
end

function TooltipPopulation.populateCharacterRequiredNotoriety(tooltip, character)
    -- "$Notoriety_Requirement" --$ Notoriety Requirement
    local notorietyGate
    tooltip:setTitle("$Notoriety_Requirement")
    if character:hasState("ForceHireable") then
        notorietyGate = 0
    else
        notorietyGate = character.notorietyGate
    end
    tooltip:setIcon("Sprites/AllSharedUI/Icon_Notoriety")
    tooltip:setIconColor("gold")
    -- "$Required" --$ Required
    tooltip:addData("$Format_Colon2Elements", "$Required", notorietyGate)
    local playerNotoriety = World.player.notorietyModifier
    local notorietyColor = (playerNotoriety >= notorietyGate) and "statePositive" or "stateNegative"
    tooltip:addData("$Format_Color", notorietyColor, "$Format_Colon2Elements", "$Character_YourNotoriety", playerNotoriety)
    if not (character.faction and character.faction.isPlayerFaction) then
        if character:playerHasEnoughNotoriety() or character:hasState("ForceHireable") then
            tooltip:setDescription("$Notoriety_Sufficient") --$ You have enough notoriety for this gangster
        else
            tooltip:setDescription("$Notoriety_Insufficient") --$ You do not have enough notoriety for this gangster
        end
    end
end

function TooltipPopulation.populateCharacterProfession(tooltip, character)
    tooltip:setTitle(character.professionName)
    tooltip:setSubtitle("$profession_noun")
    local profession = character.profession:getMain()
    tooltip:setIcon(profession.icon)
    tooltip:setIconColor("gold")
    local handle = profession.handle
    for text in character.behaviours:getCurrentModifiers(handle) do
        tooltip:addData(text)
    end
    local bonusHandles = profession.professionBonusHandles
    if bonusHandles then
        for i = 1, #bonusHandles do
            local bonusInterface = character.behaviours:getInterface(bonusHandles[i])
            local effects = bonusInterface:getEffectDescriptions()
            for j = 1, #effects do
                tooltip:addData(effects[j])
            end
        end
    end
    tooltip:setDescription("$TOOLTIPS_Profession_Description_text")
end

function TooltipPopulation.populateCharacterRole(tooltip, character)
    tooltip:setTitle("$Role")
    tooltip:setSubtitle(character.rankName)
    tooltip:setDescription("$TOOLTIPS_Role_Description_text")
end

function TooltipPopulation.populateCharacterTier(tooltip, character)
    tooltip:setTitle("$Format_Colon2Elements", "$Tier", "$Format_WholeNumber", character.tier)
    local tierCount = 5
    local lowestTier = 1
    local highestTier = 5
    tooltip:setDescription("$TOOLTIPS_Tier_Description_text", tierCount, lowestTier, highestTier)
end

function TooltipPopulation.populateCharacterTake(tooltip, character)
    tooltip:setTitle("$Format_Colon2Elements", "$Take", "$Character_Take", character:getTake(character.faction.cash.income), character.take)
    tooltip:setDescription("$TOOLTIPS_Take_Description_text")
end

function TooltipPopulation.populateCharacterUpfrontCost(tooltip, character)
    tooltip:setTitle("$Format_Colon2Elements", "$Character_Sheet_HireCost", "$Format_Price", character.hireCost)
    tooltip:setDescription("$TOOLTIPS_Upfront_Description_text")
end

function TooltipPopulation.populateCharacterLoyalty(tooltip, character)
    tooltip:setTitle("$Format_Colon2Elements", "$RPC_Review_Loyalty", "$Format_FractionWholeNumber", character.loyalty:get(), character.loyalty:getMax())
    tooltip:setDescription("$TOOLTIPS_Loyalty_Description_text")
end

function TooltipPopulation.populateCharacterMorale(tooltip, character)
    tooltip:setTitle("$Format_Colon2Elements", "$RPC_Review_Morale", "$Format_FractionWholeNumber", character.morale, character.moraleMax)
    tooltip:setDescription("$TOOLTIPS_Morale_Description_text")
end

-- --------------------------------------------------
-- Faction Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateFaction(tooltip, faction, inspectingFaction)
    local playerFaction = World.playerFaction
    inspectingFaction = inspectingFaction or playerFaction
    local known = playerFaction:knowsAbout(faction)
    local color = faction:getKnownIconColors()
    tooltip:setTitle("$Format_Color", color, faction.name)
    tooltip:setIcon(known and faction.icon or "Sprites/EmpireView/Icon_UnKnown_G")
    tooltip:setIconColor("white")
    if known then
        local factionInspected, factionInspecting
        if inspectingFaction.isPlayerFaction and not faction.isPlayerFaction then -- Flip the factions for the next section
            factionInspected = inspectingFaction
            factionInspecting = faction
        elseif not inspectingFaction.isPlayerFaction then
            factionInspected = faction
            factionInspecting = inspectingFaction
        end
        if faction.isPlayerFaction then
            tooltip:setSubtitle("$Format_PairDash", faction.boss.name, "$Format_Color", "player", "$Player")
        else
            if faction.boss then
                tooltip:setSubtitle(faction.boss.name)
            end
        end
        if faction.boss then
            local honor = faction.honor:getScore()
            local honorColor = (honor > 45 and "peer") or (honor > -46 and "neutral") or "enemy"
            tooltip:addData("$Format_Color", honorColor, "$Format_Colon2Elements", "$Honor", "$Format_PlusMinusNumber", honor)
            local notoriety = faction.boss.notorietyModifier
            tooltip:addData("$Format_Colon2Elements", "$notoriety_noun", "$Format_WholeNumber", notoriety)
        end

        -- This bit gets flipped if we're looking at the player
        if factionInspected then
            --"$StandingWithFaction" --$ Current Standing with {0}
            tooltip:addData("$Format_Color", "dullWhite", "$Format_Colon", "$StandingWithFaction", inspectingFaction.name)
            local diplomaticStatus
            local diplomaticStatusText
            local war = factionInspecting.diplomacy:getStateInterface("WAR", factionInspected)
            if war then
                diplomaticStatus = "war"
                diplomaticStatusText = war:getName()
            else
                diplomaticStatus = factionInspecting.rating:getDiplomaticStatus(factionInspected)
                diplomaticStatusText = factionInspecting.rating:getOpinionStringKey(diplomaticStatus)
            end

            local rating = factionInspecting.rating:getScore(factionInspected)
            local attitude, attitudeName = factionInspecting.attitudes:get(factionInspected)
            local threatRating = factionInspecting.threat:getScore(factionInspected)
            local threatColor = (threatRating > 65 and "enemy") or (threatRating > 15 and "neutral") or "peer"
            tooltip:addData("$Format_Color", diplomaticStatus, "$Format_BulletEntry", "$Format_Colon2Elements", "$Faction_Rating", "$Format_TextAndTextInBrackets", "$Format_PlusMinusNumber", rating, diplomaticStatusText)
            tooltip:addData("$Format_Color", threatColor, "$Format_BulletEntry", "$Format_Colon2Elements", "$Threat_Rating", "$Format_PlusMinusNumber", threatRating)
            tooltip:addData("$Format_Color", attitude, "$Format_BulletEntry", "$Format_TwoItems", "$Attitude", attitudeName)
        end
    else
        tooltip:setDescription("$YouHaventMetThisFactionYet") --$ You haven't met this faction yet.
    end
end

function TooltipPopulation.populateFactionNotorietyTooltip(tooltip, faction, hideTitle)
    TooltipPopulation.populateBossNotorietyTooltip(tooltip, faction.boss, hideTitle)
end

function TooltipPopulation.populateBossNotorietyTooltip(tooltip, boss, hideTitle)
    if not hideTitle then
        tooltip:setTitle("$notoriety_noun")
    end
    boss = boss or World.player
    tooltip:setDescription("$ResourceSummary_Notoriety_Text", boss.notorietyModifier, boss.notorietyMax)
end

function TooltipPopulation.populateFactionHonorTooltip(tooltip, faction, hideTitle)
    if not hideTitle then
        tooltip:setTitle("$Honor")
    end
    local blocks = faction.honor._blocks
    local next = next
    for effectId, effectBlock in next, blocks do
        local delta = effectBlock._deltaId and World.getModifiedValue("honor", effectBlock._deltaId, faction.factionId, 0, 0, World.playerFaction) or 0
        if effectBlock._value < 0 then
            if delta > 0 then
                tooltip:addData("$Format_NegativeModifierPositiveDelta", effectBlock._name, effectBlock._value, delta)
            elseif delta < 0 then
                tooltip:addData("$Format_NegativeModifierNegativeDelta", effectBlock._name, effectBlock._value, delta)
            else
                tooltip:addData("$Format_NegativeModifier", effectBlock._name, effectBlock._value)
            end
        else
            if delta > 0 then
                tooltip:addData("$Format_PositiveModifierPositiveDelta", effectBlock._name, effectBlock._value, delta)
            elseif delta < 0 then
                tooltip:addData("$Format_PositiveModifierNegativeDelta", effectBlock._name, effectBlock._value, delta)
            else
                tooltip:addData("$Format_PositiveModifier", effectBlock._name, effectBlock._value)
            end
        end
    end

end

function TooltipPopulation.populateFactionRatingTooltip(tooltip, faction, hideTitle)
    local playerFaction = World.playerFaction
    if not hideTitle then
        local diplomaticStatus
        local diplomaticStatusIcon
        local ratingName
        local war = faction.diplomacy:getStateInterface("WAR", playerFaction)
        if war then
            diplomaticStatus = "war"
            diplomaticStatusIcon = war:getStateIcon()
            ratingName = "$War"
        else
            diplomaticStatus = faction.rating:getDiplomaticStatus(playerFaction)
            diplomaticStatusIcon = faction.rating:getOpinionIcon(diplomaticStatus)
            ratingName = faction.rating:getOpinionStringKey(diplomaticStatus)
        end
        tooltip:setTitle("$Faction_Rating")
        tooltip:setIcon(diplomaticStatusIcon)
        tooltip:setIconColor(diplomaticStatus)
        tooltip:setSubtitle("$Format_Color", diplomaticStatus, ratingName)
    end
    local blocks = faction.rating._blocks[World.playerFaction.factionId]
    local next = next
    for effectId, effectBlock in next, blocks do
        local delta = effectBlock._deltaId and World.getModifiedValue("rating", effectBlock._deltaId, faction.factionId, 0, 0, playerFaction) or 0
        if effectBlock._value < 0 then
            if delta > 0 then
                tooltip:addData("$Format_NegativeModifierPositiveDelta", effectBlock._name, effectBlock._value, delta)
            elseif delta < 0 then
                tooltip:addData("$Format_NegativeModifierNegativeDelta", effectBlock._name, effectBlock._value, delta)
            else
                tooltip:addData("$Format_NegativeModifier", effectBlock._name, effectBlock._value)
            end
        else
            if delta > 0 then
                tooltip:addData("$Format_PositiveModifierPositiveDelta", effectBlock._name, effectBlock._value, delta)
            elseif delta < 0 then
                tooltip:addData("$Format_PositiveModifierNegativeDelta", effectBlock._name, effectBlock._value, delta)
            else
                tooltip:addData("$Format_PositiveModifier", effectBlock._name, effectBlock._value)
            end
        end
    end
end

function TooltipPopulation.populateFactionThreatTooltip(tooltip, faction, hideTitle)
    if not hideTitle then
        tooltip:setTitle("$Threat_Rating")
    end
    local blocks = faction.threat._blocks[World.playerFaction.factionId]
    local next = next
    for effectId, effectBlock in next, blocks do
        local delta = effectBlock._deltaId and World.getModifiedValue("threat", effectBlock._deltaId, faction.factionId, 0, 0, World.playerFaction) or 0
        if effectBlock._value < 0 then
            if delta > 0 then
                tooltip:addData("$Format_PositiveModifierNegativeDelta", effectBlock._name, effectBlock._value, delta)
            elseif delta < 0 then
                tooltip:addData("$Format_PositiveModifierPositiveDelta", effectBlock._name, effectBlock._value, delta)
            else
                tooltip:addData("$Format_PositiveModifier", effectBlock._name, effectBlock._value)
            end
        else
            if delta > 0 then
                tooltip:addData("$Format_NegativeModifierNegativeDelta", effectBlock._name, effectBlock._value, delta)
            elseif delta < 0 then
                tooltip:addData("$Format_NegativeModifierPositiveDelta", effectBlock._name, effectBlock._value, delta)
            else
                tooltip:addData("$Format_NegativeModifier", effectBlock._name, effectBlock._value)
            end
        end
    end
end

function TooltipPopulation.populateFactionInNeighborhood(tooltip, faction, neighborhood)
    local sharedFactionAI = FactionAI.getSharedFactionAI()
    local sharedSensor = sharedFactionAI.sharedSensor
    local neighborhoodFactionsEntry = sharedSensor.wards[neighborhood.id].factions
    local factionEntry = neighborhoodFactionsEntry[faction.configId]
    local buildingCount = factionEntry.buildings.thisFaction.numAll
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Rackets", "$Format_Count", buildingCount)

    TooltipPopulation.populateFaction(tooltip, faction)
end

function TooltipPopulation.populateSafehouseDiscoveryTooltip(tooltip, faction)
    local safehouse = faction.primarySafehouse
    local safehouseMixin = safehouse and safehouse._buildingMixin
    tooltip:setTitle(safehouseMixin:getKnownName())
    tooltip:setIcon(safehouse:getIcon())
    tooltip:setIconColor("gold")
    if safehouseMixin and safehouseMixin.isHiddenToFaction then
        if safehouseMixin:isHiddenToFaction(World.playerFaction) then
            local discoveryChance = safehouseMixin.discoveryChance[World.playerFaction.configId] or 0
            tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Location", "$Unknown")
            --"$DiscoveryChance" --$ Chance of Discovery
            tooltip:addData("$Format_TwoItems", "$Format_Colon", "$DiscoveryChance", "$Format_Percent", discoveryChance * 100)
            tooltip:setDescription("$TOOLTIPS_SafehouseDiscovery_Description_text")
        else
            local precinct = World.getPrecinct(safehouse:getPrecinctId())
            local location = World.getLocation(safehouse.locationId)
            tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Location", location.name)
            tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Precinct", precinct.name)
            tooltip:setDescription("$TOOLTIPS_Safehouse_Tooltip_Description_text")
        end
    end
end

-- --------------------------------------------------
-- Precinct Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateCustomerCountTooltip(tooltip, precinct)
    local customerCapacity = precinct:getCustomerCapacity()
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Precinct_Customers", "$Format_FractionWholeNumber", precinct.customerCount, customerCapacity)
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$CountAlreadyInPrecinct", "$Format_WholeNumber", precinct.customerCount)

    -- Customer Capacity
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Precinct_CustomersCapacity", "$Format_WholeNumber", customerCapacity)
    local racketPrecinctCapacity = 0
    tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Base_Value", "$Format_SignedNumber3DecimalPlaces", Config.WORLD.PRECINCTS.customerCapacityBase or 0)
    for i = 1, #precinct.buildings do
        local precinctCustomerCapacity = precinct.buildings[i].data.precinctCustomerCapacity
        if precinctCustomerCapacity then
            racketPrecinctCapacity = racketPrecinctCapacity + precinctCustomerCapacity
        end
    end
    local changeColor = "gold"
    if racketPrecinctCapacity > 0 then
        changeColor = "statePositive"
    elseif racketPrecinctCapacity < 0 then
        changeColor = "stateNegative"
    end
    tooltip:addData("$Format_Color", changeColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Rackets", "$Format_PlusMinusNumber", racketPrecinctCapacity)
    populateWorldModifierData(tooltip, false, "generic", "PRECINCT_CUSTOMER_CAPACITY", precinct.faction.factionId, precinct.locationId, precinct.id)

    -- Weekly Change
    local customerChange = precinct:getCustomerGrowth(true) -- Use predicted growth
    changeColor = "gold"
    if customerChange > 0 then
        changeColor = "statePositive"
    elseif customerChange < 0 then
        changeColor = "stateNegative"
    end
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Precinct_CustomersWeeklyChange", "$Format_Color", changeColor, "$Format_PlusMinusNumber", customerChange)
    -- Design: The base formula is that customers will grow by 90 a week.
    local baseGrowth = Config.WORLD.PRECINCTS.customerGrowthPerWeek
    tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Base_Value", "$Format_SignedNumber3DecimalPlaces", baseGrowth)
    -- Show alcohol effect on growth
    local consumption = precinct.consumption or precinct:getConsumption()
    if consumption > 0 then
        local predictedAlcoholGrowth = precinct:getPredictedAlcoholGrowthBonus()
        predictedAlcoholGrowth = math.floor(predictedAlcoholGrowth) -- This will change with poison
        tooltip:addData("$Format_Color", "statePositive", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$AlcoholServed", "$Format_SignedNumber3DecimalPlaces", predictedAlcoholGrowth)
    end

    local racketEffectOnGrowth = 0
    for i = 1, #precinct.buildings do
        local precinctCustomerGrowth = precinct.buildings[i].data.precinctCustomerGrowth
        if precinctCustomerGrowth then
            racketEffectOnGrowth = racketEffectOnGrowth + precinctCustomerGrowth
        end
    end
    changeColor = "gold"
    if racketEffectOnGrowth > 0 then
        changeColor = "statePositive"
    elseif racketEffectOnGrowth < 0 then
        changeColor = "stateNegative"
    end
    tooltip:addData("$Format_Color", changeColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Rackets", "$Format_PlusMinusNumber", racketEffectOnGrowth)
    -- Design: Each point of police activity reduces this number by 1.
    local policeActivity = math.floor(precinct:getPoliceActivity())
    if policeActivity ~= 0 then
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Police_Activity", "$Format_SignedNumber3DecimalPlaces", -policeActivity)
    end
    -- Design: Each 270 customers in the precinct reduces the growth by 10 points.
    local customerCountStep = Config.WORLD.PRECINCTS.customerCountEffectOnGrowthStep
    local customerEffectOnGrowth = Config.WORLD.PRECINCTS.customerCountEffectOnGrowthAmount
    local congestion = (math.floor(precinct.customerCount/customerCountStep) * customerEffectOnGrowth)
    if congestion ~= 0 then
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Precinct_CustomerCrowds", "$Format_SignedNumber3DecimalPlaces", congestion)
    end
    populateWorldModifierData(tooltip, false, "generic", "PRECINCT_CUSTOMER_GROWTH", precinct.faction.factionId, precinct.locationId, precinct.id)

    tooltip:setDescription("$TOOLTIPS_PrecinctCustomers_Description_text")
end

function TooltipPopulation.populateRacketCustomersTooltip(tooltip, precinct)

    local racketCapacity = 0
    for i = 1, #precinct.buildings do
        local b = precinct.buildings[i]
        if b.data.racketCustomerCapacity and (b.data.racketCustomerCapacity ~= 0) then
            racketCapacity = racketCapacity + b.data.racketCustomerCapacity
            tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", b.name, "$Format_FractionWholeNumber", b.data.customerCount, b.data.racketCustomerCapacity)
        end
    end
    local customersInRackets = math.min(racketCapacity, precinct.customerCount)
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Precinct_CustomersInRackets", "$Format_FractionWholeNumber", customersInRackets, racketCapacity)

    tooltip:setDescription("$TOOLTIPS_PrecinctCustomersInRackets_Description_text")
end

function TooltipPopulation.populateAvailableRequiredCustomersTooltip(tooltip, precinct)
    local customerCount = precinct.customerCount
    local racketCapacity = 0
    for i = 1, #precinct.buildings do
        local b = precinct.buildings[i]
        if b.open ~= false then
            racketCapacity = racketCapacity + (b.data.racketCustomerCapacity or 0)
        end
    end
    local customersInRackets = math.min(racketCapacity, customerCount)
    if customersInRackets < racketCapacity then
        tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Precinct_RequiredCustomers", "$Format_Color", "stateNegative", "$Format_WholeNumber", racketCapacity - customersInRackets)
        tooltip:setDescription("$TOOLTIPS_PrecinctRequiredCustomers_Description_text")
    else
        tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Precinct_AvailableCustomers", "$Format_Color", "statePositive", "$Format_WholeNumber", customerCount - customersInRackets)
        tooltip:setDescription("$TOOLTIPS_PrecinctAvailableCustomers_Description_text")
    end
end

function TooltipPopulation.populatePoliceActivityTooltip(tooltip, precinct)
    local maxPoliceActivity = 100
    local policeActivity = math.clamp(0, maxPoliceActivity, precinct:getPoliceActivity())
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$Police_Activity", "$Format_FractionWholeNumber", policeActivity, maxPoliceActivity)

    local policeFaction = World.getFaction("FACTION.CHICAGO_POLICE")
    local rating = policeFaction.rating:getScore(precinct.faction) or 0

    -- We need to convert the -500 -> 500 rating range to a 50 -> -50 Police Activity Modifier. -50 is good since it will lower police activity, reflecting the player's relationship.
    local relationshipModifier = -rating / 10
    local relationshipColor = (relationshipModifier > 0) and "stateNegative" or (relationshipModifier < 0) and "statePositive" or "stateNeutral"
    -- "$Police_Relationship" --$ Police Relationship
    tooltip:addData("$Format_Color", relationshipColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Police_Relationship", "$Format_SignedNumber2DecimalPlaces", relationshipModifier)

    populateWorldModifierData(tooltip, true, "generic", "POLICE_ACTIVITY", precinct.faction.factionId, precinct.locationId, precinct.id)

    if precinct._temporaryPoliceActivity > 0 then
        tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", "$Combat_Kills", "$Format_SignedNumber2DecimalPlaces", precinct._temporaryPoliceActivity)
    end

    local buildings = precinct.buildings
    for i = 1, #buildings do
        local cur = buildings[i]
        if cur.data.criminalActivity > 0 then
            tooltip:addData("$Format_Color", "stateNegative", "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", cur.name, "$Format_SignedNumber2DecimalPlaces", cur.data.criminalActivity)
        end
    end
    tooltip:setDescription("$TOOLTIPS_PoliceActivity_Description_text")
end

function TooltipPopulation.populateRaidChanceTooltip(tooltip, precinct)
    local raidChance = precinct:getRaidChance()
    tooltip:setTitle("$Format_TwoItems", "$Format_Colon", "$GENERIC_DEFINITIONS_RAID_CHANCE_description", "$Format_Percent", raidChance * 100)
    tooltip:setDescription("$TOOLTIPS_PoliceRaidChance_Description_text")
end

function TooltipPopulation.populatePrecinctDefendersTooltip(tooltip, precinct)
--[[ OLD CODE
local defending, reinforcements = precinct:getDefenderCounts()
    -- "$PrecinctInfo_Defenders_Title" --$ Defenders
    -- "$PrecinctInfo_Defenders_Subtitle" --$ Reinforcements
    tooltip:setTitle("$Format_Colon2Elements", "$PrecinctInfo_Defenders_Title", "$Format_Times", defending)
    tooltip:setIcon("Sprites/AllSharedUI/Icon_Crew")
    tooltip:setIconColor("gold")
    if reinforcements > 0 then
        tooltip:setSubtitle("$Format_Colon2Elements", "$PrecinctInfo_Defenders_Subtitle", "$Format_Times", reinforcements)
        local round = 2
        for _, building in next, precinct.racketBuildings do
            if not building.damaged and building.faction == precinct.faction then
                tooltip:addData("$PrecinctInfo_ReinforcementRound_Data", round, 2, building.name) --$ • Round {0}: x{1} from {2}.
                round = round + 2
            end
        end
    end
    local depotString = precinct.primaryBuilding.isSafehouse and "$Safehouse" or "$Depot"
    tooltip:setDescription("$PrecinctInfo_Defenders_Description", depotString) --$ How many defenders are guarding the {0}. Any equipped, undamaged rackets will supply the {0} with reinforcements during an attack.
    ]]
    -- NEW CODE
    local precinctMax = "?"
    local racketCapacity = "?"
    local inRackets = "?"
    tooltip:setTitle("$PrecinctInfo_Customers_TooltipTitle") --$ Customers
    tooltip:setDescription("$PrecinctInfo_Customers_Description") --$ The surplus or deficit of customers for this precinct. \nA negative number means that there is spare capacity in your rackets and you need to attract more customers to the precinct. \nA positive number indicates that there are more customers in the precinct than the rackets can handle and you need to increase the capacity in your rackets to maximise earnings.
    -- END
end

--MODIFIED - NEW CODE - NOT WORKING (may require UI changes)
function TooltipPopulation.populatePrecinctConsumptionTooltip(tooltip, precinct)
	tooltip:setTitle("$PrecinctInfo_Consumption_TooltipTitle") --$ Consumption
    tooltip:setDescription("$PrecinctInfo_Consumption_Description") --$ The amount of alcohol being consumed by the rackets in this Precinct.
end
--END 


function TooltipPopulation.populatePrecinctDepotTooltip(tooltip, precinct)
    local depotBuilding = precinct.primaryBuilding
    local isSafehouse = precinct.primaryBuilding.isSafehouse
    tooltip:setTitle(depotBuilding:getBuildingTypeName())
    tooltip:setIcon(depotBuilding:getIcon())
    tooltip:setIconColor("gold")
    tooltip:setFaction(precinct.faction)
    if isSafehouse and not precinct.faction.isPlayerFaction then
        local isKnownToPlayer = precinct.primaryBuilding.isKnownToPlayer
        if isKnownToPlayer then
            -- "$Revealed" --$ Revealed
            tooltip:setSubtitle("$Format_Color", "statePositive", "$Revealed")
        else
            -- "$Hidden" --$ Hidden
            tooltip:setSubtitle("$Format_Color", "stateNeutral", "$Hidden")
        end
    end
    if precinct.faction.isPlayerFaction then
    --NEW CODE
    local defending, reinforcements = precinct:getDefenderCounts()
    tooltip:setTitle("$Format_Colon2Elements", "$PrecinctInfo_Defenders_Title", "$Format_Times", defending)
    if reinforcements > 0 then
        tooltip:setSubtitle("$Format_Colon2Elements", "$PrecinctInfo_Defenders_Subtitle", "$Format_Times", reinforcements)
        local round = 2
        for _, building in next, precinct.racketBuildings do
            if not building.damaged and building.faction == precinct.faction then
                tooltip:addData("$PrecinctInfo_ReinforcementRound_Data2", round, 2, building.name) --$ • Round {0}: x{1} from {2}.
                round = round + 2
            end
        end
    end
    local depotString = precinct.primaryBuilding.isSafehouse and "$Safehouse" or "$Depot"
    tooltip:setDescription("$PrecinctInfo_Defenders_Description2", depotString) --$ How many defenders are guarding the {0}. Any equipped, undamaged rackets will supply the {0} with reinforcements during an attack.
    --END    
        --[[ OLD CODE 
        if isSafehouse then
            tooltip:setDescription("$PrecinctInfo_PlayerSafehouse_Description") --$ Your safehouse is in this precinct. All other precincts will need to connect to this precinct in order for you to supply them.
        else
            tooltip:setDescription("$PrecinctInfo_PlayerDepot_Description") --$ You have a depot in this precinct. This precinct will need to connect to your safehouse in order for you to supply it.
        end
        ]]
    else
        if isSafehouse then
            tooltip:setDescription("$PrecinctInfo_EnemySafehouse_Description") --$ The enemy safehouse is in this precinct.
        elseif precinct.faction.isThugFaction then
            tooltip:setDescription("$PrecinctInfo_ThugDepot_Description") --$ A thug depot is in this precinct.
        else
            tooltip:setDescription("$PrecinctInfo_EnemyDepot_Description") --$ An enemy depot is in this precinct.
        end
    end
end

function TooltipPopulation.populatePrecinctAvailableBuildingsTooltip(tooltip, precinct)
    tooltip:setIcon("Sprites/Icons/Buildings/Icon_Racket_Sale_W")
    tooltip:setIconColor("gold")
    tooltip:setTitle("$PrecinctInfo_Build_Title") --$ Available Buildings
    tooltip:setDescription("$PrecinctInfo_Build_Description") --$ There are buildings available to purchase in this precinct.
end

function TooltipPopulation.populatePrecinctSupplyCutOffTooltip(tooltip, precinct)
    local depotBuilding = precinct.primaryBuilding
    tooltip:setTitle(depotBuilding:getBuildingTypeName())
    tooltip:setIcon(depotBuilding:getIcon())
    tooltip:setIconColor("gold")
    tooltip:setFaction(precinct.faction)
    tooltip:addData("$Format_Color", "stateNegative",
            "$PrecinctInfo_SupplyLineCutoff_Title") --$ Not connected to Safehouse
    tooltip:setDescription("$PrecinctInfo_SupplyLineCutoff_Description") --$ This precinct has no supply line connection to your Safehouse. Rackets in this Precinct will not generate income or alcohol until reconnected to the supply line.
end

function TooltipPopulation.populatePrecinctIncomeTooltip(tooltip, precinct)
    tooltip:setTitle("$Format_Colon2Elements", "$NetIncome", "$Format_Price", precinct:getNetIncome())
    for _, building in next, precinct.buildings do
        if building.faction == precinct.faction then
            local netIncome = building.data.income - building.data.upkeep
            if netIncome > 0 then
                tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", building.name, "$Format_Color", "statePositive", "$Format_PricePlusCents", netIncome)
            elseif netIncome < 0 then
                tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", building.name, "$Format_Color", "stateNegative", "$Format_PriceMinusCents", -netIncome)
            end
        end
    end
    tooltip:setDescription("$PrecinctInfo_NetIncome_Description") --$ The combined net income of this precinct.
end

function TooltipPopulation.populatePrecinctOwner(tooltip, precinct)
    local owner = precinct.faction
    local color = owner:getKnownIconColors()
    if owner.isPlayerFaction or World.playerFaction:knowsAbout(owner) then
        tooltip:setTitle("$Format_Color", color, owner.name)
    else
        tooltip:setTitle("$Unknown")
    end
    tooltip:setSubtitle("$Building_Owner")
end

-- --------------------------------------------------
-- Command Tooltips
-- --------------------------------------------------

function TooltipPopulation.populateActorCommandTooltip(tooltip, command, thisActor, otherActor)
    command:executeScriptFunction("populateTooltip", thisActor, otherActor, tooltip)
end

-- --------------------------------------------------
-- Notification Tooltips
-- --------------------------------------------------

local function getNotificationTimeoutString(notification)
    local timeRemaining = notification._timeout - client.time.worldTime
    local daysRemaining = TimeUtils.convertDuration(timeRemaining, "Seconds", "Days")

    if daysRemaining == 1 then
        return "$Format_TimeoutDay"
    else
        return "$Format_TimeoutDays", daysRemaining
    end
end

function TooltipPopulation.populateNotification(tooltip, notification)
    local worldEvent = notification._vargs[1]

    if worldEvent._title then
        tooltip:setTitle(worldEvent._title)
    end

    if worldEvent._text then
        tooltip:addData(worldEvent._text, worldEvent._textParams)
    end

    if notification._timeout then
        tooltip:addPolledData(notification, getNotificationTimeoutString)
    end
end

return TooltipPopulation

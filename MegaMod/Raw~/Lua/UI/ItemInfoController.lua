--$$ Character

local UIController = require("Libs.UIController")
local FloaterTooltip = require("UI.Floaters.FloaterTooltip")
local ConfigBuilder = require("Libs.ConfigBuilder")
local World = require("World.World")
local WorldLibs = require("Libs.WorldLibs")
local TimeUtils = require("Libs.TimeUtils")
local Alcohol = require("World.Alcohol")
local Behaviour = require("Mixins.Behaviour")
local ImprovementSlot = require("World.ImprovementSlot")
local TooltipPopulation = require("UI.TooltipPopulation")
local BuildingData = require("World.BuildingData")
local Super = UIController

local ItemRaritiesConfig = Config.DEFAULTS.ITEM.rarities

local ItemInfoController = {}

local TooltipWidth = 900
local MaxTooltipHeight = 2000
local TooltipPaddingTopAndBottom = 100

local weaponTypeToStringKey =
{
    Handgun = "$Weapon_Type_Handgun",
    Melee = "$Melee_Action_Verb",
    Rifle = "$Weapon_Type_Rifle",
    Sniper = "$Weapon_Type_Sniper_Rifle",
    Shotgun = "$Weapon_Type_Shotgun",
    SubGun = "$Weapon_Type_Submachine_Gun",
    MachineGun = "$Weapon_Type_Machine_Gun",
}

local weaponTypeToPluralStringKey =
{
    Handgun = "$WeaponPlural_Handgun",
    Melee = "$WeaponPlural_MeleeWeapon",
    Rifle = "$WeaponPlural_Rifle",
    Sniper = "$WeaponPlural_SniperRifle",
    Shotgun = "$WeaponPlural_Shotgun",
    SubGun = "$WeaponPlural_SubmachineGun",
    MachineGun = "$WeaponPlural_MachineGun",
}

local WeaponTypesToCommonIconLarge =
{
    Handgun = "Sprites/Icons/Trait_Large/WeaponProficiency/WeaponProficiency_HandGun_Common_256",
    Melee = "Sprites/Icons/Trait_Large/WeaponProficiency/WeaponProficiency_Melee_Common_256",
    Rifle = "Sprites/Icons/Trait_Large/WeaponProficiency/WeaponProficiency_Rifle_Common_256",
    Sniper = "Sprites/Icons/Trait_Large/WeaponProficiency/WeaponProficiency_Sniper_Common_256",
    Shotgun = "Sprites/Icons/Trait_Large/WeaponProficiency/WeaponProficiency_ShotGun_Common_256",
    SubGun = "Sprites/Icons/Trait_Large/WeaponProficiency/WeaponProficiency_SubMachineGun_Common_256",
    MachineGun = "Sprites/Icons/Trait_Large/WeaponProficiency/WeaponProficiency_MachineGun_Common_256",
}

local rarityStringKeys =
{
    Common = "$Rarity_Common", --$ Common
    Uncommon = "$Rarity_Uncommon", --$ Uncommon
    Rare = "$Rarity_Rare", --$ Rare
    Epic = "$Rarity_Epic", --$ Epic
    Legendary = "$Rarity_Legendary", --$ Legendary
    Unique = "$Rarity_Unique", --$ Unique
}

local weaponInfo =
{
    { title = "$Weapon_Info_ClipSize",          call = "getClipSizeText", },
    { title = "$Weapon_Info_FiringModes",       call = "getFiringModesText", },
    { title = "$Weapon_Info_SpecialAmmo",       call = "getSpecialAmmoText", validate = "hasSpecialAmmo"},
    { title = "$Weapon_Info_EffectiveRange",    call = "getEffectiveRangeText", },
    { isItemValue = true },
}

local meleeInfo =
{
    { isItemValue = true },
}

local thrownInfo =
{
    { title = "$Weapon_Info_EffectiveRange",    call = "getEffectiveRangeText", },
    { isItemValue = true },
}

local explosiveInfo =
{
    { title = "$Weapon_Info_ImpactRadius",      call = "getImpactRadiusText", },
    { isItemValue = true },
}

local ammoInfo =
{
    { isItemValue = true },
}

local armorInfo =
{
    { isItemValue = true },
}

local healInfo =
{
    { title = "$Heal_Info_Value",   call = "getHealAmountText", validate = "hasHealAmount" }, --$ Heal Amount
    { isItemValue = true },
}

local repairInfo =
{
    { isItemValue = true },
}

local bandageInfo =
{
    { isItemValue = true },
}

local basicItemInfo =
{
    { isItemValue = true },
}

local _curAttributeGroupIndex = 1
local levelIcons =
{
    "$Icon_1Star",
    "$Icon_2Star",
    "$Icon_3Star",
    "$Icon_4Star",
    "$Icon_5Star",
}
local difficultyIcons =
{
    [0] = "$Icon_0Skull",
    "$Icon_1Skull",
    "$Icon_2Skull",
    "$Icon_3Skull",
    "$Icon_4Skull",
    "$Icon_5Skull",
}
local difficultyColors =
{
    [0] = "success",
    "success",
    "possible",
    "possible",
    "failure",
    "failure",
}

-- ------------------------------------------------------
-- Attribute element management
-- ------------------------------------------------------

function ItemInfoController:clearAttributes()
    -- Setup Counters the first time that this is called
    if not self._curAttributeDataCount then
        self._curAttributeDataCount = 1
        self._attributeDataCount = 1
        self._curAttributeSimpleDataCount = 1
        self._attributeSimpleDataCount = 1
        self._curAttributeSimpleDataHeaderCount = 1
        self._attributeSimpleDataHeaderCount = 1
        self._curAttributeGroupCount = 1
        self._curAttributeGroupIndex = 0
    end

    for i = 1, self._curAttributeDataCount do
        self:setActive("attributeData" .. i, false)
    end
    self._curAttributeDataCount = 0

    for i = 1, self._curAttributeGroupIndex do
        local groupId = "attributesGroup" .. i
        self:setActive(groupId, false)
        self:setActiveInternal(groupId, "groupTitle", false)
    end
    self._curAttributeGroupIndex = 0

    for i = 1, self._curAttributeSimpleDataCount do
        self:setActive("attributeSimpleData" .. i, false)
    end
    self._curAttributeSimpleDataCount = 0

    for i = 1, self._curAttributeSimpleDataHeaderCount do
        self:setActive("attributeSimpleDataHeader" .. i, false)
    end
    self._curAttributeSimpleDataHeaderCount = 0
end

local function addAttributeComponent(self, prefix, counter, elementCounter)
    self[counter] = self[counter] + 1

    local id = prefix .. self[counter]

    if self[counter] > self[elementCounter] then
        self:clone(prefix .. 1, id, true)
        self[elementCounter] = self[elementCounter] + 1
    else
        self:setActive(id, true)
    end

    if prefix == "attributeData" then
        self:setParent(id, self._curAttributeParentId)
    end

    self:toFront(id)

    return id
end

function ItemInfoController:addAttributeData(name, ...)
    local id = addAttributeComponent(self, "attributeData", "_curAttributeDataCount", "_attributeDataCount")
    self:setTextInternal(id, "name", "$Format_Colon", name)
    self:setTextInternal(id, "value", ...)
    self:setColorInternal(id, "value", "white")
    return id
end

function ItemInfoController:addAttributeSimpleData(...)
    if self._curAttributeSimpleDataHeaderCount == 0 and self._curAttributeSimpleDataCount == 0 then
        self:setActive("bonusGroup", true)
    end
    local id = addAttributeComponent(self, "attributeSimpleData", "_curAttributeSimpleDataCount", "_attributeSimpleDataCount")
    self:setText(id, ...)
end

function ItemInfoController:addAttributeSimpleDataHeader(...)
    if self._curAttributeSimpleDataHeaderCount == 0 and self._curAttributeSimpleDataCount == 0 then
        self:setActive("bonusGroup", true)
    end
    local id = addAttributeComponent(self, "attributeSimpleDataHeader", "_curAttributeSimpleDataHeaderCount", "_attributeSimpleDataHeaderCount")
    self:setText(id, ...)
end

function ItemInfoController:setAttributeTitle(...)
    self:setActiveInternal(self._curAttributeParentId, "groupTitle", true)
    self:setTextInternal(self._curAttributeParentId, "groupTitle", ...)
end

function ItemInfoController:startNewAttributeGroup()
    self._curAttributeGroupIndex = self._curAttributeGroupIndex + 1
    local groupId = "attributesGroup" .. self._curAttributeGroupIndex
    if self._curAttributeGroupIndex > self._curAttributeGroupCount then
        self:clone("attributeGroupTemplate", groupId, true)
        self:setParent(groupId, "itemInfo")
        local siblingCount = self:getChildCount("itemInfo")
        -- There should only be the bonus group, the description, and padding after this
        local siblingIndex = (siblingCount - 4)
        self:setOrder(groupId, siblingIndex)
        self._curAttributeGroupCount = self._curAttributeGroupCount + 1
    else
        self:setActive(groupId, true)
    end
    self._curAttributeParentId = groupId
end

function ItemInfoController:setIcon(image, color, scale)
    color = color or "white"
    scale = scale or 1
    self:setActive("itemIcon", true)
    self:setImage("itemIconImage", image)
    self:setColor("itemIconImage", color)
    self:setScale("itemIconImage", scale)
end

function ItemInfoController:setTitle(...)
    self:setActive("infoTitle", true)
    self:setText("infoTitle", ...)
end

function ItemInfoController:setSubtitle(...)
    self:setActive("infoType", true)
    self:setText("infoType", ...)
end

function ItemInfoController:setTitleIcon(image, color)
    color = color or "white"
    self:setActive("titleIcon", true)
    self:setImage("titleIcon", image)
    self:setColor("titleIcon", color)
    self:setPadding("titleGroup", 120, 0, 0, 0)
end

-- ------------------------------------------------------
-- Building & Building Upgrades
-- ------------------------------------------------------

function ItemInfoController:populateRacketPurchaseInfo(building, option)
    TooltipPopulation.populateRacketPurchaseTooltip(self, building, option)
end

function ItemInfoController:populateGenericBuildingInfo(building)
    self:clearInfo()
    local racketId = building.buildingData.id
    local config = ConfigBuilder.fromId( racketId )
    self:setTitle(building.knownName)
    self:setSubtitle("$Format_BulletSeparatedStrings", building:getBuildingTypeName(), building:sizeName())
    self:setTitleIcon(config.icon, "gold")
    self:setDescriptionText(building:getBuildingTypeTooltipDescription())
end

function ItemInfoController:populateUpgradeInfoBody(building)
    local upgrades = building.upgrades
    local upgradeLevel = upgrades.upgradeLevel
    self:startNewAttributeGroup()
    local currentLevelModifiers = upgrades:getTotalModifiers()
    local nextLevelModifiers = upgrades:getTotalModifiers(upgradeLevel + 1)
    local income = building.data.income
    if income and income > 0 then -- Earns income
        local percentageChange = (nextLevelModifiers.earnings or 0) - (currentLevelModifiers.earnings or 0)
        local nextIncome = income * (1 + percentageChange)
        self:addAttributeData("$Building_Income", "$Format_UpgradeValueToValue", "$Format_Price", income, "$Format_Price", nextIncome)
    end
    if building.data.racketCustomerCapacity and (building.data.racketCustomerCapacity > 0) then
        self:addAttributeData("$Precinct_Customers", "$Format_FractionWholeNumber", building.data.customerCount, building.data.racketCustomerCapacity)
    end
    if building.data.upkeep > 0 then
        local upkeepChange = (nextLevelModifiers.upkeep or 0) - (currentLevelModifiers.upkeep or 0)
        local upkeep = building.data.upkeep
        local nextUpkeep = upkeep + upkeepChange
        self:addAttributeData("$Building_Upkeep", "$Format_UpgradeValueToValue", "$Format_Price", upkeep, "$Format_Price", nextUpkeep)
    end

    local titleConfig = Config.UPGRADE_VISUALS.TITLES
    local formatConfig = Config.UPGRADE_VISUALS.VALUE_FORMAT
    local buildingData = building.data._privateData
    local addedStorage = false
    for k, v in next, buildingData do
        local name = titleConfig[k]
        if name and v ~= 0 then
            if k ~= "suspicionEffect"
                and k ~= "earnings"
                and k ~= "income"
                and k ~= "upkeep"
                and k ~= "saleValue"
            then
                local curValue = currentLevelModifiers[k]
                local nextValue = nextLevelModifiers[k]
                if curValue and nextValue then
                    local difference = nextValue - curValue
                    self:addAttributeData(name, "$Format_UpgradeValueToValue", formatConfig[k], v, formatConfig[k], v + difference)
                    if k == "storageAmount" then
                        addedStorage = true
                        self:addAttributeData("$Building_Stored", "$Format_Barrels", "$Format_FractionWholeNumber", building.storage.stored, building.storage.amount)
                    end
                else
                    self:addAttributeData(name, formatConfig[k], v)
                end
            end
        end
    end
    for k, v in next, nextLevelModifiers do
        if not buildingData[k]
            and k ~= "suspicionEffect"
            and k ~= "earnings"
            and k ~= "income"
            and k ~= "upkeep"
            and k ~= "saleValue"
        then
            if k == "maxQuality" then
                local oldValue = currentLevelModifiers[k]
                local oldName = Alcohol.getName(oldValue)
                local newName = Alcohol.getName(v)
                local oldModifier = Alcohol.getEarningsModifier(oldValue)
                local newModifier = Alcohol.getEarningsModifier(v)
                local oldColor = ((oldModifier < 0) and "stateNegative") or ((oldModifier > 0) and "statePositive") or "stateNeutral"
                local newColor = ((newModifier < 0) and "stateNegative") or ((newModifier > 0) and "statePositive") or "stateNeutral"
                self:addAttributeData(titleConfig[k], "$Format_UpgradeValueToValue", oldName, newName)
            else
                local oldValue = currentLevelModifiers[k] or 0
                self:addAttributeData(titleConfig[k], "$Format_UpgradeValueToValue", formatConfig[k], oldValue, formatConfig[k], v)
            end
        end
    end
    if building.storage and not addedStorage then
        self:addAttributeData("$Building_Stored", "$Format_Barrels", "$Format_FractionWholeNumber", building.storage.stored, building.storage.amount)
    end
end

function ItemInfoController:populateUpgradeInfo(building)
    self:populateGenericBuildingInfo(building)
    local upgrades = building.upgrades
    local upgradeLevel = upgrades.upgradeLevel
    self:startNewAttributeGroup()
    self:setAttributeTitle("$UpgradeToLevel", levelIcons[upgradeLevel], levelIcons[upgradeLevel + 1]) --$ Upgrade: {0} $Icon_RightArrow {1}
    local upgradeCost = upgrades:getUpgradeCost()
    local canAfford = World.playerFaction.cash:canAfford(upgradeCost)
    local costColor = canAfford and "statePositive" or "stateNegative"
    self:addAttributeData("$RPC_Review_Cost", "$Format_Color", costColor, "$Format_Price", upgradeCost)
    local upgradeTime = upgrades:getUpgradeTime()
    local timeString
    if upgradeTime == 1 then
        timeString = "$Shop_Day"
    else
        timeString = "$Shop_Days"
    end
    self:addAttributeData("$Missions_Time", timeString, upgradeTime)
    self:populateUpgradeInfoBody(building)
    self:setupBackplates(true)
end

function ItemInfoController:populateUpgradeInProgressInfo(building)
    self:populateGenericBuildingInfo(building)
    local upgrades = building.upgrades
    local upgradeLevel = upgrades.upgradeLevel
    self:startNewAttributeGroup()
    self:setAttributeTitle("$UpgradingToLevel", levelIcons[upgradeLevel], levelIcons[upgradeLevel + 1]) --$ Upgrading: {0} $Icon_RightArrow {1}
    local upgradeTime = upgrades:getUpgradeTimeRemaining()
    local daysRemaining = TimeUtils.convertDuration(upgradeTime, "Seconds", "Days")
    local timeString
    if daysRemaining == 1 then
        timeString = "$Shop_Day"
    else
        timeString = "$Shop_Days"
    end
    self:addAttributeData("$TimeRemaining", timeString, daysRemaining) --$ Time Remaining
    self:populateUpgradeInfoBody(building)
    self:setupBackplates(true)
end

function ItemInfoController:populateRacketBuildingInProgressInfo(building)
    self:clearInfo()
    local racketId = building.buildTargetId
    local config = ConfigBuilder.fromId( racketId )
    self:setTitle(building.knownName)
    self:setSubtitle("$Format_BulletSeparatedStrings", config.name, building:sizeName())
    self:setTitleIcon(config.icon, "gold")
    self:setDescriptionText(config.tooltipDescription)

    self:startNewAttributeGroup()
    self:setAttributeTitle("$Equipping")
    local buildTime = building:getBuildingTimeRemaining()
    local daysRemaining = TimeUtils.convertDuration(buildTime, "Seconds", "Days")
    local timeString
    if daysRemaining == 1 then
        timeString = "$Shop_Day"
    else
        timeString = "$Shop_Days"
    end
    self:addAttributeData("$TimeRemaining", timeString, daysRemaining)
    self:setupBackplates(true)
end

function ItemInfoController:populateRacketDemolishingInProgressInfo(building)
    self:clearInfo()
    local racketId = building.buildingData.id
    local config = ConfigBuilder.fromId( racketId )
    self:setTitle(building.knownName)
    self:setSubtitle("$Format_BulletSeparatedStrings", config.name, building:sizeName())
    self:setTitleIcon("Sprites/Icons/Buildings/Icon_Raze", "gold")
    self:setDescriptionText("$Demolish_Tooltip_Description")

    self:startNewAttributeGroup()
    self:setAttributeTitle("$Demolishing")
    local demolishTime = building:getDemolishTimeRemaining()
    local daysRemaining = TimeUtils.convertDuration(demolishTime, "Seconds", "Days")
    local timeString
    if daysRemaining == 1 then
        timeString = "$Shop_Day"
    else
        timeString = "$Shop_Days"
    end
    self:addAttributeData("$TimeRemaining", timeString, daysRemaining)
    self:setupBackplates(true)
end

function ItemInfoController:populateBuildingInfo(building)
    self:populateGenericBuildingInfo(building)
    local upgrades = building.upgrades

    if building.damaged then
        local daysRemaining = building.damagedInterface:getDaysRemaining()
        self:startNewAttributeGroup()
        self:setAttributeTitle("$RansackedBuilding")
        local timeString
        if daysRemaining == 1 then
            timeString = "$Shop_Day"
        else
            timeString = "$Shop_Days"
        end
        self:addAttributeData("$TimeRemaining", timeString, daysRemaining)
    end

    if building.open == false then
        local addedGroup = false
        local closedModifiers = building.buildingData._closedModifiers
        for i = 1, #closedModifiers do
            if closedModifiers[i].name ~= "$RansackedBuilding" then
                if not addedGroup then
                    addedGroup = true
                    self:startNewAttributeGroup()
                    self:setAttributeTitle("$Closed")
                end
                local daysRemaining = closedModifiers[i].timeout
                if daysRemaining then
                    local timeString
                    if daysRemaining == 1 then
                        timeString = "$Shop_Day"
                    else
                        timeString = "$Shop_Days"
                    end
                    self:addAttributeData(closedModifiers[i].name, timeString, daysRemaining)
                else
                    self:addAttributeData(closedModifiers[i].name, "")
                end
            end
        end
    end

    self:startNewAttributeGroup()
    self:setAttributeTitle("$Upgrades")
    local upgradeTextParams = {}
    for index = 1, #upgrades.upgradeIds do
        local id = upgrades.upgradeIds[index]
        local upgrade = upgrades.upgradeInterfaces[id]
        if upgrade then
            upgradeTextParams[#upgradeTextParams + 1] = "$Format_5ItemsNoSpace"
            local upgradeLevel = upgrade.level
            local isUpgrading = upgrade:isUpgrading()
            for i = 1, upgradeLevel do
                upgradeTextParams[#upgradeTextParams + 1] = "$Icon_FullStar"
            end
            if isUpgrading then
                upgradeTextParams[#upgradeTextParams + 1] = "$Icon_SemiFullStar"
            end
            for i = upgradeLevel + (isUpgrading and 1 or 0), 5 do
                upgradeTextParams[#upgradeTextParams + 1] = "$Icon_EmptyStar"
            end
            if isUpgrading then
                self:addAttributeData({ "$Format_TextAndTextInBrackets", upgrade:getName(), "$Format_Color", "dullWhite", "$Upgrading" },
                        unpack(upgradeTextParams))
                local daysRemaining = upgrade:getUpgradeTimeRemaining()
                local timeString
                if math.round(daysRemaining) == 1 then
                    timeString = "$Shop_Day"
                else
                    timeString = "$Shop_Days"
                end
                self:addAttributeData({"$Format_BulletEntry", "$TimeRemaining" }, timeString, daysRemaining)
            else
                self:addAttributeData(upgrade:getName(), unpack(upgradeTextParams))
            end
            clearTable(upgradeTextParams)
        end
    end

    self:startNewAttributeGroup()
    local income = building.data.income
    -- MEGAMOD: Neighbourhood Overview income breakdown - gross/upkeep/net income plus
    -- per-customer spend detail (replaces vanilla's single income + upkeep lines).
    local modifiers = 0
    local alcoholIncomeEffect = 0
    if building:earnsIncome() then -- Earns income
        self:addAttributeData("$Building_Income_Gross", "$Format_Currency_Unsigned", income) --$ Gross Income {0}
        self:addAttributeData("$Building_Upkeep", "$Format_Currency_Unsigned", building.data.upkeep)
        local netIncome = income - building.data.upkeep
        self:addAttributeData("$Building_Income_Net", "$Format_Currency_Unsigned", netIncome) --$ Net Income {0}
        if building.data.customerCount > 0 then
            self:startNewAttributeGroup()
            local precinct = building:getPrecinct()
            if precinct then
                modifiers = building.data.globalEarnings + (building.data.earnings or 0)
                local minAlcoholIncomePercent = building.buildingData.getConfigValue(building.buildingData._id, "minAlcoholIncomePercent")
                local maxAlcoholIncomePercent = building.buildingData.getConfigValue(building.buildingData._id, "maxAlcoholIncomePercent")
                local consumptionRatio = precinct:getConsumptionRatio()
                alcoholIncomeEffect = (consumptionRatio * (maxAlcoholIncomePercent - minAlcoholIncomePercent)) + minAlcoholIncomePercent
            end
            local averageSpend = building._baseAverageSpend * modifiers * alcoholIncomeEffect --income / building.data.customerCount
            self:addAttributeData("$Average_Spend", "$Format_Currency_Unsigned", averageSpend) --$ Average Income per Customer {0}
            self:addAttributeData("$Base_Spend", "$Format_Currency_Unsigned", building._baseAverageSpend) --$ Base Average Spend {0}
            self:addAttributeData("$Modifiers", "$Format_Number3DecimalPlaces", modifiers) --$ Modifers {0}
            self:addAttributeData("$Alcohol_Modifier", "$Format_Numeric1DecimalPlace", alcoholIncomeEffect) --$ Alcohol Modifer {0}
        end
    elseif building.data.upkeep > 0 then
        self:addAttributeData("$Building_Upkeep", "$Format_Currency_Unsigned", building.data.upkeep)
    end

    self:startNewAttributeGroup()
    if building.data.racketCustomerCapacity and (building.data.racketCustomerCapacity > 0) then
        self:addAttributeData("$Precinct_Customers", "$Format_FractionWholeNumber", building.data.customerCount, building.data.racketCustomerCapacity)
    end
    -- MEGAMOD: end income breakdown

    local titleConfig = Config.UPGRADE_VISUALS.TITLES
    local formatConfig = Config.UPGRADE_VISUALS.VALUE_FORMAT

    local buildingData = building.data._privateData

    for k, v in next, buildingData do
        local name = titleConfig[k]
        if name and v ~= 0 then
            if k ~= "suspicionEffect"
                and k ~= "earnings"
                and k ~= "income"
                and k ~= "upkeep"
                and k ~= "saleValue"
                and k ~= "storageAmount"
                and k ~= "racketCustomerCapacity" -- MEGAMOD: capacity already shown in the Customers line above
            then
                self:addAttributeData(name, formatConfig[k], v)
            end
        end
    end
    local currentLevelModifiers = upgrades:getTotalModifiers()
    for k, v in next, currentLevelModifiers do
        if not buildingData[k] then
            if k ~= "suspicionEffect"
                and k ~= "earnings"
                and k ~= "saleValue"
                and k ~= "storageAmount"
            then
                if k == "maxQuality" then
                    v = building.producer.alcoholType -- Use what is actually being produced.
                    self:addAttributeData(titleConfig[k], Alcohol.getName(v))
                else
                    self:addAttributeData(titleConfig[k], formatConfig[k], v)
                end
            end
        end
    end
    if building.storage then
        self:addAttributeData("$Building_Stored", "$Format_Barrels", "$Format_FractionWholeNumber", building.storage.stored, building.storage.amount)
    end
    self:setupBackplates(true)
end

local _racketOptionNames = {}
function ItemInfoController:populateAvailableRacketInfo(building)
    self:clearInfo()
    self:setTitle(building.knownName)
    self:setSubtitle("$Format_BulletSeparatedStrings", "$Building_Unowned_Name", building:sizeName())
    self:setTitleIcon("Sprites/Icons/Buildings/Icon_Racket_Sale_W", "gold")
    local buildingConfig = ConfigBuilder.fromId(building.configId)

    local racketOptions = building:getFactionRacketOptions(World.playerFaction)
    
    if racketOptions then
        local faction = World.playerFaction
        self:startNewAttributeGroup()
        self:setAttributeTitle("$EquipBuildingAs")
        for i = 1, #racketOptions do
            local option = racketOptions[i]
            local isValid = BuildingData.executeScriptBlock(option, "isValid", building, World.playerFaction)
            local name = _racketOptionNames[option]
            if not name then
                local racketConfig = ConfigBuilder.fromId(option)
                if not racketConfig then
                    logInfo("couldn't find config for", option)
                    printR(racketOptions, 1)
                end
                name = racketConfig.name
                _racketOptionNames[option] = name
            end
            if not isValid then
                name = {"$Format_Color", "stateInvalid", name}
            end

            local racketCost = WorldLibs.getRacketCost(building, option, faction)
            local costColor
            if faction.cash:canAfford( racketCost ) then
                costColor = "statePositive"
            else
                costColor = "stateNegative"
            end
            self:addAttributeData(name, "$Format_Color", costColor, "$Format_Price", racketCost)
        end
    end
    self:setDescriptionText("$EmptyRacket_TooltipDescription")
    self:setupBackplates(true)
end

function ItemInfoController:populateDerelictRacketInfo(building)
    self:populateGenericBuildingInfo(building)
    self:startNewAttributeGroup()
    local difficulty = math.round(building:getDifficultyRating())
    self:addAttributeData("$Settings_Difficulty", difficultyIcons[difficulty], difficultyColors[difficulty])
    self:setupBackplates(true)
end

function ItemInfoController:populateImprovementSlot(improvementSlot)
    self:clearInfo()
    self:setTitle(improvementSlot:getName())
    self:setSubtitle("$ImprovementSlot")
    self:setTitleIcon(improvementSlot:getIcon(), "gold")
    --self:startNewAttributeGroup()
    local effects = ImprovementSlot.getSlotEffectDescriptions(improvementSlot.configId, improvementSlot.precinct)
    for i = 1, #effects do
        self:addAttributeSimpleData("$Format_BulletEntry", safeUnpack(effects[i]))
    end
    self:setDescriptionText(improvementSlot:getDescription())
    self:setupBackplates(true)
end

local improvementIdsCached = {}
local improvementConfigs = {}
function ItemInfoController:populateEmptyImprovementSlotForPrecinct(precinct, allowed, reason)
    self:clearInfo()
    if not allowed then
        self:setTitle("$Format_Color", "stateInvalid", "$ImprovementSlot")
        self:setSubtitle("$Locked")
        self:setTitleIcon("Sprites/SelectFaction/Icon_Locked", "stateInvalid")
    else
        self:setTitle("$ImprovementSlot")
        self:setSubtitle("$AvailableImprovementSlot")
        self:setTitleIcon("Sprites/Icons/Buildings/Icon_Racket_Sale_W", "gold")
    end
    if not allowed then
        self:addAttributeSimpleData("$Format_Color", "stateInvalid", safeUnpack(reason))
    elseif precinct.faction.isPlayerFaction then
        clearTable(improvementConfigs)
        improvementConfigs = precinct:getVisibleImprovementConfigs(improvementConfigs)
        self:startNewAttributeGroup()
        self:setAttributeTitle("$PurchaseImprovement")
        local faction = World.playerFaction
        for key, config in next, improvementConfigs do
            local configId = improvementIdsCached[key]
            if not configId then
                configId = "IMPROVEMENT_SLOTS." .. key
                improvementIdsCached[key] = configId
            end
            local valid = ImprovementSlot.isValidConfig(configId, precinct)
            local cost = ImprovementSlot.getCost(configId, precinct)
            local costColor
            if not valid then
                costColor = "defaultButtonTextDisabled"
            elseif faction.cash:canAfford( cost ) then
                costColor = "statePositive"
            else
                costColor = "stateNegative"
            end
            if valid then
                self:addAttributeData(config.name, "$Format_Color", costColor, "$Format_Price", cost)
            else
                self:addAttributeData({"$Format_Color", "defaultButtonTextDisabled", config.name}, "$Format_Color", costColor, "$Format_Price", cost)
            end
        end
    end
    self:setDescriptionText("$TOOLTIPS_EmptyImprovementSlotDescription_text")
    self:setupBackplates(true)
end

function ItemInfoController:populateImprovementConfigForPurchase(precinct, configId, config)
    local valid = ImprovementSlot.isValidConfig(configId, precinct, true)
    self:clearInfo()
    if valid then
        self:setTitle(config.name)
        self:setSubtitle("$ImprovementSlot")
    else
        -- "$Invalid" --$ Invalid
        self:setTitle("$Format_Color", "defaultButtonTextDisabled", config.name)
        self:setSubtitle("$Format_TwoItems", "$ImprovementSlot", "$Format_Color", "stateInvalid", "$Format_InBrackets", "$Invalid")
    end
    self:setTitleIcon(config.icon, valid and "gold" or "defaultButtonTextDisabled")
    self:startNewAttributeGroup()
    local faction = precinct.faction
    local cost = ImprovementSlot.getCost(configId, precinct)
    local costColor
    if not valid then
        costColor = "defaultButtonTextDisabled"
    elseif faction.cash:canAfford( cost ) then
        costColor = "statePositive"
    else
        costColor = "stateNegative"
    end
    self:addAttributeData("$RPC_Review_Cost", "$Format_Color", costColor, "$Format_Price", cost)
    if not valid then
        for desc in ImprovementSlot.slotInvalidDescriptionIterator(configId, precinct) do
            self:addAttributeSimpleData("$Format_Color", "defaultButtonTextDisabled", "$Format_BulletEntry", desc)
        end
    end
    local effects = ImprovementSlot.getSlotEffectDescriptions(configId, precinct)
    for i = 1, #effects do
        self:addAttributeSimpleData("$Format_BulletEntry", safeUnpack(effects[i]))
    end

    self:setDescriptionText(config.description)
    self:setupBackplates(true)
end

-- ------------------------------------------------------
-- Population
-- ------------------------------------------------------

function ItemInfoController:populateGenericInfo(item, interface, info, itemPriceModifierId, inShopSellMode)
    local rarity = item:getRarity()

    local startedAttributeGroup = false

    local infoLen = info and #info or 0
    if rarity then
        if not startedAttributeGroup then
            self:startNewAttributeGroup()
            startedAttributeGroup = true
        end
        local id = self:addAttributeData("$Rarity_Title", rarityStringKeys[rarity])
        self:setColorInternal(id, "value", rarity)
        if rarity ~= "Common" then -- Common Rarity color too dark, just use gold
            self:setColor("infoTitle", rarity)
        end
    end

    for i = 1, infoLen do
        local lineItem = info[i]
        if (not lineItem.validate) or interface[lineItem.validate](interface) then
            if not startedAttributeGroup then
                self:startNewAttributeGroup()
                startedAttributeGroup = true
            end
            
            if lineItem.isItemValue then
                local title = inShopSellMode and "$Weapon_Buyback_Value" or "$Weapon_Info_Value"
                local value = item:getBuyPrice(itemPriceModifierId)
                self:addAttributeData(title, "$Format_Price", value)
            else
                self:addAttributeData(lineItem.title, interface[lineItem.call](interface))
            end
        end
    end

    local behaviourManager = item.behaviours
    for handle, _ in next, behaviourManager._activeBehaviours do
        for text in behaviourManager:getCurrentModifiers(handle) do
            self:addAttributeSimpleData(text)
        end
    end
    self:setupBackplates()
end

function ItemInfoController:populateDamageItem(weapon, character)
    self:setActive("infoIcons", true)
    self:setImage("iconInfoIcon_1", "Sprites/Icons/Combat/Icon_Damage")
    self:setImage("iconInfoIcon_2", "Sprites/Icons/Combat/Icon_CritDamage")
    self:setImage("iconInfoIcon_3", "Sprites/Icons/Combat/Icon_CritChance")
    self:setText("iconInfoTitle_1", "$Weapon_Damage")
    self:setText("iconInfoTitle_2", "$Weapon_CritDamage")

    -- Show the damage values for this weapon for when it is equipped by a member of the player's faction
    local playerFaction = World.playerFaction
    local minDamage = weapon:get("minDamage")
    local maxDamage = weapon:get("maxDamage")
    minDamage = playerFaction:modifyDamageWithDifficulty(minDamage)
    maxDamage = playerFaction:modifyDamageWithDifficulty(maxDamage)

    if minDamage == maxDamage then
        self:setText("iconInfoText_1", "$Format_Number", minDamage)
    else    
        self:setText("iconInfoText_1", "$Format_PairDash", minDamage, maxDamage)
    end
    
    if weapon.damage.minCrit == weapon.damage.maxCrit then
        self:setText("iconInfoText_2", "$Format_Number", weapon.damage.minCrit)
    else
        self:setText("iconInfoText_2", "$Format_PairDash", weapon.damage.minCrit, weapon.damage.maxCrit)
    end

    local baseCritChance = weapon:get("baseCritChance")
    if baseCritChance then
        self:setFlexibleWidth("iconInfoPaddingLeft", 0)
        self:setFlexibleWidth("iconInfoPaddingRight", 0)
        self:setText("iconInfoTitle_3", "$Weapon_CritChance")
        self:setText("iconInfoText_3", "$Format_Percent", baseCritChance)
        self:setActive("iconInfoParent_3", true)
    else
        self:setFlexibleWidth("iconInfoPaddingLeft", 5000)
        self:setFlexibleWidth("iconInfoPaddingRight", 5000)
        self:setActive("iconInfoParent_3", false)
    end

    if character then
        local weaponType = weapon:getType()
        local weaponTypeStringKey = weaponTypeToStringKey[weaponType]
        local itemRarityValue = Config.DEFAULTS.ITEM.rarityValues[weapon:getRarity()]
        local usableRarityValue = World.weaponProficiencyManager:getUsableWeaponRarityValueForCharacter(character, weaponType)

        if not character.profession:canUseWeaponType(weaponType) then
            self:setActive("cannotUseDescription", true)
            local weaponTypePluralStringKey = weaponTypeToPluralStringKey[weaponType]
            self:setText("cannotUseDescription", "$Character_Sheet_CannotEquip_WrongProfession", character.profession:getMain().stringsKeyPlural, weaponTypePluralStringKey)
        -- elseif (not World.goldenWeaponsHaveProficiency) and World.isGoldenWeapon(weapon._id) then
        --     -- can use, so do nothing
        elseif itemRarityValue then
            if itemRarityValue > usableRarityValue and weapon.originalOwner ~= character then
                self:setActive("cannotUseDescription", true)
                self:setText("cannotUseDescription", "$Character_Sheet_CannotEquip_RarityTooHigh", weaponTypeStringKey, itemRarityValue)
            end
        end
    end

    self:setDescriptionText( weapon:get("desc"))
end

function ItemInfoController:populateWeaponInfo(weapon, character, itemPriceModifierId, inShopSellMode)
    self:populateDamageItem(weapon, character)
    self:populateGenericInfo(weapon, weapon.gun, weaponInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateMeleeWeaponInfo(weapon, character, itemPriceModifierId, inShopSellMode)
    self:populateDamageItem(weapon, character)
    self:populateGenericInfo(weapon, weapon.melee, meleeInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateExplosiveInfo(explosive, itemPriceModifierId, inShopSellMode)
    self:populateDamageItem(explosive)
    self:populateGenericInfo(explosive, explosive.grenade, explosiveInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateThrownInfo(weapon, itemPriceModifierId, inShopSellMode)
    self:populateDamageItem(weapon)
    self:populateGenericInfo(weapon, weapon.missile, thrownInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateAmmoInfo(ammo, itemPriceModifierId, inShopSellMode)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)
    self:setImage("itemIconImage", ammo:get("inventoryIcon"))
    self:setDescriptionText( ammo:get("desc"))

    self:populateGenericInfo(ammo, ammo.ammo, ammoInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateArmorInfo(armor, itemPriceModifierId, inShopSellMode)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)
    self:setImage("itemIconImage", armor:get("inventoryIcon"))
    self:setDescriptionText( armor:get("desc"))

    self:setText("armorName", "$Format_Colon", "$Character_Sheet_Armor")
    local armorValue = armor.armor.current
    self:setAnchorMax("armorPointBar", armorValue/100, 1)

    self:populateGenericInfo(armor, armor.armor, armorInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateHealInfo(medKit, itemPriceModifierId, inShopSellMode)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)
    self:setImage("itemIconImage", medKit:get("inventoryIcon"))

    local desc = medKit:get("desc")
    local actionPanelDesc = medKit:get("actionPanelDesc")
    local actionDescParams = medKit:get("actionDescParams")
    self:setDescriptionText( "$Format_TwoNewLines", desc, actionPanelDesc, actionDescParams)

    self:populateGenericInfo(medKit, medKit.heal, healInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateBandageInfo(bandage, itemPriceModifierId, inShopSellMode)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)
    self:setImage("itemIconImage", bandage:get("inventoryIcon"))
    self:setDescriptionText( bandage:get("desc"))
    self:populateGenericInfo(bandage, bandage.bandage, bandageInfo, itemPriceModifierId, inShopSellMode)
end

local modifierNames =
{
    ["critChance"] = "$Weapon_CritDamage",
    ["armorDamage"] = "$Weapon_ArmorDamage",
    ["marksmanship"] = "$Skill_Marksmanship",
    ["damage"] = "$Weapon_Damage",
}

local modifierFormat =
{
    ["critChance"] = "$Format_PlusPercent",
    ["armorDamage"] = "$Format_PlusNumber",
    ["marksmanship"] = "$Format_PlusNumber",
    ["damage"] = "$Format_PlusNumber",
}

function ItemInfoController:populateAbilityInfo(item)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)
    self:setImage("itemIconImage", item:get("largeIcon"))

    local desc = item:get("desc")
    local actionPanelDesc = item:get("actionPanelDesc")
    local actionDescParams = item:get("actionDescParams")

    if desc then
        self:setDescriptionText( "$Format_TwoNewLines", desc, actionPanelDesc, actionDescParams)
    else
        self:setDescriptionText( actionPanelDesc, actionDescParams)
    end

    self:populateGenericInfo(item, item.ability, nil)
end

function ItemInfoController:populateBasicInfo(item, itemPriceModifierId, inShopSellMode)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)
    self:setImage("itemIconImage", item:get("inventoryIcon"))
    self:setDescriptionText( item:get("desc"))
    self:populateGenericInfo(item, item.view, basicItemInfo, itemPriceModifierId, inShopSellMode)
end

function ItemInfoController:populateStateInfo(character, handle)
    self:clearInfo()

    local interface = character.behaviours:getInterface(handle)

    self:setActive("itemInfo", true)
    self:setActive("itemIcon", true)
    self:setScale("itemIconImage", 0.75)
    self:setImage("ItemIconImage", interface:getLargeIcon())

    self:setTitle(interface:getName())
    self:setDescriptionText(interface:getDescription())

    if interface.isCompoundState or interface._name == "CompoundState" then -- Shane remove: Supporting older saves
        local handles = interface.handles
        for i = #handles, 1, -1 do
            local subHandle = handles[i]
            local subInterface = character.behaviours:getInterface(subHandle)
            for text in character.behaviours:getCurrentModifiers(subHandle) do
                self:addAttributeSimpleData(text)
            end
        end
    else
        local infoIndex = 1
        for text in character.behaviours:getCurrentModifiers(handle) do
            infoIndex = infoIndex + 1
            self:addAttributeSimpleData(text)
        end
    end
    self:setupBackplates()
end

function ItemInfoController:populateFromStateId(stateId, character)
    self:clearInfo()

    local stateConfig = ConfigBuilder.fromId(stateId)

    self:setTitle(stateConfig.modifierName)
    self:setActive("itemInfo", true)
    self:setActive("itemIcon", true)
    local icon = stateConfig.iconLarge
    if icon then
        self:setImage("itemIconImage", icon)
    else
        logError("No large icon for " .. stateId .. ". Defaulting to small icon. Make a ticket and give to Shane")
        self:setImage("itemIconImage", stateConfig.icon)
    end
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 0.75)

    if stateConfig.desc then
        self:setDescriptionText(stateConfig.desc)
    end

    local modifierId = stateConfig.modifierId
    if modifierId then
        local infoIndex = 1
        local modifierDescriptions = World.getModifierDescriptions(modifierId, character)
        if modifierDescriptions then
            for _, text in next, modifierDescriptions do
                infoIndex = infoIndex + 1
                self:addAttributeSimpleData(text)
            end
        end
    end
    self:setupBackplates()
end

function ItemInfoController:populateCommonWeaponProficiencyTrait(character, weaponType)
    self:clearInfo()

    self:setActive("itemInfo", true)
    self:setActive("itemIcon", true)

    local icon = WeaponTypesToCommonIconLarge[weaponType]
    self:setImage("itemIconImage", icon)
    self:setScale("itemIconImage", 0.75)

    local weaponTypeStringKey = weaponTypeToStringKey[weaponType]
    self:setTitle("$Character_Sheet_Proficiency", weaponTypeStringKey)
    self:setSubtitle("$Talents_TierNum", 1)

    local rarity = ItemRaritiesConfig[1]

    -- local weaponRarityUnlockStringKey = rarityStringKeys[rarity]
    -- local weaponTypePluralStringKey = weaponTypeToPluralStringKey[weaponType]
    -- self:addAttributeSimpleData("$WeaponProficiency_WeaponTierUnlock", "$Format_Color", rarity, weaponRarityUnlockStringKey, weaponTypePluralStringKey) --$ Enables the use of {0} {1} == {0} parameter will be a weapon rarity (Uncommon, Rare, Epic etc.); {1} will be a plural of a weapon type (Shotguns, Rifles, Melee Weapons)
    self:setupBackplates()
end

function ItemInfoController:populateWeaponProficiencyTrait(state, character, weaponType, tier)
    self:clearInfo()

    local stateConfigId = Behaviour.getBehaviourConfig(state)
    local stateConfig = ConfigBuilder.fromId(stateConfigId)

    local rarity = ItemRaritiesConfig[tier]
    if rarity then
        if rarity ~= "Common" then
            self:setColor("infoTitle", rarity)
        end
    end

    local weaponTypeStringKey = weaponTypeToStringKey[weaponType]

    self:setTitle("$Character_Sheet_Proficiency", weaponTypeStringKey)
    self:setSubtitle("$Talents_TierNum", tier)

    self:setActive("itemInfo", true)
    self:setActive("itemIcon", true)
    local icon = stateConfig.iconLarge
    if icon then
        self:setImage("itemIconImage", icon)
    else
        logError("No large icon for " .. state .. ". Defaulting to small icon. Make a ticket and give to Shane")
        self:setImage("itemIconImage", stateConfig.icon)
    end
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 0.75)

    self:addAttributeSimpleDataHeader(stateConfig.modifierName)

    local infoIndex = 1
    local modifierDescriptions = stateConfig.ModifierDescription
    if modifierDescriptions then
        for key, description in next, modifierDescriptions do
            if type(key) == "string" then
                infoIndex = infoIndex + 1
                self:addAttributeSimpleData("$Format_BulletEntry", description)
            end
        end

        for _, description in ipairs(modifierDescriptions) do
            infoIndex = infoIndex + 1
            self:addAttributeSimpleData("$Format_BulletEntry", description)
        end
    end

    -- if rarity then
    --     local weaponRarityUnlockStringKey = rarityStringKeys[rarity]
    --     local weaponTypePluralStringKey = weaponTypeToPluralStringKey[weaponType]
    --     self:addAttributeSimpleData("$Format_BulletEntry", "$WeaponProficiency_WeaponTierUnlock", "$Format_Color", rarity, weaponRarityUnlockStringKey, weaponTypePluralStringKey)
    -- end

    local weaponTypePluralStringKey = weaponTypeToPluralStringKey[weaponType]

    local numRequiredKills = World.weaponProficiencyManager:getNumKillsUntilTraitUnlock(character, state)
    if numRequiredKills == 1 then
        self:setDescriptionText("$WeaponProficiency_NumRequiredKills_Single", weaponTypePluralStringKey) --$ Get 1 more kill with {0} to unlock
    elseif numRequiredKills ~= nil then
        self:setDescriptionText("$WeaponProficiency_NumRequiredKills", numRequiredKills, weaponTypePluralStringKey) --$ Get {0} more kills with {1} to unlock
    end
    self:setupBackplates()
end

function ItemInfoController:populateItemInfo(item, character, itemPriceModifierId, inShopSellMode)
    self:clearInfo()

    local name = item:get("name")
    
    --print(name)
    self:setActive("itemInfo", true)
    self:setTitle(name)

    local type = weaponTypeToStringKey[item:getType()]
    if type then
        self:setSubtitle(type)
    end

    local hasArmor = false
    if item.gun then
        self:populateWeaponInfo(item, character, itemPriceModifierId, inShopSellMode)
    elseif item.melee then
        self:populateMeleeWeaponInfo(item, character, itemPriceModifierId, inShopSellMode)
    elseif item.ammo then
        self:populateAmmoInfo(item, itemPriceModifierId, inShopSellMode)
    elseif item.armor then
        hasArmor = true
        self:populateArmorInfo(item, itemPriceModifierId, inShopSellMode)
    elseif item.grenade then
        self:populateExplosiveInfo(item, itemPriceModifierId, inShopSellMode)
    elseif item.missile then
        self:populateThrownInfo(item, itemPriceModifierId, inShopSellMode)
    elseif item.heal then
        self:populateHealInfo(item, itemPriceModifierId, inShopSellMode)
    elseif item.bandage then
        self:populateBandageInfo(item, itemPriceModifierId, inShopSellMode)
    elseif item.ability then
        self:populateAbilityInfo(item)
    else
        local itemType = item:getType()
        local itemSlotType = item:getSlotType()
        if itemSlotType == "Misc" or itemSlotType == "Utility" or itemSlotType == "DogCollars" or itemType == "Trinket" or itemType == "Mission" then
            self:populateBasicInfo(item, itemPriceModifierId, inShopSellMode)
        end
    end

    self:setActive("ArmorPips", hasArmor)
    self:setupBackplates()
end

function ItemInfoController:populateCashInfo(cashCount)
    self:clearInfo()

    self:setActive("itemInfo", true)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)

    self:setTitle("$Cash")
    self:setImage("itemIconImage", "Sprites/Images/Items/GameResources/Resource_Dollars")
    self:setDescriptionText( "$TOOLTIPS_Cash_Tooltip_Description_text")
    self:setupBackplates()
end

function ItemInfoController:populateAlcoholInfo(alcoholType, alcoholAmount)
    self:clearInfo()

    self:setActive("itemInfo", true)
    self:setActive("itemIcon", true)
    self:setColor("itemIconImage", "white")
    self:setScale("itemIconImage", 1)
    self:setDescriptionText(Alcohol.getTooltipDescription(alcoholType))
    self:setTitle(Alcohol.getName(alcoholType))
    self:setImage("itemIconImage", Alcohol.getIcon(alcoholType))
    self:setupBackplates()
end

function ItemInfoController:setDescriptionText(...)
    if (... ~= nil) then
        self:setActive("descriptionGroup", true)
        self:setText("descInfo", ...)
    end
end

function ItemInfoController:setupBackplates(startWithBackplate)
    local showBackplate = not not startWithBackplate
    for i = 1, self._curAttributeGroupIndex do
        local groupId = "attributesGroup" .. i
        if showBackplate then
            self:setActiveInternal(groupId, "backplate", true)
            self:setPadding(groupId, 20, 20, 30, 30)
        else
            self:setActiveInternal(groupId, "backplate", false)
            self:setPadding(groupId, 0, 0, 0, 0)
        end
        showBackplate = not showBackplate
    end
    if self._curAttributeSimpleDataCount > 0 then
        if showBackplate then
            self:setActiveInternal("bonusGroup", "backplate", true)
            self:setPadding("bonusGroup", 20, 20, 30, 30)
        else
            self:setActiveInternal("bonusGroup", "backplate", false)
            self:setPadding("bonusGroup", 0, 0, 0, 0)
        end
        showBackplate = not showBackplate
    end
    if showBackplate then
        self:setActiveInternal("descriptionGroup", "backplate", true)
        self:setPadding("descriptionGroup", 20, 20, 30, 30)
    else
        self:setActiveInternal("descriptionGroup", "backplate", false)
        self:setPadding("descriptionGroup", 0, 0, 0, 0)
    end
    if not self:isTooltip() then
        self:resetPassiveScrollAnimation("scrollView")
        self:triggerPassiveScrollAnimation("scrollView")
    end
end

function ItemInfoController:clearInfo()
    self:clearAttributes()

    self:setColor("infoTitle", "gold")
    self:setActive("infoTitle", false)
    self:setPadding("titleGroup", 0, 0, 0, 0)
    self:setActive("titleIcon", false)
    self:setActive("infoType", false)
    self:setActive("infoIcons", false)
    self:setActive("itemIcon", false)
    self:setActive("ArmorPips", false)
    self:setActive("bonusGroup", false)
    self:setActive("descriptionGroup", false)
    self:setActive("cannotUseDescription", false)
end

function ItemInfoController:setControllerParent(parentController, parentElementId)
    Super.setControllerParent(self, parentController, parentElementId)

    self:setContentSizeFitterEnabled("root", false)
    self:setAnchorMin("root", 0, 0)
    self:setAnchorMax("root", 1, 1)
    self:setOffsetMin("root", 0, 0)
    self:setOffsetMax("root", 0, 0)

    self:setColor("root", "clear")

    self:setActive("scrollView", true)
    self:setParent("itemInfo", "scrollView")
    self:setAnchorMin("itemInfo", 0, 0)
    self:setAnchorMax("itemInfo", 1, 1)
    self:setOffsetMin("itemInfo", 0, 0)
    self:setOffsetMax("itemInfo", 0, 0)
end

local _tooltipInstance
function ItemInfoController:isTooltip()
    return self == _tooltipInstance
end

function ItemInfoController.getTooltipInstance()
    if not _tooltipInstance then
        -- Dumb hack
        -- Create a new table made up references to the functions of ItemInfoController
        local t = {}
        for k, v in next, ItemInfoController do
            if type(v) == "function" then
                t[k] = v
            end
        end
        -- Remove the reference to ItemInfoController's init function
        t.init = nil

        -- Defer showing the tooltip for a full frame to give then layout group a chance rebuild
        local delayedCallback
        function t:showAtElement(ui, id, internalId, positionMode)
            if delayedCallback then
                return
            end
            self:setActive("tooltipBorder", true)
            local tempHeight = MaxTooltipHeight / client.ui:getScreenScale()
            self:setWidthHeight("root", self.tooltipWidth or TooltipWidth, tempHeight)

            local i = 2
            delayedCallback = function()
                if i <= 0 then
                    local targetSize = self:getHeight("itemInfo") + TooltipPaddingTopAndBottom
                    local maxHeight = MaxTooltipHeight / client.ui:getScreenScale()
                    if targetSize > maxHeight then
                        targetSize = maxHeight
                        self:setScrollRectSoftMaskEnabled("scrollView", true)
                        self:setActive("bottomPadding", true)
                    else
                        self:setScrollRectSoftMaskEnabled("scrollView", false)
                        self:setActive("bottomPadding", false)
                    end
                    self:setWidthHeight("root", self.tooltipWidth or TooltipWidth, targetSize)

                    self:rebuild("root")
                    self:resetPassiveScrollAnimation("scrollView")
                    self:triggerPassiveScrollAnimation("scrollView")

                    FloaterTooltip.showAtElement(self, ui, id, internalId, positionMode)

                    game:removeEventListener("frame", delayedCallback)
                    delayedCallback = nil
                    i = 2
                else
                    i = i - 1
                end
            end
            game:addEventListener("frame", delayedCallback)
        end

        function t:hide(immediate)
            if delayedCallback then
                game:removeEventListener("frame", delayedCallback)
                delayedCallback = nil
            end
            FloaterTooltip.hide(self, immediate)
        end

        -- Create an instance of a new class which is defined by this new table, and has FloaterTooltip as a super class
        _tooltipInstance = newClass("RomeroGames.UI.ItemInfoTooltip", t, FloaterTooltip):new("Xml/ItemInfo", Config.FLOATERS.FLOATER_TOOLTIP)
    end
    return _tooltipInstance
end

return newClass("RomeroGames.UI.ItemInfoController", ItemInfoController, Super)

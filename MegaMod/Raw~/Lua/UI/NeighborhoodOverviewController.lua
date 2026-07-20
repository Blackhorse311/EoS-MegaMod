--$$ Empire Info

local FullScreenPanelController = require("UI.FullScreenPanelController")
local World = require("World.World")
local WorldMapController = require("World.WorldMapController")
local InputProcessor = require("Libs.InputProcessor")
local GenericTooltip = require("UI.Floaters.GenericTooltip")
local TooltipPopulation = require("UI.TooltipPopulation")
local tooltip
local input = client.input

local Super = FullScreenPanelController

local NeighborhoodOverviewController = {}

local _neighborhoodBonusIds = { "neighborhoodBonus_1" }

local _precinctSlotIds = { "precinctButton1" }
local _precinctIdToIndex = { precinctButton1 = 1 }
local _racketSlotIds =
{
    "racketSlot1",
    "racketSlot2",
    "racketSlot3",
    "racketSlot4",
    "racketSlot5",
    "racketSlot6",
    "racketSlot7",
    "racketSlot8",
    "racketSlot9",
    "racketSlot10",
}
local _selectedPrecinctId
local _starIcons =
{
    emptyIcon = "Sprites/EmpireView/Icon_Star_Empty_W",
    fullIcon = "Sprites/EmpireView/Icon_Star_W",
}
local starIds =
{
    "star_1",
    "star_2",
    "star_3",
    "star_4",
    "star_5",
}

local MAX_GRID_ELEMENTS = 10

-- -----------------------------------------------------------------------------------
-- Tooltip Functions
-- -----------------------------------------------------------------------------------

function NeighborhoodOverviewController:onShowTooltip(id, internalId)
    tooltip:clear()
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowNeighborhoodNicknameTooltip(id, internalId)
    tooltip:clear()
    local neighborhood = World.uiData.curFocusedNeighborhood
    tooltip:setTitle("$NeighborhoodNicknameWrapper", neighborhood.nickname.name)
    tooltip:setSubtitle("$NickName_Title")
    local modifierId = neighborhood.nickname.modifierId
    local effects = World.getModifierDescriptions(modifierId)
    for i = 1, #effects do
        tooltip:addData(effects[i])
    end
    tooltip:showToRightOfElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowNeighborhoodOwner(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    tooltip:clear()
    TooltipPopulation.populateNeighborhoodOwner(tooltip, neighborhood)
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowSynergyOverviewTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    tooltip:clear()
    TooltipPopulation.populateNeighborhoodSynergies(tooltip, neighborhood)
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowSynergyTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    tooltip:clear()
    TooltipPopulation.populateSynergyTooltip(tooltip, neighborhood, id)
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowBonusesTooltip(id, internalId)
    tooltip:clear()
    tooltip:setTitle("$TOOLTIPS_bonusTitle_text")
    tooltip:setDescription("$TOOLTIPS_bonusIconSubtitle_text")
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowNetIncomeTooltip(id, internalId)
    tooltip:clear()
    tooltip:setWidth(800)
    tooltip:setTitle("$YourNetIncome")
    local neighborhood = World.uiData.curFocusedNeighborhood
    local income = 0
    local upkeep = 0
    local netIncomeColor
    for i = 1, #neighborhood.precincts do
        local precinct = neighborhood.precincts[i]
        if precinct.faction.isPlayerFaction then
            local precinctIncome = 0
            local precinctUpkeep = 0
            for j = 1, #precinct.buildings do
                local b = precinct.buildings[j]
                precinctIncome = precinctIncome + b.data.income
                precinctUpkeep = precinctUpkeep + b.data.upkeep
            end
            income = income + precinctIncome
            upkeep = upkeep + precinctUpkeep
            if precinctIncome > precinctUpkeep then
                netIncomeColor = "statePositive"
            elseif precinctUpkeep > precinctIncome then
                netIncomeColor = "stateNegative"
            else
                netIncomeColor = "gold"
            end
            tooltip:addData("$Format_Color", netIncomeColor, "$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", precinct.name, "$Format_Price", precinctIncome - precinctUpkeep)
        end
    end
    if income > upkeep then
        netIncomeColor = "statePositive"
    elseif upkeep > income then
        netIncomeColor = "stateNegative"
    else
        netIncomeColor = "gold"
    end
    tooltip:addData("$Format_Color", netIncomeColor, "$Format_TwoItems", "$Format_Colon", "$Total", "$Format_Price", income - upkeep)
    tooltip:showToRightOfElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowGrossIncomeTooltip(id, internalId)
    tooltip:clear()
    tooltip:setWidth(800)
    tooltip:setTitle("$YourGrossIncome")
    local neighborhood = World.uiData.curFocusedNeighborhood
    local income = 0
    for i = 1, #neighborhood.precincts do
        local precinct = neighborhood.precincts[i]
        if precinct.faction.isPlayerFaction then
            local precinctIncome = 0
            for j = 1, #precinct.buildings do
                local b = precinct.buildings[j]
                precinctIncome = precinctIncome + b.data.income
            end
            income = income + precinctIncome
            tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", precinct.name, "$Format_Price", precinctIncome)
        end
    end
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Total", "$Format_Price", income)
    tooltip:showToRightOfElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowExpensesTooltip(id, internalId)
    tooltip:clear()
    tooltip:setWidth(800)
    tooltip:setTitle("$YourExpenses")
    local neighborhood = World.uiData.curFocusedNeighborhood
    local upkeep = 0
    for i = 1, #neighborhood.precincts do
        local precinct = neighborhood.precincts[i]
        if precinct.faction.isPlayerFaction then
            local precinctUpkeep = 0
            for j = 1, #precinct.buildings do
                local b = precinct.buildings[j]
                precinctUpkeep = precinctUpkeep + b.data.upkeep
            end
            upkeep = upkeep + precinctUpkeep
            tooltip:addData("$Format_BulletEntry", "$Format_TwoItems", "$Format_Colon", precinct.name, "$Format_Price", precinctUpkeep)
        end
    end
    tooltip:addData("$Format_TwoItems", "$Format_Colon", "$Total", "$Format_Price", upkeep)
    tooltip:showToRightOfElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowWeeklyProductionTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    tooltip:clear()
    tooltip:setWidth(800)
    local totalProduction = 0
    for i = 1, #neighborhood.precincts do
        local precinct = neighborhood.precincts[i]
        if precinct.faction.isPlayerFaction then
            local precinctProduction = 0
            for j = 1, #precinct.buildings do
                local b = precinct.buildings[j]
                precinctProduction = precinctProduction + (b.data.production or 0)
            end
            totalProduction = totalProduction + precinctProduction
            tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", precinct.name, "$Format_Color", "statePositive", "$Format_PlusBarrels2DecimalPlaces", precinctProduction)
        end
    end
    tooltip:setTitle("$Format_Colon2Elements", "$Building_WeeklyProduction", "$Format_Color", "statePositive", "$Format_PlusBarrels2DecimalPlaces", totalProduction)
    tooltip:showToRightOfElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowWeeklyConsumptionTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    tooltip:clear()
    tooltip:setWidth(800)
    local totalConsumption = 0
    for i = 1, #neighborhood.precincts do
        local precinct = neighborhood.precincts[i]
        if precinct.faction.isPlayerFaction then
            local precinctConsumption = 0
            for j = 1, #precinct.buildings do
                local b = precinct.buildings[j]
                precinctConsumption = precinctConsumption + (b.data.consumption or 0)
            end
            totalConsumption = totalConsumption + precinctConsumption
            tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", precinct.name, "$Format_Color", "stateNegative", "$Format_PlusBarrels2DecimalPlaces", precinctConsumption)
        end
    end
    tooltip:setTitle("$Format_Colon2Elements", "$Building_WeeklyConsumption", "$Format_Color", "stateNegative", "$Format_PlusBarrels2DecimalPlaces", totalConsumption)
    tooltip:showToRightOfElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowStorageTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    tooltip:clear()
    tooltip:setWidth(800)
    local totalStorage, totalStored = 0, 0
    for i = 1, #neighborhood.precincts do
        local precinct = neighborhood.precincts[i]
        if precinct.faction.isPlayerFaction then
            local storage = 0
            local stored = 0
            for j = 1, #precinct.buildings do
                local b = precinct.buildings[j]
                if b.storage then
                    storage = storage + b.storage.amount
                    stored = stored + b.storage.stored
                end
            end
            totalStorage = totalStorage + storage
            totalStorage = totalStorage + stored
            tooltip:addData("$Format_BulletEntry", "$Format_Colon2Elements", precinct.name, "$Format_Barrels", "$Format_FractionWholeNumber", stored, storage)
        end
    end
    tooltip:setTitle("$Format_Colon2Elements", "$Building_Storage", "$Format_Barrels", "$Format_FractionWholeNumber", totalStored, totalStorage)
    tooltip:showToRightOfElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowPrecinctOwnerTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    local precinct = neighborhood.precincts[_precinctIdToIndex[id]]
    tooltip:clear()
    TooltipPopulation.populatePrecinctOwner(tooltip, precinct)
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowPrecinctDepotTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    local precinct = neighborhood.precincts[_precinctIdToIndex[id]]
    tooltip:clear()
    if precinct:canSupplyOwner() then
        TooltipPopulation.populatePrecinctDepotTooltip(tooltip, precinct)
    else
        TooltipPopulation.populatePrecinctSupplyCutOffTooltip(tooltip, precinct)
    end
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowPrecinctCanBuildTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    local precinct = neighborhood.precincts[_precinctIdToIndex[id]]
    tooltip:clear()
    TooltipPopulation.populatePrecinctAvailableBuildingsTooltip(tooltip, precinct)
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowPrecinctDefendersTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    local precinct = neighborhood.precincts[_precinctIdToIndex[id]]
    tooltip:clear()
    TooltipPopulation.populatePrecinctDefendersTooltip(tooltip, precinct)
    tooltip:showToLeftOfElement(self, id, "defendersIcon")
end

function NeighborhoodOverviewController:onShowPrecinctPoliceActivityTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    local precinct = neighborhood.precincts[_precinctIdToIndex[id]]
    tooltip:clear()
    TooltipPopulation.populatePoliceActivityTooltip(tooltip, precinct)
    tooltip:showOverElement(self, id, internalId)
end

function NeighborhoodOverviewController:onShowPrecinctRacketTooltip(id, internalId)
    local neighborhood = World.uiData.curFocusedNeighborhood
    local precinct = neighborhood.precincts[_precinctIdToIndex[id]]
    local building
    for i = 1, #_racketSlotIds do
        if _racketSlotIds[i] == internalId then
            building = precinct.racketBuildings[i]
            break
        end
    end
    if building then
        tooltip:clear()
        TooltipPopulation.populateBuildingTooltip(tooltip, building)
        tooltip:showOverElement(self, id, internalId)
    end
end

function NeighborhoodOverviewController:onShowPrecinctConsumptionTooltip( id, internalId)
	local neighborhood = World.uiData.curFocusedNeighborhood
    local precinct = neighborhood.precincts[_precinctIdToIndex[id]]
    tooltip:clear()
    TooltipPopulation.populatePrecinctConsumptionTooltip(tooltip, precinct)
    tooltip:showToLeftOfElement(self, id, "netProduction")
end


function NeighborhoodOverviewController:onHideTooltip()
    tooltip:hide()
end

-- -----------------------------------------------------------------------------------
-- Xml Events
-- -----------------------------------------------------------------------------------

function NeighborhoodOverviewController:nextNeighborhood()
    local location
    local curFocusedLocation = World.uiData.curFocusedNeighborhood
    local neighborhoods = World._exteriorLocations
    for i = 1, #neighborhoods do
        if neighborhoods[i] == curFocusedLocation then
            if i >= #neighborhoods then
                location = neighborhoods[1]
            else
                location = neighborhoods[i+1]
            end
            break
        end
    end
    World.uiData.curFocusedNeighborhood = location
    self:verticalScrollTo("precinctGridScrollView", 1, 0)
    self:populate(location)
    self:select("precinctButton1", true)
end

function NeighborhoodOverviewController:previousNeighborhood()
    local location
    local curFocusedLocation = World.uiData.curFocusedNeighborhood
    local neighborhoods = World._exteriorLocations
    for i = 1, #neighborhoods do
        if neighborhoods[i] == curFocusedLocation then
            if i <= 1 then
                location = neighborhoods[#neighborhoods]
            else
                location = neighborhoods[i-1]
            end
            break
        end
    end
    World.uiData.curFocusedNeighborhood = location
    self:verticalScrollTo("precinctGridScrollView", 1, 0)
    self:populate(location)
    self:select("precinctButton1", true)
end

function NeighborhoodOverviewController:onClickOnPrecinct(id)
    local index = _precinctIdToIndex[id]
    local precinct = World.uiData.curFocusedNeighborhood.precincts[index]
    World.uiData.curFocusedPrecinct = precinct
    client.transition:enableLayer("PrecinctOverview")
end

function NeighborhoodOverviewController:onSelectPrecinct(id)
    _selectedPrecinctId = id
    self:applyBlackAndWhiteInternal(id, "precinctImage", false)
    self:setElementAlphaInternal(id, "precinctImage", 0.5)
    self:refreshButtonPrompts()
end

function NeighborhoodOverviewController:onDeselectPrecinct(id)
    self:applyBlackAndWhiteInternal(id, "precinctImage", true)
    self:setElementAlphaInternal(id, "precinctImage", 0.25)
    _selectedPrecinctId = nil
    self:refreshButtonPrompts()
end

function NeighborhoodOverviewController:onMouseEnterButton(id)
    self:select(id, true)
end

local _scrollAmount = 0
local _scrollStep = 4
function NeighborhoodOverviewController:onScrollPrecinctGrid(id, internalId, normalizedAmount)
    if _scrollAmount ~= normalizedAmount then
        _scrollAmount = normalizedAmount
    end
end

-- -----------------------------------------------------------------------------------
-- Events
-- -----------------------------------------------------------------------------------

function NeighborhoodOverviewController:onInputSourceChanged(e)
    self:checkControllerInput(e.mode == "controller")
end

function NeighborhoodOverviewController:scrollUp()
    local scrollAmount = self:scrollHelper("precinctGridScrollView", 1, _scrollAmount, nil, _scrollStep)
    self:verticalScrollTo("precinctGridScrollView", scrollAmount)
end

function NeighborhoodOverviewController:scrollDown()
    local scrollAmount = self:scrollHelper("precinctGridScrollView", -1, _scrollAmount, nil, _scrollStep)
    self:verticalScrollTo("precinctGridScrollView", scrollAmount)
end

-- -----------------------------------------------------------------------------------
-- Input Events
-- -----------------------------------------------------------------------------------

local inputEvents =
{
    "onCloseUI",
    "onSubmitUI",
    "onNavUp",
    "onNavDown",
    "onNavLeft",
    "onNavRight",
    "onScroll",

    "onPreviousEntry",
    "onNextEntry",
}

function NeighborhoodOverviewController:onPreviousTab(e) -- Override parent function
end

function NeighborhoodOverviewController:onNextTab(e) -- Override parent function
end

function NeighborhoodOverviewController:onPreviousEntry(e)
    self:previousNeighborhood()
end

function NeighborhoodOverviewController:onNextEntry(e)
    self:nextNeighborhood()
end

function NeighborhoodOverviewController:onScroll(e)
    if e.direction > 0 then
        self:scrollUp()
    else
        self:scrollDown()
    end
end

function NeighborhoodOverviewController:onNavUp(e)
    local allowLooping = true
    if not (_selectedPrecinctId and input:attemptNavigateUIUp(allowLooping)) then
        local precincts = World.uiData.curFocusedNeighborhood.precincts
        local selectId = _precinctSlotIds[#precincts]
        self:select(selectId, true)
    end
end

function NeighborhoodOverviewController:onNavDown(e)
    local allowLooping = true
    if not (_selectedPrecinctId and input:attemptNavigateUIDown(allowLooping)) then
        local selectId = _precinctSlotIds[1]
        self:select(selectId, true)
    end
end

function NeighborhoodOverviewController:onNavLeft(e)
    local allowLooping = true
    if not (_selectedPrecinctId and input:attemptNavigateUILeft(allowLooping)) then
        local precincts = World.uiData.curFocusedNeighborhood.precincts
        local selectId = _precinctSlotIds[#precincts]
        self:select(selectId, true)
    end
end

function NeighborhoodOverviewController:onNavRight(e)
    local allowLooping = true
    if not (_selectedPrecinctId and input:attemptNavigateUIRight(allowLooping)) then
        local selectId = _precinctSlotIds[1]
        self:select(selectId, true)
    end
end

function NeighborhoodOverviewController:onSubmitUI(e)
    if _selectedPrecinctId then
        self:onClickOnPrecinct(_selectedPrecinctId)
    end
end

-- -----------------------------------------------------------------------------------
-- Populate
-- -----------------------------------------------------------------------------------

function NeighborhoodOverviewController:populate(neighborhood)
    self:setText("neighborhoodName", neighborhood.name)
    if neighborhood.nickname then
        self:setActive("neighborhoodNickname", true)
        self:setText("neighborhoodNickname", "$NeighborhoodNicknameWrapper", neighborhood.nickname.name) --$ "{0}"
    else
        self:setActive("neighborhoodNickname", false)
    end
    local faction = neighborhood.owner
    local icon
    if faction then
        icon = faction:getKnownBossPortrait(true)
    else
        icon = "Sprites/EmpireView/Icon_NoOwner_G"
    end
    self:setImage("ownerPortrait", icon)
    self:setImage("neighborhoodImage", neighborhood.keyImage)
    local income = 0
    local upkeep = 0
    local production = 0
    local consumption = 0
    local stored = 0
    local storageSpace = 0
    for i = 1, #neighborhood.buildings do
        local b = neighborhood.buildings[i]
        if b.faction.isPlayerFaction then
            income = income + b.data.income
            upkeep = upkeep + b.data.upkeep
            if b.producer then
                production = production + b.producer.amount
            else
                consumption = consumption + (b.data.consumption or 0)
            end
            if b.storage then
                stored = stored + b.storage.stored
                storageSpace = storageSpace + b.storage.amount
            end
        end
    end
    local netIncomeColor
    if income > upkeep then
        netIncomeColor = "statePositive"
    elseif upkeep > income then
        netIncomeColor = "stateNegative"
    else
        netIncomeColor = "gold"
    end
    self:setText("netIncome", "$Format_Price", income - upkeep)
    self:setColor("netIncome", netIncomeColor)
    self:setText("grossIncome", "$Format_Price", income)
    self:setText("expenses", "$Format_Price", upkeep)
    self:setText("weeklyProduction", "$Format_Barrels", production)
    self:setText("weeklyConsumption", "$Format_Barrels", consumption)
    self:setText("storage", "$Format_Barrels", "$Format_FractionWholeNumber", stored, storageSpace)

    -- Populate Bonuses
    local modifierId = neighborhood:getLocationModifierIds()
    local startingIndex = 1
    for i = 1, #modifierId do
        startingIndex = self:populateBonuses(modifierId[i], startingIndex)
    end
    
    for i = startingIndex, #_neighborhoodBonusIds do
        self:setActive(_neighborhoodBonusIds[i], false)
    end

    -- MODIFIED NEW CODE - Show bonus from neighbourhood nickname with other bonuses
    if neighborhood.nickname then
        local modifierId2 = neighborhood.nickname.modifierId
        --local effects = World.getModifierDescriptions(modifierId2)
        --for i = 1, #modifierId2 do
            startingIndex = self:populateBonuses(modifierId2, startingIndex) 
        --end
    end
    -- END

    self:populateSynergies(neighborhood)
    self:populatePrecincts(neighborhood)
end

function NeighborhoodOverviewController:populateBonuses(modifierId, startingIndex)
    local descriptions = World.getModifierDescriptions(modifierId)
    startingIndex = startingIndex - 1
    for i = 1, #descriptions do
        local id = _neighborhoodBonusIds[i + startingIndex]
        if id then
            self:setActive(id, true)
        else
            id = "neighborhoodBonus_" .. (i + startingIndex)
            self:clone("neighborhoodBonus_1", id, true)
            _neighborhoodBonusIds[i + startingIndex] = id
        end
        self:setText(id, descriptions[i])
    end
    return startingIndex + #descriptions + 1
end

function NeighborhoodOverviewController:populateSynergies(neighborhood)
    local playerFaction = World.playerFaction
    local synergies = World.neighborhoodSynergies[neighborhood.id]
    local synergyPriorityList = Config.BEHAVIOURS.SYNGERGY.synergyPriority

    for index = 1, #synergyPriorityList do
        local synergyKey = synergyPriorityList[index]
        local factionHasSynergy = synergies:factionHasSynergy(synergyKey, playerFaction)
        self:setColor(synergyKey, factionHasSynergy and "gold" or "dullGrey")
    end
end

function NeighborhoodOverviewController:populatePrecincts(neighborhood)
    local precincts = neighborhood.precincts
    for i = 1, #precincts do
        local precinct = precincts[i]
        local id = _precinctSlotIds[i]
        if not id then
            id = "precinctButton" .. i
            self:clone("precinctButton1", id, true)
            self:setupCallbacksForPrecinctButton(id)
            _precinctSlotIds[i] = id
            _precinctIdToIndex[id] = i
        end
        self:setActive(_precinctSlotIds[i], true)
        self:setTextInternal(id, "precinctName", precinct.shortName)
        self:setImageInternal(id, "ownerPortrait", precinct.faction:getKnownBossPortrait(true))
        self:setImageInternal(id, "precinctImage", precinct.keyImage)
        self:applyBlackAndWhiteInternal(id, "precinctImage", true)
        self:setElementAlphaInternal(id, "precinctImage", 0.25)
        self:setImageInternal(id, "depotIcon", precinct.primaryBuilding:getIcon())
        if precinct:canSupplyOwner() then
            self:setColorInternal(id, "depotIcon", "gold")
        else
            self:setColorInternal(id, "depotIcon", "stateNegative")
        end
        local racketBuildings = precinct.racketBuildings
        local canBuild = false
        local emptyIcon = _starIcons.emptyIcon
        local fullIcon = _starIcons.fullIcon
        local level = precinct:getOverallUpgradeLevel()
        for j = 1, 5 do
            local internalId = starIds[j]
            local showStars = not precinct.faction.isThugFaction
            self:setActiveInternal(id, internalId, showStars)
            if showStars then
                if j > level then
                    self:setImageInternal(id, internalId, emptyIcon)
                else
                    self:setImageInternal(id, internalId, fullIcon)
                end
            end
        end

            for j = 1, math.min(#racketBuildings, MAX_GRID_ELEMENTS) do
                local building = racketBuildings[j]
                local racketId = building.buildingData.id or building.buildTargetId
                local internalId = _racketSlotIds[j]
                self:setActiveInternal(id, internalId, true)
                --MODIFIED self:setImageInternal(id, internalId, building:getIcon())
            
                --NEW CODE
                local buildingIcon = building:getIcon()
                if building.faction.isCitizenFaction and precinct.faction.isPlayerFaction then
                    self:setColorInternal(id, internalId, "statePositive")
                    --print(string.format("TESTING: Building available - %s", building.name))
                elseif (building.open == false or building.faction.isThugFaction) and precinct.faction.isPlayerFaction then
                    --buildingIcon = "Sprites/Icons/Buildings/Icon_Ransack"
                    self:setColorInternal(id, internalId, "stateNegative")
                    --print(string.format("TESTING: Building not open - %s", building.name))
                else
                    --buildingIcon = building:getIcon()
                    self:setColorInternal(id, internalId, "gold")
                    --print(string.format("TESTING: Other buidlings - %s", building.name))
                end
                self:setImageInternal(id, internalId, buildingIcon)
            
                --END
            
                if not racketId then
                    canBuild = true
                end
                self:setElementAlphaInternal(id, internalId, racketId and 1 or 0.25)
            end
            for j = #racketBuildings + 1, MAX_GRID_ELEMENTS do
                self:setActiveInternal(id, _racketSlotIds[j], false)
            end
            --MODIFIED (ORIGINAL CODE) self:setActiveInternal(id, "canBuildIcon", canBuild and precinct.faction.isPlayerFaction)
            self:setActiveInternal(id, "canBuildIcon", false) -- never show this icon
            --MODIFIED (ORIGINAL CODE) local defenders = precinct:getDefenderCounts()

            --NEW CODE
            local racketCapacity = 0
            for i = 1, #precinct.buildings do
                local b = precinct.buildings[i]
                if b.open ~= false then
                    racketCapacity = racketCapacity + (b.data.racketCustomerCapacity or 0)
                end
            end
            local customersInPrecinct = precinct.customerCount
            local customersInRackets = math.min(racketCapacity, customersInPrecinct)
            local customerCapacity = 0
            if customersInPrecinct > customersInRackets then
                customerCapacity = customersInPrecinct - customersInRackets 
            else
                customerCapacity = customersInRackets - racketCapacity
            end
            local customerCapacityColor = (customerCapacity > 0) and "statePositive" or (customerCapacity < 0) and "stateNegative" or "gold"
            self:setTextInternal(id, "defenderCount", "$Format_Color", customerCapacityColor, "$Format_PlusMinusNumber", customerCapacity)

            --END

            local maxPoliceActivity = 100
            local policeActivityAmount = (math.clamp(0, maxPoliceActivity, precinct:getPoliceActivity())/maxPoliceActivity)
            self:setFillAmountInternal(id, "policeActivityFill", policeActivityAmount)

            if not precinct.faction.isPlayerFaction then --if precinct.faction.isThugFaction then
                self:setActiveInternal(id, "netIncome", false)
                self:setActiveInternal(id, "netProduction", false)
                self:setActiveInternal(id, "defenderCount", false)
            else
                self:setActiveInternal(id, "netIncome", true)
                self:setActiveInternal(id, "netProduction", true)
                self:setActiveInternal(id, "defenderCount", true) -- MODIFIED (added)
                local netIncome = precinct:getNetIncome()
                local netIncomeColor = (netIncome > 0) and "statePositive" or (netIncome < 0) and "stateNegative" or "gold"
                local netIncomeFormat = (netIncome > 0) and "$Format_PricePlus" or "$Format_PriceMinus"
                self:setTextInternal(id, "netIncome", "$Format_Color", netIncomeColor, netIncomeFormat, math.abs(netIncome))
                --MODIFIED (old code) local netProduction = precinct:getNetProduction()
                local netProduction = precinct:getConsumption() -- MODIFIED (new code)
                local netProductionColor = "gold" --(netProduction > 0) and "statePositive" or (netProduction < 0) and "stateNegative" or "gold"
                self:setTextInternal(id, "netProduction", "$Format_Color", netProductionColor, "$Format_MinusBarrels", netProduction) -- MODIFIED (old format $Format_PlusBarrels)
            end
    end 
    for i = #precincts + 1, #_precinctSlotIds do
        self:setActive(_precinctSlotIds[i], false)
    end
end

-- -----------------------------------------------------------------------------------
-- Initialization/Show/Hide Functions
-- -----------------------------------------------------------------------------------

function NeighborhoodOverviewController:showUI(movingFromFullScreenContext)
    Super.showUI(self, movingFromFullScreenContext)
    self:select("precinctButton1", true)
    self:verticalScrollTo("precinctGridScrollView", 1, 0)
    self:populate(World.uiData.curFocusedNeighborhood)
    self:checkControllerInput(InputProcessor.getInputMode() == "controller")
end

function NeighborhoodOverviewController:hideUI(movingToFullScreenContext)
    Super.hideUI(self, movingToFullScreenContext)
    if WorldMapController:isWorldMapActive() then
        if self.revertToZoom == "WorldMapSummaryGrid" then
            WorldMapController:overrideClampRotation(true)
        end
    end
    _selectedPrecinctId = nil
end

function NeighborhoodOverviewController:adjustToScreenSettings(scale, width, height, aspectRatio)
    Super.adjustToScreenSettings(self, scale, width, height, aspectRatio)
    if scale > 1 then
        self:setAnchorMax("statsPanel", 0.25, 1)
        self:setAnchorMin("precincts", 0.25, 0)
        _scrollStep = 4
    else
        local anchorOffset = 0.25 * scale
        self:setAnchorMax("statsPanel", anchorOffset, 1)
        self:setAnchorMin("precincts", anchorOffset, 0)
        _scrollStep = 1
    end
end

function NeighborhoodOverviewController:onConcealFlagChanged(e)
    Super.onConcealFlagChanged(self, e)
    if e.flag == "ButtonPrompts" then
        self:setActive("buttonPrompts", not e.state)
    end
end

function NeighborhoodOverviewController:checkControllerInput(controllerConnected)
    -- Super.checkControllerInput(self, controllerConnected)
    -- self:setPromptImage("selectGroupIcon", "navigateUISubmit")
    -- self:setActive("changeLocationGroup", controllerConnected)
    -- if controllerConnected then
    --     self:setPromptImage("changeLocationIcon", "navigateEntries")
    -- end
    self:refreshButtonPrompts()
end

local function isSelectingPrecinct()
    return not not _selectedPrecinctId
end

function NeighborhoodOverviewController:addButtonPrompts()
    self:addButtonPrompt("navigateUISubmit", "$ViewPrecinct", nil, isSelectingPrecinct) --$ View Precinct
    self:addButtonPrompt("navigateUIClose", "$Button_Back", self.onCloseUI)
end

function NeighborhoodOverviewController:setupCallbacksForPrecinctButton(id)
    self:setOnClickCallback(id, self.onClickOnPrecinct)
    self:setOnSelectCallback(id, self.onSelectPrecinct)
    self:setOnDeselectCallback(id, self.onDeselectPrecinct)
    self:setOnMouseEnterCallback(id, self.onMouseEnterButton)

    self:setUITooltipCallbacksInternal(id, "ownerPortrait", self.onShowPrecinctOwnerTooltip, self.onHideTooltip)
    self:setUITooltipCallbacksInternal(id, "depotIcon", self.onShowPrecinctDepotTooltip, self.onHideTooltip)
    self:setUITooltipCallbacksInternal(id, "canBuildIcon", self.onShowPrecinctCanBuildTooltip, self.onHideTooltip)
    self:setUITooltipCallbacksInternal(id, "defendersIcon", self.onShowPrecinctDefendersTooltip, self.onHideTooltip)
    self:setUITooltipCallbacksInternal(id, "defenderCount", self.onShowPrecinctDefendersTooltip, self.onHideTooltip)
    self:setUITooltipCallbacksInternal(id, "policeActivity", self.onShowPrecinctPoliceActivityTooltip, self.onHideTooltip)
    self:setUITooltipCallbacksInternal(id, "netProduction", self.onShowPrecinctConsumptionTooltip, self.onHideToolTip) -- MODIFIED - added

    for i = 1, 10 do
        self:setUITooltipCallbacksInternal(id, "racketSlot" .. i, self.onShowPrecinctRacketTooltip, self.onHideTooltip)
    end
end

function NeighborhoodOverviewController:setupCallbacks()
    -- Super.setupCallbacks(self)
    self:setOnClickCallback("previousNeighborhood", self.previousNeighborhood)
    self:setOnClickCallback("nextNeighborhood", self.nextNeighborhood)
    self:setOnValueChangedCallback("precinctGridScrollView", self.onScrollPrecinctGrid)

    self:setUITooltipCallbacks("neighborhoodNickname", self.onShowNeighborhoodNicknameTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("ownerPortrait", self.onShowNeighborhoodOwner, self.onHideTooltip)
    self:setUITooltipCallbacks("netIncomeParent", self.onShowNetIncomeTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("grossIncomeParent", self.onShowGrossIncomeTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("expensesParent", self.onShowExpensesTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("weeklyProductionParent", self.onShowWeeklyProductionTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("weeklyConsumptionParent", self.onShowWeeklyConsumptionTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("storageParent", self.onShowStorageTooltip, self.onHideTooltip)

    self:setUITooltipCallbacks("neighborhoodSynergies", self.onShowSynergyOverviewTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("twoPair", self.onShowSynergyTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("threeOfAKind", self.onShowSynergyTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("fullHouse", self.onShowSynergyTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("straight", self.onShowSynergyTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("fiveOfAKind", self.onShowSynergyTooltip, self.onHideTooltip)
    self:setUITooltipCallbacks("neighborhoodBonusesTitle", self.onShowBonusesTooltip, self.onHideTooltip)

    self:setupCallbacksForPrecinctButton("precinctButton1")
end

function NeighborhoodOverviewController:init(gameLayer)
    Super.init(self, gameLayer, "Xml/NeighborhoodOverview")
    self:setInputEvents(inputEvents)
    tooltip = GenericTooltip.getInstance()
end

return newClass("RomeroGames.UI.NeighborhoodOverviewController", NeighborhoodOverviewController, Super)

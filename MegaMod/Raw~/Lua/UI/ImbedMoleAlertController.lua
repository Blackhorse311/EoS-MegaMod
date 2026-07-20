local UIController = require("Libs.UIController")
local InputProcessor = require("Libs.InputProcessor")
local World = require("World.World")
local ConfigBuilder = require("Libs.ConfigBuilder")
local GenericTooltip = require("UI.Floaters.GenericTooltip")
local TooltipPopulation = require("UI.TooltipPopulation")

local ImbedMoleAlertController = {}
local tooltip

local idToFactionMap = {}
local selectedIndex = 1
local factionElementCount = 0
local indexedFactionList = {}
local factionListToIndexMap = {}
local wrapThreshold = 5
local currentWrapIndex = wrapThreshold
local factionButtonElements = 0

-- "$EmbedMoleAlertTitle" --$ Embed Mole
-- "$EmbedMoleAlertSubtitle" --$ Choose mole's target
-- "$ImbedMoleDescription" --$ {0:name} will not be available to your crew for up to 6 months while embedded with another faction, but {0:gender?he|she|they} will remain on your payroll. \n{0:gender?He|She|They} will be in touch on a regular basis for your instructions'


function ImbedMoleAlertController:doYes()
    self:sendMole(self.gangster, idToFactionMap[indexedFactionList[selectedIndex]], World.playerFaction)
    client.transition:disableLayer("ImbedMole")
end

function ImbedMoleAlertController:doNo()
    client.transition:disableLayer("ImbedMole")
end

function ImbedMoleAlertController:doNavUp()
    self:wrapIndexToFlipLines()
end

function ImbedMoleAlertController:doNavDown()
    self:wrapIndexToFlipLines()
end

function ImbedMoleAlertController:wrapIndexToFlipLines()
    if factionElementCount <= currentWrapIndex then
        return
    end
    if selectedIndex <= currentWrapIndex then
        selectedIndex = selectedIndex + currentWrapIndex
    else
        selectedIndex = selectedIndex - currentWrapIndex
    end
    if selectedIndex > factionElementCount then
        selectedIndex = selectedIndex - factionElementCount
    end
    local id = indexedFactionList[selectedIndex]
    self:select(id, true)
end

function ImbedMoleAlertController:doNavLeft()
    selectedIndex = selectedIndex - 1

    if selectedIndex < 1 then
        selectedIndex = factionElementCount
    end

    local id = indexedFactionList[selectedIndex]
    self:select(id, true)
end

function ImbedMoleAlertController:doNavRight()
    selectedIndex = selectedIndex + 1
    if selectedIndex > factionElementCount then
        selectedIndex = 1
    end

    local id = indexedFactionList[selectedIndex]
    self:select(id, true)
end

function ImbedMoleAlertController:checkControllerInput(controllerConnected)
    self:setPromptImage("confirmImage", "doSend")
    self:setPromptImage("cancelImage", "doCancel")
end

function ImbedMoleAlertController:onInputSourceChanged(e)
    self:checkControllerInput(e.mode == "controller")
end

function ImbedMoleAlertController:display( params )
    local character = params.selectedChar
    self.gangster = character
    local characterConfig = ConfigBuilder.fromId(character.configId)
    local playerFaction = World.playerFaction
    local profession = character.profession:getMain()
    local moleActionConfig = World.moleManager:getSabotageActionForProfession(profession)
    local successChance = moleActionConfig.successChances[6 - character.tier] / 5

    self:setText("imbedMoleText", {"$ImbedMoleDescription", character})  --MODIFIED (was character.name)
    self:setText("imbedMoleProfessionText", {"$ImbedMoleProfessionNew", character.profession:getMain().stringsKey, moleActionConfig.descriptionKey, successChance}) --$ {0}\n{1}\nInitial chance of success: {2:P0}
    self:setImage("fullBodyRender", character:getFullBodyPortrait())

    local allKnownFactions = playerFaction.diplomacy:getKnownGangs()
    local knownFactions = {}
    for i = 1, #allKnownFactions do
        local factionToCheck = allKnownFactions[i]
        if factionToCheck._active then
            knownFactions[#knownFactions + 1] = factionToCheck
        end
    end

    local knownFactionCount = knownFactions and #knownFactions or 0
    clearTable(indexedFactionList)
    clearTable(factionListToIndexMap)
    clearTable(idToFactionMap)
    local populatedCount = 0
    currentWrapIndex = math.max(wrapThreshold, math.floor(knownFactionCount / 2))
    --print("Wrap index for count of", knownFactionCount, "is", currentWrapIndex)
    if knownFactionCount > 0 then
        local loopCount = math.max(factionButtonElements, knownFactionCount)
        for i = 1, loopCount do
            local id = "factionButton_" .. i
            if i > knownFactionCount then
                self:setActive(id, false)
            else
                if i > factionButtonElements then
                    self:clone("factionButton_0", id, true)
                    factionButtonElements = factionButtonElements + 1
                else
                    self:setActive(id, true)
                end

                local boss = knownFactions[i].boss

                self:setImageInternal(id, "portrait", boss.characterIcon)
                idToFactionMap[id] = boss.faction
                indexedFactionList[#indexedFactionList + 1] = id
                populatedCount = populatedCount + 1
                factionListToIndexMap[id] = populatedCount
                self:setUITooltipCallbacks(id, self.onShowRelationshipTooltip, self.onHideTooltip)
                self:setOnClickCallback(id, self.onFactionClicked)
                self:setOnHighlightCallback(id, self.onFactionSelected)
            end
        end
    end
    factionElementCount = populatedCount

    self:showUI()
    if self:idExists("panelBack") then
        self:setWidthHeight("panelBack", params.wide and 1440 or 960, 0)
    end
    self:checkControllerInput(InputProcessor.getInputMode() == "controller")
end

function ImbedMoleAlertController:onFactionClicked(id)
    self:doYes()
end

function ImbedMoleAlertController:onFactionSelected(id)
    --local targetFaction = idToFactionMap[id]
    selectedIndex = factionListToIndexMap[id]
    --print("Selected ", targetFaction.name)
end

function ImbedMoleAlertController:sendMole(gangster, targetFaction)
    World.moleManager:sendMole(gangster, targetFaction)
end

function ImbedMoleAlertController:onShowRelationshipTooltip(id)
    local targetFaction = idToFactionMap[id]
    tooltip:clear()
    TooltipPopulation.populateFaction(tooltip, targetFaction)
    tooltip:showOverElement(self, id)
end

function ImbedMoleAlertController:onHideTooltip(id, internalId)
    tooltip:hide()
end

function ImbedMoleAlertController:hide()
    if self:exists() then
        if self:idExists("bonusText") then
            self:setActive("bonusText", false)
        end
        self.gangster = nil
        selectedIndex = 1
        self:hideUI()
    end
end

function ImbedMoleAlertController:init(gameLayer)
    UIController.init(self, gameLayer, "Xml/ImbedMoleAlert")
    self:addConcealFlagListener()
    self:setOnClickCallback("yesButton", self.doYes)
    self:setOnClickCallback("noButton", self.doNo)
    tooltip = GenericTooltip.getInstance()
end

return newClass("RomeroGames.UI.ImbedMoleAlertController", ImbedMoleAlertController, UIController)

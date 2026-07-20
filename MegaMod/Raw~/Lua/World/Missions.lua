--$$ Mission

local Script = require("Libs.Script")
local Hotload = require("Mixins.Hotload")
local TimeSlicer = require("Libs.TimeSlicer")
local TimeUtils = require("Libs.TimeUtils")
local ItemPool = require("Libs.ItemPool")
local time = client.time
local ConfigBuilder = require("Libs.ConfigBuilder")
local Behaviour = require("Mixins.Behaviour")

local Character = require("World.Actors.Characters.Character")

local TelemetryUtils = require("Libs.TelemetryUtils")

local MissionOutcome = {}
local MissionPOI = {}
local MissionObjective = {}
local Mission = {}
local Missions = {}

local missionsInLocations = {}

local _curLoadingMission

local _missionMap = {}
local _numMissions = 0
local function buildMissionMap()
    clearTable(_missionMap)
    _numMissions = 0
    local missions = Config.MISSIONS
    if missions then
        for missionName, mission in pairs(missions) do
            _numMissions = _numMissions + 1
            local m = mission._mission
            if m then
                _missionMap[m] = "MISSIONS." .. missionName
            end
        end
    end
end

local _world
local function getWorld()
    _world = _world or require("World.World")
    return _world
end

local _worldLibs
local function getWorldLibs()
    _worldLibs = _worldLibs or require("Libs.WorldLibs")
    return _worldLibs
end

local function readFunctionParam(script, func)
    if type(func) == "string" then
        func = script:getBlock(func)
        if not func then
            logError("Unable to find mission script function: ", func)
        end
    end
    return func
end

local function readTextParam(text)
    local params
    if type(text) == "table" then
        if #text > 1 then
            params = { unpack(text, 2) }
        end
        text = text[1]
    end
    return text, params
end

SaveState.defineSaveKeys(MissionOutcome,
{
    {"alcohol"},
    {"cash"},
    {"modifier"},
    {"customRewardFnName"},
    {"customName"},
    {"customNameParams"},
    {"customDescription"},
    {"customDescriptionParams"},
    {"factionRatingChange"},
    {"honor"},
    {"itemReward"},
    {"notoriety"},
    {"productionIncrease"},
    {"racket"},
    {"stat"},
    {"trait"},
    {"upgrade"},
    {"improvementReward"},
    {"alreadyGiven"}
})

function MissionOutcome:load()
    if self.customRewardFnName then
        self.customRewardFn = _curLoadingMission._script:getBlock(self.customRewardFnName)
        if not self.customRewardFn then
            logError(string.format("Unable to load custom reward function:%s in mission:%s", self.customRewardFnName, _curLoadingMission._script._configId))
        end
    end
    SaveState.loadDependencies(self, MissionOutcome)
end

function MissionOutcome:onPoolRelease()
    self.alcohol = nil
    self.cash = nil
    self.modifier = nil
    self.customRewardFn = nil
    self.customRewardFnName = nil
    self.draw = nil
    self.factionRatingChange = nil
    self.honor = nil
    self.itemReward = nil
    self.notoriety = nil
    self.productionIncrease = nil
    self.racket = nil
    self.stat = nil
    self.trait = nil
    self.upgrade = nil
    self.alreadyGiven = nil
    self.racketReward = nil
    self.improvementReward = nil
end

function MissionOutcome:onPoolAcquire()
    self.alcohol = nil
    self.modifier = nil
    self.cash = nil
    self.customRewardFn = nil
    self.customRewardFnName = nil
    self.draw = nil
    self.factionRatingChange = nil
    self.honor = nil
    self.itemReward = nil
    self.notoriety = nil
    self.productionIncrease = nil
    self.racket = nil
    self.upgrade = nil
    self.stat = nil
    self.trait = nil
    self.alreadyGiven = false
    self.racketReward = nil
    self.improvementReward = nil
end

function MissionOutcome:addItem(itemId, quantity)
    self.itemReward = {}
    self.itemReward.item = ItemPool:acquire(itemId)
    self.itemReward.itemName = self.itemReward.item and self.itemReward.item:get("name")
    self.itemReward.itemIcon = self.itemReward.item and self.itemReward.item:get("inventoryIcon")
    self.itemReward.amount = quantity or 1
end

function MissionOutcome:releaseItem()
    --Keep item name for mission journal and resolution screen
    if not self.itemReward.itemName then
        self.itemReward.itemName = self.itemReward.item and self.itemReward.item:get("name")
        self.itemReward.itemIcon = self.itemReward.item and self.itemReward.item:get("inventoryIcon")
    end

    ItemPool:release(self.itemReward.item)
    self.itemReward.item = nil
end

function MissionOutcome:addAlcohol(quality, amount)
    self.alcohol = {}
    self.alcohol.quality = quality
    self.alcohol.amount = amount
end

function MissionOutcome:addModifier(modifierId, factionId, locationId, precinctId, actor)
    self.modifier = {}
    self.modifier.modifierId = modifierId
    self.modifier.factionId = factionId
    self.modifier.locationId = locationId
    self.modifier.precinctId = precinctId
    self.modifier.actor = actor
end

function MissionOutcome:addNotoriety(amount, reason)
    self.notoriety = {}
    self.notoriety.amount = amount
    self.notoriety.reason = reason
end

function MissionOutcome:addProductionIncrease(building, modifier, reason)
    self.productionIncrease = {}
    self.productionIncrease.building = building
    self.productionIncrease.modifier = modifier
    self.productionIncrease.reason = reason
end

function MissionOutcome:addUpgrade(building, upgradeType, amount)
    self.upgrade = {}
    self.upgrade.building = building
    self.upgrade.type = upgradeType
    self.upgrade.amount = amount

    if upgradeType == "production" then
        self.upgrade.name = "$MissionReward_UpgradeProduction" --$ Production upgrade
        self.upgrade.icon = "Sprites/RacketView/Icon_ProductionUpgrade_W"
    elseif upgradeType == "security" then
        self.upgrade.name = "$MissionReward_UpgradeSecurity" --$ Security upgrade
        self.upgrade.icon = "Sprites/RacketView/Icon_Security_W"
    elseif upgradeType == "deflect" then
        self.upgrade.name = "$MissionReward_UpgradeDeflect" --$ Deflection upgrade
        self.upgrade.icon = "Sprites/RacketView/Icon_Deflection_W"
    elseif upgradeType == "ambiance" then
        self.upgrade.name = "$MissionReward_UpgradeAmbiance" --$ Ambience upgrade
        self.upgrade.icon = "Sprites/RacketView/Icon_Ambience_W"
    elseif upgradeType == "storage" then
        self.upgrade.name = "$MissionReward_UpgradeStorage" --$ Storage upgrade
        self.upgrade.icon = "Sprites/RacketView/Icon_Storage_W"
    elseif upgradeType == "wordOfMouth" then
        self.upgrade.name = "$MissionReward_UpgradeWordOfMouth" --$ Word Of Mouth upgrade
        self.upgrade.icon = "Sprites/RacketView/Icon_WordOfMouth_W"
    end
end

function MissionOutcome:addFactionRatingChange(faction, modifierId, icon)
    self.factionRatingChange = {}
    self.factionRatingChange.faction = faction
    self.factionRatingChange.modifierId = modifierId
    self.factionRatingChange.icon = icon
end

function MissionOutcome:addStat(stat, amount, name)
    self.stat = {}
    self.stat.stat = stat
    self.stat.amount = amount
    self.stat.name = name
end

function MissionOutcome:addTrait(trait, character, name)
    self.trait = {}
    self.trait.trait = trait
    self.trait.character = character
    local behaviourConfig = Behaviour.getBehaviourConfig(trait)
    local config = ConfigBuilder.fromId(behaviourConfig)
    self.trait.name = config.modifierName
    self.trait.icon = config.icon
end

function MissionOutcome:addHonor(faction, effectId)
    self.honor = {}
    self.honor.faction = faction
    self.honor.effectId = effectId
    local honorEffects = Config.HONOR_EFFECTS
    local config = honorEffects[effectId]
    self.honor.value = config.value
end

function MissionOutcome:addRacket(racket, racketType, name)
    self.racketReward = {}
    self.racketReward.racket = racket
    self.racketReward.racketType = racketType or "BUILDING_DATA.BAR"
    self.racketReward.name = name or getWorld().pickRandomRacketName(self.racketReward.racketType)
end

function MissionOutcome:addImprovement(configId, precinctId)
    self.improvementReward = {}
    self.improvementReward.configId = configId
    self.improvementReward.precinctId = precinctId
    local config = ConfigBuilder.fromId(configId)
    self.improvementReward.icon = config.icon
    self.improvementReward.name = config.name
end

function MissionOutcome:addCustomReward(text, customFn, icon)
    self.customReward = {}

    self.customReward.text = text
    self.customReward.customFn = customFn
    self.customReward.icon = icon
end

newClass("RomeroGames.World.Missions.MissionOutcome", MissionOutcome)
local _missionOutcomePool = newPool(MissionOutcome, {initialCapacity = 64, incrementalCapacity = 16})


SaveState.defineSaveKeys(MissionPOI,
{
    {"target"},
    {"poiType"},
    {"objective"},
})

function MissionPOI:onPoolAcquire(target, poiType)
    -- when getting a POI from the pool, target is the objective, but we override in addPOIImpl.
    -- make sure it doesn't break save/load!!!
    self.objective = target
    self.target = target
    self.poiType = poiType
end

function MissionPOI:onPoolRelease()
    self:disable()
    self.target = nil
    self.poiType = nil
    self.objective = nil
    self.icon = nil
    self.enabled = nil
end

function MissionPOI:enable(mission)
    if not self.enabled and mission and self.target and not self.target.isDeleted then
        mission = mission._parent or mission
        local missionName = mission._name
        local objectiveName = self.objective and self.objective._text
        local missionDescription = { mission._description, mission._descriptionParams}

        local tooltipCallback = function(tooltip, populateVars)
            tooltip:clear()
            tooltip:setTitle(missionName)
            tooltip:setIcon("Sprites/AllSharedUI/Icon_MissionLog")
            tooltip:setIconColor("gold")
            if objectiveName then
                tooltip:addData(objectiveName)
            end
            if #missionDescription > 0 then
                tooltip:setDescription(unpack(missionDescription))
            end
            tooltip:setOffsetXY(40, 0)
            tooltip:setDefaultPositionMode()
            return true
        end

        -- Status icons with the same mission name are assigned the same groupId.
        -- The groupId is used to display a single icon instead of a group of identical icons.
        -- Todo: Would it be safe to use Mission IID for this instead?
        local groupId = 0
        if missionName then
            local t = type(missionName)
            if t == "string" then
                groupId = _s[missionName] -- Use string handle of mission name as group id
            elseif t == "table" then
                for _, v in ipairs(missionName) do  -- Use sum of string handles as the group id
                    if type(v) == "string" then
                        local id = _s[v]
                        groupId = groupId + id
                    end
                end
            end
        end

        if self.poiType then
            self.icon = self.target.icon:addStatusIcon("STATUS_ICONS." .. self.poiType, objectiveName or missionName, nil, tooltipCallback, nil, groupId)
        else
            self.icon = self.target.icon:addStatusIcon("STATUS_ICONS.MISSION_TARGET", objectiveName or missionName, nil, tooltipCallback, nil, groupId)
        end

        self.enabled = true
    end
end

function MissionPOI:disable()
    if self.target and not self.target.isDeleted then
        local configId = self.poiType and "STATUS_ICONS." .. self.poiType or "STATUS_ICONS.MISSION_TARGET"

        if self.icon then
            self.target.icon:removeStatusIconByHandle(self.icon)
        else
            self.target.icon:removeStatusIcon(configId)
        end

        self.enabled = nil
        self.icon = nil
    end
end

function MissionPOI:refresh(mission)
    local objectiveName = self.objective and self.objective._text or mission._name
    if self.target and not self.target.isDeleted then
        if self.poiType then
            self.target.icon:removeStatusIcon("STATUS_ICONS." .. self.poiType)
            self.icon = self.target.icon:addStatusIcon("STATUS_ICONS." .. self.poiType, objectiveName)
        else
            self.target.icon:removeStatusIcon("STATUS_ICONS.MISSION_TARGET")
            self.icon = self.target.icon:addStatusIcon("STATUS_ICONS.MISSION_TARGET", objectiveName)
        end
    end
end

newClass("RomeroGames.World.Missions.MissionPOI", MissionPOI)
local _missionPOIPool = newPool(MissionPOI, {initialCapacity = 8, incrementalCapacity = 8})


SaveState.defineSaveKeys(MissionObjective,
{
    {"_optional"},
    {"_status"},
    {"_enabled"},
    {"_blockName"},
    {"_text"},
    {"_textParams"},
    {"_extraInfo"},
    {"_pois", autoload = true}
})

function MissionObjective:load()
    self._mission = _curLoadingMission
    SaveState.loadDependencies(self, MissionObjective)
    self:setBlockName(self._blockName, _curLoadingMission._script)
end

function MissionObjective:init()
    self._pois = {}
end

function MissionObjective:onPoolAcquire(mission)
    self._mission = mission
    self._status = "InProgress"
end

function MissionObjective:setBlockName(blockName, script)
    self._blockName = blockName
    self._checkCompleteFn = readFunctionParam(script, blockName .. "Check")
    self._onDoneFn = readFunctionParam(script, blockName .. "Done")
end

function MissionObjective:onPoolRelease()
    self._checkCompleteFn = nil
    self._onDoneFn = nil
    self._blockName = nil
    self._mission = nil
    self._text = nil
    self._enabled = false
    for i, poi in ipairs(self._pois) do
        _missionPOIPool:release(poi)
        self._pois[i] = nil
    end
    self._status = nil
    self._textParams = nil
    self._optional = nil
    self._extraInfo = nil
end

function MissionObjective:isComplete()
    return (self._status == "Complete")
end

function MissionObjective:onMissionFocused()
    if self._enabled and not self:isComplete() then
        for i, poi in ipairs(self._pois) do
            poi:enable(self._mission)
        end
    end
end

function MissionObjective:disablePOIs()
    for i, poi in ipairs(self._pois) do
        poi:disable()
    end
end

function MissionObjective:removePOIs()
    for i, poi in ipairs(self._pois) do
        _missionPOIPool:release(poi)
        self._pois[i] = nil
    end
end

function MissionObjective:onMissionUnfocused()
    self:disablePOIs()
end

--Not used unfocused missions go straight to onMissionUnfocused
function MissionObjective:disable()
    if self._enabled then
        self:onMissionUnfocused()
        self._enabled = false
    end
end

function MissionObjective:enable()
    if not self._enabled then
        self._enabled = true
        if self._mission._focused or (self._mission._parent and self._mission._parent._focused) then
            self:onMissionFocused()
        end
    end
end

function MissionObjective:completeObjective(fail)
    if (self._status == "Complete") or (self._status == "Failure") then return end
    if fail then
        self._status = "Failure"
        local script = self._mission._script
        if script then
            self:removePOIs()
            self.target = nil
        end

        getWorld().uiData.missionNotification = true
        game:dispatchPooledEvent("onObjectivesUpdate")
    else
        self:onDone()
    end

    self._mission._missions:updateMissionLocations()
end

local function objectiveXpCallHandler(msg)
    return (msg.."\n"..getDebugTraceback())
end

function MissionObjective:onDone()
    local script = self._mission._script
    if script then
        self:removePOIs()
        if self._onDoneFn then
            local function safeCallExecuteObjectiveDone()
                script:executeFunction(self._onDoneFn)
            end
            local success, result = xpcall(safeCallExecuteObjectiveDone, objectiveXpCallHandler)
            if not success then
                logError(result)
            end
        end
        self._status = "Complete"
        self.target = nil

        -- Enable the next objective
        local mission = self._mission
        for i = 1, #mission._objectives do
            local objective = mission._objectives[i]
            if objective == self then
                local nextObjective = mission._objectives[i +1]
                if nextObjective then
                    nextObjective:enable()
                end
                break
            end
        end

        getWorld().uiData.missionNotification = true
        game:dispatchPooledEvent("onObjectivesUpdate")
    end
end

function MissionObjective:update()
    local script = self._mission and self._mission._script
    if script then
        if self._checkCompleteFn then
            self._mission._curObjective = self

            local success, result
            local r
            if __useXpcall then
                local function safeCallExecuteObjectiveCheck()
                    return script:executeFunction(self._checkCompleteFn)
                end
                success, result = xpcall(safeCallExecuteObjectiveCheck, objectiveXpCallHandler)
            else
                success, result = pcall(script.executeFunction, script, self._checkCompleteFn)
            end
            r = result

            if not success then
                logError(result)
                r = false
            end

            if r then
                self:onDone()
            end
            self._mission._curObjective = nil
        end
    end
end

newClass("RomeroGames.World.Missions.MissionObjective", MissionObjective)

local _missionObjectivePool = newPool(MissionObjective, {initialCapacity = 512, incrementalCapacity = 64})


local function clearCriticalBuildings(self)
    local criticalBuildings = self._criticalBuildings
    if criticalBuildings then
        for i = 1, #criticalBuildings do
            local criticalBuilding = self._criticalBuildings[i]
            local interface = criticalBuilding.missionCriticalBuilding
            if interface then
                interface:unregisterMission(self._scriptName)
            end
            self._criticalBuildings[i] = nil
        end
    end
end

--Side Missions: Priority 0 - 99
--Main Missions: Priority 100 - 199
--Bridging Missions: Priority 200 - 299
--Combat Missions: Priority 300 - 399
SaveState.defineSaveKeys(Mission,
{
    {"_missionId"},
    {"_iid"},
    {"_memory"},
    {"_focused"},
    {"_status"},
    {"_script", autoload = true},
    {"_rewards", autoload = true},
    {"_choiceRewards", autoload = true},
    {"_penalties", autoload = true},
    {"_objectives", autoload = true},
    {"_optionalObjectives"},
    {"_endMissionTime"},
    {"_timeLimit"},
    {"_optionalTimer"},
    {"_timeoutWarning"},
    {"_subMissions"},
    {"_optionalMission"},
    {"_parent"},
    {"_criticalActors"},
    {"_criticalBuildings"},
    {"_barkeepQuestion"},
    {"_timerHandles"},
    {"_gangstersInvolvedInMissions"},
    {"_sitdown"},
    {"_priority"},
    {"_finalBossMission"},
})

function Mission:load()
    if Mission.checkOrMarkLoaderExecuted(self) then
        return
    end
    -- print("Mission:load", self._missionId)
    self._objectivesBuffer = {}
    _curLoadingMission = self
    if self._script then
        self._script._client = self
    end
    SaveState.loadDependencies(self, Mission)
    _curLoadingMission = nil
    Mission.construct(self)
    if self._status == "InProgress" then
        self._script:registerGameEvents()
    end

    if self._gangstersInvolvedInMissions and #self._gangstersInvolvedInMissions > 0 then
        game:addEventListener("onRemoveCrewCharacter", self)
        game:addEventListener("onMoleSent", self)
        game:addEventListener("onCharacterDeath", self)
        game:addEventListener("onSetLieutenant", self)
    end
end

function Mission:init()
    self._subMissions = {}
    self._objectives = {}
    self._optionalObjectives = {}
    self._objectivesBuffer = {}
    self._rewards = {}
    self._choiceRewards = {}
    self._penalties = {}
    self._memory = {}
    self._criticalActors = {}
    self._optionalMission = false
end

function Mission:onConstruct()
    local script = self._script
    self._scriptName = script:getVar("_mission")
    self._name = script:getVar("_name")
    self._highLevel = script:getVar("_highLevel")
    self._highLevelParams = script:getVar("_highLevelParams")
    self._description = script:getVar("_description")
    self._descriptionParams = script:getVar("_descriptionParams")
    self._isSecret = script:getVar("_isSecret")
    self._isHidden = script:getVar("_isHidden")
    self._icon = script:getVar("_icon")
    self._location = script:getVar("_location")
    self._barkeepQuestion = script:getVar("_barkeepQuestion")
    self._sitdown = script:getVar("_sitdown")
    self._priority = script:getVar("_priority") or 0
    self._isCombatMission = script:getVar("_isCombatMission")
    self._removeWhenComplete = script:getVar("_removeWhenComplete")
    self._finalBossMission = script:getVar("_finalBossMission")
end

function Mission:onPoolAcquire(missions, missionId, iid)
    local script = Script.acquire(missionId, self)
    self._missions = missions
    self._missionId = missionId
    self._iid = iid
    self._script = script
    self._status = "Ready"
    self._focused = false
    Mission.construct(self)
end

function Mission:onPoolRelease()
    self._missionId = nil
    self._iid = nil
    if self._script then
        Script.release(self._script)
        self._script = nil
    end
    for i,o in ipairs(self._objectives) do
        _missionObjectivePool:release(o)
        self._objectives[i] = nil
    end
    for i, r in ipairs(self._rewards) do
        _missionOutcomePool:release(r)
        self._rewards[i] = nil
    end
    for i, r in pairs(self._choiceRewards) do
        _missionOutcomePool:release(r)
        self._choiceRewards[i] = nil
    end
    for i, r in pairs(self._penalties) do
        _missionOutcomePool:release(r)
        self._penalties[i] = nil
    end
    if self._timerHandles then
        clearTable(self._timerHandles)
    end
    if self._gangstersInvolvedInMissions then
        clearTable(self._gangstersInvolvedInMissions)
    end


    clearTable(self._objectivesBuffer)
    clearTable(self._memory)
    clearTable(self._criticalActors)
    clearCriticalBuildings(self)
    self._name = nil
    self._location = nil
    self._endMissionTime = nil
    self._timeLimit = nil
    self._timeoutWarning = nil
    self._status = nil
    self._highLevel = nil
    self._highLevelParams = nil
    self._description = nil
    self._descriptionParams = nil
    self._focused = false
    self._isSecret = nil
    self._isHidden = nil
    self._missions = nil
    self._icon = nil
    self._barkeepQuestion = nil
    self._sitdown = nil
    self._priority = nil
    self._isCombatMission = nil
    self._removeWhenComplete = nil
    self._finalBossMission = nil
end

--------------------
-- Properties
--------------------
Mission._get = {}
Mission._set = {}

function Mission._get:name()
    return self._name or (self._script and self._script:getVar("_name"))
end

function Mission._set:name(v)
    logError("Can't set name on mission!")
end

function Mission._get:description()
    return self._description or (self._script and self._script:getVar("_description"))
end

function Mission._set:description(v)
    logError("Can't set description on mission!")
end

function Mission._get:priority()
    return self._priority or 0
end

function Mission._set:priority(v)
    logError("Can't set name on mission!")
end

function Mission:returnMissionType()
    if self._priority >= 300 then
        return "COMBAT_MISSION"
    elseif (self._priority < 300) and (self._priority >= 200) then
        return "BRIDGING_MISSION"
    elseif (self._priority < 200) and (self._priority >= 100) then
        return "MAIN_MISSION"
    else
        return "SIDE_MISSION"
    end
end

--Combat missions (300-399)
function Mission:isCombatMission()
    return self._priority >= 300
end

--Empire missions (200-299)
function Mission:isBridgingMission()
    return (self._priority < 300) and (self._priority >= 200)
end

--Boss, CMA, Hoffman missions(100-199)
function Mission:isMainMission()
    return (self._priority < 200) and (self._priority >= 100)
end

--Empire, alcohol, citizen, crew missions (0-99)
function Mission:isSideMission()
    return self._priority < 100
end

--Main and side missions (Excluding bridging)
function Mission:isStoryMission()
    return self._priority < 200
end

function Mission:isCompleted()
    return (self._status == "Failure") or (self._status == "Complete") or (self._status == "Success")
end

function Mission:inProgress()
    return (self._status == "InProgress") or (self._status == "Ready")
end

-- ----------------------
-- STARTING MISSION STAGE
-- ----------------------
function Mission:onCreate(...)
    local script = self._script

    local n = select("#",...)
    for i = 1, n, 2 do
        local k = select(i, ...)
        local v = select(i + 1, ...)

        if k == nil or v == nil then
            logError("Invalid mission parameters for key:", k, "supplied to " .. tostring(self._missionId) .. ".")
            break
        end

        script:setVar(k, v)
        script:persistVar(k)

        -- Handle target actor as a special case
        if k == "thisActor" then
            -- TODO: Possibly check for reassignment
            script:registerObjectEvents(v)
        end
    end
    script:registerGameEvents()

    local function safeCallExecuteMissionCreate()
        script:executeBlock("onMissionCreate")
    end

    local success, result = xpcall(safeCallExecuteMissionCreate, objectiveXpCallHandler)
    if not success then
        logError(result)
    end
end

function Mission:onActorDelete(e)
    -- Remove the actor as a POI if they are one
    for _, objective in next, self._objectives do
        for i, poi in next, objective._pois do
            if poi.target == e.target then
                table.remove(objective._pois, i)
                _missionPOIPool:release(poi)
            end
        end
    end
end

function Mission:onTest(testFunctionName, ...)
    local script = self._script
    local block = script:getBlock(testFunctionName)
    if not block then
        logError(string.format("Unable to test mission: %s Could not find %s", tostring(self._missionId), tostring(testFunctionName)))
        return
    end
    self._status = "InProgress"
    script:executeBlock(block)
end

function Mission:onStart()
    local script = self._script
    local block = script:getBlock("onMissionStart")
    if not block then
        logError(string.format("Unable to start mission: %s Could not find onMissionStart", tostring(self._missionId)))
        return
    end
    self._status = "InProgress"
    script:executeBlock(block)
    --Boss mission priorities
    local priority = self._parent and self._parent._priority or self._priority
    if priority == 100 then
        getWorld().setFocusedMission(self._parent or self)
    end
end

function Mission:hotload()
    self._missions:resetMission(self._script:getId())
end

-- ----------------------
-- IMPL
-- ----------------------
local function getParentValueImpl(self, key)
    return self._parent and self._parent:getValue(key) or nil
end

local function setParentValueImpl(self, key, value)
    if not self._parent then
        return
    end

    self._parent:setValue(key, value)
end

local function getSubMissionValueImpl(self, subMissionId, key)
    if not self._subMissions or (#self._subMissions == 0) then
        return
    end

    if self:isCompleted() then
        return
    end

    for i = 1, #self._subMissions do
        local subMission = self._subMissions[i]
        if subMission._scriptName == subMissionId then
            if subMission:isCompleted() then
                return
            end
            return subMission:getValue(key) or nil
        end
    end

    logError("Failed to get value on submission", subMissionId)
    return nil
end

local function setSubMissionValueImpl(self, subMissionId, key, value)
    if not self._subMissions or (#self._subMissions == 0) then
        return
    end

    if self:isCompleted() then
        return
    end

    for i = 1, #self._subMissions do
        local subMission = self._subMissions[i]
        if subMission._scriptName == subMissionId then
            if subMission:isCompleted() then
                logError("Attempting to set value on completed submission", subMissionId)
                return
            end

            subMission:setValue(key, value)
            return
        end
    end

    logError("Failed to set value on submission", subMissionId)
end

local function setCriticalActorsImpl(self, actors)
    clearTable(self._criticalActors)
    self._criticalActors = actors
end

local function addTimerHandleImpl(self, handle)
    if self._timerHandles then
        self._timerHandles[#self._timerHandles + 1] = handle
    else
        self._timerHandles = {}
        self._timerHandles[1] = handle
    end
end

local function addGangsterToMissionImpl(self, gangster, unhireable)
    if gangster.involvedInMission and gangster.involvedInMission ~= self._name then
        logError("adding a gangster that's already involved in mission:", gangster.involvedInMission, "to ", self._name, ". Is this intended.")
    end

    if self._gangstersInvolvedInMissions then
        self._gangstersInvolvedInMissions[#self._gangstersInvolvedInMissions + 1] = gangster
    else
        self._gangstersInvolvedInMissions = {}
        self._gangstersInvolvedInMissions[1] = gangster

        game:addEventListener("onRemoveCrewCharacter", self)
        game:addEventListener("onMoleSent", self)
        game:addEventListener("onCharacterDeath", self)
        game:addEventListener("onSetLieutenant", self)
    end
    gangster.involvedInMission = self._name
    if unhireable then
        gangster:addTag("UnhireableDueToMission")
    end

    if not gangster:hasTag("NoInjuryChance") then
        gangster:addTag("NoInjuryChance")
    end
end

local function removeGangsterFromMissionImpl(self, gangster)
    if self._gangstersInvolvedInMissions then
        for i = #self._gangstersInvolvedInMissions, 1, -1 do
            if self._gangstersInvolvedInMissions[i] == gangster then
                self._gangstersInvolvedInMissions[i] = nil
                break
            end
        end

    end

    if gangster and not gangster.isDeleted then
        gangster.involvedInMission = nil
        if gangster:hasTag("UnhireableDueToMission") then
            gangster:removeTag("UnhireableDueToMission")
        end
        
        if gangster:hasTag("NoInjuryChance") then
            gangster:removeTag("NoInjuryChance")
        end
    end

    if self._gangstersInvolvedInMissions and #self._gangstersInvolvedInMissions == 0 then
        game:removeEventListener("onRemoveCrewCharacter", self)
        game:removeEventListener("onMoleSent", self)
        game:removeEventListener("onCharacterDeath", self)
        game:removeEventListener("onSetLieutenant", self)
    end

end

local function setNameImpl(self, name)
    self._name = name
    self._script:setVar("_name", name)
    self._script:persistVar("_name")
end

local function setLocationImpl(self, location)
    self._location = location
    self._script:setVar("_location", location)
    self._script:persistVar("_location")
end

local function setHighLevelImpl(self, text)
    local params
    text, params = readTextParam(text)
    self._highLevel = text
    self._highLevelParams = params
    self._script:setVar("_highLevel", text)
    self._script:persistVar("_highLevel")
    self._script:setVar("_highLevelParams", params)
    self._script:persistVar("_highLevelParams")
end

local function setIconImpl(self, icon)
    self._icon = icon
    self._script:setVar("_icon", icon)
    self._script:persistVar("_icon")
end

local function setDescriptionImpl(self, text)
    local params
    text, params = readTextParam(text)
    self._description = text
    self._descriptionParams = params
    self._script:setVar("_description", text)
    self._script:persistVar("_description")
    self._script:setVar("_descriptionParams", params)
    self._script:persistVar("_descriptionParams")
end

local function defineMissionImpl(self, defs)
    if defs.name then
        setNameImpl(self, defs.name)
    end
    if defs.location then
        setLocationImpl(self, defs.location)
    end
    if defs.highLevel then
        setHighLevelImpl(self, defs.highLevel)
    end
    if defs.icon then
        setIconImpl(self, defs.icon)
    end
    if defs.description then
        setDescriptionImpl(self, defs.description)
    end
end

local function addPOIImpl(self, poiTarget, poiType, objectiveName, isSubmission)
    local curObjective = self._curObjective
    if objectiveName then
        local objectives = {}
        if isSubmission then
            for i = 1, #self._subMissions do
                local subMission = self._subMissions[i]
                for j = 1, #subMission._objectives do
                    objectives[#objectives + 1] =  subMission._objectives[j]
                end
            end
        else
            objectives = self._objectives
        end

        for _, o in next, objectives do
            if o._blockName and o._blockName == objectiveName then
                curObjective = o
                break
            end
        end
    end
    local poi = _missionPOIPool:acquire(curObjective, poiType)
    poi.target = poiTarget
    curObjective._pois[#curObjective._pois + 1] = poi

    --objective is enabled once it's added
    if (self._parent and self._parent._focused or self._focused)  and curObjective._enabled and not curObjective:isComplete() then
        poi:enable(self)
    end
    poiTarget:addEventListener("onActorDelete", self)

    self._missions:updateMissionLocations()
end

local function removePOIImpl(self, target, objectiveName, isSubmission)
    local curObjective = self._curObjective
    if objectiveName then
        local objectives = {}
        if isSubmission then
            for i = 1, #self._subMissions do
                local subMission = self._subMissions[i]
                for j = 1, #subMission._objectives do
                    objectives[#objectives + 1] =  subMission._objectives[j]
                end
            end
        else
            objectives = self._objectives
        end

        for _, o in next, objectives do
            if o._blockName and o._blockName == objectiveName then
                curObjective = o
                break
            end
        end
    end

    if curObjective then
        local pois = curObjective._pois
        for j, p in next, pois do
            if p.target == target then
                _missionPOIPool:release(p)
                table.remove(pois, j)
                break
            end
        end
    end
end

local function checkForPOIImpl(self, poiTarget, objectiveName)
    local curObjective = self._curObjective
    if objectiveName then
        local objectives = self._objectives
        for _, o in next, objectives do
            if o._blockName and o._blockName == objectiveName then
                curObjective = o
                break
            end
        end
    end

    local pois = curObjective and curObjective._pois
    if not pois or (next(pois) == nil) then
        return false
    end

    if poiTarget then
        for j, p in next, pois do
            if p.target == poiTarget then 
                return true
            end
        end
        return false
    end
    return true
end

local function checkCompleteImpl(self, checkCompleteFn)
    logError("onCheck is deprecated")
end

local function addSubMissionImpl(self, missionName, notify, ...)
    self:addSubMission(missionName, notify, ...)
end

local function failMissionImpl( self, text )
    if self._status == "Failure" then return end
    if getWorld().inCombat() then
        self:markForFail(text)
    else
        self:complete(false, text, nil)
    end
end

local function completeMissionImpl( self, text )
    if self._status == "Failure" then return end
    self:complete(true, text)
end

local function addObjectiveImpl(self, objectiveName, optional, extraInfo)
    -- if self._enabled == nil then self._enabled = true end
    local script = self._script
    local objectiveFn = readFunctionParam(script, objectiveName)
    local objective = self:addObjective(objectiveFn, optional)
    if not objective then
        failMissionImpl(self, "$ParentMissionFailed")
        return
    end
    objective._optional = optional
    objective._extraInfo = extraInfo
    objective._text = objective._text or ""
    objective:setBlockName(objectiveName, script)

    if self._parent and self._parent._focused then
        getWorld().setFocusedMission(self._parent)
    end
end

local function addOptionalObjectiveImpl(self, objectiveName)
    addObjectiveImpl(self, objectiveName, true)
end

local function addInfoObjectiveImpl(self, objectiveName)
    addObjectiveImpl(self, objectiveName, false, true)
end

local function failObjectiveImpl(self, objectiveName)
    if objectiveName then
        local objectives = self._objectives
        for _, o in next, objectives do
            if o._blockName and o._blockName == objectiveName then
                o:completeObjective(true)
                break
            end
        end
    end
end

local function defineObjectiveImpl(self, defs)
    self._curObjective._text = defs.description
end

local function updateObjectiveNameImpl(self, objectiveName, desc, isSubmission)
    local objectives = self._objectives
    if isSubmission then
        for i = 1, #self._subMissions do
            local subMission = self._subMissions[i]
            for j = 1, #subMission._objectives do
                objectives[#objectives + 1] =  subMission._objectives[j]
            end
        end
    end

    for _, o in next, objectives do
        if o._blockName and o._blockName == objectiveName then
            o._text = desc
            if( self._parent and self._parent._focused or self._focused) and o._enabled and not o:isComplete() then
                local pois = o._pois
                for j, p in next, pois do
                    if p then
                        p:refresh(self)
                    end
                end
            end
            game:dispatchPooledEvent("onMissionsUpdate")
            break
        end
    end

    self._missions:updateMissionLocations()
end

local function markSubMissionAsOptionalImpl(self)
    self._optionalMission = true
end

local function onDoneImpl(self, onDoneFn)
    logError("onDone is deprecated")
end

local function modifierRewardImpl(self, modifierId, factionId, locationId, precinctId, actor, alreadyGiven)
    local reward = _missionOutcomePool:acquire()
    reward:addModifier(modifierId, factionId, locationId, precinctId, actor)
    self:addReward(reward, nil, alreadyGiven)
end

local function cashRewardImpl(self, amount, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward.cash = amount or 0
    self:addReward(reward, isChoice, alreadyGiven)
end

local function notorietyRewardImpl(self, amount, reason, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward:addNotoriety(amount, reason)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function alcoholRewardImpl(self, quality, amount, alreadyGiven, isChoice)
    quality = quality or 3 -- Default to Rack quality
    amount = amount or 1
    local reward = _missionOutcomePool:acquire()
    reward:addAlcohol(quality, amount)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function factionRatingChangeImpl(self, factionId, modifierId, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    local faction = getWorld().getFaction(factionId)
    local icon = faction.icon
    reward:addFactionRatingChange(faction, modifierId, icon)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function factionRatingDecreaseImpl(self, factionId, modifierId, alreadyGiven, isChoice)
    local penalty = _missionOutcomePool:acquire()
    local faction = getWorld().getFaction(factionId)
    local icon = faction.icon
    penalty:addFactionRatingChange(faction, modifierId, icon)
    self:addPenalty(penalty, isChoice, alreadyGiven)
end

local function productionRewardImpl(self, building, modifier, reason, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward:addProductionIncrease(building, modifier, reason)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function upgradeRewardImpl(self, building, upgradeType, amount, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward:addUpgrade(building, upgradeType, amount)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function racketRewardImpl(self, building, racketType, name, alreadyGiven, isChoice)
    if not building then
        return
    end
    local reward = _missionOutcomePool:acquire()
    reward:addRacket(building, racketType, name)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function honorRewardImpl(self, faction, effectId, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward:addHonor(faction, effectId)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function statRewardImpl(self, stat, amount, name, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward:addStat(stat, amount, name)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function traitRewardImpl(self, trait, char, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    char = char or getWorld().player
    reward:addTrait(trait, char)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function improvementRewardImpl(self, configId, precinctId, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward:addImprovement(configId, precinctId)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function customRewardImpl(self, text, customRewardFn, icon, alreadyGiven, isChoice)
    local reward = _missionOutcomePool:acquire()
    reward:addCustomReward(text, customRewardFn, icon)

    self:addReward(reward, isChoice, alreadyGiven)
end

local function customPenaltyImpl(self, name, desc, penaltyfn)
    local script = self._script
    local penalty = _missionOutcomePool:acquire()
    penalty.customRewardFn = readFunctionParam(script, penaltyfn)
    penalty.customRewardFnName = script:getBlockName(penalty.customRewardFn)
    if not penalty.customRewardFnName then
        logError("Invalid custom reward function in mission: " .. script._configId .. " ... must be a block function!")
    end
    local nameParams
    name, nameParams = readTextParam(name)
    local descParams
    desc, descParams = readTextParam(desc)
    penalty.customName = name
    penalty.customNameParams = nameParams
    penalty.customDescription = desc
    penalty.customDescriptionParams = descParams
    self:addPenalty(penalty)
end

local function itemsRewardImpl(self, configId, amount, alreadyGiven, isChoice)
    amount = amount or 1
    local reward = _missionOutcomePool:acquire()
    reward:addItem(configId, amount)
    self:addReward(reward, isChoice, alreadyGiven)
end

local function textImpl(self, text)
    logError("text is deprecated")
end

local function timeLimitImpl(self, duration, units)
    self:setTimeLimit(duration, units)
end

local function optionalTimeLimitImpl(self, duration, units)
    self:setOptionalTimeLimit(duration, units)
end

local function removeTimeLimitImpl(self)
    self:removeTimeLimit()
end

local function timeoutWarningImpl(self, duration, units)
    self:setTimeoutWarning(duration, units)
end

local function addCriticalBuildingImpl(self, building)
    local missionCritical = building:getOrAddState("MissionCriticalBuilding")
    missionCritical:registerMission(self._scriptName)
    local criticalBuildings = self._criticalBuildings
    if not criticalBuildings then
        self._criticalBuildings = {}
        criticalBuildings = self._criticalBuildings
    end
    criticalBuildings[#criticalBuildings + 1] = building
end

local function removeCriticalBuildingImpl(self, building)
    local missionCritical = building:getState("MissionCriticalBuilding")
    if missionCritical then
        missionCritical:unregisterMission(self._scriptName)
    end

    local criticalBuildings = self._criticalBuildings
    if criticalBuildings then
        for i = #criticalBuildings, 1, -1 do
            local criticalBuilding = criticalBuildings[i]
            if building == criticalBuilding then
                table.remove(criticalBuildings, i)
                break
            end
        end
    end
end

local scriptKeys =
{
    setName = function(self)
        return setNameImpl
    end,

    setLocation = function(self)
        return setLocationImpl
    end,

    setHighLevel = function(self)
        return setHighLevelImpl
    end,

    setIcon = function(self)
        return setIconImpl
    end,

    setDescription = function(self)
        return setDescriptionImpl
    end,

    defineMission = function(self)
        return defineMissionImpl
    end,

    addPOI = function(self)
        return addPOIImpl
    end,

    removePOI = function(self)
        return removePOIImpl
    end,

    checkForPOI = function(self)
        return checkForPOIImpl
    end,

    onCheck = function(self)
        return checkCompleteImpl
    end,

    addSubMission = function(self)
        return addSubMissionImpl
    end,

    markSubMissionAsOptional = function(self)
        return markSubMissionAsOptionalImpl
    end,

    addObjective = function(self)
        return addObjectiveImpl
    end,

    addOptionalObjective = function(self)
        return addOptionalObjectiveImpl
    end,

    addInfoObjective = function(self)
        return addInfoObjectiveImpl
    end,

    failObjective = function(self)
        return failObjectiveImpl
    end,

    defineObjective = function(self)
        return defineObjectiveImpl
    end,

    updateObjectiveName = function(self)
        return updateObjectiveNameImpl
    end,

    failMission = function(self)
        return failMissionImpl
    end,

    completeMission = function(self)
        return completeMissionImpl
    end,

    onDone = function(self)
        return onDoneImpl
    end,

    addModifierReward = function(self)
        return modifierRewardImpl
    end,

    addCashReward = function(self)
        return cashRewardImpl
    end,

    addNotorietyReward = function(self)
        return notorietyRewardImpl
    end,

    addFactionRatingReward = function(self)
        return factionRatingChangeImpl
    end,

    addFactionRatingPenalty = function(self)
        return factionRatingDecreaseImpl
    end,

    addCustomReward = function(self)
        return customRewardImpl
    end,

    addAlcoholReward = function(self)
        return alcoholRewardImpl
    end,

    addProductionReward = function(self)
        return productionRewardImpl
    end,

    addRacketReward = function(self)
        return racketRewardImpl
    end,

    addUpgradeReward = function(self)
        return upgradeRewardImpl
    end,

    addHonorReward = function(self)
        return honorRewardImpl
    end,

    addStatReward = function(self)
        return statRewardImpl
    end,

    addTraitReward = function(self)
        return traitRewardImpl
    end,

    addImprovementReward = function(self)
        return improvementRewardImpl
    end,

    addCustomPenalty = function(self)
        return customPenaltyImpl
    end,

    memory = function(self)
        return self._memory, true
    end,

    addItemsReward = function(self)
        return itemsRewardImpl
    end,

    text = function(self)
        return textImpl
    end,

    setTimeLimit = function(self)
        return timeLimitImpl
    end,

    setOptionalTimeLimit = function(self)
        return optionalTimeLimitImpl
    end,

    removeTimeLimit = function(self)
        return removeTimeLimitImpl
    end,

    setTimeoutWarning = function(self)
        return timeoutWarningImpl
    end,

    getParentValue = function(self)
        return getParentValueImpl
    end,

    setParentValue = function(self)
        return setParentValueImpl
    end,

    getSubMissionValue = function(self)
        return getSubMissionValueImpl
    end,

    setSubMissionValue = function(self)
        return setSubMissionValueImpl
    end,

    setCriticalActors = function(self)
        return setCriticalActorsImpl
    end,

    addCriticalBuilding = function(self)
        return addCriticalBuildingImpl
    end,

    removeCriticalBuilding = function(self)
        return removeCriticalBuildingImpl
    end,

    addTimerHandle = function(self)
        return addTimerHandleImpl
    end,

    addGangsterToMission = function(self)
        return addGangsterToMissionImpl
    end,

    removeGangsterFromMission = function(self)
        return removeGangsterFromMissionImpl
    end,
}

function Mission:getScriptValue(k)
    local fn = scriptKeys[k]
    if fn then
        local v, cache = fn(self)
        return v, cache
    end
end

function Mission:getValue(k)
    return self._script:getVar(k)
end

function Mission:setValue(k, v)
    return self._script:setVar(k, v)
end

function Mission:addSubMission(missionId, notify, ...)
    local parent = self
    if self._parent then
        parent = self._parent
    end

    local mission = getWorld().addSubMission(missionId, notify, parent, ...)
    parent._subMissions[#parent._subMissions + 1] = mission
    self._missions:updateMissionLocations()
end

--MISSIONTODO: Make this function local
function Mission:addObjective(objective, optional)
    local newObjective = _missionObjectivePool:acquire(self)
    newObjective._optional = not not optional
    if not not optional then
        self._optionalObjectives[#self._optionalObjectives + 1 ] = newObjective
    end
    self._objectives[#self._objectives + 1] = newObjective
    self._curObjective = newObjective

    local function safeCallExecuteObjective()
        self._script:executeFunction(objective)
    end
    local success, result = xpcall(safeCallExecuteObjective, objectiveXpCallHandler)
    self._curObjective = nil
    if not success then
        logError(result)
        for i = 1, #self._objectives do
            if self._objectives[i] == newObjective then
                table.remove(self._objectives, i)
                break
            end
        end
        for i = 1, #self._optionalObjectives do
            if self._optionalObjectives[i] == newObjective then
                table.remove(self._optionalObjectives, i)
                break
            end
        end
        return
    end

    newObjective:enable()
    getWorld().uiData.missionNotification = true
    return newObjective
end

function Mission:addReward(reward, isChoice, alreadyGiven)
    if alreadyGiven then
        reward.alreadyGiven = true
    end

    if isChoice then
        self._choiceRewards[#self._choiceRewards + 1] = reward
    else
        self._rewards[#self._rewards + 1] = reward
    end
    --Add rewards to the parent mission so they'll show correctly in journal and on mission resolution screen
    if self._parent then
        self._parent:addReward(reward, isChoice, alreadyGiven)
    end
end

function Mission:addPenalty(penalty)
    self._penalties[#self._penalties + 1] = penalty
end

function Mission:setTimeLimit(duration, units)
    local mission = self._parent or self
    local durationSecs = TimeUtils.durationToSecs(duration, units) * 100
    mission._endMissionTime = clientTimeWorldTime + durationSecs
    mission._timeLimit = durationSecs
    mission._optionalTimer = true  -- MEGAMOD: Make all timers advisory, not punishing
end

function Mission:setOptionalTimeLimit(duration, units)
    local mission = self._parent or self
    units = units or "Days"
    local durationSecs = TimeUtils.durationToSecs(duration, units)
    mission._endMissionTime = clientTimeWorldTime + durationSecs
    mission._timeLimit = durationSecs
    mission._optionalTimer = true
end

function Mission:removeTimeLimit()
    local mission = self._parent or self
    mission._endMissionTime = nil
    mission._timeLimit = nil
    mission._optionalTimer = nil
end

function Mission:setTimeoutWarning(duration, units)
    local mission = self._parent or self
    local durationSecs = TimeUtils.durationToSecs(duration, units)
    self._timeoutWarning = clientTimeWorldTime + durationSecs
end

function Mission:markForFail(text)
    self.markedForFailReason = text
    game:addEventListener("onCombatResolved", self)
end

-- ----------------------
-- EVENTS
-- ----------------------
function Mission:onCombatResolved()
    self:complete(false, self.markedForFailReason, nil)
    game:removeEventListener("onCombatResolved", self)
end

local function _checkIfGangsterInUse(gangstersInvolvedInMissions, gangsterInvalidated)
    if gangstersInvolvedInMissions then
        for i = 1, #gangstersInvolvedInMissions do
            if gangstersInvolvedInMissions[i] == gangsterInvalidated then
                return true
            end
        end
    end

    return false
end

local function removeGangster(self, reason, gangster, failString)
    removeGangsterFromMissionImpl(self, gangster)
    local script = self._script
    if script then
        script:executeBlock("onGangsterInvalidated", reason, gangster, failString)
    end
end

function Mission:onMoleSent(e)
    local mole = e.mole
    if _checkIfGangsterInUse(self._gangstersInvolvedInMissions, mole) then
        removeGangster(self, "Mole", mole, "$MissionRPCMole")
    end
end

function Mission:onCharacterDeath(e)
    local deadGangster = e.target

    if _checkIfGangsterInUse(self._gangstersInvolvedInMissions, deadGangster) then
        removeGangster(self, "Died", deadGangster, "$Missions_CriticalActorDied")
    end
end

function Mission:onRemoveCrewCharacter(e)
    local removedRPC = e.character

    if _checkIfGangsterInUse(self._gangstersInvolvedInMissions, removedRPC) then
        removeGangster(self, e.reason, removedRPC, "$MissionRPCFired")
    end
end

function Mission:onSetLieutenant(e)
    local lieutenant = e.rpc

    if _checkIfGangsterInUse(self._gangstersInvolvedInMissions, lieutenant) then
        removeGangster(self, e.reason, lieutenant, "$MissionRPCMole") --writingtodo: replace this with more accurate string
    end
end


-- ------------------------
-- COMPLETING MISSION STAGE
-- ------------------------

--Cleans up any lingering vars or settings from mission on fail or success
local function _missionCleanup(self)
    --Clear any critical actors and buildings
    clearTable(self._criticalActors)
    clearCriticalBuildings(self)

    --Clear any timers that are still going
    if self._timerHandles then
        for i = 1, #self._timerHandles do
            local handle = self._timerHandles[i]
            if game:getTimeCallbackFromIid(handle) then
                game:cancelTimeCallback(handle)
            end
        end
        clearTable(self._timerHandles)
        self._timerHandles = nil
    end

    --Clear any gangsters that we set to be involved in the mission
    if self._gangstersInvolvedInMissions then
        for i = #self._gangstersInvolvedInMissions, 1, -1 do
            local gangster = self._gangstersInvolvedInMissions[i]
            if gangster and not gangster.isDeleted then
                removeGangsterFromMissionImpl(self, gangster)
            end
        end

        if self._gangstersInvolvedInMissions then
            clearTable(self._gangstersInvolvedInMissions)
            self._gangstersInvolvedInMissions = nil
        end

        game:removeEventListener("onRemoveCrewCharacter", self)
        game:removeEventListener("onMoleSent", self)
        game:removeEventListener("onCharacterDeath", self)
        game:removeEventListener("onSetLieutenant", self)
    end

    if self._barkeepQuestion then
        local barkeepMissionGenerator = getWorld().barkeepMissionGenerator
        barkeepMissionGenerator:removeBarkeepQuestion(self._scriptName)
    end
end

local _removePersistVarIgnoreKeys =
{
    _name = true,
    _description = true,
    _descriptionParams = true,
}
function Mission:complete(succeeded, reasonText, reasonParams)
    if self._status == "Complete" or self._status == "Success" or self._status == "Failure" then
        return
    end

    --Set this fact before the status is updated
    if succeeded then
        if self._finalBossMission then
            getWorld().facts.BossMissionCompleted = true
            game:dispatchPooledEvent("onBossMissionChainCompleted", "success", true)
        end
    else
        if self._priority == 100 then
            getWorld().facts.BossMissionCompleted = true
            game:dispatchPooledEvent("onBossMissionChainCompleted")
        end
    end

    self._reasonText = reasonText
    self._reasonParams = reasonParams
    self._status = succeeded and "Success" or "Failure"

    _missionCleanup(self)
    -- Check default notoriety reward
    local useDefaultNotoriety = not self._parent -- Don't add a default notoriety reward for submissions.
    for i = 1, #self._rewards do
        local reward = self._rewards[i]
        if reward.notoriety then
            useDefaultNotoriety = false
            break
        end
    end
    if useDefaultNotoriety and not self._isCombatMission then
        notorietyRewardImpl(self, 10, {"$Mission_NotorietyReward", self._name}, false) --$ {0} mission.
    end
    local script = self._script
    local block
    if self._status == "Failure" then
        block = self._script and self._script:getBlock("onMissionFail")
        for i = 1, #self._rewards do
            local reward = self._rewards[i]
            if reward.itemReward then
                reward:releaseItem()
            end
        end
    elseif self._status == "Success" then
        block = self._script and self._script:getBlock("onMissionSuccess")
    end

    if block then
        script:executeBlock(block)
    end

    for i = 1, #self._objectives do
        local objective = self._objectives[i]
        objective:removePOIs()
    end

    self._missions:updateMissionLocations()

    if self._status ~= "Success" then
        -- If submission fails then fail the parent.
        if self._parent and not self._optionalMission then
            local reason = reasonText or "$SubMissionFailed" --$ Sub-mission failed
            self._parent:complete(false, reasonText, reasonParams)
        end

        -- If parent mission fails then fail all submissions
        for i=1, #self._subMissions do
            self._subMissions[i]:complete(false, "$ParentMissionFailed") --$ Parent mission failed
        end
    end

    --marked unfinished objectives(optional) as failed
    for i = 1, #self._objectives do
        if self._objectives[i]._status ~= "Complete" then
            self._objectives[i]._status = "Failure"
        end
    end

    self._script:unregisterGameEvents()

    self._missions:onMissionComplete(self, self._status)

    --Auto accept rewards in case there's an error with the event displaying
    if self._status == "Success" then
        self:acceptRewards()
    end

    -- Don't raise the onMissionComplete event for combat and hidden missions.
    if not self._isCombatMission and not self._isHidden then
        -- Raise a game event that a mission is complete
        game:dispatchPooledEvent("onMissionComplete", "mission", self, "status", self._status)
    end
    self._script:removePersistVarReferences(_removePersistVarIgnoreKeys)

    if self._removeWhenComplete then
        self._missions:removeMission(self._missionId, self._iid)
    end
end

local function acceptReward(self, reward)
    if not reward.alreadyGiven then
        if reward.cash then
            getWorld().playerFaction.cash:add(reward.cash, "CASH.MISSION_REWARD")
        end
        if reward.modifier then
            local m = reward.modifier
            getWorld().applyModifier(m.modifierId, m.factionId, m.locationId, m.precinctId, m.actor)
        end
        if reward.customRewardFn then
            local script = self._script
            script:executeFunction(reward.customRewardFn)
        end
        if reward.customReward then
            if reward.customReward.customFn then
                local script = self._script
                script:executeFunction(reward.customRewardFn)
            end
        end
        if reward.itemReward then
            for i = 1, reward.itemReward.amount do
                getWorld().playerFaction.inventory:addItem(reward.itemReward.item)
            end
        end
        if reward.factionRatingChange then
            reward.factionRatingChange.faction.rating:applyEffect(getWorld().playerFaction, reward.factionRatingChange.modifierId)
        end
        if reward.alcohol then
            local quality = reward.alcohol.quality
            local amount = reward.alcohol.amount
            getWorldLibs().addAlcoholToFaction(getWorld().playerFaction, amount, quality)
        end
        if reward.notoriety then
            getWorld().player:addNotoriety(reward.notoriety.amount, reward.notoriety.reason)
        end
        if reward.productionIncrease then
            local mod = (reward.productionIncrease.building.producer.amount/100) * reward.productionIncrease.modifier
            reward.productionIncrease.building.producer:addProductionModifier(reward.productionIncrease.reason, mod)
        end
        if reward.upgrade then
            local rewardBuilding = reward.upgrade.building
            local upgradeType = reward.upgrade.type
            local upgradeAmount = reward.upgrade.amount or 1
            if type(rewardBuilding) == "string" then
                local buildings
                if rewardBuilding == "ALL" then
                    buildings = getWorld().playerFaction.buildings
                else
                    buildings = {}
                    local racketType =  "BUILDING_DATA."..reward.upgrade.building
                    for i = 1, #getWorld().playerFaction.buildings do
                        local building = getWorld().playerFaction.buildings[i]
                        if building.buildingData and building.buildingData.id == racketType then
                            buildings[#buildings + 1] = building
                        end
                    end
                end
                for i = 1, #buildings do
                    local racket = buildings[i]
                    if upgradeType then
                        local upgrade = racket.upgrades:getUpgradeOfType(upgradeType)
                        if upgrade then
                            upgrade:upgrade(upgradeAmount)
                        end
                    else
                        for _, upgrade in next, racket.upgrades.upgradeInterfaces do
                            upgrade:upgrade(upgradeAmount)
                        end
                    end
                end
            else
                local racket = reward.upgrade.building
                if upgradeType then
                    local upgrade = racket.upgrades:getUpgradeOfType(upgradeType)
                    if upgrade then
                        upgrade:upgrade(upgradeAmount)
                    end
                else
                    for _, upgrade in next, racket.upgrades.upgradeInterfaces do
                        upgrade:upgrade(upgradeAmount)
                    end
                end
            end
        end
        if reward.racket or reward.racketReward then
            local racket = reward.racketReward and reward.racketReward.racket or reward.racket
            racket.faction:changeBuildingOwner(racket, getWorld().playerFaction, "Gifted")

            local racketType = reward.racketReward and reward.racketReward.racketType
            local currentRacketType = racket.buildingData and racket.buildingData.id
            if racketType and racketType ~= currentRacketType then
                local name = reward.racketReward.name or getWorld().pickRandomRacketName(reward.racketReward.racketType)
                racket:getOwnerFaction():changeRacketType(racket, reward.racketReward.racketType, name)
                reward.racketReward.name = name
            end
        end
        if reward.honor then
            getWorld().playerFaction.honor:applyEffect(reward.honor.faction, reward.honor.effectId)
        end
        if reward.stat then
            local skills = getWorld().player.skills
            local current = skills:get(reward.stat.stat)
            skills:set(reward.stat.stat, current + reward.stat.amount)
        end
        if reward.trait then
            local p = reward.trait.character
            if not p:hasState(reward.trait.trait) then
                return p:addState(reward.trait.trait)
            end
        end
        if reward.improvementReward then
            local precinctId = reward.improvementReward.precinctId
            local precinct = precinctId and getWorld().getPrecinct(precinctId)

            if precinct then
                precinct:addImprovement(reward.improvementReward.configId)
            end
        end
        --Mark as given so parent doesn't give it again
        if self._parent then
            reward.alreadyGiven = true
        end
    end
end

local function acceptPenalty(self, penalty)
    if penalty.customRewardFn then
        local script = self._script
        script:executeFunction(penalty.customRewardFn)
    end
    if penalty.factionRatingChange and penalty.factionRatingChange.faction then
        penalty.factionRatingChange.faction.rating:applyEffect(getWorld().playerFaction, penalty.factionRatingChange.modifierId)
    end
end

function Mission:acceptRewards(choiceNum)
    for i = 1, #self._rewards do
        local reward = self._rewards[i]
        local optionalObjective = nil
        for j=1, #self._objectives do
            local obj = self._objectives[j]
            -- A reward with objectiveName is an optional objective/reward
            if obj._blockName == reward.objectiveName then
                optionalObjective = obj
                break
            end
        end
        if not optionalObjective or optionalObjective._status == "Complete" then
            acceptReward(self, reward)
        end
    end
    if choiceNum and self._choiceRewards[choiceNum] then
        local reward = self._choiceRewards[choiceNum]
        acceptReward(self, reward)
    end
    return true
end

function Mission:acceptPenalties()
    for i = 1, #self._penalties do
        local penalty = self._penalties[i]
        acceptPenalty(self, penalty)
    end
end

function Mission:focus()
    if self._isHidden then return end

    self._focused = true

    local missionsToFocus = #self._subMissions > 0 and self._subMissions or {self}
    for _, mission in next, missionsToFocus do
        for _, objective in next, mission._objectives do
            objective:onMissionFocused()
        end
    end

    game:dispatchPooledEvent("onMissionFocused", "mission", self)
end

function Mission:unfocus()
    self._focused = false

    local missionsToUnfocus = #self._subMissions > 0 and self._subMissions or {self}
    for _, mission in next, missionsToUnfocus do
        for _, objective in next, mission._objectives do
            objective:onMissionUnfocused()
        end
    end
end

function Mission:update()
    -- Update each ongoing objective (clone to protect against re-entrancy)
    clearTable(self._objectivesBuffer)
    -- Early out if mission has already been completed
    if (self._status == "Success") or (self._status == "Failure") then
        return
    end

    for i = 1, #self._objectives do
        self._objectivesBuffer[i] = self._objectives[i]
    end

    for i = 1, #self._objectivesBuffer do
        local objective = self._objectivesBuffer[i]
        if objective._status == "InProgress" then
            objective:update()
        end
    end

    for i = 1, #self._criticalActors do
        local actor = self._criticalActors[i]
        if actor and actor:isA(Character) then
            -- Need to decide what to do with buildings
            if actor:isDead() then
                self._script:executeBlock("onCriticalActorDeath", actor)
            end
        end
    end

    -- Rescan objectives to see if all are complete (new ones may have just been added)
    local inProgress = false
    for i = 1, #self._objectives do
        local objective = self._objectives[i]
        if objective._status == "InProgress" and not objective._optional then
            inProgress = true
            break
        end
    end

    for i = 1, #self._subMissions do
        local subMission = self._subMissions[i]
        if subMission then
            if subMission._status ~= nil and subMission._status == "InProgress" and not subMission._optionalMission then
                inProgress = true
                break
            end
        end
    end

    if not inProgress then
        local completeMsg = self._script:executeBlock("getSuccessDescription") or "$ErrorNoCompleteMessage" --$ ERROR: NO MISSION COMPLETE DESCRIPTION PROVIDED!
        self:complete(true, completeMsg)
    else
        -- Check Time Limit
        if self._endMissionTime then
            if clientTimeWorldTime >= self._endMissionTime then
                local script = self._script
                script:executeBlock("onMissionTimeout")

                for i = 1, #self._subMissions do
                    local subMission = self._subMissions[i]
                    if subMission then
                        if subMission._status ~= nil and subMission._status == "InProgress" then
                            local submissionScript = subMission._script
                            if submissionScript then
                                submissionScript:executeBlock("onMissionTimeout")
                            end
                        end
                    end
                end

                local completeMsg = script:executeBlock("getTimeoutDescription") or "$MissionFailTimeRanOut" --$ Time ran out.

                if not self._optionalTimer then
                    self:complete(false, completeMsg)
                else
                    self._endMissionTime = nil
                end
            elseif self._timeoutWarning and time.worldTime >= self._timeoutWarning then
                self._script:executeBlock("onTimeoutWarning")
                self._timeoutWarning = nil
            end
        end
    end
end

newClass("RomeroGames.World.Missions.Mission", Mission)

local _missionPool = newPool(Mission, {initialCapacity = 256, incrementalCapacity = 64})

SaveState.defineSaveKeys(Missions,
{
    {"_activeMissions"},
    {"_completedMissions"},
    {"_failedMissions"},
    {"_completedSitdownMissions"},
    {"_failedSitdownMissions"},
    {"_focusedMission"},
    {"_missions"},
    {"_iidGenerator"},
    {"_activeQuestGivers"},
    {"_previousFocusedMission"}
})

function Missions:load()
    if Missions.checkOrMarkLoaderExecuted(self) then
        return
    end
    buildMissionMap()

    for _, missionList in next, self._missions do
        for _, mission in pairs(missionList) do
            mission._missions = self
            mission:loadInstance()
        end
    end
    Missions.construct(self)
end

function Missions:onConstruct()
    self._activeMissionsBuffer = {}
    TimeSlicer.addSliceListener("MISSIONS", self)
    game:addEventListener("onGameLoaded", self)
    game:addEventListener("onLocationActivated", self)
    game:addEventListener("onPlacementInvalidated", self)
end

function Missions:init()
    self._missions = {}
    self._activeMissions = {}
    self._completedMissions = {}
    self._failedMissions = {}
    self._completedSitdownMissions = {}
    self._failedSitdownMissions = {}
    self._iidGenerator = 1
    self._activeQuestGivers = 0
    self._previousFocusedMission = nil
    Missions.construct(self)

    Hotload.mixin(self)
    self:hotload()
end

function Missions:onGameLoaded(e)
    if self._focusedMission then
        if self._focusedMission._parent then
            self._focusedMission = self._focusedMission._parent
        end
        self._focusedMission:focus()
    end

    -- self:updateMissionLocations()
end

function Missions:onPlacementInvalidated(e)
    self:updateMissionLocations()
end


local _curCallback = nil
--Using to check location after actors have been moved in
local function lateOnActivate()
    _curCallback = nil
    game:dispatchPooledEvent("onLateLocationActivated", "location", getWorld().currentLocation)
end

function Missions:onLocationActivated(e)
    if _curCallback and game:getTimeCallbackFromIid(_curCallback) then
        game:cancelTimeCallback(_curCallback)
    end
    _curCallback = game:gameTimeCallback(lateOnActivate, 0.5)
end

function Missions:hotload()
    buildMissionMap()
    for _, missionList in next, self._missions do
        for _, mission in pairs(missionList) do
            if not mission._parent then
                mission:hotload()
            end
        end
    end
end

-- Please use for debugging only - not performant
function Missions:findMissionWithPlacementId(placementId)
    for _,entries in next, self._missions do
        for _, mission in next, entries do
            local script = mission._script
            if script then
                local vars = script._vars
                if vars then
                    for vk, vv in next, vars do
                        if type(vv) == "table" and type(vv.rules) == "table" then
                            if vv._iid == placementId then
                                print("Mission contains placement:", script._configId)
                            end
                        end
                    end
                end
            end
        end
    end
end

function Missions:getNewMissionIid()
    local iid = self._iidGenerator
    self._iidGenerator = self._iidGenerator + 1
    return iid
end

function Missions:createSubMission(missionId, notify, parent, ...)
    if parent._parent then
        logError(string.format("Attempting to add sub-mission (%s) to another sub-mission (%s) - sub-missions cannot have sub-missions", missionId, parent._name))
        return
    end

    if #parent._objectives > 0 then
        logError(string.format("%s should not have both objectives and submissions, add objective logic to a sub-mission instead", parent._name))
    end

    notify = notify or false
    local iid = self:getNewMissionIid()
    missionId = _missionMap[missionId] or missionId

    local mission = _missionPool:acquire(self, missionId, iid)
    if mission then
        mission._parent = parent

        self._missions[missionId] = self._missions[missionId] or {}
        self._missions[missionId][iid] = mission
        self._activeMissions[#self._activeMissions + 1] = mission
        getWorld().uiData.missionNotification = true
        game:dispatchPooledEvent("onMissionsUpdate")
        mission:onCreate(...)
        mission:onStart()

        if notify then
            getWorld().uiData.missionNotification = true
        end
    end
    return mission
end

function Missions:createMission(missionId, ...)
    local iid = self:getNewMissionIid()
    missionId = _missionMap[missionId] or missionId

    local mission = _missionPool:acquire(self, missionId, iid)
    if mission then
        self._missions[missionId] = self._missions[missionId] or {}
        self._missions[missionId][iid] = mission
        self._activeMissions[#self._activeMissions + 1] = mission
        getWorld().uiData.missionNotification = true
        mission:onCreate(...)
        if mission:isCompleted() then
            logError("carrying on with a mission that's completed")
        else
            mission:onStart()
        end

        if not mission._isSecret then
            local txt
            if mission._sitdown then
                txt = "$sitdown"
            else
                txt = mission._name
            end
            game:dispatchPooledEvent("onMissionAlertQueued", "configId", "MISSION_NEW", "secondaryText", txt)
        end

        if not mission:isCombatMission() then
            local uiData = getWorld().uiData
            uiData.missionNotification = true
            uiData.missionInteractable = true
        end

        game:dispatchPooledEvent("onMissionsUpdate")

        if not self._focusedMission and not mission._isHidden then
            self:setFocusedMission(mission)
        end

        TelemetryUtils:addMissionActionEvent(mission._missionId, mission._name, mission._rewards, mission._choiceRewards, "start")
    end
    return mission
end

function Missions:resetMission(missionId)
    missionId = _missionMap[missionId] or missionId

    if self._focusedMission and self._focusedMission._missionId == missionId then
        self:setFocusedMission(nil)
    end

    local missionList = self._missions[missionId]
    if missionList then
        for iid, _ in pairs(missionList) do
            local mission = self._missions[missionId][iid]
            local script = mission._script
            if script then
                local block = script:getBlock("resetMission")
                if block then
                    script:executeBlock(block)
                end
            end

            self:removeMission(missionId, iid)
        end

        self._missions[missionId] = nil
    end
end

function Missions:testMission(missionId, testFunctionName, ...)
    local iid = self:getNewMissionIid()
    missionId = _missionMap[missionId] or missionId
    local mission = _missionPool:acquire(self, missionId, iid)
    if mission then
        self._missions[missionId] = self._missions[missionId] or {}
        self._missions[missionId][iid] = mission
        self._activeMissions[#self._activeMissions + 1] = mission
        getWorld().uiData.missionNotification = true
        mission:onCreate(...)
        mission:onTest(testFunctionName)
        game:dispatchPooledEvent("onMissionAlertQueued", "configId", "MISSION_NEW", "secondaryText", mission._name)
        getWorld().uiData.missionNotification = true
        game:dispatchPooledEvent("onMissionsUpdate")
    end
    return mission
end

function Missions:testExistingMission(missionId, testFunctionName, ...)
    local mission = self:getMission(missionId)
    if not mission then
        logError("Unable to find existing mission " .. missionId)
        return
    end

    mission:onTest(testFunctionName, ...)
    return mission
end

function Missions:failMission(missionId, ...)
    self:getMission(missionId):complete(false, "Test Fail")
end

-- If no params are passed it will give the first mission with that id it finds.
function Missions:getMission(missionId, ...)
    missionId = _missionMap[missionId] or missionId
    local missionList = self._missions[missionId]
    if missionList then
        for _, mission in pairs(missionList) do
            local isMission = true
            if ... then
                local n = select("#",...)
                for i = 1, n, 2 do
                    local k = select(i, ...)
                    local v = select(i + 1, ...)

                    if k == nil or v == nil then
                        logError("Invalid mission search parameters supplied to getMission(" .. tostring(self._missionId) .. ").")
                        return
                    end

                    if mission:getValue(k) ~= v then
                        isMission = false
                        break
                    end
                end
            end
            if isMission then
                return mission
            end
        end
    end
end

function Missions:getMissions(missionList)
    clearTable(missionList)
    for id, v in pairs(self._missions) do
        for _, mission in pairs(v) do
            missionList[#missionList + 1] = mission
        end
    end
end

function Missions:getTopLevelMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._parent then
            missionList[#missionList + 1] = mission
        end
    end
    table.sort(missionList, function(a,b) return a._priority > b._priority end)
end

function Missions:getTopLevelClosedMissions(missionList)
    clearTable(missionList)
    for _, mission in pairs(self._completedMissions) do
        if not mission._parent then
            missionList[#missionList + 1] = mission
        end
    end
    for _, mission in pairs(self._failedMissions) do
        if not mission._parent then
            missionList[#missionList + 1] = mission
        end
    end
    for i = 1, #self._completedSitdownMissions do
        missionList[#missionList + 1] = self._completedSitdownMissions[i]
    end
    for i = 1, #self._failedSitdownMissions do
        missionList[#missionList + 1] = self._failedSitdownMissions[i]
    end
end

--Boss, CMA, Hoffman
function Missions:getTopLevelMainMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._parent and mission:isMainMission() then
            missionList[#missionList + 1] = mission
        end
    end
    table.sort(missionList, function(a,b) return a._priority > b._priority end)
end

--Empire, alcohol, citizen, crew
function Missions:getTopLevelSideMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._parent and mission:isSideMission() then
            missionList[#missionList + 1] = mission
        end
    end
end

function Missions:getActiveMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._isSecret then
            missionList[#missionList + 1] = mission
        end
    end
end

-- Active Boss missions, side missions (Excludes bridging missions)
function Missions:getTopLevelActiveStoryMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._parent and mission:isStoryMission() then
            missionList[#missionList + 1] = mission
        end
    end
end

-- Active or completed Boss missions, CMA
function Missions:getAllTopLevelMainMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._parent and mission:isMainMission() then
            missionList[#missionList + 1] = mission
        end
    end

    for id, mission in pairs(self._completedMissions) do
        if not mission._parent and mission:isMainMission() then
            missionList[#missionList + 1] = mission
        end
    end

    for _, mission in pairs(self._failedMissions) do
        if not mission._parent and mission:isMainMission() then
            missionList[#missionList + 1] = mission
        end
    end
end

--Active or completed Side missions (eg Izzys Been Busy, Just a deflector...)
function Missions:getAllTopLevelSideMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._parent and not mission._isHidden and mission:isSideMission() then
            missionList[#missionList + 1] = mission
        end
    end

    for id, mission in pairs(self._completedMissions) do
        if not mission._parent and not mission._isHidden and mission:isSideMission() then
            missionList[#missionList + 1] = mission
        end
    end

    for _, mission in pairs(self._failedMissions) do
        if not mission._parent and not mission._isHidden and mission:isSideMission() then
            missionList[#missionList + 1] = mission
        end
    end
end

--Active or completed Bridging missions (eg Get 5 rackets, Produce 20 barrels of alcohol...)
function Missions:getAllTopLevelBridgingMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._activeMissions) do
        if not mission._parent and mission:isBridgingMission() then
            missionList[#missionList + 1] = mission
        end
    end

    for id, mission in pairs(self._completedMissions) do
        if not mission._parent and mission:isBridgingMission() then
            missionList[#missionList + 1] = mission
        end
    end

    for _, mission in pairs(self._failedMissions) do
        if not mission._parent and mission:isBridgingMission() then
            missionList[#missionList + 1] = mission
        end
    end
end

function Missions:getCompletedMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._completedMissions) do
        missionList[#missionList + 1] = mission
    end
    for i = 1, #self._completedSitdownMissions do
        missionList[#missionList + 1] = self._completedSitdownMissions[i]
    end
end

function Missions:getFailedMissions(missionList)
    clearTable(missionList)
    for id, mission in pairs(self._failedMissions) do
        missionList[#missionList + 1] = mission
    end
    for i = 1, #self._failedSitdownMissions do
        missionList[#missionList + 1] = self._failedSitdownMissions[i]
    end
end

function Missions:getNumTotalMissions()
    return _numMissions -- TODO: update this based on dynamic missions?
end

function Missions:addActiveQuestGivers()
    if not self._activeQuestGivers then
        self._activeQuestGivers = 0
    end
    self._activeQuestGivers = self._activeQuestGivers + 1
end

function Missions:removeActiveQuestGivers()
    if not self._activeQuestGivers then
        self._activeQuestGivers = 0
        return
    end
    self._activeQuestGivers = self._activeQuestGivers - 1
end

function Missions:getActiveQuestGivers()
    return self._activeQuestGivers or 0
end

function Missions:destroy()
    TimeSlicer.removeSliceListener("MISSIONS", self)
    clearTable(self._completedMissions)
    clearTable(self._failedMissions)
    clearTable(self._completedSitdownMissions)
    clearTable(self._failedSitdownMissions)
    clearTable(self._activeMissions)
    clearTable(self._activeMissionsBuffer)
    for missionId, missionList in pairs(self._missions) do
        for iid, _ in pairs(missionList) do
            self:removeMission(missionId, iid)
        end
    end
    game:removeEventListener("onGameLoaded", self)
    game:removeEventListener("onLocationActivated", self)
    game:removeEventListener("onPlacementInvalidated", self)
end

function Missions:removeMissionFromActiveList(mission)
    local wasFocused = mission._focused or (mission._parent and mission._parent._focused)
    for i = 1, #self._activeMissions do
        if self._activeMissions[i] == mission then
            table.remove(self._activeMissions, i)
            if (mission._status == "Failure") then
                if mission._sitdown then
                    self._failedSitdownMissions[#self._failedSitdownMissions + 1] = mission
                else
                    self._failedMissions[mission._missionId] = mission
                end
            elseif (mission._status == "Success") then
                if mission._sitdown then
                    self._completedSitdownMissions[#self._completedSitdownMissions + 1] = mission
                else
                    self._completedMissions[mission._missionId] = mission
                end
            end
            if wasFocused then
                if mission._parent and mission._parent._status == "InProgress" then
                    self:setFocusedMission(mission._parent)
                elseif self._previousFocusedMission and self._previousFocusedMission._status == "InProgress" then
                    self:focusPreviousFocusedMission()
                else
                    self:focusNewMission()
                end
            end
            return
        end
    end
end

function Missions:focusPreviousFocusedMission()
    self:setFocusedMission(self._previousFocusedMission)
end

function Missions:focusNewMission()
    local focusedMission = nil
    
    for _, mission in ipairs(self._activeMissions) do
        if not mission._isHidden then
            focusedMission = mission
            break
        end
    end

    self:setFocusedMission(focusedMission)
end

function Missions:setFocusedMission(mission)
    local previousFocused = self._focusedMission
    if previousFocused then 
        previousFocused:unfocus()     
        self._previousFocusedMission = (previousFocused._status == "InProgress") and previousFocused or nil
    end

    self._focusedMission = mission
    if mission then
        mission:focus()
    else
        game:dispatchPooledEvent("onMissionFocused", "mission", nil)
    end
end

function Missions:toggleFocusMission(mission)
    local focusedMission = self._focusedMission
    if mission == focusedMission then
        self:setFocusedMission(nil)
    else
        self:setFocusedMission(mission)
    end
end

function Missions:updateMissions(e)
    -- Clone active missions for re-entrancy
    clearTable(self._activeMissionsBuffer)
    for i, mission in ipairs(self._activeMissions) do
        self._activeMissionsBuffer[i] = mission
    end
    local updateMissionsDirty = false
    for i, mission in ipairs(self._activeMissionsBuffer) do
        mission:update()
        if mission._status ~= "InProgress" then
            self:removeMissionFromActiveList(mission)
            updateMissionsDirty = true
        end
    end

    if updateMissionsDirty then
        getWorld().uiData.missionNotification = true
        game:dispatchPooledEvent("onMissionsUpdate")
    end
end

function Missions:removeMissionFromActiveMissionsList(missionId)
    missionId = _missionMap[missionId] or missionId
    for i=1, #self._activeMissions do
        local mission = self._activeMissions[i]
        if mission._missionId == missionId then
            self._activeMissions[i] = nil
            break
        end
    end
end

function Missions:removeMissionFromActiveBufferList(missionId)
    missionId = _missionMap[missionId] or missionId
    for i=1, #self._activeMissionsBuffer do
        local mission = self._activeMissionsBuffer[i]
        if mission._missionId == missionId then
            self._activeMissionsBuffer[i] = nil
            break
        end
    end
end

function Missions:removeMissionFromCompletedList(missionId)
    missionId = _missionMap[missionId] or missionId
    local mission = self._completedMissions[missionId]
    if mission then
        self._completedMissions[missionId] = nil
    end
end

function Missions:removeMissionFromFailedList(missionId)
    missionId = _missionMap[missionId] or missionId
    local mission = self._failedMissions[missionId]
    if mission then
        self._failedMissions[missionId] = nil
    end
end

function Missions:removeMissionFromCompletedSitdownList(mission)
    for i = 1, #self._completedSitdownMissions do
        if self._completedSitdownMissions[i] == mission then
            self._completedSitdownMissions[i] = nil
        end
    end
end

function Missions:removeMissionFromFailedSitdownList(mission)
    for i = 1, #self._failedSitdownMissions do
        if self._failedSitdownMissions[i] == mission then
            self._failedSitdownMissions[i] = nil
        end
    end
end

function Missions:removeAndClearMission(mission, missionId, iid)
    if not mission then return end

    mission._optionalMission = false
    mission._parent = nil

    self:removeMissionFromActiveList(mission)
    clearTable(mission._subMissions)

    self:removeMissionFromActiveMissionsList(mission)
    self:removeMissionFromActiveBufferList(mission)
    self:removeMissionFromCompletedList(missionId)
    self:removeMissionFromFailedList(missionId)
    self:removeMissionFromCompletedSitdownList(mission)
    self:removeMissionFromFailedSitdownList(mission)

    _missionPool:release(mission)

    if missionId and iid then
        self._missions[missionId][iid] = nil
    end

    game:dispatchPooledEvent("onMissionsUpdate")
end

function Missions:removeMission(missionId, iid)
    missionId = _missionMap[missionId] or missionId
    local mission = self._missions[missionId][iid]
    if mission then
        if mission._subMissions and #mission._subMissions > 0 then
            for _, subMission in pairs(mission._subMissions) do
                self:removeMission(subMission._missionId, subMission._iid)
            end

            self:removeAndClearMission(mission, missionId, iid)
        else
            self:removeAndClearMission(mission, missionId, iid)
        end
    end
end

function Missions:onMissionComplete(mission, status)
    -- The main logic is handled in Missions:update
    local block = mission._script:getBlock("onMissionComplete")
    if block then
        mission._script:executeBlock(block, status)
    end

    TelemetryUtils:addMissionActionEvent(mission._missionId, mission._name, mission._rewards, mission._choiceRewards, "complete")
end

function Missions:addMissionReward(missionId, rewardType, params)
    local mission = self:getMission(missionId)
    if not mission then
        logError("no mission to add reward to")
        return
    end
    local  alreadyGiven = (params.alreadyGiven == nil) and true or params.alreadyGiven
    local reward = _missionOutcomePool:acquire()
    if rewardType == "CASH" then
        reward.cash =  params.amount
    elseif rewardType == "ITEM" then
        local amount = params.amount or 1
        reward:addItem(params.configId, amount)
    elseif rewardType == "FACTION_RATING" then
        local faction = getWorld().getFaction(params.factionId)
        local icon = faction.icon
        reward:addFactionRatingChange(faction, params.modifierId, icon)
    elseif rewardType == "ALCOHOL" then
        local quality = params.quality or 3 -- Default to Rack quality
        local amount = params.amount or 1
        reward:addAlcohol(quality, amount)
    elseif rewardType == "NOTORIETY" then
        reward:addNotoriety(params.amount, params.reason)
    elseif rewardType == "PRODUCTION" then
        reward:addProductionIncrease(params.building, params.modifier, params.reason)
    elseif rewardType == "UPGRADE" then
        reward:addUpgrade(params.building, params.upgradeType, params.amount)
    elseif rewardType == "RACKET" then
        local building = params.building
        if not building then
            reward:release()
            return
        end
        reward:addRacket(building, building.buildingData.id, building.name)
    elseif rewardType == "HONOR" then
        reward:addHonor(params.faction, params.effectId)
    elseif rewardType == "STAT" then
        reward:addStat(params.stat, params.amount, params.name)
    elseif rewardType == "TRAIT" then
        reward:addTrait(params.trait, params.character, params.name)
    elseif rewardType == "IMPROVEMENT" then
        reward:addImprovement(params.configId, params.precinctId)
    elseif rewardType == "MODIFIER" then
        reward:addModifier(params.modifierId, params.factionId, params.locationId, params.precinctId, params.actor)
    elseif rewardType == "CUSTOM" then
        reward:addCustomReward(params.text, params.customFunc, params.icon)
    end
    mission:addReward(reward, false, alreadyGiven)
end

local locationIdCount = {}
local subMissionObjectives ={}
local function addLocationsFromScriptVars(mission)
    clearTable(locationIdCount)

    local hasSubmissions = mission._subMissions and (#mission._subMissions > 0)

    if hasSubmissions then
        clearTable(subMissionObjectives)
        for i = 1, #mission._subMissions do
            local subMission = mission._subMissions[i]
            for j = 1, #subMission._objectives do
                subMissionObjectives[#subMissionObjectives + 1] =  subMission._objectives[j]
            end
        end
    end
    local objectives = hasSubmissions and subMissionObjectives or mission._objectives

    for i = 1, #objectives do
        local curObjective = objectives[i]
        local pois = curObjective and curObjective._pois

        if next(pois) ~= nil then
            for _, p in next, pois do
                local target = nil
                if p.target and not p.target.isDeleted then
                    target = p.target
                end

                if not target then
                    logInfo("Attempting to put POI on a nil or deleted target in mission", mission.name, "for objective", curObjective._text, "this should be checked!")
                end

                local locationId = target and target:getLocationId()
                if locationId and locationId ~= 0 then
                    locationIdCount[locationId] = true
                end
            end
        end
    end

    if next(locationIdCount) then
        for locationId, _ in next, locationIdCount do
            local location = getWorld().getLocation(locationId)
            if location and location.building then
                if not locationIdCount[location.building.locationId] then
                    local locId = location.building.locationId
                    if not missionsInLocations[locId] then
                        missionsInLocations[locId] = {}
                    end
                    local locationMissions = missionsInLocations[locId]
                    locationMissions[#locationMissions + 1] = mission._parent or mission
                end
            elseif location then
                if not missionsInLocations[locationId] then
                    missionsInLocations[locationId] = {}
                end
                local locationMissions = missionsInLocations[locationId]
                locationMissions[#locationMissions + 1] = mission._parent or mission
            end
        end
    end
end

function Missions:updateMissionLocations()
    local next = next
    for _, v in next, missionsInLocations do
        clearTable(v)
    end
    for _, mission in next, self._activeMissions do
        if not mission._parent then
            addLocationsFromScriptVars(mission)
        end
    end
    game:dispatchPooledEvent("onMissionLocationsUpdated", "missionsInLocations", missionsInLocations)
end

function Missions:getActiveMissionsInLocation(locationId)
    return missionsInLocations[locationId]
end

newClass("RomeroGames.World.Missions", Missions)

function Missions.saveGameCompatibility_removeItems(version, compatibility, itemIds)
    -- remove items from MissionOutcomes
    compatibility:applyToObjects("RomeroGames.World.Missions.Mission",
    function(mission)
        for itemIdx = 1, #itemIds do
            local itemId = itemIds[itemIdx]

            -- normal rewards
            for rewardIdx = #mission._rewards, 1, -1 do
                local outcome = mission._rewards[rewardIdx]
                local itemReward = outcome.itemReward
                if itemReward and itemReward.item then
                    -- printR(itemReward, 2, "cur itemReward")
                    -- print(itemId, 1, "itemId")
                    if itemReward.item._id == itemId then
                        -- print("Removing Reward item: ", itemId)
                        outcome.itemReward = nil
                        outcome.amount = nil
                        table.remove(mission._rewards, rewardIdx)
                    end
                end
            end

            -- choice rewards
            for rewardIdx = #mission._choiceRewards, 1, -1 do
                local outcome = mission._choiceRewards[rewardIdx]
                local itemReward = outcome.itemReward
                -- print("Choice Reward processing item: ", itemId)
                if itemReward and itemReward.item then
                    if itemReward.item._id == itemId then
                        -- print("Removing Choice Reward item: ", itemId)
                        outcome.itemReward = nil
                        outcome.amount = nil
                        table.remove(mission._choiceRewards, rewardIdx)
                    end
                end
            end
        end
    end,
    true)
end

if Dev then
    local _devMissionsConcat = {}
    local _activeMissions = {}
    local _completedMissions = {}
    local _failedMissions = {}

    local function addLine(indentLevel, line)
        local lineBuf = ""
        for i = 1, indentLevel do
            lineBuf = lineBuf .. "  "
        end
        lineBuf = lineBuf .. tostring(line)
        _devMissionsConcat[#_devMissionsConcat + 1] = lineBuf
    end

    function Dev.showMissions()
        clearTable(_devMissionsConcat)
        addLine(0, "")
        addLine(0, "Active Missions")
        addLine(0, "---------------")
        getWorld().getActiveMissions(_activeMissions)
        for i = 1, #_activeMissions do
            local mission = _activeMissions[i]
            local missionLine = mission._scriptName
            addLine(1, missionLine)
        end
        addLine(0,"")
        addLine(0, "Completed Missions")
        addLine(0, "-----------------")
        getWorld().getCompletedMissions(_completedMissions)
        for i = 1, #_completedMissions do
            local mission = _completedMissions[i]
            local missionLine = mission._scriptName
            addLine(1, missionLine)
        end
        addLine(0,"")
        addLine(0, "Failed Missions")
        addLine(0, "---------------")
        getWorld().getFailedMissions(_failedMissions)
        for i = 1, #_failedMissions do
            local mission = _failedMissions[i]
            local missionLine = mission._scriptName
            addLine(1, missionLine)
        end
        print(table.concat(_devMissionsConcat, "\n"))
    end
end

return Missions

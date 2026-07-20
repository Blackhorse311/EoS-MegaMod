_namespace = "BEHAVIOURS"
_id = "UPGRADES_MANAGER"
_name = "UpgradesManager"
_interface = "upgrades"
_autoTimeSlice = false

MAX_LEVEL = 5

upgradeIds = {}
upgradeInterfaces = {}
upgradeTags = {}

persist{}
upgradeHandles = {}

persist{}
upgradeLevel = 1 -- Still used to determine the starting level of upgrades
persist{}
upgradeTime = 60
persist{}
upgradeStartTime = 0
persist{}
upgradesActive = true
upgradesActivated = 0

persist{}
upgradeStartTimes = {}
persist{}
upgradeCompleteTimes = {}

upgradeDataConfigIds = nil
primaryUpgradeTag = nil

function getDatasheetValue(key, level)
    level = level or upgradeLevel + 1
    return Config.RACKET_UPGRADE_DATA[upgradeDataConfigIds[thisObject.size][level]][key]
end

function getUpgradeTime(level)
    local baseUpgradeTime = getDatasheetValue("upgradeTime", level)
    return WorldUtils:getModifiedValueForActor("generic", "UPGRADE_TIME", thisActor, baseUpgradeTime)
end

function setLevel(level, upgradeInterface)
    if upgradeInterface then
        upgradeInterface:setLevel(level)
    else
        for _, upgrade in next, upgradeInterfaces do
            upgrade:setLevel(level)
        end
    end
end

function setMinLevel(level)
    for _, upgrade in next, upgradeInterfaces do
        if upgrade.level < level then
            upgrade:setLevel(level)
        end
    end
end

function onUpgradeComplete(upgradeHandle)
    if isUpgrading(upgradeHandle) then -- If not this was called directly from outside code
        upgradeStartTimes[upgradeHandle] = nil
        upgradeCompleteTimes[upgradeHandle] = nil
        if not isUpgrading() then
            unregisterTimeSlice("upgradeTime")
        end
    end
    local newValue = 0
    for _, upgrade in next, upgradeInterfaces do
        for i = 2, upgrade.level do
            newValue = newValue + upgrade:getCost(i)
        end
    end

    local level = getLevel()
    thisActor:dispatchPooledEvent("onUpgradeComplete", "cancelled", false, "upgradeLevel", level)
    if thisActor.faction.isPlayerFaction then
        Utils:raiseGameEvent("onPlayerUpgradeComplete", "building", thisActor)

        -- Check for police activity effect
        if upgradeHandle then
            local upgrade = thisActor.behaviours:getInterface(upgradeHandle)
            local upgradeLevel = upgrade:getLevel()
            local mods = upgrade:getModifiers(upgradeLevel)
            if mods and mods.criminalActivity then
                local criminalActivity = mods.criminalActivity
                local prevMods = upgrade:getModifiers(upgradeLevel - 1)
                if prevMods and prevMods.criminalActivity then
                    criminalActivity = criminalActivity - prevMods.criminalActivity
                end
                if criminalActivity ~= 0 then
                    local precinct = thisActor:getPrecinct()
                    if precinct then
                        local curPoliceActivity = precinct and precinct:getPoliceActivity() or 0
                        local alertKey = "racketUpgradePoliceActivity" .. precinct.id
                        Utils:raiseGameEvent("onPoliceActivityEffectApplied", "alertKey", alertKey, "appliedPoliceActivity", criminalActivity,
                                "originalValue", curPoliceActivity, "effectId", "UPGRADED_RACKET", "precinct", precinct,
                                "description", {"$Cash_UpgradeBuilding", thisActor.name} )
                    end
                end
            end
            --MODIFIED - Generate persistent notification when all upgrades in a Precinct have completed (see new event at the bottom of this file)
            if upgradeLevel > 1 then
                local upgradeType = upgrade:getName()
                local precinct = thisActor:getPrecinct()
                local upgradeCount = 0
                 for i = 1, #precinct.buildings do
                    local b = precinct.buildings[i]
                    if b.upgrades and b.upgrades:isUpgrading() then
                        upgradeCount = upgradeCount + 1
                    end
                 end
                if upgradeCount == 0 then
                    WorldUtils:triggerEvent("UpgradeComplete", "precinct", precinct)
                end
            end
            -- END OF MODIFICATION
        end
    end

    thisActor.data:setModifier("value", "$RacketUpgradeLevel", newValue)
    thisActor:onUpgrade()
    thisActor:markPrecinctCashValueDirty()
end

function setUpgradesActive(v)
    upgradesActive = v
    for _, upgrade in next, upgradeInterfaces do
        if v then
            upgrade:activateBase()
        else
            upgrade:deactivateBase()
        end
    end
end

function atMaxLevel()
    return upgradeLevel == MAX_LEVEL
end

function onAdd()
    upgradesActivated = 0
    for i = 1, #upgradeIds do
        local upgradeConfigId = upgradeIds[i]
        if not upgradeHandles[upgradeConfigId] then
            addUpgrade(upgradeConfigId)
        end
    end
end

function onUpgradeAdded()
    upgradesActivated = upgradesActivated + 1
    if upgradesActivated == #upgradeIds then
        local precinct = thisActor:getPrecinct()
        if precinct then
            precinct:refreshCustomerDistribution()
        end
    end
end

function onRemove()
    setUpgradesActive(false) -- Ensures modifiers are removed before refreshing precinct
    for id, upgradeHandle in next, upgradeHandles do
        thisActor.behaviours:remove(upgradeHandle)
        upgradeHandles[id] = nil
        upgradeInterfaces[id] = nil
    end
    local precinct = thisActor:getPrecinct()
    if precinct then
        precinct:refreshCustomerDistribution()
        thisActor:markPrecinctCashValueDirty()
    end
end

function forceAdd()
    onAdd()
end

-- TODO: Check with Ronan about this
function getTotalModifiers()
    local modifiers = {}
    local next = next
    for _, interface in next, upgradeInterfaces do
        local s = interface:getModifiers(interface.level)
        if s then
            for k, v in next, s do
                modifiers[k] = (modifiers[k] and (modifiers[k] + v)) or v
            end
        end
    end
    return modifiers
end

function getUpgradeOfType(tag)
    for id, t in next, upgradeTags do
        if t == tag then
            if upgradeInterfaces[id] then
                return upgradeInterfaces[id]
            else
                return addUpgrade(id)
            end
        end
    end
    -- onAdd hasn't been called yet, adding.
    local Utils = Utils
    local configFromId = Utils.configFromId
    for i = 1, #upgradeIds do
        local upgradeConfigId = upgradeIds[i]
        local upgradeConfig = configFromId(Utils, upgradeConfigId)
        if upgradeConfig._tag == tag then
            if upgradeInterfaces[upgradeConfigId] then
                upgradeTags[upgradeConfigId] = tag
                return upgradeInterfaces[upgradeConfigId]
            elseif upgradeHandles[upgradeConfigId] then -- Handling the frame where the onAdd/onActivate hasn't been called yet for the behaviour
                return thisActor.behaviours:getInterface(upgradeHandles[upgradeConfigId])
            else
                return addUpgrade(upgradeConfigId)
            end
        end
    end
end

function getUpgradeFromId(id)
    if upgradeInterfaces[id] then
        return upgradeInterfaces[id]
    else
        -- We must make sure that the upgrade id is valid for this building.
        local found = false
        for i = 1, #upgradeIds do
            if upgradeIds[i] == id then
                found = true
                break
            end
        end

        -- If we did not find the id in this building's upgrades then we should not add it. Return nil instead.
        if not found then return nil end

        return addUpgrade(id)
    end
end

function getPrimaryUpgrade()
    if primaryUpgradeTag then
        return getUpgradeOfType(primaryUpgradeTag)
    end
end

function onActivate()
    for id, upgradeHandle in next, upgradeHandles do
        local upgrade = thisActor.behaviours:getInterface(upgradeHandle)
        upgradeInterfaces[id] = upgrade
    end
    if isUpgrading() then
        registerTimeSlice("upgradeTime")
    end
end

function addUpgrade(id)
    if upgradeHandles[id] then
        logError(id .. " already exists in current upgrade set.")
        return
    end
    if not upgradeTags[id] then
        -- Possibly not added yet.
        local hasId = false
        for i = 1, #upgradeIds do
            if upgradeIds[i] == id then
                hasId = true
            end
        end
        if not hasId then
            logError(id .. " has no tags in current upgrade set.")
        end
    end

    local upgradeHandle = thisActor.behaviours:add(id)
    upgradeHandles[id] = upgradeHandle
    local interface = thisActor.behaviours:getInterface(upgradeHandle)
    upgradeInterfaces[id] = interface
    interface:setLevel(upgradeLevel)
    local upgradeConfig = Utils:configFromId(id)
    upgradeTags[id] = upgradeConfig._tag
    return interface
end

function getUpgradeCost(level)
    level = level or (upgradeLevel + 1)
    local costId = getDatasheetValue("costId", level)
    return WorldUtils:getModifiedValueForActor("cash", costId, thisActor)
end

function getUpgradeTimeRemaining(upgradeHandle)
    if not upgradeHandle then
        -- Use the closest upgrade to finishing
        local earliestTime = worldTime + 9999999999999999
        local earliestHandle
        for h, completeTime in next, upgradeCompleteTimes do
            if completeTime < earliestTime then
                earliestTime = completeTime
                earliestHandle = h
            end
        end
        if earliestHandle then
            upgradeHandle = earliestHandle
        else
            return 0
        end
    end
    local timeInSeconds = upgradeCompleteTimes[upgradeHandle] - worldTime
    return Utils:convertDuration(timeInSeconds, "Seconds", "Days")
end

function canUpgrade()
    return (not isUpgrading()) and (upgradeLevel < MAX_LEVEL)
end

function isUpgrading(upgradeHandle)
    if upgradeHandle then
        return not not upgradeCompleteTimes[upgradeHandle]
    else
        return not not next(upgradeCompleteTimes)
    end
end

function rushUpgrade()
    if isUpgrading() then
        setLevel(upgradeLevel + 1)
    end
end

function cancelUpgrade(upgradeHandle)
    if isUpgrading(upgradeHandle) then
        if upgradeHandle then
            upgradeStartTimes[upgradeHandle] = nil
            upgradeCompleteTimes[upgradeHandle] = nil
        else
            clearTable(upgradeStartTimes)
            clearTable(upgradeCompleteTimes)
        end
        if not isUpgrading() then
            upgradeStartTime = 0
            unregisterTimeSlice("upgradeTime")
            thisActor:dispatchPooledEvent("onUpgradeComplete", "cancelled", true)
            if thisActor.faction.isPlayerFaction then
                Utils:raiseGameEvent("onPlayerUpgradeComplete", "building", thisActor, "cancelled", true)
            end
        end
    end
end

function beginUpgrading(upgradeHandle, timeInDays)
    local isAlreadyUpgrading = isUpgrading()
    local t = Utils:convertDuration(timeInDays, "Days", "Seconds")
    upgradeStartTimes[upgradeHandle] = worldTime
    upgradeCompleteTimes[upgradeHandle] = worldTime + t
    thisActor:dispatchPooledEvent("onUpgradeStart")
    Utils:raiseGameEvent("onUpgradeStart", "building", thisActor)
    if not isAlreadyUpgrading then
        registerTimeSlice("upgradeTime")
    end
end


function getUpgradeProgress(upgradeHandle)
    if not upgradeHandle then
        -- Use the closest upgrade to finishing
        local earliestTime = worldTime + 9999999999999999
        local earliestHandle
        for h, completeTime in next, upgradeCompleteTimes do
            if completeTime < earliestTime then
                earliestTime = completeTime
                earliestHandle = h
            end
        end
        if earliestHandle then
            upgradeHandle = earliestHandle
        else
            return 1
        end
    end
    local t = upgradeCompleteTimes[upgradeHandle] - upgradeStartTimes[upgradeHandle]
    if t == 0 then
        return 1
    else
        return (worldTime - upgradeStartTimes[upgradeHandle]) / t
    end
end

function getLevel()
    local minLevel = 5
    local maxLevel = 1
    for _, upgradeInterface in next, upgradeInterfaces do
        if minLevel > upgradeInterface.level then
            minLevel = upgradeInterface.level
        end
        if maxLevel < upgradeInterface.level then
            maxLevel = upgradeInterface.level
        end
    end
    return minLevel, maxLevel
end

function TimeSlice.upgradeTime()
    for upgradeHandle, completeTime in next, upgradeCompleteTimes do
        if completeTime <= worldTime then
            local upgradeInterface = thisActor.behaviours:getInterface(upgradeHandle)
            setLevel(upgradeInterface.level + 1, upgradeInterface)
            upgradeCompleteTimes[upgradeHandle] = nil
            upgradeStartTimes[upgradeHandle] = nil
        end
    end
    if isUpgrading() then
        local upgradeProgress = getUpgradeProgress() or 0
        thisActor:dispatchPooledEvent("onUpgradeProgress", "progress", upgradeProgress)
    else
        unregisterTimeSlice("upgradeTime")
    end
end

function removeUpgrades()
    for id, upgradeHandle in next, upgradeHandles do
        thisActor.behaviours:remove(upgradeHandle)
        upgradeHandles[id] = nil
        upgradeInterfaces[id] = nil
    end
end

function addRacketUpgradeTelemetryEvent()
    local building = thisActor
    if not building or not building.isRacket then
        do return end
    end
    if not building.buildingData then
        logError("UpgradesManager:addRacketUpgradeTelemetryEvent() doesn't have valid building data")
        do return end
    end
    if not building.faction.isPlayerFaction then
        return
    end

    local racketType = building.buildingData._telemetryId
    local racketId = building.iid

    TelemetryContextUtils:addRacketUpgradeEvent(racketType, racketId, tostring(upgradeLevel))
end

--------------------------------------------------------------------------------
-- BAR UPGRADES
--------------------------------------------------------------------------------

_id = "BAR_UPGRADES"
_name = "BarUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "ambiance"

upgradeIds =
{
    "BEHAVIOURS.BAR_SECURITY_UPGRADE",
    "BEHAVIOURS.BAR_DEFLECT_UPGRADE",
    "BEHAVIOURS.BAR_AMBIANCE_UPGRADE",
    "BEHAVIOURS.BAR_WORD_OF_MOUTH_UPGRADE",
}

upgradeDataConfigIds =
{
    {
        "BAR_SM_BASE_DATA",
        "BAR_SM_UPGRADE_LEVEL_2",
        "BAR_SM_UPGRADE_LEVEL_3",
        "BAR_SM_UPGRADE_LEVEL_4",
        "BAR_SM_UPGRADE_LEVEL_5"
    },
    {
        "BAR_M_BASE_DATA",
        "BAR_M_UPGRADE_LEVEL_2",
        "BAR_M_UPGRADE_LEVEL_3",
        "BAR_M_UPGRADE_LEVEL_4",
        "BAR_M_UPGRADE_LEVEL_5"
    },
    {
        "BAR_LG_BASE_DATA",
        "BAR_LG_UPGRADE_LEVEL_2",
        "BAR_LG_UPGRADE_LEVEL_3",
        "BAR_LG_UPGRADE_LEVEL_4",
        "BAR_LG_UPGRADE_LEVEL_5"
    },
}

--------------------------------------------------------------------------------
-- CASINO UPGRADES
--------------------------------------------------------------------------------

_id = "CASINO_UPGRADES"
_name = "CasinoUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "ambiance"

upgradeIds =
{
    "BEHAVIOURS.CASINO_SECURITY_UPGRADE",
    "BEHAVIOURS.CASINO_DEFLECT_UPGRADE",
    "BEHAVIOURS.CASINO_AMBIANCE_UPGRADE",
    "BEHAVIOURS.CASINO_WORD_OF_MOUTH_UPGRADE",
    "BEHAVIOURS.GAME_UPGRADE",
}

-- Note, upgradeDataConfigIds is also used by Precinct:getEstimatedMaxCashValue
upgradeDataConfigIds =
{
    {
        "CASINO_SM_BASE_DATA",
        "CASINO_SM_UPGRADE_LEVEL_2",
        "CASINO_SM_UPGRADE_LEVEL_3",
        "CASINO_SM_UPGRADE_LEVEL_4",
        "CASINO_SM_UPGRADE_LEVEL_5"
    },
    {
        "CASINO_M_BASE_DATA",
        "CASINO_M_UPGRADE_LEVEL_2",
        "CASINO_M_UPGRADE_LEVEL_3",
        "CASINO_M_UPGRADE_LEVEL_4",
        "CASINO_M_UPGRADE_LEVEL_5"
    },
    {
        "CASINO_LG_BASE_DATA",
        "CASINO_LG_UPGRADE_LEVEL_2",
        "CASINO_LG_UPGRADE_LEVEL_3",
        "CASINO_LG_UPGRADE_LEVEL_4",
        "CASINO_LG_UPGRADE_LEVEL_5"
    },
}

--------------------------------------------------------------------------------
-- BROTHEL UPGRADES
--------------------------------------------------------------------------------

_id = "BROTHEL_UPGRADES"
_name = "BrothelUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "ambiance"

upgradeIds =
{
    "BEHAVIOURS.BROTHEL_SECURITY_UPGRADE",
    "BEHAVIOURS.BROTHEL_DEFLECT_UPGRADE",
    "BEHAVIOURS.BROTHEL_AMBIANCE_UPGRADE",
    "BEHAVIOURS.BROTHEL_WORD_OF_MOUTH_UPGRADE",
}

upgradeDataConfigIds =
{
    {
        "BROTHEL_SM_BASE_DATA",
        "BROTHEL_SM_UPGRADE_LEVEL_2",
        "BROTHEL_SM_UPGRADE_LEVEL_3",
        "BROTHEL_SM_UPGRADE_LEVEL_4",
        "BROTHEL_SM_UPGRADE_LEVEL_5"
    },
    {
        "BROTHEL_M_BASE_DATA",
        "BROTHEL_M_UPGRADE_LEVEL_2",
        "BROTHEL_M_UPGRADE_LEVEL_3",
        "BROTHEL_M_UPGRADE_LEVEL_4",
        "BROTHEL_M_UPGRADE_LEVEL_5"
    },
    {
        "BROTHEL_LG_BASE_DATA",
        "BROTHEL_LG_UPGRADE_LEVEL_2",
        "BROTHEL_LG_UPGRADE_LEVEL_3",
        "BROTHEL_LG_UPGRADE_LEVEL_4",
        "BROTHEL_LG_UPGRADE_LEVEL_5"
    },
}

--------------------------------------------------------------------------------
-- BREWERY UPGRADES
--------------------------------------------------------------------------------

_id = "BREWERY_UPGRADES"
_name = "BreweryUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "production"

upgradeIds =
{
    "BEHAVIOURS.BREWERY_SECURITY_UPGRADE",
    "BEHAVIOURS.BREWERY_DEFLECT_UPGRADE",
    "BEHAVIOURS.BREWERY_PRODUCTION_UPGRADE",
    "BEHAVIOURS.BREWERY_QUALITY_UPGRADE",
    "BEHAVIOURS.BREWERY_STORAGE_UPGRADE",
}

upgradeDataConfigIds =
{
    {
        "BREWERY_SM_BASE_DATA",
        "BREWERY_SM_UPGRADE_LEVEL_2",
        "BREWERY_SM_UPGRADE_LEVEL_3",
        "BREWERY_SM_UPGRADE_LEVEL_4",
        "BREWERY_SM_UPGRADE_LEVEL_5"
    },
    {
        "BREWERY_M_BASE_DATA",
        "BREWERY_M_UPGRADE_LEVEL_2",
        "BREWERY_M_UPGRADE_LEVEL_3",
        "BREWERY_M_UPGRADE_LEVEL_4",
        "BREWERY_M_UPGRADE_LEVEL_5"
    },
    {
        "BREWERY_LG_BASE_DATA",
        "BREWERY_LG_UPGRADE_LEVEL_2",
        "BREWERY_LG_UPGRADE_LEVEL_3",
        "BREWERY_LG_UPGRADE_LEVEL_4",
        "BREWERY_LG_UPGRADE_LEVEL_5"
    },
}

--------------------------------------------------------------------------------
-- LOAN SHARK UPGRADES
--------------------------------------------------------------------------------

_id = "LOAN_SHARK_UPGRADES"
_name = "LoanSharkUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "loanSharkEarnings"

upgradeIds =
{
    "BEHAVIOURS.LOAN_SHARK_SECURITY_UPGRADE",
    "BEHAVIOURS.LOAN_SHARK_EARNINGS_UPGRADE",
    "BEHAVIOURS.LOAN_SHARK_DEFLECT_UPGRADE",
}

upgradeDataConfigIds =
{
    {
        "LOAN_SHARK_BASE_DATA",
        "LOAN_SHARK_UPGRADE_LEVEL_2",
        "LOAN_SHARK_UPGRADE_LEVEL_3",
        "LOAN_SHARK_UPGRADE_LEVEL_4",
        "LOAN_SHARK_UPGRADE_LEVEL_5",
    },
    {
        "LOAN_SHARK_BASE_DATA",
        "LOAN_SHARK_UPGRADE_LEVEL_2",
        "LOAN_SHARK_UPGRADE_LEVEL_3",
        "LOAN_SHARK_UPGRADE_LEVEL_4",
        "LOAN_SHARK_UPGRADE_LEVEL_5",
    },
    {
        "LOAN_SHARK_BASE_DATA",
        "LOAN_SHARK_UPGRADE_LEVEL_2",
        "LOAN_SHARK_UPGRADE_LEVEL_3",
        "LOAN_SHARK_UPGRADE_LEVEL_4",
        "LOAN_SHARK_UPGRADE_LEVEL_5",
    },
}

--------------------------------------------------------------------------------
-- DANCE CLUB UPGRADES (MEGAMOD: restored from current vanilla)
--------------------------------------------------------------------------------

_id = "DANCE_CLUB_UPGRADES"
_name = "DanceClubUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "security"

upgradeIds =
{
    "BEHAVIOURS.DANCE_CLUB_SECURITY_UPGRADE",
    "BEHAVIOURS.DANCE_CLUB_AMBIANCE_UPGRADE",
    "BEHAVIOURS.DANCE_CLUB_WORD_OF_MOUTH_UPGRADE",
}

upgradeDataConfigIds =
{
    {
        "DANCE_CLUB_SM_BASE_DATA",
        "DANCE_CLUB_SM_UPGRADE_LEVEL_2",
        "DANCE_CLUB_SM_UPGRADE_LEVEL_3",
        "DANCE_CLUB_SM_UPGRADE_LEVEL_4",
        "DANCE_CLUB_SM_UPGRADE_LEVEL_5"
    },
    {
        "DANCE_CLUB_M_BASE_DATA",
        "DANCE_CLUB_M_UPGRADE_LEVEL_2",
        "DANCE_CLUB_M_UPGRADE_LEVEL_3",
        "DANCE_CLUB_M_UPGRADE_LEVEL_4",
        "DANCE_CLUB_M_UPGRADE_LEVEL_5"
    },
    {
        "DANCE_CLUB_LG_BASE_DATA",
        "DANCE_CLUB_LG_UPGRADE_LEVEL_2",
        "DANCE_CLUB_LG_UPGRADE_LEVEL_3",
        "DANCE_CLUB_LG_UPGRADE_LEVEL_4",
        "DANCE_CLUB_LG_UPGRADE_LEVEL_5"
    },
}

--------------------------------------------------------------------------------
-- SAFEHOUSE UPGRADES
--------------------------------------------------------------------------------

_id = "SAFEHOUSE_UPGRADES"
_name = "SafehouseUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "production"

upgradeIds =
{
    "BEHAVIOURS.SAFEHOUSE_SECURITY_UPGRADE",
    "BEHAVIOURS.SAFEHOUSE_PRODUCTION_UPGRADE",
    "BEHAVIOURS.SAFEHOUSE_QUALITY_UPGRADE",
}

upgradeDataConfigIds =
{
    "SAFEHOUSE_BASE_DATA",
    "SAFEHOUSE_UPGRADE_LEVEL_2",
    "SAFEHOUSE_UPGRADE_LEVEL_3",
    "SAFEHOUSE_UPGRADE_LEVEL_4",
    "SAFEHOUSE_UPGRADE_LEVEL_5"
}


function getDatasheetValue(key, level)
    level = level or upgradeLevel + 1
    return Config.RACKET_UPGRADE_DATA[upgradeDataConfigIds[level]][key]
end

--------------------------------------------------------------------------------
-- DEPOT UPGRADES
--------------------------------------------------------------------------------

_id = "DEPOT_UPGRADES"
_name = "DepotUpgrades"
_includes = "UPGRADES_MANAGER"

primaryUpgradeTag = "security"

upgradeIds =
{
    "BEHAVIOURS.SAFEHOUSE_SECURITY_UPGRADE",
}

upgradeDataConfigIds =
{
    "SAFEHOUSE_BASE_DATA",
    "SAFEHOUSE_UPGRADE_LEVEL_2",
    "SAFEHOUSE_UPGRADE_LEVEL_3",
    "SAFEHOUSE_UPGRADE_LEVEL_4",
    "SAFEHOUSE_UPGRADE_LEVEL_5"
}

function getDatasheetValue(key, level)
    level = level or upgradeLevel + 1
    return Config.RACKET_UPGRADE_DATA[upgradeDataConfigIds[level]][key]
end

--------------------------------------------------------------------------------
-- DERELICT UPGRADES
--------------------------------------------------------------------------------

_id = "DERELICT_UPGRADES"
_name = "DerelictUpgrades"
_includes = "UPGRADES_MANAGER"

upgradeIds =
{
}

function canUpgrade()
    return false
end

--------------------------------------------------------------------------------
-- HOTEL UPGRADES
--------------------------------------------------------------------------------

_id = "HOTEL_UPGRADES"
_name = "HotelUpgrades"
_includes = "UPGRADES_MANAGER"

upgradeIds =
{
}

function canUpgrade()
    return false
end

_namespace = "WORLD_EVENTS"
_id = "UPGRADE_COMPLETE"
_event = "UpgradeComplete"

precinct = nil

function onTrigger()
    title("$Upgrade_complete_title") --$ Precinct Upgrades Complete
    text({"$Upgrade_complete_text", precinct.name}) --$ All upgrades in {0} have completed.
    option({"$LookAtUpgrades_Text", precinct.name}, doCommand) --$ Look at {0}
    option("$ok")
end

function doCommand()
    local uiData = WorldUtils:getUIData()
    uiData.curFocusedPrecinct = precinct
    clientServices.transition:enableLayer("PrecinctOverview")
end
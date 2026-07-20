--$$ Empire

local Audio = require("Libs.Audio")
local WorldAudio = require("World.WorldAudio")
local ConfigBuilder = require("Libs.ConfigBuilder")
local Clone = require("Libs.Clone")
local TimeSlicer = require("Libs.TimeSlicer")
local WorldEvents = require("World.WorldEvents")
local Scenarios = require("World.Scenarios")
local Jobs = require("Libs.Jobs")
local History = require("World.History")
local SelectionProcessor = require("Libs.SelectionProcessor")
local NavigationProcessor = require("Libs.NavigationProcessor")
local TableUtils = require("Libs.TableUtils")
local LocalEvents = require("Libs.LocalEvents")
local ConversationMatcher = require("Libs.ConversationMatcher")
local Queue = require("Libs.Queue")
local Script = require("Libs.Script")
local Behaviour = require("Mixins.Behaviour")
local ActorSearch = require("World.ActorSearch")
local WorldMapController = require("World.WorldMapController")
local UIConcealer = require("World.UIConcealer")
local CombatContext = require("Combat.CombatContext")
local Market = require("World.Market")
local TelemetryUtils = require("Libs.TelemetryUtils")
local CameraUtils = require("Libs.CameraUtils")
local AutoResolveState = require("Combat.AutoResolve.AutoResolveState")
local LateRequires = require("Libs.LateRequires")
local RPCSkinManager = require("World.RPCSkinManager")
local DanceClubStrategyManager = require("World.DanceClubStrategyManager")

local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local PlatformType = RomeroGames.PlatformType

local _worldSetupPhase = "InitPlayer"
local _worldSetupAndLoadPhase = "Start"
local _numExteriorLocationsAtStart
local _nextExteriorLocationIndexToCreate

local _generateNewGamePhase = "Start"
local _newGameScript

local Actor
local ActorSpawner
local World =
{
    _locationLocks = {},
    _nextLocationLockId = 1,
    _numLocationLocks = 0,

    _combatLocks = {},
    _nextCombatLockId = 1,
    _numCombatLocks = 0,

    _worldMapLocks = {},
    _nextWorldMapLockId = 1,
    _numWorldMapLocks = 0,

    _fleeLock = false,
    activeEntitlements = {},

    uiData = require("DataClasses.UIData"):new()
}

local activeFactions = { }
local activeFactionsById = {}
local allRPCs
local allFollowers
local allNonExcludedRPCsSorted
local allNonExcludedCharactersSorted
local combatRequested = false
local inCombat = false
local areCombatActorsKnown = false
local resolvedCombat = true
local _combatRequestParams
local _aiAutoResolveCombatRequestParams
local notifyCombatActorQuery
local curCombatId
local nextCombatId = 1
local _gameOver = false
local curGameSave
local _registeredTutorialUI = {}
local _pauseKeys = {}
local worldState = nil
local _worldCreated = false

-- local _pendingInteriorLoads = {}

local function buildActiveFactionsById()
    clearTable(activeFactionsById)
    for i = 1, #activeFactions do
        local faction = activeFactions[i]
        activeFactionsById[faction.configId] = faction
    end
end

local function getActor()
    if not Actor then
        Actor = require("World.Actors.Actor")
    end
    return Actor
end

local function getActorSpawner()
    if not ActorSpawner then
        ActorSpawner = require("World.Actors.ActorSpawner")
    end
    return ActorSpawner
end

local function getNotifyCombatActorQuery()
    if not notifyCombatActorQuery then
        notifyCombatActorQuery = getActor().createQuery():
            include("NotifyCombat")
    end
    return notifyCombatActorQuery
end

local function teardownFactions()

    for k, v in pairs(activeFactions) do
        v:teardown()
    end

    activeFactions = { }

    World.activeFactions = activeFactions
    activeFactionsById = {}
end

local function createFactions()
    local Faction = require("World.Faction")

    local index = 1
    for k, v in next, World.initConfig.factions do
        if v then
            activeFactions[index] = Faction:new(k)
            index = index + 1
        end
    end

    -- Create all minor factions
    for factionId, factionConfig in next, Config.FACTION do
        if factionConfig.isMinorFaction and not factionConfig.isMissionFaction then
            activeFactions[#activeFactions + 1] = Faction:new("FACTION." .. factionId)
        end
    end

    World.activeFactions = activeFactions
    buildActiveFactionsById()

    World.noFaction = World.getFaction("FACTION.CITIZENS")
    World.independentFaction = World.getFaction("FACTION.INDEPENDENT")
    World.thugFaction = World.getFaction("FACTION.THUGS")
end

local function loadFactions()
    -- print("World.loadFactions")
    local Faction = require("World.Faction")
    SaveState.loadInstancesOfClass(Faction, World.curLoadData)
end

local function loadResourceManagers()
    local factions = World.activeFactions
    for i = 1, #factions do
        local alcohol = factions[i].alcohol
        if alcohol then
            alcohol:loadInstance()
        end
    end
end

local function teardownAgencies()
    for k, v in pairs(World.activeAgencies) do
        v:teardown()
    end
    allRPCs = nil

    clearTable(World.activeAgencies)
end

local function loadDeletedActors()
    local DeletedActor = getActor().DeletedActor
    SaveState.loadInstancesOfClass(DeletedActor, World.curLoadData)
end

local function loadAgencies()
    local Agency = require("World.Agency")
    SaveState.loadInstancesOfClass(Agency, World.curLoadData)
end

local function loadRacketData()
    local RacketData = require("World.BuildingData")
    SaveState.loadInstancesOfClass(RacketData, World.curLoadData)
end

local function loadFactionAI()
    -- print("World.loadFactionAI")
    local FactionAI = require("AI.Factions.FactionAI")
    SaveState.loadInstancesOfClass(FactionAI, World.curLoadData)
end

local function loadFeatures()
    local BaseFeature = require("AI.Locations.BaseFeature")
    SaveState.loadInstancesOfClass(BaseFeature, World.curLoadData)
end

local function loadRPCs()
    -- print("World.loadRPCS")
    local RPC = require("World.Actors.Characters.RPC")
    SaveState.loadInstancesOfClass(RPC, World.curLoadData)
end

local function loadFollowers()
    -- print("World.loadFollowers")
    local Follower = require("World.Actors.Characters.Follower")
    SaveState.loadInstancesOfClass(Follower, World.curLoadData)
end

local function loadNPCs()
    -- print("World.loadNPCS")
    local NPC = require("World.Actors.Characters.NPC")
    SaveState.loadInstancesOfClass(NPC, World.curLoadData)
end

local function loadAlcohol()
    -- print("World.loadNPCS")
    local Alcohol = require("World.Alcohol")
    local AlcoholCrate = Alcohol.getCrateClass()
    SaveState.loadInstancesOfClass(AlcoholCrate, World.curLoadData)
end

local function loadTaxis()
    local Taxi = require("World.Actors.Taxi")
    local loadedTaxis = {}
    SaveState.loadInstancesOfClass(Taxi, World.curLoadData, loadedTaxis)
    local existingSpidsByLocation = {}
    for i = 1, #loadedTaxis do
        local loadedTaxi = loadedTaxis[i]
        local loadedTaxiLocationId = loadedTaxi:getLocationId()
        local locationEntry = existingSpidsByLocation[loadedTaxiLocationId]
        if not locationEntry then
            locationEntry = {}
            existingSpidsByLocation[loadedTaxiLocationId] = locationEntry
        end
        locationEntry[#locationEntry + 1] = { spIdHi = loadedTaxi._spIdHi, spIdLo = loadedTaxi._spIdLo}
    end
    for i = 1, #World._exteriorLocations do
        local location = World._exteriorLocations[i]
        local existingTaxis = existingSpidsByLocation[location.id] or {}
        client.location:createMissingLocationPersisentActors(location.id, existingTaxis, RomeroGames.ActorSpawnerClass.Taxi)
    end
end

local function loadSafes()
    local Safe = require("World.Actors.Safe")
    SaveState.loadInstancesOfClass(Safe, World.curLoadData)
end

local function loadNewsKiosks()
    local NewsKiosk = require("World.Actors.NewsKiosk")
    SaveState.loadInstancesOfClass(NewsKiosk, World.curLoadData)
end

local function loadItems()
    require("Libs.ItemPool").loadItems()
end

local function loadMarkers()
    local Marker = require("World.Actors.Marker")
    SaveState.loadInstancesOfClass(Marker, World.curLoadData)
end

local function loadDynamicProps()
    local DynamicProp = require("World.Actors.DynamicProp")
    SaveState.loadInstancesOfClass(DynamicProp, World.curLoadData)
end

local function loadTriggerVolumes()
    local TriggerVolume = require("World.Actors.TriggerVolume")
    SaveState.loadInstancesOfClass(TriggerVolume, World.curLoadData)
end

local function loadInteriorDoors()
    local InteriorDoor = require("World.Actors.InteriorDoor")
    local doorsLoaded = {}
    SaveState.loadInstancesOfClass(InteriorDoor, World.curLoadData, doorsLoaded)
    return doorsLoaded
end

local function loadMissionBuildings()
    local MissionBuildings = require("World.MissionBuildings")
    SaveState.loadInstancesOfClass(MissionBuildings, World.curLoadData)
end

local function loadQuestBuildings()
    local QuestBuildings = require("World.QuestBuildings")
    
    if World.questBuildings == nil then
        World.questBuildings = QuestBuildings:new()
        return
    end
    
    SaveState.loadInstancesOfClass(QuestBuildings, World.curLoadData)
end

local function loadLibs()
    local LimitedLog = require("Libs.LimitedLog")
    SaveState.loadInstancesOfClass(LimitedLog, World.curLoadData)
end

local function loadScriptClass()
    Script.classLoad(World._scriptClassSaveData)
    World._scriptClassSaveData = nil
end

local function loadSkinManagerClass()
    RPCSkinManager.classLoad(World._skinManagerSaveData)
    World._skinManagerSaveData = nil
end

local function loadModifiableConfigBuilderClass()
    local ModifiableConfigBuilder = require("Libs.ModifiableConfigBuilder")
    ModifiableConfigBuilder.classLoad(World._modifiableConfigBuilderSaveData)
    World._modifiableConfigBuilderSaveData = nil
end

local function loadDanceClubStrategyManagerClass()
    DanceClubStrategyManager.classLoad(World._danceClubStrategyManagerSaveData)
    World._danceClubStrategyManagerSaveData = nil
end

local function loadBrainClass()
    local Brain = require("Mixins.Brain")
    Brain.classLoad(World._brainClassSaveData)
end

local function loadBehaviourClass()
    Behaviour.classLoad(World._behaviourClassSaveData)
    World._behaviourClassSaveData = nil
end

local function loadFactionClass()
    local Faction = require("World.Faction")
    Faction.classLoad(World._factionClassSaveData)
    World._factionClassSaveData = nil
end

local function loadLocationLocks()
    if World.locationLocks then
        for id, reason in next, World.locationLocks do
             World._locationLocks[id] = reason
             World._nextLocationLockId = id + 1
             World._numLocationLocks = World._numLocationLocks + 1
        end

        if  World._numLocationLocks ~= 0 then
            World.uiData.toggleMapInteractable = false
            game:dispatchPooledEvent("onLocationLocked")
        end
    end

    World.locationLocks = nil
end

local function loadWorldMapLocks()
    if World.worldMapLocks then
        for id, reason in next, World.worldMapLocks do
            World.addWorldMapLock(reason, nil, id)
        end
    end

    World.worldMapLocks = nil
end

local function loadActorCommandsClass()
    local ActorCommands = require("Libs.ActorCommands")
    ActorCommands.classLoad(World._actorCommandsClassSaveData)
    World._actorCommandsClassSaveData = nil
end

local function loadSquadClass()
    local Squads = require("Mixins.Squads")
    Squads.classLoad(World._squadClassSaveData)
    World._squadClassSaveData = nil
end

local function loadTargetPriorityClass()
    local TargetPriority = require("Combat.AI.TargetPriority"):getClass()
    TargetPriority.classLoad(World._targetPriorityClassSaveData)
    World._targetPriorityClassSaveData = nil
end

local function loadScenarioClass()
    if World._scenarioClassSaveData then
        Scenarios.classLoad(World._scenarioClassSaveData)
        World._scenarioClassSaveData = nil
    end
end

local function updatePrecinctSupplyLinesAfterLoad()
    for _, precinct in next, World.precincts do
        precinct:updateSupplyLine()
    end
    require("World.Precinct").updateAllPrecinctsDashed()
end

local function updateAvailableRacketNamesAfterLoad()
    for id, config in next, Config.BUILDING_DATA do
        if config.names and not World.availableRacketNames["BUILDING_DATA." .. id] then
            local names = {}
            for i = 1, #config.names do
                names[i] = config.names[i]
            end
            World.availableRacketNames["BUILDING_DATA." .. id] = names
        end
    end
end

local function createCanadaShop()
    local canadaShop = {}
    local Store = require("Mixins.Store")
    Store.mixin(canadaShop)
    SaveState.defineSaveKeys(canadaShop, { {Store} })
    canadaShop.store:populate("STORES.CANADA_BORDER_SHOP")
    canadaShop.name = "$Canada" --$ Canada
    World.canadaBorderShop = canadaShop
end

-- Todo: figure out how to load new mod classes

-- local function loadRemainingActors()
--     local Actor = require("World.Actors.Actor")
--     SaveState.loadInstancesOfClass(Actor, World.curLoadData)
-- end

local _numInitialRPCs
local _curInitialRPC
local _initialRPCIds
local function updateInitializeRPCs()
    if not _initialRPCIds then
        World.rpcs = {}
        _initialRPCIds = {}
        for n, c in ConfigBuilder.findNamespaces("^RPC%.", nil) do
            for k, v in pairs(c) do
                if v.take then
                    _initialRPCIds[#_initialRPCIds + 1] = n .. "." .. k
                else
                    logWarning("Excluded " .. k .. ", please remove this RPC from configs.")
                end
            end
        end
        _numInitialRPCs = #_initialRPCIds
        _curInitialRPC = 0
        return updateInitializeRPCs()
    else
        local rpcs = World.rpcs
        local actorSpawner = getActorSpawner()
        local remainingRPCs = _numInitialRPCs - _curInitialRPC
        local numRPCsPerUpdate = 5
        for i = 1, math.min(remainingRPCs, numRPCsPerUpdate) do
            _curInitialRPC = _curInitialRPC + 1
            local id = _initialRPCIds[_curInitialRPC]
            local rpc = actorSpawner.spawn("RPC", id )
            rpcs[#rpcs + 1] = rpc
            rpc:setFaction(World.independentFaction)
            rpc:addState("Associate")
        end
        if _curInitialRPC >= _numInitialRPCs then
            -- If dlc 5 enabled we will initialize all rpcs later in RPCSkinManager
            if not World.hasActiveEntitlement(RomeroGames.DLCName.DLC5) then
                for i = 1, #rpcs do
                    rpcs[i]:initializeRelationships()
                end
            end
            return true
        end
    end
    return false
end

local _numInitialFollowers
local _curInitialFollower
local _initialFollowerIds
local function updateInitializeFollowers()
    if not _initialFollowerIds then
        World.followers = {}
        _initialFollowerIds = {}

        for n, c in ConfigBuilder.findNamespaces("FOLLOWER", nil) do
            for k, v in pairs(c) do
                if v.take then
                    _initialFollowerIds[#_initialFollowerIds + 1] = n .. "." .. k
                else
                    logWarning("Excluded " .. k .. ", please remove this Follower from configs.")
                end
            end
        end
        _numInitialFollowers = #_initialFollowerIds
        _curInitialFollower = 0
        return updateInitializeFollowers()
    else
        local followers = World.followers
        local actorSpawner = getActorSpawner()
        local remainingFollowers = _numInitialFollowers - _curInitialFollower
        local numFollowersPerUpdate = 5
        for i = 1, math.min(remainingFollowers, numFollowersPerUpdate) do
            _curInitialFollower = _curInitialFollower + 1
            local id = _initialFollowerIds[_curInitialFollower]
            local follower = actorSpawner.spawn("Follower", id )
            followers[#followers + 1] = follower
            follower:setFaction(World.independentFaction)
        end
        if _curInitialFollower >= _numInitialFollowers then
            for i = 1, #followers do
                --followers[i]:initializeRelationships()
            end
            return true
        end
    end
    return false
end

local function teardownRPCs()
    local rpcs = World.rpcs
    for i = 1, #rpcs do
        rpcs[i]:delete()
    end

    World.rpcs = {}
end

local function teardownFollowers()
    local followers = World.followers
    for i = 1, #followers do
        followers[i]:delete()
    end

    World.followers = {}
end

local function initializeTraffic()
    -- Vehicles
    local vehicleTypes = Config.VEHICLE.VEHICLE_TYPES
    for i, v in ipairs(vehicleTypes) do
        local t = Config.VEHICLE[v]
        if not t then
            throwException("Vehicle type not found: " .. v)
        else
            client.traffic:createVehicleType(function (vehicle)
                vehicle.prefab = _s[t.prefab]
                vehicle.engineAudio = _s[t.engineAudio]
                vehicle.hornAudio = _s[t.hornAudio]
                vehicle.brakesAudio = _s[t.brakesAudio]
                vehicle.minVelocity = t.minVelocity
                vehicle.maxVelocity = t.maxVelocity
                vehicle.turnVelocity = t.turnVelocity
                vehicle.maxVelocityBoost = t.maxVelocityBoost
                vehicle.acceleration = t.acceleration
                vehicle.deceleration = t.deceleration
                vehicle.turnRotationOvershoot = t.turnRotationOvershoot
                vehicle.wheelTurnScale= t.wheelTurnScale
                vehicle.turnRollAngle= t.turnRollAngle
                vehicle.roadBumpPitch = t.roadBumpPitch
                vehicle.roadBumpRoll = t.roadBumpRoll
                vehicle.roadBumpFrequency = t.roadBumpFrequency
                vehicle.soundEffectProbability = t.soundEffectProbability
                vehicle.isStreetcar = t.isStreetcar or false
            end)
        end
    end

    local spawnPedestrian = function()
        local pedestriansToSpawn = Config.PEDESTRIAN.DEFAULTS.pedestriansToSpawn
        local actorSpawner = getActorSpawner()
        local actor = actorSpawner.spawn("Pedestrian", pedestriansToSpawn[math.random(#pedestriansToSpawn)])
        return actor._rgActor
    end

    client.traffic:initSimulation(Config.TRAFFIC.SIMULATION, spawnPedestrian)
end

local function loadTraffic()
    -- Todo: replace
    initializeTraffic()
end

local function initializeStreetcars()
    -- Create a streetcar actor for every line in each exterior locations
    for i = 1, #World._exteriorLocations do
        local location = World._exteriorLocations[i]
        if location.numStreetcarLines then
            for lineIndex = 0, location.numStreetcarLines-1 do
                getActorSpawner().spawnAt("Streetcar", "STREETCAR.VEHICLE", location.id, Vector3.zero, 0, lineIndex)
            end
        end
    end
end

local function loadStreetcars()
    initializeStreetcars()
end

local function initializeBlackMarket()
    local hank = ActorSpawner.spawnAt("NPC", "NPC.HANK", 0, Vector3(0, 0.25, 0), 0)
    hank:addLabel("Hank")
    LateRequires.getWorldLibs().mixinShopToActor(hank, "STORES.SLAB_STORE")
end

local function loadBosses()
    SaveState.loadInstancesOfClass(require("World.Actors.Characters.Boss"), World.curLoadData)
    if Dev then
        Dev.player = World.player
    end
end

local function loadLocationTemplates()

    local function createPrecinct(precinctDefinitionName, id, locationId)
        -- print("CreatePrecinct", precinctDefinitionName, id, locationId)
        local precinct = require("World.Precinct"):new(id, precinctDefinitionName, World.getLocation(locationId))
        World.precincts[id] = precinct
        return precinct
    end

    local function loadPrecinct(precinctDefinitionName, id, locationId)
        -- print("LoadPrecinct", precinctDefinitionName, id, locationId)
        local precinct = World.curLoadDataPrecincts[id]
        if not precinct then
            precinct = createPrecinct(precinctDefinitionName, id, locationId)
        end
        World.precincts[id] = precinct
        return precinct
    end

    local function createLocation(templateName, configId, locationType, locationScript, id, cinematicLocationName, building, midPoint, minBounds, maxBounds)
        -- print("createLocation", templateName, configId, minBounds, maxBounds, building)
        local location = require("World.Locations."..locationScript):new(id, configId, locationType, templateName, cinematicLocationName, building, midPoint, minBounds, maxBounds)
        World.locations[id] = location
        if location.isExterior then
            World._exteriorLocationsByConfigId[configId] = location
            World._exteriorLocationsByName[templateName] = location
            World._exteriorLocations[#World._exteriorLocations + 1] = location
        elseif location.isCinematic then
            World._cinematicLocationsByName[templateName] = location
            World._cinematicLocations[#World._cinematicLocations + 1] = location
        end
        return location
    end

    local function loadLocation(templateName, id)
        -- print("loadLocation", tostring(id))
        local location = World.curLoadDataLocations[id]
        World.locations[id] = location
        if location.isExterior then
            World._exteriorLocationsByConfigId[location.configId] = location
            World._exteriorLocationsByName[templateName] = location
            World._exteriorLocations[#World._exteriorLocations + 1] = location
        elseif location.isCinematic then
            World._cinematicLocationsByName[templateName] = location
            World._cinematicLocations[#World._cinematicLocations + 1] = location
        end
        return location
    end

    local function deleteLocation(id)
        World.locations[id] = nil
    end

    local function setCurrentLocation(id)
        local location = World.getLocation(id)
        World.currentLocationId = id
        World.currentLocation = location
        if location.isExterior then
            World.currentExteriorLocationId = id
            World.currentExteriorLocation = location
        elseif location.isInterior then
            World.currentExteriorLocationId = location.building:getLocationId()
            World.currentExteriorLocation = World.getLocation(World.currentExteriorLocationId)
        end
        game:dispatchPooledEvent("onCurrentLocationChanged", "location", location, "locationId", id)
        assert(World.currentLocation ~= nil, "Cannot find location with id "..id)
    end

    client.location:loadLocationTemplates(World.activeNeighborhoodConfigIds, createLocation, loadLocation, deleteLocation, setCurrentLocation, createPrecinct, loadPrecinct)
end

local LocationsMT = { __isLocationsMT = true }
local PrecinctsMT = { __isPrecinctsMT = true }

local function initializeLocationsAndPrecincts()

    -- We don't log load time in this function as almost all the time is spent
    -- in the location Lua files, so that's where the profiling hooks should be.

    assert(World.locations == nil)
    World.locations = setmetatable({}, LocationsMT) -- Setting a metatable ensures that table is not saved as an array by the SaveState

    World._exteriorLocationsByConfigId = {}
    World._exteriorLocationsByName = {}
    World._exteriorLocations = {}
    World._cinematicLocationsByName = {}
    World._cinematicLocations = {}

    assert(World.precincts == nil)
    World.precincts = setmetatable({}, PrecinctsMT) -- Setting a metatable ensures that table is not saved as an array by the SaveState

    loadLocationTemplates()
end

local function sortNeighbors(a, b)
    return a.distance < b.distance
end

local function populateBehaviour(locations, behaviourName, behaviourArray)
    if behaviourArray == nil then
        logError("Cannot populate behaviour without a valid array to store the resulting interface handles. Please pre-initialise a destination array before calling this function.")
        return
    end

    for i = 1, #locations do
        local thisLocation = World._exteriorLocations[i]
        if thisLocation ~= nil then
            local locationId = thisLocation.id
            local handle = World.behaviours:add(behaviourName, "thisLocation", thisLocation, "locationId", locationId)
            behaviourArray[locationId] = World.behaviours:getInterface(handle)
        end
    end
end

local function initPrecinctShapes(updatePrecinctColor)
    client.rendering.precinct:generateShapes()
    if updatePrecinctColor then
        for _, precinct in next, World.precincts do
            precinct:updatePrecinctColor()
        end
    end
end

local function buildLocationNeighbors()
    for i = 1, #World._exteriorLocations do
        local thisLocation = World._exteriorLocations[i]
        local neighbors = {}
        local thisMinBounds = thisLocation.minBounds
        local thisMaxBounds = thisLocation.maxBounds
        -- print(thisLocation.templateName, thisMinBounds, thisMaxBounds)
        for j = 1, #World._exteriorLocations do
            local otherLocation = World._exteriorLocations[j]
            if i ~= j then
                local otherMinBounds = otherLocation.minBounds
                local otherMaxBounds = otherLocation.maxBounds
                local dist = math.distanceBetweenAABBs(thisMinBounds.x, thisMinBounds.y, thisMinBounds.z, thisMaxBounds.x, thisMaxBounds.y, thisMaxBounds.z,
                                                              otherMinBounds.x, otherMinBounds.y, otherMinBounds.z, otherMaxBounds.x, otherMaxBounds.y, otherMaxBounds.z)
                neighbors[#neighbors + 1] = { location = otherLocation, distance = dist }
            end
        end
        table.sort(neighbors, sortNeighbors)
        thisLocation:setNeighbors(neighbors)
        thisLocation:initLinks()
    end
end

local function buildPrecinctAccessLinks()
    -- logInfo("buildPrecinctAccessLinks")
    local taxis = {}
    LateRequires.getWorldLibs().getActorsWithTag("TaxiSpawner", taxis)
    local taxiPositions = {}
    for _, taxi in next, taxis do
        taxiPositions[#taxiPositions + 1] = taxi:getPos()
    end
    client.location:buildPrecinctAccessLinks(taxiPositions)
    client.rendering.precinct:initAccessLinks()
end

local function setupFactionTables()
    -- Set up gang factions table for quick reference
    World.currentGangFactions = {}
    World.currentAIGangFactions = {}
    World.currentMinorFactions = {}
    World.currentLawEnforcementFactions = {}
    World.currentNonGangFactions = {}
    World.tutorialFaction = World.getFaction("FACTION.THE_MEAT_PACKERS")
    for i = 1, #World.currentGameFactions do
        local faction = World.currentGameFactions[i]
        if faction._active then
            faction.diplomacy:setup(World.currentGameFactions)
        end
        if not faction:isDead() then
            if faction.isGang and faction.boss then
                World.currentGangFactions[#World.currentGangFactions + 1] = faction
                if not faction.isPlayerFaction then
                    World.currentAIGangFactions[#World.currentAIGangFactions + 1] = faction
                end
                --Five families is used as a mission faction
            elseif faction.isMinorFaction and not faction.isMissionFaction then
                World.currentMinorFactions[#World.currentMinorFactions + 1] = faction
            elseif not faction.isGang then
                World.currentNonGangFactions[#World.currentNonGangFactions + 1] = faction
                if faction.isLawEnforcement then
                    World.currentLawEnforcementFactions[#World.currentLawEnforcementFactions + 1] = faction
                end
            end
        end
    end
end

local function initializeCurrentGameFactions()
    local meatPackersFaction = World.getFaction("FACTION.THE_MEAT_PACKERS")
    local ankleBitersFaction = World.getFaction("FACTION.THUGS")
    local policeFaction = World.getFaction("FACTION.CHICAGO_POLICE")
    local citizensFaction = World.getFaction("FACTION.CITIZENS")
    local fireDeptFaction = World.getFaction("FACTION.FIRE_DEPARTMENT")
    local boiFaction = World.getFaction("FACTION.BUREAU_OF_INVESTIGATION")
    local bopFaction = World.getFaction("FACTION.BUREAU_OF_PROHIBITION")
    local fiveFamiliesFaction = World.getFaction("FACTION.FIVE_FAMILIES")
    local cmaFaction = World.getFaction("FACTION.CANADIAN_MAPLE_ASSOCIATION")
    local indieFaction = World.getFaction("FACTION.INDEPENDENT")

    --Mission factions
    local theCollectorsFaction = World.getFaction("FACTION.THE_COLLECTORS")
    local theLodgeFaction = World.getFaction("FACTION.THE_LODGE")
    local whiteHandFaction = World.getFaction("FACTION.WHITE_HAND_GANG")
    local hoffmanCrew = World.getFaction("FACTION.HOFFMANS_CREW")
    local goldenTong = World.getFaction("FACTION.THE_GOLDEN_TONG")
    local schultzGang = World.getFaction("FACTION.SCHULTZ_GANG")
    local spikesCrew = World.getFaction("FACTION.SPIKES_CREW")
    local highestCasino = World.getFaction("FACTION.HIGHEST_CASINO")
    local scissorBlades = World.getFaction("FACTION.SCISSORS_BLADES")

    World.currentGameFactions =
    {
        World.playerFaction,
        indieFaction,
        ankleBitersFaction,
        policeFaction,
        citizensFaction,
        fireDeptFaction,
        boiFaction,
        bopFaction,
        meatPackersFaction,
        fiveFamiliesFaction,
        cmaFaction,
        theCollectorsFaction,
        theLodgeFaction,
        whiteHandFaction,
        hoffmanCrew,
        goldenTong,
        schultzGang,
        spikesCrew,
        highestCasino,
        scissorBlades
    }

    local minorFactions = {}
    World.minorFactions = {}
    for i = 1, #World.activeFactions do
        local faction = World.activeFactions[i]
        if faction.isMinorFaction and not faction.isMissionFaction then
            minorFactions[#minorFactions + 1] = faction
            World.minorFactions[#World.minorFactions + 1] = faction
        end
    end

    TableUtils.shuffle(minorFactions)
    for i = 1, #minorFactions do
        World.currentGameFactions[#World.currentGameFactions + 1] = minorFactions[i]
    end

    local requiredFactionId
    if Dev and (settings:getString("playMode", "") == "CurrentEditorLocation") then
        requiredFactionId = settings:getString("spawnLocationFactionId")
        if requiredFactionId == "player" then
            requiredFactionId = nil
        end
    end

    -- Build playable factions
    local playableFactions = {}
    for i = 1, #activeFactions do
        if activeFactions[i].playable then
            playableFactions[#playableFactions + 1] = activeFactions[i]
        end
    end

    -- Set rival flags
    meatPackersFaction.isRival = true
    ankleBitersFaction.isRival = true

    -- Fill in required factions
    local needsRequired = not not requiredFactionId
    for i = 1, #World.currentGameFactions do
        local curFaction = World.currentGameFactions[i]
        if curFaction.configId == requiredFactionId then
            needsRequired = false
        end
    end
    if needsRequired then
        World.currentGameFactions[#World.currentGameFactions + 1] = World.getFaction(requiredFactionId)
    end

    -- Fill in rival factions
    local numNeighborhoods = settings:getInteger("numNeighborhoods", World.numNeighborhoods or TableUtils.numKeys(Config.WARD))
    local numRivalFactions = settings:getInteger("numRivalFactions", World.numRivals or 7)

    if numRivalFactions < numNeighborhoods then
        numRivalFactions = numNeighborhoods
    end

    for i = #World.currentGameFactions + 1, #World.currentGameFactions + numRivalFactions do
        local newFaction = TableUtils.selectRandomNotInlist(playableFactions, World.currentGameFactions)
        assert(newFaction)
        World.currentGameFactions[#World.currentGameFactions + 1] = newFaction
        newFaction.isRival = true
    end

    for i = 1, #World.currentGameFactions do
        -- Passing in the game factions for the faction to be able to setup their rating and threat structures.
        local curFaction = World.currentGameFactions[i]
        curFaction:setup(World.currentGameFactions)
        if curFaction.boss then
            curFaction.boss:applyBossBonuses(curFaction)
        end
    end

    LateRequires.getWorldLibs().mixinShopToActor(policeFaction.boss, "STORES.POLICE_STORE")

    World.setFact( "AnkleBitersFactionId", ankleBitersFaction.configId )
    World.setFact( "PoliceFactionId", policeFaction.configId )
    World.setFact( "LittleBossFactionId", meatPackersFaction.configId )

    World.victoryTracker:setup(World.currentGameFactions)

    setupFactionTables()
    worldState:calculateNormalizedFactionStrength()
end

function World.calculateNormalizedFactionStrength()
    worldState:calculateNormalizedFactionStrength()
end

local function initializeCurrentGameAgencies()
    local Agency = require("World.Agency")

    clearTable(World.activeAgencies)
    for agencyConfigId, v in next, World.initConfig.agencies do
        if v then
            World.activeAgencies[#World.activeAgencies + 1] = Agency:new(agencyConfigId)
        end
    end
end

local function getMustToAppearNeighborhoodIds()
	local _neighborhoods = {}
    local playerFaction = World.playerFaction

    if not playerFaction then
        return _neighborhoods
    end

    if playerFaction.configId == "FACTION.THE_FIRM" then
        _neighborhoods = { "NEIGHBORHOOD_04" }
    end

    return _neighborhoods
end


local _neighborhoodSizes = { "Large", "Medium", "Small" }
local function selectNeighborhoods(n)
    -- Select one large, one medium and one small neighborhood, then select the next n - 3 neighborhoods randomly
    local wardsConfig = Config.WARD
    local _candidates = {}
    local _allCandidates = {}
    local _results = {}

    for id, neighborhood in next, wardsConfig do
        _allCandidates[id] = id
    end

    local _mustToAppearNeighborhoodIds = getMustToAppearNeighborhoodIds()
    for _, id in ipairs(_mustToAppearNeighborhoodIds) do
        _results[id] = id
        _allCandidates[id] = nil
    end

    local index = #_mustToAppearNeighborhoodIds + 1
    for _, size in ipairs(_neighborhoodSizes) do
        if index > n then
            break
        end
        index = index + 1

        clearTable(_candidates)

        for id, neighborhood in next, wardsConfig do
            if _allCandidates[id] ~= nil and neighborhood.size == size then
                _candidates[id] = id
            end
        end

        local selectedId = TableUtils.selectRandom(_candidates)
        _results[selectedId] = wardsConfig[selectedId]
        _allCandidates[selectedId] = nil
    end

    for i = #_mustToAppearNeighborhoodIds + 4, n do
        local selectedId = TableUtils.selectRandom(_allCandidates)
        _results[selectedId] = wardsConfig[selectedId]

        _allCandidates[selectedId] = nil
    end

    return _results
end

local function initializeCurrentGameNeighborhoods()
    local numNeighborhoods = settings:getInteger("numNeighborhoods", World.numNeighborhoods or TableUtils.numKeys(Config.WARD))

    local selectedNeighborhoods = selectNeighborhoods(numNeighborhoods)

    local activeNeighborhoodConfigIds = {}

    for k,_ in next, selectedNeighborhoods do
        local id = "WARD."..k
        activeNeighborhoodConfigIds[#activeNeighborhoodConfigIds+1] = id
    end

    -- print("setting active neighborhood config ids")
    World.activeNeighborhoodConfigIds = activeNeighborhoodConfigIds

    if Dev and Dev.perfTest then
        World.playerStartLocationId = "WARD.NEIGHBORHOOD_06"
    else
        local possiblePlayerLocationIds = {}
        for i = 1, #activeNeighborhoodConfigIds do
            local nConfigId = activeNeighborhoodConfigIds[i]
            local nConfig = ConfigBuilder.fromId(nConfigId)
            if nConfig.size == "Large" or nConfig.size == "Medium" then
                possiblePlayerLocationIds[#possiblePlayerLocationIds + 1] = nConfigId
            end
        end
        World.playerStartLocationId = TableUtils.selectRandom(possiblePlayerLocationIds)
    end
end

local function initializePlayer()
    -- The player creation screen wasn't run - set the player up with a random boss
    World.create()

    local settingsPlayerFaction = settings:getString("playerFaction", "random")

    local faction
    if settingsPlayerFaction == "random" then

        local randomFactions = {}
        local randomFactionIndex = 1

        for i = 1, #World.activeFactions do
            local f = World.activeFactions[i]
            if f.playable then
                randomFactions[randomFactionIndex] = i
                randomFactionIndex = randomFactionIndex + 1
            end
        end
        local r = randomFactions[math.random(#randomFactions)]
        faction = World.activeFactions[r]
    else
        -- Use quickStartFaction override
        for i = 1, #World.activeFactions do
            local f = World.activeFactions[i]
            if f.configId == settingsPlayerFaction then
                faction = World.activeFactions[i]
                break
            end
        end
    end
    World.setPlayerFaction(faction)

    World.createPlayer()
end

local difficultyModifiers =
{
    Player =
    {
        "DIFFICULTY_ASSOCIATE_PLAYER",
        "DIFFICULTY_MADE_PLAYER",
        "DIFFICULTY_LIEUTENANT_PLAYER",
        "DIFFICULTY_UNDERBOSS_PLAYER",
        "DIFFICULTY_BOSS_PLAYER",
    },
    AI =
    {
        "DIFFICULTY_ASSOCIATE_AI",
        "DIFFICULTY_MADE_AI",
        "DIFFICULTY_LIEUTENANT_AI",
        "DIFFICULTY_UNDERBOSS_AI",
        "DIFFICULTY_BOSS_AI",
    },
}

local function clearDifficultyModifiers(factions, difficultyLevel)
    local playerModifier = difficultyModifiers.Player[difficultyLevel]
    local aiModifier = difficultyModifiers.AI[difficultyLevel]
    for i = 1, #factions do
        local faction = factions[i]
        if faction.isPlayerFaction then
            World.removeModifier(playerModifier, faction.factionId)
        else
            World.removeModifier(aiModifier, faction.factionId)
        end
    end
end

local function applyDifficultyModifiers(factions, difficultyLevel)
    local playerModifier = difficultyModifiers.Player[difficultyLevel]
    local aiModifier = difficultyModifiers.AI[difficultyLevel]
    for i = 1, #factions do
        local faction = factions[i]
        if faction.isPlayerFaction then
            World.applyModifier(playerModifier, faction.factionId)
        else
            World.applyModifier(aiModifier, faction.factionId)
        end
    end
end

local NewGameScriptClient = {}
function NewGameScriptClient:getScriptValue()
end
newClass("World.NewGameScriptClient", NewGameScriptClient)
local newGameScriptClient = NewGameScriptClient:new()

function World.startIntroCinematic()
    local playerId = World.player.configId
    local introToUse = (playerId == "CHARACTER.BOSS.RAGENCOLTS_BOSS" and "BossSitdown_Brothel")
        or (playerId == "CHARACTER.BOSS.LOSLUCEROS_BOSS" and "BossSitdown_Brothel")
        or (playerId == "CHARACTER.BOSS.VICEKINGS_BOSS" and "BossSitdown_Casino")
        or (playerId == "CHARACTER.BOSS.OUTFIT_BOSS" and "IntroTaxi")
        or (playerId == "CHARACTER.BOSS.NORTHSIDE_BOSS" and "BossSitdown_Speakeasy")
        or (playerId == "CHARACTER.BOSS.WHITECITY_BOSS" and "IntroTaxi")
        or (playerId == "CHARACTER.BOSS.DONOVANS_BOSS" and "BossSitdown_Speakeasy")
        or (playerId == "CHARACTER.BOSS.SALTIS_BOSS" and "IntroTaxi")
        or (playerId == "CHARACTER.BOSS.FORTUNETELLERS_BOSS" and "IntroTaxi")
        or (playerId == "CHARACTER.BOSS.HIPSINGTONG_BOSS" and "BossSitdown_Casino")
        or (playerId == "CHARACTER.BOSS.GENNA_BOSS" and "BossSitdown_Speakeasy")
        or (playerId == "CHARACTER.BOSS.LOSHIJOS_BOSS" and "IntroTaxi")
        or (playerId == "CHARACTER.BOSS.ALLEYCATS_BOSS" and "IntroTaxi")
        or (playerId == "CHARACTER.BOSS.CARDSHARKS_BOSS" and "BossSitdown_Casino")
        or (playerId == "CHARACTER.BOSS.MURDER_BOSS" and "BossSitdown_Safehouse")
        or (playerId == "CHARACTER.BOSS.THEFIRM_BOSS" and "IntroTaxiTwo")    

    local npcToUse = (playerId == "CHARACTER.BOSS.RAGENCOLTS_BOSS" and "NPC.MISSION_WILLIAM_HALE_THOMPSON_CINEMATIC")
        or (playerId == "CHARACTER.BOSS.LOSLUCEROS_BOSS" and "NPC.MISSION_DELIA_CINEMATIC")
        or (playerId == "CHARACTER.BOSS.VICEKINGS_BOSS" and "NPC.MISSION_WILLIAM_HALE_THOMPSON_CINEMATIC")
        or (playerId == "CHARACTER.BOSS.OUTFIT_BOSS" and "NPC.TAXI_DRIVER_INTRO")
        or (playerId == "CHARACTER.BOSS.NORTHSIDE_BOSS" and "NPC.MISSION_FATHER_HIGGINS_CINEMATIC")
        or (playerId == "CHARACTER.BOSS.WHITECITY_BOSS" and "NPC.TAXI_DRIVER_INTRO")
        or (playerId == "CHARACTER.BOSS.DONOVANS_BOSS" and "NPC.CINEMATIC_GENERIC_MALE")
        or (playerId == "CHARACTER.BOSS.SALTIS_BOSS" and "NPC.TAXI_DRIVER_INTRO")
        or (playerId == "CHARACTER.BOSS.FORTUNETELLERS_BOSS" and "NPC.TAXI_DRIVER_INTRO")
        or (playerId == "CHARACTER.BOSS.HIPSINGTONG_BOSS" and "NPC.MISSION_KUNG_LIN_CINEMATIC")
        or (playerId == "CHARACTER.BOSS.GENNA_BOSS" and "NPC.MISSION_ANTONIO_CINEMATIC")
        or (playerId == "CHARACTER.BOSS.LOSHIJOS_BOSS" and "NPC.TAXI_DRIVER_INTRO")
        or (playerId == "CHARACTER.BOSS.ALLEYCATS_BOSS" and "NPC.TAXI_DRIVER_INTRO")
        or (playerId == "CHARACTER.BOSS.CARDSHARKS_BOSS" and "NPC.MISSION_NATHALIE_CINEMATIC")
        or (playerId == "CHARACTER.BOSS.MURDER_BOSS" and "NPC.MISSION_HOFFMAN")
        or (playerId == "CHARACTER.BOSS.THEFIRM_BOSS" and "NPC.TAXI_DRIVER_INTRO")

    local playerIsOwner = false

    local conversationTarget = getActorSpawner().spawnAt("NPC", npcToUse, 0, Vector3(1000,1000,1000), 0)
    conversationTarget:setConversationEntryPoint("IntroConversation_Start", "Introduction", 100) -- TODO: Add a config for entryPoint priorities

    client.transition:enableLayerWithParams("Cinematic", {
        cinematicName = introToUse,
        intro = true,
        playerCharacter = World.player,
        conversationTarget = conversationTarget,
        playerIsOwner = playerIsOwner,
    })
end

function World.isCompletedGameWithSylvia()
    local sylvia

    if World.playerFaction.characters then
        for _, character in next, World.playerFaction.characters do
            if character.configId == "RPC.VANGUARD.RPC_66" then
                sylvia = character
                break
            end
        end
    end

    if sylvia == nil or sylvia:isDead() then
        return false
    end

    local factKrayCompletedMainMissionWithSylvia = World.getFact("KrayCompletedMainMissionWithSylvia")

    return factKrayCompletedMainMissionWithSylvia
end

function World.startOutroCinematicInTaxi()
    
    local playerId = World.player.configId
    
    local introToUse = (playerId == "CHARACTER.BOSS.THEFIRM_BOSS" and World.isCompletedGameWithSylvia() and "IntroTaxiTwo")
            or "IntroTaxi"
    
    local npcToUse = "NPC.TAXI_DRIVER_INTRO"

    local conversationTarget = getActorSpawner().spawnAt("NPC", npcToUse, 0, Vector3(1000,1000,1000), 0)
    conversationTarget:setConversationEntryPoint("IntroConversation_End", "EndGame", 100)

    client.transition:enableLayerWithParams("Cinematic", {
        cinematicName = introToUse,
        outro = true,
        playerCharacter = World.player,
        conversationTarget = conversationTarget,
    })
end

function World.startOutroCinematic()

    local playerId = World.player.configId

    if playerId == "CHARACTER.BOSS.THEFIRM_BOSS" and World.isCompletedGameWithSylvia() then
        local introToUse = "Walk_Under_Rain"
        local npcToUse = "RPC.VANGUARD.RPC_66"

        local conversationTarget

        if World.playerFaction.characters then
            for _, character in next, World.playerFaction.characters do
                if character.configId == npcToUse then
                    conversationTarget = character
                    print( "Silvia character selected for outsize final" )
                    break
                end
            end
        end

        conversationTarget:setConversationEntryPoint("KrayFinalOutside", nil, 101)

        client.transition:enableLayerWithParams("Cinematic", {
            cinematicName = introToUse,
            intro = false,
            outro = false,
            playerCharacter = World.player,
            conversationTarget = conversationTarget,
            playerIsOwner = false,
            onCinematicEnd = World.startOutroCinematicInTaxi,
            autoSelectFirstOption = true,
            endingFadeOutDuration = 4
        })
    else
        World.startOutroCinematicInTaxi()
    end
end

function World.escapeByTaxiFromDog()
    local conversationTarget = getActorSpawner().spawnAt("NPC", "NPC.TAXI_DRIVER_INTRO", 0, Vector3(1000,1000,1000), 0)
    conversationTarget:setConversationEntryPoint("EscapeByTaxiFromDog_Start", "Escape", 100)

    client.transition:fadeOut(0.25)
    client.transition:enableLayerWithParams("Cinematic", {
        cinematicName = "IntroTaxi",
        intro = false,
        playerCharacter = World.player,
        conversationTarget = conversationTarget,
        playerIsOwner = false,
    })

end

function World.pickRandomRacketName(buildingType)
    if not World.availableRacketNames then return end
    local names = World.availableRacketNames[buildingType]
    if not names then
        logError("Could not find racket names for building type", buildingType)
    end
    local roll = math.random(#names)
    local name = names[roll]
    names[roll] = names[#names]
    names[#names] = nil
    if #names == 0 then
        -- Repopulate if empty
        local config = ConfigBuilder.fromId(buildingType)
        for i = 1, #config.names do
            names[i] = config.names[i]
        end
    end
    return name
end

function World.removeRacketName(buildingType, name)
    if not World.availableRacketNames then return end
    local names = World.availableRacketNames[buildingType]
    for i = 1, #names do
        if names[i] == name then
            names[i] = names[#names]
            names[#names] = nil
            break
        end
    end
    if #names == 0 then
        -- Repopulate if empty
        local config = ConfigBuilder.fromId(buildingType)
        for i = 1, #config.names do
            names[i] = config.names[i]
        end
    end
end

function World.removeFactionFromCurrentGame(faction)
    for i = #World.currentGameFactions, 1, -1 do
        if World.currentGameFactions[i] == faction then
            -- print("Removing faction from current game", faction.configId)
            table.remove(World.currentGameFactions, i)
            break
        end
    end

    for i = #World.currentGangFactions, 1, -1 do
        if World.currentGangFactions[i] == faction then
            -- print("Removing currentGangFaction from current game", faction.configId)
            table.remove(World.currentGangFactions, i)
            break
        end
    end

    for i = #World.currentAIGangFactions, 1, -1 do
        if World.currentAIGangFactions[i] == faction then
            -- print("Removing currentAIGangFactions from current game", faction.configId)
            table.remove(World.currentAIGangFactions, i)
            break
        end
    end
end

function World.updateGenerateNewGame()
    if rgperf then rgperf.pushMarker("World.updateGenerateNewGame " .. _generateNewGamePhase) end
    if _generateNewGamePhase == "Start" then

        -- if Dev then
        --     Dev.enableTacticMonitoring()
        -- end

        World.availableRacketNames = {}
        for id, config in next, Config.BUILDING_DATA do
            if config.names then
                local names = {}
                for i = 1, #config.names do
                    names[i] = config.names[i]
                end
                World.availableRacketNames["BUILDING_DATA." .. id] = names
            end
        end

        _newGameScript = Script.acquire("NEWGAME.STANDARD", newGameScriptClient)
        local generatorSeed = settings.gameSeed
        if generatorSeed == 0 then
            generatorSeed = math.random(2 ^ 31 - 1)
            settings.gameSeed = generatorSeed
        end
        _newGameScript:setVar("generatorSeed", generatorSeed)
        print(string.format("New game seed: 0x%x", generatorSeed))

        _generateNewGamePhase = "SetupGame"
        if rgperf then rgperf.popMarker() end
        return false

    elseif _generateNewGamePhase == "SetupGame" then

        if _newGameScript:executeBlock("updateSetupGame") then
            _generateNewGamePhase = "NewGameGenerated"
        end
        if rgperf then rgperf.popMarker() end
        return false

    elseif _generateNewGamePhase == "NewGameGenerated" then

        Script.release(_newGameScript)
        _newGameScript = nil
        game:dispatchPooledEvent("onNewGameGenerated")
        World.uiData:setupNewGame()
        _generateNewGamePhase = "Complete"
        if rgperf then rgperf.popMarker() end
        return true

    else
        logError("Invalid updateGenerateNewGame phase", _generateNewGamePhase)
        if rgperf then rgperf.popMarker() end
        return true
    end
end

SaveState.defineSaveKeys(World,
{
    {"difficulty"},
    {"facts"},
    {"history"},
    {"currentGameFactions"},
    {"activeAgencies"},
    {"activeNeighborhoodConfigIds"},
    {"player"},
    {"rpcs"},
    {"followers"},
    {"noFaction"},
    {"independentFaction"},
    {"thugFaction"},
    {"playerFaction"},
    {"activeFactions"},
    {"minorFactions"},
    {"locations"},
    {"precincts"},
    {"worldEvents"},
    {"localEvents"},
    {"placements"},
    {"missions"},
    {"combatRecords"},
    {"tutorials"},
    {"uiData"},
    {"victoryTracker"},
    {"slicedTimers"},
    {"market"},
    {"newspapers"},
    {"actorAI"},
    {"scenarios"},
    {"unscaledScenarios"},
    {"canadaBorderShop"},
    {"availableRacketNames"},
    {"invisibleiidCounter"},
    {"warIds"},
    {"modifiers"},
    {"stateHandle"},
    {"modifierDescriptionsHandle"},
    {"recheckAlcoholConnections"},
    {"lockedForEconomyLoop"},
    {Behaviour},
    {"neighborhoodProsperities"},
    {"neighborhoodSynergies"},
    {"playerStartLocationId"},
    {"activeEntitlements"},
    {"missionBuildings"},
    {"questBuildings"},
    {"unlockedImprovementSlots"},
    {"bribeCounter"},
    {"maxCrewSize"},
    {"isBossRunawayEnabled"},
    {"needCheckProductionYear"},
    -- {"goldenWeaponsHaveProficiency"},
})

function World:save(saveBlock)
    SaveState.defaultSaveFunction(World, saveBlock, World)
    saveBlock.curCombatId = curCombatId
    saveBlock.nextCombatId = nextCombatId
    saveBlock.selectedGroup = SaveState.saveReference(require("Libs.SelectionProcessor").getActiveGroup())

    saveBlock.worldMapLocks = World._worldMapLocks
    saveBlock.locationLocks = World._locationLocks

    local scriptClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_scriptClassSaveData")
    Script.classSave(scriptClassSaveData, World)

    local skinManagerSaveData = SaveState.getNewSaveBlock(saveBlock, "_skinManagerSaveData")
    RPCSkinManager.classSave(skinManagerSaveData)

    local ModifiableConfigBuilder = require("Libs.ModifiableConfigBuilder")
    local modifiableConfigBuilderSaveData = SaveState.getNewSaveBlock(saveBlock, "_modifiableConfigBuilderSaveData")
    ModifiableConfigBuilder.classSave(modifiableConfigBuilderSaveData)

    local danceClubStrategyManagerSaveData = SaveState.getNewSaveBlock(saveBlock, "_danceClubStrategyManagerSaveData")
    DanceClubStrategyManager.classSave(danceClubStrategyManagerSaveData)

    local behaviourClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_behaviourClassSaveData")
    Behaviour.classSave(behaviourClassSaveData, World)

    local Squads = require("Mixins.Squads")
    local squadClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_squadClassSaveData")
    Squads.classSave(squadClassSaveData)

    local Faction = require("World.Faction")
    local factionClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_factionClassSaveData")
    Faction.classSave(factionClassSaveData)

    local ActorCommands = require("Libs.ActorCommands")
    local actorCommandsClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_actorCommandsClassSaveData")
    ActorCommands.classSave(actorCommandsClassSaveData)

    local TargetPriority = require("Combat.AI.TargetPriority"):getClass()
    local targetPriorityClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_targetPriorityClassSaveData")
    TargetPriority.classSave(targetPriorityClassSaveData)

    local scenarioClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_scenarioClassSaveData")
    Scenarios.classSave(scenarioClassSaveData)

    local Brain = require("Mixins.Brain")
    local brainClassSaveData = SaveState.getNewSaveBlock(saveBlock, "_brainClassSaveData")
    Brain.classSave(brainClassSaveData)

    for iid, actor in next, getActor().actorsByInstance do
        local autosave = actor._autosave
        if autosave == nil or autosave == true then
            local status, err = pcall(SaveState.saveReference, actor)
            if not status then
                logError("Unable to save actor of type: ".. tostring(actor.__rt) .. " " .. tostring(err) .. SaveState.getDebugLogSaveTrace(true))
            end
        end
    end
end

local function registerTutorialUI()
    for k, v in pairs(_registeredTutorialUI) do
        World.tutorials:registerUI(k, v)
    end
    clearTable(_registeredTutorialUI)
end

function World.load()
    if rgperf then rgperf.pushMarker("World.load") end
    -- print("World.load")
    World.precreate()
    local locations = World.locations

    World.isLoadedGame = true
    if not World.activeEntitlements then
        World.activeEntitlements = {}
    end
    World.autoResolveState = AutoResolveState:new()

    if World.maxCrewSize == nil then
        World.maxCrewSize = Config.WORLD.INIT.minCrewSize
    end
    
    if World.isBossRunawayEnabled == nil then
        World.isBossRunawayEnabled = false
    end
    
    if World.needCheckProductionYear == nil then
        World.needCheckProductionYear = true
    end

    loadLocationLocks()
    loadWorldMapLocks()

    loadFactionClass()
    loadScriptClass()
    loadSkinManagerClass()
    loadModifiableConfigBuilderClass()
    loadDanceClubStrategyManagerClass()
    loadBehaviourClass()
    loadActorCommandsClass()
    loadBrainClass()
    loadSquadClass()
    loadTargetPriorityClass()
    loadScenarioClass()
    loadLibs()
    World.combatContext = CombatContext:new()
    activeFactions = World.activeFactions
    buildActiveFactionsById()
    loadDeletedActors()
    World.localEvents:loadInstance()
    World.history:loadInstance()
    World.combatRecords:loadInstance()
    World.uiData:loadInstance()
    registerTutorialUI()
    clearTable(_registeredTutorialUI)
    curCombatId = World.curCombatId
    nextCombatId = World.nextCombatId
    World.newspapers:loadInstance()
    World.playerNotifications = require("World.PlayerNotifications"):new()
    loadFactions()
    setupFactionTables()
    World.locations = nil
    World.precincts = nil
    loadRacketData()

    initializeLocationsAndPrecincts()

    -- Todo: split this function so we can get more frame updates between loads

    client.location:loadExteriorLocations()

    initPrecinctShapes(true)
    buildLocationNeighbors()

    -- Load buildings and create interior locations
    for _, location in next, locations do
        local buildings = location.buildings
        if buildings then
            for j = 1, #buildings do
                local building = buildings[j]
                building:loadInstance()
            end
        end
    end

    -- Load interactable props for all locations
    for _, location in next, locations do
        local interactableProps = location.interactableProps
        for j = 1, #interactableProps do
            local interactableProp = interactableProps[j]
            interactableProp:loadInstance()
        end
    end

    -- Create new buildings that were not in the previous save file
    --for i = 1, #World._exteriorLocations do
    --    local location = World._exteriorLocations[i]
    --    local existingSpids = {}
    --
    --    for j = 1, #location.buildings do
    --        local building = location.buildings[j]
    --        existingSpids[#existingSpids + 1] = { spIdHi = building._spIdHi, spIdLo = building._spIdLo}
    --    end
    --
    --    client.location:createMissingLocationPersisentActors(location.id, existingSpids, RomeroGames.ActorSpawnerClass.RacketBuilding)
    --end
    
    loadMissionBuildings()
    loadQuestBuildings()

    -- Todo: loadsave: Create new buildings that were not in the previous save file
    loadBosses()
    loadRPCs()
    loadFollowers()
    loadAgencies()
    loadNPCs()
    loadResourceManagers()
    loadAlcohol()
    loadFactionAI()
    loadFeatures()
    loadTriggerVolumes()

    World.placements:loadInstance()
    World.missions:loadInstance()
    World.tutorials:loadInstance()

    loadTraffic()
    loadStreetcars()
    loadTaxis()
    buildPrecinctAccessLinks()
    loadSafes()
    loadNewsKiosks()
    loadItems()
    loadMarkers()
    loadDynamicProps()
    updatePrecinctSupplyLinesAfterLoad()
    updateAvailableRacketNamesAfterLoad()

    World.victoryTracker:loadInstance()
    World.slicedTimers:loadInstance()
    World.worldEvents:loadInstance()
    World.market:loadInstance()
    local Store = require("Mixins.Store")
    Store.load(World.canadaBorderShop, Store)
    World.canadaBorderShop.name = "$Canada"
    Behaviour.load(World)
    World.actorAI:loadInstance()
    World.scenarios:loadInstance()

    if World.unscaledScenarios then
        World.unscaledScenarios:loadInstance()
    else
        local usesUnscaled = true
        World.unscaledScenarios = Scenarios:new(usesUnscaled)
    end

    Jobs.resumeLoadedJobs()

    worldState = World.behaviours:getInterface(World.stateHandle)
    worldState:setup(World)

    World.setupComplete = true
    if rgperf then rgperf.popMarker() end
end

function World.loadInteriorLocation(locationId)
    -- _pendingInteriorLoads[#_pendingInteriorLoads + 1] = locationId
    return client.location:loadInteriorLocation(locationId)
end

function World.loadInteriorLocationWithCustomTemplate(locationId, templateName)
    -- _pendingInteriorLoads[#_pendingInteriorLoads + 1] = locationId
    return client.location:loadInteriorLocationWithCustomTemplate(locationId, _s[templateName])
end

function World.loadWaypointNetwork(dataPath, locationId)
    local waypointNetwork = RomeroGames.WaypointNetwork.create(locationId)
    waypointNetwork:clear()
    local waypointData = dofile(dataPath)
    local waypoints = waypointData.waypoints
    local links = waypointData.links
    for _, w in ipairs(waypoints) do
        waypointNetwork:addWaypoint(w.pos, w.radius, _s[""])
    end
    for _, l in ipairs(links) do
        local startWaypoint = waypointNetwork:getWaypoint(l.startId - 1)
        local endWaypoint = waypointNetwork:getWaypoint(l.endId - 1)
        local cost = (endWaypoint.pos - startWaypoint.pos).magnitude
        waypointNetwork:addLink(startWaypoint, endWaypoint, _s[""], cost)
    end

    return waypointNetwork
end

function World.loadMissionBuildings()
    loadMissionBuildings()
end

function World.loadTemporaryActors(location)
    local doorActors = loadInteriorDoors()
    if doorActors then
        local existingSpids = {}
        for i = 1, #doorActors do
            local doorActor = doorActors[i]
            existingSpids[#existingSpids + 1] = { spIdHi = doorActor._spIdHi, spIdLo = doorActor._spIdLo}
        end
        client.location:createMissingTemporaryActors(location.id, existingSpids, RomeroGames.ActorSpawnerClass.InteriorDoor)
    end
end

function World.debugPrintWorldEvents()
    World.worldEvents:debugPrintInfo()
end

function World.createWorldEvent(id, ...)
    return World.worldEvents:createEvent(id, ...)
end

function World.trigger(eventConfigId, ...)
    return World.worldEvents:triggerEvent(eventConfigId, ...)
end

function World.triggerForFaction(faction, eventConfigId, ...)
    if faction == World.playerFaction then
        return World.worldEvents:triggerEvent(eventConfigId, ...)
    else
        return World.worldEvents:triggerAIEvent(faction, eventConfigId, ...)
    end
end

function World.triggerForceNext(eventConfigId, ...)
    return World.worldEvents:triggerForceNext(eventConfigId, ...)
end
function World.removeEvent(eventId)
    World.worldEvents:removeEvent(eventId)
end

function World.selectEvent(poolConfigId, ...)
    return World.worldEvents:selectEvent(poolConfigId, ...)
end

function World.getEventFromId(eventId)
    return World.worldEvents:getEventFromId(eventId)
end

function World.isEventActive(eventId)
    return World.worldEvents:isEventActive(eventId)
end

function World.getEventsByName(eventName)
    return World.worldEvents:getEventsByName(eventName)
end

function World.getFirstEventByName(eventName)
    return World.worldEvents:getFirstEventByName(eventName)
end

function World.registerEventBlocker(blockerName)
    if World.worldEvents and World.worldEvents.registerEventBlocker then
        World.worldEvents:registerEventBlocker(blockerName)
    end
end

function World.unregisterEventBlocker(blockerName)
    if World.worldEvents and World.worldEvents.unregisterEventBlocker then
        World.worldEvents:unregisterEventBlocker(blockerName)
    end
end

function World.addLocationLock(reason, lockId)
    assert(type(reason) == "string", "A reason is required to lock the locations!")
    local locks = World._locationLocks

    for id, existingReason in pairs(locks) do
        if existingReason == reason then
            return id -- Return early if reason already exists
        end
    end

    local id = lockId ~= nil and lockId or World._nextLocationLockId
    locks[id] = reason
    World._nextLocationLockId = id + 1
    if World._numLocationLocks == 0 then
        World.uiData.toggleMapInteractable = false
        game:dispatchPooledEvent("onLocationLocked")
    end
    World._numLocationLocks = World._numLocationLocks + 1
    return id
end

function World.removeLocationLock(id)
    if id and World._locationLocks[id] then
        World._locationLocks[id] = nil
        World._numLocationLocks = World._numLocationLocks - 1
        if World._numLocationLocks == 0 then
            World.uiData.toggleMapInteractable = true
            game:dispatchPooledEvent("onLocationUnlocked")
        end
    end
end

function World.hasLocationLock()
    return World._numLocationLocks > 0
end

function World.isLockReasonActive(lockReason)
    for id, reason in next, World._locationLocks do
        if reason == lockReason then
            return id
        end
    end
    return false
end

function World.removeLocationLocksWithReason(lockReason)
    while World.isLockReasonActive(lockReason) do
        for id, reason in next, World._locationLocks do
            if reason == lockReason then
                World.removeLocationLock(id)
                break
            end
        end
    end
end

function World.addWorldMapLock(reason, closeMap, lockId)
    assert(type(reason) == "string", "A reason is required to lock the world map!")
    if closeMap then
        WorldMapController:closeWorldMap()
    end
    local locks = World._worldMapLocks
    local id = lockId ~= nil and lockId or World._nextWorldMapLockId
    locks[id] = reason
    World._nextWorldMapLockId = id + 1
    if World._numWorldMapLocks == 0 then
        World.uiData.toggleMapInteractable = false
    end
    World._numWorldMapLocks = World._numWorldMapLocks + 1
    return id
end

function World.removeWorldMapLock(id)
    if id and World._worldMapLocks[id] then
        World._worldMapLocks[id] = nil
        World._numWorldMapLocks = World._numWorldMapLocks - 1
        if World._numWorldMapLocks == 0 then
            World.uiData.toggleMapInteractable = true
        end
    end
end

function World.hasWorldMapLock()
    return World._numWorldMapLocks > 0
end

function World.hasWorldMapLockWithReason(reason)
    if reason then
        for id, r in next, World._worldMapLocks do
            if r == reason then
                return true
            end
        end
    end
    return false
end

function World.removeWorldMapLocksWithReason(reason)
    while World.hasWorldMapLockWithReason(reason) do
        for id, r in next, World._worldMapLocks do
            if r == reason then
                World.removeWorldMapLock(id)
                break
            end
        end
    end
end

function World.addCombatLock(reason)
    assert(reason, "World.addCombat lock requires a reason")
    local locks = World._combatLocks
    local id = World._nextCombatLockId
    locks[id] = reason
    World._nextCombatLockId = id + 1
    World._numCombatLocks = World._numCombatLocks + 1
    if World._numCombatLocks == 1 then
        game:dispatchPooledEvent("onCombatLockApplied")
    end
    return id
end

function World.removeCombatLock(id)
    if id and World._combatLocks[id] then
        World._combatLocks[id] = nil
        World._numCombatLocks = World._numCombatLocks - 1
        if World._numCombatLocks == 0 then
            game:dispatchPooledEvent("onCombatLocksCleared")
        end
    end
end

function World.hasCombatLock(lockId)
    if lockId then
        for id, reason in next, World._combatLocks do
            if reason == lockId then
                return true
            end
        end
        return false
    else
        return World._numCombatLocks > 0
    end
end

function World.addFleeLock()
    World._fleeLock = true
end

function World.removeFleeLock()
    World._fleeLock = false
end

function World.hasFleeLock()
    return World._fleeLock
end

local _worldPauseKeys = {}
function World.addWorldPause(key)
    if Dev and Dev.runningAutotest then
        return
    end

    _worldPauseKeys[key] = true
    if not client.time.worldTimePaused then
        TimeSlicer.setIntervalTypeScale("Ticks", 0)
        TimeSlicer.setIntervalTypeScale("Turns", 0)
        TimeSlicer.setIntervalTypeScale("Days", 0)
        TimeSlicer.setIntervalTypeScale("Months", 0)
        client.time:pauseWorldTime()
        game:dispatchPooledEvent("onWorldPause")
    end
end

function World.removeWorldPause(key)
    _worldPauseKeys[key] = nil
    local resume = true
    if next(_worldPauseKeys) then
        resume = false
    end
    if resume and client.time.worldTimePaused then
        TimeSlicer.resetIntervalTypeScale("Ticks")
        TimeSlicer.resetIntervalTypeScale("Turns")
        TimeSlicer.resetIntervalTypeScale("Days")
        TimeSlicer.resetIntervalTypeScale("Months")
        client.time:resumeWorldTime()
        game:dispatchPooledEvent("onWorldResume")
    end
end

function World.hasWorldPause(key)
    if key then
        return (_worldPauseKeys[key] ~= nil)
    else
        return (next(_worldPauseKeys) ~= nil)
    end
end

function World.addPause(key)
    if Dev and Dev.runningAutotest then
        return
    end

    if key ~= "pause" then
        if World.uiData then
            World.uiData.pauseInteractable = false
        end
    end

    _pauseKeys[key] = true
    if not clientTime.paused then
        client.time:pause()
        game:dispatchPooledEvent("onPause", "key", key)
        client.transition:enableLayer("WorldPause")
    end
    game:dispatchPooledEvent("onPauseKeysChanged")
end

function World.addSlowPause(key)
    _pauseKeys[key] = true
    if not clientTime.paused then
        client.time:slowPause(0.66)
        game:dispatchPooledEvent("onPause")
        client.transition:enableLayer("WorldPause")
    end
    game:dispatchPooledEvent("onPauseKeysChanged")
end

function World.removePause(key)
    _pauseKeys[key] = nil
    if next(_pauseKeys) then -- Do we have any keys left?
        local keepNonInteractable = false
        if key ~= "pause" then
            for k, _ in next, _pauseKeys do
                if k ~= "pause" then -- Do we have any keys that aren't the default "pause" key?
                    keepNonInteractable = true
                    break
                end
            end
        end
        if not keepNonInteractable then
            if World.uiData then
                World.uiData.pauseInteractable = true
            end
        end
    else
        if World.uiData then
            World.uiData.pauseInteractable = true
        end
        if clientTime.paused then
            client.time:resume()
            game:dispatchPooledEvent("onResume")
            client.transition:disableLayer("WorldPause")
        end
    end
    game:dispatchPooledEvent("onPauseKeysChanged")
end

function World.hasPause(key)
    return not not _pauseKeys[key]
end

function World.clearAllPauseKeys()
    clearTable(_pauseKeys)
    if clientTime.paused then
        client.time:resume()
        game:dispatchPooledEvent("onResume")
        client.transition:disableLayer("WorldPause")
    end
    World.uiData.pauseInteractable = true
    game:dispatchPooledEvent("onPauseKeysChanged")
end

function World.isPauseKeyExclusive(key)
    if not next(_pauseKeys) then
        return false
    end

    for k, v in next, _pauseKeys do
        if k ~= key then
            return false
        end
    end

    return true
end

function World.getGameSave()
    return curGameSave
end

function World.setGameSave(gameSave)
    curGameSave = gameSave
end

local function teardownLocations()
    client.location:clearLocations()
    World.precincts = nil
    World.locations = nil
    World._exteriorLocationsByConfigId = nil
    World._exteriorLocationsByName = nil
    World._cinematicLocationsByName = nil
    World.currentLocationId = 0
    World.currentLocation = nil
    clearTable(World._locationLocks)
    clearTable(World._worldMapLocks)
    World._numLocationLocks = 0
    World._numCombatLocks = 0
end

function World.deleteInteriorLocation(id)
    client.location:deleteInteriorLocation(id)
end

function World.locationExists(id)
    return (World.locations[id] ~= nil)
end

function World.getTotalEarningsForCity()
    local runningTotal = 0
    for k, v in pairs(World._exteriorLocationsByConfigId) do
        if v.totalEarned ~= nil then
            runningTotal = runningTotal + v.totalEarned
        end
    end
    return runningTotal
end

function World.getPrecinct(id)
    return World.precincts[id]
end

function World.getPrecinctsList(results)
    results = results and clearTable(results) or {}

    for id, precinct in next, World.precincts do
        results[#results + 1] = precinct
    end

    return results
end

function World.getClosestOwnedPrecinctInLocation(locationId, faction, x, y)
    local precinctId = client and client.location:getClosestOwnedPrecinctInLocation(locationId, _s[faction.configId], x, y)
    return World.precincts[precinctId]
end


function World.getLocation(id)
    local location = World.locations[id]
    -- assert((id == 0) or (location ~= nil), "Location not found for id "..tostring(id))
    return location
end

function World.getExteriorLocationByName(name)
    local location = World._exteriorLocationsByName[name]
    assert(location ~= nil, "Location not found for name "..name)
    return location
end

function World.doesLocationExistByName(name)
    local location = World._exteriorLocationsByName[name]
    return location ~= nil
end

local _playerStartLocation = nil
function World.getPlayerStartLocation()
    if not _playerStartLocation then
        _playerStartLocation = World._exteriorLocationsByConfigId[World.playerStartLocationId]
    end
    return _playerStartLocation
end


function World.getFaction(id)
    if not id then
        return World.noFaction
    else
        return activeFactionsById[id]
    end
end

-- local _goldenWeaponConfigIds =
-- {
--     ["ITEM.WEAPON.LEGENDARY_MACHINEGUN_03"] = true,
--     ["ITEM.WEAPON.LEGENDARY_SHOTGUN_03"] = true,
--     ["ITEM.WEAPON.LEGENDARY_HANDGUN_06"] = true,
-- }
--
-- function World.isGoldenWeapon(id)
--     return _goldenWeaponConfigIds[id]
-- end

function World.ctxGetActiveFactionsById()
    return activeFactionsById
end

function World.setPlayerFaction(faction)
    local curPlayerFaction = World.playerFaction
    World.playerFaction = faction
    for i = 1, #activeFactions do
        local activeFaction = activeFactions[i]
        if activeFaction == faction then
            activeFaction:setAsPlayerFaction(true)
            clientAI:setPlayerFaction(_s[activeFaction.configId])
        elseif curPlayerFaction == activeFaction then
            activeFaction:setAsPlayerFaction(false)
        end
    end
    World.setFact("PlayerFactionSelected", not not faction)
end

local function _addNewFactions(configIds)
    local Faction = require("World.Faction")

    for i = 1, #configIds do
        local newFaction = Faction:new(configIds[i])
        World.activeFactions[#World.activeFactions + 1] = newFaction
        World.currentGameFactions[#World.currentGameFactions + 1] = newFaction
        newFaction:setup(World.currentGameFactions)
    end

    buildActiveFactionsById()
end

function World.addNewFactions(configIds)
    _addNewFactions(configIds)
end

function World.bumpManualMaxSaveNumber()
    World.maxManualSaveNumber = (World.maxManualSaveNumber or client.settings:getFloat("maxManualSaveNumber", 0)) + 1
    return World.maxManualSaveNumber
end

function World.bumpAutoSaveNumber()
    World.maxAutoSaveNumber = (World.maxAutoSaveNumber or client.settings:getFloat("maxAutoSaveNumber", 0)) + 1
    return World.maxAutoSaveNumber
end

function World.setNumRivals(numRivals)
    World.numRivals = numRivals
end

function World.getNumMinorFactions()
    return World.numMinorFactions or 2
end

function World.setNumMinorFactions(numMinorFactions)
    World.numMinorFactions = numMinorFactions
end

function World.getNumNeighborhoods()
    return World.numNeighborhoods
end

function World.setNumNeighborhoods(numNeighborhoods)
    World.numNeighborhoods = numNeighborhoods
end

function World.setDifficulty(difficulty)
    local oldDifficulty = World.difficulty
    World.difficulty = difficulty
    if World.currentGangFactions then -- We have a running game
        clearDifficultyModifiers(World.currentGangFactions, oldDifficulty)
        applyDifficultyModifiers(World.currentGangFactions, difficulty)
    end
end

function World.getMaxCrewSize()
    return World.maxCrewSize
end

function World.setMaxCrewSize(maxCrewSize)
    World.maxCrewSize = maxCrewSize
end

-- function World.setGoldenWeaponsHaveProficiency(v)
--     World.goldenWeaponsHaveProficiency = v
-- end

local _findFeaturesLocationBuffer = {}
local _findFeaturesFeatureBuffer = {}
function World.findFeatures(searchParams, results) -- Todo: maybe move this to CSharp if required for speed
    -- locationId = false,
    -- featureType = "RpcEncounter",
    -- pos = false,
    -- maxDist = false,
    -- minDist = false,
    -- stations = "RPC_ENCOUNTER",
    -- offCameraRadius = 1
    -- stationTags = ""
    -- includeAcquired = true

    -- Find matching locations
    clearTable(results)

    -- printR(searchParams, 2, "World.findFeatures")

    local paramFeatureType = searchParams.featureType
    if not paramFeatureType then
        logError("World.findFeatures requires featureType in search params.")
        return
    end

    local paramLocationIds = searchParams.locationIds
    local paramLocationId = searchParams.locationId
    if not paramLocationIds then
        clearTable(_findFeaturesLocationBuffer)
        if paramLocationId then
            _findFeaturesLocationBuffer[1] = paramLocationId
            paramLocationIds = _findFeaturesLocationBuffer
        else
            logError("World.findFeatures requires locationId or locationIds in search params.")
            return
        end
    end

    local paramIncludeAcquired = searchParams.includeAcquired

    for i = 1, #paramLocationIds do
        local locationId = paramLocationIds[1]
        local location = World.locations[locationId]
        if not location then
            logError("Unknown locationId passed to World.findFeatures : " .. tostring(locationId) )
            -- continue
        else
            local locationAI = location.locationAI
            if locationAI then
                clearTable(_findFeaturesFeatureBuffer)
                locationAI:getFeaturesWithType(paramFeatureType, _findFeaturesFeatureBuffer)
                for j = 1, #_findFeaturesFeatureBuffer do
                    local possibleFeature = _findFeaturesFeatureBuffer[j]

                    -- printR(possibleFeature, 2, "possibleFeature" .. j)

                    local isValidFeature = true

                    -- Todo: filter by free stations
                    -- Todo: filter by min/max distance from pos
                    -- Todo: filter by available stations
                        -- Todo: filter by available stations off camera

                    if isValidFeature then
                        if paramIncludeAcquired or not possibleFeature._featureCode.acquired then
                            results[#results + 1] = possibleFeature
                        end
                    end
                end
            end
        end
    end

    return #results > 0
end

function World.createPlayer()
    assert(World.playerFaction ~= nil)
    local actorSpawner = getActorSpawner()
    World.player = actorSpawner.spawn("Boss", World.playerFaction.bossId, World.playerFaction.configId)
    World.player:addLabel("Player")
    World.player:addState("TeresaCandle")
    World.player:addState("PlayerFactionMember")
    client.localization:setDynamicString(_s["$Player_Name"], _s[World.player.name])
    client.localization:setDynamicString(_s["$Player_Faction"], _s[World.playerFaction.name])
    if Dev then
        Dev.player = World.player
        Dev.applyCheats()
    end
end

function World.onPlayerResurrect()
    _gameOver = false
end

function World.gameOver()
    -- The player might not have won the game if game over is true
    -- print("World.gameOver")
    if _gameOver then
        logError("World.gameOver already called!")
        return
    end
    _gameOver = true
    TelemetryUtils:addPlaythroughExitEvent("defeat")
end

function World.isGameOver()
    -- The player might not have won the game if game over is true
    return _gameOver
end

function World.destroyPlayer()
    assert(World.player ~= nil)

    World.player:delete()
    World.player = nil
end

function World.getAllRPCs()
    if allRPCs ~= nil then
        return allRPCs
    end
    allRPCs = {}
    for i = 1, #World.activeAgencies do
        World.activeAgencies[i]:getRPCs(allRPCs)
    end
    return allRPCs
end

function World.getAllFollowers()
    if allFollowers ~= nil then
        return allFollowers
    end
    allFollowers = {}

    local followerIds = World.initConfig.followers

    -- Load up the Followers that are associated with this Agency
    local followers = { }
    for i = 1, #followerIds do

        local Follower = require("World.Actors.Characters.Follower")
        local curr = Follower.getFollowerByID(followerIds[i])
        if curr then
            local tier = curr.tier
            if not followers[tier] then
                followers[tier] = {}
            end
            followers[tier][#followers[tier] + 1] = curr
        end
    end

    allFollowers = followers
    
    return allFollowers
end

function World.getAllBlackBookRPCsSorted()
    if allNonExcludedRPCsSorted ~= nil then
        return allNonExcludedRPCsSorted
    end

    allNonExcludedRPCsSorted = {}
    local tieredList = World.getAllRPCs()
    for _, tier in next, tieredList do
        for _, rpc in next, tier do
            if not rpc:hasState("Excluded") and not rpc.notInBlackBook then
                table.insert(allNonExcludedRPCsSorted, rpc)
            end
        end
    end

    local sortFn = function(a, b)
        if b.notorietyGate ~= a.notorietyGate then
            return b.notorietyGate < a.notorietyGate
        end

        -- Not necessarily sorted by name alphabetically. Sorted by string key value so that we get a consistent sort
        return b.name < a.name
    end

    table.sort(allNonExcludedRPCsSorted, sortFn)
    return allNonExcludedRPCsSorted
end

function World.addFollowersToPlayerFaction()

    local followers = World.getAllFollowers()

    for _, tier in next, followers do
        for _, follower in next, tier do
            if not World.playerFaction:hasCrewCharacter(follower) then
                World.playerFaction:addCrewCharacter(follower)
            end
        end
    end
end

function World.removeFollowersfromPlayerFaction()

    for _, member in next, World.player.faction.members do
        if member.isFollower then
            member.faction:removeCrewCharacter(member, true, "Fired")
            member.brain:addGoal("LeaveLocationAndDelete", 1001)
        end
    end
end

function World.getAllBlackBookCharactersSorted()
    if allNonExcludedCharactersSorted ~= nil then
        return allNonExcludedCharactersSorted
    end

    allNonExcludedCharactersSorted = {}

    local tieredList = World.getAllRPCs()
    
    for _, tier in next, tieredList do
        for _, character in next, tier do
            if not character:hasState("Excluded") and not character.notInBlackBook then
                table.insert(allNonExcludedCharactersSorted, character)
            end
        end
    end

    local sortFn = function(a, b)
        if b.notorietyGate ~= a.notorietyGate then
            return b.notorietyGate < a.notorietyGate
        end

        -- Not necessarily sorted by name alphabetically. Sorted by string key value so that we get a consistent sort
        return b.name < a.name
    end

    table.sort(allNonExcludedCharactersSorted, sortFn)
    return allNonExcludedCharactersSorted
end

function World.dirtyBlackBookRPCsTable()
    allNonExcludedRPCsSorted = nil
end

function World.dirtyBlackBookCharactersTable()
    allNonExcludedCharactersSorted = nil
end

function World.getNumBlackBookCharacters()
    local count = 0
    local tieredList = World.getAllRPCs()
    for _, tier in next, tieredList do
        for _, rpc in next, tier do
            if not rpc:hasState("Excluded") and not rpc.notInBlackBook then
                count = count + 1
            end
        end
    end
    return count
end

function World.canRequestEnterCombat()
    if combatRequested or World.hasCombatLock() or inCombat then
        return false
    end
    return true
end

function World.requestNewCombatId()
    local combatId = nextCombatId
    nextCombatId = nextCombatId + 1
    return combatId
end

function World.requestEnterCombat(params)
    -- print("Requesting actor", params.requestingActor.name, "Target actor", params.targetActor and params.targetActor.name, getDebugTraceback())
    --printR(params, 2, "requestEnterCombat params")
    if not params.requestingFaction and params.requestingActor then
        params.requestingFaction = params.requestingActor.faction
    end

    if params.requestingActor and params.requestingActor:hasTag("NonCombat") then
        return
    end

    if params.aiAutoResolve then
        _aiAutoResolveCombatRequestParams = Clone.shallow(params)
        local combatId = params.combatId
        if not combatId then
            combatId = World.requestNewCombatId()
        end
        _aiAutoResolveCombatRequestParams.id = combatId
        return combatId
    end

    -- We are not AI autoresolving so continue

    if combatRequested or World.hasCombatLock() then
        return
    end

    _combatRequestParams = Clone.shallow(params)

    -- print("World.requestEnterCombat(params)")
    combatRequested = true
    if inCombat then
        return
    end

    World.setInCombat(true)
    Audio.oneShot( "AUDIO.COMBAT.COMBAT_START" )
    return curCombatId
end

function World.isCombatRequested()
    return combatRequested
end

function World.requestEndCombat()
    if not combatRequested then return end
    local combatId = curCombatId
    combatRequested = false
    World.setInCombat(false)
    local turnBasedCombat = require("Combat.TurnBasedCombat").getInstance()
    local wasFullCombat = turnBasedCombat.combatSession:hasStarted()
    if wasFullCombat then
        local remainingFactions = {}
        turnBasedCombat.combatSession:getRemainingFactions(remainingFactions)
        game:dispatchPooledEvent("onCombatEnd", "combatId", combatId, "remainingFactions", remainingFactions)
    else
        game:dispatchPooledEvent("onCombatEnd", "combatId", combatId)
    end
end

function World.requestEndCombatFromAutoResolve()
    local combatId = curCombatId
    combatRequested = false
    World.setInCombat(false)
    -- Dev.remainingFactions = World.autoResolveState.remainingFactions
    game:dispatchPooledEvent("onCombatEnd", "autoResolved", true, "combatId", combatId, "remainingFactions", World.autoResolveState.remainingFactions)
end

function World.inCombat()
    return inCombat
end

function World.areCombatActorsKnown()
    return areCombatActorsKnown
end

function World.resolvedCombat()
    return (not inCombat) and resolvedCombat
end

function World.getCurCombatId()
    return curCombatId
end

function World.getCombatRequestParams()
    return _combatRequestParams
end

function World.getAIAutoResolveCombatRequestParams()
    return _aiAutoResolveCombatRequestParams
end

function World.resolveCombat()
    resolvedCombat = true
end

local function notifyActorsCombatStarted()
    local actorQueryResult = getActor().createQueryResult()
    getNotifyCombatActorQuery():doQuery(actorQueryResult)
    for i = 1, actorQueryResult.count do
        local actor = actorQueryResult:get(i)
        if actor then
            actor:onCombatStart()
        else
            logError("notifyActorsCombatStarted actor is nil")
        end
    end
    actorQueryResult:destroy()
end

local function notifyActorsCombatEnded()
    local actorQueryResult = getActor().createQueryResult()
    getNotifyCombatActorQuery():doQuery(actorQueryResult)
    for i = 1, actorQueryResult.count do
        local actor = actorQueryResult:get(i)
        if actor then
            actor:onCombatEnd()
        else
            logError("notifyActorsCombatEnded actor is nil")
        end
    end
    actorQueryResult:destroy()
end

function World.setAreCombatActorsKnown(v)
    areCombatActorsKnown = v
end

local function _setInCombatRecoveryFunc()
    logError("Error occurred during combat initialization. Attempting to recover.")
    World.removeWorldPause("Combat")
    SaveState.removeSaveBlocker("Combat")
    World.removeLocationLock(World._combatLocationLock)
    client.worldActor.inCombat = false
    inCombat = false
    curCombatId = nil
    combatRequested = false
end

function World.setInCombat(v)
    -- print("World.setInCombat(" .. tostring(v) .. ")")
    -- if not v then
    --     print(debug.traceback())
    -- end
    if inCombat == v then return end

    client.worldActor.inCombat = v

    inCombat = v
    areCombatActorsKnown = false
    resolvedCombat = false -- Entering we haven't resolved, exiting we haven't resolved.

    game:dispatchPooledEvent("onInCombatChanged")

    if v then
        SaveState.addSaveBlocker("Combat")
        World._combatLocationLock = World.addLocationLock("Combat")
        World.addWorldPause("Combat")

        curCombatId = _combatRequestParams.combatId
        if not curCombatId then
            curCombatId = World.requestNewCombatId()
        end
        _combatRequestParams.id = curCombatId
        local snapMove = false
        local ignoreClearShot = false


        LateRequires.getTurnBasedCombat().getInstance():resetCombatSession()

        -- Assume all actors are present in the combat location
        local function continueCombatFunction()
            -- Make sure we pause the game so that no one can move while the game is focusing on the combat actors
            World.addPause("startingCombat")

            CameraUtils.focusOnActor(_combatRequestParams.requestingActor, false, "goto_location", snapMove, ignoreClearShot, function(success)

                -- Make sure to remove the pause before we return from a focus on actor failure
                World.removePause("startingCombat")

                if not success then
                    -- Camera failed to focus on the actor so cancel entering combat
                    _setInCombatRecoveryFunc()
                    return
                end

                local scale = CameraUtils.getZoomScale()
                if scale < 0.5 then
                    scale = 0.8
                else
                    scale = 0.2
                end

                CameraUtils.setCombatCameraActive(true)
                CameraUtils.zoomToScale(scale)
                CameraUtils.rotateCameraToSnap(30, 0.5)

                -- Enable combat
                client.transition:enableLayerWithParams("SetupCombat", _combatRequestParams)
                UIConcealer.setConcealFlag("Combat", true)
                client.transition:disableLayer("TopBar")
                client.transition:disableLayer("Notifications")

                notifyActorsCombatStarted()
            end)
        end
        
        World.autoResolveState:clear()

        if _combatRequestParams.takeOverBuildingAutoResolveMode then
            World.autoResolveState:setupBeforeCombat({takeOverBuildingAutoResolveMode = true})
        else
            if (_combatRequestParams.targetActor or _combatRequestParams.targetFaction) and _combatRequestParams.showAutoResolveBeforeCombat and not World.isMainTutorialActive() then
                local autoResolveParams = {
                    fightFunction = continueCombatFunction,
                    errorFunction = _setInCombatRecoveryFunc
                }
                World.autoResolveState:setupBeforeCombat(autoResolveParams)
            else
                continueCombatFunction()
            end
        end
    else
        SaveState.removeSaveBlocker("Combat")
        World.removeLocationLock(World._combatLocationLock)

        UIConcealer.setConcealFlag("Combat", false)
        client.transition:enableLayer("TopBar")
        client.transition:enableLayer("Notifications")

        World.removeWorldPause("Combat")

        -- Combat is over, disable the layer
        client.transition:disableLayer("SetupCombat")
        client.transition:disableLayer("Combat")
        client.transition:disableLayer("FinishCombat")

        CameraUtils.setCombatCameraActive(false)

        -- If combat was cancelled while starting up, there might not be a combat session
        if World.combatSession then
            local focusActor
            for _, actor in World.combatSession:allValidCombatAgents() do
                if not focusActor and actor.faction.isPlayerFaction then
                    focusActor = actor
                end
            end
            if focusActor then
                local scale = CameraUtils.getZoomScale()
                if scale < 0.5 then
                    scale = 0.8
                else
                    scale = 0.2
                end

                CameraUtils.focusOnActor(focusActor)
                CameraUtils.zoomToScale(scale)
                CameraUtils.rotateCameraToSnap(-30, 0.5)
            end
        end

        notifyActorsCombatEnded()

        curCombatId = nil
    end
end

function World.setCombatSession(v)
    World.combatSession = v
end

function World.setInCinematic(v)
    if v then
        World.addWorldPause("Cinematic")
        SaveState.addSaveBlocker("Cinematic")
    else
        World.removeWorldPause("Cinematic")
        SaveState.removeSaveBlocker("Cinematic")
    end

end

function World.schedule(eventId, slice, ...)
    return World.worldEvents:schedule(eventId, slice, ...)
end

function World.scheduleWithDelay(eventId, delay, slice, ...)
    return World.worldEvents:scheduleWithDelay(eventId, delay, slice, ...)
end

function World.precreate()
    _gameOver = false
    game:addEventListener("onEnvironmentSettingsChanged", World)
    game:addEventListener("frame", World)
    game:addEventListener("onFactionVictory", World)
    game:addEventListener("onFactionLoss", World)
    game:addEventListener("onEventsUnblocked", World)
    game:addEventListener("onTutorialComplete", World)
end

function World.create()
    if _worldCreated then
        return
    end
    _worldCreated = true
    World.combatContext = CombatContext:new()
    World.precreate()
    World.facts = {}
    World.scenarios = Scenarios:new()
    local usesUnscaled = true
    World.unscaledScenarios = Scenarios:new(usesUnscaled)
    World.missions = require("World.Missions"):new()
    World.placements = require("World.Placements"):new()
    World.missionBuildings = require("World.MissionBuildings"):new()
    World.questBuildings = require("World.QuestBuildings"):new()
    World.combatRecords = require("World.CombatRecords"):new()
    World.tutorials = require("World.Tutorials"):new()
    registerTutorialUI()
    World.victoryTracker = require("World.VictoryTracker"):new()
    World.slicedTimers = require("Libs.SlicedTimer"):new()
    World.newspapers = require("World.Newspapers"):new()
    World.worldEvents = WorldEvents:new()
    World.market = Market:new()
    World.localEvents = LocalEvents:new()
    World.playerNotifications = require("World.PlayerNotifications"):new()
    Behaviour.mixin(World)
    World.behaviours:add("WeaponProficiencyManager")
    World.modifierDescriptionsHandle = World.behaviours:add("ModifierDescriptions")
    World.actorSearch = ActorSearch:new()
    World.initConfig = Config.WORLD.INIT
    World.warIds = {}
    World.activeAgencies = {}
    World.unlockedImprovementSlots = {}

    createFactions()
    World.history = History:new()
    createCanadaShop()
    World.actorAI = require("World.ActorAI"):new()
end

function World.addActiveEntitlement(dlcName)
    if not World.activeEntitlements then
        return
    end

    --Convert enum to string.
    local dlcStr = client.mods:getDLCNameAsString(dlcName)
    World.activeEntitlements[dlcStr] = true
end

function World.hasActiveEntitlement(dlcName)
    if not World.activeEntitlements then
        return false
    end

    --Convert enum to string.
    local dlcStr = client.mods:getDLCNameAsString(dlcName)
    return not not World.activeEntitlements[dlcStr]
end

function World.updateActiveEntitlements()
    for id, config in next, Config.GAME.ENTITLEMENTS do
        if client.mods:isDLCActive(config.dlcName) then
            World.addActiveEntitlement(config.dlcName)
        end
    end
end

function World:onEnvironmentSettingsChanged(e)
    WorldAudio.onEnvironmentSettingsChanged(e)
end

function World:onFactionVictory(e)
    if e.faction == self.playerFaction then
        TelemetryUtils:addPlaythroughExitEvent("victory")
    end
end

function World:onFactionLoss(e)
    local currentGangFactions = World.currentGangFactions
    for i = 1, #currentGangFactions do
        if e.faction == currentGangFactions[i] then
            currentGangFactions[i] = currentGangFactions[#currentGangFactions]
            currentGangFactions[#currentGangFactions] = nil
            break
        end
    end
    local currentAIGangFactions = World.currentAIGangFactions
    for i = 1, #currentAIGangFactions do
        if e.faction == currentAIGangFactions[i] then
            currentAIGangFactions[i] = currentAIGangFactions[#currentAIGangFactions]
            currentAIGangFactions[#currentAIGangFactions] = nil
            break
        end
    end
    local currentMinorFactions = World.currentMinorFactions
    for i = 1, #currentMinorFactions do
        if e.faction == currentMinorFactions[i] then
            currentMinorFactions[i] = currentMinorFactions[#currentMinorFactions]
            currentMinorFactions[#currentMinorFactions] = nil
            break
        end
    end
end

function World.preLoadingScreenSetup() -- This is here so we can start the audio for the location when we first start loading.
    if not World.setupComplete then
        initializeCurrentGameNeighborhoods()
    end
end

-- This function should only be used for non-standard editor startups
function World.setupAll()
    while not (World.updateSetup()) do
    end
end

function World.setupWithStartIntro()
    game:setStartGameUpdater(
        function()
            local r = World.updateSetup()
            if r then
                World.startIntroCinematic()
            end
            return r
        end
    )
end

-- This is called when setting up a new game, for loading a save game see World.updateSetupAndload
function World.updateSetup()
    if rgperf then rgperf.pushMarker("World.setup " .. _worldSetupPhase) end
    -- print("World.updateSetup", _worldSetupPhase)
    if _worldSetupPhase == "InitPlayer" then
        World.updateActiveEntitlements()
        if World.player == nil then
            initializePlayer()
        end
        if World.activeNeighborhoodConfigIds == nil then
            initializeCurrentGameNeighborhoods()
        end
        World.setGameSave(nil)
        if rgperf then rgperf.popMarker() end
        if World.setupComplete then
            _worldSetupPhase = "Complete"
            return true
        end
        _worldSetupPhase = "WorldState"
        return false

    elseif _worldSetupPhase == "WorldState" then

        require("Libs.LootDropLib").setup()
        World.difficulty = settings:getInteger("difficulty", World.difficulty or 3)
        World.maxCrewSize = settings:getInteger("maxCrewSize", World.maxCrewSize or 100)
        
        local bossRunawayEnabled = false
        if World.isBossRunawayEnabled ~= nil then
            bossRunawayEnabled = World.isBossRunawayEnabled
        end
        
        World.isBossRunawayEnabled = settings:getBool("isBossRunawayEnabled", bossRunawayEnabled)
        
        local needCheckProductionYear = true
        if World.needCheckProductionYear ~= nil then
            needCheckProductionYear = World.needCheckProductionYear
        end
        
        World.needCheckProductionYear = settings:getBool("needCheckProductionYear", needCheckProductionYear)
        
        World.behaviours:add("Achievements")
        World.behaviours:add("NonStackableWorldModifierManager")
        World.behaviours:add("NicknameManager")
        World.behaviours:add("NeighborhoodNicknameManager")
        World.behaviours:add("RPCNetwork")
        World.behaviours:add("AIConversations")
        World.behaviours:add("GameLifecycle")
        World.behaviours:add("AutoSaver")
        World.behaviours:add("AlertQueueChecker")
        World.behaviours:add("GameOverChecker")
        World.behaviours:add("ConqueredBuildingChecker")
        World.behaviours:add("LootCrates")
        World.behaviours:add("AlcoholHistoryTracker")
        World.behaviours:add("BarkeepMissionGenerator")
        World.behaviours:add("PoliceActivityWatcher")
        World.behaviours:add("PostBattleHealing")
        -- TODO Turn off modifiable config builder logic before certification, need turn on after sending build to certification
        --World.behaviours:add("ConfigModifierScheduler")

        if World.hasActiveEntitlement(RomeroGames.DLCName.DLC4) then
            World.behaviours:add("BlackmailEventManager")
        end

        World.stateHandle = World.behaviours:add("WorldState")
        World.autoResolveState = AutoResolveState:new()
        worldState = World.behaviours:getInterface(World.stateHandle)
        worldState:setup(World)
        _worldSetupPhase = "InitRPCs"
        if rgperf then rgperf.popMarker() end
        return false

    elseif _worldSetupPhase == "InitRPCs" then

        if not updateInitializeRPCs() then
            if rgperf then rgperf.popMarker() end
            return false
        end

        initializeCurrentGameFactions()
        initializeCurrentGameAgencies()
        _worldSetupPhase = "InitFollowers"
        if rgperf then rgperf.popMarker() end
        return false

    elseif _worldSetupPhase == "InitFollowers" then

        if not updateInitializeFollowers() then
            if rgperf then rgperf.popMarker() end
            return false
        end

        _worldSetupPhase = "InitLocations"
        if rgperf then rgperf.popMarker() end
        return false

    elseif _worldSetupPhase == "InitLocations" then

        initializeLocationsAndPrecincts()
        _numExteriorLocationsAtStart = client.location:getNumExteriorLocations()
        _worldSetupPhase = "CreateExteriorLocations"
        _nextExteriorLocationIndexToCreate = 0
        if rgperf then rgperf.popMarker() end
        return World.updateSetup()

    elseif _worldSetupPhase == "CreateExteriorLocations" then

        if _nextExteriorLocationIndexToCreate < _numExteriorLocationsAtStart then
            client.location:createExteriorLocation(_nextExteriorLocationIndexToCreate)
            _nextExteriorLocationIndexToCreate = _nextExteriorLocationIndexToCreate + 1
        else
            applyDifficultyModifiers(World.currentGangFactions, World.difficulty)

            World.neighborhoodProsperities = {}
            populateBehaviour(World.locations, "Prosperity", World.neighborhoodProsperities)

            World.neighborhoodSynergies = {}
            populateBehaviour(World.locations, "Synergy", World.neighborhoodSynergies)

            initPrecinctShapes(false)
            buildLocationNeighbors()
            buildPrecinctAccessLinks()

            _worldSetupPhase = "InitTraffic"
        end
        if rgperf then rgperf.popMarker() end
        return false

    elseif _worldSetupPhase == "InitTraffic" then

        initializeTraffic()
        initializeStreetcars()
        _worldSetupPhase = "InitConversations"
        if rgperf then rgperf.popMarker() end
        return false

    elseif _worldSetupPhase == "InitConversations" then
        ConversationMatcher:setup()
        
        local bossConfigId = World.playerFaction.bossId
        local bossConfig = ConfigBuilder.fromId(bossConfigId)
        World.behaviours:add("TimeManager")
        World.timeManager:initWithSelectedFaction(bossConfig, bossConfigId)
        
        World.behaviours:add("MoleManager")
        World.uiData:setup()
        World.invisibleiidCounter = 0
        World.setupComplete = true

        game:worldTimeCallback(World.processPendingConversations, 1)
        _worldSetupPhase = "Complete"

        initializeBlackMarket()

        if rgperf then rgperf.popMarker() end
        return true

    elseif _worldSetupPhase == "Complete" then -- Called when the base game layer is enabled after the world has been setup
        if rgperf then rgperf.popMarker() end
        return true

    else
        logError("World.updateSetup has invalid phase", _worldSetupPhase)
        if rgperf then rgperf.popMarker() end
        return true
    end
end

-- This is called when loading a save game, for setting up a new game see World.updateSetup
function World.updateSetupAndLoad(loadData, gameSave)

    if _worldSetupAndLoadPhase == "Start" then

        World.initConfig = Config.WORLD.INIT
        World.curLoadData = loadData
        World.setGameSave(gameSave)
        World.actorSearch = ActorSearch:new()

        -- Build map of locations to be loaded
        World.curLoadDataLocations = {}
        local results = {}
        SaveState.findMatchingInstancesWithClass(World.curLoadData, require("World.Location"), results)
        for i = 1, #results do
            local resultLocation = results[i]
            World.curLoadDataLocations[resultLocation.id] = resultLocation
        end

        -- Build map of precincts to be loaded
        World.curLoadDataPrecincts = {}
        clearTable(results)
        SaveState.findMatchingInstancesWithClass(World.curLoadData, require("World.Precinct"), results)
        for i = 1, #results do
            local resultPrecinct = results[i]
            World.curLoadDataPrecincts[resultPrecinct.id] = resultPrecinct
        end

        require("Libs.LootDropLib").setup()
        _worldSetupAndLoadPhase = "LoadGameData"
        return false

    elseif _worldSetupAndLoadPhase == "LoadGameData" then

        if game:updateLoadData(loadData) then
            _worldSetupAndLoadPhase = "ApplyEntitlements"
        end
        return false

    elseif _worldSetupAndLoadPhase == "ApplyEntitlements" then

        if game:updateEntitlementsPostLoad() then
            _worldSetupAndLoadPhase = "FinalSetup"
        end
        return false

    elseif _worldSetupAndLoadPhase == "FinalSetup" then

        World.updateActiveEntitlements()
        ConversationMatcher:setup()
        World.uiData:setup(true)
        game:worldTimeCallback(World.processPendingConversations, 1)

        if World.hasActiveEntitlement(RomeroGames.DLCName.DLC4) and not World.behaviours:has("BlackmailEventManager") then
            World.behaviours:add("BlackmailEventManager")
        end

        if not World.behaviours:has("PostBattleHealing") then
            World.behaviours:add("PostBattleHealing")
        end

        _worldSetupAndLoadPhase = "Complete"
        return true

    else
        logError("Invalid world setupAndload phase", _worldSetupAndLoadPhase)
        if rgperf then rgperf.popMarker() end
        return true
    end
end

function World.teardown()
    teardownRPCs()
    teardownFollowers()
    teardownAgencies()
    teardownFactions()
    World.missions:destroy()
    World.placements:destroy()
    World.missionBuildings:destroy()
    World.questBuildings:destroy()
    World.tutorials:destroy()
    World.newspapers:destroy()
    World.scenarios:destroy()
    require("Libs.ActorCache").clear()
    client.ui.releaseTutorialArrow()
    client.transition:unloadCurrentLocation():callback(teardownLocations)
end

function World.shutdown()
    game:dispatchEvent{ name = "onWorldShutdown" }
    World.teardown()
end

function World.setFact(name, value)
    local typeOfV = type(value)
    if not(typeOfV == "string" or typeOfV == "number" or typeOfV == "nil" or typeOfV == "boolean" or typeOfV == "table") then
        logError("Unable to set fact: " .. tostring(name) .. "  - invalid type: " .. typeOfV)
        return false
    end
    World.facts[name] = value
    return true
end

function World.getFact(name)
    -- print("Getting fact: " .. tostring(name))
    return World.facts[name]
end

function World.getMission(missionId, ...)
    return World.missions:getMission(missionId, ...)
end

function World.isMissionActive(missionId, ...)
    local mission = World.missions:getMission(missionId, ...)
    if mission then
        return mission._status == "InProgress"
    else
        return false
    end
end

function World.setFocusedMissionById(missionId)
    local mission = World.missions:getMission(missionId)
    if mission then
        World.missions:setFocusedMission(mission)
    else
        logError("No mission with that ID")
    end
end

function World.setFocusedMission(mission)
    World.missions:setFocusedMission(mission)
end

function World.toggleFocusMission(mission)
    World.missions:toggleFocusMission(mission)
end

function World.getFocusedMission()
    return World.missions._focusedMission
end

function World.addSubMission(missionId, notify, parent, ...)
    return World.missions:createSubMission(missionId, notify, parent, ...)
end

function World.addMission(missionId, ...)
    local mission = World.missions:createMission(missionId, ...)
    return mission
end

function World.testMission(missionId, testFunctionName, ...)
    testFunctionName = testFunctionName or "onMissionStart"
    local mission = World.missions:getMission(missionId)
    if mission then
        mission = World.missions:testExistingMission(missionId, testFunctionName, ...)
    else
        mission = World.missions:testMission(missionId, testFunctionName, ...)
    end

    World.missions:setFocusedMission(mission)
    return mission
end

function World.failMission(missionId, ...)
    local mission = World.missions:failMission(missionId, ...)
    return mission
end

function World.resetMission(missionId)
    World.missions:resetMission(missionId)
end

function World.getNumTotalMissions()
    return World.missions:getNumTotalMissions()
end

function World.getActiveMissions(missionList)
    World.missions:getActiveMissions(missionList)
    return missionList
end

function World.getCompletedMissions(missionList)
    World.missions:getCompletedMissions(missionList)
    return missionList
end

function World.getFailedMissions(missionList)
    World.missions:getFailedMissions(missionList)
    return missionList
end

function World.getTopLevelMissions(missionList)
    World.missions:getTopLevelMissions(missionList)
    return missionList
end

function World.getTopLevelClosedMissions(missionList)
    World.missions:getTopLevelClosedMissions(missionList)
    return missionList
end

function World.getTopLevelMainMissions(missionList)
    World.missions:getTopLevelMainMissions(missionList)
    return missionList
end

function World.getTopLevelSideMissions(missionList)
    World.missions:getTopLevelSideMissions(missionList)
    return missionList
end

function World.getTopLevelActiveStoryMissions(missionList)
    World.missions:getTopLevelActiveStoryMissions(missionList)
    return missionList
end

-- Active or completed Boss missions, CMA
function World.getAllTopLevelMainMissions(missionList)
    World.missions:getAllTopLevelMainMissions(missionList)
    return missionList
end

--Active or completed Side missions (eg Izzys Been Busy, Just a deflector...)
function World.getAllTopLevelSideMissions(missionList)
    World.missions:getAllTopLevelSideMissions(missionList)
    return missionList
end

--Active or completed Bridging missions (eg Get 5 rackets, Produce 20 barrels of alcohol...)
function World.getAllTopLevelBridgingMissions(missionList)
    World.missions:getAllTopLevelBridgingMissions(missionList)
    return missionList
end

function World.createPlacement(rule, priority)
    return World.placements:createPlacement(rule, priority)
end

function World.startTutorial(tutorialId)
    return World.tutorials:startTutorial(tutorialId)
end

function World.dispatchTutorialEvent(name, ...)
    World.tutorials:dispatchTutorialEvent(name, ...)
end

function World.queueTutorial(tutorialId)
    World.tutorials:queueTutorial(tutorialId)
end

function World.isTutorialActive()
    return World.tutorials:isTutorialActive()
end

function World.isTutorialAmbidexterity()
    return World.tutorials:isTutorialAmbidexterity()
end

function World.isMainTutorialActive()
    return World.tutorials:isTutorialActive() and not World.gameLifecycle:hasStartingTutorialCompleted()
end

function World.canStartTutorial(tutorialId)
    if World.tutorials:isTutorialForced(tutorialId) then
        return true
    end

    return LateRequires.getSettings().tutorialsActive and not World.isTutorialActive() and not World.tutorials:hasShownTutorial(tutorialId)
end

function World.tryStartTutorial(tutorialId)
    if World.canStartTutorial(tutorialId) then
        World.startTutorial(tutorialId)
    end
end

function World.registerUIWithTutorials(key, controller)
    if World.tutorials then
        World.tutorials:registerUI(key, controller)
    else
        _registeredTutorialUI[key] = controller
    end
end

function World.showRemovedUnusableItemsPrompt()
    local faction = World.player.faction
    for _, member in next, faction.members do
        if member.queueUnusableItemsRemovedMessage then
            World.confirmDialog({
                image = member.characterIcon,
                text = {"$WeaponProficiencyWarningText", member}, --$ Due to item and weapon changes, {0:name} has had one or more of {0:gender?his|her|their} items unequipped. Please review {0:gender?him|her|them} before entering combat.
                pause = true,
                usesNoButton = false,
            })
        end
    end
end

function World.createScenario(scenarioId)
    local configId = Scenarios.getScenarioConfigId(scenarioId)
    if configId then
        local config = ConfigBuilder.fromId(configId)
        local usesUnscaled = config and config._usesUnscaled
        if usesUnscaled then
            return World.unscaledScenarios:createScenario(scenarioId)
        else
            return World.scenarios:createScenario(scenarioId)
        end
    end
    logError("Invalid scenario id!", scenarioId)
end

function World.getScenarios(scenarioList)
    World.scenarios:getScenarios(scenarioList)
end

function World.getActiveScenarios(scenarioList)
    World.scenarios:getActiveScenarios(scenarioList)
end

function World.getWorldEvents()
    return World.worldEvents
end

function World.createSlicedTimer(time, slice, callbackObject)
    return World.slicedTimers:create(time, slice, callbackObject)
end

function World.setSlicedTimerCount(id, count)
    World.slicedTimers:setTimerCount(id, count)
end

function World.pushAchievementNotification(configId)
    World.achievementNotificationQueue = World.achievementNotificationQueue or Queue.newQueue()

    local emptyBefore = World.achievementNotificationQueueIsEmpty()

    World.achievementNotificationQueue:pushLast(configId)

    if emptyBefore then
        client.transition:enableLayer("AchievementAlert")
    end
end

function World.popAchievementNotification(configId)
    return World.achievementNotificationQueue:popLast()
end

function World.achievementNotificationQueueIsEmpty()
    return World.achievementNotificationQueue and World.achievementNotificationQueue:isEmpty()
end

function World.refreshAchievements()
    local platformType = client.platform.platformType
    local achievementIds = {}
    local count = 0
    for configId, achievementData in next, Config.ACHIEVEMENTS do
        count = count + 1
        achievementIds[count] = achievementData.achievementId

        count = count + 1
        if platformType == PlatformType.PS4 then
            achievementIds[count] = achievementData.ps4AchievementId
        elseif platformType == PlatformType.XboxOne or platformType == PlatformType.UWP or platformType == PlatformType.Win64_GDK then
            achievementIds[count] = _s[achievementData.xboxAchievementId]
        elseif platformType == PlatformType.Win64 or platformType == PlatformType.Mac then
            achievementIds[count] = _s[achievementData.steamAchievementId]
        else
            achievementIds[count] = achievementData.achievementId
        end
    end
    client.platform:refreshAchievements(achievementIds)
end

function World.setCharacterLocation(character, locationId, spawnRotation, requestAutoSave)
    if not World.locationExists(locationId) then return end

    local curLocation = World.getLocation(character:getLocationId())
    local targetLocation = World.getLocation(locationId)
    local targetLocationIdForCamera = locationId

    targetLocation:addPendingActor()
    local pendingEntries = targetLocation:getPendingEntries()

    -- If there is no one left in the selection group then we need to follow this character into the location
    local selectedGroup = SelectionProcessor.getActiveGroup()

    -- Check to see whether the transitioning actor is currently selected, and whether they are the last one in the active location / exterior

    local followActor = false
    if curLocation.isInterior then
        local found = false
        local activeInLocation = 0
        for i = 1, #selectedGroup do
            local cur = selectedGroup[i]
            found = found or cur == character
            if cur:getLocationId() == World.currentLocationId then
                activeInLocation = activeInLocation + 1
            end
        end
        followActor = (found and activeInLocation == 1)
    elseif curLocation.isExterior then
        local found = false
        local activeInLocation = 0
        for i = 1, #selectedGroup do
            local cur = selectedGroup[i]
            found = found or cur == character
            local characterLocation = World.getLocation(cur:getLocationId())
            if characterLocation.isExterior then
                activeInLocation = activeInLocation + 1
            end
        end
        followActor = (found and activeInLocation == 1)
    end

    -- The function that will move the actors when the location is loaded
    local function changeActorLocation()

        character.behaviours:blockCommands(false)

        -- Validate the location
        if not World.locationExists(locationId) then return end

        local dPos
        local sPos
        local rot
        local building = curLocation.building
        local targetLocationIsMissionBuilding = targetLocation.building and targetLocation.building:isMissionBuilding()

        --check we're not moving from one interior to another(Happens with mission buildings)
        if building and not targetLocationIsMissionBuilding then

            --Move back to safehouse if leaving a mission building(in the void)
            if building:isMissionBuilding() then
                building = World.playerFaction:getPrimarySafehouseOrRacket()
                if not building then
                    building = World.playerFaction:getStartingSafehouse()
                end
                targetLocationIdForCamera = building:getLocationId()
            end

            dPos = building.doorInteractionPos
            sPos = building.doorSpawnPos
            rot = spawnRotation
        else
            local station = LateRequires.getWorldLibs().getInteriorMainDoorEntranceStation(targetLocation.building)
            -- Flip the spawn position around so that the entry positions are generated inside the building
            local offset = Vector3(0, 0, 1)
            local from = Quaternion.AngleAxis(station.rot, Vector3.up) * offset
            dPos = station.pos
            sPos = dPos + Vector2(from.x, from.z)
            rot = station.rot
        end

        local moveLocations, moveLocationRot = NavigationProcessor.getBuildingEntryPositions(pendingEntries, dPos, sPos)
        rot = rot or moveLocationRot

        -- Add a little jitter to prevent character's spawning in exactly same position.
        -- The NavAgent will separate overlapping characters as long as their positions are not equal.
        local newPos = moveLocations[pendingEntries]
        newPos.x = newPos.x + (math.random() - 0.5) * 0.1
        newPos.y = newPos.y + (math.random() - 0.5) * 0.1

        character:setLocationId(targetLocationIdForCamera, newPos, rot)
    end

    if followActor then

        character.behaviours:blockCommands(true)

        CameraUtils.gotoLocation(targetLocationIdForCamera, nil, true, function()
            changeActorLocation() -- Removes the command block added above
            CameraUtils.focusOnActor(character)

            if requestAutoSave then
                client.transition:callback(function()
                    game:dispatchPooledEvent("onRequestAutoSave", "reason", "Transition")
                end)
            end

        end)
    else
        changeActorLocation()
    end
end

-- TODO: Merge with WorldContextUtils.findSpawnPoint
local waypoints = {}
local visited = {}
function World.getSpawnPointNear(pos, location, ignoreVisibility)
    if not World.locations[location].waypointNetwork then
        return
    end

    clearTable(waypoints)
    clearTable(visited)

    World.locations[location].waypointNetwork:getNearestWaypoints(pos, 4, waypoints)

    local cur
    local minDist = 20 * 20
    if WorldMapController:isWorldMapActive() then
        return waypoints[#waypoints].pos
    end
    while #waypoints > 0 do
        cur = waypoints[#waypoints]
        waypoints[#waypoints] = nil
        visited[cur] = true

        local dist = (pos - cur.pos).sqrMagnitude
        if dist < minDist or (not ignoreVisibility and client.camera:isPointVisible(cur.pos)) then
            local numLinks = cur:numLinks()
            while numLinks > 0 do
                numLinks = numLinks - 1
                local link = cur:getLink(numLinks)
                local linkStart = link.start
                if not visited[linkStart] then
                    waypoints[#waypoints + 1] = linkStart
                end
                local linkEnd = link["end"]
                if not visited[linkEnd] then
                    waypoints[#waypoints + 1] = linkEnd
                end
            end
        else
            -- Pick this node!
            return cur.pos
        end
    end
end

function World.getWardOwnership(result, faction)
    clearTable(result)
    local index = 1
    for i = 1, #World._exteriorLocations do
        if World._exteriorLocations[i].getOwnershipPercent then
            local percent = World._exteriorLocations[i]:getOwnershipPercent(faction)
            if percent > 0 then
                result[index] = percent
                index = index + 1
            end
        end
    end
end

function World.isInSameNeighborhood(thisActor, otherActor)
    local thisLocationId = thisActor:getLocationId()
    local otherLocationId = otherActor:getLocationId()

    if thisLocationId == 0 or otherLocationId == 0 then return false end
    if thisLocationId == otherLocationId then return true end

    -- Otherwise check if one or both are inside locations in the same neighborhood
    local thisLocation = World.getLocation(thisLocationId)
    local otherLocation = World.getLocation(otherLocationId)

    return World.areLocationsInSameNeighborhood(thisLocation, otherLocation)
end

function World.areLocationsInSameNeighborhood(locationA, locationB)

    if locationA == nil or locationB == nil then return false end

    if locationA.isInterior then
        local id = locationA.building.locationId
        locationA = World.getLocation(id)
    end

    if locationB.isInterior then
        local id = locationB.building.locationId
        locationB = World.getLocation(id)
    end

    return (locationA and locationB) and locationA == locationB
end

function World.getActiveWards()
    local activeWards = {}
    for i = 1, #World.activeNeighborhoodConfigIds do
        activeWards[#activeWards + 1] = World._exteriorLocationsByConfigId[World.activeNeighborhoodConfigIds[i]]
    end

    return activeWards
end

local conversationQueue = {}
local _waitForConversationLayer = false

local function _stopWaitForConversationLayer()
    _waitForConversationLayer = false
end

local function _nextConversation()
    _waitForConversationLayer = true
    local conversationParams = conversationQueue[1]
    conversationParams.enterConversationCombatLock = World.addCombatLock("enterConversationCombatLock")
    table.remove(conversationQueue, 1)

    local visualConfigId = conversationParams.visualConfig
    local source = conversationParams.source
    local curVisualConfig = Config.CONVERSATION_VISUALS[visualConfigId]
    local enableConversationLayer = function()
        client.transition:enableLayerWithParams("ConversationLayer", conversationParams):callback(_stopWaitForConversationLayer)
    end

    if WorldMapController:isWorldMapActive() and curVisualConfig.conversationCamera then
        local locationId = source:getLocationId()
        local focalPoint = source:getPos()
        WorldMapController:closeToLocation(locationId, focalPoint, true, false)
        conversationParams.locationLock = World.addLocationLock("conversation")
        -- closeAndGoToFocalPointLocation() queues up some transitions so queue up a callback to
        -- run when those have completed
        client.transition:callback(enableConversationLayer)
        client.transition:fadeIn(0.1)
    else
        enableConversationLayer()
    end
end


function World.startConversation(source, target, visualConfigId, forcedEntryPoint, showPortrait, overwritePortrait)
    visualConfigId = visualConfigId or "DEFAULT"
    local conversationParams = {}
    conversationParams.source = source
    conversationParams.target = target
    conversationParams.visualConfig = visualConfigId
    conversationParams.entryPoint = forcedEntryPoint
    conversationParams.showPortrait = showPortrait
    conversationParams.overwritePortrait = overwritePortrait
    conversationQueue[#conversationQueue + 1] = conversationParams

    if World.canStartNextConversation() and (#conversationQueue == 1) then
        _nextConversation()
    end
end

function World.canStartNextConversation()
    return not _waitForConversationLayer
        and not World.hasWorldPause("Cinematic")
        and not World.inCombat()
        and (#conversationQueue > 0)
        and World.worldEvents:canDisplayEvents()
end

function World.onEventsUnblocked(self, e)
    World.processPendingConversations()
end

function World.onTutorialComplete(self, e)
    World.processPendingConversations()
end

function World.processPendingConversations()
    if not World.canStartNextConversation() or World.hasWorldPause() or client.transition.transitionQueued then
        return true
    end
    _nextConversation()
    return true
end

function World.frame(e)
    if worldState then
        worldState:update()
    end
end

local alertLayer
function World.confirmDialog(params)
    alertLayer:queueConfirmDialog(params)
end

function World.registerAlertLayer(layer)
    alertLayer = layer
end

local multiRenameLayer
function World.multiRenameDialog(params)
    multiRenameLayer:queueMultiRenameDialog(params)
end

function World.registerMultiRenameLayer(layer)
    multiRenameLayer = layer
end

--[[------------------------------------------------------------------------------
Modifier System
--------------------------------------------------------------------------------]]

World.modifiers = {
    cash = {},
    decision = {},
    rating = {},
    threat = {},
    honor = {},
    loyalty = {},
    generic = {},
}
World.cachedModifiers = {
    cash = {},
    decision = {},
    rating = {},
    threat = {},
    honor = {},
    loyalty = {},
    generic = {},
}
World.cachedSanityCheck = {}

local scopeKeys =
{
    actor       = math.pow(2,0),
    faction     = math.pow(2,1),
    location    = math.pow(2,2),
    precinct    = math.pow(2,3),
    breweries   = math.pow(2,4),
    speakeasies = math.pow(2,5),
    casinos     = math.pow(2,6),
    brothels    = math.pow(2,7),
    loanSharks  = math.pow(2,8),
    danceClubs  = math.pow(2,9),
    safehouses  = math.pow(2,10),
    derelict    = math.pow(2,11),
    depots      = math.pow(2,12),
}
scopeKeys.hasBuildingType = scopeKeys.breweries + scopeKeys.speakeasies + scopeKeys.casinos + scopeKeys.brothels + scopeKeys.loanSharks + scopeKeys.danceClubs + scopeKeys.safehouses + scopeKeys.derelict + scopeKeys.depots

local function createBitFieldFromModifierScopeConfig(sc)
    local result = 0
    if sc.actor or sc.targetFaction then -- Using both for the bit key, as they're exclusive states
        result = result + scopeKeys.actor
    end
    for k, v in next, scopeKeys do
        if sc[k] and k ~= "actor" then -- Already added actor/targetFaction
            result = result + v
        end
    end
    return result
end

local modifierConfigs
local baseConfigs
function World.getModifierDescriptions(id, actor)
    if World.behaviours:hasFunction(World.modifierDescriptionsHandle, id) then
        return World.behaviours:executeFunction(World.modifierDescriptionsHandle, id, actor)
    end
end

local function setupModifierConfigs()
    modifierConfigs =
    {
        cash =      Config.CASH_MODIFIERS,
        decision =  Config.DECISION_MODIFIERS,
        rating =    Config.RATING_EFFECT_MODIFIERS,
        threat =    Config.THREAT_EFFECT_MODIFIERS,
        honor =     Config.HONOR_EFFECT_MODIFIERS,
        loyalty =   Config.LOYALTY_MODIFIERS,
        generic =   Config.GENERIC_MODIFIERS,
    }
    baseConfigs =
    {
        cash =      Config.CASH_DATA,
        decision =  Config.FACTIONAI_DECISIONS,
        rating =    Config.RATING_EFFECTS,
        threat =    Config.THREAT_EFFECTS,
        honor =     Config.HONOR_EFFECTS,
        loyalty =   Config.LOYALTY_DATA,
        generic =   Config.GENERIC_DEFINITIONS,
    }
end

local eventsToSend = {}
local modifierEventListeners = {}
function World.addModifierListener(id, obj, property)
    if not modifierEventListeners[id] then
        modifierEventListeners[id] = {}
    end
    modifierEventListeners[id][obj] = property
end

function World.removeModifierListener(id, obj, property)
    if not modifierEventListeners[id] then
        return
    end
    modifierEventListeners[id][obj] = nil
end

function World.getModifierConfig(key)
    if not modifierConfigs then
        setupModifierConfigs()
    end
    return modifierConfigs[key]
end

local function applyModifierWithKeys(modifierId, entryKey, scopeKey, canStack)

    -- Data Structure: World.modifiers.cash.BREWERY_SM_COST.scopeKey.raw.entryKey

    -- rgperf.pushMarker("World.applyModifier:ITERATE_OVER_MODIFIERS")
    -- Iterating over CASH_MODIFIERS...etc
    for configKey, config in next, modifierConfigs do
        if config[modifierId] then
            -- Iterating over percent and raw
            for modifierType, values in next, config[modifierId] do
                -- Iterating over value types (i.e. BREWERY_SM_COST in CASH_DATA)
                for valueId, value in next, values do
                    local modifiers
                    if World.modifiers[configKey][valueId] then
                        World.cachedModifiers[configKey][valueId] = nil
                        modifiers = World.modifiers[configKey][valueId]
                    else
                        modifiers = {}
                        modifiers.entries = {}
                        local baseConfig = baseConfigs[configKey][valueId]
                        if not baseConfig then
                            logError(string.format("cannot find %s in the %s config. Do you need to download the latest datasheets?", valueId, configKey))
                        else
                            modifiers.baseValue = baseConfig.value or 0
                        end
                        World.modifiers[configKey][valueId] = modifiers
                    end

                    local modifierTypes
                    if modifiers.entries[scopeKey] then
                        modifierTypes = modifiers.entries[scopeKey]
                    else
                        modifierTypes = { applied = {} }
                        modifiers.entries[scopeKey] = modifierTypes
                    end
                    if not modifierTypes.applied[modifierId] then
                        modifierTypes.applied[modifierId] = {}
                    end
                    if modifierTypes.applied[modifierId][entryKey] then
                        if modifierTypes.applied[modifierId][entryKey] == true then -- Supporting older saves
                            modifierTypes.applied[modifierId][entryKey] = 1
                        end
                        if canStack then
                            modifierTypes.applied[modifierId][entryKey] = modifierTypes.applied[modifierId][entryKey] + 1
                            local modifierTypeEntries = modifierTypes[modifierType]
                            modifierTypeEntries[entryKey] = modifierTypeEntries[entryKey] + value
                            eventsToSend[#eventsToSend + 1] = valueId
                        end
                    else
                        modifierTypes.applied[modifierId][entryKey] = 1

                        local modifierTypeEntries
                        if modifierTypes[modifierType] then
                            modifierTypeEntries = modifierTypes[modifierType]
                        else
                            modifierTypeEntries = {}
                            modifierTypes[modifierType] = modifierTypeEntries
                        end
                        local curValue = modifierTypeEntries[entryKey] or 0
                        modifierTypeEntries[entryKey] = curValue + value
                        eventsToSend[#eventsToSend + 1] = valueId
                    end
                end
            end
        end
    end
    -- rgperf.popMarker()
    -- rgperf.pushMarker("onSystemModifiersUpdated")
end

-- Note: This takes faction.factionId not faction.configId
function World.applyModifier(modifierId, factionId, locationId, precinctId, target)
    if type(modifierId) == "table" then
        for i = 1, #modifierId do
            World.applyModifier(modifierId[i], factionId, locationId, precinctId, target)
        end
        return
    end
    local scopeConfig = Config.MODIFIER_DEFINITIONS[modifierId]
    if not scopeConfig then
        logError("Couldn't find modifier definition for", modifierId)
        return
    end
    local scopeKey = createBitFieldFromModifierScopeConfig(scopeConfig)

    factionId = factionId or 0
    locationId = locationId or 0
    precinctId = precinctId or 0
    local targetId = target and (target.iid or target.factionId) or 0

    if not modifierConfigs then
        setupModifierConfigs()
    end

    local entryKey = client.lua:createModifierEntryKey(scopeKey, factionId, locationId, precinctId, targetId)
    applyModifierWithKeys(modifierId, entryKey, scopeKey, scopeConfig.stacking)

    -- nil scope parameters for the events if not used
    if not (scopeConfig.actor or scopeConfig.targetFaction) then
        target = nil
    end
    if not scopeConfig.faction then
        factionId = nil
    end
    if not scopeConfig.location then
        locationId = nil
    end
    if not scopeConfig.precinct then
        precinctId = nil
    end

    for i = 1, #eventsToSend do
        local id = eventsToSend[i]
        local listeners = modifierEventListeners[id]
        if listeners then
            for obj, property in next, listeners do
                obj:onSystemModifiersUpdated(property, factionId, locationId, precinctId, target)
            end
        end
    end
    clearTable(eventsToSend)
    -- rgperf.popMarker()
end

function World.removeModifier(modifierId, factionId, locationId, precinctId, target)
    local scopeConfig = Config.MODIFIER_DEFINITIONS[modifierId]
    local scopeKey = createBitFieldFromModifierScopeConfig(scopeConfig)

    factionId = factionId or 0
    locationId = locationId or 0
    precinctId = precinctId or 0
    local targetId = target and (target.iid or target.factionId) or 0

    if not modifierConfigs then
        setupModifierConfigs()
    end

    local entryKey = client.lua:createModifierEntryKey(scopeKey, factionId, locationId, precinctId, targetId)

    -- Data Structure: World.modifiers.BREWERY_SM_COST.scopeKey.raw.entryKey

    local canStack = scopeConfig.stacking

    -- Iterating over CASH_MODIFIERS...etc
    for configKey, config in next, modifierConfigs do
        if config[modifierId] then
            -- Iterating over percent and raw
            for modifierType, values in next, config[modifierId] do
                -- Iterating over value types (i.e. BREWERY_SM_COST in CASH_DATA)
                for valueId, value in next, values do
                    World.cachedModifiers[configKey][valueId] = nil
                    local modifiers = World.modifiers[configKey][valueId]
                    if modifiers then
                        local scopeEntry = modifiers.entries[scopeKey]
                        if scopeEntry then
                            local scopeModifierGroup = scopeEntry.applied[modifierId]
                            local isApplied = false
                            if scopeModifierGroup then
                                if scopeModifierGroup[entryKey] == true then
                                    isApplied = true
                                    scopeModifierGroup[entryKey] = nil
                                    if not next(scopeEntry.applied[modifierId]) then
                                        scopeEntry.applied[modifierId] = nil
                                    end
                                elseif scopeModifierGroup[entryKey] then
                                    isApplied = true
                                    if canStack then
                                        scopeModifierGroup[entryKey] = scopeModifierGroup[entryKey] - 1
                                    else
                                        scopeModifierGroup[entryKey] = 0
                                    end
                                    if scopeModifierGroup[entryKey] <= 0 then
                                        scopeModifierGroup[entryKey] = nil
                                        if not next(scopeEntry.applied[modifierId]) then
                                            scopeEntry.applied[modifierId] = nil
                                        end
                                    end
                                end
                            end
                            if not next(scopeEntry.applied) then
                                modifiers.entries[scopeKey] = nil
                            else
                                local entryList = scopeEntry[modifierType]
                                if entryList and entryList[entryKey] and isApplied then
                                    entryList[entryKey] = entryList[entryKey] - value
                                    if entryList[entryKey] == 0 then
                                        entryList[entryKey] = nil
                                    end
                                end
                            end
                        end
                    end
                    eventsToSend[#eventsToSend + 1] = valueId
                end
            end
        end
    end
    -- rgperf.pushMarker("onSystemModifiersUpdated")

    -- nil scope parameters for the events if not used
    if not (scopeConfig.actor or scopeConfig.targetFaction) then
        target = nil
    end
    if not scopeConfig.faction then
        factionId = nil
    end
    if not scopeConfig.location then
        locationId = nil
    end
    if not scopeConfig.precinct then
        precinctId = nil
    end

    for i = 1, #eventsToSend do
        local id = eventsToSend[i]
        local listeners = modifierEventListeners[id]
        if listeners then
            for obj, property in next, listeners do
                obj:onSystemModifiersUpdated(property, factionId, locationId, precinctId, target)
            end
        end
    end
    clearTable(eventsToSend)
    -- rgperf.popMarker()
end

function World.getAppliedModifiers(configKey, id, factionId, locationId, precinctId, target, result)
    local modifiers = World.modifiers[configKey][id]
    if modifiers then
        factionId = factionId or 0
        locationId = locationId or 0
        precinctId = precinctId or 0
        local targetId = target and (target.iid or target.factionId) or 0
        local buildingTypeKey = (target and target.buildingType and _s[target.buildingType]) or 0
        local LuaService = client.lua
        local exteriorLocationId
        if locationId ~= 0 and not (target and target.buildingType) then
            local location = World.getLocation(locationId)
            if location.building then
                exteriorLocationId = location.building.locationId
            end
        end
        for scopeKey, scopedModifiers in next, modifiers.entries do
            local entryKey = LuaService:createModifierCheckKey(scopeKey, factionId, locationId, precinctId, targetId, buildingTypeKey)
            local exteriorEntryKey
            local interiorEntryKey
            if exteriorLocationId then
                exteriorEntryKey = LuaService:createModifierCheckKey(scopeKey, factionId or 0, exteriorLocationId, precinctId, targetId, buildingTypeKey)
            elseif target and target.interiorLocationId then
                interiorEntryKey = LuaService:createModifierCheckKey(scopeKey, factionId or 0, target.interiorLocationId, precinctId, targetId, buildingTypeKey)
            end
            local applied = scopedModifiers.applied
            for modifierId, entryKeys in next, applied do
                if entryKeys[entryKey] or (exteriorEntryKey and entryKeys[exteriorEntryKey]) or (interiorEntryKey and entryKeys[interiorEntryKey]) then
                    result[#result + 1] = modifierId
                end
            end
        end
    end
end

function World.getModifiedValue(configKey, id, factionId, locationId, precinctId, target, overridingValue)
    -- rgperf.pushMarker("getModifiedValue:", id)
    local buildingType = target and target.buildingType
    local sanityCheck = World.cachedSanityCheck[target]
    local cachedModifier = World.cachedModifiers[configKey][id]
    locationId = locationId or 0
    precinctId = precinctId or 0

    if sanityCheck
        and sanityCheck.factionId == factionId
        and sanityCheck.locationId == locationId
        and sanityCheck.precinctId == precinctId
        and sanityCheck.buildingType == buildingType
        and World.cachedModifiers[configKey][id]
        and World.cachedModifiers[configKey][id][target] then
        return World.cachedModifiers[configKey][id][target]
    end

    if not modifierConfigs then
        setupModifierConfigs()
    end

    local modifiers = World.modifiers[configKey][id]
    if not modifiers then
        if overridingValue then
            -- rgperf.popMarker()
            return overridingValue
        end
        local configNamespace = baseConfigs[configKey]
        if not configNamespace then
            logError("cannot find config namespace for " .. configKey)
            -- rgperf.popMarker()
            return 0
        end
        local config = configNamespace[id]
        if not config then
            logError("cannot find config for " .. id)
            -- rgperf.popMarker()
            return 0
        end
        return config.value
    end

    local baseValue = overridingValue or modifiers.baseValue
    local percentModifiers = 1
    local rawModifiers = 0
    local buildingTypeKey = (buildingType and _s[buildingType]) or 0

    -- Check if actor is inside a building, if so also apply the exterior location modifiers
    local exteriorLocationId
    if locationId ~= 0 and not buildingType then
        local location = World.getLocation(locationId)
        if location.building then
            exteriorLocationId = location.building.locationId
        end
    end

    local targetId = target and (target.iid or target.factionId) or 0
    local LuaService = client.lua
    local overrideWithZero = false
    for scopeKey, modifierTypes in next, modifiers.entries do
        local entryKey = LuaService:createModifierCheckKey(scopeKey, factionId or 0, locationId, precinctId, targetId, buildingTypeKey)
        local exteriorEntryKey
        local interiorEntryKey
        if exteriorLocationId then
            exteriorEntryKey = LuaService:createModifierCheckKey(scopeKey, factionId or 0, exteriorLocationId, precinctId, targetId, buildingTypeKey)
        elseif target and target.interiorLocationId then
            interiorEntryKey = LuaService:createModifierCheckKey(scopeKey, factionId or 0, target.interiorLocationId, precinctId, targetId, buildingTypeKey)
        end
        if modifierTypes.raw then
            if modifierTypes.raw[entryKey] then
                rawModifiers = rawModifiers + modifierTypes.raw[entryKey]
            end
            if exteriorEntryKey and exteriorEntryKey ~= entryKey and modifierTypes.raw[exteriorEntryKey] then
                rawModifiers = rawModifiers + modifierTypes.raw[exteriorEntryKey]
            elseif interiorEntryKey and interiorEntryKey ~= entryKey and modifierTypes.raw[interiorEntryKey] then
                rawModifiers = rawModifiers + modifierTypes.raw[interiorEntryKey]
            end
        end
        if modifierTypes.percent then
            if modifierTypes.percent[entryKey] then
                local p = modifierTypes.percent[entryKey]
                if p == -1 then -- Any individual modifier of -100% will cause the value to return 0
                    overrideWithZero = true
                    break
                end
                percentModifiers = percentModifiers + p
            end
            if exteriorEntryKey and exteriorEntryKey ~= entryKey and modifierTypes.percent[exteriorEntryKey] then
                local p = modifierTypes.percent[exteriorEntryKey]
                if p == -1 then -- Any individual modifier of -100% will cause the value to return 0
                    overrideWithZero = true
                    break
                end
                percentModifiers = percentModifiers + p
            elseif interiorEntryKey and interiorEntryKey ~= entryKey and modifierTypes.percent[interiorEntryKey] then
                local p = modifierTypes.percent[interiorEntryKey]
                if p == -1 then -- Any individual modifier of -100% will cause the value to return 0
                    overrideWithZero = true
                    break
                end
                percentModifiers = percentModifiers + p
            end
        end
    end

    local value
    if overrideWithZero then
        value = 0
    else
        percentModifiers = math.max(0, percentModifiers)

        if (baseValue + rawModifiers) < 0 then -- Invert the percentage modifier if the base decision is
            local difference = 1 - percentModifiers
            percentModifiers = 1 + difference
            percentModifiers = math.max(0, percentModifiers)
        end

        value = (baseValue + rawModifiers) * percentModifiers
        -- print("baseValue: " .. baseValue .. ", rawModifiers: " .. rawModifiers .. ", percentModifiers: " .. percentModifiers .. ", value: " .. value)
        if configKey == "cash" then -- Don't pass back negative cash values
            value = math.max(0, value)
        end
    end


    if not overridingValue then -- Do not cache dynamic values
        if target then
            cachedModifier = cachedModifier or {}
            World.cachedModifiers[configKey][id] = cachedModifier
            cachedModifier[target or 0] = value

            -- Remembering what the state of the target was when we calculated the cached value,
            -- This makes sure modifiers don't stay if faction/location/racketType changes
            sanityCheck = sanityCheck or {}
            sanityCheck.factionId = factionId
            sanityCheck.locationId = locationId
            sanityCheck.precinctId = precinctId
            sanityCheck.buildingType = buildingType
            World.cachedSanityCheck[target] = sanityCheck
        end
    end
    -- rgperf.popMarker()

    return value
end

local buildingsToValidate = {}
function World.validateModifiers()
    clearTable(buildingsToValidate)
    local modifiersToReapply = {}
    for configType, modifierGroup in next, World.modifiers do
        local configGroup = modifierConfigs[configType]
        for configKey, modifiers in next, modifierGroup do
            for scopeKey, entryGroup in next, modifiers.entries do
                local modifiersToReapplyAtScopeKey = modifiersToReapply[scopeKey]
                if not modifiersToReapplyAtScopeKey then
                    modifiersToReapplyAtScopeKey = {}
                    modifiersToReapply[scopeKey] = modifiersToReapplyAtScopeKey
                end
                for modifierKey, appliedGroup in next, entryGroup.applied do
                    local entriesToReapply = modifiersToReapplyAtScopeKey[modifierKey]
                    if not entriesToReapply then
                        entriesToReapply = {}
                        modifiersToReapplyAtScopeKey[modifierKey] = entriesToReapply
                    end
                    for entryKey, v in next, appliedGroup do
                        -- Update to modifiers, now hold on to the number of times applied
                        entriesToReapply[entryKey] = (type(v) == "number") and v or 1
                    end
                end
            end
        end
    end

    World.modifiers = {
        cash = {},
        decision = {},
        rating = {},
        threat = {},
        honor = {},
        loyalty = {},
        generic = {},
    }
    World.cachedModifiers = {
        cash = {},
        decision = {},
        rating = {},
        threat = {},
        honor = {},
        loyalty = {},
        generic = {},
    }
    World.cachedSanityCheck = {}

    for scopeKey, modifiers in next, modifiersToReapply do
        for modifierId, entries in next, modifiers do
            for entryKey, count in next, entries do
                count = (count == true) and 1 or count
                for i = 1, count do
                    local scopeConfig = Config.MODIFIER_DEFINITIONS[modifierId]
                    if scopeConfig then
                        applyModifierWithKeys(modifierId, entryKey, scopeKey, scopeConfig.stacking)
                    end
                end
            end
        end
    end

    for id, listeners in next, modifierEventListeners do
        if listeners then
            for obj, property in next, listeners do
                obj:onSystemModifiersUpdated(property)
                if obj._o and obj._o.generatesIncome then
                    buildingsToValidate[obj._o] = true
                end
            end
        end
    end
    -- Update building income
    for building, _ in next, buildingsToValidate do
        building:setModifier()
    end
end

function World.renameOrRemoveModifiers(nameReplacements)
    local replacementsCache = {}
    for configType, modifierGroup in next, World.modifiers do
        for configKey, modifiers in next, modifierGroup do
            for scopeKey, entryGroup in next, modifiers.entries do
                clearTable(replacementsCache)
                for modifierKey, appliedGroup in next, entryGroup.applied do
                    if nameReplacements[modifierKey] ~= nil then
                        entryGroup.applied[modifierKey] = nil
                        local newKey = nameReplacements[modifierKey]
                        if newKey then -- if newKey == false then don't save entryGroup
                            replacementsCache[newKey] = appliedGroup
                        end
                    end
                end
                for k, v in next, replacementsCache do
                    entryGroup.applied[k] = v
                end
            end
        end
    end
    World.validateModifiers()
end

function World.lockEconomy()
    World.lockedForEconomyLoop = true
    require("AI.Factions.FactionAI").disable("economyLoop")
    local factions = World.currentGameFactions
    for i = 1, #factions do
        local faction = factions[i]
        if faction.isGang and not faction.isThugFaction then
            faction.alcohol:lockForEconomyLoop()
            faction.alcohol:sortConsumption()
            faction.cash:lockForEconomyLoop()
            faction.cash:sortExpenses()
        end
    end
end

if Dev then
    Dev.world = World
    Dev.worldPauseKeys = _worldPauseKeys
    Dev.pauseKeys = _pauseKeys
end

return World

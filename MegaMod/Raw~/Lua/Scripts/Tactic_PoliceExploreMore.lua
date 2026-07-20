--[[------------------------------------------------------------------------------
    Welcome! In this advanced modding tutorial we're going to learn how to:
        - Create a new AI tactic for the Chicago Police faction that sends a squad of
          police to neighborhoods with high police activity.
        - Show a game alert when this happens.

    For more details and examples, check out the FactionAI.lua class and
    other tactics (they are lua files prefaced by "Tactic_" in the main codebase).

    Note that the code in each step below could be placed in separate files
    (as long as they are in a subdirectory of the Lua/Scripts directory).
--------------------------------------------------------------------------------]]


--[[------------------------------------------------------------------------------
    Step 1: We create some configuration variables we can use later in our code.
--------------------------------------------------------------------------------]]

_namespace = "POLICE_EXPLORE_MORE" -- We use a namespace based on the name of our mod to avoid clashes with other mods
_id = "DEFAULTS"

-- The maximum number of explore more tactics to have running at once.
maxNumExploreMoreTactics = 3

-- The number of points to explore when building a path to explore in the neighborhood.
numMoreExploreWaypoints = 4

-- The PoliceActivity value for a precinct at which the police consider sending a larger squad (the range is from 0 to 100).
policeActivityThreshold = 60



--[[------------------------------------------------------------------------------
    Step 2: We setup data for our custom User Interface alert that we will display.
--------------------------------------------------------------------------------]]

_namespace = "UI.GAMEALERTS" -- This is the namespace for defining alerts
_id = "POLICE_EXPLORE_MORE" -- We use a custom id based on the name of our mod to avoid clashes with other mods

_includes = "BASE"  -- We inherit from the default game alert values
textColor = "red"   -- Set the text color
audio = "AUDIO.UI.NOTIFICATION_BAD"  -- Set the audio to play
text = "$POLICE_EXPLORE_MORE_alert" --$ Police are sending a large squad to {0}!



--[[------------------------------------------------------------------------------
    Step 3: We register our tactic with the FactionAI system.

    We inform the system about the name of our custom evaluator and tactic.
    We also say to which type of faction the tactic should apply and what AI need that
    the tactic satisfies.

    In this tutorial we only care about the top-level (Agenda) AI need.
    Top-level needs (or Agenda) are the things that the faction AI decide to do as highest priority.
        For example, exploring, attacking, expanding, diplomacy, saving money.
--------------------------------------------------------------------------------]]

_namespace = "FACTIONAI_TACTICS"

_id = "POLICE_EXPLORE_MORE"
name = "policeExploreMore"  -- The name of the evaluator for the tactic

-- This tactic is used by law enforcement factions only and is ignored by gangs and minor factions.
USED_BY =
{
    LAW_ENFORCEMENT = true,
    GANG = false,
    MINOR_FACTION = false,
}

NEED =
{
    AGENDA = true,   -- This tactic fulfills a top-level decision (or Agenda)
}


--[[------------------------------------------------------------------------------
    Step 4: We extend the existing police faction ai sensor object to persist where we are currently sending large squads.

    The ai sensor is a good place to store AI information that needs to persist between instances of running tactics.
    We will use it to store a map of the number of current custom explores for each neighborhood. This way, we avoid
    sending too many squads to the same neighborhood.
    
    Every FactionAI instance has a corresponding aiSensor.
        Police factions have a custom ai sensor defined as BEHAVIOURS.FACTIONAI_LAW_SENSOR.
        All other non-police factions currently use BEHAVIOURS.FACTIONAI_SENSOR.
--------------------------------------------------------------------------------]]

_namespace = "BEHAVIOURS"
_extends = "FACTIONAI_LAW_SENSOR" -- The id of the Police sensor object that we are modifying

-- Marking a variable with persist{} makes it automatically load and save
persist{}
exploreMoreInfo = nil -- This is the map between location id and the number of current explores.

-- This function is called by the evaluator (see Step 5) when it detects that the sensor needs to be setup.
function setupExploreMoreInfo()

    -- Create a new table for each neighborhood (exterior location) and set the number of current explores to zero.
    if not exploreMoreInfo then
        exploreMoreInfo = {}

        -- Loop over each exterior location in the game to get it's unique id
        -- We use the id as a key for the 'exploreMoreInfo' map in the sensor
        local locations = WorldUtils:getExteriorLocations()
        for _, location in ipairs(locations) do
            exploreMoreInfo[location.id] =
                {
                    curNumExplores = 0
                }
        end
    end

    -- We implement a Dev method to help us test the tactic.
    -- Enter Dev.policeExploreMoreAtPlayer() in the console when developerMode is active.
    -- This will raise police activity in the player's current neighborhood and should trigger the new tactic (unless the police are busy).
    -- Enter Dev.enableFogOfWar(false) to make it easier to see the squad in action once it spawns.
    if Dev then -- Always check Dev exists before using it

        function Dev.policeExploreMoreAtPlayer()

            -- Get the current precinct of the player character
            local playerPrecinct = Dev.player:getPrecinct()
            if playerPrecinct then

                -- Raise the police activity of that precinct so the tactic will be triggered.
                print("Dev.policeExploreMoreAtPlayer() raising player precinct police activity")
                playerPrecinct:addTemporaryPoliceActivity(100)
            end

        end
    end
end


--[[------------------------------------------------------------------------------
    Step 5: We create an evaluator function that returns a score based on the relevance of our tactic.

    Tactics with higher scores will be selected over tactics with lower scores.
    Returning a score of 0 or less means the system will not select the tactic.

    At the top level, the Faction AI system will look for evaluators that match the NEED.AGENDA flag (see Step 3).
    All matching evaluators are run to calculate scores, then the one with the best score is selected and the corresponding tactic is executed.

    Note that the name of the evaluator function (in our case, policeExploreMore) MUST match the name specified above in Step 3.
--------------------------------------------------------------------------------]]

_namespace = "TACTICS"
_extends = "TACTIC_EVALUATORS"  -- We add a custom evaluator function by extending this object.

-- To reduce Lua Garbage Collection pressure, we use a local variable that is shared between all instances of the tactic
local _possibleTargetLocations = {}

-- This function name MUST match the name in the FACTIONAI_TACTICS entry above
-- factionAI and personalityVars are objects always passed to an evaluator function (note, we are not using personalityVars in this tutorial)
function policeExploreMore(factionAI, personalityVars)

    -- Prevent police factions other than the chicago police from exploring (such as the Bureau)
    if factionAI.faction.configId ~= "FACTION.CHICAGO_POLICE" then
        return 0
    end

    -- Get a reference to our custom configuration table from Step 1
    -- The Config variable is globally accessable from all code
    local PoliceExploreMoreDefaults = Config.POLICE_EXPLORE_MORE.DEFAULTS
    local maxNumExploreMoreTactics = PoliceExploreMoreDefaults.maxNumExploreMoreTactics
    local policeActivityThreshold = PoliceExploreMoreDefaults.policeActivityThreshold

    -- Limit the number of concurrent explore more tactics
    local exploreMoreAgendas = factionAI:getTacticInterfaces("TACTICS.POLICE_EXPLORE_MORE")
    if exploreMoreAgendas and (#exploreMoreAgendas >= maxNumExploreMoreTactics) then
        return 0
    end

    -- Get a reference to the police faction's AI sensor object
    -- The AI sensor is a good place to store persistant state shared between tactic instances
    local aiSensor = factionAI.aiSensor
    local wardsLawInfo = aiSensor.wardsLawInfo
    local exploreMoreInfo = aiSensor.exploreMoreInfo

    -- First time initialization (exploreMoreInfo will be nil the first time this is ever run)
    if not exploreMoreInfo then
        aiSensor:setupExploreMoreInfo()
        exploreMoreInfo = aiSensor.exploreMoreInfo
    end

    -- Go through each neighborhood and add possible matches if any of their precincts has a high police activity
    clearTable(_possibleTargetLocations)
    local numPossibleTargetLocations = 0
    for locationId, exploreMoreNeighborhoodInfo in next, exploreMoreInfo do

        -- Every location in the world has a unique id. This is a number that can be saved/loaded safely.
        -- A location is either an interior (inside a building) an exterior (a neighborhood) or a cinematic location (for conversations)
        -- Exterior locations have a number of precincts that we can query for current police activity values.
        local location = WorldUtils:getLocationFromId(locationId)

        -- wardsLawInfo is a variable already defined in the police AI sensor that we can use to see if a blind eye is aalready active on a neighborhood.
        -- (We don't want to send squad patroling if the police is meant to be ignoring the neighborhood)
        local lawInfo = wardsLawInfo[locationId]
        if not lawInfo or (not lawInfo.hasBlindEye) then

            -- Do not have more than 1 of our tactics in a given ward (neighborhood)
            if exploreMoreNeighborhoodInfo.curNumExplores < 1 then
                -- If any of the precincts have high police activity then add the neighborhood to the list
                for i = 1 , #location.precincts do
                    local precinct = location.precincts[i]
                    if precinct:getPoliceActivity() >= policeActivityThreshold then
                        numPossibleTargetLocations = numPossibleTargetLocations + 1
                        _possibleTargetLocations[numPossibleTargetLocations] = location
                        break
                    end
                end
            end
        end
    end
    if numPossibleTargetLocations == 0 then
        -- No location found
        -- print("No location found!")
        return 0
    end

    -- Select one of the matching neighborhoods at random
    local selectedLocation = _possibleTargetLocations[math.random(numPossibleTargetLocations)]

    -- print("locationFound", selectedLocation.name)

    -- The number here is the score used when the system is comparing evaluator results
    -- The existing tactic evauluator for normal police patrols in game has a score of 100 so using 150 here ensures our tactic is always preferred.
    local resultScore = 150

    -- This evaluator passes the selected location to the tactic as an extra parameter. This parameter is automatically passed to the tactic's start function above.
    return resultScore, selectedLocation
end


--[[------------------------------------------------------------------------------
    Step 6: We implement the new tactic.
    This code will run if the tactic has been selected after evaluation.

    This code makes use of existing functions and objects that manage squads and allow them to explore.
--------------------------------------------------------------------------------]]

_namespace = "TACTICS"
_id = "POLICE_EXPLORE_MORE" -- This MUST match the id given in Step 3
_includes = "BASE"

-- Store the neighborhood we are exploring
persist{}
targetLocation = nil

-- Store a reference to the squad of police that are exploring
persist{}
exploreSquad = nil

-- Store a reference to the scenario script that manages exploring squads.
persist{}
exploreScenario = nil

-- Used to check if we have already completed the explore scenario script
persist{}
exploreScenarioCompleted = nil

-- The number of seconds until the next update call  (we do not need to persist this).
timeUntilUpdate = 1

function getName() -- Shows up on the diplomacy screen under agendas
    return "$Tactic_PoliceExplore_Name", targetLocation.name --$ Send Large Patrol to {0}
end

function getIcon() -- Shows up on the diplomacy screen
    return "Sprites/Diplomacy/FactionAI_Explore_W" -- Use the existing patrol icon on the diplomacy screen
end

-- This function is called when tactic is created
-- Note the location parameter is what we returned from the evaluator function in Step 5
function start(factionAI, personalityVars, location)
    
    targetLocation = location
    
    -- timer is a built-in variable that lets us control when we should next update
    -- worldTime is the amount of time that has passed (not including combat or paused time)
    timer = worldTime + timeUntilUpdate + introTime

    -- Increment the current number of explores on our custom police ai sensor entry (see Step 4)
    local aiSensor = factionAI.aiSensor
    local exploreMoreNeighborhoodInfo = aiSensor.exploreMoreInfo[location.id]
    exploreMoreNeighborhoodInfo.curNumExplores = exploreMoreNeighborhoodInfo.curNumExplores + 1

    -- Tactics have built-in support for simple state machines that can help organsize high-level logic.
    -- Call smEnterState(<StateName>) and it will automatically call onEnterState<StateName>()
    -- Then when smUpdateState() is called, it will automatically call onUpdate<StateName> until another state is entered.
    -- The current state is automatically loaded/saved.

    -- Entery the 'GetSquads' state
    smEnterState("GetSquads")
end

-- Called automatically by the system when the worldTime of the timer variable has been reached
function update()

    -- Update our custom State Machine
    smUpdateState()
end

-- This is a callback function that called when the explore scenario has completed. We register this below.
function onExploreScenarioComplete()
    exploreScenarioCompleted = true
    exploreScenario = nil
end

function onEnterStateGetSquads()
    -- Create a squad of police with power level 5
    local faction = thisObject.faction
    local powerLevel = 5
    local squadType = "Police"
    local maxNumSquadMembers = 5
    local squad = faction.squads:createUnmanaged(powerLevel, squadType, maxNumSquadMembers, true)
    squad.status = "exploring"
    exploreSquad = squad
end

function onUpdateStateGetSquads()
    -- We can just transition to the Explore state
    smEnterState("Explore")
end

-- This is a function to find a safe position near the edge of a location
-- Note: the underlying waypoint system is not explained in this tutorial
local waypointCache = {}
function findStartPosition()
    local edgeBuilding = WorldUtils:getRandomBuildingOnLocationEdge(targetLocation.id)
    if edgeBuilding then
        local rx = edgeBuilding.doorInteractionPos.x
        local ry = edgeBuilding.doorInteractionPos.y
        WorldUtils:getNearestWaypointsXY(rx, ry, 1, targetLocation, waypointCache)
        if #waypointCache > 0 then
            rx, ry = waypointCache[1]:xy()
            clearTable(waypointCache)
        end
        return rx, ry
    end
end

-- This is a function that looks for a safe position within a certain distance of the previous position
-- It uses the exterior door position of a building so that police will move between buildings.
-- Note: the underlying waypoint system is not explained in this tutorial
local _possibleBuildings = {}
function findNextPosition(lastTargetX, lastTargetY)
    clearTable(_possibleBuildings)
    local numPossibleBuildings = 0
    local buildings = targetLocation.buildings
    for i = 1, #buildings do
        local possibleBuilding = buildings[i]
        local interactionPos = possibleBuilding.doorInteractionPos
        local px = interactionPos.x
        local py = interactionPos.y
        local diffx = px - lastTargetX
        local diffy = py - lastTargetY
        local distSq = diffx * diffx + diffy * diffy
        if distSq > 1000 then
            numPossibleBuildings = numPossibleBuildings + 1
            _possibleBuildings[numPossibleBuildings] = possibleBuilding
        end
    end
    if numPossibleBuildings == 0 then
        return
    end
    local building = _possibleBuildings[math.random(numPossibleBuildings)]
    local rx = building.doorInteractionPos.x
    local ry = building.doorInteractionPos.y
    WorldUtils:getNearestWaypointsXY(rx, ry, 1, targetLocation, waypointCache)
    if #waypointCache > 0 then
        rx, ry = waypointCache[1]:xy()
        clearTable(waypointCache)
    end
    return rx, ry
end

-- This function registers for the "onTurnABlindEyeBegin" game event which is raised elsewhere in code when the police are bribed to ignore activity in a neighborhood.
-- It allows us to stop this tactic when this location is selected for the event.
function GameEvent.onTurnABlindEyeBegin(e)
    local blindEyeLocation = e.location
    if blindEyeLocation == targetLocation then
        completeAndRemoveTactic(true)
    end
end

function onEnterStateExplore()

    -- The explore scenerio script that we will be using expects a list of actions as input.
    -- The actions we need are:
        -- Spawn
            -- Tells the scenario the position where we want to spawn the squad
        -- Move
            -- Tells the scenario the next position to move the squad.
            -- Squads will move to the positions in the order of the actions.

    -- Select a number of buildings to explore at random
    local actionList =
    {
    }
    local numWaypoints = Config.POLICE_EXPLORE_MORE.DEFAULTS.numMoreExploreWaypoints
    local lastTargetX
    local lastTargetY
    local doCancel
    for i = 1, numWaypoints do
        local targetPositionX
        local targetPositionY
        if i == 1 then
            targetPositionX, targetPositionY = findStartPosition()
            -- Find any random building in the location
            actionList[#actionList + 1] =
            {
                action = "Spawn",
                x = targetPositionX,
                y = targetPositionY,
            }
        else
           targetPositionX, targetPositionY = findNextPosition(lastTargetX, lastTargetY)
           actionList[#actionList + 1] =
           {
                action = "Move",
                x = targetPositionX,
                y = targetPositionY,
           }
        end
        if not targetPositionX then
            doCancel = true
            break
        end
        lastTargetX = targetPositionX
        lastTargetY = targetPositionY
    end

    -- If we can't find anywhere to spawn then cancel by removing this tactic.
    if doCancel then
        completeAndRemoveTactic(false)
        return
    end

    for i = #actionList - 1, 2, -1 do
        actionList[#actionList + 1] = actionList[i]
    end

    -- printR(actionList, 2, "ACTION LIST")

    -- Show our custom game alert that we made in Step 2 above.
    Utils:showGameAlert("POLICE_EXPLORE_MORE", targetLocation.name)

    -- In development mode, log a message
    if Dev then
        print("Exploring more in", targetLocation.name)
    end

    -- Create the explore scenario and pass in our squad, action list and completion callback function
    exploreScenario = Utils:scenario("ExploreNeighborhood")
    exploreScenario:setOnComplete(scriptCallback("onExploreScenarioComplete"))
    exploreScenario:start(thisObject.faction, {exploreSquad}, targetLocation.id, actionList, nil, "None")
end

-- We wait here until the explore scenario is finished.
-- Our completion function will set exploreScenarioCompleted when this occurs.
function onUpdateStateExplore()
    -- If the explore scenario is complete then we are finished
    if exploreScenarioCompleted then
        exploreScenario = nil
        completeAndRemoveTactic(true)
    end
end

-- This function is automatically called if the tactic is removed for any reason
-- We should tidy up references to local variables here
function onRemoveTactic(result)
    if targetLocation then

        -- Tell our custom police ai sensor that we are no longer exploring
        local aiSensor = thisObject.aiSensor
        local exploreMoreInfo = aiSensor.exploreMoreInfo[targetLocation.id]
        exploreMoreInfo.curNumExplores = exploreMoreInfo.curNumExplores - 1

        -- If we were cancelled but have a running scenario then we should stop that scenario
        if exploreScenario then
            exploreScenario:stop()
            exploreScenario:destroy()
            exploreScenario = nil
        end

        -- We should remove our squads (this will automatically delete the squad members)
        if exploreSquad then
            exploreSquad:removeFromSquads()
            exploreSquad = nil
        end
    end
end

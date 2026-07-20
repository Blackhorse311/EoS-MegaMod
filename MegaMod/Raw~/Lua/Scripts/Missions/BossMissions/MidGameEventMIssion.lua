-- --------------------------------------------------
-- MidGameEventMission.lua
-- --------------------------------------------------
_namespace = "MISSIONS"
--[[------------------------------------------------------------------------------
HELP DEMOCRATS A
--------------------------------------------------------------------------------]]
_id = "HELP_DEMOCRATS_A"
_mission = "HelpDemocratsA"
_timeLimit = 29

persist{}
derelictPlacement = nil

persist{}
strangerPlacement = nil

persist{}
womanPlacement = nil

persist{}
derelict = nil

persist{}
woman = nil

persist{}
stranger = nil

persist{}
derelictMarker = nil

persist{}
conqueredBuilding = nil

-- MEGAMOD: softlock fix - street squad guarding the derelict (see MidGameDemocratA1 ConquerRacket)
persist{}
derelictSquad = nil

function onMissionCreate()
    defineMission
    {
        name = "$ChicagoStylePolitics",
        description = "$MidGameDemocratA_desc", --$ You have chosen to support the Democrats in the upcoming Gubernatorial elections... and they want you to do them a couple of favors. There's a Shady Stranger in town who wants to talk to you. See what he wants.
    }
    derelict = WorldUtils:getBuildingFromPlacement(derelictPlacement, true)

    stranger = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_NON_COMBAT_02", strangerPlacement)
    stranger.memory.ChicagoPolitics_Derelict = derelict
    woman = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_FEMALE_NON_COMBAT_02", womanPlacement)

    stranger:setConversationEntryPoint("ChicagoPolitics1_Start")
    woman:setConversationEntryPoint("ChicagoPolitics2_Start")

    derelictMarker = MissionUtils:placeMarker(derelict)
end

function onMissionStart()
    addSubMission("MidGameDemocratA1")
    addSubMission("MidGameDemocratA2")
    setTimeLimit(_timeLimit, "Days")
end

function onMissionSuccess()
    WorldUtils:triggerEvent("MidGameEventAEnd", "helpedDemocrats", true)
end

function onMissionFail()
    if derelictPlacement then
        derelictPlacement:release()
    end
    if strangerPlacement then
        strangerPlacement:release()
    end
    if womanPlacement then
        womanPlacement:release()
    end

    if stranger then
        stranger:delete()
    end
    if woman then
        woman:delete()
    end
    -- MEGAMOD: softlock fix - disband the street squad
    if derelictSquad then
        derelictSquad:removeFromSquads()
    end
    if derelictMarker then
        derelictMarker:delete()
    end
end

-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function resetMission()
    fact.ChicagoPolitics_MetStranger = false
    fact.ChicagoPolitics_ReturnedToStranger = false
    fact.ChicagoPolitics_MetWoman = false
    fact.ChicagoPolitics_ReturnedToWoman = false
    fact.ChicagoPolitics_RejectedTask1 = false
    fact.ChicagoPolitics_RejectedTask2 = false

    onMissionFail()
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == derelictPlacement then
        if fact.ChicagoPolitics_MetStranger and ((e.reason == "ConqueredByPlayer") or (e.reason == "ClearedOutByPlayer")) then
            conqueredBuilding = true
            derelictPlacement = nil
        else
            derelictPlacement = WorldUtils:acquirePlacement(
                MissionUtils:derelictRacketInPlayerOrThugPrecinct()
            )
            if not derelictPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            derelict = WorldUtils:getBuildingFromPlacement(derelictPlacement, true)

            MissionUtils:placeMarker(derelict, derelictMarker.iid)

            -- MEGAMOD: softlock fix - move the street squad to the new derelict
            if derelictSquad then
                MissionUtils:placeSquad(derelictSquad, derelictPlacement.locationId, derelictPlacement.station.pos)
            end
        end
    end
end

function onMissionTimeout()
    if not fact.ChicagoPolitics_ReturnedToStranger then
        fact.ChicagoPolitics_RejectedTask1 = true
    end
    if not fact.ChicagoPolitics_ReturnedToWoman then
        fact.ChicagoPolitics_RejectedTask2 = true
    end
end

--[[------------------------------------------------------------------------------
MID GAME EVENT DEMOCRAT A I
--------------------------------------------------------------------------------]]
_id = "MID_GAME_DEMOCRAT_A_1"
_mission = "MidGameDemocratA1"

persist{}
stranger = nil

persist{}
derelictMarker = nil

-- MEGAMOD: softlock fix - street squad guarding the derelict (see ConquerRacket)
persist{}
derelictSquad = nil

function onMissionCreate()
    defineMission
    {
        name = "$MidGameDemocratA1_name", --$ Get Intel
        description = "$MidGameDemocratA1_desc", --$ The Shady Stranger told you that there's some intel on the Republicans being held in a racket nearby. Take out the knuckleheads guarding the place and the Democrats will be grateful.
    }
    stranger = getParentValue("stranger")
    derelictMarker = getParentValue("derelictMarker")
end

function onMissionStart()
    addObjective("MeetStranger")
end

function onMissionSuccess()
    stranger.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("stranger", nil)

    getParentValue("strangerPlacement"):release()
    setParentValue("strangerPlacement", nil)
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetStranger()
    defineObjective
    {
        description = "$MidGameEvent_MeetStranger", --$ Talk to the Shady Stranger.
    }
    addPOI(stranger)
end

function MeetStrangerCheck()
    return fact.ChicagoPolitics_MetStranger or fact.ChicagoPolitics_RejectedTask1
end

function MeetStrangerDone()
    if fact.ChicagoPolitics_MetStranger then
        addObjective("ConquerRacket")
    end
end

function ConquerRacket()
    defineObjective
    {
        description = "$MidGameEvent_ConquerRacket", --$ Take out the racket and get the intel.
    }
    -- MEGAMOD: softlock fix - the derelict can land in a precinct the player cannot
    -- supply an attack from (TAKE_OVER_BUILDING.isValid fails), stalling the mission.
    -- Spawn the racket's guards in the street outside instead (MidGameDemocratB1
    -- brothel pattern) so the task can always be completed by wiping the squad.
    derelictSquad = MissionUtils:spawnSquad(6)
    MissionUtils:placeSquad(derelictSquad, getParentValue("derelictPlacement").locationId, getParentValue("derelictPlacement").station.pos)
    setParentValue("derelictSquad", derelictSquad)

    addPOI(derelictMarker)
end

function ConquerRacketCheck()
    -- MEGAMOD: softlock fix - a dead street squad also completes the task; the
    -- original conquest path still counts
    return (derelictSquad and MissionUtils:isSquadDead(derelictSquad)) or getParentValue("conqueredBuilding")
end

function ConquerRacketDone()
    -- MEGAMOD: softlock fix - clean up squad remnants
    if derelictSquad then
        derelictSquad:removeFromSquads()
    end
    setParentValue("derelictSquad", nil)
    derelictSquad = nil

    addObjective("ReturnToStranger")
end

function ReturnToStranger()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToStranger", --$ Return to the Shady Stranger.
    }
    stranger.memory.ChicagoPolitics_ClearedOutDerelict = true
    addPOI(stranger)
end

function ReturnToStrangerCheck()
    return fact.ChicagoPolitics_ReturnedToStranger
end

function ReturnToStrangerDone()
end

--[[------------------------------------------------------------------------------
MID GAME EVENT DEMOCRAT A II
--------------------------------------------------------------------------------]]
_id = "MID_GAME_DEMOCRAT_A_2"
_mission = "MidGameDemocratA2"

persist{}
woman = nil

persist{}
upgradedRacket = false

function onMissionCreate()
    defineMission
    {
        name = "$MidGameDemocratA2_name", --$ Talk to the Businesswoman
        description = "$MidGameDemocratA2_desc", --$ Provide the Businesswoman with a high class speakeasy for the Senator's celebrations. Increasing your ambience to level 3 or above oughta do it.
    }
    woman = getParentValue("woman")
end

function onMissionStart()
    addObjective("MeetWoman")
end

function onMissionSuccess()
    woman.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("woman", nil)

    getParentValue("womanPlacement"):release()
    setParentValue("womanPlacement", nil)
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onRacketUpgraded(e)
    local building = e.building
    local faction = building.faction
    local upgrade = e.upgradeTag

    if  (faction == WorldUtils:getPlayerFaction()) and
        (building.buildingData and building.buildingData.id == "BUILDING_DATA.BAR") then
            local upgrades = building.upgrades:getUpgradeOfType("ambiance")
            if upgrades:getLevel() > 2 then
                upgradedRacket = true
            end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetWoman()
    defineObjective
    {
        description = "$MidGameEvent_MeetWoman", --$ Meet the Businesswoman.
    }
    addPOI(woman)
end

function MeetWomanCheck()
    return fact.ChicagoPolitics_MetWoman or fact.ChicagoPolitics_ReturnedToWoman or fact.ChicagoPolitics_RejectedTask2
end

function MeetWomanDone()
    if fact.ChicagoPolitics_MetWoman then
        addObjective("UpgradeRacket")
    end
end

function UpgradeRacket()
    defineObjective
    {
        description = "$MidGameEvent_UpgradeRacket", --$ Upgrade your racket's ambience to level 3 or higher.
    }
    upgradedRacket = false
end

function UpgradeRacketCheck()
    return upgradedRacket
end

function UpgradeRacketDone()
    addObjective("ReturnToWoman")
end

function ReturnToWoman()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToWoman", --$ Return to the Businesswoman.
    }
    addPOI(woman)
end

function ReturnToWomanCheck()
    return fact.ChicagoPolitics_ReturnedToWoman
end

function ReturnToWomanDone()
end

--[[------------------------------------------------------------------------------
HELP DEMOCRATS B
--------------------------------------------------------------------------------]]
_id = "HELP_DEMOCRATS_B"
_mission = "HelpDemocratsB"
_timeLimit = 29

persist{}
derelictPlacement = nil

persist{}
brothelPlacement = nil

persist{}
strangerPlacement = nil

persist{}
womanPlacement = nil

persist{}
derelict = nil

persist{}
brothel = nil

persist{}
squad = nil

persist{}
woman = nil

persist{}
stranger = nil

persist{}
derelictMarker = nil

persist{}
brothelMarker = nil

persist{}
conqueredBuilding = nil

persist{}
conqueredBrothel = nil

-- MEGAMOD: softlock fix - street squad guarding the derelict (see MidGameDemocratB2 ConquerRacket)
persist{}
derelictSquad = nil

function onMissionCreate()
    defineMission
    {
        name = "$ChicagoStylePolitics",
        description = "$MidGameDemocratB_desc", --$ You have chosen to support the Democrats in the upcoming Gubernatorial elections... and they want you to do them a couple of favors.
    }
    derelict = WorldUtils:getBuildingFromPlacement(derelictPlacement, true)
    brothel = WorldUtils:getBuildingFromPlacement(brothelPlacement)

    stranger = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_NON_COMBAT_04", strangerPlacement)
    stranger.memory.ChicagoPolitics_Brothel = brothel
    woman = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_FEMALE_NON_COMBAT", womanPlacement)
    woman.memory.ChicagoPolitics_Derelict = derelict

    stranger:setConversationEntryPoint("ChicagoPolitics3_Start")
    woman:setConversationEntryPoint("ChicagoPolitics4_Start")

    derelictMarker = MissionUtils:placeMarker(derelict)
    brothelMarker = MissionUtils:placeMarker(brothel)
end

function onMissionStart()
    addSubMission("MidGameDemocratB1")
    addSubMission("MidGameDemocratB2")
    setTimeLimit(_timeLimit, "Days")
end

function onMissionSuccess()
    WorldUtils:triggerEvent("MidGameEventBEnd")
end

function onMissionFail()
    if derelictPlacement then
        derelictPlacement:release()
    end
    if brothelPlacement then
        brothelPlacement:release()
    end
    if strangerPlacement then
        strangerPlacement:release()
    end
    if womanPlacement then
        womanPlacement:release()
    end

    if stranger then
        stranger:delete()
    end
    if woman then
        woman:delete()
    end
    if squad then
        squad:removeFromSquads()
    end
    -- MEGAMOD: softlock fix - disband the street squad
    if derelictSquad then
        derelictSquad:removeFromSquads()
    end
    if derelictMarker then
        derelictMarker:delete()
    end
    if brothelMarker then
        brothelMarker:delete()
    end
end

-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function resetMission()
    fact.ChicagoPolitics_MetStranger = false
    fact.ChicagoPolitics_ReturnedToStranger = false
    fact.ChicagoPolitics_MetWoman = false
    fact.ChicagoPolitics_ReturnedToWoman = false
    fact.ChicagoPolitics_RejectedTask1 = false
    fact.ChicagoPolitics_RejectedTask2 = false

    onMissionFail()
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == derelictPlacement then
        if fact.ChicagoPolitics_MetWoman and ((e.reason == "ConqueredByPlayer") or (e.reason == "ClearedOutByPlayer")) then
            conqueredBuilding = true
            derelictPlacement = nil
        else
            derelictPlacement = WorldUtils:acquirePlacement(
                MissionUtils:derelictRacketInPlayerOrThugPrecinct()
            )
            if not derelictPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            derelict = WorldUtils:getBuildingFromPlacement(derelictPlacement, true)

            MissionUtils:placeMarker(derelict, derelictMarker.iid)

            -- MEGAMOD: softlock fix - move the street squad to the new derelict
            if derelictSquad then
                MissionUtils:placeSquad(derelictSquad, derelictPlacement.locationId, derelictPlacement.station.pos)
            end
        end
    elseif e.placement == brothelPlacement then
        if fact.ChicagoPolitics_MetStranger and ((e.reason == "ConqueredByPlayer") or (e.reason == "ClearedOutByPlayer")) then
            conqueredBrothel = true
            derelictPlacement = nil
        else
            brothelPlacement = WorldUtils:acquirePlacement(
                MissionUtils:racketOwnedByNeutralFaction("Brothel"))
            if not brothelPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            brothel = WorldUtils:getBuildingFromPlacement(brothelPlacement)
            stranger.memory.ChicagoPolitics_Brothel = brothel

            if squad then
                MissionUtils:placeSquad(squad, brothelPlacement.locationId, brothelPlacement.station.pos)
            end

            MissionUtils:placeMarker(brothel, brothelMarker.iid)
        end
    end
end

function onMissionTimeout()
    if not fact.ChicagoPolitics_ReturnedToStranger then
        fact.ChicagoPolitics_RejectedTask1 = true
    end
    if not fact.ChicagoPolitics_ReturnedToWoman then
        fact.ChicagoPolitics_RejectedTask2 = true
    end
end

--[[------------------------------------------------------------------------------
MID GAME EVENT DEMOCRAT B I
--------------------------------------------------------------------------------]]
_id = "MID_GAME_DEMOCRAT_B_1"
_mission = "MidGameDemocratB1"

persist{}
stranger = nil

persist{}
brothelMarker = nil

persist{}
squad = nil

function onMissionCreate()
    defineMission
    {
        name = "$MidGameDemocratB1_name", --$ Meet the Shady Stranger
        description = "$MidGameDemocratB1_desc", --$ Meet the Shady Stranger to find out how you can help the Democrats.
    }
    stranger = getParentValue("stranger")
    brothelMarker = getParentValue("brothelMarker")
end

function onMissionStart()
    addObjective("MeetStranger")
end

function onMissionSuccess()
    stranger.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("stranger", nil)

    getParentValue("strangerPlacement"):release()
    setParentValue("strangerPlacement", nil)

    local rackets = MissionUtils:controlledRackets("BROTHEL")
    for i = 1, #rackets do
        rackets[i].data:setModifier("earnings", "$ChicagoStylePolitics", 0.1)
    end
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onEnterLocation(e)
    local brothel = getParentValue("brothel")
    if squad then
        local selectedChar = MissionUtils:selectedCharacter() or Character:getPlayer()
        if e.locationId == brothel.interiorLocationId and selectedChar:getLocationId() == e.locationId then
            local _, lead = next(squad.members)
            WorldUtils:startScenario("StartCombatOnLoadLoc", lead, selectedChar)
        end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetStranger()
    defineObjective
    {
        description = "$MidGameEvent_MeetStranger",
    }
    addPOI(stranger)
end

function MeetStrangerCheck()
    return fact.ChicagoPolitics_MetStranger or fact.ChicagoPolitics_RejectedTask1
end

function MeetStrangerDone()
    if fact.ChicagoPolitics_MetStranger then
        addObjective("ConquerRacket")
    end
end

function ConquerRacket()
    defineObjective
    {
        description = "$MidGameEvent_ConquerRacket",
    }
    squad = MissionUtils:spawnSquad(6)
    MissionUtils:placeSquad(squad, getParentValue("brothelPlacement").locationId, getParentValue("brothelPlacement").station.pos)
    setParentValue("squad", squad)

    addPOI(brothelMarker)
end

function ConquerRacketCheck()
    return MissionUtils:isSquadDead(squad) or getParentValue("conqueredBrothel")
end

function ConquerRacketDone()
    if brothelMarker then
        brothelMarker:delete()
    end
    setParentValue("brothelMarker", nil)
    brothelMarker = nil
    setParentValue("squad", nil)
    squad = nil

    addObjective("ReturnToStranger")
end

function ReturnToStranger()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToStranger",
    }
    stranger.memory.ChicagoPolitics_ClearedOutBrothel = true
    addPOI(stranger)
end

function ReturnToStrangerCheck()
    return fact.ChicagoPolitics_ReturnedToStranger
end

function ReturnToStrangerDone()
end

--[[------------------------------------------------------------------------------
MID GAME EVENT DEMOCRAT B II
--------------------------------------------------------------------------------]]
_id = "MID_GAME_DEMOCRAT_B_2"
_mission = "MidGameDemocratB2"

persist{}
woman = nil

persist{}
derelictMarker = nil

-- MEGAMOD: softlock fix - street squad guarding the derelict (see ConquerRacket)
persist{}
derelictSquad = nil

function onMissionCreate()
    defineMission
    {
        name = "$MidGameDemocratB2_name", --$ Meet the Businesswoman
        description = "$MidGameDemocratB2_desc", --$ Meet the Businesswoman to find out how you can help the Democrats.
    }
    woman = getParentValue("woman")
    derelictMarker = getParentValue("derelictMarker")
end

function onMissionStart()
    addObjective("MeetWoman")
end

function onMissionSuccess()
    woman.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("woman", nil)

    getParentValue("womanPlacement"):release()
    setParentValue("womanPlacement", nil)
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetWoman()
    defineObjective
    {
        description = "$MidGameEvent_MeetWoman",
    }
    addPOI(woman)
end

function MeetWomanCheck()
    return fact.ChicagoPolitics_MetWoman or fact.ChicagoPolitics_RejectedTask2
end

function MeetWomanDone()
    if fact.ChicagoPolitics_MetWoman then
        addObjective("ConquerRacket")
    end
end

function ConquerRacket()
    defineObjective
    {
        description = "$MidGameEvent_ConquerRacket",
    }
    -- MEGAMOD: softlock fix - the derelict can land in a precinct the player cannot
    -- supply an attack from (TAKE_OVER_BUILDING.isValid fails), stalling the mission.
    -- Spawn the racket's guards in the street outside instead (MidGameDemocratB1
    -- brothel pattern) so the task can always be completed by wiping the squad.
    derelictSquad = MissionUtils:spawnSquad(6)
    MissionUtils:placeSquad(derelictSquad, getParentValue("derelictPlacement").locationId, getParentValue("derelictPlacement").station.pos)
    setParentValue("derelictSquad", derelictSquad)

    addPOI(derelictMarker)
end

function ConquerRacketCheck()
    -- MEGAMOD: softlock fix - a dead street squad also completes the task; the
    -- original conquest path still counts
    return (derelictSquad and MissionUtils:isSquadDead(derelictSquad)) or getParentValue("conqueredBuilding")
end

function ConquerRacketDone()
    -- MEGAMOD: softlock fix - clean up squad remnants
    if derelictSquad then
        derelictSquad:removeFromSquads()
    end
    setParentValue("derelictSquad", nil)
    derelictSquad = nil

    if derelictMarker then
        derelictMarker:delete()
    end
    setParentValue("derelictMarker", nil)
    derelictMarker = nil

    addObjective("ReturnToWoman")
end

function ReturnToWoman()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToWoman",
    }
    woman.memory.ChicagoPolitics_ClearedOutDerelict = true
    addPOI(woman)
end

function ReturnToWomanCheck()
    return fact.ChicagoPolitics_ReturnedToWoman
end

function ReturnToWomanDone()
end

--[[------------------------------------------------------------------------------
HELP REPUBLICANS A
--------------------------------------------------------------------------------]]
_id = "HELP_REPUBLICANS_A"
_mission = "HelpRepublicansA"
_timeLimit = 29

persist{}
brothelPlacement = nil

persist{}
witnessPlacement = nil

persist{}
strangerPlacement = nil

persist{}
businessPersonPlacement = nil

persist{}
brothel = nil

persist{}
smith = nil

persist{}
stranger = nil

persist{}
witnessA = nil

persist{}
witnessB = nil

persist{}
brothelMarker = nil

persist{}
conqueredBrothel = nil

function onMissionCreate()
    defineMission
    {
        name = "$ChicagoStylePolitics",
        description = "$MidGameRepublicansA_desc", --$ You have chosen to support the Republicans in the upcoming Gubernatorial elections... and they want you to do them a couple of favors.
    }
    brothel = WorldUtils:getBuildingFromPlacement(brothelPlacement)

    stranger = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_NON_COMBAT_07", strangerPlacement)
    smith = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_WILHEIM_SMITH", businessPersonPlacement)
    smith.memory.ChicagoPolitics_Brothel = brothel

    stranger:setConversationEntryPoint("ChicagoPolitics5_Start")
    smith:setConversationEntryPoint("ChicagoPolitics6_Start")

    brothelMarker = MissionUtils:placeMarker(brothel)
end

function onMissionStart()
    addSubMission("HelpRepublicansA1")
    addSubMission("HelpRepublicansA2")
    setTimeLimit(_timeLimit, "Days")
end

function onMissionSuccess()
    WorldUtils:triggerEvent("MidGameEventAEnd", "helpedDemocrats", false)
end

function onMissionFail()
    if witnessPlacement then
        witnessPlacement:release()
    end
    if strangerPlacement then
        strangerPlacement:release()
    end
    if businessPersonPlacement then
        businessPersonPlacement:release()
    end

    if stranger then
        stranger:delete()
    end
    if smith then
        smith:delete()
    end
    if brothelMarker then
        brothelMarker:delete()
    end
end

-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function resetMission()
    fact.ChicagoPolitics_MetStranger = false
    fact.ChicagoPolitics_ReturnedToStranger = false
    fact.ChicagoPolitics_MetSmith = false
    fact.ChicagoPolitics_ReturnedToSmith = false
    fact.ChicagoPolitics_RejectedTask1 = false
    fact.ChicagoPolitics_RejectedTask2 = false

    onMissionFail()
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == brothelPlacement then
        if fact.ChicagoPolitics_MetSmith and ((e.reason == "ConqueredByPlayer") or (e.reason == "ClearedOutByPlayer")) then
            conqueredBrothel = true
            brothelPlacement = nil
        else
            brothelPlacement = WorldUtils:acquirePlacement(
                MissionUtils:racketOwnedByNeutralFaction("Brothel")
            )
            if not brothelPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            brothel = WorldUtils:getBuildingFromPlacement(brothelPlacement)
            smith.memory.ChicagoPolitics_Brothel = brothel

            MissionUtils:placeMarker(brothel, brothelMarker.iid)
        end
    end
end

function onMissionTimeout()
    if not fact.ChicagoPolitics_ReturnedToStranger then
        fact.ChicagoPolitics_RejectedTask1 = true
    end
    if not fact.ChicagoPolitics_ReturnedToSmith then
        fact.ChicagoPolitics_RejectedTask2 = true
    end
end

--[[------------------------------------------------------------------------------
MID GAME EVENT REPUBLICANS A I
--------------------------------------------------------------------------------]]
_id = "HELP_REPUBLICANS_A_1"
_mission = "HelpRepublicansA1"

persist{}
stranger = nil

persist{}
witnessA = nil

persist{}
witnessB = nil

function onMissionCreate()
    defineMission
    {
        name = "$HelpRepublicansA1_name", --$ Meet the Shady Stranger
        description = "$HelpRepublicansA1_desc", --$ Meet the Shady Stranger to find out how you can help the Republicans.
    }
    stranger = getParentValue("stranger")
end

function onMissionStart()
    addObjective("MeetStranger")
end

function onMissionSuccess()
    stranger.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("stranger", nil)

    getParentValue("strangerPlacement"):release()
    setParentValue("strangerPlacement", nil)

    WorldUtils:applyModifier("MISSION_MID_GAME_EVENT", WorldUtils:getPlayerFaction().factionId)
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetStranger()
    defineObjective
    {
        description = "$MidGameEvent_MeetStranger",
    }
    addPOI(stranger)
end

function MeetStrangerCheck()
    return fact.ChicagoPolitics_MetStranger or fact.ChicagoPolitics_RejectedTask1
end

function MeetStrangerDone()
    if fact.ChicagoPolitics_MetStranger then
        addObjective("KillWitnesses")
    end
end

function KillWitnesses()
    defineObjective
    {
        description = "$MidGameEvent_KillWitnesses", --$ Take care of the witnesses.
    }
    witnessA = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_02", getParentValue("witnessPlacement"))
    witnessB = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_06", getParentValue("witnessPlacement"), nil, 1, 3)
    MissionUtils:makeNPCCombat(witnessA, false)
    MissionUtils:makeNPCCombat(witnessB, false)
    setParentValue("witnessA", witnessA)
    setParentValue("witnessB", witnessB)

    addPOI(witnessA)
end

function KillWitnessesCheck()
    return witnessA:isDead() or witnessB:isDead()
end

function KillWitnessesDone()
    if getParentValue("witnessPlacement") then
        getParentValue("witnessPlacement"):release()
    end
    setParentValue("witnessPlacement", nil)
    setParentValue("witnessA", nil)
    setParentValue("witnessB", nil)

    addObjective("ReturnToStranger")
end

function ReturnToStranger()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToStranger",
    }
    stranger.memory.ChicagoPolitics_KilledWitnesses = true
    addPOI(stranger)
end

function ReturnToStrangerCheck()
    return fact.ChicagoPolitics_ReturnedToStranger
end

function ReturnToStrangerDone()
end

--[[------------------------------------------------------------------------------
MID GAME EVENT REPUBLICANS A II
--------------------------------------------------------------------------------]]
_id = "HELP_REPUBLICANS_A_2"
_mission = "HelpRepublicansA2"

persist{}
smith = nil

persist{}
brothelMarker = nil

function onMissionCreate()
    defineMission
    {
        name = "$HelpRepublicansA2_name", --$ Meet Wilhelm Smith
        description = "$HelpRepublicansA2_desc", --$ Meet Wilhelm Smith to find out how you can help the Republicans.
    }
    smith = getParentValue("smith")
    brothelMarker = getParentValue("brothelMarker")
end

function onMissionStart()
    addObjective("MeetSmith")
end

function onMissionSuccess()
    smith.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("smith", nil)

    getParentValue("businessPersonPlacement"):release()
    setParentValue("businessPersonPlacement", nil)

    WorldUtils:applyModifier("MISSION_MID_GAME_EVENT", WorldUtils:getPlayerFaction().factionId)
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetSmith()
    defineObjective
    {
        description = "$MidGameEvent_MeetSmith", --$ Meet Wilhelm Smith.
    }
    addPOI(smith)
end

function MeetSmithCheck()
    return fact.ChicagoPolitics_MetSmith or fact.ChicagoPolitics_RejectedTask2
end

function MeetSmithDone()
    if fact.ChicagoPolitics_MetSmith then
        addObjective("ConquerRacket")
    end
end

function ConquerRacket()
    defineObjective
    {
        description = "$MidGameEvent_ConquerRacket",
    }
    addPOI(brothelMarker)
end

function ConquerRacketCheck()
    return getParentValue("conqueredBrothel")
end

function ConquerRacketDone()
    if brothelMarker then
        brothelMarker:delete()
    end
    setParentValue("brothelMarker", nil)
    brothelMarker = nil

    addObjective("ReturnToSmith")
end

function ReturnToSmith()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToSmith", --$ Return to Wilhelm Smith.
    }
    smith.memory.ChicagoPolitics_ClearedOutBrothel = true
    addPOI(smith)
end

function ReturnToSmithCheck()
    return fact.ChicagoPolitics_ReturnedToSmith
end

function ReturnToSmithDone()
end

--[[------------------------------------------------------------------------------
MID GAME EVENT REPUBLICANS B
--------------------------------------------------------------------------------]]
_id = "HELP_REPUBLICANS_B"
_mission = "HelpRepublicansB"
_timeLimit = 29

persist{}
witnessPlacement = nil

persist{}
strangerPlacement = nil

persist{}
businessPersonPlacement = nil

persist{}
woman = nil

persist{}
stranger = nil

persist{}
journalist = nil

function onMissionCreate()
    defineMission
    {
        name = "$ChicagoStylePolitics",
        description = "$HelpRepublicansB_desc", --$ You have chosen to support the Republicans in the upcoming Gubernatorial elections... and they want you to do them a couple of favors.
    }

    stranger = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_NON_COMBAT_03", strangerPlacement)
    stranger.memory.ChicagoPolitics_Ward = WorldUtils:getWardNameFromLocationId(witnessPlacement.locationId)
    woman = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_FEMALE_NON_COMBAT_03", businessPersonPlacement)

    stranger:setConversationEntryPoint("ChicagoPolitics7_Start")
    woman:setConversationEntryPoint("ChicagoPolitics8_Start")
end

function onMissionStart()
    addSubMission("HelpRepublicansB1")
    addSubMission("HelpRepublicansB2")
    setTimeLimit(_timeLimit, "Days")
end

function onMissionSuccess()
    WorldUtils:triggerEvent("MidGameEventBEnd", "helpedDemocrats", false)
end

function onMissionFail()
    if witnessPlacement then
        witnessPlacement:release()
    end
    if strangerPlacement then
        strangerPlacement:release()
    end
    if businessPersonPlacement then
        businessPersonPlacement:release()
    end

    if stranger then
        stranger:delete()
    end
    if woman then
        woman:delete()
    end
    if journalist then
        journalist:delete()
    end
end

-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function resetMission()
    fact.ChicagoPolitics_MetStranger = false
    fact.ChicagoPolitics_ReturnedToStranger = false
    fact.ChicagoPolitics_MetWoman = false
    fact.ChicagoPolitics_ReturnedToWoman = false
    fact.ChicagoPolitics_RejectedTask1 = false
    fact.ChicagoPolitics_RejectedTask2 = false

    onMissionFail()
end

-- --------------------------
-- Game Events
-- --------------------------
function onMissionTimeout()
    if not fact.ChicagoPolitics_ReturnedToStranger then
        fact.ChicagoPolitics_RejectedTask1 = true
    end
    if not fact.ChicagoPolitics_ReturnedToWoman then
        fact.ChicagoPolitics_RejectedTask2 = true
    end
end

--[[------------------------------------------------------------------------------
MID GAME EVENT REPUBLICANS B I
--------------------------------------------------------------------------------]]
_id = "HELP_REPUBLICANS_B_1"
_mission = "HelpRepublicansB1"

persist{}
stranger = nil

persist{}
journalist = nil

function onMissionCreate()
    defineMission
    {
        name = "$HelpRepublicansB1_name", --$ Meet the Shady Stranger
        description = "$HelpRepublicansB1_desc", --$ Meet the Shady Stranger to find out how you can help the Republicans.
    }
    stranger = getParentValue("stranger")
end

function onMissionStart()
    addObjective("MeetStranger")
end

function onMissionSuccess()
    stranger.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("stranger", nil)

    getParentValue("strangerPlacement"):release()
    setParentValue("strangerPlacement", nil)

    if fact.ChicagoPolitics_ReturnedToStranger then
        WorldUtils:applyModifier("MISSION_MID_GAME_EVENT", WorldUtils:getPlayerFaction().factionId)
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetStranger()
    defineObjective
    {
        description = "$MidGameEvent_MeetStranger",
    }
    addPOI(stranger)
end

function MeetStrangerCheck()
    return fact.ChicagoPolitics_MetStranger or fact.ChicagoPolitics_RejectedTask1
end

function MeetStrangerDone()
    if fact.ChicagoPolitics_MetStranger then
        addObjective("KillJournalist")
    end
end

function KillJournalist()
    defineObjective
    {
        description = "$MidGameEvent_KillJournalist", --$ Take out the Journalist.
    }
    journalist = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_JOURNALIST", getParentValue("witnessPlacement"))
    MissionUtils:makeNPCCombat(journalist, false)
    setParentValue("journalist", journalist)

    addPOI(journalist)
end

function KillJournalistCheck()
    return journalist:isDead()
end

function KillJournalistDone()
    if getParentValue("witnessPlacement") then
        getParentValue("witnessPlacement"):release()
    end
    setParentValue("witnessPlacement", nil)
    setParentValue("journalist", nil)

    addObjective("ReturnToStranger")
end

function ReturnToStranger()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToStranger",
    }
    stranger.memory.ChicagoPolitics_KilledJournalist = true
    addPOI(stranger)
end

function ReturnToStrangerCheck()
    return fact.ChicagoPolitics_ReturnedToStranger
end

function ReturnToStrangerDone()
end

--[[------------------------------------------------------------------------------
MID GAME EVENT REPUBLICANS B II
--------------------------------------------------------------------------------]]
_id = "HELP_REPUBLICANS_B_2"
_mission = "HelpRepublicansB2"

persist{}
woman = nil

persist{}
upgradedRacket = false

function onMissionCreate()
    defineMission
    {
        name = "$HelpRepublicansB2_name", --$ Talk to the Businesswoman
        description = "$HelpRepublicansB2_desc", --$ Provide the Businesswoman with a high class casino to indulge the Republican candidate's vice. A casino at an ambience level of 3 or more oughta do it.
    }
    woman = getParentValue("woman")
end

function onMissionStart()
    addObjective("MeetWoman")
end

function onMissionSuccess()
    woman.brain:addGoal("LeaveLocationAndDelete", 1001)
    setParentValue("woman", nil)

    getParentValue("businessPersonPlacement"):release()
    setParentValue("businessPersonPlacement", nil)

    if fact.ChicagoPolitics_ReturnedToWoman then
        local rackets = MissionUtils:controlledRackets("CASINO")
        for i = 1, #rackets do
            rackets[i].data:setModifier("_earnings", "$ChicagoStylePolitics", 0.1)
        end
    end
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onRacketUpgraded(e)
    local building = e.building
    local faction = building.faction
    local upgrade = e.upgradeTag

    if  (faction == WorldUtils:getPlayerFaction()) and
        (building.buildingData and building.buildingData.id == "BUILDING_DATA.CASINO") then
            local upgrades = building.upgrades:getUpgradeOfType("ambiance")
            if upgrades:getLevel() > 2 then
                upgradedRacket = true
            end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetWoman()
    defineObjective
    {
        description = "$MidGameEvent_MeetWoman",
    }
    addPOI(woman)
end

function MeetWomanCheck()
    return fact.ChicagoPolitics_MetWoman or fact.ChicagoPolitics_ReturnedToWoman or fact.ChicagoPolitics_RejectedTask2
end

function MeetWomanDone()
    if fact.ChicagoPolitics_MetWoman then
        addObjective("UpgradeRacket")
    end
end

function UpgradeRacket()
    defineObjective
    {
        description = "$MidGameEvent_UpgradeRacket",
    }
    upgradedRacket = false
end

function UpgradeRacketCheck()
    return upgradedRacket
end

function UpgradeRacketDone()
    addObjective("ReturnToWoman")
end

function ReturnToWoman()
    defineObjective
    {
        description = "$MidGameEvent_ReturnToWoman",
    }
    addPOI(woman)
end

function ReturnToWomanCheck()
    return fact.ChicagoPolitics_ReturnedToWoman or fact.ChicagoPolitics_RejectedTask2
end

function ReturnToWomanDone()
end

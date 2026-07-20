-- --------------------------------------------------
-- CaponeMissions.lua
-- --------------------------------------------------
_namespace = "MISSIONS"

--[[------------------------------------------------------------------------------
GUESS WHOS BACK IN TOWN
--------------------------------------------------------------------------------]]
_id = "GUESS_WHOS_BACK"
_mission = "GuessWhosBack"
_priority = 100

persist{}
carPlacement = nil

persist{}
brothelPlacement = nil

persist{}
brothel = nil

persist{}
whiteHandThugs = {}

persist{}
cabDriver = nil

function onMissionCreate()
    defineMission
    {
        name = "$GuessWhosBack_name", --$  Guess Who's Back in Town
        description = "$GuessWhosBack_desc", --$ You heard from Sal, your taxi driver, that Frankie Yale is in Chicago. Thing is, Yale didn't tell you he was coming. Sal needs you to handle some punks that are messing with his taxis, and in return he'll find Yale for you. He'll also give you a line on a few crates of booze.
    }

    brothel = fact.GuessWhosBack_brothel
end

function onMissionStart()
    addSubMission("GuessWhosBack1", true, "carPlacement", carPlacement, "brothelPlacement", brothelPlacement, "brothel", brothel)

    addNotorietyReward(1, "$MissionReward_GuessWhosBack") --$ Chased off thugs
end

function onMissionSuccess()
    if carPlacement then
        carPlacement:release()
        carPlacement = nil
    end

    WorldUtils:startMission("AWarmReunion", "brothelPlacement", brothelPlacement, "brothel", brothel)
end

function onMissionFail()
    if carPlacement then
        carPlacement:release()
        carPlacement = nil
    end
    if brothelPlacement then
        brothelPlacement:release()
        brothelPlacement = nil
    end

    if whiteHandThugs then
        if whiteHandThugs.members then
            whiteHandThugs:removeFromSquads()
        else
            for i = 1, #whiteHandThugs do
                if whiteHandThugs[i] ~= nil and (not whiteHandThugs[i].isDeleted or not whiteHandThugs[i]:isDead()) then
                    whiteHandThugs[i]:delete()
                    whiteHandThugs[i] = nil
                end
            end
        end
    end
    if cabDriver ~= nil and not cabDriver.isDeleted then
        cabDriver:delete()
        cabDriver = nil
    end
end

-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function testMission()
    onMissionStart()
end
function testMissionSubmission2_FoughtWhiteHand()
    testMission()
    fact.GuessWhosBack_ConfrontedThugs = true
end

function resetMission()
    fact.GuessWhosBack_ConfrontedThugs = false
    fact.GuessWhosBack_brothel = nil

    onMissionFail()
end

--[[------------------------------------------------------------------------------
GUESS WHOS BACK IN TOWN I
--------------------------------------------------------------------------------]]
_id = "GUESS_WHOS_BACK_1"
_mission = "GuessWhosBack1"

persist{}
carPlacement = nil

persist{}
whiteHandThugs = {}

persist{}
foughtThugs = nil

persist{}
brothelPlacement = nil

persist{}
brothel = nil

function onMissionCreate()
    defineMission
    {
        name = "$GuessWhosBack1_name", --$  Take care of the thugs
        description = "$GuessWhosBack1_desc", --$ Get rid of the thugs messing with Sal's taxis.
    }

    local locationId = carPlacement.locationId
    whiteHandThugs = MissionUtils:spawnSquad(2, "FACTION.WHITE_HAND_GANG")
    MissionUtils:placeSquad(whiteHandThugs, carPlacement.locationId, carPlacement.station.pos, "Capone_Start", true)
    setParentValue("whiteHandThugs", whiteHandThugs)
end

function onMissionStart()
    addObjective("ConfrontThugs")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == brothelPlacement then
        if e.reason == "Upgrade" then
            brothelPlacement = WorldUtils:acquirePlacement({
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = brothel.interiorLocationId
            })
        else
            brothelPlacement = WorldUtils:acquirePlacement({
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = WorldUtils:getCurrentExteriorLocationId()
            }, 2,
            {
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
            }, 1)
            if not brothelPlacement then
                failMission("$MissionFailLostBuilding")
                return
            else
                brothel = WorldUtils:getLocationFromId(brothelPlacement.locationId).building
                fact.GuessWhosBack_brothel = brothel
            end
        end
        setParentValue("brothelPlacement", brothelPlacement)
    end
end

function GameEvent.onCombatResolvedAndCleanedUp(e)
    if whiteHandThugs and MissionUtils:isSquadDead(whiteHandThugs) then
        foughtThugs = true
    elseif whiteHandThugs then
        local foundPOI
        if whiteHandThugs.members then
            for _, crewMember in next, whiteHandThugs.members do
                if not crewMember:isDead() and checkForPOI(crewMember, "ConfrontThugs") then
                    foundPOI = true
                    break
                end
            end
        else
            for i = 1, #whiteHandThugs do
                local crewMember = whiteHandThugs[i]
                if not crewMember:isDead() and checkForPOI(crewMember, "ConfrontThugs") then
                    foundPOI = true
                    break
                end
            end
        end
        if not foundPOI then
            if whiteHandThugs.members then
                for _, crewMember in next, whiteHandThugs.members do
                    if not crewMember:isDead() then
                        addPOI(crewMember, "MISSION_TARGET", "ConfrontThugs")
                        break
                    end
                end
            else
                for i = 1, #whiteHandThugs do
                    local crewMember = whiteHandThugs[i]
                    if not crewMember:isDead() then
                        addPOI(crewMember, "MISSION_TARGET", "ConfrontThugs")
                        break
                    end
                end
            end
        end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function ConfrontThugs()
    defineObjective
    {
        description = "$ConfrontThugs", --$ Confront the thugs.
    }
    local _, lead = next(whiteHandThugs.members)
    addPOI(lead)
end

function ConfrontThugsCheck()
    return fact.GuessWhosBack_ConfrontedThugs or foughtThugs
end

function ConfrontThugsDone()
    if fact.GuessWhosBack_ConfrontedThugs then
        MissionUtils:makeSquadLeave(whiteHandThugs)
    end
    whiteHandThugs = nil
    setParentValue("whiteHandThugs", nil)
end

function onMissionSuccess()
    addSubMission("GuessWhosBack2", true, "carPlacement", carPlacement, "brothelPlacement", brothelPlacement, "brothel", brothel)
end

--[[------------------------------------------------------------------------------
GUESS WHOS BACK IN TOWN II
--------------------------------------------------------------------------------]]
_id = "GUESS_WHOS_BACK_2"
_mission = "GuessWhosBack2"

persist{}
carPlacement = nil

persist{}
cabDriver = nil

persist{}
brothelPlacement = nil

persist{}
brothel = nil

function onMissionCreate()
    defineMission
    {
        name = "$GuessWhosBack2_name", --$  Speak with Sal's contact
        description = "$GuessWhosBack2_desc", --$ Now that the thugs are gone, you can find out where Yale is and collect your booze. Speak with Sal's contact to get his location.
    }

    local player = MissionUtils:selectedCharacter() or WorldUtils:getPlayerFaction().boss
    local pos = player:getPos()
    local locationId = WorldUtils:getCurrentExteriorLocationId()
    local spawnPoint = WorldUtils:findSpawnPoint(pos, nil, player:getLocation())

    cabDriver = MissionUtils:placeActorAtLocationId("NPC.MISSION_CAB_DRIVER", locationId, player:get3DPos(), nil, 5, 10, "NPC")
    WorldUtils:startScenario("NPCApproachesPlayer", cabDriver, "Capone2_Start")
end

function onMissionStart()
    addObjective("TalkToContact")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == brothelPlacement then
        if e.reason == "Upgrade" then
            brothelPlacement = WorldUtils:acquirePlacement({
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = brothel.interiorLocationId
            })
        else
            brothelPlacement = WorldUtils:acquirePlacement({
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = WorldUtils:getCurrentExteriorLocationId()
            }, 2,
            {
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
            }, 1)
            if not brothelPlacement then
                failMission("$MissionFailLostBuilding")
                return
            else
                brothel = WorldUtils:getLocationFromId(brothelPlacement.locationId).building
            end
        end
        fact.GuessWhosBack_brothel = brothel
        setParentValue("brothelPlacement", brothelPlacement)
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function TalkToContact()
    defineObjective
    {
        description = "$TalkToContact", --$ Talk to the contact.
    }
    addPOI(cabDriver)
end

function TalkToContactCheck()
    return fact.GuessWhosBack_SpokeToContact
end

function TalkToContactDone()
    if cabDriver and not cabDriver.isDeleted then
        cabDriver.brain:addGoal("LeaveLocationAndDelete", 1001)
    end
end

--[[------------------------------------------------------------------------------
A WARM REUNION
--------------------------------------------------------------------------------]]
_id = "A_WARM_REUNION"
_mission = "AWarmReunion"
_priority = 100

persist{}
brothelPlacement = nil

persist{}
brothel = nil

persist{}
racketGuard = nil

persist{}
whiteHandRacketPlacement = nil

persist{}
whiteHandRacket = nil

persist{}
frankie = nil

persist{}
brothelWorker = nil

function onMissionCreate()
    defineMission
    {
        name = "$AWarmReunion_name", --$ A Warm Reunion
        description = "$AWarmReunion_desc", --$ Sal's contact told you that Yale's hiding out in a nearby brothel. You've gotta find a way in and talk to Yale.
        location = MissionUtils:getCurrentWardConfigId(),
        icon = WorldUtils:getPlayerFaction().icon,
    }

    brothel.memory.buildingLocked = true
end

function onMissionStart()
    addSubMission("AWarmReunion1", true, "brothel", brothel, "brothelPlacement", brothelPlacement)
end

function onMissionSuccess()
    MissionUtils:setEntryPoint(frankie, "Capone5_Start")
    local pos, locId = MissionUtils:interactionPos3DOfBuilding(whiteHandRacket)
    frankie = MissionUtils:placeActorAtLocationId("NPC.MISSION_FRANKIE_YALE", locId, pos, frankie.iid, 2, 4, nil)

    if brothelPlacement then
        brothelPlacement:release()
    end

    WorldUtils:startMission("HitEmWhereItHurts", "whiteHandRacket", whiteHandRacket, "whiteHandRacketPlacement", whiteHandRacketPlacement)
end

function onMissionFail()
    brothel.memory.buildingLocked = false

    if brothelPlacement then
        brothelPlacement:release()
    end
    if whiteHandRacketPlacement then
        whiteHandRacketPlacement:release()
    end

    if racketGuard then
        racketGuard:delete()
    end
    if frankie then
        frankie:delete()
    end
    if brothelWorker then
        brothelWorker:delete()
    end
end

-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function testMission()
    onMissionStart()
end

function testSubMission2()
    testMission()
    fact.WarmReunion_LetInBrothel = true
end

function testMission_SetTalkStage()
    local frankie = ActorUtils:getActorFromLabel("FrankieYale")
    frankie.memory.talkStage = "Quote_K4"
end

function resetMission()
    fact.WarmReunion_LetInBrothel = false
    fact.WarmReunion_Double = 0
    fact.WarmReunion_TalkedToFrankie = 0

    onMissionFail()
end

--[[------------------------------------------------------------------------------
A WARM REUNION I
--------------------------------------------------------------------------------]]
_id = "A_WARM_REUNION_1"
_mission = "AWarmReunion1"

persist{}
brothelPlacement = nil

persist{}
brothel = nil

persist{}
racketGuard = nil

persist{}
whiteHandRacketPlacement = nil

persist{}
whiteHandRacket = nil

function onMissionCreate()
    defineMission
    {
        name = "$AWarmReunion1_name", --$ Find a way into the brothel
        description = "$AWarmReunion1_desc", --$ Speak with one of the guards in front of the brothel to find a way in.
        location = MissionUtils:getCurrentWardConfigId(),
        icon = WorldUtils:getPlayerFaction().icon,
    }

    local locationId = brothel:getLocationId()
    local interactionPosX, interactionPosY = brothel:getInteractionPosXY()
    local pos = WorldUtils:getPointInFrontOf(interactionPosX, interactionPosY,  brothel:getSpawnRotation(), 1)

    local racketGuardConfigId = MissionUtils:getRacketGuardConfigId(brothel:getOwnerFaction())
    racketGuard = MissionUtils:placeActorAtLocationId(racketGuardConfigId, locationId, Vector3(pos.x, 0, pos.y), nil, 2, 4, "NPC")
    racketGuard:setConversationEntryPoint("Capone3_Start", nil, 100)
    setParentValue("racketGuard", racketGuard)

    whiteHandRacketPlacement = WorldUtils:acquirePlacement(
        MissionUtils:racketOwnedByNeutralFaction()
    )

    if not whiteHandRacketPlacement then
        logError("no whiteHandRacketPlacement")
        return
    end

    whiteHandRacket = WorldUtils:getLocationFromId(whiteHandRacketPlacement.locationId).building
    fact.GuessWhosBack_racketPlacement = whiteHandRacketPlacement
    fact.GuessWhosBack_racket = whiteHandRacket
    setParentValue("whiteHandRacketPlacement", whiteHandRacketPlacement)
    setParentValue("whiteHandRacket", whiteHandRacket)
end

function onMissionStart()
    addObjective("GetInsideTheBrothel")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == brothelPlacement then
        if e.reason == "Upgrade" then
            brothelPlacement = WorldUtils:acquirePlacement({
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = brothel.interiorLocationId
            })
        else
            brothelPlacement = WorldUtils:acquirePlacement({
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = WorldUtils:getCurrentExteriorLocationId()
            }, 2,
            {
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
            }, 1)
            if not brothelPlacement then
                failMission("$MissionFailLostBuilding")
                return
            else
                brothel.memory.buildingLocked = false
                brothel = WorldUtils:getLocationFromId(brothelPlacement.locationId).building
                if not fact.WarmReunion_LetInBrothel or not racketGuard:isDead() then
                    brothel.memory.buildingLocked = true
                    local locationId = brothel:getLocationId()
                    local interactionPosX, interactionPosY = brothel:getInteractionPosXY()
                    local pos = WorldUtils:getPointInFrontOf(interactionPosX, interactionPosY,  brothel:getSpawnRotation(), 1)

                    local racketGuardConfigId = MissionUtils:getRacketGuardConfigId(brothel:getOwnerFaction())
                    racketGuard = MissionUtils:placeActorAtLocationId(racketGuardConfigId, locationId, Vector3(pos.x, 0, pos.y), racketGuard.iid, 2, 4, "NPC")
                end
            end
        end
        fact.GuessWhosBack_brothel = brothel
        setParentValue("brothelPlacement", brothelPlacement)
    elseif e.placement == whiteHandRacketPlacement then
        if e.reason == "Upgrade" then
            whiteHandRacketPlacement = WorldUtils:acquirePlacement({
                buildingType = "Racket",
                featureType = "MissionArea",
                locationId = whiteHandRacket.interiorLocationId
            })
        else
            whiteHandRacketPlacement = WorldUtils:acquirePlacement({
                factionIds = WorldUtils:getOtherGangFactionsIds(),
                buildingType = "Racket",
                featureType = "MissionArea"
            })

            if not whiteHandRacketPlacement then
                logError("no whiteHandRacketPlacement")
            end

            whiteHandRacket = WorldUtils:getLocationFromId(whiteHandRacketPlacement.locationId).building
            fact.GuessWhosBack_racket = whiteHandRacket
            setParentValue("whiteHandRacket", whiteHandRacket)
        end
        fact.GuessWhosBack_racketPlacement = whiteHandRacketPlacement
        setParentValue("whiteHandRacketPlacement", whiteHandRacketPlacement)
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function GetInsideTheBrothel()
    defineObjective
    {
        description = "$SpeakWithTheGuard", --$ Speak with the Guard at the door.
    }
    racketGuard:addStateIfNotAdded("Unbribable")
    addPOI(racketGuard)
end

function GetInsideTheBrothelCheck()
    return fact.WarmReunion_LetInBrothel or racketGuard:isDead()
end

function GetInsideTheBrothelDone()
    if fact.WarmReunion_LetInBrothel then
        racketGuard.behaviours:add("RemoveIfIdleAndOffScreen")
        setParentValue("racketGuard", nil)
    end
end

function onMissionSuccess()
    addSubMission("AWarmReunion2", true, "brothel", brothel, "brothelPlacement", brothelPlacement, "whiteHandRacket", whiteHandRacket, "whiteHandRacketPlacement", whiteHandRacketPlacement)
    brothel.memory.buildingLocked = nil
end

--[[------------------------------------------------------------------------------
A WARM REUNION II
--------------------------------------------------------------------------------]]
_id = "A_WARM_REUNION_2"
_mission = "AWarmReunion2"

persist{}
brothelPlacement = nil

persist{}
brothel = nil

persist{}
whiteHandRacketPlacement = nil

persist{}
whiteHandRacket = nil

persist{}
frankie = nil

persist{}
brothelWorker = nil

function onMissionCreate()
    defineMission
    {
        name = "$AWarmReunion2_name", --$ Talk to Yale
        description = "$AWarmReunion2_desc", --$ Now that you've found a way into the brothel, talk to Yale to see why he's in Chicago.
        location = MissionUtils:getCurrentWardConfigId(),
    }

    frankie = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_FRANKIE_YALE", brothelPlacement)
    frankie:addLabel("FrankieYale")
    frankie:setConversationEntryPoint("Capone4_Start", nil, 100)
    if frankie.missionPatron then
        frankie.missionPatron:removePatronGoal(true)
    end

    brothelWorker = MissionUtils:placeActorAtLocationId("NPC.BROTHEL_WORKER_1", frankie:getLocationId(), frankie:get3DPos(), nil, 0.5, 1, "NPC")
    fact.WarmReunion_TalkedToFrankie = 0
    setParentValue("frankie", frankie)
    setParentValue("brothelWorker", brothelWorker)
end

function onMissionStart()
    addObjective("TalkToFrankie")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == brothelPlacement then
        if e.reason == "Upgrade" then
            brothelPlacement = WorldUtils:acquirePlacement({
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = brothel.interiorLocationId
            })
        else
            brothelPlacement = WorldUtils:acquirePlacement({
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
                locationId = WorldUtils:getCurrentExteriorLocationId()
            }, 2,
            {
                factionIds = MissionUtils:getNonHatedFactionIds(),
                racketType = "Brothel",
                stationTag = "BROTHEL_PRIVATE_ROOM_SPAWN",
                featureType = "MissionArea",
            }, 1)
            if not brothelPlacement then
                failMission("$MissionFailLostBuilding")
                return
            else
                brothel = WorldUtils:getLocationFromId(brothelPlacement.locationId).building
                frankie = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_FRANKIE_YALE", brothelPlacement, frankie.iid)
                brothelWorker = MissionUtils:placeActorAtLocationId("NPC.MISSION_BROTHEL_WORKER", frankie:getLocationId(), frankie:get3DPos(), brothelWorker.iid, 0.5, 1, "NPC")
                --SHOW EVENT FRANKIE HAS MOVED
            end
        end
        fact.GuessWhosBack_brothel = brothel
        setParentValue("brothelPlacement", brothelPlacement)
    elseif e.placement == whiteHandRacketPlacement then
        if e.reason == "Upgrade" then
            whiteHandRacketPlacement = WorldUtils:acquirePlacement({
                buildingType = "Racket",
                featureType = "MissionArea",
                locationId = whiteHandRacket.interiorLocationId
            })
        else
            whiteHandRacketPlacement = WorldUtils:acquirePlacement({
                factionIds = WorldUtils:getOtherGangFactionsIds(),
                buildingType = "Racket",
                featureType = "MissionArea",
            })

            if not whiteHandRacketPlacement then
                logError("no whiteHandRacketPlacement")
            end

            whiteHandRacket = WorldUtils:getLocationFromId(whiteHandRacketPlacement.locationId).building
            fact.GuessWhosBack_racket = whiteHandRacket
            setParentValue("whiteHandRacket", whiteHandRacket)
        end
        fact.GuessWhosBack_racketPlacement = whiteHandRacketPlacement
        setParentValue("whiteHandRacketPlacement", whiteHandRacketPlacement)
        setParentValue("whiteHandRacket", whiteHandRacket)
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function TalkToFrankie()
    defineObjective
    {
        description = "$TalkToFrankie", --$ Find Yale inside the brothel.
    }
    addPOI(frankie)
end

function TalkToFrankieCheck()
    return fact.WarmReunion_TalkedToFrankie > 0 and fact.WarmReunion_LeftBuilding
end

function TalkToFrankieDone()
end

--[[------------------------------------------------------------------------------
HIT 'EM WHERE IT HURTS
--------------------------------------------------------------------------------]]
_id = "HIT_EM_WHERE_IT_HURTS"
_mission = "HitEmWhereItHurts"
_priority = 100

persist{}
whiteHandRacket = nil

persist{}
whiteHandRacketPlacement = nil

persist{}
whiteHandThugs = {}

persist{}
frankie = nil

persist{}
foughtThugs = nil

function onMissionCreate()
    defineMission
    {
        name = "$HitEmWhereItHurts_name", --$ Hit 'Em Where It Hurts
        description = {"$HitEmWhereItHurts_desc", whiteHandRacket.name}, --$ Yale told you that the White Hand gang, the same gang that's been giving Sal trouble, stole a million bucks off him. He's asked you to help get revenge on the White Hand gang and get his money back. First, he needs some intel to find out where the stash is being hidden. It should be on one of the guards in {0}.
    }
    frankie = ActorUtils:getActorFromLabel("FrankieYale")

    local locationId = whiteHandRacketPlacement.locationId
    local whiteHandFaction = WorldUtils:getFactionById("FACTION.THUGS")

    whiteHandThugs = MissionUtils:spawnSquad(5, "FACTION.WHITE_HAND_GANG")
    MissionUtils:placeSquad(whiteHandThugs, locationId, whiteHandRacketPlacement.station.pos, nil, true)

    addCashReward(fact.WarmReunion_Double)
    addNotorietyReward(1, "$MissionReward_WarmReunion") --$ Fought with White Hand
end

function onMissionStart()
    addObjective("MeetWithFrankie")
end

function onMissionSuccess()
    if whiteHandRacketPlacement then
        whiteHandRacketPlacement:release()
    end
    fact.GuessWhosBack_racket = nil
    fact.GuessWhosBack_racketPlacement = nil

    local safeHouse = WorldUtils:getPlayerFaction():getPrimarySafehouse()
    local safehousePlacement = WorldUtils:acquirePlacement({
        factionId = "Player",
        stationTag = "SAFEHOUSE_STILL",
        featureType = "MissionArea",
        buildingType = "Safehouse",
        locationId = safeHouse.interiorLocationId
    })
    if not safehousePlacement then
        return
    end
    frankie.brain:addGoal("LeaveLocationAndTeleport", 100, {locationId = safehousePlacement.locationId, pos = safehousePlacement.station.pos})
    safehousePlacement:release()

    WorldUtils:createEvent("AllIrish")
    WorldUtils:scheduleWithDelay("AllIrishBoozeStolen", 2, "WEEKLY_TICK")
end

function onMissionFail()
    if frankie then
        frankie:delete()
        frankie = nil
    end

    if whiteHandRacketPlacement then
        whiteHandRacketPlacement:release()
        whiteHandRacketPlacement = nil
    end

    if whiteHandThugs then
        if whiteHandThugs.members then
            whiteHandThugs:removeFromSquads()
        else
            for i = 1, #whiteHandThugs do
                if whiteHandThugs[i] and not whiteHandThugs[i]:isDead() then
                    whiteHandThugs[i]:delete()
                    whiteHandThugs[i] = nil
                end
            end
        end
    end
end

--Check Frankie in the right position, old saves might not have moved him with the placement invalidating
function checkFrankie()
    if frankie then
        local pos, locId = MissionUtils:interactionPos3DOfBuilding(whiteHandRacket)
        MissionUtils:placeActorAtLocationId("NPC.MISSION_FRANKIE_YALE", locId, pos, frankie.iid, 2, 4, nil)
        updateObjectiveName("MeetWithFrankie", {"$MeetWithFrankie", whiteHandRacket.name})
    end
end
-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function testMission()
    onMissionStart()
end

function resetMission()
    fact.HitEmWhereItHurts_MetWithFrankie = false

    onMissionFail()
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == whiteHandRacketPlacement then
        if foughtThugs then
            local pos, locId = MissionUtils:interactionPos3DOfBuilding(whiteHandRacket)
            MissionUtils:placeActorAtLocationId("NPC.MISSION_FRANKIE_YALE", locId,pos, frankie.iid, 2, 4, nil)
            whiteHandRacketPlacement = nil
        elseif e.reason == "Upgrade" then
            whiteHandRacketPlacement = WorldUtils:acquirePlacement({
                buildingType = "Racket",
                featureType = "MissionArea",
                locationId = whiteHandRacket.interiorLocationId
            })
        else
            whiteHandRacketPlacement = WorldUtils:acquirePlacement(
                MissionUtils:racketOwnedByNeutralFaction()
            )

            if not whiteHandRacketPlacement then
                logError("no whiteHandRacketPlacement")
                failMission("$MissionFailLostBuilding")
                return
            end
            whiteHandRacket = WorldUtils:getBuildingFromPlacement(whiteHandRacketPlacement)
            fact.GuessWhosBack_racket = whiteHandRacket
            setParentValue("whiteHandRacket", whiteHandRacket)

            if fact.HitEmWhereItHurts_MetWithFrankie then
                ActorUtils:placeActorAtPlacement("NPC", "NPC.WHITE_HAND_WEAK", whiteHandRacketPlacement, frankie.iid, 1, 2)
            elseif not fact.HitEmWhereItHurts_MetWithFrankie and not foughtThugs then
                local pos, locId = MissionUtils:interactionPos3DOfBuilding(whiteHandRacket)
                MissionUtils:placeActorAtLocationId("NPC.MISSION_FRANKIE_YALE", locId, pos, frankie.iid, 2, 4, nil)
                updateObjectiveName("MeetWithFrankie", {"$MeetWithFrankie", whiteHandRacket.name})
            end

            MissionUtils:placeSquad(whiteHandThugs,  whiteHandRacket.interiorLocationId, whiteHandRacketPlacement.station.pos, nil, true)
        end
        fact.GuessWhosBack_racketPlacement = whiteHandRacketPlacement
        setParentValue("whiteHandRacketPlacement", whiteHandRacketPlacement)
    end
end

function GameEvent.onEnterLocation(e)
    if foughtThugs then
        return
    end
    local selectedActor = MissionUtils:selectedCharacter() or Character:getPlayer()
    if e.target == selectedActor then
        if e.locationId == whiteHandRacket.interiorLocationId then
            MissionUtils:makeNPCCombat(frankie, true)
            frankie:addState("PlotArmor")
            local attacker
            if whiteHandThugs.members then
                local _, lead = next(whiteHandThugs.members)
                attacker = lead
            else
                attacker = whiteHandThugs[1]
            end
            if not attacker or (attacker and (attacker.isDeleted or attacker:isDead())) then
                if whiteHandThugs.members then
                    for _, thug in next, whiteHandThugs.members do
                        if thug and not (thug.isDeleted or thug:isDead()) then
                            attacker = thug
                            break
                        end
                    end
                else
                    for i = 1, #whiteHandThugs do
                        if whiteHandThugs[i] and not (whiteHandThugs[i].isDeleted or whiteHandThugs[i]:isDead()) then
                            attacker = whiteHandThugs[i]
                            break
                        end
                    end
                end


            end
            WorldUtils:startScenario("StartCombatOnLoadLoc", attacker, MissionUtils:selectedCharacter())
        end
    end
end

function GameEvent.onCombatResolvedAndCleanedUp(e)
    if whiteHandThugs then
        if MissionUtils:isSquadDead(whiteHandThugs) then
            if not fact.HitEmWhereItHurts_MetWithFrankie or frankie:getLocationId() ~=  whiteHandRacket.interiorLocationId then
                fact.HitEmWhereItHurts_MetWithFrankie = true
            end
            foughtThugs = true
        end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function MeetWithFrankie()
    defineObjective
    {
        description = {"$MeetWithFrankie", whiteHandRacket.name}, --$ Meet Yale outside {0}.
    }
    addPOI(frankie)
end

checkedFrankie = nil
function MeetWithFrankieCheck()
    if not checkedFrankie then
        checkedFrankie = true
        checkFrankie()
    end
    return fact.HitEmWhereItHurts_MetWithFrankie or foughtThugs
end

function MeetWithFrankieDone()
    if not foughtThugs then
        frankie.brain:addGoal("EnterLocation", 1000, {whiteHandRacket, true, whiteHandRacketPlacement.station.pos, 0})
    end
    addObjective("TakeOutThugs")
end

function TakeOutThugs()
    defineObjective
    {
        description = "$TakeOutThugs", --$ Take out the thugs inside the racket.
    }
    addPOI(frankie)
end

function TakeOutThugsCheck()
    return foughtThugs
end

function TakeOutThugsDone()
    whiteHandThugs = nil
    if frankie:isDead() then
        MissionUtils:resurrectCharacter(frankie)
    end
    if frankie:hasState("PlotArmor") then
        frankie:removeState("PlotArmor")
    end
    MissionUtils:makeNPCNonCombat(frankie)
    addObjective("ReturnToFrankie")
end

function ReturnToFrankie()
    defineObjective
    {
        description = "$ReturnToFrankie", --$ Return To Frankie.
    }
    MissionUtils:setEntryPoint(frankie, "Capone6_Start")
    addPOI(frankie)
end

function ReturnToFrankieCheck()
    return fact.HitEmWhereItHurts_ReturnedToFrankie
end

function ReturnToFrankieDone()
end

--[[------------------------------------------------------------------------------
IT'S ALL IRISH TO ME
--------------------------------------------------------------------------------]]
_id = "ALL_IRISH"
_mission = "AllIrish"
_priority = 100

persist{}
racketPlacement = nil

persist{}
playerRacketPlacement = nil

persist{}
frankie = nil

persist{}
outsideThugs = {}

persist{}
insideThugs = {}

persist{}
racketGuard = nil

function onMissionCreate()
    defineMission
    {
        name = "$AllIrish_name", --$ It's All Irish To Me
        description = "$AllIrish_desc", --$  Frankie was able to translate that note you gave him. Turns out it was all in Irish. Now Yale knows where the White Hand boss is, and more importantly, where his stash is.
    }
    frankie = ActorUtils:getActorFromLabel("FrankieYale")
end

function onMissionStart()
    addSubMission("AllIrish1", true, "racketPlacement", racketPlacement, "playerRacketPlacement", playerRacketPlacement)

    addNotorietyReward(5, "$MissionReward_AllIrishToMe") --$ Took over thug racket
    addItemsReward("ITEM.WEAPON.RARE_MACHINEGUN_02", 1)
end

function onMissionSuccess()
    if racketPlacement then
        racketPlacement:release()
        racketPlacement = nil
    end

    local safehousePlacement = WorldUtils:acquirePlacement({
        factionId = "Player",
        stationTag = "SAFEHOUSE_STILL",
        featureType = "MissionArea",
        buildingType = "Safehouse",
    })
    if not safehousePlacement then
        return
    end

    frankie.brain:addGoal("LeaveLocationAndTeleport", 100, {locationId = safehousePlacement.locationId, pos = safehousePlacement.station.pos})
    safehousePlacement:release()

    WorldUtils:createEvent("RedHanded")
end

function onMissionFail()
    if outsideThugs then
        if outsideThugs.members then
            outsideThugs:removeFromSquads()
        else
            for i = 1, #outsideThugs do
                if outsideThugs[i] ~= nil and (not outsideThugs[i].isDeleted or not outsideThugs[i]:isDead()) then
                    outsideThugs[i]:delete()
                    outsideThugs[i] = nil
                end
            end
        end
    end

    if insideThugs then
        if insideThugs.members then
            insideThugs:removeFromSquads()
        else
            for i = 1, #insideThugs do
                if insideThugs[i] ~= nil and (not insideThugs[i].isDeleted or not insideThugs[i]:isDead()) then
                    insideThugs[i]:delete()
                    insideThugs[i] = nil
                end
            end
        end
    end

    if racketGuard then
        racketGuard:delete()
        racketGuard = nil
    end

    if racketPlacement then
        racketPlacement:release()
        racketPlacement = nil
    end
    if playerRacketPlacement then
        playerRacketPlacement:release()
        playerRacketPlacement = nil
    end
end

-- -----------------------------------
-- MISSION TESTS
-- -----------------------------------
function testMission()
    onMissionStart()
end

function resetMission()
    onMissionFail()
end

--[[------------------------------------------------------------------------------
IT'S ALL IRISH TO ME I
--------------------------------------------------------------------------------]]
_id = "ALL_IRISH_1"
_mission = "AllIrish1"
_barkeepQuestion  = true

persist{}
racketPlacement = nil

persist{}
racket = nil

persist{}
playerRacket = nil

persist{}
playerRacketPlacement = nil

persist{}
racketGuard = nil

function onMissionCreate()
    racket = WorldUtils:getLocationFromId(racketPlacement.locationId).building
    playerRacket = WorldUtils:getLocationFromId(playerRacketPlacement.locationId).building
    defineMission
    {
        name = {"$AllIrish1_name", playerRacket.name}, --$ Meet Yale at {0}
        description = {"$AllIrish1_desc", playerRacket.name}, --$ Yale knows where his stash is and where the White Hand gang are hiding out. He wants you to meet him at {0} to discuss the next steps.
    }

    local racketGuardConfigId = MissionUtils:getRacketGuardConfigId()
    racketGuard = ActorUtils:placeActorAtPlacement("NPC", racketGuardConfigId, playerRacketPlacement)
    racketGuard:setConversationEntryPoint("Capone8_Start", nil, 100)
    setParentValue("racketGuard", racketGuard)
end

function onMissionStart()
    addObjective("FindFrankie")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == racketPlacement then
        if e.reason == "Upgrade" then
            racketPlacement = WorldUtils:acquirePlacement({
                buildingType = "Racket",
                featureType = "MissionArea",
                locationId = racket.interiorLocationId
            })
        else
            racketPlacement = WorldUtils:acquirePlacement(
                MissionUtils:drinkingRacketOwnedByNeutralFaction()
            )

            if not racketPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            racket = WorldUtils:getLocationFromId(racketPlacement.locationId).building
        end
	setParentValue("racketPlacement", racketPlacement)
        fact.AllIrishToMe_racketPlacement = racketPlacement

    elseif e.placement == playerRacketPlacement then
        if e.reason == "Upgrade" then
            playerRacketPlacement = WorldUtils:acquirePlacement({
                buildingType = "Racket",
                featureType = "MissionArea",
                locationId = playerRacket.interiorLocationId
            })
        else
            playerRacketPlacement = WorldUtils:acquirePlacement(
                {
                    factionId = "Player",
                    buildingType = "Racket",
                    featureType = "MissionArea",
                }, 2,
                {
                    factionIds = MissionUtils:getNonHatedFactionIds(),
                    buildingType = "Racket",
                    featureType = "MissionArea",
            }, 1)

            if not playerRacketPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            playerRacket = WorldUtils:getLocationFromId(playerRacketPlacement.locationId).building
            local racketGuardConfigId = MissionUtils:getRacketGuardConfigId()
            racketGuard = ActorUtils:placeActorAtPlacement("NPC", racketGuardConfigId, playerRacketPlacement, racketGuard.iid)
        end
        setParentValue("playerRacketPlacement", playerRacketPlacement)
    end
end

function GameEvent.onLocationActivated(e)
    local building = e.location.building
    if building == playerRacket then
        WorldUtils:addBarkeepQuestion(_mission, "CONVERSATIONS.CAPONE_8", "CONVERSATIONS.CAPONE_8", "Quote_A1")
    else
        WorldUtils:removeBarkeepQuestion(_mission)
    end
end
-- --------------------------
-- Objectives
-- --------------------------
function FindFrankie()
    defineObjective
    {
        description = "$FindFrankie", --$ Find Yale.
    }
    addPOI(racketGuard)
end

function FindFrankieCheck()
    return fact.AllIrishToMe_SpokeWithGuard
end

function FindFrankieDone()
end

function onMissionSuccess()
    if playerRacketPlacement then
        playerRacketPlacement:release()
        playerRacketPlacement = nil
        setParentValue("playerRacketPlacement", nil)
    end

    racketGuard.brain:addGoal("DeleteOnLookAway", 1000)
    racketGuard = nil
    setParentValue("racketGuard", nil)

    WorldUtils:triggerEvent("AllIrishRansomNote", "racketName", racket.name)
    addSubMission("AllIrish2", true, "racketPlacement", racketPlacement, "racket", racket)
end

--[[------------------------------------------------------------------------------
IT'S ALL IRISH TO ME II
--------------------------------------------------------------------------------]]
_id = "ALL_IRISH_2"
_mission = "AllIrish2"

persist{}
racketPlacement = nil

persist{}
racket = nil

persist{}
outsideThugs = nil

persist{}
insideThugs = nil

persist{}
frankie = nil

persist{}
foughtOutsideThugs = false

persist{}
foughtInsideThugs = false

function onMissionCreate()
    defineMission
    {
        name = {"$AllIrish2_name", racket.name}, --$ Go to {0} and find Yale
        description = {"$AllIrish2_desc", racket.name}, --$ Yale's being held at {0} by the White Hand gang. They want you to bring some cash in exchange for his freedom. Or, you can bring a few trusty guns and spring him the old fashioned way.
    }

    --FRANKIE
    frankie = ActorUtils:getActorFromLabel("FrankieYale")
    local stationTag
    if racket.buildingData.id == "BAR" then
        stationTag = "BAR_ROOM_SPAWN"
    elseif racket.buildingData.id == "CASINO" then
        stationTag = "CASINO_ROOM_SPAWN"
    elseif racket.buildingData.id == "BROTHEL" then
        stationTag = "BROTHEL_ROOM_SPAWN"
    end

    local frankieStation = racketPlacement.feature:findFreeStation(stationTag)
    frankie:setLocationId(racketPlacement.locationId, frankieStation.pos, frankieStation.rot)
    frankie.anims:setInjured(true)

    local whiteHandFaction = WorldUtils:getFactionById("FACTION.THUGS")
    local outsidePos, locationId = MissionUtils:interactionPosOfBuilding(racket)
    --INSIDE THUGS
    insideThugs = MissionUtils:spawnSquad(5, "FACTION.WHITE_HAND_GANG")
    MissionUtils:placeSquad(insideThugs, racketPlacement.locationId, racketPlacement.station.pos, "Capone9_Start", true)
    setParentValue("insideThugs", insideThugs)

    --OUTSIDE THUGS
    outsideThugs = MissionUtils:spawnSquad(5, "FACTION.WHITE_HAND_GANG")
    MissionUtils:placeSquad(outsideThugs, locationId, outsidePos, nil, true, outsidePos, true)
    setParentValue("outsideThugs", outsideThugs)

    racket.memory.buildingLocked = true
end

function onMissionStart()
    addObjective("GetInsideRacket")
    addObjective("TalkToWhiteHand")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == racketPlacement then
        if e.reason == "Upgrade" then
            racketPlacement = WorldUtils:acquirePlacement({
                buildingType = "Racket",
                featureType = "MissionArea",
                locationId = racket.interiorLocationId
            })
        else
            racketPlacement = WorldUtils:acquirePlacement(
                MissionUtils:drinkingRacketOwnedByNeutralFaction()
            )
            if not racketPlacement then
                logError("no racketPlacement")
                failMission("$MissionFailLostBuilding")
                return
            end
            local buildingLocked = racket.memory.buildingLocked
            racket.memory.buildingLocked = nil
            racket = WorldUtils:getLocationFromId(racketPlacement.locationId).building
            racket.memory.buildingLocked = buildingLocked
            local stationTag
            if racket.buildingData.id == "BAR" then
                stationTag = "BAR_ROOM_SPAWN"
            elseif racket.buildingData.id == "CASINO" then
                stationTag = "CASINO_ROOM_SPAWN"
            elseif racket.buildingData.id == "BROTHEL" then
                stationTag = "BROTHEL_ROOM_SPAWN"
            end

            local frankieStation = racketPlacement.feature:findFreeStation(stationTag)
            frankie:setLocationId(racketPlacement.locationId, frankieStation.pos, frankieStation.rot)

            --INSIDE THUGS
            MissionUtils:placeSquad(insideThugs, racketPlacement.locationId, racketPlacement.station.pos)

            --OUTSIDE THUGS
            if not foughtOutsideThugs then
                local outsidePos, locationId = MissionUtils:interactionPosOfBuilding(racket)
                MissionUtils:placeSquad(outsideThugs, locationId, outsidePos)
            end
        end
        setParentValue("racketPlacement", racketPlacement)
    end
end

function GameEvent.onCombatResolvedAndCleanedUp()
    if outsideThugs and MissionUtils:isSquadDead(outsideThugs) then
        foughtOutsideThugs = true
    elseif outsideThugs and not foughtOutsideThugs then
        local foundPOI
        for i = 1, #outsideThugs do
            if outsideThugs.members then
                for _, crewMember in next, outsideThugs.members do
                    if crewMember and not crewMember:isDead() and checkForPOI(crewMember, "GetInsideRacket") then
                        foundPOI = true
                        break
                    end
                end
            else
                local crewMember = outsideThugs[i]
                if crewMember and not crewMember:isDead() and checkForPOI(crewMember, "GetInsideRacket") then
                    foundPOI = true
                    break
                end
            end
        end
        if not foundPOI then
            if outsideThugs.members then
                for _, crewMember in next, outsideThugs.members do
                    if crewMember and not crewMember:isDead() then
                        addPOI(crewMember, "MISSION_TARGET", "GetInsideRacket")
                        break
                    end
                end
            else
                for i = 1, #outsideThugs do
                    local crewMember = outsideThugs[i]
                    if crewMember and not crewMember:isDead() then
                        addPOI(crewMember, "MISSION_TARGET", "GetInsideRacket")
                        break
                    end
                end
            end
        end
    end

    if insideThugs and MissionUtils:isSquadDead(insideThugs) then
        foughtInsideThugs = true
    elseif insideThugs and foughtOutsideThugs and not (foughtInsideThugs or fact.AllIrishToMe_BribedWhiteHand) then
        local foundPOI
        if insideThugs.members then
            for _, crewMember in next, insideThugs.members do
                if crewMember and not crewMember:isDead() and checkForPOI(crewMember, "TalkToWhiteHand") then
                    foundPOI = true
                    break
                end
            end
        else
            for i = 1, #insideThugs do
                local crewMember = insideThugs[i]
                if crewMember and not crewMember:isDead() and checkForPOI(crewMember, "TalkToWhiteHand") then
                    foundPOI = true
                    break
                end
            end
        end

        if not foundPOI then
            if insideThugs.members then
                for _, crewMember in next, insideThugs.members do
                    if crewMember and not crewMember:isDead() then
                        addPOI(crewMember, "MISSION_TARGET", "TalkToWhiteHand")
                        break
                    end
                end
            else
                for i = 1, #insideThugs do
                    local crewMember = insideThugs[i]
                    if crewMember and not crewMember:isDead() then
                        addPOI(crewMember, "MISSION_TARGET", "TalkToWhiteHand")
                        break
                    end
                end
            end
        end
    end

end

function GameEvent.onLateLocationActivated(e)
    if e.location.id == racket.interiorLocationId then
        local selectedActor = MissionUtils:selectedCharacter()
        if selectedActor:getLocationId() == racket.interiorLocationId then
            local whiteHandMember
            if insideThugs.members then
                local _, lead = next(insideThugs.members)
                whiteHandMember = lead
            else
                whiteHandMember = insideThugs[1]
            end
            WorldUtils:startScenario("NPCApproachesPlayer", whiteHandMember)
        end
    end
end
-- --------------------------
-- Objectives
-- --------------------------
function GetInsideRacket()
    defineObjective
    {
        description = {"$GetInsideRacket", racket.name}, --$ Get inside {0}.
    }
    local leadThug
    if outsideThugs.members then
        local _, thug = next(outsideThugs.members)
        leadThug = thug
    else
        leadThug = outsideThugs[1]
    end

    addPOI(leadThug)
end

function GetInsideRacketCheck()
    return foughtOutsideThugs or foughtInsideThugs
end

function GetInsideRacketDone()
    if outsideThugs and not MissionUtils:isSquadDead(outsideThugs) then
        if outsideThugs.members then
            outsideThugs:removeFromSquads()
        end
    end
    outsideThugs = nil
    setParentValue("outsideThugs", nil)
    racket.memory.buildingLocked = nil
end

function TalkToWhiteHand()
    defineObjective
    {
        description = "$ConfrontTheWhiteHand", --$ Confront the White Hand.
    }
    local leadThug
    if insideThugs.members then  -- MEGAMOD: was outsideThugs (nil by this point, causing crash)
        local _, thug = next(insideThugs.members)
        leadThug = thug
    else
        leadThug = insideThugs[1]
    end

    addPOI(leadThug)
end

function TalkToWhiteHandCheck()
    return foughtInsideThugs or fact.AllIrishToMe_BribedWhiteHand
end

function TalkToWhiteHandDone()
end

function onMissionSuccess()
    if fact.AllIrishToMe_BribedWhiteHand then
        MissionUtils:makeSquadLeave(insideThugs)
    end
    if outsideThugs then
        outsideThugs = nil
        setParentValue("outsideThugs", nil)
    end
    insideThugs = nil
    setParentValue("insideThugs", nil)
    addSubMission("AllIrish3", true, "racketPlacement", racketPlacement, "racket", racket)
end

--[[------------------------------------------------------------------------------
IT'S ALL IRISH TO ME III
--------------------------------------------------------------------------------]]
_id = "ALL_IRISH_3"
_mission = "AllIrish3"

persist{}
racketPlacement = nil

persist{}
racket = nil

persist{}
frankie = nil

function onMissionCreate()
    defineMission
    {
        name = {"$AllIrish3_name", racket.name}, --$ Talk to Yale
        description = {"$AllIrish3_desc", racket.name}, --$ You freed Yale from White Hand gang captivity. Talk to him and see what he has to say.
    }

    --FRANKIE
    frankie = ActorUtils:getActorFromLabel("FrankieYale")
    MissionUtils:setEntryPoint(frankie, "Capone10_Start")
end

function onMissionStart()
    addObjective("CheckFrankie")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == racketPlacement then
        if e.reason == "Upgrade" then
            racketPlacement = WorldUtils:acquirePlacement({
                buildingType = "Racket",
                featureType = "MissionArea",
                locationId = racket.interiorLocationId
            })
        else
            racketPlacement = WorldUtils:acquirePlacement({
                factionId = "Player",
                stationTag = "SAFEHOUSE_STILL",
                featureType = "MissionArea",
                buildingType = "Safehouse",
            })

            if not racketPlacement then
                logError("no racketPlacement")
                failMission("$MissionFailLostBuilding")
                return
            end
            racket = WorldUtils:getLocationFromId(racketPlacement.locationId).building
            ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_FRANKIE_YALE", racketPlacement, frankie.iid)
        end
        setParentValue("racketPlacement", racketPlacement)
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function CheckFrankie()
    defineObjective
    {
        description = "$CheckOnFrankie", --$ Check on Yale.
    }
    addPOI(frankie)
end

function CheckFrankieCheck()
    return fact.AllIrishToMe_CheckedOnFrankie
end

function CheckFrankieDone()
end

--[[------------------------------------------------------------------------------
RED HANDED
--------------------------------------------------------------------------------]]
_id = "RED_HANDED"
_mission = "RedHanded"
_priority = 100

persist{}
darlaPlacement = nil

persist{}
barPlacement = nil

persist{}
truckPlacement = nil

persist{}
safehousePlacement = nil

persist{}
yalesRacketPlacement = nil

persist{}
brewery = nil

persist{}
bar = nil

persist{}
safehouse = nil

persist{}
yalesRacket = nil

persist{}
darla = nil

persist{}
bert = nil

persist{}
bartender = nil

persist{}
thugSquad = nil

persist{}
yale = nil

function onMissionCreate()
    defineMission
    {
        name = "$RedHanded_name", --$ Red Handed
        description = "$RedHanded_desc", --$ This is the second time someone's hijacked your brewery truck You've gotta look into it before they strike again.
    }

    brewery = WorldUtils:getLocationFromId(darlaPlacement.locationId).building
    bar = WorldUtils:getLocationFromId(barPlacement.locationId).building
    safehouse = WorldUtils:getLocationFromId(safehousePlacement.locationId).building
    yalesRacket = WorldUtils:getLocationFromId(yalesRacketPlacement.locationId).building

    darla = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_DARLA", darlaPlacement)
    darla.memory.RedHanded_BertsRacket = bar.name

    yale = ActorUtils:getActorFromLabel("FrankieYale")
    yale.anims:setInjured(false)

    fact.RedHanded_ConfrontedYale = 0
end

function onMissionStart()
    addSubMission("RedHanded1")


    addNotorietyReward(1, "$MissionReward_RedHanded") --$ Dealt with a traitor
end

function onMissionSuccess()
    -- ----------------------------
    -- 1: Agreed to kill Darla
    -- ----------------------------
    if fact.RedHanded_ConfrontedYale == 1 then
        yalesRacketPlacement:release()
        yalesRacketPlacement = nil

        WorldUtils:startMission("AboutDarla", "darlaPlacement", darlaPlacement, "darla", darla, "safehousePlacement", safehousePlacement)
    -- ----------------------------
    -- 3: Killed Yale
    -- ----------------------------
    elseif fact.RedHanded_ConfrontedYale == 2 then
        fact.BossMissionCompleted = true
        Utils:raiseGameEvent("onBossMissionChainCompleted", "success", true)

        if yalesRacketPlacement then
            yalesRacketPlacement:release()
            yalesRacketPlacement = nil
        end

        safehousePlacement:release()
        safehousePlacement = nil

        darlaPlacement:release()
        darlaPlacement = nil
        darla:delete()
        darla = nil

        yale = nil
    end
end

function onMissionFail()
    if darla then
        darla:delete()
        darla = nil
    end
    if bert then
        bert:delete()
        bert = nil
    end
    if thugSquad then
        thugSquad:deleteMembers()
        thugSquad:removeFromSquads()
        thugSquad = nil
    end

    if darlaPlacement then
        darlaPlacement:release()
        darlaPlacement = nil
    end
    if barPlacement then
        barPlacement:release()
        barPlacement = nil
    end
    if truckPlacement then
        truckPlacement:release()
        truckPlacement = nil
    end
    if safehousePlacement then
        safehousePlacement:release()
        safehousePlacement = nil
    end
    if yalesRacketPlacement then
        yalesRacketPlacement:release()
        yalesRacketPlacement = nil
    end
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    local placement = e.placement
    if placement == darlaPlacement then
        if e.reason == "Upgrade" then
            darlaPlacement = WorldUtils:acquirePlacement({
                locationId = brewery.interiorLocationId,
                buildingType = "Racket",
                featureType = "MissionArea"
            })
        else
            darlaPlacement = WorldUtils:acquirePlacement(
                MissionUtils:breweryOrRacketOwnedByPlayer()
            )

            if not darlaPlacement then
                failMission("$MissionFailLostBuilding")
            else
                brewery = WorldUtils:getBuildingFromPlacement(darlaPlacement)
                darla = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_DARLA", darlaPlacement, darla.iid)
            end
        end
    -- BERT PLACEMENT
    elseif placement == barPlacement then
        if e.reason == "Upgrade" then
            barPlacement = WorldUtils:acquirePlacement({
                locationId = bar.interiorLocationId,
                buildingType = "Racket",
                featureType = "MissionArea"
            })
        else
            barPlacement = WorldUtils:acquirePlacement(
                MissionUtils:barOrDrinkingRacketOwnedByPlayer()
            )
            if not barPlacement then
                failMission("$MissionFailLostBuilding")
            else
                bar = WorldUtils:getBuildingFromPlacement(barPlacement)
                if bert then
                    bert = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_BREWERY_WORKER", barPlacement, bert.iid)
                end
                if bartender then
                    ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_BARTENDER", barPlacement, bartender.iid, 1, 4)
                end
            end
        end
        -- SAFEHOUSE PLACEMENT
    elseif placement == safehousePlacement then
        if e.reason == "Upgrade" then
            safehousePlacement = WorldUtils:acquirePlacement({
                locationId = safehouse.interiorLocationId,
                buildingType = "All",
                featureType = "MissionArea"
            })
        else
            safehousePlacement = WorldUtils:acquirePlacement(
                MissionUtils:safehouseOrRacketOwnedByPlayer()
            )

            if not safehousePlacement then
                failMission("$MissionFailLostBuilding")
            else
                safehouse = WorldUtils:getBuildingFromPlacement(safehousePlacement)
                yale = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_FRANKIE_YALE", safehousePlacement, yale.iid)
            end
        end
        -- YALES RACKET PLACEMENT
    elseif placement == yalesRacketPlacement then
        if e.reason == "Upgrade" then
            yalesRacketPlacement = WorldUtils:acquirePlacement({
                locationId = yalesRacket.interiorLocationId,
                buildingType = "Racket",
                featureType = "MissionArea"
            })
        elseif WorldUtils:isMissionActive("RedHanded5") and ((e.reason == "ConqueredByPlayer") or (e.reason == "ClearedOutByPlayer")) then
            yalesRacketPlacement = nil
        else
            yalesRacketPlacement = WorldUtils:acquirePlacement(
                MissionUtils:racketOwnedByNeutralFaction()
            )
            if not yalesRacketPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            yalesRacket = WorldUtils:getLocationFromId(yalesRacketPlacement.locationId).building
        end
    end
end

-- --------------------------
-- Mission Tests
-- --------------------------
function resetMission()
    fact.RedHanded_TalkedToDarla = false
    fact.RedHanded_TalkedToBert = false
    fact.RedHanded_TalkedToBartenderOrRPC = false
    fact.RedHanded_BribedThug = false
    fact.RedHanded_TalkedToDarlaAgain = false
    fact.RedHanded_ConfrontedYale = 0

    onMissionFail()
end

function testSubMission1()
    onMissionStart()
end

function testSubmission2()
    testSubMission1()
    fact.RedHanded_TalkedToDarla = true
end

function testSubmission3()
    testSubmission2()
    fact.RedHanded_TalkedToBert = true
    fact.RedHanded_TalkedToBartenderOrRPC = true
end

function testSubmission4()
    testSubmission3()
    fact.RedHanded_BribedThug = true
end

function testSubmission5()
    testSubmission4()
    fact.RedHanded_TalkedToDarlaAgain = true
end

function testAboutDarla_PlayerAgreedToKilledDarla()
    testSubmission5()
    fact.RedHanded_ConfrontedYale = 1
end

--[[------------------------------------------------------------------------------
RED HANDED I
--------------------------------------------------------------------------------]]
_id = "RED_HANDED_1"
_mission = "RedHanded1"

persist{}
darla = nil

function onMissionCreate()
    defineMission
    {
        name = "$RedHanded1_name", --$ Talk to your brewery worker, Darla
        description = "$RedHanded1_desc", --$ Darla might have some insight on who hijacked the truck. She was working at your brewery the night it was taken.
    }

    darla = getParentValue("darla")
    darla:setConversationEntryPoint("Capone11_Start", nil, 100)
end

function onMissionStart()
    addObjective("TalkToDarla")
end

-- --------------------------
-- Objectives
-- --------------------------
function TalkToDarla()
    defineObjective
    {
        description = "$TalkToDarla", --$ Talk To Darla.
    }
    addPOI(darla)
end

function TalkToDarlaCheck()
    return fact.RedHanded_TalkedToDarla
end

function TalkToDarlaDone()
end

function onMissionSuccess()
    addSubMission("RedHanded2")
end

--[[------------------------------------------------------------------------------
RED HANDED II
--------------------------------------------------------------------------------]]
_id = "RED_HANDED_2"
_mission = "RedHanded2"
_barkeepQuestion  = true

persist{}
bert = nil

persist{}
doctor = nil

persist{}
bartender = nil

function onMissionCreate()
    defineMission
    {
        name = "$RedHanded2_name", --$ Talk to Bert
        description = "$RedHanded2_desc", --$ Darla suggested talking to Bert, the driver of the hijacked truck. He's hiding out in one of your speakeasies drinking his troubles away. She also suggested that you might check out the actual truck to see if there's any evidence inside.
    }

    local barPlacement = getParentValue("barPlacement")
    bert = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_BREWERY_WORKER", barPlacement)
    bert.name = "$Bert_Name" --$ Bert
    bert.anims:setDrunk(true)

    setParentValue("bert", bert)
    bert:setConversationEntryPoint("Capone12_Start", nil, 100)

    bartender = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_BARTENDER", barPlacement, nil, 1, 4)
    setParentValue("bartender", bartender)
end

function onMissionStart()
    addObjective("TalkToBert")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onLocationActivated(e)
    if fact.RedHanded_TalkedToBert then
        local building = e.location.building
        local bar = getParentValue("bar")
        if building == bar then
            WorldUtils:addBarkeepQuestion(_mission, "CONVERSATIONS.CAPONE_12B", "CONVERSATIONS.CAPONE_12B", "Quote_Intro")
        else
            WorldUtils:removeBarkeepQuestion(_mission)
        end
    end
end

function GameEvent.onRemoveCrewCharacter(e)
    if e.character == doctor then
        addObjective("TalkToBartender")
        failObjective("TalkToRPC")
    end
end

function GameEvent.onMoleSent(e)
    if e.mole == doctor then
        addObjective("TalkToBartender")
        failObjective("TalkToRPC")
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function TalkToBert()
    defineObjective
    {
        description = "$TalkToBert", --$ Talk To Bert.
    }
    addPOI(bert)
end

function TalkToBertCheck()
    if not getParentValue("bert") then
        setParentValue("bert", bert)
    end

    return fact.RedHanded_TalkedToBert
end

function TalkToBertDone()
    MissionUtils:killCharacter(bert, true, true)
    bert = nil
    setParentValue("bert", nil)

    local rpcs = MissionUtils:getSelectedGroup()
    local hasDoctor = false
    for i = 1, #rpcs do
        if rpcs[i].profession:is("Doctor") then
            doctor = rpcs[i]
            break
        end
    end

    if doctor then
        addObjective("TalkToRPC")
    else
        addObjective("TalkToBartender")
    end
end

function TalkToRPC()
    defineObjective
    {
        description = "$TalkToRPC", --$ Talk to a doctor in your crew.
    }
    addPOI(doctor)

    doctor:setConversationEntryPoint("Capone12A_Start", nil, 100)
    WorldUtils:startScenario("NPCApproachesPlayer", doctor)
end

function TalkToRPCCheck()
    return fact.RedHanded_TalkedToBartenderOrRPC
end

function TalkToRPCDone()
    doctor:removeConversationEntryPoint("Capone12A_Start")
    doctor = nil
end

function TalkToBartender()
    defineObjective
    {
        description = "$TalkToBarTender", --$ Talk to the bartender.
    }
    bartender:setConversationEntryPoint("Capone12A_Start", nil, 100)
    WorldUtils:startScenario("NPCApproachesPlayer", bartender)

    addPOI(bartender)
end

function TalkToBartenderCheck()
    return fact.RedHanded_TalkedToBartenderOrRPC
end

function TalkToBartenderDone()
end

function onMissionSuccess()


    bartender.brain:addGoal("DeleteOnLookAway", 1000)
    bartender = nil
    setParentValue("bartender", nil)

    if getParentValue("barPlacement") then
        getParentValue("barPlacement"):release()
        setParentValue("barPlacement", nil)
    end

    bert = nil
    setParentValue("bert", nil)

    addSubMission("RedHanded3")
end

--[[------------------------------------------------------------------------------
RED HANDED III
--------------------------------------------------------------------------------]]
_id = "RED_HANDED_3"
_mission = "RedHanded3"

persist{}
thugSquad = nil

function onMissionCreate()
    defineMission
    {
        name = "$RedHanded3_name", --$ Inspect the brewery truck
        description = "$RedHanded3_desc", --$ The stolen brewery truck might have some clues as to who stole it.
    }

    local thugFaction = WorldUtils:getFactionById("FACTION.THUGS")
    thugSquad = thugFaction.squads:createUnmanaged(3, "Balanced")

    local truckPlacement = getParentValue("truckPlacement")
    MissionUtils:placeSquad(thugSquad, truckPlacement.locationId, truckPlacement.station.pos, "Capone13_Start", true)
    setParentValue("thugSquad", thugSquad)
end

function onMissionStart()
    addObjective("InspectTruck")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onCombatResolvedAndCleanedUp(e)
    if thugSquad and not MissionUtils:isSquadDead(thugSquad) then
        local foundPOI
        for _, thug in next, thugSquad.members do
            if not thug:isDead() and checkForPOI(thug, "InspectTruck") then
                foundPOI = true
                break
            end
        end
        if not foundPOI then
            for _, thug in next, thugSquad.members do
                if not thug:isDead() then
                    addPOI(thug, "MISSION_TARGET", "InspectTruck")
                    break
                end
            end
        end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function InspectTruck()
    defineObjective
    {
        description = "$InspectTruck", --$ Inspect the truck.
    }

    local _, leadThug = next(thugSquad.members)
    addPOI(leadThug)
end

function InspectTruckCheck()
    return fact.RedHanded_BribedThug or MissionUtils:isSquadDead(thugSquad)
end

function InspectTruckDone()
    WorldUtils:schedule("RedHanded_TruckInspection", "TICK")

    addItemsReward( "ITEM.EQUIPMENT.TRINKET_01", 1)
end

function onMissionSuccess()
    if thugSquad then
        MissionUtils:makeSquadLeave(thugSquad)
        thugSquad:removeFromSquads()
        thugSquad = nil
    end
    setParentValue("thugSquad", nil)

    addSubMission("RedHanded4")
end

--[[------------------------------------------------------------------------------
RED HANDED IV
--------------------------------------------------------------------------------]]
_id = "RED_HANDED_4"
_mission = "RedHanded4"

persist{}
darla = nil

function onMissionCreate()
    defineMission
    {
        name = "$RedHanded4_name", --$ Speak with Darla
        description = "$RedHanded4_desc", --$ Bert died while talking to you, and then you found a cigar in the stolen brewery truck. The cigar is most certainly one of Yale's. Let Darla know what you found out.
    }

    darla = getParentValue("darla")
    MissionUtils:setEntryPoint(darla, "Capone14_Start", nil, 104)
end

function onMissionStart()
    addObjective("TalkToDarla")
end

-- --------------------------
-- Objectives
-- --------------------------
function TalkToDarla()
    defineObjective
    {
        description = "$TalkToDarla",
    }
    addPOI(darla)
end

function TalkToDarlaCheck()
    return fact.RedHanded_TalkedToDarlaAgain
end

function TalkToDarlaDone()

end

function onMissionSuccess()
    addSubMission("RedHanded5")
end

--[[------------------------------------------------------------------------------
RED HANDED V
--------------------------------------------------------------------------------]]
_id = "RED_HANDED_5"
_mission = "RedHanded5"

persist{}
yale = nil

persist{}
enteredLocation = nil

persist{}
waitTillAfterFight = nil

function onMissionCreate()
    defineMission
    {
        name = "$RedHanded5_name", --$ Confront Yale
        description = "$RedHanded5_desc", --$ Bert died while talking to you, and then you found a cigar in the stolen brewery truck. The cigar is most certainly one of Yale's. Everything points to Yale, so you better go have a talk with him.
    }

    yale = getParentValue("yale")
    MissionUtils:setEntryPoint(yale, "Capone15_Start")
end

function onMissionStart()
    addObjective("ConfrontYale")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onLocationActivated(e)
    if fact.RedHanded_ConfrontedYale > 0 then
        local racket = getParentValue("yalesRacket")
        if e.location.id == racket.interiorLocationId then
            if WorldUtils:hasCombatLock("TakeOverBuilding") then
                waitTillAfterFight = true
            else
                enteredLocation = true
                WorldUtils:triggerEvent("RedHandedReward")
            end
        end
    end
end

function GameEvent.onCombatResolved(e)
    if e.aiAutoResolve then
        return
    end
    if waitTillAfterFight then
        enteredLocation = true
        WorldUtils:schedule("RedHandedReward")
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function ConfrontYale()
    defineObjective
    {
        description = "$RedHanded_DealWithYale", --$ Confront Yale about the missing booze.
    }
    yale.behaviours:add("GuardIfFlee", "targetPos", yale:getPos())
    addPOI(yale)
end

function ConfrontYaleCheck()
    return fact.RedHanded_ConfrontedYale > 0 or yale:isDead()
end

function ConfrontYaleDone()
    if yale:isDead() then
        WorldUtils:triggerEvent("RedHandedYaleNote", "racket", getParentValue("yalesRacket"))
        addObjective("GoToLocation")

        yale = nil
        setParentValue("yale", nil)
        fact.RedHanded_ConfrontedYale = 2
    end
end

function GoToLocation()
    local yalesRacket = getParentValue("yalesRacket")
    defineObjective
    {
        description = {"$RedHanded_GoToLocation", yalesRacket.name} --$ Go to {0}.
    }


    addPOI(yalesRacket)
end

function GoToLocationCheck()
    return enteredLocation
end

function GoToLocationDone()
end

--[[------------------------------------------------------------------------------
THE THING ABOUT DARLA
--------------------------------------------------------------------------------]]
_id = "ABOUT_DARLA"
_mission = "AboutDarla"
_priority = 100
_finalBossMission = true

persist{}
darlaPlacement = nil

persist{}
safehousePlacement = nil

persist{}
brewery = nil

persist{}
safehouse = nil

persist{}
darla = nil

persist{}
yale = nil

persist{}
safehouseMarker = nil

function onMissionCreate()
    defineMission
    {
        name = "$AboutDarla_name", --$  The Thing About Darla
        description = "$AboutDarla_desc", --$ Yale thinks that Darla is the mole in your operation. He said she's been stealing crates of booze from you recently.
    }
    brewery = WorldUtils:getLocationFromId(darlaPlacement.locationId).building
    safehouse = WorldUtils:getLocationFromId(safehousePlacement.locationId).building
    yale = ActorUtils:getActorFromLabel("FrankieYale")

    MissionUtils:setEntryPoint(yale, "Capone18_Start", nil, 200)
    safehouseMarker = MissionUtils:placeMarker(safehouse)
end

function onMissionStart()
    addSubMission("AboutDarla1")
end

function onMissionSuccess()
    if safehouseMarker then
        safehouseMarker:delete()
    end
    if fact.AboutDarla_ReturnedToYale then
        addUpgradeReward(safehouse, "security", 1)
        Utils:showGameAlert("BUILDING_UPGRADED", safehouse.name)

        if safehousePlacement then
            safehousePlacement:release()
        end
        WorldUtils:createEvent("WarmReunionRedux_Note", "safehouse", safehouse)
    end
end

function onMissionFail()
    if darla then
        darla:delete()
        darla = nil
    end
    if yale then
        yale:delete()
        yale = nil
    end

    if darlaPlacement then
        darlaPlacement:release()
        darlaPlacement = nil
    end
    if safehousePlacement then
        safehousePlacement:release()
        safehousePlacement = nil
    end
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    local placement = e.placement
    if placement == darlaPlacement then
        if e.reason == "Upgrade" then
            darlaPlacement = WorldUtils:acquirePlacement({
                locationId = brewery.interiorLocationId,
                buildingType = "Racket",
                featureType = "MissionArea"
            })
        else
            darlaPlacement = WorldUtils:acquirePlacement(
                MissionUtils:breweryOrRacketOwnedByPlayer()
            )

            if not darlaPlacement then
                failMission("$MissionFailLostBuilding")
            else
                darla = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_DARLA", darlaPlacement, darla.iid)
            end
        end
    -- SAFEHOUSE PLACEMENT
    elseif placement == safehousePlacement then
        if e.reason == "Upgrade" then
            safehousePlacement = WorldUtils:acquirePlacement({
                locationId = safehouse.interiorLocationId,
                buildingType = "All",
                featureType = "MissionArea"
            })
        else
            safehousePlacement = WorldUtils:acquirePlacement(
                MissionUtils:safehouseOrRacketOwnedByPlayer()
            )
            safehouse = WorldUtils:getBuildingFromPlacement(safehousePlacement)
            MissionUtils:placeMarker(safehouse, safehouseMarker.iid)

            if not safehousePlacement then
                failMission("$MissionFailLostBuilding")
            else
                yale = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_FRANKIE_YALE", safehousePlacement, yale.iid)
            end
        end
    end
end

-- --------------------------
-- Mission Tests
-- --------------------------
function resetMission()
    fact.AboutDarla_ReturnedToYale = false
    fact.AboutDarla_ConfrontedDarla = false

    onMissionFail()
end

function testSubMission1_PlayerConfrontsDarla()
    fact.RedHanded_ConfrontedYale = 1
    onMissionStart()
end

function testSubMission1_YaleConfrontsDarla()
    fact.RedHanded_ConfrontedYale = 2
    onMissionStart()
end

--[[------------------------------------------------------------------------------
THE THING ABOUT DARLA I
--------------------------------------------------------------------------------]]
_id = "ABOUT_DARLA_1"
_mission = "AboutDarla1"

persist{}
darla = nil

function onMissionCreate()
    defineMission
    {
        name = "$AboutDarla1_name", --$  Deal with Darla
        description = "$AboutDarla1_desc", --$ Yale says that Darla's been stealing from you. Confront her and see what she has to say for herself.
    }

    darla = getParentValue("darla")
    MissionUtils:setEntryPoint(darla, "Capone16_Start", nil, 105)
end

function onMissionStart()
    addObjective("ConfrontDarla")
end

-- --------------------------
-- Objectives
-- --------------------------
function ConfrontDarla()
    defineObjective
    {
        description = "$AboutDarla_ConfrontDarla", --$ Deal with Darla.
    }
    addPOI(darla)
end

function ConfrontDarlaCheck()
    return fact.AboutDarla_ConfrontedDarla or darla:isDead()
end

function ConfrontDarlaDone()
end

function onMissionSuccess()
    local sparedDarla = false
    if not darla:isDead() then
        sparedDarla = true

        addHonorReward(WorldUtils:noFaction(), "CAPONE_SPARED_DARLA")
        if fact.AboutDarla_TalkedAboutCops then
            addUpgradeReward("ALL", "deflect", 1)
            WorldUtils:createEvent("AboutDarlaAlcoholReduction")
        end
        MissionUtils:returnActorToWork(darla, "BREWERY")
    else
        getParentValue("yale").memory.AboutDarla_DarlaIsDead = true
        addItemsReward("ITEM.WEAPON.RARE_RIFLE_02", 1)
        addHonorReward(WorldUtils:noFaction(), "CAPONE_KILLED_DARLA")
    end

    local darlaPlacement = getParentValue("darlaPlacement")
    darlaPlacement:release()
    setParentValue("darlaPlacement", nil)

    darla = nil
    setParentValue("darla", nil)

    addSubMission("AboutDarla2", true, "playerSparedDarla", sparedDarla)
end

--[[------------------------------------------------------------------------------
THE THING ABOUT DARLA II
--------------------------------------------------------------------------------]]
_id = "ABOUT_DARLA_2"
_mission = "AboutDarla2"

persist{}
yale = nil

persist{}
playerSparedDarla = false

persist{}
recievedYaleNote = false

function onMissionCreate()
    local missionDesc
    if playerSparedDarla then
        missionDesc = "$AboutDarla2_PlayerSparedDesc" --$ You spoke with Darla and believed her side of the story. Now you've gotta deal with Yale.
    else
        missionDesc = "$AboutDarla2_PlayerKilledDarlaDesc" --$ Darla's dead. She was stealing from you. Return to Yale and let him know what happened.
    end

    defineMission
    {
        name = "$AboutDarla2_name", --$  Return to Yale.
        description = missionDesc
    }

    yale = getParentValue("yale")
    if not playerSparedDarla then
        yale = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_FRANKIE_YALE", getParentValue("safehousePlacement"), yale.iid)
    else
        yale:setLocationId(0)
    end
end

function onMissionStart()
    addObjective("ReturnToYale")
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onLocationActivated(e)
    if playerSparedDarla then
        local safehouse = getParentValue("safehouse")
        if e.location.id == safehouse.interiorLocationId then
            WorldUtils:triggerEvent("WarmReunionRedux_Note", "safehouse", safehouse)
            recievedYaleNote = true
        end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function ReturnToYale()
    defineObjective
    {
        description = "$AboutDarla_ReturnToYale", --$ Return to Yale.
    }
    if playerSparedDarla then
        addPOI(getParentValue("safehouseMarker"))
    else
        addPOI(yale)
    end
end

function ReturnToYaleCheck()
    return fact.AboutDarla_ReturnedToYale or recievedYaleNote
end

function ReturnToYaleDone()
end

--[[------------------------------------------------------------------------------
A WARM REUNION REDUX
--------------------------------------------------------------------------------]]
_id = "WARM_REUNION_REDUX"
_mission = "WarmReunionRedux"
_priority = 100

persist{}
yalePlacement = nil

persist{}
yale = nil

persist{}
yaleRacket = nil

persist{}
locationLockId = nil

function onMissionCreate()
    defineMission
    {
        name = "$WarmReunionRedux_name", --$ A Warm Reunion Redux
        description = "$WarmReunionRedux_desc" --$  Go confront Yale.
    }
    yale = ActorUtils:getActorFromLabel("FrankieYale")
    yaleRacket = WorldUtils:getLocationFromId(yalePlacement.locationId).building
    if yale.missionPatron then
        yale.missionPatron:addPatronGoal()
    end
end

function onMissionStart()
    addObjective("ReturnToYale")
end

function onMissionSuccess()
    if fact.WarmReunionRedux_SparedYale then
        yale.brain:addGoal("LeaveLocationAndDelete", 1002, {run = false})
    else
        addCashReward(50000)
        addItemsReward("ITEM.WEAPON.UNIQUE_MISSION_MACHINEGUN_15",1)
    end
end

function onMissionFail()
    if yale then
        yale:delete()
    end

    if yalePlacement then
        yalePlacement:release()
    end

    if locationLockId then
        WorldUtils:removeLocationLock(locationLockId)
    end
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    local placement = e.placement
    if placement == yalePlacement then
        if e.reason == "Upgrade" then
            yalePlacement = WorldUtils:acquirePlacement({
                locationId = yaleRacket.interiorLocationId,
                buildingType = "Racket",
                featureType = "MissionArea"
            })
        else
            yalePlacement = WorldUtils:acquirePlacement(
                MissionUtils:barOrDrinkingRacketOwnedByPlayer()
            )
            if not yalePlacement then
                failMission("$MissionFailLostBuilding")
            else
                yale = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_FRANKIE_YALE", yalePlacement, yale.iid)
            end
        end
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function ReturnToYale()
    defineObjective
    {
        description = "$WarmReunionRedux_GoToYale", --$ Talk to Yale.
    }
    addPOI(yale)
end

function ReturnToYaleCheck()
    return fact.WarmReunionRedux_SparedYale or yale:isDead()
end

function ReturnToYaleDone()
    if locationLockId then
        WorldUtils:removeLocationLock(locationLockId)
    end
end

--[[------------------------------------------------------------------------------
                        SCENARIOS
--------------------------------------------------------------------------------]]
-- ---------------------------------
-- Leaving Building - Warm Reunion
-- ---------------------------------
_namespace = "SCENARIOS"
_id = "LEAVE_BUILDING"
_name = "LeaveBuilding"

function onStart(actor, locationId)
    EnableScenarioLayer()
    step(LeaveBuilding, actor)
    addWaitUntil(CheckLeftBuilding, actor, locationId).timeout(10)
    step(ToggleBool, actor)
    step(DisableScenarioLayer)
end

function EnableScenarioLayer()
    clientServices.transition:enableLayer("ScenarioLayer")
end

function DisableScenarioLayer()
    clientServices.transition:disableLayer("ScenarioLayer")
end


function LeaveBuilding(actor)
    actor.brain:addGoal("LeaveLocation", 1000, {run = true})
end

function CheckLeftBuilding(actor, locationId)
    return actor:getLocationId() ~= locationId
end

function ToggleBool(actor)
    actor.brain:removeGoals("LeaveLocation", 1000)
    fact.WarmReunion_LeftBuilding = true
end

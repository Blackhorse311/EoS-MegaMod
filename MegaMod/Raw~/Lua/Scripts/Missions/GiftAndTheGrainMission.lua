-- ----------------
-- NPC Configs
-- ----------------
_namespace = "NPC"
--We need to set up a new config for charly so that she can combat
_id = "MISSION_CHARLY_COMBAT"
_includes =
{
    "BASE_MISSION_FEMALE_NON_COMBAT",
}
name = "$Charly_name"
characterIcon = "Sprites/Images/Characters/Profile/Extras/RacketWorker_Female_02_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/RacketWorker_Female_02"
prefab = "Models/Characters/Extras/MissionNPCs/Prefabs/MissionNPC_RacketWorker_Female_01"
ragdollPrefab = "Models/Characters/Extras/RacketWorkers/Prefabs/RacketWorker_Female_02_Ragdoll"

-- ----------------
-- EVENTS
-- ----------------
_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
GIFT AND THE GRAIN
--------------------------------------------------------------------------------]]
_id = "GIFT_AND_THE_GRAIN"
_event = "GiftAndTheGrain"
_gameStage = "Bridging" --Changing the mission to trigger from the beginning of the game
_autoStartMode = "Schedule"
_category = "EmpireMission"
_triggerDelay = 20 -- Changing the time between when it checks canTrigger

breweryPlacement = nil
barPlacement = nil
charlyPlacement = nil
function canTrigger()
    if MissionUtils:isAtMaxMissions() then
        return false
    end

    if WorldUtils:isMissionActive("TwoBrew") then
        return false
    end

    charlyPlacement = WorldUtils:acquirePlacement(
        MissionUtils:alleyPlacementRules()
    )
    if not charlyPlacement then
        return false
    end

    breweryPlacement = WorldUtils:acquirePlacement(
        MissionUtils:racketOwnedByPlayer("Brewery")
    )
    if not breweryPlacement then
        charlyPlacement:release()
        return false
    end

    barPlacement = WorldUtils:acquirePlacement(
        MissionUtils:barOrDrinkingRacketOwnedByPlayer()
    )
    if not barPlacement then
        breweryPlacement:release()
        charlyPlacement:release()
        return false
    end

    return true
end

function onTrigger()
    local brewery = WorldUtils:getBuildingFromPlacement(breweryPlacement)
    local wardName = brewery:getLocation().name
    title("$GiftAndTheGrain_name")
    text({"$GiftAndTheGrain_text", brewery.name, wardName}) --$ A message from Henry at {0} in {1}: "Boss, we just checked the inventory. Looks like someone's been stealing our grain. We're down a few sacks. It's probably best you come down here."
    option("$GiftAndTheGrain_o1", startMission) --$ I'll be right there.
end

function startMission()
    WorldUtils:startMission(_event, "charlyPlacement", charlyPlacement, "breweryPlacement", breweryPlacement, "barPlacement", barPlacement)
end

-- ----------------
-- MISSION
-- ----------------
_namespace = "MISSIONS"
--[[------------------------------------------------------------------------------
GIFT AND THE GRAIN
--------------------------------------------------------------------------------]]
_id = "GIFT_AND_THE_GRAIN"
_mission = "GiftAndTheGrain"

persist{}
breweryWorker = nil

persist{}
charly = nil

persist{}
contractor = nil

persist{}
brewery = nil

persist{}
breweryPlacement = nil

persist{}
bar = nil

persist{}
barPlacement = nil

persist{}
charlyPlacement = nil

persist{}
killedContractor = nil

persist{}
attackedCharly = nil

function onMissionCreate()
    brewery = WorldUtils:getBuildingFromPlacement(breweryPlacement)
    bar = WorldUtils:getBuildingFromPlacement(barPlacement)

    local wardName = brewery:getLocation().name
    defineMission
    {
        name = "$GiftAndTheGrain_name", --$ The Gift And The Grain
        description = {"$GiftAndTheGrain_desc", brewery.name, wardName}, --$ Goods have gone missing from {0} in {1}. You better go check it out.
    }

    breweryWorker = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_HENRY", breweryPlacement)
    breweryWorker:setFaction(WorldUtils:getPlayerFaction())
    MissionUtils:setEntryPoint(breweryWorker, "TheGiftAndTheGrain1_Start")
end

function onMissionStart()
    addObjective("TalkToBreweryWorker")
end

function onMissionSuccess()
    WorldUtils:unlockImprovementSlotForWorld("IMPROVEMENT_SLOTS.MALTING")
    Utils:showGameAlert("IMPROVEMENT_UNLOCKED", "$IMPROVEMENT_SLOTS_MALTING_name")

    charly.brain:addGoal("LeaveLocationAndDelete", 1001)

    --Adding custom reward for choosing to attack Charly
    if fact.GiftAndTheGrain_AttackedCharly then
        addTraitReward("Cruel")
    end

    -- MEGAMOD: nil-guard; the self-heal leaves this nil when no alley was available
    if charlyPlacement then
        charlyPlacement:release()
    end
    if barPlacement then
        barPlacement:release()
    end
end

function onMissionFail()
    if breweryPlacement then
        breweryPlacement:release()
    end
    if barPlacement then
        barPlacement:release()
    end
    if charlyPlacement then
        charlyPlacement:release()
    end

    if breweryWorker then
        breweryWorker:delete()
    end
    if charly then
        charly:delete()
    end
    if contractor then
        contractor:delete()
    end
end

-- --------------------------
-- Game Events
-- --------------------------
function GameEvent.onPlacementInvalidated(e)
    if e.placement == breweryPlacement then
        if e.reason == "Upgrade" then
            breweryPlacement = WorldUtils:acquirePlacement({
                factionId = "Player",
                featureType = "MissionArea",
                locationId = brewery.interiorLocationId
            })
        else
            breweryPlacement = WorldUtils:acquirePlacement(
                MissionUtils:racketOwnedByPlayer("Brewery")
            )
            if not breweryPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            brewery = WorldUtils:getBuildingFromPlacement(breweryPlacement)
            local wardName = brewery:getLocation().name
            setDescription({"$GiftAndTheGrain_desc", brewery.name, wardName})

            if breweryWorker then
                ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_HENRY", breweryPlacement, breweryWorker.iid)
            end
        end
    elseif e.placement == barPlacement then
        if e.reason == "Upgrade" then
            barPlacement = WorldUtils:acquirePlacement({
                factionId = "Player",
                featureType = "MissionArea",
                locationId = bar.interiorLocationId
            })
        else
            barPlacement = WorldUtils:acquirePlacement(
                MissionUtils:barOrDrinkingRacketOwnedByPlayer()
            )
            if not barPlacement then
                failMission("$MissionFailLostBuilding")
                return
            end
            bar = WorldUtils:getBuildingFromPlacement(barPlacement)

            if charly then
                charly.memory.GiftAndTheGrain_Bar = bar
            end

            if contractor then
                ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_NON_COMBAT_08", barPlacement, contractor.iid)
                local wardName = bar:getLocation().name
                setDescription({"$GiftAndTheGrainHelpCharly_desc", bar.name, wardName})
            end
        end
    elseif e.placement == charlyPlacement then
        -- MEGAMOD: vanilla only guards the brewery/bar placements. When a ward
        -- flip invalidates the alley placement, the pooled object is cleared and
        -- recycled while the mission still holds the ref; Charly then spawns into
        -- location 0 (limbo, no map marker). Re-acquire immediately; if no alley
        -- is available right now, the TalkToCharlyCheck self-heal keeps retrying.
        charlyPlacement = WorldUtils:acquirePlacement(
            MissionUtils:alleyPlacementRules()
        )
        if charlyPlacement and charly then
            ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_CHARLY_COMBAT", charlyPlacement, charly.iid)
        end
    end
end

function GameEvent.onCombatResolvedAndCleanedUp(e)
    if contractor and contractor:isDead() then
        killedContractor = true
    end
end

function GameEvent.onCombatResolved()
    if charly and charly:hasState("Unconscious") then
        attackedCharly = true
    end
end

-- --------------------------
-- Objectives
-- --------------------------
function TalkToBreweryWorker()
    defineObjective
    {
        description = {"$ObjectiveTitle_TalkToCharacter", breweryWorker.name}
    }
    addPOI(breweryWorker)
end

function TalkToBreweryWorkerCheck()
    return fact.GiftAndTheGrain_TalkedToBreweryWorker
end

function TalkToBreweryWorkerDone()
    if breweryPlacement then
        breweryPlacement:release()
        breweryPlacement = nil
    end
    MissionUtils:returnActorToWork(breweryWorker, "BREWERY")
    breweryWorker = nil

    addObjective("TalkToCharly")
end

function TalkToCharly()
    defineObjective
    {
        description = "$GiftAndTheGrain_TalkToCharly" --$ Hire Charly to work for you.
    }
    setDescription("$GiftAndTheGrainFindCharly_desc") --$ Get over to the garage that Charly Flint operates from and see if she's there.

    -- MEGAMOD: the alley placement can die between mission start and this
    -- objective (invalidation clears pooled placements; see onPlacementInvalidated)
    if not (charlyPlacement and charlyPlacement.placementType) then
        charlyPlacement = WorldUtils:acquirePlacement(
            MissionUtils:alleyPlacementRules()
        )
    end
    if charlyPlacement then
        charly = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_CHARLY_COMBAT", charlyPlacement) --Changing the npc config Charly is using to the new one we made which will allow her to combat
        charly.memory.GiftAndTheGrain_Bar = bar
        MissionUtils:setEntryPoint(charly, "TheGiftAndTheGrain2_Start")
        addPOI(charly)
    end
end

function TalkToCharlyCheck()
    -- MEGAMOD self-heal, polled while this objective is active: if the alley
    -- placement ref is dead or Charly is stranded in the void (location 0), grab
    -- a fresh alley and (re)place her there. Also rescues saves broken before
    -- this fix existed. The old ref is deliberately NOT released -- the pool may
    -- already have recycled it to another owner.
    local placementDead = not (charlyPlacement and charlyPlacement.placementType)
    local charlyLost = charly and not charly:getLocation()
    if placementDead or charlyLost then
        charlyPlacement = WorldUtils:acquirePlacement(
            MissionUtils:alleyPlacementRules()
        )
        if charlyPlacement then
            if charly then
                ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_CHARLY_COMBAT", charlyPlacement, charly.iid)
            else
                charly = ActorUtils:placeActorAtPlacement("NPC", "NPC.MISSION_CHARLY_COMBAT", charlyPlacement)
                charly.memory.GiftAndTheGrain_Bar = bar
                MissionUtils:setEntryPoint(charly, "TheGiftAndTheGrain2_Start")
                addPOI(charly)
            end
        end
    end
    return fact.GiftAndTheGrain_TalkedToCharly or attackedCharly
end

function TalkToCharlyDone()
    if attackedCharly then
        MissionUtils:makeNPCNonCombat(charly) --Making Charly not attackable again
        charly:removeState("PlotArmor") --Removing her invincibility
        charly:removeState("GuardIfFlee") --Removing her GuardIfFlee so she doesn't attack the player

        addObjective("ReturnToCharly") --Speak with her again
    elseif fact.GiftAndTheGrain_TalkedToCharly == 1 then
        contractor = ActorUtils:placeActorAtPlacement("NPC", "NPC.BASE_MISSION_MALE_NON_COMBAT_08", barPlacement)
        contractor.name = "$Contractor_name" --$ Contractor
        -- MEGAMOD: guard the placement ref; fall back to Charly's live location
        local charlyLocation
        if charlyPlacement and charlyPlacement.locationId and charlyPlacement.locationId ~= 0 then
            charlyLocation = WorldUtils:getLocationFromId(charlyPlacement.locationId)
        end
        if not charlyLocation and charly then
            charlyLocation = charly:getLocation()
        end
        contractor.memory.GiftAndTheGrain_CharlyLocationName = charlyLocation and charlyLocation.name or ""
        MissionUtils:setEntryPoint(contractor, "TheGiftAndTheGrain3_Start")
        contractor:addState("GuardIfFlee")
        addObjective("TalkToContractor")
    end
end

function TalkToContractor()
    defineObjective
    {
        description = {"$ObjectiveTitle_TalkToCharacter", contractor.name}
    }
    local wardName = bar:getLocation().name
    setDescription({"$GiftAndTheGrainHelpCharly_desc", bar.name, wardName}) --$ Go to {0} in {1} to meet the contractor.
    addPOI(contractor)
end

function TalkToContractorCheck()
    return fact.GiftAndTheGrain_TalkedToContractor or killedContractor
end

function TalkToContractorDone()
    if fact.GiftAndTheGrain_TalkedToContractor then
        contractor.brain:addGoal("leaveLocationAndDelete", 1001)
    end
    contractor = nil

    if barPlacement then
        barPlacement:release()
        barPlacement = nil
    end

    addObjective("ReturnToCharly")
end

function ReturnToCharly()
    defineObjective
    {
        description = {"$ObjectiveTitle_ReturnToCharacter", charly.name}
    }
    setDescription("$GiftAndTheGrainHelpedCharly_desc") --$ Now that the contractor has been taken care of, it's time to tell Charly the good news.
    MissionUtils:setEntryPoint(charly, "TheGiftAndTheGrain4_Start")
    addPOI(charly)
end

function ReturnToCharlyCheck()
    return fact.GiftAndTheGrain_ReturnedToCharly
end

function ReturnToCharlyDone()
end

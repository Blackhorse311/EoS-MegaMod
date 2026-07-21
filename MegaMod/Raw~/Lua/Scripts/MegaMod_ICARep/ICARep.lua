--[[------------------------------------------------------------------------------
    MegaMod: ICA Contact (Mr. Smith)
    A mysterious operative from a global assassination conglomerate who pays
    $20,000 for killing specific targets across the city.
    No bosses, no questions asked.
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    NPC Definition
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_ICAREP"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_01_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_01_Profile"
prefab = "Models/Characters/Extras/MissionNPCs/Prefabs/MissionNPC_Bartender_Male_01"
ragdollPrefab = "Models/Characters/Extras/Bartenders/Prefabs/Bartender_Male_01_Ragdoll"

name = "$MEGAMOD_BANK_fullname" --$ Mr. Smith
firstName = "$MEGAMOD_BANK_firstname" --$ Mr.
lastName = "$MEGAMOD_BANK_lastname" --$ Smith
profession = "NoProfession"
commands =
{
    Talk = true,
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    WORLD_EVENTS: Spawn + daily monitor for mission creation
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_ICAREP_SPAWN"
_event = "MegaModICARepSpawn"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 15
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    -- MEGAMOD FIX: was a persist var; only used inside this function, so a plain local suffices
    local icaRepActor = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_ICAREP")
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    safehouse:enter(icaRepActor, "IDLE", true)
    icaRepActor.behaviours:add("MegaModICARepBehaviour")

    title("$MEGAMOD_BANK_arrive_title") --$ A Visitor From Abroad
    text("$MEGAMOD_BANK_arrive_text") --$ A sharply dressed man with a foreign accent and an air of quiet authority has appeared in your safehouse. He introduces himself only as "Mr. Smith" and says he has work for you. Lucrative work. Talk to him when you're ready.
    option("$MEGAMOD_BANK_arrive_option") --$ Interesting.
    -- MEGAMOD FIX: no complete() here - this event shows UI; auto-complete handles it
end

-- Note: Mission creation is handled in BEHAVIOURS GameEvent.onDayBegin;
-- cancellation of a running mission is handled by the MISSIONS script itself.

--[[------------------------------------------------------------------------------
    CONVERSATIONS: Full contract flow handled in conversation.
    Target info shown as individual localization-key options on one screen.
    Mission created via flag picked up by BEHAVIOURS onDayBegin.
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_ICAREP_CONVERSATION"
EntryPoint = "MegaMod_ICARep_Start"

local askedWhoAreYou = false
local askedWhyMe = false
local askedWhyContract = false
local askedWhyMoney = false

-- Contract state
local currentTarget = nil
local targetName = nil
local targetNeighborhood = nil
local targetPrecinct = nil
local targetFaction = nil
local targetType = nil
local contractActive = false

-- MEGAMOD FIX: single place that wipes contract state so accept/payout/fail/cancel
-- all leave the same clean slate (icaCancelContract handled separately by callers)
function ClearContractState()
    -- MEGAMOD ICA ACCESS: undo the building access grant on every contract end path.
    -- The building object itself is stored in memory (vanilla pattern, cf.
    -- stranger.memory.ChicagoPolitics_Derelict in MidGameEventMission).
    local accessBuilding = them.memory.icaAccessBuilding
    if accessBuilding and not accessBuilding.isDeleted then
        WorldUtils:removeImportantForMissionBuilding(accessBuilding)
    end
    -- Restore the target's original faction only if the contract ended with them
    -- alive AND they are still under our THUGS cover (a fulfilled contract leaves a
    -- corpse; a target hired by the player must not be ripped out of the crew)
    local accessTarget = them.memory.icaActiveTarget
    local origFactionId = them.memory.icaTargetOrigFactionId
    if accessTarget and origFactionId and not accessTarget.isDeleted
        and not accessTarget:isDead()
        and accessTarget.faction and accessTarget.faction.isThugFaction then
        local origFaction = WorldUtils:getFactionById(origFactionId)
        if origFaction then
            accessTarget:setFaction(origFaction)
        end
    end
    -- Disband any bodyguards the ICA hired for the target
    local guards = them.memory.icaGuardSquad
    if guards then
        guards:removeFromSquads()
    end
    them.memory.icaAccessBuilding = nil
    them.memory.icaTargetOrigFactionId = nil
    them.memory.icaGuardSquad = nil
    them.memory.icaSpawnGuards = nil
    them.memory.icaFearKills = nil

    contractActive = false
    currentTarget = nil
    targetName = nil
    targetNeighborhood = nil
    targetPrecinct = nil
    targetFaction = nil
    targetType = nil
    them.memory.icaContractActive = nil
    them.memory.icaActiveTarget = nil
    them.memory.icaActiveTargetName = nil
    them.memory.icaActiveTargetHood = nil
    them.memory.icaActiveTargetPrecinct = nil
    them.memory.icaActiveTargetFaction = nil
    them.memory.icaActiveTargetType = nil
    them.memory.icaPendingMission = nil
end

function onStart()
    -- MEGAMOD FIX: ad-hoc actor fields are not saved; actor memory survives save/load
    askedWhoAreYou = them.memory.icaAskedWho or false
    askedWhyMe = them.memory.icaAskedWhyMe or false
    askedWhyContract = them.memory.icaAskedWhyContract or false
    askedWhyMoney = them.memory.icaAskedWhyMoney or false

    -- Sync contract state from actor memory (persists across conversations and save/load)
    if them.memory.icaContractActive then
        contractActive = true
        currentTarget = them.memory.icaActiveTarget
        targetName = them.memory.icaActiveTargetName
        targetNeighborhood = them.memory.icaActiveTargetHood
        targetPrecinct = them.memory.icaActiveTargetPrecinct
        targetFaction = them.memory.icaActiveTargetFaction
        targetType = them.memory.icaActiveTargetType
    end

    -- Contract completed: payout
    if them.memory.icaContractCompleted then
        them.memory.icaContractCompleted = nil
        go(PayOut)
        return
    end

    -- MEGAMOD FIX: target actor no longer exists - void the contract cleanly
    if contractActive and not currentTarget then
        if not them.memory.icaPendingMission then
            them.memory.icaCancelContract = true -- tell the running mission to fail itself
        end
        ClearContractState()
    end

    -- Active contract: check target status
    if contractActive and currentTarget then
        if currentTarget:isDead() then
            go(PayOut)
            return
        end
        if currentTarget.faction and currentTarget.faction.isPlayerFaction then
            go(TargetJoinedPlayer)
            return
        end
        go(StatusCheck)
        return
    end

    -- No active contract: intro questions then offer
    if not askedWhoAreYou or not askedWhyMe or not askedWhyContract or not askedWhyMoney then
        go(Introductions)
        return
    end

    go(OfferTarget)
end

function Introductions()
    say("$MEGAMOD_BANK_intro_greeting") --$ Welcome, my friend. Before we discuss business, is there anything you would like to know?
    if not askedWhoAreYou then
        option("$MEGAMOD_BANK_who_are_you", WhoAreYou) --$ Who are you, exactly?
    end
    if not askedWhyMe then
        option("$MEGAMOD_BANK_why_me", WhyMe) --$ Why me?
    end
    if not askedWhyContract then
        option("$MEGAMOD_BANK_ask_why", AskWhyContract) --$ How does this work?
    end
    if not askedWhyMoney then
        option("$MEGAMOD_BANK_ask_money", AskWhyMoney) --$ Why twenty grand?
    end
    option("$MEGAMOD_BANK_skip_intro", OfferTarget) --$ Let's get down to business
end

function WhoAreYou()
    askedWhoAreYou = true
    them.memory.icaAskedWho = true
    say("$MEGAMOD_BANK_who_answer") --$ I am a representative of a...global conglomerate. We extend our services to wealthy and influential clients around the world. It just so happens that our agent in Chicago was...taken out of our portfolio recently. And we...and by "we" I mean the ICA, have decided to back YOU my friend. We believe you can help us. And by helping us, you help yourself. You may address me as "Mr. Smith."
    option("$MEGAMOD_BANK_continue", AfterQuestion) --$ Go on...
end

function WhyMe()
    askedWhyMe = true
    them.memory.icaAskedWhyMe = true
    say("$MEGAMOD_BANK_whyme_answer") --$ Because we have seen your ability to kill my friend, and killing is our business...and business is good.
    option("$MEGAMOD_BANK_continue", AfterQuestion) --$ Go on...
end

function AskWhyContract()
    askedWhyContract = true
    them.memory.icaAskedWhyContract = true
    say("$MEGAMOD_BANK_contract_answer") --$ Oh no, my friend, this is strictly a no questions asked business. I don't even know who wants this person dead, or why, and it doesn't matter one bit. I get paid to hire you to do the job, and we both get paid when the job is complete.
    option("$MEGAMOD_BANK_continue", AfterQuestion) --$ Go on...
end

function AskWhyMoney()
    askedWhyMoney = true
    them.memory.icaAskedWhyMoney = true
    say("$MEGAMOD_BANK_money_answer") --$ We pay twenty because we can, and because we expect results that are worth twenty. You'll notice we're not haggling, we're not explaining ourselves, and we're certainly not repeating this conversation. The money answers your question better than I ever could -- now, do we have a deal or don't we?
    option("$MEGAMOD_BANK_continue", AfterQuestion) --$ Go on...
end

function AfterQuestion()
    if not askedWhoAreYou or not askedWhyMe or not askedWhyContract or not askedWhyMoney then
        go(Introductions)
        return
    end
    go(OfferTarget)
end

function OfferTarget()
    local targets = them.icaRepTargets
    if not targets or #targets == 0 then
        say("$MEGAMOD_BANK_no_targets") --$ I have nothing for you at the moment, my friend. The city is...quieter than we would like. Check back later.
        option("$MEGAMOD_BANK_leave_notargets", Leave) --$ I'll check back
        return
    end

    -- Prefer gangster targets (70% chance) when available
    local gangsters = them.icaRepGangsters
    local pool = targets
    if gangsters and #gangsters > 0 and math.random() < 0.7 then
        pool = gangsters
    end
    local entry = pool[math.random(#pool)]
    currentTarget = entry.actor
    targetName = entry.name
    targetNeighborhood = entry.neighborhood
    targetPrecinct = entry.precinct
    targetFaction = entry.faction
    targetType = entry.targetType

    say("$MEGAMOD_BANK_offer") --$ I have a contract for you, my friend. Twenty thousand dollars when the job is complete.
    option(targetName, ShowTargetDetails)
    option("$MEGAMOD_BANK_reroll", RerollTarget) --$ Got anyone else?
    option("$MEGAMOD_BANK_decline", Leave) --$ Not interested
end

function ShowTargetDetails()
    say("$MEGAMOD_BANK_where_intro") --$ Our sources have tracked the target. Here is what we know:
    if targetType then
        option(targetType, AcceptScreen)
    end
    if targetNeighborhood then
        option(targetNeighborhood, AcceptScreen)
    end
    if targetPrecinct then
        option(targetPrecinct, AcceptScreen)
    end
    if targetFaction then
        option(targetFaction, AcceptScreen)
    end
    option("$MEGAMOD_BANK_accept_after_where", AcceptContract) --$ I'll take the job
    option("$MEGAMOD_BANK_reroll", RerollTarget) --$ Got anyone else?
    option("$MEGAMOD_BANK_decline", Leave) --$ Not interested
end

function AcceptScreen()
    go(AcceptContract)
end

function AcceptContract()
    -- MEGAMOD FIX: refuse contracts on targets that died since the daily list was built
    if not currentTarget or currentTarget:isDead() then
        go(TargetAlreadyDead)
        return
    end

    contractActive = true

    -- Store in actor memory so it survives save/load and the mission monitor can read it
    them.memory.icaContractActive = true
    them.memory.icaActiveTarget = currentTarget
    them.memory.icaActiveTargetName = targetName
    them.memory.icaActiveTargetHood = targetNeighborhood
    them.memory.icaActiveTargetPrecinct = targetPrecinct
    them.memory.icaActiveTargetFaction = targetFaction
    them.memory.icaActiveTargetType = targetType
    them.memory.icaPendingMission = true
    them.memory.icaCancelContract = nil -- MEGAMOD FIX: never carry a stale cancel into a new contract

    -- MEGAMOD ICA ACCESS: if the target is holed up inside a rival-owned building,
    -- the ICA burns their cover. The ImportantForMissionBuilding tag lets the player
    -- walk in war-free (BUILDING_ENTER checks it before ownership/war checks), and
    -- flipping the target to FACTION.THUGS means killing them triggers no faction
    -- war. Rival safehouses/depots stay off-limits: the isSafehouseOrDepot branch of
    -- BUILDING_ENTER.isVisible() takes precedence over the tag, so the daily street
    -- teleport keeps handling those targets instead.
    local targetLoc = WorldUtils:getLocationFromId(currentTarget:getLocationId())
    if targetLoc and targetLoc.isInterior and targetLoc.building then
        local building = targetLoc.building
        local owner = building.faction
        if owner and not owner.isPlayerFaction and not building.isSafehouseOrDepot then
            them.memory.icaAccessBuilding = building
            them.memory.icaTargetOrigFactionId = currentTarget.faction and currentTarget.faction.factionId
            WorldUtils:addImportantForMissionBuilding(building)
            local thugFaction = WorldUtils:getFactionById("FACTION.THUGS")
            if thugFaction then
                currentTarget:setFaction(thugFaction)
            end
            -- Bodyguards are spawned by the behaviour on day begin (squad utils are
            -- verified in behaviour context; the mission starts on day begin anyway)
            them.memory.icaSpawnGuards = true
        end
    end

    say("$MEGAMOD_BANK_accepted") --$ Excellent. Make it clean. Come back to me when it's done and I'll have your twenty thousand waiting.
    option("$MEGAMOD_BANK_leave_accepted", Leave) --$ Consider it done
end

function TargetAlreadyDead()
    say("$MEGAMOD_BANK_target_dead") --$ One moment, my friend...my sources report the target is already deceased. Someone beat you to it. No work, no payment. Allow me to find another name.
    option("$MEGAMOD_BANK_new_target", OfferTarget) --$ Give me a new target
    option("$MEGAMOD_BANK_leave_hired", Leave) --$ Maybe later
end

function RerollTarget()
    local targets = them.icaRepTargets
    if not targets or #targets == 0 then
        say("$MEGAMOD_BANK_no_targets") --$ I have nothing for you at the moment, my friend. The city is...quieter than we would like. Check back later.
        option("$MEGAMOD_BANK_leave_notargets", Leave) --$ I'll check back
        return
    end

    local entry = targets[math.random(#targets)]
    local attempts = 0
    while entry.actor == currentTarget and attempts < 5 and #targets > 1 do
        entry = targets[math.random(#targets)]
        attempts = attempts + 1
    end

    currentTarget = entry.actor
    targetName = entry.name
    targetNeighborhood = entry.neighborhood
    targetPrecinct = entry.precinct
    targetFaction = entry.faction
    targetType = entry.targetType

    say("$MEGAMOD_BANK_reroll_offer") --$ How about this one? Same terms. Twenty thousand when they are no longer breathing.
    option(targetName, ShowTargetDetails)
    option("$MEGAMOD_BANK_reroll", RerollTarget) --$ Got anyone else?
    option("$MEGAMOD_BANK_decline", Leave) --$ Not interested
end

function StatusCheck()
    say("$MEGAMOD_BANK_still_alive") --$ The target is still breathing. Get it done and come see me.
    option("$MEGAMOD_BANK_where_active", ShowActiveTarget) --$ Where is the target?
    option("$MEGAMOD_BANK_howto_flush", ExplainFlush) --$ The target's holed up somewhere I can't get into.
    option("$MEGAMOD_BANK_cancel", CancelContract) --$ I want to cancel the contract
    option("$MEGAMOD_BANK_leave_status", Leave) --$ I'm working on it
end

-- MEGAMOD ICA FLUSH: Mr. Smith explains the fear mechanic (the count he quotes
-- must match ICA_FEAR_KILLS_TO_FLUSH in the behaviour below)
function ExplainFlush()
    say("$MEGAMOD_BANK_flush_answer") --$ Ah, a man gone to ground. We see this often, my friend, and our field manual is very clear on the subject: a man in hiding does not watch the streets. He listens to them. The muscle that guards men like him -- the thugs, the rented guns, the two-dollar toughs on every corner -- they are his ears, and they talk. Put four of them in the ground, loudly, anywhere in this city, and I promise you his nerve will not survive the arithmetic. He will bolt for open air like a rat from a burning wall. And a man in the open, my friend...well. That is where you come in.
    option("$MEGAMOD_BANK_flush_got_it", BackToStatus) --$ Loud. I can do loud.
end

function ShowActiveTarget()
    say("$MEGAMOD_BANK_where_intro") --$ Our sources have tracked the target. Here is what we know:
    if targetType then
        option(targetType, BackToStatus)
    end
    if targetNeighborhood then
        option(targetNeighborhood, BackToStatus)
    end
    if targetPrecinct then
        option(targetPrecinct, BackToStatus)
    end
    if targetFaction then
        option(targetFaction, BackToStatus)
    end
    option("$MEGAMOD_BANK_leave_status", Leave) --$ I'm working on it
end

function BackToStatus()
    go(StatusCheck)
end

function CancelContract()
    -- MEGAMOD FIX: if the mission was already created, flag it to fail itself
    -- (a still-pending mission is cancelled by simply clearing icaPendingMission below)
    if not them.memory.icaPendingMission then
        them.memory.icaCancelContract = true
    end
    ClearContractState()
    say("$MEGAMOD_BANK_cancelled") --$ Your call. But the money would have been good. Come back if you change your mind.
    option("$MEGAMOD_BANK_new_after_cancel", OfferTarget) --$ Actually, give me a new target
    option("$MEGAMOD_BANK_leave_cancel", Leave) --$ I'll think about it
end

function PayOut()
    -- MEGAMOD FIX: this is the ONLY $20k grant (the mission's cash reward is display-only)
    BRScript:PlayerAddCash(20000, "CASH.MISSION_REWARD")
    them.memory.icaContractCompleted = nil
    ClearContractState()
    say("$MEGAMOD_BANK_payout") --$ Well done, my friend. The target is no longer a concern. Here is your twenty thousand. I may have another contract for you, if you are interested.
    option("$MEGAMOD_BANK_another", OfferTarget) --$ I could go again
    option("$MEGAMOD_BANK_leave_paid", Leave) --$ Pleasure doing business
end

function TargetJoinedPlayer()
    -- MEGAMOD FIX: void the contract; fail the running mission if one was created
    if not them.memory.icaPendingMission then
        them.memory.icaCancelContract = true
    end
    ClearContractState()
    say("$MEGAMOD_BANK_target_hired") --$ It appears the target is now in your employ. We cannot have you eliminating your own people. The contract is void. Allow me to find another name.
    option("$MEGAMOD_BANK_new_target", OfferTarget) --$ Give me a new target
    option("$MEGAMOD_BANK_leave_hired", Leave) --$ Maybe later
end

function Leave()
    say("$MEGAMOD_BANK_goodbye") --$ You know where to find me, my friend.
    endConversation()
end

--[[------------------------------------------------------------------------------
    BEHAVIOURS: Sets conversation entry point and builds target list
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_ICAREP_BEHAVIOUR"
_name = "MegaModICARepBehaviour"

-- MEGAMOD FIX: helpers must be plain GLOBAL functions declared before first use.
-- As `local function`s they had no sandbox env (WorldUtils was nil inside them), and
-- ensureTargetAccessible was declared AFTER its caller, so the call site saw nil and
-- contract missions never started.
-- True while the target sits inside a building owned by a non-player faction
-- (loc.building / building.faction are the same reads AcceptContract uses)
function icaTargetIsHiddenFromPlayer(target)
    local loc = WorldUtils:getLocationFromId(target:getLocationId())
    if not loc or not loc.isInterior or not loc.building then return false end
    local owner = loc.building.faction
    return owner ~= nil and not owner.isPlayerFaction
end

-- Teleport the target from inside a building to that building's neighborhood
-- exterior. Returns true if they were moved.
-- MEGAMOD FIX: match hood buildings by object identity OR interiorLocationId.
-- The old scan compared building.locationId against the target's INTERIOR
-- location id -- vanilla keeps the interior id in building.interiorLocationId
-- (Faction.lua), so the match could silently never fire and hidden targets
-- stayed hidden forever.
function icaFlushTargetToStreet(target)
    if not target or target:isDead() then return false end
    local targetLocId = target:getLocationId()
    if not targetLocId then return false end
    local loc = WorldUtils:getLocationFromId(targetLocId)
    if not loc or not loc.isInterior or not loc.building then return false end

    local neighborhoods = WorldUtils:getExteriorLocations()
    if not neighborhoods then return false end
    for i = 1, #neighborhoods do
        local hood = neighborhoods[i]
        if hood.buildings then
            for j = 1, #hood.buildings do
                local building = hood.buildings[j]
                if building == loc.building or building.interiorLocationId == targetLocId then
                    target:setLocationId(hood.id)
                    return true
                end
            end
        end
    end
    return false
end

-- Move a target to the street if they're in a rival-owned building the player
-- can't enter. Teleports them to the exterior of their current neighborhood.
function ensureTargetAccessible(target)
    if not target or target:isDead() then return end
    if not icaTargetIsHiddenFromPlayer(target) then return end
    icaFlushTargetToStreet(target)
end

function getPrecinctKey(member) -- MEGAMOD FIX: global (was local function, see above)
    local precinctObj = member.getPrecinct and member:getPrecinct()
    if precinctObj and precinctObj.name then
        return precinctObj.name
    end
    return nil
end

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_ICARep_Start")
    refreshTargets()
end

function GameEvent.onDayBegin(e)
    refreshTargets()

    -- If there's an active contract, ensure the target is accessible
    -- MEGAMOD ICA ACCESS: skip targets with building access granted - they are
    -- reachable where they are; teleporting them would defeat the access grant.
    -- Safehouse/depot-dwellers and other inaccessible targets still get moved.
    if thisActor.memory.icaContractActive and thisActor.memory.icaActiveTarget
        and not thisActor.memory.icaAccessBuilding then
        ensureTargetAccessible(thisActor.memory.icaActiveTarget)
    end

    -- MEGAMOD ICA ACCESS: hire two thug bodyguards for a freshly covered target
    -- (war-free fight: FACTION.THUGS combat never triggers faction war)
    if thisActor.memory.icaSpawnGuards then
        thisActor.memory.icaSpawnGuards = nil
        local target = thisActor.memory.icaActiveTarget
        local building = thisActor.memory.icaAccessBuilding
        if target and not target.isDeleted and not target:isDead()
            and building and not building.isDeleted
            and target:getLocationId() == building.interiorLocationId then
            local guards = MissionUtils:spawnSquad(3, nil, nil, 2)
            if guards then
                MissionUtils:placeSquad(guards, target:getLocationId(), target:getPos())
                thisActor.memory.icaGuardSquad = guards
            end
        end
    end

    -- Create mission if contract was accepted in conversation
    if thisActor.memory.icaPendingMission then
        thisActor.memory.icaPendingMission = nil
        -- Move target outside before starting the mission
        -- MEGAMOD ICA ACCESS: unless building access was granted (see above)
        if thisActor.memory.icaActiveTarget and not thisActor.memory.icaAccessBuilding then
            ensureTargetAccessible(thisActor.memory.icaActiveTarget)
        end
        WorldUtils:startMission("MegaModICAContract",
            "targetActor", thisActor.memory.icaActiveTarget,
            "targetName", thisActor.memory.icaActiveTargetName or "$MEGAMOD_ICA_unknown",
            "targetHood", thisActor.memory.icaActiveTargetHood or "$MEGAMOD_ICA_unknown",
            "targetPrecinct", thisActor.memory.icaActiveTargetPrecinct or "$MEGAMOD_ICA_unknown",
            "targetFaction", thisActor.memory.icaActiveTargetFaction or "$MEGAMOD_ICA_unknown",
            "targetType", thisActor.memory.icaActiveTargetType or "$MEGAMOD_ICA_unknown",
            "icaRepActor", thisActor
        )
    end

    -- MEGAMOD FIX: cancellation of a running mission is handled by the mission script
    -- itself (EliminateTargetCheck watches icaCancelContract); a not-yet-created mission
    -- is cancelled in the conversation by clearing icaPendingMission.
end

-- MEGAMOD ICA FLUSH: while a contract target is holed up somewhere the player
-- can't enter, every street thug the PLAYER kills rattles them; at the
-- threshold the target loses their nerve and bolts to the open street.
-- (James 2026-07-20: needed an active way to smoke out inaccessible targets.)
-- Kill attribution via the Dead state's killerFaction (SalBonus pattern,
-- vanilla Health.lua DEAD onAdd). Counter lives in actor memory so it
-- survives save/load; cleared on every contract end path.
ICA_FEAR_KILLS_TO_FLUSH = 4 -- keep in sync with Mr. Smith's flush_answer dialog

function GameEvent.onCharacterDeath(e)
    local mem = thisActor.memory
    if not mem.icaContractActive then return end
    if mem.icaAccessBuilding then return end -- access granted; target already reachable
    local target = mem.icaActiveTarget
    if not target or target.isDeleted or target:isDead() then return end

    local dead = e.target
    if not dead or dead == target then return end
    if not (dead.faction and dead.faction.isThugFaction) then return end
    local deathInformation = dead:getState("Dead")
    local killerFaction = deathInformation and deathInformation.killerFaction
    if not killerFaction or not killerFaction.isPlayerFaction then return end

    if not icaTargetIsHiddenFromPlayer(target) then return end -- already in the open

    mem.icaFearKills = (mem.icaFearKills or 0) + 1
    if mem.icaFearKills < ICA_FEAR_KILLS_TO_FLUSH then return end
    mem.icaFearKills = nil

    if icaFlushTargetToStreet(target) then
        -- Short delay so the notice lands after the fight wraps up
        WorldUtils:scheduleWithDelay("MegaModICATargetFlushed", 10, "TICK",
            "flushedTargetName", mem.icaActiveTargetName)
    end
end

-- MEGAMOD ICA ACCESS: when the player's selected character walks into the
-- contracted building and the target is still inside, the target (and any
-- bodyguards in the room) turn hostile - politician's-son pattern, cf.
-- MidGameEventMission GameEvent.onEnterLocation / GuardIfFleeBehaviour
function GameEvent.onEnterLocation(e)
    local mem = thisActor.memory
    if not mem.icaContractActive then return end
    local building = mem.icaAccessBuilding
    if not building or building.isDeleted then return end
    local target = mem.icaActiveTarget
    if not target or target.isDeleted or target:isDead() then return end
    if e.locationId ~= building.interiorLocationId then return end
    if target:getLocationId() ~= e.locationId then return end
    local selectedChar = MissionUtils:selectedCharacter() or Character:getPlayer()
    if not selectedChar or selectedChar:getLocationId() ~= e.locationId then return end
    WorldUtils:startScenario("StartCombatOnLoadLoc", target, selectedChar)
end

function refreshTargets()
    local neighborhoodMap = {}
    local neighborhoods = WorldUtils:getExteriorLocations()
    if neighborhoods then
        for i = 1, #neighborhoods do
            local hood = neighborhoods[i]
            local hoodName = hood.name
            if hoodName and hood.buildings then
                for j = 1, #hood.buildings do
                    local building = hood.buildings[j]
                    if building.locationId then
                        neighborhoodMap[building.locationId] = hoodName
                    end
                end
            end
        end
    end

    local candidates = {}
    local rivalIds = WorldUtils:getOtherGangFactionsIds()
    if rivalIds then
        for i = 1, #rivalIds do
            local faction = WorldUtils:getFactionById(rivalIds[i])
            if faction and not faction:isDead() then
                local boss = faction.boss
                local bossName = boss and boss.name or faction.name
                for _, member in next, faction.members do
                    if member ~= boss and not member:isDead() then
                        local locId = member:getLocationId()
                        candidates[#candidates + 1] = {
                            actor = member,
                            name = member.name,
                            neighborhood = neighborhoodMap[locId],
                            precinct = getPrecinctKey(member),
                            faction = bossName,
                            targetType = "$MEGAMOD_ICA_type_gangster",
                        }
                    end
                end
            end
        end
    end

    local thugFaction = WorldUtils:thugFaction()
    if thugFaction and thugFaction.members then
        for _, member in next, thugFaction.members do
            if not member:isDead() then
                local locId = member:getLocationId()
                candidates[#candidates + 1] = {
                    actor = member,
                    name = member.name,
                    neighborhood = neighborhoodMap[locId],
                    precinct = getPrecinctKey(member),
                    faction = "$MEGAMOD_ICA_unaffiliated",
                    targetType = "$MEGAMOD_ICA_type_thug",
                }
            end
        end
    end

    local citizenFaction = WorldUtils:getFactionById("FACTION.CITIZENS")
    if citizenFaction and citizenFaction.members then
        for _, member in next, citizenFaction.members do
            if not member:isDead() then
                local locId = member:getLocationId()
                candidates[#candidates + 1] = {
                    actor = member,
                    name = member.name,
                    neighborhood = neighborhoodMap[locId],
                    precinct = getPrecinctKey(member),
                    faction = "$MEGAMOD_ICA_unaffiliated",
                    targetType = "$MEGAMOD_ICA_type_citizen",
                }
            end
        end
    end

    -- Separate gangsters from civilians/thugs so gangsters are offered more often
    -- MEGAMOD FIX: dropped unused icaRepOthers. These lists are intentionally
    -- transient (ad-hoc fields, rebuilt every day begin) - do not move to memory.
    local gangsters = {}
    for i = 1, #candidates do
        if candidates[i].targetType == "$MEGAMOD_ICA_type_gangster" then
            gangsters[#gangsters + 1] = candidates[i]
        end
    end
    thisActor.icaRepTargets = candidates
    thisActor.icaRepGangsters = gangsters
end

--[[------------------------------------------------------------------------------
    WORLD_EVENTS: flush notification (scheduled by the behaviour's fear counter)
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_ICA_FLUSHED"
_event = "MegaModICATargetFlushed"
_category = "Misc"

persist{}
flushedTargetName = nil -- Expected Param

function canTrigger()
    return flushedTargetName ~= nil
end

function onTrigger()
    title("$MEGAMOD_ICA_flushed_title") --$ The Target Bolts
    text({"$MEGAMOD_ICA_flushed_text", flushedTargetName}) --$ Word travels fast when street muscle starts dying. Our sources report that {0} has lost their nerve -- seen slipping out a side door with collar up and hat brim low, and no plan beyond AWAY. The target is in the open now, my friend. Frightened people do not stay found for long. Move.
    option("$MEGAMOD_ICA_flushed_dismiss") --$ They can run all they like.
end

--[[------------------------------------------------------------------------------
    MISSIONS: ICA Contract Side Quest
    Uses plain string description (parameterized arrays corrupt mission journal UI).
    Vanilla engine file overrides (Missions.lua etc.) were the cause of journal
    tab corruption - those have been moved to Research/ folder.
--------------------------------------------------------------------------------]]
_namespace = "MISSIONS"
_id = "MEGAMOD_ICA_CONTRACT"
_mission = "MegaModICAContract"
_priority = 0
_faction = "FACTION.PLAYER"
_category = "Crew"

persist{}
targetActor = nil

persist{}
targetName = nil

persist{}
targetHood = nil

persist{}
targetPrecinct = nil

persist{}
targetFaction = nil

persist{}
targetType = nil

persist{}
icaRepActor = nil

function onMissionCreate()
    defineMission
    {
        name = "$MEGAMOD_ICA_mission_name", --$ ICA Contract
        description = "$MEGAMOD_ICA_mission_desc",
    }
end

function onMissionStart()
    addObjective("EliminateTarget")
    addPOI(targetActor, "MISSION_TARGET", "EliminateTarget")
    -- MEGAMOD FIX: alreadyGiven=true makes this display-only; Mr. Smith hands over the
    -- $20k in conversation (PayOut). Was addCashReward(20000, false, true) = paid twice.
    addCashReward(20000, true)
end

function onMissionSuccess()
    -- MEGAMOD FIX: only queue the payout if the contract is still live
    -- (not already paid out or cancelled in conversation)
    if icaRepActor and icaRepActor.memory.icaContractActive then
        icaRepActor.memory.icaContractCompleted = true
    end
    if icaRepActor then
        icaRepActor.memory.icaCancelContract = nil
    end
end

function onMissionFail()
    -- MEGAMOD FIX: clear ALL contract state (was only 2 of the fields)
    if icaRepActor then
        local mem = icaRepActor.memory
        -- MEGAMOD ICA ACCESS: undo the building access grant (mirrors the
        -- conversation's ClearContractState; a no-op when the conversation already
        -- cleaned up before flagging this mission to fail)
        local accessBuilding = mem.icaAccessBuilding
        if accessBuilding and not accessBuilding.isDeleted then
            WorldUtils:removeImportantForMissionBuilding(accessBuilding)
        end
        local accessTarget = mem.icaActiveTarget
        if accessTarget and mem.icaTargetOrigFactionId and not accessTarget.isDeleted
            and not accessTarget:isDead()
            and accessTarget.faction and accessTarget.faction.isThugFaction then
            local origFaction = WorldUtils:getFactionById(mem.icaTargetOrigFactionId)
            if origFaction then
                accessTarget:setFaction(origFaction)
            end
        end
        if mem.icaGuardSquad then
            mem.icaGuardSquad:removeFromSquads()
        end
        mem.icaAccessBuilding = nil
        mem.icaTargetOrigFactionId = nil
        mem.icaGuardSquad = nil
        mem.icaSpawnGuards = nil
        mem.icaFearKills = nil
        mem.icaContractActive = nil
        mem.icaActiveTarget = nil
        mem.icaActiveTargetName = nil
        mem.icaActiveTargetHood = nil
        mem.icaActiveTargetPrecinct = nil
        mem.icaActiveTargetFaction = nil
        mem.icaActiveTargetType = nil
        mem.icaPendingMission = nil
        mem.icaContractCompleted = nil
        mem.icaCancelContract = nil
    end
end

function EliminateTarget()
    defineObjective
    {
        description = {"$MEGAMOD_ICA_obj_kill", targetName},
    }
end

function EliminateTargetCheck()
    -- MEGAMOD FIX: player called off the contract at Mr. Smith - fail this mission
    -- (vanilla pattern: failMission inside a Check fn, cf. PlayingTheMarketMission)
    if icaRepActor and icaRepActor.memory.icaCancelContract then
        icaRepActor.memory.icaCancelContract = nil
        failMission("$MEGAMOD_ICA_mission_cancelled")
        return false
    end
    return targetActor and targetActor:isDead()
end

function EliminateTargetDone()
end

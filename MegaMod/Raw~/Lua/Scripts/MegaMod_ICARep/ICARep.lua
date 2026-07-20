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
    option("$MEGAMOD_BANK_cancel", CancelContract) --$ I want to cancel the contract
    option("$MEGAMOD_BANK_leave_status", Leave) --$ I'm working on it
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
-- Move a target to the street if they're in a rival-owned building the player
-- can't enter. Teleports them to the exterior of their current neighborhood.
function ensureTargetAccessible(target)
    if not target or target:isDead() then return end

    local targetLocId = target:getLocationId()
    if not targetLocId then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    -- Build a map of building locationId -> neighborhood exterior + building ref
    local neighborhoods = WorldUtils:getExteriorLocations()
    if not neighborhoods then return end

    for i = 1, #neighborhoods do
        local hood = neighborhoods[i]
        -- Check if target's location is the exterior itself (already outside)
        if hood.id == targetLocId then return end

        if hood.buildings then
            for j = 1, #hood.buildings do
                local building = hood.buildings[j]
                if building.locationId == targetLocId then
                    -- Found the building the target is in
                    local owner = building.getOwnerFaction and building:getOwnerFaction()
                    if owner and owner ~= playerFaction and not owner.isPlayerFaction then
                        -- Target is in a rival-owned building, move them outside
                        target:setLocationId(hood.id)
                    end
                    return
                end
            end
        end
    end
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
    if thisActor.memory.icaContractActive and thisActor.memory.icaActiveTarget then
        ensureTargetAccessible(thisActor.memory.icaActiveTarget)
    end

    -- Create mission if contract was accepted in conversation
    if thisActor.memory.icaPendingMission then
        thisActor.memory.icaPendingMission = nil
        -- Move target outside before starting the mission
        if thisActor.memory.icaActiveTarget then
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

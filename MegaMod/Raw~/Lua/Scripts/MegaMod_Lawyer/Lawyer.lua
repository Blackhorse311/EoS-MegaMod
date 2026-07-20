--[[------------------------------------------------------------------------------
    MegaMod: Vincent "The Brief" Moretti - The Corrupt Lawyer
    A crooked attorney who can reduce police heat, provide legal defense,
    and bribe a judge for permanent benefits. All for a price.
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: Define the Lawyer NPC
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_LAWYER"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_02_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_02_Profile"
prefab = "Models/Characters/Extras/MissionNPCs/Prefabs/MissionNPC_Bartender_Male_02"
ragdollPrefab = "Models/Characters/Extras/Bartenders/Prefabs/Bartender_Male_02_Ragdoll"

name = "$MEGAMOD_LAWYER_fullname" --$ Vincent "The Brief" Moretti
firstName = "$MEGAMOD_LAWYER_firstname" --$ Vincent
lastName = "$MEGAMOD_LAWYER_lastname" --$ Moretti
profession = "NoProfession"
commands =
{
    Talk = true,
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    Step 2: Spawn event - appears at mid-game
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_LAWYER_SPAWN"
_event = "MegaModLawyerSpawn"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 220
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    -- MEGAMOD FIX: check preconditions BEFORE spawning so an early return can't leak a location-less actor
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    local lawyer = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_LAWYER")
    safehouse:enter(lawyer, "IDLE", true)
    lawyer.behaviours:add("MegaModLawyerBehaviour")

    title("$MEGAMOD_LAWYER_arrive_title") --$ A Man of the Law
    text("$MEGAMOD_LAWYER_arrive_text") --$ A man in an expensive suit and gold cufflinks has appeared at your safehouse. "Vincent Moretti, Esquire," he announces. "The law is my business. Making it look the other way is my specialty." Talk to him when the heat gets too much.
    option("$MEGAMOD_LAWYER_arrive_option") --$ Good to have a lawyer on hand.
end

--[[------------------------------------------------------------------------------
    Step 3: Lawyer conversation
    Conversation sandbox: no WorldUtils, no getWorld().
    MEGAMOD FIX: durable state lives in world facts (save-persistent, shared by
    all safehouse clones); pending flags stay on the actor (consumed next frame).

    fact.MegaModLawyerCooldownUntil - worldTime when heat-reduction cooldown ends
    fact.MegaModJudgeBribed         - one-time judge bribe flag (faction-wide)
    them.pendingHeatReduction - set by conversation; behaviour applies heat drop, charges $500
    them.pendingLegalDefense  - set by conversation; behaviour applies heat dip, charges net $200
    them.pendingJudgeBribe    - set by conversation; behaviour applies one-time heat drop
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_LAWYER_CONVERSATION"
EntryPoint = "MegaMod_Lawyer_Start"

function onStart()
    go(MainMenu)
end

function MainMenu()
    say("$MEGAMOD_LAWYER_greeting") --$ What legal troubles can I make disappear today?
        option("$MEGAMOD_LAWYER_heat", ReduceHeat)  --$ Reduce police heat ($500)
        option("$MEGAMOD_LAWYER_defense", LegalDefense)  --$ Legal defense ($300)
        option("$MEGAMOD_LAWYER_judge", BribeJudge)  --$ Bribe a judge ($1,000)
        option("$MEGAMOD_LAWYER_leave", Leave)  --$ Not today
end

function ReduceHeat()
    -- Check cooldown (pending flag guards the frame between purchase and application)
    if them.pendingHeatReduction or (fact.MegaModLawyerCooldownUntil and worldTime < fact.MegaModLawyerCooldownUntil) then
        say("$MEGAMOD_LAWYER_heat_cooldown") --$ I already pulled strings this week. The captain I know needs time before he can look the other way again. Give it a few days.
                option("$MEGAMOD_LAWYER_backtomenu", MainMenu)  --$ What else can you do?
            option("$MEGAMOD_LAWYER_leave", Leave)  --$ I'll be back
        return
    end

    -- Check cash
    if you.faction.cash.count < 500 then
        say("$MEGAMOD_LAWYER_cantafford") --$ My services don't come cheap, and you don't have enough. Come back when your treasury's looking healthier.
                option("$MEGAMOD_LAWYER_backtomenu", MainMenu)
            option("$MEGAMOD_LAWYER_leave", Leave)
        return
    end

    say("$MEGAMOD_LAWYER_heat_confirm") --$ Five hundred dollars. I know a captain on the force who owes me a favor. I'll have him pull his boys off your territory for a while. The heat goes down, your operations breathe easier. Deal?
        option("$MEGAMOD_LAWYER_heat_yes", ExecuteHeatReduction)  --$ Make it happen
        option("$MEGAMOD_LAWYER_heat_no", MainMenu)  --$ On second thought...
end

function ExecuteHeatReduction()
    -- MEGAMOD FIX: behaviour charges the $500 and starts the cooldown only when
    -- the heat reduction is actually applied
    them.pendingHeatReduction = true
    say("$MEGAMOD_LAWYER_heat_done") --$ Consider it handled. I know a captain on the force who owes me a favor. Your streets will be a lot quieter for a while.
        option("$MEGAMOD_LAWYER_backtomenu", MainMenu)  --$ What else can you do?
        option("$MEGAMOD_LAWYER_leave", Leave)  --$ Good doing business
end

function LegalDefense()
    if you.faction.cash.count < 300 then
        say("$MEGAMOD_LAWYER_cantafford") --$ My services don't come cheap, and you don't have enough. Come back when your treasury's looking healthier.
                option("$MEGAMOD_LAWYER_backtomenu", MainMenu)
            option("$MEGAMOD_LAWYER_leave", Leave)
        return
    end

    say("$MEGAMOD_LAWYER_defense_confirm") --$ Three hundred dollars and I'll make some calls. If any of your boys are in hot water, I'll get them out faster. I'll also recover some assets the cops have been sitting on. Net cost to you is about two hundred after I get back what's yours. Sound good?
        option("$MEGAMOD_LAWYER_defense_yes", ExecuteDefense)  --$ Do it
        option("$MEGAMOD_LAWYER_defense_no", MainMenu)  --$ Maybe later
end

function ExecuteDefense()
    -- MEGAMOD FIX: was a $200 placebo; behaviour now applies a real police-activity
    -- dip on all player precincts, charging $300 (and recovering $100) on application
    them.pendingLegalDefense = true
    say("$MEGAMOD_LAWYER_defense_done") --$ I've filed the motions and made the calls. Your people will have an easier time if they run into trouble. I also recovered a hundred dollars in seized assets from the precinct evidence locker. Consider it a professional courtesy.
        option("$MEGAMOD_LAWYER_backtomenu", MainMenu)
        option("$MEGAMOD_LAWYER_leave", Leave)
end

function BribeJudge()
    if fact.MegaModJudgeBribed then
        say("$MEGAMOD_LAWYER_judge_already") --$ Judge Henderson is already in our pocket. No need to pay him twice. He knows which side his bread is buttered on.
                option("$MEGAMOD_LAWYER_backtomenu", MainMenu)
            option("$MEGAMOD_LAWYER_leave", Leave)
        return
    end

    if you.faction.cash.count < 1000 then
        say("$MEGAMOD_LAWYER_cantafford") --$ My services don't come cheap, and you don't have enough. Come back when your treasury's looking healthier.
                option("$MEGAMOD_LAWYER_backtomenu", MainMenu)
            option("$MEGAMOD_LAWYER_leave", Leave)
        return
    end

    say("$MEGAMOD_LAWYER_judge_confirm") --$ For a grand, I can get Judge Henderson in our pocket. He handles most of the criminal cases in this district. Your people will get lighter sentences, your operations will draw less scrutiny, and the cops will have a harder time making charges stick. It's a one-time investment that pays for itself. We have a deal?
        option("$MEGAMOD_LAWYER_judge_yes", ExecuteJudgeBribe)  --$ Pay the man
        option("$MEGAMOD_LAWYER_judge_no", MainMenu)  --$ That's a lot of money
end

function ExecuteJudgeBribe()
    BRScript:PlayerSubtractCash(1000, "CASH.LEGAL_FEES")
    -- MEGAMOD FIX: fact so every safehouse clone shares the one-time bribe
    fact.MegaModJudgeBribed = true
    them.pendingJudgeBribe = true
    say("$MEGAMOD_LAWYER_judge_done") --$ Done. Judge Henderson will receive a very generous anonymous donation to his "retirement fund" tonight. From now on, your outfit gets the benefit of the doubt in his courtroom. That's as good as it gets in this city.
        option("$MEGAMOD_LAWYER_backtomenu", MainMenu)
        option("$MEGAMOD_LAWYER_leave", Leave)
end

function Leave()
    say("$MEGAMOD_LAWYER_goodbye") --$ My door is always open. Well, the back door, anyway.
    endConversation()
end

--[[------------------------------------------------------------------------------
    Step 4: Lawyer behaviour
    - Sets conversation entry point
    - Processes pending heat reduction / legal defense / judge bribe by applying
      REAL police activity via precinct:addTemporaryPoliceActivity (decays over time)
    - Cooldown is a world fact checked directly by the conversation via worldTime
    WorldUtils IS available in behaviours.
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_LAWYER_BEHAVIOUR"
_name = "MegaModLawyerBehaviour"

local COOLDOWN_SECONDS = 7 * 24 * 60 * 60
local HEAT_REDUCTION_AMOUNT = -20
local JUDGE_BRIBE_AMOUNT = -10
local DEFENSE_HEAT_AMOUNT = -5

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_Lawyer_Start")
end

-- MEGAMOD FIX: must be a plain global function (local functions don't get the
-- sandbox env, so WorldUtils was nil and this errored after taking the money).
-- Applies real heat to every distinct precinct holding a player building.
-- Returns the number of precincts affected.
function applyPoliceEffect(amount)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return 0 end
    local buildings = playerFaction.buildings
    local processed = {}
    local numAffected = 0
    for i = 1, #buildings do
        local building = buildings[i]
        local precinct = building and building:getPrecinct()
        if precinct and not processed[precinct.id] then
            processed[precinct.id] = true
            precinct:addTemporaryPoliceActivity(amount)
            numAffected = numAffected + 1
        end
    end
    return numAffected
end

function GameEvent.frame(e)
    -- Process pending heat reduction (flag set by conversation)
    if thisActor.pendingHeatReduction then
        thisActor.pendingHeatReduction = false
        -- MEGAMOD FIX: charge and start the cooldown only if the effect landed
        if applyPoliceEffect(HEAT_REDUCTION_AMOUNT) > 0 then
            BRScript:PlayerSubtractCash(500, "CASH.LEGAL_FEES")
            fact.MegaModLawyerCooldownUntil = worldTime + COOLDOWN_SECONDS
        end
    end

    -- Process legal defense: small heat dip on all player precincts, $300 fee
    -- offset by $100 of "recovered assets" (net $200, as Vincent promises)
    if thisActor.pendingLegalDefense then
        thisActor.pendingLegalDefense = false
        if applyPoliceEffect(DEFENSE_HEAT_AMOUNT) > 0 then
            BRScript:PlayerSubtractCash(300, "CASH.LEGAL_FEES")
            BRScript:PlayerAddCash(100, "CASH.RECOVERED_ASSETS")
        end
    end

    -- Process judge bribe (one-time heat reduction; flag itself lives in fact)
    if thisActor.pendingJudgeBribe then
        thisActor.pendingJudgeBribe = false
        applyPoliceEffect(JUDGE_BRIBE_AMOUNT)
    end
end

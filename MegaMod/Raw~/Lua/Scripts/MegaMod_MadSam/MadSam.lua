--[[------------------------------------------------------------------------------
    MegaMod: "Mad Sam" DeStefano - The Juice Man
    Chicago's most feared loan shark. Offers a starter loan on day one
    ($10k / $15k / $25k "The Special"). The juice is 20% of the principal,
    due every 4 weeks, forever, until the principal is settled in full.

    Miss a payment and the juice compounds onto the principal AND Sam's
    muscle takes it out of your rackets: a random business loses a full
    star from a random characteristic; if the business is already bled
    dry (all ratings at 1 star), the Outfit takes the whole building.
    Out of rackets entirely? Capone's goons come for your safehouse.

    Decline the starter loan and Sam's man still sets up in your safehouse;
    small loans ($2k / $3k / $5k) stay available with the same juice terms.

    Kill Capone yourself and Mad Sam dies with him: his $100k stash turns
    up in the wreckage and any outstanding ledger burns.

    Enforcer faction: the Outfit; if the PLAYER is the Outfit (or Capone is
    already gone), the strongest surviving rival gang carries Sam's paper.

    State (world facts, save-durable, shared everywhere):
      fact.MegaModLoanPrincipal   - active principal ($), nil when no loan
      fact.MegaModLoanWeeks       - weeks since the last juice demand (0-3)
      fact.MegaModLoanDeclined    - player turned down the starter offer
      fact.MegaModMadSamStashFound- Capone/enforcer killed by player, Sam dead
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: Define Mad Sam's NPC
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_MADSAM"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/CivMale_05_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/CivMale_05_Profile"
prefab = "Models/Characters/Extras/MissionNPCs/Prefabs/MissionNPC_Male_05"
ragdollPrefab = "Models/Characters/Extras/CivMales/Prefabs/CivMale_05_Ragdoll"

name = "$MEGAMOD_MADSAM_fullname" --$ "Mad Sam" DeStefano
firstName = "$MEGAMOD_MADSAM_firstname" --$ Sam
lastName = "$MEGAMOD_MADSAM_lastname" --$ DeStefano
profession = "NoProfession"
commands =
{
    Talk = true,
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    Step 2: Day-one starter loan offer (modal) + NPC spawn
    Mad Sam stays in the PRIMARY safehouse only (like Mr. Smith) - he is NOT
    in the SafehouseManager registry, so no clone bookkeeping is needed.
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_OFFER"
_event = "MegaModMadSamOffer"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 100
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        complete()
        return
    end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then
        complete()
        return
    end

    local sam = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_MADSAM")
    if sam then
        safehouse:enter(sam, "IDLE", true)
        sam.behaviours:add("MegaModMadSamBehaviour")
    end

    setModal(true)
    title("$MEGAMOD_MADSAM_offer_title") --$ The Juice Man Comes Calling
    text("$MEGAMOD_MADSAM_offer_text") --$ A thick-necked man in an expensive suit lets himself into your safehouse like he owns the joint. "Sam DeStefano sends his regards. Every new outfit in this town needs walking-around money, and Sam's got plenty. The juice is twenty percent, due every month, and it keeps coming until the principal's paid in full. Miss a payment and, well... Sam gets emotional. So. How much are we talking?"
    option("$MEGAMOD_MADSAM_offer_10k", takeLoan10k) --$ Ten grand. ($10,000 - juice $2,000 a month)
    option("$MEGAMOD_MADSAM_offer_15k", takeLoan15k) --$ Fifteen grand. ($15,000 - juice $3,000 a month)
    option("$MEGAMOD_MADSAM_offer_25k", takeLoan25k) --$ "The Special." ($25,000 - juice $5,000 a month)
    option("$MEGAMOD_MADSAM_offer_decline", declineLoan) --$ Tell Sam I don't need his money.
end

function acceptLoan(amount)
    BRScript:PlayerAddCash(amount, "CASH.TRADE")
    fact.MegaModLoanPrincipal = amount
    fact.MegaModLoanWeeks = 0
    WorldUtils:scheduleWithDelay("MegaModMadSamTerms", 15, "TICK")
    complete()
end

function takeLoan10k()
    acceptLoan(10000)
end

function takeLoan15k()
    acceptLoan(15000)
end

function takeLoan25k()
    acceptLoan(25000)
end

function declineLoan()
    fact.MegaModLoanDeclined = true
    complete()
end

--[[------------------------------------------------------------------------------
    Step 3: Loan terms notification (scheduled after accepting the starter loan)
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_TERMS"
_event = "MegaModMadSamTerms"

function onTrigger()
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then
        return
    end
    local vig = math.ceil(principal * 0.20 / 100) * 100

    title("$MEGAMOD_MADSAM_terms_title") --$ Sam's Terms
    text({"$MEGAMOD_MADSAM_terms_text", principal, vig}) --$ The cash lands on your desk in a paper sack, and Sam's man spells it out: "The principal is {0:C0}. The juice is {1:C0}, due every month. Pay the juice, the principal stays alive. Settle the whole thing whenever you feel flush - come see Sam's man at your safehouse. And friend - don't miss a payment. The last fella who missed a payment, Sam got out the ice pick."
    option("$MEGAMOD_MADSAM_terms_dismiss") --$ Understood.
end

--[[------------------------------------------------------------------------------
    Step 4: Mad Sam conversation (at the safehouse)
    Conversation sandbox: no WorldUtils, no dynamic numbers in dialog text.
    Small loans use fixed amounts, so exact terms are baked into the loc keys.
    Dynamic amounts (status / payoff) hand off to world events through pending
    flags on the actor (them.*), processed by the behaviour's frame listener.
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_MADSAM_CONVERSATION"
EntryPoint = "MegaMod_MadSam_Start"

function onStart()
    go(MainMenu)
end

function MainMenu()
    if fact.MegaModLoanPrincipal and fact.MegaModLoanPrincipal > 0 then
        say("$MEGAMOD_MADSAM_conv_debt_greeting") --$ "You know how this works. Sam's ledger says you're still on the books. The juice keeps coming until the principal's settled. What'll it be?"
        option("$MEGAMOD_MADSAM_conv_status", RequestStatus) --$ Where does my ledger stand?
        option("$MEGAMOD_MADSAM_conv_payoff", RequestPayoff) --$ I want to settle up. All of it.
        option("$MEGAMOD_MADSAM_conv_leave", Leave) --$ Just passing through.
    else
        say("$MEGAMOD_MADSAM_conv_offer_greeting") --$ "Sam says the big money's off the table, but he's still got walking-around cash for a friend. Same terms as always: twenty percent juice, every month, until you settle the principal. How much?"
        option("$MEGAMOD_MADSAM_conv_loan2k", TakeLoan2k) --$ Two grand. ($2,000 - juice $400 a month)
        option("$MEGAMOD_MADSAM_conv_loan3k", TakeLoan3k) --$ Three grand. ($3,000 - juice $600 a month)
        option("$MEGAMOD_MADSAM_conv_loan5k", TakeLoan5k) --$ Five grand. ($5,000 - juice $1,000 a month)
        option("$MEGAMOD_MADSAM_conv_leave", Leave) --$ Not today.
    end
end

function TakeLoan2k()
    BRScript:PlayerAddCash(2000, "CASH.TRADE")
    fact.MegaModLoanPrincipal = 2000
    fact.MegaModLoanWeeks = 0
    go(LoanTaken)
end

function TakeLoan3k()
    BRScript:PlayerAddCash(3000, "CASH.TRADE")
    fact.MegaModLoanPrincipal = 3000
    fact.MegaModLoanWeeks = 0
    go(LoanTaken)
end

function TakeLoan5k()
    BRScript:PlayerAddCash(5000, "CASH.TRADE")
    fact.MegaModLoanPrincipal = 5000
    fact.MegaModLoanWeeks = 0
    go(LoanTaken)
end

function LoanTaken()
    say("$MEGAMOD_MADSAM_conv_loan_done") --$ He counts the bills out slow, like he's savoring it. "First juice payment comes due in a month. Sam wishes you the best of luck in your business endeavors. Sincerely. It's better for everybody when the money keeps moving."
    option("$MEGAMOD_MADSAM_conv_leave_paid", Leave) --$ Pleasure doing business.
end

function RequestStatus()
    them.pendingMadSamStatus = 1
    say("$MEGAMOD_MADSAM_conv_status_answer") --$ He flips open a little black notebook, licks his thumb, and starts turning pages. "Give me a minute to check the figures. Sam's very particular about the figures."
    option("$MEGAMOD_MADSAM_conv_leave_wait", Leave) --$ I'll wait.
end

function RequestPayoff()
    them.pendingMadSamPayoff = 1
    say("$MEGAMOD_MADSAM_conv_payoff_answer") --$ His eyebrows go up. "Settling in full? Sam always says it's a sad day when a good customer gets square. Let me tally it up - principal plus this month's juice, all of it, right now."
    option("$MEGAMOD_MADSAM_conv_leave_wait", Leave) --$ Run the numbers.
end

function Leave()
    say("$MEGAMOD_MADSAM_conv_goodbye") --$ "Sam knows where to find you. He always knows."
    endConversation()
end

--[[------------------------------------------------------------------------------
    Step 5: Mad Sam behaviour
    - Sets the conversation entry point
    - frame: processes pending status/payoff requests from the conversation
      (ContractBroker handoff pattern) and hands exact figures to world events
    - onDayBegin: if the player killed Sam's paymaster (stash found), Sam is
      dead too - his man packs up and disappears
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_MADSAM_BEHAVIOUR"
_name = "MegaModMadSamBehaviour"

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_MadSam_Start")
end

function GameEvent.frame(e)
    if thisActor.pendingMadSamStatus then
        thisActor.pendingMadSamStatus = nil
        WorldUtils:scheduleWithDelay("MegaModMadSamStatus", 5, "TICK")
    end
    if thisActor.pendingMadSamPayoff then
        thisActor.pendingMadSamPayoff = nil
        WorldUtils:scheduleWithDelay("MegaModMadSamPayoff", 5, "TICK")
    end
end

function GameEvent.onDayBegin(e)
    if fact.MegaModMadSamStashFound then
        thisActor:delete()
    end
end

--[[------------------------------------------------------------------------------
    Step 6: Permanent listener - monthly juice ticker + Capone death watch
    (SafehouseManager "Create + disableAutoComplete" permanent-listener pattern)
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_LISTENER"
_event = "MegaModMadSamListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete()
end

function GameEvent.onWeekBegin(e)
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then return end
    local weeks = (fact.MegaModLoanWeeks or 0) + 1
    if weeks >= 4 then
        fact.MegaModLoanWeeks = 0
        WorldUtils:scheduleWithDelay("MegaModMadSamDemand", 10, "TICK")
    else
        fact.MegaModLoanWeeks = weeks
    end
end

-- Kill attribution via the Dead state's killerFaction (Headlines.lua pattern).
-- Player kills Capone -> Mad Sam died in the battle, his stash is in the ruins.
-- If the PLAYER is the Outfit, Sam's paper is carried by a rival gang instead,
-- so the first rival boss the player personally puts down counts as Sam's end.
function GameEvent.onBossDeath(e)
    if fact.MegaModMadSamStashFound then return end
    local boss = e.target
    if not boss or boss.isPlayer then return end
    local deathInformation = boss:getState("Dead")
    local killerFaction = deathInformation and deathInformation.killerFaction
    if not killerFaction or not killerFaction.isPlayerFaction then return end
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local bossFaction = boss.faction
    if not bossFaction then return end

    if playerFaction.configId ~= "FACTION.THE_OUTFIT"
        and bossFaction.configId ~= "FACTION.THE_OUTFIT" then
        return
    end

    fact.MegaModMadSamStashFound = true
    WorldUtils:scheduleWithDelay("MegaModMadSamStash", Utils:daysToSecs(1), "DAILY_TICK")
end

--[[------------------------------------------------------------------------------
    Step 7: Monthly juice demand (modal)
    Miss it (or can't pay) and the juice compounds onto the principal AND
    Sam's muscle collects out of your rackets.
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_DEMAND"
_event = "MegaModMadSamDemand"

UPGRADE_TYPES = {"security", "ambiance", "production", "quality", "deflect", "game", "storage"}

function vigOf(principal)
    return math.ceil(principal * 0.20 / 100) * 100
end

function getEnforcerFaction(playerFaction)
    if playerFaction.configId ~= "FACTION.THE_OUTFIT" then
        local outfit = WorldUtils:getFactionById("FACTION.THE_OUTFIT")
        if outfit and not outfit:isDead() then
            return outfit
        end
    end
    -- Player IS the Outfit (or Capone is gone): strongest surviving rival
    local best, bestStrength
    local ids = WorldUtils:getOtherGangFactionsIds()
    if ids then
        for i = 1, #ids do
            local f = WorldUtils:getFactionById(ids[i])
            if f and not f:isDead() then
                local s = f:getStrength()
                if not best or s > bestStrength then
                    best, bestStrength = f, s
                end
            end
        end
    end
    return best
end

function onTrigger()
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then
        return
    end
    local vig = vigOf(principal)

    setModal(true)
    title("$MEGAMOD_MADSAM_demand_title") --$ The Juice Is Due
    text({"$MEGAMOD_MADSAM_demand_text", vig, principal}) --$ Sam's collector plants himself in front of your desk and cracks his knuckles one at a time. "The juice is due. {0:C0}, on the principal of {1:C0}. Sam sends his regards and says - and I'm quoting here - 'the money, or the emotional conversation.'"
    if BRScript:PlayerCanAfford(vig) then
        option("$MEGAMOD_MADSAM_demand_pay", payVig) --$ Pay the juice. (Sam stays happy)
        option("$MEGAMOD_MADSAM_demand_refuse", missPayment) --$ Sam can wait. (The juice compounds - and Sam gets emotional)
    else
        option("$MEGAMOD_MADSAM_demand_broke", missPayment) --$ I don't have it... (The juice compounds - and Sam gets emotional)
    end
end

function payVig()
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then return end
    BRScript:PlayerSubtractCash(vigOf(principal), "CASH.TRADE")
end

function missPayment()
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then return end
    local vig = vigOf(principal)
    -- Unpaid juice compounds onto the principal (rounded up to the next $100)
    fact.MegaModLoanPrincipal = math.ceil((principal + vig) / 100) * 100
    applyPenalty()
end

function applyPenalty()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    local rackets = {}
    for b in playerFaction:racketBuildingsIter() do
        rackets[#rackets + 1] = b
    end

    if #rackets == 0 then
        -- Nothing left to bleed: the enforcer comes for the safehouse itself
        WorldUtils:scheduleWithDelay("MegaModMadSamAttack", 20, "TICK")
        return
    end

    local racket = rackets[math.random(#rackets)]
    local candidates = {}
    if racket.upgrades then
        for i = 1, #UPGRADE_TYPES do
            local up = racket.upgrades:getUpgradeOfType(UPGRADE_TYPES[i])
            if up and up:getLevel() and up:getLevel() > 1 then
                candidates[#candidates + 1] = up
            end
        end
    end

    if #candidates > 0 then
        local up = candidates[math.random(#candidates)]
        up:downgrade(1)
        WorldUtils:scheduleWithDelay("MegaModMadSamStarLoss", 20, "TICK",
            "racketName", racket.name)
    else
        -- Business already bled dry: the enforcer faction takes the building
        local enforcer = getEnforcerFaction(playerFaction)
        if enforcer then
            local racketName = racket.name
            playerFaction:changeBuildingOwner(racket, enforcer, "Seized")
            WorldUtils:scheduleWithDelay("MegaModMadSamSeized", 20, "TICK",
                "racketName", racketName, "enforcerName", enforcer.name)
        end
    end
end

--[[------------------------------------------------------------------------------
    Step 8: Missed-payment fallout notifications
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_STARLOSS"
_event = "MegaModMadSamStarLoss"

persist{}
racketName = nil

function canTrigger()
    return racketName ~= nil
end

function onTrigger()
    title("$MEGAMOD_MADSAM_starloss_title") --$ Sam Gets Emotional
    text({"$MEGAMOD_MADSAM_starloss_text", racketName}) --$ You missed the juice, and Sam's boys paid a visit to {0} overnight. Smashed fixtures, roughed-up staff, merchandise in the river. The place is still yours - what's left of it - but the unpaid juice just got added to your principal. Sam says next month he expects better things from you.
    option("$MEGAMOD_MADSAM_starloss_dismiss") --$ He'll get his money.
end

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_SEIZED"
_event = "MegaModMadSamSeized"

persist{}
racketName = nil
enforcerName = nil

function canTrigger()
    return racketName ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_MADSAM_seized_title") --$ Sam Takes His Pound of Flesh
    text({"$MEGAMOD_MADSAM_seized_text", racketName, enforcerName}) --$ There was nothing left to smash at {0}, so Sam took the whole building. His muscle - {1} soldiers - ransacked the place and hung their colors out front by morning. It's their racket now. The unpaid juice compounded onto your principal too. Sam suggests, warmly, that you find the money next month.
    option("$MEGAMOD_MADSAM_seized_dismiss") --$ This isn't over.
end

--[[------------------------------------------------------------------------------
    Step 9: Safehouse attack - the player has no rackets left to bleed
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_ATTACK"
_event = "MegaModMadSamAttack"

function getEnforcerFaction(playerFaction)
    if playerFaction.configId ~= "FACTION.THE_OUTFIT" then
        local outfit = WorldUtils:getFactionById("FACTION.THE_OUTFIT")
        if outfit and not outfit:isDead() then
            return outfit
        end
    end
    local best, bestStrength
    local ids = WorldUtils:getOtherGangFactionsIds()
    if ids then
        for i = 1, #ids do
            local f = WorldUtils:getFactionById(ids[i])
            if f and not f:isDead() then
                local s = f:getStrength()
                if not best or s > bestStrength then
                    best, bestStrength = f, s
                end
            end
        end
    end
    return best
end

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    local enforcer = getEnforcerFaction(playerFaction)
    if not enforcer then return end

    local locId = safehouse.locationId
    local station = WorldUtils:getFreeStation(locId)
    local pos = station and station.pos

    local squad = MissionUtils:spawnSquad(8, enforcer.configId, "Balanced", 6)
    if squad then
        if pos then
            -- guard=true (they hunt the player), unbribable, forced hostility
            MissionUtils:placeSquad(squad, locId, pos, nil, nil, pos, true, false, nil, nil, true, true)
        elseif squad.members then
            for _, member in next, squad.members do
                member:setLocationId(locId)
                member:addTag("FightsAgainstPlayer")
                member:addStateIfNotAdded("Unbribable")
            end
        end
    end

    setModal(true)
    title("$MEGAMOD_MADSAM_attack_title") --$ Sam Calls In the Outfit
    text({"$MEGAMOD_MADSAM_attack_text", enforcer.name}) --$ You've got nothing left for Sam's boys to take - except the roof over your head. Word on the street is {0} muscle is rolling toward your safehouse right now, and they're not coming to negotiate. Sam wants his money or he wants you. Arm everybody.
    option("$MEGAMOD_MADSAM_attack_dismiss") --$ Let them come.
end

--[[------------------------------------------------------------------------------
    Step 10: Ledger status (non-modal notification with exact figures)
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_STATUS"
_event = "MegaModMadSamStatus"

function onTrigger()
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then
        title("$MEGAMOD_MADSAM_status_clear_title") --$ Sam's Ledger
        text("$MEGAMOD_MADSAM_status_clear_text") --$ Sam's man snaps the notebook shut. "You're not in the book. Clean as a whistle. Sam finds that almost disappointing."
        option("$MEGAMOD_MADSAM_status_dismiss") --$ Good.
        return
    end
    local vig = math.ceil(principal * 0.20 / 100) * 100
    local weeksLeft = 4 - (fact.MegaModLoanWeeks or 0)

    title("$MEGAMOD_MADSAM_status_title") --$ Sam's Ledger
    text({"$MEGAMOD_MADSAM_status_text", principal, vig, weeksLeft}) --$ Sam's man runs a fat finger down the page. "Here you are. Principal outstanding: {0:C0}. Juice on that: {1:C0} a month. Next collection comes in about {2} week(s). Settle the principal plus one month's juice any time and you're out of the book for good."
    option("$MEGAMOD_MADSAM_status_dismiss") --$ Noted.
end

--[[------------------------------------------------------------------------------
    Step 11: Full payoff (modal, exact figures)
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_PAYOFF"
_event = "MegaModMadSamPayoff"

function onTrigger()
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then
        return
    end
    local vig = math.ceil(principal * 0.20 / 100) * 100
    local total = principal + vig

    setModal(true)
    title("$MEGAMOD_MADSAM_payoff_title") --$ Settling With Sam
    text({"$MEGAMOD_MADSAM_payoff_text", principal, vig, total}) --$ The figures come back: principal {0:C0}, plus this month's juice {1:C0}. Total to get square with Sam, once and for all: {2:C0}.
    if BRScript:PlayerCanAfford(total) then
        option("$MEGAMOD_MADSAM_payoff_pay", payOff) --$ Pay it. Every dime.
        option("$MEGAMOD_MADSAM_payoff_later", dismissPayoff) --$ Not yet.
    else
        option("$MEGAMOD_MADSAM_payoff_broke", dismissPayoff) --$ I can't cover that right now.
    end
end

function payOff()
    local principal = fact.MegaModLoanPrincipal
    if not principal or principal <= 0 then return end
    local vig = math.ceil(principal * 0.20 / 100) * 100
    BRScript:PlayerSubtractCash(principal + vig, "CASH.TRADE")
    fact.MegaModLoanPrincipal = nil
    fact.MegaModLoanWeeks = nil
end

function dismissPayoff()
end

--[[------------------------------------------------------------------------------
    Step 12: Mad Sam's stash - the player personally killed Sam's paymaster
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_MADSAM_STASH"
_event = "MegaModMadSamStash"

function onTrigger()
    BRScript:PlayerAddCash(100000, "CASH.LOOT")
    local hadLoan = fact.MegaModLoanPrincipal and fact.MegaModLoanPrincipal > 0
    fact.MegaModLoanPrincipal = nil
    fact.MegaModLoanWeeks = nil

    setModal(true)
    title("$MEGAMOD_MADSAM_stash_title") --$ Mad Sam's Stash
    if hadLoan then
        text("$MEGAMOD_MADSAM_stash_debt_text") --$ Your crew finds him in the wreckage of the safehouse: "Mad Sam" DeStefano, the juice man himself, caught in the crossfire with his little black notebook still in his coat. Behind a false wall your boys pry out a strongbox stuffed with $100,000 in small bills - and every page of his ledger goes into the furnace. Your debt died with him.
    else
        text("$MEGAMOD_MADSAM_stash_text") --$ Your crew finds him in the wreckage of the safehouse: "Mad Sam" DeStefano, the juice man himself, caught in the crossfire with his little black notebook still in his coat. Behind a false wall your boys pry out a strongbox stuffed with $100,000 in small bills. Every debtor in Chicago just got an unexpected holiday.
    end
    option("$MEGAMOD_MADSAM_stash_dismiss") --$ Chicago's a safer town already.
end

--[[------------------------------------------------------------------------------
    MegaMod: The Big Bankroll (EventDirector: ROTHSTEIN_LOAN)
    Arnold Rothstein -- "the man who fixed the 1919 World Series" -- bankrolls
    half the bootleggers on the eastern seaboard, at terms only a desperate
    man takes. His Chicago representative comes calling with an open satchel.
    Borrow, and twenty-one days later the office expects its money back with
    interest. A.R.'s collectors don't take IOUs.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass) and drives the
    repayment chain via scheduleWithDelay (save-persisted, TheUntouchable shape).
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ROTHSTEIN_LOAN_LISTENER"
_event = "MegaModRothsteinLoanListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if e.eventName ~= "ROTHSTEIN_LOAN" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.cash then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "ROTHSTEIN_LOAN")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModRothsteinLoanOffer", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "ROTHSTEIN_LOAN")
end

--[[------------------------------------------------------------------------------
    THE OFFER
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ROTHSTEIN_LOAN_OFFER"
_event = "MegaModRothsteinLoanOffer"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_ROTHSTEIN_offer_title") --$ The Big Bankroll
    text("$MEGAMOD_ROTHSTEIN_offer_text") --$ A quiet man in a New York suit takes a seat across from your desk without being asked. He lays down a card with no name on it, just a Manhattan telephone exchange. "I represent a gentleman on the East Coast. You'd know him as the fellow who settled the 1919 Series to his own satisfaction. Mr. Rothstein extends credit to men of ambition -- bootleggers, gamblers, builders of empires. His terms are his terms. Nobody haggles with the Big Bankroll." He opens a satchel of banded bills. "How much ambition are we financing today?"
    option("$MEGAMOD_ROTHSTEIN_offer_big", rothsteinBorrowBig) --$ Take the $5,000. I'm good for it.
    option("$MEGAMOD_ROTHSTEIN_offer_small", rothsteinBorrowSmall) --$ Just $2,000. A taste, not a habit.
    option("$MEGAMOD_ROTHSTEIN_offer_decline", rothsteinDecline) --$ Smart money stays home. No deal.
end

function rothsteinBorrowBig()
    BRScript:PlayerAddCash(5000, "CASH.MISSION_REWARD")

    -- The office calls the note in three weeks: $5,000 principal, $7,500 due
    WorldUtils:scheduleWithDelay("MegaModRothsteinCollection", Utils:daysToSecs(21), "TICK",
        "rothsteinDebt", 7500,
        "rothsteinPrincipal", 5000)

    title("$MEGAMOD_ROTHSTEIN_big_taken_title") --$ Five Grand on the Table
    text("$MEGAMOD_ROTHSTEIN_big_taken_text") --$ The quiet man counts out five thousand dollars like he's dealing cards. "Seventy-five hundred comes due in three weeks. Mr. Rothstein doesn't send letters, and he doesn't send lawyers. He sends men who used to break legs for a living and found they missed it." He closes the satchel and tips his hat. "A pleasure doing business."
    option("$MEGAMOD_ROTHSTEIN_dismiss_taken") --$ Three weeks. Plenty of time.
end

function rothsteinBorrowSmall()
    BRScript:PlayerAddCash(2000, "CASH.MISSION_REWARD")

    -- Same clock, smaller note: $2,000 principal, $3,000 due
    WorldUtils:scheduleWithDelay("MegaModRothsteinCollection", Utils:daysToSecs(21), "TICK",
        "rothsteinDebt", 3000,
        "rothsteinPrincipal", 2000)

    title("$MEGAMOD_ROTHSTEIN_small_taken_title") --$ A Modest Note
    text("$MEGAMOD_ROTHSTEIN_small_taken_text") --$ "Two thousand." The quiet man peels off the bills with something close to disappointment. "Three grand due in twenty-one days. Small note, same rules. Mr. Rothstein once had a man followed for eleven months over a fifty-dollar marker -- it isn't the money with him, you understand. It's the principle of the money." He leaves the way he came, without a sound.
    option("$MEGAMOD_ROTHSTEIN_dismiss_taken") --$ Three weeks. Plenty of time.
end

function rothsteinDecline()
    title("$MEGAMOD_ROTHSTEIN_decline_title") --$ Smart Money Stays Home
    text("$MEGAMOD_ROTHSTEIN_decline_text") --$ You slide the card back across the desk. "Tell Mr. Rothstein I finance my own ambitions." The quiet man almost smiles as he closes the satchel. "He said you might say that. He said the smart ones always do -- right up until the week they don't." He sees himself out. Somewhere in Manhattan, a ledger closes with your name still out of it. Best place for it.
    option("$MEGAMOD_ROTHSTEIN_dismiss_decline") --$ My money, my rules.
end

--[[------------------------------------------------------------------------------
    THE COLLECTION (21 days later)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ROTHSTEIN_COLLECTION"
_event = "MegaModRothsteinCollection"
_category = "Misc"

persist{}
rothsteinDebt = nil -- Expected Param

persist{}
rothsteinPrincipal = nil -- Expected Param

function canTrigger()
    return rothsteinDebt ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_ROTHSTEIN_collect_title") --$ The Note Comes Due
    text({"$MEGAMOD_ROTHSTEIN_collect_text", rothsteinDebt}) --$ The quiet man is back, and this time he isn't alone -- two wide gentlemen wait by the door with their hands folded. "Twenty-one days," he says pleasantly. "Mr. Rothstein's regards. The figure is ${0}, and the figure is not a conversation." He sets an empty satchel on your desk and waits.
    option("$MEGAMOD_ROTHSTEIN_collect_pay", rothsteinPayUp) --$ Pay the man. A debt's a debt.
    option("$MEGAMOD_ROTHSTEIN_collect_stiff", rothsteinStiff) --$ Tell A.R. to take a walk.
end

-- MEGAMOD: collectors call at the safehouse when the office gets stiffed.
-- FACTION.THUGS squad (spawnSquad default) -- no faction war, just a fight.
function rothsteinSpawnCollectors()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end

    local collectors = MissionUtils:spawnSquad(5)
    if collectors then
        -- Building.locationId is the exterior street location the building sits in
        MissionUtils:placeSquad(collectors, safehouse.locationId, safehouse:getPos())
    end
end

function rothsteinPayUp()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cash = (playerFaction and playerFaction.cash and playerFaction.cash.count) or 0

    if cash >= rothsteinDebt then
        BRScript:PlayerSubtractCash(rothsteinDebt, "CASH.EXPENSES")

        title("$MEGAMOD_ROTHSTEIN_paid_title") --$ Square with the Office
        text({"$MEGAMOD_ROTHSTEIN_paid_text", rothsteinDebt}) --$ You count out ${0} and fill the satchel. The quiet man doesn't recount it -- that's the compliment. "Mr. Rothstein will be pleased. He keeps a short list of people who pay on time, and it's a good list to be on." The wide gentlemen unfold their hands and file out. Expensive lesson, clean ending.
        option("$MEGAMOD_ROTHSTEIN_dismiss_paid") --$ Never again. Probably.
    else
        -- Short: hand over everything on hand, and the collectors come anyway
        local partial = math.min(rothsteinDebt, cash)
        if partial > 0 then
            BRScript:PlayerSubtractCash(partial, "CASH.EXPENSES")
        end
        rothsteinSpawnCollectors()

        title("$MEGAMOD_ROTHSTEIN_short_title") --$ Short on the Marker
        text({"$MEGAMOD_ROTHSTEIN_short_text", partial}) --$ You empty the till -- ${0} -- and it isn't enough. The quiet man closes the satchel without a word, which is worse than anything he could say. "Mr. Rothstein regards a short payment as no payment. His collectors will call on you to discuss the balance." They already have. Word is a crew of leg-breakers is loitering outside your safehouse right now, and they aren't there for the scenery.
        option("$MEGAMOD_ROTHSTEIN_dismiss_short") --$ Get the boys ready.
    end
end

function rothsteinStiff()
    rothsteinSpawnCollectors()

    title("$MEGAMOD_ROTHSTEIN_stiff_title") --$ Nobody Stiffs the Brain
    text("$MEGAMOD_ROTHSTEIN_stiff_text") --$ "Take a walk," you say, and the quiet man does exactly that -- calmly, without argument, like a croupier clearing a losing bet. That's what worries you. By nightfall the word comes up from the street: a crew of out-of-town collectors is posted outside your safehouse, and they've been telling the neighborhood they're paid through the end of the month. Rothstein's arithmetic always balances. One way or the other.
    option("$MEGAMOD_ROTHSTEIN_dismiss_stiff") --$ Let them come.
end

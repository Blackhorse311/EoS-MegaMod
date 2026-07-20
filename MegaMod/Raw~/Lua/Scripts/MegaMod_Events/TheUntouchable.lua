--[[------------------------------------------------------------------------------
    MegaMod: The Untouchable
    Multi-week event chain. A new federal agent who can't be bought starts
    putting pressure on your empire. Three weeks of escalation, then a
    final decision.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    WEEK 1: The Warning
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_UNTOUCHABLE_WARNING"
_event = "MegaModUntouchableWarning"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_UNTCH_warn_title") --$ The Untouchable
    text("$MEGAMOD_UNTCH_warn_text") --$ Word travels fast in this city, and the word right now is bad. A new federal agent has been assigned to your district. Name's not important -- what's important is his reputation. Every gang in Detroit tried to buy him. Every gang in Detroit failed. He shut down three operations in his first month and put two bosses behind bars. They call him "The Untouchable" because nothing sticks to him -- no bribes, no threats, no favors. And now he's in Chicago, asking questions about you.
    option("$MEGAMOD_UNTCH_dismiss") --$ This could be trouble.

    untouchableStage = 1
    worldTimeCallback(triggerPressure, Utils:daysToSecs(7))
    complete()
end

function triggerPressure()
    WorldUtils:scheduleWithDelay("MegaModUntouchablePressure", 5, "TICK")
end

--[[------------------------------------------------------------------------------
    WEEK 2: The Pressure
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_UNTOUCHABLE_PRESSURE"
_event = "MegaModUntouchablePressure"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    -- Find the precinct where the player has the most buildings
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
        local precinctCounts = {}
        local bestPrecinct = nil
        local bestCount = 0

        for _, building in next, playerFaction.buildings do
            if building and building.precinct then
                local p = building.precinct
                precinctCounts[p] = (precinctCounts[p] or 0) + 1
                if precinctCounts[p] > bestCount then
                    bestCount = precinctCounts[p]
                    bestPrecinct = p
                end
            end
        end

        if bestPrecinct then
            Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                "alertKey", "MEGAMOD_UNTCH_PRESSURE",
                "appliedPoliceActivity", 20,
                "originalValue", 0,
                "effectId", "MEGAMOD_UNTOUCHABLE_PRESSURE",
                "precinct", bestPrecinct,
                "description", {"$Text", "Federal Agent Investigation"})
        end
    end

    setModal(true)
    title("$MEGAMOD_UNTCH_pressure_title") --$ The Pressure Mounts
    text("$MEGAMOD_UNTCH_pressure_text") --$ The Untouchable isn't wasting time. He's been making the rounds in your most profitable neighborhood, flashing his badge, asking questions, scaring your customers. The local cops are falling in line behind him -- nobody wants to be seen looking the other way when a fed is watching. Your businesses are feeling the squeeze. Revenue is down and your people are nervous.
    option("$MEGAMOD_UNTCH_dismiss") --$ He's making his move.

    untouchableStage = 2
    worldTimeCallback(triggerDecision, Utils:daysToSecs(7))
    complete()
end

function triggerDecision()
    WorldUtils:scheduleWithDelay("MegaModUntouchableDecision", 5, "TICK")
end

--[[------------------------------------------------------------------------------
    WEEK 3: The Decision
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_UNTOUCHABLE_DECISION"
_event = "MegaModUntouchableDecision"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_UNTCH_decide_title") --$ The Decision
    text("$MEGAMOD_UNTCH_decide_text") --$ It's been two weeks and The Untouchable is tightening the noose. Your lieutenants are looking to you for a plan. You've got three options, and none of them are great.
    option("$MEGAMOD_UNTCH_decide_dirt", digUpDirt) --$ Dig up dirt on him ($1500)
    option("$MEGAMOD_UNTCH_decide_laylow", layLow) --$ Lay low for a while
    option("$MEGAMOD_UNTCH_decide_ignore", ignoreIt) --$ Ignore it and hope he goes away
end

function digUpDirt()
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction.cash.count < 1500 then
        title("$MEGAMOD_UNTCH_dirt_broke_title") --$ Can't Afford It
        text("$MEGAMOD_UNTCH_dirt_broke_text") --$ You don't have $1500 to throw at private investigators and informants. The Untouchable keeps doing his thing, and you're left hoping for the best.
        option("$MEGAMOD_UNTCH_dismiss") --$ Damn.
        untouchableStage = 3
        complete()
        return
    end

    BRScript:PlayerSubtractCash(1500, "CASH.INVESTIGATION")

    if math.random() < 0.50 then
        -- Success: found skeletons
        title("$MEGAMOD_UNTCH_dirt_success_title") --$ Skeletons in the Closet
        text("$MEGAMOD_UNTCH_dirt_success_text") --$ Your investigators hit pay dirt. Turns out The Untouchable isn't so untouchable after all. A gambling debt from his college days, a questionable relationship with a witness in his Detroit cases, and some very interesting photographs from a hotel in Milwaukee. A manila envelope finds its way to his supervisor's desk. Two days later, The Untouchable is reassigned to a field office in Montana. Problem solved.
        option("$MEGAMOD_UNTCH_dismiss") --$ Everyone's got a price.
    else
        -- Failure: money wasted
        title("$MEGAMOD_UNTCH_dirt_fail_title") --$ Nothing Found
        text("$MEGAMOD_UNTCH_dirt_fail_text") --$ Your investigators come back empty-handed. The man really is clean -- no debts, no vices, no skeletons. He lives in a one-bedroom apartment, drives a Ford, and goes to church on Sundays. Your $1500 bought you nothing but confirmation that you're dealing with a genuine Boy Scout.
        option("$MEGAMOD_UNTCH_dismiss") --$ Money down the drain.
    end

    untouchableStage = 3
    complete()
end

function layLow()
    title("$MEGAMOD_UNTCH_laylow_title") --$ Laying Low
    text("$MEGAMOD_UNTCH_laylow_text") --$ You pull back operations, tell your people to keep their heads down, and wait. It's not glamorous, and it's not cheap -- lost revenue adds up fast. But sometimes the smart play is no play at all. Give the fed a few weeks of nothing to find, and maybe he'll move on to easier targets.
    option("$MEGAMOD_UNTCH_dismiss") --$ Patience.

    untouchableStage = 3
    worldTimeCallback(triggerAllClear, Utils:daysToSecs(14))
    complete()
end

function triggerAllClear()
    WorldUtils:scheduleWithDelay("MegaModUntouchableAllClear", 5, "TICK")
end

function ignoreIt()
    if math.random() < 0.40 then
        -- Raid: lose cash + more heat
        local playerFaction = WorldUtils:getPlayerFaction()
        if playerFaction.cash.count >= 1000 then
            BRScript:PlayerSubtractCash(1000, "CASH.FINE")
        end

        if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
            local building = playerFaction.buildings[1]
            if building and building.precinct then
                Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                    "alertKey", "MEGAMOD_UNTCH_RAID",
                    "appliedPoliceActivity", 30,
                    "originalValue", 0,
                    "effectId", "MEGAMOD_UNTOUCHABLE_RAID",
                    "precinct", building.precinct,
                    "description", {"$Text", "Federal Raid"})
            end
        end

        title("$MEGAMOD_UNTCH_ignore_raid_title") --$ The Raid
        text("$MEGAMOD_UNTCH_ignore_raid_text") --$ Ignoring The Untouchable was a mistake. He spent the last two weeks building an airtight case, and this morning he kicked down your door with a squad of federal agents. They seized $1000 in cash, smashed up your best operation, and arrested half your runners. The papers are calling it the biggest bust of the year. The Untouchable is a hero, and you're left picking up the pieces.
        option("$MEGAMOD_UNTCH_dismiss") --$ Should've taken this seriously.
    else
        -- He gets reassigned
        title("$MEGAMOD_UNTCH_ignore_gone_title") --$ Reassigned
        text("$MEGAMOD_UNTCH_ignore_gone_text") --$ Turns out you're not the only one who doesn't like The Untouchable. His own bosses in Washington think he's a showboat, and when he couldn't produce results fast enough, they pulled him off your case and sent him to chase moonshiners in Kentucky. Sometimes doing nothing is the right call. Sometimes you just get lucky.
        option("$MEGAMOD_UNTCH_dismiss") --$ I'll take it.
    end

    untouchableStage = 3
    complete()
end

--[[------------------------------------------------------------------------------
    ALL CLEAR EVENT (after laying low for 14 days)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_UNTOUCHABLE_ALLCLEAR"
_event = "MegaModUntouchableAllClear"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_UNTCH_allclear_title") --$ All Clear
    text("$MEGAMOD_UNTCH_allclear_text") --$ Your patience paid off. Two weeks of laying low and The Untouchable moved on to greener pastures -- or rather, greener speakeasies. Word is he's poking around the South Side now, giving someone else headaches. You can breathe easy and get back to business.
    option("$MEGAMOD_UNTCH_dismiss") --$ Back to work.
    complete()
end

--[[------------------------------------------------------------------------------
    UNTOUCHABLE MONITOR - Background listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_UNTOUCHABLE_MONITOR"
_event = "MegaModUntouchableMonitor"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 300
_category = "Misc"

persist{}
untouchableStage = 0

persist{}
untouchableCheckStarted = false

function canTrigger()
    return true
end

function onTrigger()
    complete()
end

function GameEvent.onWeekBegin(e)
    -- Only trigger initial event; subsequent stages use worldTimeCallback
    if untouchableStage ~= 0 then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    -- Require 5+ buildings
    local buildings = playerFaction.buildings
    if not buildings or #buildings < 5 then return end

    -- 12% chance per week once conditions are met
    if math.random() < 0.12 then
        WorldUtils:scheduleWithDelay("MegaModUntouchableWarning", 5, "TICK")
    end
end

--[[------------------------------------------------------------------------------
    MegaMod: Alderman System
    Purchase corrupt aldermen to reduce police activity in precincts.
    Aldermen require monthly upkeep and can be poached by rivals.

    All roster state lives in the persistent monitor block below (script vars
    are NOT shared across _id blocks). Dialog events receive their precinct id
    via scheduleWithDelay params and report outcomes back to the monitor
    through custom game events.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

local ALDERMAN_COST = 1000
local ALDERMAN_UPKEEP = 200
local ALDERMAN_MAX = 3
local OFFER_COOLDOWN_DAYS = 21
local UPKEEP_INTERVAL_DAYS = 28
local BUYOUT_INTERVAL_DAYS = 28
local OFFER_CHANCE = 0.30
local BUYOUT_CHANCE = 0.15
local BUYOUT_MATCH_COST = 500
local POLICE_REDUCTION = -15
local MIN_BUILDINGS_IN_PRECINCT = 3

--[[------------------------------------------------------------------------------
    Alderman Monitor - Background listener (owns all alderman state)
    MEGAMOD FIX: "Schedule" events are created inactive so GameEvent listeners
    never fired; converted to the Create-listener pattern (see HardModeBankroll).
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ALDERMAN_MONITOR"
_event = "MegaModAldermanMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
aldermanPrecincts = {} -- precinctId -> true

persist{}
aldermanCount = 0

persist{}
lastOfferTime = 0

persist{}
lastUpkeepTime = 0

persist{}
lastBuyoutCheckTime = 0

-- Safe as a local helper: touches no sandbox globals (WorldUtils etc. would be nil here)
local function countBuildingsInPrecinct(buildings, precinctId)
    local count = 0
    for i = 1, #buildings do
        local building = buildings[i]
        if building then
            local precinct = building:getPrecinct()
            if precinct and precinct.id == precinctId then
                count = count + 1
            end
        end
    end
    return count
end

function GameEvent.onWeekBegin(e)
    if worldTime < 250 then return end -- MEGAMOD FIX: preserves the old _triggerDelay = 250

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return end

    -- Weekly check 0: keep protection topped up while an alderman is held
    -- MEGAMOD FIX: temporary police activity decays, so the benefit must be
    -- re-applied weekly; it stops automatically once the precinct leaves the roster
    for precinctId in next, aldermanPrecincts do
        local precinct = WorldUtils:getPrecinct(precinctId)
        if precinct then
            precinct:addTemporaryPoliceActivity(POLICE_REDUCTION)
        end
    end

    -- Weekly check 1: Monthly upkeep
    if lastUpkeepTime == 0 then
        lastUpkeepTime = worldTime
    end
    if (worldTime - lastUpkeepTime) >= Utils:daysToSecs(UPKEEP_INTERVAL_DAYS) then
        lastUpkeepTime = worldTime
        processUpkeep(playerFaction)
    end

    -- Weekly check 2: Rival buyout attempt (monthly)
    if aldermanCount > 0 then
        if lastBuyoutCheckTime == 0 then
            lastBuyoutCheckTime = worldTime
        end
        if (worldTime - lastBuyoutCheckTime) >= Utils:daysToSecs(BUYOUT_INTERVAL_DAYS) then
            lastBuyoutCheckTime = worldTime
            checkBuyoutAttempt()
        end
    end

    -- Weekly check 3: New alderman offer
    if aldermanCount < ALDERMAN_MAX then
        if lastOfferTime == 0 or (worldTime - lastOfferTime) >= Utils:daysToSecs(OFFER_COOLDOWN_DAYS) then
            checkNewOffer(playerFaction)
        end
    end
end

function processUpkeep(playerFaction)
    if aldermanCount <= 0 then return end

    local totalUpkeep = aldermanCount * ALDERMAN_UPKEEP
    if playerFaction.cash.count >= totalUpkeep then
        BRScript:PlayerSubtractCash(totalUpkeep, "CASH.ALDERMAN_UPKEEP")
    else
        -- Can't afford, lose an alderman (removal from the roster also stops
        -- the weekly police reduction)
        local lostPrecinctId = next(aldermanPrecincts)
        if lostPrecinctId then
            aldermanPrecincts[lostPrecinctId] = nil
            aldermanCount = aldermanCount - 1
            WorldUtils:scheduleWithDelay("MegaModAldermanLost", 5, "TICK")
        end
    end
end

function checkBuyoutAttempt()
    -- For each alderman, BUYOUT_CHANCE to trigger
    for precinctId in next, aldermanPrecincts do
        if math.random() < BUYOUT_CHANCE then
            -- MEGAMOD FIX: precinct identity rides on the event itself (persisted param)
            WorldUtils:scheduleWithDelay("MegaModAldermanBuyout", 5, "TICK", "buyoutPrecinctId", precinctId)
            return -- One buyout attempt per check
        end
    end
end

function checkNewOffer(playerFaction)
    local buildings = playerFaction.buildings
    if not buildings or #buildings < MIN_BUILDINGS_IN_PRECINCT then return end

    -- Collect precincts where player has 3+ buildings and no alderman
    local candidates = {}
    local seenPrecincts = {}

    for i = 1, #buildings do
        local building = buildings[i]
        if building then
            local precinct = building:getPrecinct()
            if precinct and not seenPrecincts[precinct.id] and not aldermanPrecincts[precinct.id] then
                seenPrecincts[precinct.id] = true
                local count = countBuildingsInPrecinct(buildings, precinct.id)
                if count >= MIN_BUILDINGS_IN_PRECINCT then
                    candidates[#candidates + 1] = precinct
                end
            end
        end
    end

    if #candidates == 0 then return end

    -- Roll for offer
    if math.random() >= OFFER_CHANCE then return end

    local precinct = candidates[math.random(1, #candidates)]
    lastOfferTime = worldTime

    WorldUtils:scheduleWithDelay("MegaModAldermanOffer", 5, "TICK", "offerPrecinctId", precinct.id)
end

-- MEGAMOD FIX: dialog outcomes flow back to the monitor through custom game
-- events (the dialogs run in their own script instances and can't touch our vars)
function GameEvent.onMegaModAldermanBought(e)
    if not aldermanPrecincts[e.precinctId] then
        aldermanPrecincts[e.precinctId] = true
        aldermanCount = aldermanCount + 1
    end
end

function GameEvent.onMegaModAldermanRemoved(e)
    if aldermanPrecincts[e.precinctId] then
        aldermanPrecincts[e.precinctId] = nil
        aldermanCount = aldermanCount - 1
    end
end

--[[------------------------------------------------------------------------------
    Alderman Offer Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ALDERMAN_OFFER"
_event = "MegaModAldermanOffer"
_category = "Misc"

persist{}
offerPrecinctId = nil -- Expected Param

function canTrigger()
    return offerPrecinctId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_ALDER_offer_title") --$ Alderman Available
    text("$MEGAMOD_ALDER_offer_text") --$ A city alderman has quietly let it be known that he's open to an arrangement. For $1000, he'll look the other way in the precinct where you've been operating. Police activity would drop significantly while he's on your payroll. Of course, he'll expect a monthly retainer of $200 to keep things friendly.
    option("$MEGAMOD_ALDER_offer_buy", buyAlderman) --$ Put him on the payroll ($1000)
    option("$MEGAMOD_ALDER_offer_pass", passOnOffer) --$ Too rich for my blood
end

function buyAlderman()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < ALDERMAN_COST then
        title("$MEGAMOD_ALDER_broke_title") --$ Can't Afford It
        text("$MEGAMOD_ALDER_broke_text") --$ You don't have $1000 to grease the alderman's palm. He shrugs and says he'll find someone else who appreciates the value of political friendship.
        option("$MEGAMOD_ALDER_dismiss") --$ Noted.
        return
    end

    BRScript:PlayerSubtractCash(ALDERMAN_COST, "CASH.ALDERMAN_PURCHASE")
    Utils:raiseGameEvent("onMegaModAldermanBought", "precinctId", offerPrecinctId)

    -- Apply the police reduction immediately (the monitor keeps it topped up weekly)
    local precinct = WorldUtils:getPrecinct(offerPrecinctId)
    if precinct then
        precinct:addTemporaryPoliceActivity(POLICE_REDUCTION) -- MEGAMOD FIX: real effect; the game event below is only the UI toast
        Utils:raiseGameEvent("onPoliceActivityEffectApplied",
            "alertKey", "MEGAMOD_ALDERMAN_" .. tostring(offerPrecinctId),
            "appliedPoliceActivity", POLICE_REDUCTION,
            "originalValue", precinct:getPoliceActivity() or 0,
            "effectId", "MEGAMOD_ALDERMAN_PROTECTION",
            "precinct", precinct,
            "description", {"$Text", "Alderman Protection"})
    end

    title("$MEGAMOD_ALDER_bought_title") --$ Alderman Acquired
    text("$MEGAMOD_ALDER_bought_text") --$ The alderman pockets the cash with a practiced smile. "Pleasure doing business. I'll make some calls, and you'll notice the patrols thinning out real quick." Police activity in the precinct drops immediately. Just remember, he expects $200 a month to keep things that way.
    option("$MEGAMOD_ALDER_dismiss") --$ Worth every penny.
end

function passOnOffer()
    title("$MEGAMOD_ALDER_pass_title") --$ Opportunity Declined
    text("$MEGAMOD_ALDER_pass_text") --$ The alderman nods and slips back into the crowd. He'll find another buyer, and next time he might not come to you first. In Chicago, political friends are hard to come by and easy to lose.
    option("$MEGAMOD_ALDER_dismiss") --$ We'll manage.
end

--[[------------------------------------------------------------------------------
    Alderman Lost (can't afford upkeep)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ALDERMAN_LOST"
_event = "MegaModAldermanLost"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_ALDER_lost_title") --$ Alderman Walks
    text("$MEGAMOD_ALDER_lost_text") --$ Your alderman contact hasn't received his monthly payment and he's not happy about it. "No money, no favors," he says on his way out the door. Without his protection, the police will be back to their old habits in the precinct. You'll need to find and pay a new contact if you want the coverage back.
    option("$MEGAMOD_ALDER_dismiss") --$ Should've paid up.
end

--[[------------------------------------------------------------------------------
    Alderman Buyout - Rival tries to steal your alderman
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ALDERMAN_BUYOUT"
_event = "MegaModAldermanBuyout"
_category = "Misc"

persist{}
buyoutPrecinctId = nil -- Expected Param

function canTrigger()
    return buyoutPrecinctId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_ALDER_buyout_title") --$ Rival Wants Your Alderman
    text("$MEGAMOD_ALDER_buyout_text") --$ Word reaches you that a rival outfit is trying to outbid you for your alderman's loyalty. The politician is nothing if not practical, and he's entertaining their offer. You can match their price of $500 to keep him on your side, or let him go and save the cash.
    option("$MEGAMOD_ALDER_buyout_match", matchBuyout) --$ Match the offer ($500)
    option("$MEGAMOD_ALDER_buyout_lose", loseBuyout) --$ Let them have him
end

function matchBuyout()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < BUYOUT_MATCH_COST then
        title("$MEGAMOD_ALDER_buyout_broke_title") --$ Can't Match It
        text("$MEGAMOD_ALDER_buyout_broke_text") --$ You don't have the $500 to keep the alderman loyal. He tips his hat and walks to the other side. Your police protection in the precinct is gone.
        option("$MEGAMOD_ALDER_dismiss") --$ Damn.
        Utils:raiseGameEvent("onMegaModAldermanRemoved", "precinctId", buyoutPrecinctId)
        return
    end

    BRScript:PlayerSubtractCash(BUYOUT_MATCH_COST, "CASH.ALDERMAN_RETENTION")
    title("$MEGAMOD_ALDER_buyout_kept_title") --$ Alderman Retained
    text("$MEGAMOD_ALDER_buyout_kept_text") --$ You slide the alderman an extra $500 and remind him who butters his bread. He pockets the cash and makes a phone call. "Tell them I'm not available." Your precinct protection stays intact, but these little loyalty tests are getting expensive.
    option("$MEGAMOD_ALDER_dismiss") --$ Stay bought, pal.
end

function loseBuyout()
    Utils:raiseGameEvent("onMegaModAldermanRemoved", "precinctId", buyoutPrecinctId)
    title("$MEGAMOD_ALDER_buyout_gone_title") --$ Alderman Poached
    text("$MEGAMOD_ALDER_buyout_gone_text") --$ Your alderman switches sides without so much as a goodbye. Politicians -- loyal as a weathervane. The police will be back to full patrols in the precinct before the week is out.
    option("$MEGAMOD_ALDER_dismiss") --$ We'll deal with it.
end

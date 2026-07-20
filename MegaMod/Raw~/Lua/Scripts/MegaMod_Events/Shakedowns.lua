--[[------------------------------------------------------------------------------
    MegaMod: Protection Racket Shakedowns
    Recurring opportunity to extort businesses for quick cash.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Shakedown Monitor - permanent day counter with ~2 week cooldown
--------------------------------------------------------------------------------]]
-- MEGAMOD FIX: "TIME.WEEKLY" is not a valid slice id and complete() made the old
-- event one-shot. A Create-mode onDayBegin listener gives real 14-day recurrence.
_id = "MEGAMOD_SHAKEDOWN_MONITOR"
_event = "MegaModShakedownMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
lastShakedownTime = 0

function GameEvent.onDayBegin(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return end
    if #playerFaction.buildings < 3 then return end

    -- Cooldown: ~2 weeks
    local cooldownSeconds = Utils:daysToSecs(14)
    if lastShakedownTime > 0 and (worldTime - lastShakedownTime) < cooldownSeconds then
        return
    end

    -- 25% chance per day once off cooldown, so it doesn't fire like clockwork
    if math.random() < 0.25 then
        lastShakedownTime = worldTime
        WorldUtils:scheduleWithDelay("MegaModShakedown", 5, "TICK")
    end
end

--[[------------------------------------------------------------------------------
    Shakedown Offer
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SHAKEDOWN"
_event = "MegaModShakedown"
_category = "Misc"

function onTrigger()
    setModal(true)
    title("$MEGAMOD_SHAKE_title") --$ Shakedown Opportunity
    text("$MEGAMOD_SHAKE_text") --$ One of your enforcers reports that a business outside your territory is ripe for the picking. The owner's been doing well and doesn't have anyone watching his back. How do you want to handle it?
    option("$MEGAMOD_SHAKE_aggressive", aggressiveShakedown) --$ Send the heavies (high cash, high heat)
    option("$MEGAMOD_SHAKE_subtle", subtleShakedown) --$ Make them an offer they can't refuse (lower cash, low heat)
    option("$MEGAMOD_SHAKE_skip", skipShakedown) --$ Not worth the risk
end

-- MEGAMOD FIX: result pages must be separate events -- rebuilding this dialog after
-- complete() released the pooled event, so the result text never displayed.
function aggressiveShakedown()
    local cash = math.random(400, 800)
    BRScript:PlayerAddCash(cash, "CASH.MISSION_REWARD")

    -- MEGAMOD FIX: "high heat" is now real -- +5 temporary police activity (vanilla cop-kill scale, decays 2/week)
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
        local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
        local precinct = building and building:getPrecinct()
        if precinct then
            precinct:addTemporaryPoliceActivity(5)
        end
    end

    WorldUtils:triggerEvent("MegaModShakedownAggro", "cash", cash)
end

function subtleShakedown()
    local cash = math.random(100, 300)
    BRScript:PlayerAddCash(cash, "CASH.MISSION_REWARD")

    -- MEGAMOD FIX: "low heat" -- +1 temporary police activity
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
        local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
        local precinct = building and building:getPrecinct()
        if precinct then
            precinct:addTemporaryPoliceActivity(1)
        end
    end

    WorldUtils:triggerEvent("MegaModShakedownSubtle", "cash", cash)
end

function skipShakedown()
    WorldUtils:triggerEvent("MegaModShakedownSkip")
end

--[[------------------------------------------------------------------------------
    Shakedown Results
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SHAKEDOWN_AGGRO_RESULT"
_event = "MegaModShakedownAggro"
_category = "Misc"

persist{}
cash = 0

function onTrigger()
    title("$MEGAMOD_SHAKE_aggressive_title") --$ Heavies Sent
    text({"$MEGAMOD_SHAKE_aggressive_text", cash}) --$ Your boys paid the business a visit. After some persuasion -- the loud kind -- the owner handed over ${0}. The cops might come sniffing, and the local gang won't be happy about it.
    option("$MEGAMOD_SHAKE_dismiss") --$ Money's money.
end

_id = "MEGAMOD_SHAKEDOWN_SUBTLE_RESULT"
_event = "MegaModShakedownSubtle"
_category = "Misc"

persist{}
cash = 0

function onTrigger()
    title("$MEGAMOD_SHAKE_subtle_title") --$ Offer Made
    text({"$MEGAMOD_SHAKE_subtle_text", cash}) --$ A quiet conversation in the back office and ${0} finds its way into your pocket. No broken windows, no witnesses. The owner understands the arrangement.
    option("$MEGAMOD_SHAKE_dismiss") --$ Smooth.
end

_id = "MEGAMOD_SHAKEDOWN_SKIP_RESULT"
_event = "MegaModShakedownSkip"
_category = "Misc"

function onTrigger()
    title("$MEGAMOD_SHAKE_skip_title") --$ Passed On It
    text("$MEGAMOD_SHAKE_skip_text") --$ You let this one go. Sometimes restraint is its own reward -- and the cops won't be breathing down your neck over it.
    option("$MEGAMOD_SHAKE_dismiss") --$ Smart move.
end

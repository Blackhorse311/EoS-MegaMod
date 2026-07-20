--[[------------------------------------------------------------------------------
    MegaMod: Protection Racket Shakedowns
    Recurring opportunity to extort businesses for quick cash.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Shakedown Monitor - director-driven listener
--------------------------------------------------------------------------------]]
-- MEGAMOD DIRECTOR: cadence (daily 25% roll + own 14-day cooldown) now lives in
-- EventDirector.lua (registry: SHAKEDOWNS, cooldownDays 14). This block answers
-- director picks: pass when ineligible, launch when eligible.
_id = "MEGAMOD_SHAKEDOWN_MONITOR"
_event = "MegaModShakedownMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "SHAKEDOWNS" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "SHAKEDOWNS")
        return
    end
    if #playerFaction.buildings < 3 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "SHAKEDOWNS")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModShakedown", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "SHAKEDOWNS")
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
    local cash = math.floor(math.random(400, 800) * (fact.MegaModCfgPayout or 1)) -- MEGAMOD CONFIG: payout knob
    BRScript:PlayerAddCash(cash, "CASH.MISSION_REWARD")

    -- MEGAMOD FIX: "high heat" is now real -- +5 temporary police activity (vanilla cop-kill scale, decays 2/week)
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
        local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
        local precinct = building and building:getPrecinct()
        if precinct then
            precinct:addTemporaryPoliceActivity(math.max(1, math.floor(5 * (fact.MegaModCfgHeat or 1)))) -- MEGAMOD CONFIG: heat knob
        end
    end

    WorldUtils:triggerEvent("MegaModShakedownAggro", "cash", cash)
end

function subtleShakedown()
    local cash = math.floor(math.random(100, 300) * (fact.MegaModCfgPayout or 1)) -- MEGAMOD CONFIG: payout knob
    BRScript:PlayerAddCash(cash, "CASH.MISSION_REWARD")

    -- MEGAMOD FIX: "low heat" -- +1 temporary police activity
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
        local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
        local precinct = building and building:getPrecinct()
        if precinct then
            precinct:addTemporaryPoliceActivity(math.max(1, math.floor(1 * (fact.MegaModCfgHeat or 1)))) -- MEGAMOD CONFIG: heat knob
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

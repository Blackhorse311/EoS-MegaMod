--[[------------------------------------------------------------------------------
    MegaMod: Rival Provocations
    Rival factions periodically provoke the player with vandalism, threats,
    or roughing up crew. Player chooses how to respond.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Provocation Monitor - director-driven listener
--------------------------------------------------------------------------------]]
-- MEGAMOD DIRECTOR: cadence (weekly 25% roll + own 14-day cooldown) now lives in
-- EventDirector.lua (registry: RIVAL_PROVOCATION, cooldownDays 14). This block
-- answers director picks: pass when ineligible, launch when eligible.
_id = "MEGAMOD_PROVOCATION_MONITOR"
_event = "MegaModProvocationMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: Schedule-mode events are created inactive so GameEvent listeners never register; Create keeps the monitor alive (see HardModeBankroll.lua)
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "RIVAL_PROVOCATION" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "RIVAL_PROVOCATION")
        return
    end

    -- Need at least one known rival
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs or #knownGangs == 0 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "RIVAL_PROVOCATION")
        return
    end

    -- Collect active rivals
    local activeRivals = {}
    for i = 1, #knownGangs do
        if knownGangs[i]._active then
            activeRivals[#activeRivals + 1] = knownGangs[i]
        end
    end
    if #activeRivals == 0 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "RIVAL_PROVOCATION")
        return
    end

    -- Pick a random rival and provocation type (outcome rolls, not cadence)
    local rival = activeRivals[math.random(1, #activeRivals)]

    -- MEGAMOD FIX: persist{} vars are not shared across _id blocks; pass the rival and
    -- provocation type through the event payload (factions are identified by factionId)
    WorldUtils:scheduleWithDelay("MegaModProvocationEvent", 5, "TICK",
        "provocationRivalFactionId", rival.factionId,
        "provocationTypeIndex", math.random(1, 3))
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "RIVAL_PROVOCATION")
end

--[[------------------------------------------------------------------------------
    Provocation Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PROVOCATION_EVENT"
_event = "MegaModProvocationEvent"
_category = "Misc"

persist{}
provocationRivalFactionId = nil

persist{}
provocationTypeIndex = 0

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)

    if provocationTypeIndex == 1 then
        title("$MEGAMOD_PROVOC_vandal_title") --$ Vandalism!
        text("$MEGAMOD_PROVOC_vandal_text") --$ You wake up to find one of your storefronts trashed. Windows smashed, the inside torn apart, and a message scrawled on the wall: "Stay in your lane." A rival outfit is sending you a message.
    elseif provocationTypeIndex == 2 then
        title("$MEGAMOD_PROVOC_rough_title") --$ Crew Member Roughed Up
        text("$MEGAMOD_PROVOC_rough_text") --$ One of your boys stumbles in with a black eye and a busted lip. Says a group of thugs jumped him on his way back from a pickup. They made sure he knew which gang sent them.
    else
        title("$MEGAMOD_PROVOC_threat_title") --$ Threatening Message
        text("$MEGAMOD_PROVOC_threat_text") --$ A note arrives at your office, wrapped around a bullet. The message is short: "Next one won't come with a letter." Somebody's trying to rattle you.
    end

    option("$MEGAMOD_PROVOC_retaliate", retaliateOption) --$ Retaliate ($500)
    option("$MEGAMOD_PROVOC_threaten", threatenBack) --$ Threaten back (free)
    option("$MEGAMOD_PROVOC_slide", letItSlide) --$ Let it slide
end

-- MEGAMOD FIX: pages set inside option callbacks never display (the event window doesn't
-- re-render and the event auto-completes on option click), so results are shown as a
-- separate event like vanilla racket events do
function showProvocResult(titleKey, textKey)
    WorldUtils:scheduleWithDelay("MegaModProvocationResult", 5, "TICK", "resultTitle", titleKey, "resultText", textKey)
end

-- MEGAMOD FIX: faction lookup by factionId (factions have no .iid, so the old iid-based
-- lookup always returned nil)
function getProvocationRival()
    local rival = WorldUtils:getFactionByFactionId(provocationRivalFactionId)
    if rival and rival._active then
        return rival
    end
    return nil
end

function retaliateOption()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 500 then
        showProvocResult("$MEGAMOD_PROVOC_broke_title", "$MEGAMOD_PROVOC_broke_text") --$ Can't Afford It / You don't have $500 to fund a proper retaliation. Your boys look at you, waiting. Sometimes the wallet decides for you.
        return
    end

    BRScript:PlayerSubtractCash(500, "CASH.RETALIATION")

    -- MEGAMOD FIX: MOLE_DISCOVERED is a morale config, not a rating effect; AGGRESSIVE_BEHAVIOUR
    -- is the verified RatingEffects id for hitting back with violence
    local rival = getProvocationRival()
    if rival then
        rival.rating:applyEffect(playerFaction, "AGGRESSIVE_BEHAVIOUR")
    end

    -- 60% chance rival backs down, 40% escalates
    if math.random() < 0.60 then
        -- Rival backs down, but relations worsen
        showProvocResult("$MEGAMOD_PROVOC_ret_success_title", "$MEGAMOD_PROVOC_ret_success_text") --$ Message Received / Your boys hit back hard. Smashed up one of their joints and left a few bruises as souvenirs. Word gets back that the rival boss is fuming but told his crew to stand down. They got the message, but don't expect a Christmas card.
    else
        -- Escalation
        showProvocResult("$MEGAMOD_PROVOC_ret_fail_title", "$MEGAMOD_PROVOC_ret_fail_text") --$ Things Got Worse / Your crew hit them back, but it only made things worse. They retaliated the same night, torching one of your stash houses. This is turning into a real feud, and it's going to cost more before it's over.
    end
end

function threatenBack()
    -- 30% chance rival backs down
    if math.random() < 0.30 then
        -- MEGAMOD FIX: THREATENED is the verified RatingEffects id (was MOLE_DISCOVERED, a morale config)
        local rival = getProvocationRival()
        if rival then
            rival.rating:applyEffect(WorldUtils:getPlayerFaction(), "THREATENED")
        end
        showProvocResult("$MEGAMOD_PROVOC_thr_success_title", "$MEGAMOD_PROVOC_thr_success_text") --$ Words Were Enough / You sent your most intimidating enforcer to deliver a message in person. Something about the look in his eyes convinced them to back off. No blood spilled, no cash spent, and you kept your reputation intact.
    else
        showProvocResult("$MEGAMOD_PROVOC_thr_fail_title", "$MEGAMOD_PROVOC_thr_fail_text") --$ They Laughed It Off / Your threats fell on deaf ears. The rival crew thought it was funny, actually. You can hear them laughing from across town. Empty words without action behind them just make you look weak.
    end
end

function letItSlide()
    showProvocResult("$MEGAMOD_PROVOC_slide_title", "$MEGAMOD_PROVOC_slide_text") --$ Turning the Other Cheek / You swallow your pride and let it go. No point starting a war over a broken window or a bruised ego. Your crew doesn't love the decision, but they'll live. The rival gang will see it as weakness, though, and that's a currency you can't afford to lose.
end

--[[------------------------------------------------------------------------------
    Provocation Result Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PROVOCATION_RESULT"
_event = "MegaModProvocationResult"
_category = "Misc"

persist{}
resultTitle = nil

persist{}
resultText = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title(resultTitle)
    text(resultText)
    option("$MEGAMOD_PROVOC_dismiss")
end

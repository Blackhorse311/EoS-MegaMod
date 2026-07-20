--[[------------------------------------------------------------------------------
    MegaMod: Bootleg Hijacking
    Opportunity to ambush rival bootleg shipments for alcohol.
    Risk/reward scales with investment level.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Hijacking Monitor - director-driven listener
--------------------------------------------------------------------------------]]
-- MEGAMOD DIRECTOR: cadence (weekly 20% roll + own 21-day cooldown) now lives in
-- EventDirector.lua (registry: BOOTLEG_HIJACK, cooldownDays 14). This block
-- answers director picks: pass when ineligible, launch when eligible.
_id = "MEGAMOD_HIJACK_MONITOR"
_event = "MegaModHijackMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: Schedule-mode events are created inactive so GameEvent listeners never register; Create keeps the monitor alive (see HardModeBankroll.lua)
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BOOTLEG_HIJACK" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOOTLEG_HIJACK")
        return
    end

    -- Need at least one known rival
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs or #knownGangs == 0 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOOTLEG_HIJACK")
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
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOOTLEG_HIJACK")
        return
    end

    -- Pick a random rival for flavor text (outcome roll, not cadence)
    local rival = activeRivals[math.random(1, #activeRivals)]

    -- MEGAMOD FIX: persist{} vars are not shared across _id blocks; pass the rival through
    -- the event payload instead (factions are identified by factionId, they have no .iid)
    WorldUtils:scheduleWithDelay("MegaModHijackEvent", 5, "TICK", "hijackRivalFactionId", rival.factionId)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BOOTLEG_HIJACK")
end

--[[------------------------------------------------------------------------------
    Hijacking Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HIJACK_EVENT"
_event = "MegaModHijackEvent"
_category = "Misc"

persist{}
hijackRivalFactionId = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_HIJACK_title") --$ Bootleg Shipment Spotted
    text("$MEGAMOD_HIJACK_text") --$ One of your runners spotted a rival convoy moving hooch through your side of town. A couple of trucks, lightly guarded, rolling slow. If you move fast you could help yourself to their supply. The question is how much muscle to bring.
    option("$MEGAMOD_HIJACK_small", smallAmbush) --$ Small ambush ($300)
    option("$MEGAMOD_HIJACK_big", bigAmbush) --$ Big ambush ($600)
    option("$MEGAMOD_HIJACK_pass", passOnIt) --$ Pass
end

-- MEGAMOD FIX: pages set inside option callbacks never display (the event window doesn't
-- re-render and the event auto-completes on option click), so results are shown as a
-- separate event like vanilla racket events do
function showHijackResult(titleKey, textKey)
    WorldUtils:scheduleWithDelay("MegaModHijackResult", 5, "TICK", "resultTitle", titleKey, "resultText", textKey)
end

function smallAmbush()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 300 then
        showHijackResult("$MEGAMOD_HIJACK_broke_title", "$MEGAMOD_HIJACK_broke_text") --$ Can't Afford It / You can't scrape together enough cash to outfit even a small crew for the hit. The convoy rolls right past while you watch from the curb.
        return
    end

    BRScript:PlayerSubtractCash(300, "CASH.HIJACK_OPS")

    -- 60% success
    if math.random() < 0.60 then
        -- Gain some alcohol
        local amount = math.random(15, 25)
        local quality = math.random(1, 3)
        WorldUtils:addAlcoholToFaction(playerFaction, amount, quality) -- MEGAMOD FIX: getWorldLibs() is unreachable from the script sandbox
        showHijackResult("$MEGAMOD_HIJACK_small_win_title", "$MEGAMOD_HIJACK_small_win_text") --$ Quick and Clean / Your boys hit the tail truck and vanished before the lead driver even knew what happened. A few crates of hooch are now sitting in your warehouse. Not a bad morning's work.
    else
        -- Fail: lose the $300, nothing gained
        showHijackResult("$MEGAMOD_HIJACK_small_lose_title", "$MEGAMOD_HIJACK_small_lose_text") --$ Botched Job / The ambush went sideways. Your boys jumped too early, the drivers floored it, and the whole convoy got away. You're out $300 and have nothing to show for it but tire tracks and embarrassment.
    end
end

function bigAmbush()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 600 then
        showHijackResult("$MEGAMOD_HIJACK_broke_title", "$MEGAMOD_HIJACK_broke_text") --$ Can't Afford It
        return
    end

    BRScript:PlayerSubtractCash(600, "CASH.HIJACK_OPS")

    -- 80% success
    if math.random() < 0.80 then
        -- Gain more alcohol
        local amount = math.random(30, 50)
        local quality = math.random(2, 4)
        WorldUtils:addAlcoholToFaction(playerFaction, amount, quality) -- MEGAMOD FIX: getWorldLibs() is unreachable from the script sandbox
        showHijackResult("$MEGAMOD_HIJACK_big_win_title", "$MEGAMOD_HIJACK_big_win_text") --$ Cleaned Them Out / Your crew boxed in the entire convoy. Both trucks, every barrel, every crate. The drivers were smart enough not to argue with the hardware your boys were carrying. You've got enough hooch to keep your joints running for weeks.
    else
        -- Fail: lose $600 and rival relation worsens
        -- MEGAMOD FIX: MOLE_DISCOVERED is a morale config, not a rating effect; AMBUSHED is the
        -- verified RatingEffects id for getting hit by a player ambush
        local rival = WorldUtils:getFactionByFactionId(hijackRivalFactionId)
        if rival and rival._active then
            rival.rating:applyEffect(playerFaction, "AMBUSHED")
        end
        showHijackResult("$MEGAMOD_HIJACK_big_lose_title", "$MEGAMOD_HIJACK_big_lose_text") --$ Ambush Went Wrong / They were ready for you. The convoy was bait, and your crew walked right into a counter-ambush. You're out $600, a couple of your boys got roughed up, and the rival gang knows you tried to hit them. This will have consequences.
    end
end

function passOnIt()
    showHijackResult("$MEGAMOD_HIJACK_pass_title", "$MEGAMOD_HIJACK_pass_text") --$ Convoy Passes / You watch the trucks roll by and let them go. Not every opportunity is worth the risk. There'll be another shipment, and maybe next time the odds will be better.
end

--[[------------------------------------------------------------------------------
    Hijacking Result Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HIJACK_RESULT"
_event = "MegaModHijackResult"
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
    option("$MEGAMOD_HIJACK_dismiss")
end

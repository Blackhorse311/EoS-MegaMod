--[[------------------------------------------------------------------------------
    MegaMod: Bootleg Hijacking
    Opportunity to ambush rival bootleg shipments for alcohol.
    Risk/reward scales with investment level.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Hijacking Monitor - Background listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HIJACK_MONITOR"
_event = "MegaModHijackMonitor"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 200
_category = "Misc"

persist{}
lastHijackTime = 0

persist{}
hijackRivalIid = nil

local hijackCooldownDays = 21
local hijackChance = 0.20

function canTrigger()
    return true
end

function onTrigger()
    complete()
end

function GameEvent.onWeekBegin(e)
    -- Cooldown check
    if lastHijackTime > 0 and (worldTime - lastHijackTime) < Utils:daysToSecs(hijackCooldownDays) then
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    -- Need at least one known rival
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs or #knownGangs == 0 then return end

    -- Collect active rivals
    local activeRivals = {}
    for i = 1, #knownGangs do
        if knownGangs[i]._active then
            activeRivals[#activeRivals + 1] = knownGangs[i]
        end
    end
    if #activeRivals == 0 then return end

    -- Roll for trigger
    if math.random() >= hijackChance then return end

    -- Pick a random rival for flavor text
    local rival = activeRivals[math.random(1, #activeRivals)]
    hijackRivalIid = rival.iid
    lastHijackTime = worldTime

    WorldUtils:scheduleWithDelay("MegaModHijackEvent", 5, "TICK")
end

--[[------------------------------------------------------------------------------
    Hijacking Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HIJACK_EVENT"
_event = "MegaModHijackEvent"
_category = "Misc"

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

function smallAmbush()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 300 then
        title("$MEGAMOD_HIJACK_broke_title") --$ Can't Afford It
        text("$MEGAMOD_HIJACK_broke_text") --$ You can't scrape together enough cash to outfit even a small crew for the hit. The convoy rolls right past while you watch from the curb.
        option("$MEGAMOD_HIJACK_dismiss") --$ Next time.
        complete()
        return
    end

    BRScript:PlayerSubtractCash(300, "CASH.HIJACK_OPS")

    -- 60% success
    if math.random() < 0.60 then
        -- Gain some alcohol
        local amount = math.random(15, 25)
        local quality = math.random(1, 3)
        getWorldLibs().addAlcoholToFaction(playerFaction, amount, quality)
        title("$MEGAMOD_HIJACK_small_win_title") --$ Quick and Clean
        text("$MEGAMOD_HIJACK_small_win_text") --$ Your boys hit the tail truck and vanished before the lead driver even knew what happened. A few crates of hooch are now sitting in your warehouse. Not a bad morning's work.
        option("$MEGAMOD_HIJACK_dismiss") --$ That'll do.
    else
        -- Fail: lose the $300, nothing gained
        title("$MEGAMOD_HIJACK_small_lose_title") --$ Botched Job
        text("$MEGAMOD_HIJACK_small_lose_text") --$ The ambush went sideways. Your boys jumped too early, the drivers floored it, and the whole convoy got away. You're out $300 and have nothing to show for it but tire tracks and embarrassment.
        option("$MEGAMOD_HIJACK_dismiss") --$ Waste of money.
    end
    complete()
end

function bigAmbush()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 600 then
        title("$MEGAMOD_HIJACK_broke_title") --$ Can't Afford It
        text("$MEGAMOD_HIJACK_broke_text") --$ You can't scrape together enough cash to outfit even a small crew for the hit. The convoy rolls right past while you watch from the curb.
        option("$MEGAMOD_HIJACK_dismiss") --$ Next time.
        complete()
        return
    end

    BRScript:PlayerSubtractCash(600, "CASH.HIJACK_OPS")

    -- 80% success
    if math.random() < 0.80 then
        -- Gain more alcohol
        local amount = math.random(30, 50)
        local quality = math.random(2, 4)
        getWorldLibs().addAlcoholToFaction(playerFaction, amount, quality)
        title("$MEGAMOD_HIJACK_big_win_title") --$ Cleaned Them Out
        text("$MEGAMOD_HIJACK_big_win_text") --$ Your crew boxed in the entire convoy. Both trucks, every barrel, every crate. The drivers were smart enough not to argue with the hardware your boys were carrying. You've got enough hooch to keep your joints running for weeks.
        option("$MEGAMOD_HIJACK_dismiss") --$ Beautiful.
    else
        -- Fail: lose $600 and rival relation worsens
        local rival = getHijackRivalByIid(hijackRivalIid)
        if rival then
            rival.rating:applyEffect(playerFaction, "MOLE_DISCOVERED")
        end
        title("$MEGAMOD_HIJACK_big_lose_title") --$ Ambush Went Wrong
        text("$MEGAMOD_HIJACK_big_lose_text") --$ They were ready for you. The convoy was bait, and your crew walked right into a counter-ambush. You're out $600, a couple of your boys got roughed up, and the rival gang knows you tried to hit them. This will have consequences.
        option("$MEGAMOD_HIJACK_dismiss") --$ That was ugly.
    end
    complete()
end

function passOnIt()
    title("$MEGAMOD_HIJACK_pass_title") --$ Convoy Passes
    text("$MEGAMOD_HIJACK_pass_text") --$ You watch the trucks roll by and let them go. Not every opportunity is worth the risk. There'll be another shipment, and maybe next time the odds will be better.
    option("$MEGAMOD_HIJACK_dismiss") --$ Patience.
    complete()
end

function getHijackRivalByIid(iid)
    if not iid then return nil end
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return nil end
    for i = 1, #knownGangs do
        if knownGangs[i].iid == iid then
            return knownGangs[i]
        end
    end
    return nil
end

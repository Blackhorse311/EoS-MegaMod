--[[------------------------------------------------------------------------------
    MegaMod: Rival Provocations
    Rival factions periodically provoke the player with vandalism, threats,
    or roughing up crew. Player chooses how to respond.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Provocation Monitor - Background listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PROVOCATION_MONITOR"
_event = "MegaModProvocationMonitor"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 200
_category = "Misc"

persist{}
lastProvocationTime = 0

persist{}
provocationRivalIid = nil

persist{}
provocationTypeIndex = 0

local provocationCooldownDays = 14
local provocationChance = 0.25

function canTrigger()
    return true
end

function onTrigger()
    complete()
end

function GameEvent.onWeekBegin(e)
    -- Cooldown check
    if lastProvocationTime > 0 and (worldTime - lastProvocationTime) < Utils:daysToSecs(provocationCooldownDays) then
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
    if math.random() >= provocationChance then return end

    -- Pick a random rival and provocation type
    local rival = activeRivals[math.random(1, #activeRivals)]
    provocationRivalIid = rival.iid
    provocationTypeIndex = math.random(1, 3)
    lastProvocationTime = worldTime

    WorldUtils:scheduleWithDelay("MegaModProvocationEvent", 5, "TICK")
end

--[[------------------------------------------------------------------------------
    Provocation Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PROVOCATION_EVENT"
_event = "MegaModProvocationEvent"
_category = "Misc"

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

function retaliateOption()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 500 then
        title("$MEGAMOD_PROVOC_broke_title") --$ Can't Afford It
        text("$MEGAMOD_PROVOC_broke_text") --$ You don't have $500 to fund a proper retaliation. Your boys look at you, waiting. Sometimes the wallet decides for you.
        option("$MEGAMOD_PROVOC_dismiss") --$ Damn.
        complete()
        return
    end

    BRScript:PlayerSubtractCash(500, "CASH.RETALIATION")

    -- 60% chance rival backs down, 40% escalates
    if math.random() < 0.60 then
        -- Rival backs down, but relations worsen
        local rival = getRivalByIid(provocationRivalIid)
        if rival then
            rival.rating:applyEffect(playerFaction, "MOLE_DISCOVERED")
        end
        title("$MEGAMOD_PROVOC_ret_success_title") --$ Message Received
        text("$MEGAMOD_PROVOC_ret_success_text") --$ Your boys hit back hard. Smashed up one of their joints and left a few bruises as souvenirs. Word gets back that the rival boss is fuming but told his crew to stand down. They got the message, but don't expect a Christmas card.
        option("$MEGAMOD_PROVOC_dismiss") --$ That settles it.
    else
        -- Escalation
        local rival = getRivalByIid(provocationRivalIid)
        if rival then
            rival.rating:applyEffect(playerFaction, "MOLE_DISCOVERED")
        end
        title("$MEGAMOD_PROVOC_ret_fail_title") --$ Things Got Worse
        text("$MEGAMOD_PROVOC_ret_fail_text") --$ Your crew hit them back, but it only made things worse. They retaliated the same night, torching one of your stash houses. This is turning into a real feud, and it's going to cost more before it's over.
        option("$MEGAMOD_PROVOC_dismiss") --$ This isn't over.
    end
    complete()
end

function threatenBack()
    -- 30% chance rival backs down
    if math.random() < 0.30 then
        local rival = getRivalByIid(provocationRivalIid)
        if rival then
            rival.rating:applyEffect(WorldUtils:getPlayerFaction(), "MOLE_DISCOVERED")
        end
        title("$MEGAMOD_PROVOC_thr_success_title") --$ Words Were Enough
        text("$MEGAMOD_PROVOC_thr_success_text") --$ You sent your most intimidating enforcer to deliver a message in person. Something about the look in his eyes convinced them to back off. No blood spilled, no cash spent, and you kept your reputation intact.
        option("$MEGAMOD_PROVOC_dismiss") --$ Good enough.
    else
        title("$MEGAMOD_PROVOC_thr_fail_title") --$ They Laughed It Off
        text("$MEGAMOD_PROVOC_thr_fail_text") --$ Your threats fell on deaf ears. The rival crew thought it was funny, actually. You can hear them laughing from across town. Empty words without action behind them just make you look weak.
        option("$MEGAMOD_PROVOC_dismiss") --$ Should've hit harder.
    end
    complete()
end

function letItSlide()
    title("$MEGAMOD_PROVOC_slide_title") --$ Turning the Other Cheek
    text("$MEGAMOD_PROVOC_slide_text") --$ You swallow your pride and let it go. No point starting a war over a broken window or a bruised ego. Your crew doesn't love the decision, but they'll live. The rival gang will see it as weakness, though, and that's a currency you can't afford to lose.
    option("$MEGAMOD_PROVOC_dismiss") --$ Move on.
    complete()
end

function getRivalByIid(iid)
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

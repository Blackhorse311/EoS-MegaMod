--[[------------------------------------------------------------------------------
    MegaMod: Protection Racket Shakedowns
    Recurring opportunity to extort businesses for quick cash.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_SHAKEDOWN"
_event = "MegaModShakedown"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 250
_category = "Misc"
_slice = "TIME.WEEKLY"

persist{}
lastShakedownTime = 0

function canTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return false end
    if #playerFaction.buildings < 3 then return false end

    -- Cooldown: ~2 weeks
    local cooldownSeconds = Utils:daysToSecs(14)
    if lastShakedownTime > 0 and (worldTime - lastShakedownTime) < cooldownSeconds then
        return false
    end

    return true
end

function onTrigger()
    lastShakedownTime = worldTime
    setModal(true)
    title("$MEGAMOD_SHAKE_title") --$ Shakedown Opportunity
    text("$MEGAMOD_SHAKE_text") --$ One of your enforcers reports that a business outside your territory is ripe for the picking. The owner's been doing well and doesn't have anyone watching his back. How do you want to handle it?
    option("$MEGAMOD_SHAKE_aggressive", aggressiveShakedown) --$ Send the heavies (high cash, high heat)
    option("$MEGAMOD_SHAKE_subtle", subtleShakedown) --$ Make them an offer they can't refuse (lower cash, low heat)
    option("$MEGAMOD_SHAKE_skip", skipShakedown) --$ Not worth the risk
end

function aggressiveShakedown()
    local cash = math.random(400, 800)
    BRScript:PlayerAddCash(cash, "CASH.MISSION_REWARD")

    title("$MEGAMOD_SHAKE_aggressive_title") --$ Heavies Sent
    text({"$MEGAMOD_SHAKE_aggressive_text", cash}) --$ Your boys paid the business a visit. After some persuasion -- the loud kind -- the owner handed over ${0}. The cops might come sniffing, and the local gang won't be happy about it.
    option("$MEGAMOD_SHAKE_dismiss") --$ Money's money.
    complete()
end

function subtleShakedown()
    local cash = math.random(100, 300)
    BRScript:PlayerAddCash(cash, "CASH.MISSION_REWARD")

    title("$MEGAMOD_SHAKE_subtle_title") --$ Offer Made
    text({"$MEGAMOD_SHAKE_subtle_text", cash}) --$ A quiet conversation in the back office and ${0} finds its way into your pocket. No broken windows, no witnesses. The owner understands the arrangement.
    option("$MEGAMOD_SHAKE_dismiss") --$ Smooth.
    complete()
end

function skipShakedown()
    title("$MEGAMOD_SHAKE_skip_title") --$ Passed On It
    text("$MEGAMOD_SHAKE_skip_text") --$ You let this one go. Sometimes restraint is its own reward -- and the cops won't be breathing down your neck over it.
    option("$MEGAMOD_SHAKE_dismiss") --$ Smart move.
    complete()
end

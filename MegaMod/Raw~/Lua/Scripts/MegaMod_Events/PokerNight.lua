--[[------------------------------------------------------------------------------
    MegaMod: Table Stakes (EventDirector: POKER_NIGHT)
    An engraved invitation to a high-stakes game in the Rothstein style --
    hotel suite, thick carpets, out-of-town money and a rival outfit's people
    at the felt. Buy in light, buy in heavy, or keep your bankroll in your
    coat. Repeatable by design.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    POKER NIGHT LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_POKERNIGHT_LISTENER"
_event = "MegaModPokerNightListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "POKER_NIGHT" then return end

    -- No point sitting down without at least the light buy-in (scaled + clamped
    -- here exactly as the offer block computes it)
    local lowBuyIn = math.max(200, math.min(math.floor(500 * (fact.MegaModCfgCost or 1)), 1500))
    if not BRScript:PlayerCanAfford(lowBuyIn) then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "POKER_NIGHT")
        return
    end

    -- If a rival outfit is known, their people are at the table; otherwise the
    -- game is strictly out-of-town money (RivalProvocations rival selection)
    local playerFaction = WorldUtils:getPlayerFaction()
    local activeRivals = {}
    local knownGangs = playerFaction and playerFaction.diplomacy
            and playerFaction.diplomacy:getKnownGangs()
    if knownGangs then
        for i = 1, #knownGangs do
            if knownGangs[i]._active then
                activeRivals[#activeRivals + 1] = knownGangs[i]
            end
        end
    end

    if #activeRivals > 0 then
        local rival = activeRivals[math.random(#activeRivals)]
        WorldUtils:scheduleWithDelay("MegaModPokerNightOffer", 5, "TICK",
            "pokerNightRivalFactionId", rival.factionId,
            "pokerNightRivalName", rival.name)
    else
        WorldUtils:scheduleWithDelay("MegaModPokerNightOffer", 5, "TICK")
    end
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "POKER_NIGHT")
end

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

--[[------------------------------------------------------------------------------
    POKER NIGHT OFFER - the engraved invitation
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_POKERNIGHT_OFFER"
_event = "MegaModPokerNightOffer"
_category = "Misc"

persist{}
pokerNightRivalFactionId = nil -- Expected Param (nil = out-of-town money only)

persist{}
pokerNightRivalName = nil -- Expected Param (nil = out-of-town money only)

-- Buy-ins scaled by the config cost knob, clamped (charges only; winnings
-- scale by the payout knob and are never clamped)
function pokerNightLowBuyIn()
    return math.max(200, math.min(math.floor(500 * (fact.MegaModCfgCost or 1)), 1500))
end

function pokerNightHighBuyIn()
    return math.max(600, math.min(math.floor(1500 * (fact.MegaModCfgCost or 1)), 4500))
end

function pokerNightGetRival()
    local rival = pokerNightRivalFactionId
            and WorldUtils:getFactionByFactionId(pokerNightRivalFactionId)
    if rival and rival._active then
        return rival
    end
    return nil
end

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_POKERNIGHT_title") --$ Table Stakes
    if pokerNightRivalName then
        text({"$MEGAMOD_POKERNIGHT_rival_text", pokerNightRivalName}) --$ The invitation arrives by messenger boy in a starched collar: heavy cream card stock, engraved lettering, no names anywhere. But the messenger talks. A suite at the Metropole, tonight. The man running the game learned his trade dealing for Arnold Rothstein himself back east -- fresh decks every hour, a stickman in white gloves, and no gun comes past the coat check. Out-of-town money at the felt, big and quiet. And seats already spoken for by {0} -- their people will be playing, and they'll know your face the minute you sit down.
    else
        text("$MEGAMOD_POKERNIGHT_text") --$ The invitation arrives by messenger boy in a starched collar: heavy cream card stock, engraved lettering, no names anywhere. But the messenger talks. A suite at the Metropole, tonight. The man running the game learned his trade dealing for Arnold Rothstein himself back east -- fresh decks every hour, a stickman in white gloves, and no gun comes past the coat check. Strictly out-of-town money at the felt, the kind that arrives in a private car and leaves before the papers wake up. No local outfits, no local grudges. Just cards.
    end
    if BRScript:PlayerCanAfford(pokerNightLowBuyIn()) then
        option({"$MEGAMOD_POKERNIGHT_low", pokerNightLowBuyIn()}, pokerNightBuyInLow) --$ Buy in light (${0})
    end
    if BRScript:PlayerCanAfford(pokerNightHighBuyIn()) then
        option({"$MEGAMOD_POKERNIGHT_high", pokerNightHighBuyIn()}, pokerNightBuyInHigh) --$ Buy in heavy (${0})
    end
    option("$MEGAMOD_POKERNIGHT_decline", pokerNightDecline) --$ Not my table, not my night
end

-- MEGAMOD: pages set in option callbacks never display (pooled event completes on
-- click), so results run as a separate event. Rival name is only sent when the
-- text uses it (varargs must never carry a nil value).
function pokerNightShowResult(titleKey, textKey, amount, rivalName)
    if rivalName then
        WorldUtils:triggerEvent("MegaModPokerNightResult",
            "pokerNightResultTitle", titleKey,
            "pokerNightResultText", textKey,
            "pokerNightResultAmount", amount or 0,
            "pokerNightResultRivalName", rivalName)
    else
        WorldUtils:triggerEvent("MegaModPokerNightResult",
            "pokerNightResultTitle", titleKey,
            "pokerNightResultText", textKey,
            "pokerNightResultAmount", amount or 0)
    end
end

-- One hand of fate for either stake: 45% double up, 35% lose it, 20% win big
-- and the host outfit takes it personally
function pokerNightPlay(buyIn)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < buyIn then
        pokerNightShowResult("$MEGAMOD_POKERNIGHT_broke_title", "$MEGAMOD_POKERNIGHT_broke_text", buyIn) --$ Short Stack / Your bankroll can't cover the chair.
        return
    end
    BRScript:PlayerSubtractCash(buyIn, "CASH.GENERIC")

    local roll = math.random()
    if roll < 0.45 then
        local winnings = math.floor(2 * buyIn * (fact.MegaModCfgPayout or 1))
        BRScript:PlayerAddCash(winnings, "CASH.GENERIC")
        pokerNightShowResult("$MEGAMOD_POKERNIGHT_win_title", "$MEGAMOD_POKERNIGHT_win_text", winnings) --$ A Good Night's Work / Doubled up and out the door by three.
    elseif roll < 0.80 then
        pokerNightShowResult("$MEGAMOD_POKERNIGHT_lose_title", "$MEGAMOD_POKERNIGHT_lose_text", buyIn) --$ The Cards Ran Cold / The buy-in stays at the Metropole.
    else
        local winnings = math.floor(3 * buyIn * (fact.MegaModCfgPayout or 1))
        BRScript:PlayerAddCash(winnings, "CASH.GENERIC")
        local rival = pokerNightGetRival()
        if rival then
            -- The host outfit takes the beating personally (THREATENED, verified
            -- RatingEffects id, RivalProvocations pattern)
            rival.rating:applyEffect(WorldUtils:getPlayerFaction(), "THREATENED")
            pokerNightShowResult("$MEGAMOD_POKERNIGHT_bigwin_rival_title", "$MEGAMOD_POKERNIGHT_bigwin_rival_text", winnings, rival.name) --$ Cleaned Them Out / Tripled up -- and the hosts didn't clap.
        else
            pokerNightShowResult("$MEGAMOD_POKERNIGHT_bigwin_title", "$MEGAMOD_POKERNIGHT_bigwin_text", winnings) --$ The Night of Nights / Tripled up against the out-of-town money.
        end
    end
end

function pokerNightBuyInLow()
    pokerNightPlay(pokerNightLowBuyIn())
end

function pokerNightBuyInHigh()
    pokerNightPlay(pokerNightHighBuyIn())
end

function pokerNightDecline()
    pokerNightShowResult("$MEGAMOD_POKERNIGHT_decline_title", "$MEGAMOD_POKERNIGHT_decline_text", 0) --$ Fold Before the Deal / The card goes in the fire and the bankroll stays home.
end

--[[------------------------------------------------------------------------------
    POKER NIGHT RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_POKERNIGHT_RESULT"
_event = "MegaModPokerNightResult"
_category = "Misc"

persist{}
pokerNightResultTitle = nil

persist{}
pokerNightResultText = nil

persist{}
pokerNightResultAmount = 0

persist{}
pokerNightResultRivalName = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title(pokerNightResultTitle)
    text({pokerNightResultText, pokerNightResultAmount, pokerNightResultRivalName})
    option("$MEGAMOD_POKERNIGHT_dismiss") --$ Never play cards with a man called Doc.
end

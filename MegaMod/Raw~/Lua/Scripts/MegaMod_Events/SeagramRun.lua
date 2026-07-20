--[[------------------------------------------------------------------------------
    MegaMod: Seagram Run (The Bronfman Special)
    Director event "SEAGRAM_RUN". A broker for the Bronfman distilleries offers
    a clean, guaranteed bulk import of Canadian whisky across the Windsor-Detroit
    funnel. No risk, no drama -- the price IS the catch. RUM_ROW's sober cousin.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    SEAGRAM RUN LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SEAGRAM_LISTENER"
_event = "MegaModSeagramListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "SEAGRAM_RUN" then return end

    -- Must at least be able to afford the half order
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not BRScript:PlayerCanAfford(math.floor(1600 * (fact.MegaModCfgCost or 1))) then -- MEGAMOD CONFIG: cost knob (paired with the half-order charge)
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "SEAGRAM_RUN")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModSeagramOffer", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "SEAGRAM_RUN")
end

--[[------------------------------------------------------------------------------
    SEAGRAM OFFER
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SEAGRAM_OFFER"
_event = "MegaModSeagramOffer"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_SEAGRAM_title") --$ The Bronfman Special
    text("$MEGAMOD_SEAGRAM_text") --$ The man who calls on you wears a banker's suit and carries a leather portfolio instead of a heater. He represents "certain distilling interests" in Canada -- the Bronfman family's operation, the biggest legal whisky business on the continent. "Our product is exported in full compliance with Canadian law," he says, laying out papers stamped for Havana. "Where the boats turn after Windsor is, of course, their own affair." No hijackings, no cutters, no bathtub swill: bonded Canadian rye, aged in oak, delivered in three days like clockwork. The price is steep because the product is real. That's the whole catch.
    if BRScript:PlayerCanAfford(math.floor(3000 * (fact.MegaModCfgCost or 1))) then -- MEGAMOD CONFIG: cost knob (paired with the charge in seagramBuyFull)
        option("$MEGAMOD_SEAGRAM_full", seagramBuyFull) --$ The full order ($3,000)
    end
    option("$MEGAMOD_SEAGRAM_half", seagramBuyHalf) --$ A half order ($1,600)
    option("$MEGAMOD_SEAGRAM_decline", seagramDecline) --$ Too rich for my blood
end

-- MEGAMOD: result pages must be separate events (pooled event auto-completes on
-- option click, pages set in callbacks never display -- see FedRaids/Moonshiners)
function seagramShowResult(titleKey, textKey)
    WorldUtils:triggerEvent("MegaModSeagramResult", "resultTitle", titleKey, "resultText", textKey)
end

function seagramBuyFull()
    local cost = math.floor(3000 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < cost then
        seagramShowResult("$MEGAMOD_SEAGRAM_broke_title", "$MEGAMOD_SEAGRAM_broke_text") --$ Insufficient Funds / The broker glances at the bankroll and closes his portfolio with a soft click. "Perhaps when your circumstances improve." He leaves a card with no name on it, only a Montreal exchange.
        return
    end
    BRScript:PlayerSubtractCash(cost, "CASH.TRADE")
    WorldUtils:scheduleWithDelay("MegaModSeagramDelivery", Utils:daysToSecs(3), "TICK", "seagramFullOrder", true)
    seagramShowResult("$MEGAMOD_SEAGRAM_ordered_title", "$MEGAMOD_SEAGRAM_ordered_text") --$ Order Placed / The broker writes out a receipt in a neat clerk's hand -- an honest-to-goodness receipt, like you'd bought a davenport. "Three days. The freight crosses at Windsor, comes down by rail as 'machine parts,' and is trucked to your door." He shakes your hand like a banker closing a mortgage. It's the most respectable crime you've ever committed.
end

function seagramBuyHalf()
    local cost = math.floor(1600 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < cost then
        seagramShowResult("$MEGAMOD_SEAGRAM_broke_title", "$MEGAMOD_SEAGRAM_broke_text")
        return
    end
    BRScript:PlayerSubtractCash(cost, "CASH.TRADE")
    WorldUtils:scheduleWithDelay("MegaModSeagramDelivery", Utils:daysToSecs(3), "TICK", "seagramFullOrder", false)
    seagramShowResult("$MEGAMOD_SEAGRAM_ordered_title", "$MEGAMOD_SEAGRAM_ordered_text")
end

function seagramDecline()
    seagramShowResult("$MEGAMOD_SEAGRAM_declined_title", "$MEGAMOD_SEAGRAM_declined_text") --$ No Sale / The broker takes it without a flicker, the way rich men take everything. "The offer stands whenever your ledger allows." He settles his hat, steps over a drunk on your doorstep without looking down, and is gone. Somewhere north of the border, an ocean of good whisky rolls on without you.
end

--[[------------------------------------------------------------------------------
    SEAGRAM DELIVERY - 3 days, guaranteed, right on the timetable
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SEAGRAM_DELIVERY"
_event = "MegaModSeagramDelivery"
_category = "Misc"

persist{}
seagramFullOrder = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    local playerFaction = WorldUtils:getPlayerFaction()
    local amount = seagramFullOrder and math.random(45, 60) or math.random(22, 30)
    if playerFaction then
        WorldUtils:addAlcoholToFaction(playerFaction, amount, 6) -- type 6 = ALCOHOL.WHISKEY
    end

    title("$MEGAMOD_SEAGRAM_delivery_title") --$ Right on the Timetable
    text({"$MEGAMOD_SEAGRAM_delivery_text", amount}) --$ Three days to the hour, a freight truck marked "Dominion Machine Parts" backs up to your warehouse. The crates come off clean and stenciled, and inside sit {0} barrels of bonded Canadian rye -- aged, sealed, and smooth as a hymn. No cutters, no hijackers, no funerals. Just whisky, exactly as promised. You begin to understand how the Bronfmans got rich enough to wear banker's suits.
    option("$MEGAMOD_SEAGRAM_dismiss") --$ Clockwork.
end

--[[------------------------------------------------------------------------------
    SEAGRAM RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SEAGRAM_RESULT"
_event = "MegaModSeagramResult"
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
    option("$MEGAMOD_SEAGRAM_dismiss")
end

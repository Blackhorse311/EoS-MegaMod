--[[------------------------------------------------------------------------------
    MegaMod: Rum Row (The Real McCoy)
    Director event "RUM_ROW". An agent for Bill McCoy's outfit offers a premium
    shipment of unwatered liquor landed via the Great Lakes. Buy the full lot or
    a half share; delivery lands in 2 days with a Coast Guard seizure risk.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    RUM ROW LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_RUMROW_LISTENER"
_event = "MegaModRumRowListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "RUM_ROW" then return end

    -- Must at least be able to afford the half share for the pitch to make sense
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not BRScript:PlayerCanAfford(1200) then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "RUM_ROW")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModRumRowOffer", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "RUM_ROW")
end

--[[------------------------------------------------------------------------------
    RUM ROW OFFER
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_RUMROW_OFFER"
_event = "MegaModRumRowOffer"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_RUMROW_title") --$ The Real McCoy
    text("$MEGAMOD_RUMROW_text") --$ A sunburned character in a pea coat finds you at the bar and talks low. Says he books freight for Bill McCoy -- THE McCoy, the skipper who anchors his schooner out past the three-mile limit where the law can't lay a finger on him. "Every bottle straight off the boat. Never cut, never watered, never touched. The real McCoy, friend -- that's where the sayin' comes from. We ran a load down through the Lakes and it's sitting in a boathouse as we speak. Cash on the barrelhead, and it's yours in two days."
    -- Only show what the bankroll can cover (FedRaids conditional-option pattern)
    if BRScript:PlayerCanAfford(2500) then
        option("$MEGAMOD_RUMROW_full", rumRowBuyFull) --$ Buy the whole lot ($2,500)
    end
    option("$MEGAMOD_RUMROW_half", rumRowBuyHalf) --$ Take a half share ($1,200)
    option("$MEGAMOD_RUMROW_decline", rumRowDecline) --$ Not buying today
end

-- MEGAMOD: result pages must be separate events (pooled event auto-completes on
-- option click, pages set in callbacks never display -- see FedRaids/Moonshiners)
function rumRowShowResult(titleKey, textKey)
    WorldUtils:triggerEvent("MegaModRumRowResult", "resultTitle", titleKey, "resultText", textKey)
end

function rumRowBuyFull()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 2500 then
        rumRowShowResult("$MEGAMOD_RUMROW_broke_title", "$MEGAMOD_RUMROW_broke_text") --$ Light in the Pocket / You count out the roll and come up short. The agent sniffs, buttons his coat, and heads for the door. "McCoy don't do credit, friend. Nothing personal."
        return
    end
    BRScript:PlayerSubtractCash(2500, "CASH.TRADE")
    -- Seizure roll happens on delivery day; pass the lot size to the delivery event
    WorldUtils:scheduleWithDelay("MegaModRumRowDelivery", Utils:daysToSecs(2), "TICK", "rumRowHalfLot", false)
    rumRowShowResult("$MEGAMOD_RUMROW_deal_title", "$MEGAMOD_RUMROW_deal_text") --$ Cash on the Barrelhead / The agent thumbs through the bills once, nods, and makes them disappear into his coat. "Smart money. The boys will run it in by night boat -- two days, no lights, no noise. Keep a warehouse door open." He tips his cap and is gone before the ice melts in your glass.
end

function rumRowBuyHalf()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 1200 then
        rumRowShowResult("$MEGAMOD_RUMROW_broke_title", "$MEGAMOD_RUMROW_broke_text")
        return
    end
    BRScript:PlayerSubtractCash(1200, "CASH.TRADE")
    WorldUtils:scheduleWithDelay("MegaModRumRowDelivery", Utils:daysToSecs(2), "TICK", "rumRowHalfLot", true)
    rumRowShowResult("$MEGAMOD_RUMROW_deal_title", "$MEGAMOD_RUMROW_deal_text")
end

function rumRowDecline()
    rumRowShowResult("$MEGAMOD_RUMROW_declined_title", "$MEGAMOD_RUMROW_declined_text") --$ No Sale / The agent shrugs like a man who has heard it before. "Suit yourself. There's a fella on the South Side who won't be so choosy." He drains his coffee, leaves a nickel on the bar, and walks out into the wind.
end

--[[------------------------------------------------------------------------------
    RUM ROW DELIVERY - 2 days later; 80% landed, 20% Coast Guard seizure
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_RUMROW_DELIVERY"
_event = "MegaModRumRowDelivery"
_category = "Misc"

persist{}
rumRowHalfLot = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    local playerFaction = WorldUtils:getPlayerFaction()

    if math.random() < 0.80 then
        -- Landed: large batch of premium, uncut liquor (alcohol type 5 = ALCOHOL.PREMIUM)
        local amount = rumRowHalfLot and math.random(28, 38) or math.random(55, 75)
        if playerFaction then
            WorldUtils:addAlcoholToFaction(playerFaction, amount, 5)
        end
        title("$MEGAMOD_RUMROW_landed_title") --$ Straight Off the Boat
        text({"$MEGAMOD_RUMROW_landed_text", amount}) --$ The night boat came in quiet as a church. Your boys rolled {0} barrels of the good stuff into the warehouse before sunup -- top-shelf liquor, never cut, never watered. One taste and there's no arguing: that's the real McCoy. Your joints will be pouring the best hooch in Chicago this week.
    else
        -- Seized: partial refund, small heat
        local refund = rumRowHalfLot and 500 or 1000
        BRScript:PlayerAddCash(refund, "CASH.TRADE")
        if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
            local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
            local precinct = building and building:getPrecinct()
            if precinct then
                precinct:addTemporaryPoliceActivity(5) -- small heat; decays over time
            end
        end
        title("$MEGAMOD_RUMROW_seized_title") --$ The Cutter Got 'Em
        text({"$MEGAMOD_RUMROW_seized_text", refund}) --$ Bad news rides a fast boat. A Coast Guard cutter ran down the load off the breakwater -- every barrel confiscated, the crew scattered into the reeds. McCoy's agent comes around looking sick and presses ${0} back into your hand "as a courtesy of the house." Worse, a federal man wrote your name in a little black book, and now there's extra blue wool walking your streets.
    end
    option("$MEGAMOD_RUMROW_dismiss") --$ That's the rum business.
end

--[[------------------------------------------------------------------------------
    RUM ROW RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_RUMROW_RESULT"
_event = "MegaModRumRowResult"
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
    option("$MEGAMOD_RUMROW_dismiss")
end

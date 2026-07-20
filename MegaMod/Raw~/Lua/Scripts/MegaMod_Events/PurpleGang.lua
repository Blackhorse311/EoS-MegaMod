--[[------------------------------------------------------------------------------
    MegaMod: Purple Gang (Purple Reign)
    Director event "PURPLE_GANG". An emissary of Detroit's Purple Gang demands
    you buy THEIR whiskey. Sign on for three weekly deliveries, refuse politely
    and risk a hijacking, or insult them and fight their torpedoes in the street.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    PURPLE GANG LISTENER - permanent director handshake + street-ambush lifecycle
    (squad refs persist fine in WORLD_EVENTS blocks -- vanilla TwistOfFateEvent
    persists ambushSquad the same way)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PURPLEGANG_LISTENER"
_event = "MegaModPurpleGangListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
purpleGangSquad = nil

persist{}
purpleGangSquadTime = 0

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "PURPLE_GANG" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    -- Need a building for the ambush option to have a street to happen on,
    -- and no leftover Purple squad still prowling from a previous visit
    if not playerFaction or not playerFaction.buildings
            or #playerFaction.buildings == 0 or purpleGangSquad then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "PURPLE_GANG")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModPurpleGangOffer", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "PURPLE_GANG")
end

-- Raised by the offer dialog's insult option (dialog blocks can't share squad
-- state with this block, so the spawn happens here where the ref can persist)
function GameEvent.onMegaModPurpleGangAmbush(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings or #playerFaction.buildings == 0 then return end

    local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
    if not building then return end

    -- Street thugs outside a player building (Capone-mission exterior pattern:
    -- building:getLocationId() = street the building sits on; guard + guardIfFlee)
    local squad = MissionUtils:spawnSquad(5, nil, nil, 4)
    if not squad then return end
    local pos = building:getInteractionPos3D()
    MissionUtils:placeSquad(squad, building:getLocationId(), pos, nil, true, pos, true)
    purpleGangSquad = squad
    purpleGangSquadTime = worldTime
end

function GameEvent.onDayBegin(e)
    if not purpleGangSquad then return end

    if MissionUtils:isSquadDead(purpleGangSquad) then
        -- FACTION.THUGS fight: no faction war, no notoriety -- just their bankroll
        purpleGangSquad = nil
        BRScript:PlayerAddCash(800, "CASH.LOOT")
        WorldUtils:triggerEvent("MegaModPurpleGangLoot")
    elseif (worldTime - purpleGangSquadTime) > Utils:daysToSecs(30) then
        -- Nobody took the bait; the torpedoes get bored and catch a train home
        MissionUtils:makeSquadLeave(purpleGangSquad)
        purpleGangSquad = nil
    end
end

--[[------------------------------------------------------------------------------
    PURPLE GANG OFFER
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PURPLEGANG_OFFER"
_event = "MegaModPurpleGangOffer"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_PURPLEGANG_title") --$ Purple Reign
    text("$MEGAMOD_PURPLEGANG_text") --$ Two men in good coats walk into your office like they own the deed. The talker introduces himself as a friend of the Bernstein brothers -- the Purple Gang, out of Detroit. "Every drop of Old Log Cabin that crosses the river comes through us. The Little Jewish Navy runs it over, we move it, and smart operators buy it. Capone buys from us 'stead of fighting us, and Capone ain't a man who scares easy. Fifteen hundred buys you in: three weeks, three deliveries, the best Canadian whiskey money can float." He smiles with all his teeth. "And fellas who buy from us don't get hijacked. Funny how that works."
    if BRScript:PlayerCanAfford(1500) then
        option("$MEGAMOD_PURPLEGANG_sign", purpleGangSign) --$ Sign on ($1,500)
    end
    option("$MEGAMOD_PURPLEGANG_refuse", purpleGangRefuse) --$ Decline, politely
    option("$MEGAMOD_PURPLEGANG_insult", purpleGangInsult) --$ Tell Detroit where to stick it
end

-- MEGAMOD: result pages must be separate events (pooled event auto-completes on
-- option click, pages set in callbacks never display -- see FedRaids/Moonshiners)
function purpleGangShowResult(titleKey, textKey)
    WorldUtils:triggerEvent("MegaModPurpleGangResult", "resultTitle", titleKey, "resultText", textKey)
end

function purpleGangSign()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 1500 then
        purpleGangShowResult("$MEGAMOD_PURPLEGANG_broke_title", "$MEGAMOD_PURPLEGANG_broke_text") --$ Short Count / You come up light, and the talker's smile goes thin while his partner counts the ceiling tiles. "Tell you what -- we'll come back when you're a serious operation." They leave without shaking hands.
        return
    end
    BRScript:PlayerSubtractCash(1500, "CASH.TRADE")
    WorldUtils:scheduleWithDelay("MegaModPurpleGangDelivery", Utils:daysToSecs(7), "TICK", "purpleDeliveriesLeft", 3)
    purpleGangShowResult("$MEGAMOD_PURPLEGANG_signed_title", "$MEGAMOD_PURPLEGANG_signed_text") --$ Deal Inked / The talker folds your money away like it was always his. "Pleasure doing business. First truck's a week out -- Old Log Cabin, right off the river, still smelling of Canada." At the door he pauses. "You just bought more than whiskey, friend. You bought peace of mind." You almost believe him.
end

function purpleGangRefuse()
    -- 40% they make an example of you next week (rolled now, delivered later --
    -- the delayed event queue is save-persisted, see BlackSoxFixer)
    if math.random() < 0.40 then
        WorldUtils:scheduleWithDelay("MegaModPurpleGangHijack", Utils:daysToSecs(7), "TICK")
    end
    purpleGangShowResult("$MEGAMOD_PURPLEGANG_refused_title", "$MEGAMOD_PURPLEGANG_refused_text") --$ No Hard Feelings / You keep it civil: the shelves are full, the ledger's tight, maybe another season. The talker takes it with a nod that doesn't reach his eyes. "Sure, sure. Business is business." His partner looks you over once, slow, like he's pricing a truck. They see themselves out. Something about it sits crooked in your gut all day.
end

function purpleGangInsult()
    -- The Purples answer insults in the street: raise to the listener block,
    -- which owns the squad ref (script vars are not shared across _id blocks)
    Utils:raiseGameEvent("onMegaModPurpleGangAmbush")
    purpleGangShowResult("$MEGAMOD_PURPLEGANG_insult_title", "$MEGAMOD_PURPLEGANG_insult_text") --$ Fighting Words / You tell him exactly what Chicago thinks of Detroit muscle, in language that would make a dock foreman blush. The talker's smile never moves. "That's a shame," he says, and puts on his hat. "Fellas work hard, come all this way..." Word comes within the hour: Purple torpedoes are loitering outside one of your places, heaters under their coats, waiting. If your crew puts them down, whatever's in their pockets is yours.
end

--[[------------------------------------------------------------------------------
    PURPLE GANG DELIVERY - weekly chain of 3 (BlackSoxFixer scheduleWithDelay chain)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PURPLEGANG_DELIVERY"
_event = "MegaModPurpleGangDelivery"
_category = "Misc"

persist{}
purpleDeliveriesLeft = 0

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    local playerFaction = WorldUtils:getPlayerFaction()
    local amount = math.random(15, 25)
    if playerFaction then
        WorldUtils:addAlcoholToFaction(playerFaction, amount, 4) -- type 4 = ALCOHOL.TOP_SHELF
    end

    title("$MEGAMOD_PURPLEGANG_delivery_title") --$ The Log Cabin Express
    if purpleDeliveriesLeft > 1 then
        WorldUtils:scheduleWithDelay("MegaModPurpleGangDelivery", Utils:daysToSecs(7), "TICK", "purpleDeliveriesLeft", purpleDeliveriesLeft - 1)
        text({"$MEGAMOD_PURPLEGANG_delivery_text", amount}) --$ A truck with Michigan plates backs up to your warehouse at dawn and two quiet men unload {0} barrels of Old Log Cabin whiskey -- the good Canadian article, same as Capone pours. The driver touches his cap. "Same time next week." Then the truck is gone, headed back east toward the river.
    else
        text({"$MEGAMOD_PURPLEGANG_delivery_final_text", amount}) --$ The last truck rolls in and {0} barrels of Old Log Cabin come off the tailgate. The driver hands you a scrap of paper with a Detroit exchange written on it. "That squares us. The Bernsteins say you're all right -- for a Chicago man. Ring that number if you ever want back in." The Purple pipeline runs dry, but your shelves are singing.
    end
    option("$MEGAMOD_PURPLEGANG_dismiss") --$ Business is business.
end

--[[------------------------------------------------------------------------------
    PURPLE GANG HIJACK - the price of a polite refusal
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PURPLEGANG_HIJACK"
_event = "MegaModPurpleGangHijack"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    local playerFaction = WorldUtils:getPlayerFaction()
    local loss = 0
    if playerFaction and playerFaction.alcohol then
        loss = math.floor(playerFaction.alcohol.stored * 0.20)
        if loss > 0 then
            playerFaction.alcohol:dump(nil, loss) -- FedRaids confiscation pattern
        end
    end

    -- A rival gang tipped the Purples off about your shipment schedule;
    -- relations sour (THREATENED = verified small RatingEffects id)
    local tipster = nil
    if playerFaction then
        local knownGangs = playerFaction.diplomacy:getKnownGangs()
        if knownGangs then
            local activeRivals = {}
            for _, faction in next, knownGangs do
                if faction and faction._active then
                    activeRivals[#activeRivals + 1] = faction
                end
            end
            if #activeRivals > 0 then
                tipster = activeRivals[math.random(#activeRivals)]
                tipster.rating:applyEffect(playerFaction, "THREATENED")
            end
        end
    end

    title("$MEGAMOD_PURPLEGANG_hijack_title") --$ Hijacked!
    if tipster then
        text({"$MEGAMOD_PURPLEGANG_hijack_text", loss, tipster.name}) --$ It happens the way it always happens: a truck full of your hooch takes a wrong turn, a sedan noses across the road, and men with shotguns relieve your boys of {0} barrels without so much as raising their voices. Purple work, no question -- fast, clean, and mean. Worse, the street says somebody from the {1} outfit told Detroit exactly when and where your trucks roll. Remember that.
    else
        text({"$MEGAMOD_PURPLEGANG_hijack_solo_text", loss}) --$ It happens the way it always happens: a truck full of your hooch takes a wrong turn, a sedan noses across the road, and men with shotguns relieve your boys of {0} barrels without so much as raising their voices. Purple work, no question -- fast, clean, and mean. The talker's parting words come back to you: fellas who buy from us don't get hijacked. Funny how that works.
    end
    option("$MEGAMOD_PURPLEGANG_dismiss")
end

--[[------------------------------------------------------------------------------
    PURPLE GANG AMBUSH LOOT - their torpedoes are face-down on the pavement
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PURPLEGANG_LOOT_RESULT"
_event = "MegaModPurpleGangLoot"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_PURPLEGANG_loot_title") --$ Detroit Goes Home in a Box
    text("$MEGAMOD_PURPLEGANG_loot_text") --$ The Purple torpedoes won't be catching the train back to Detroit. Your crew left them on the pavement and went through their pockets: $800 in traveling money, now yours. Word will reach the Bernsteins soon enough, but Detroit is a long way off, and Chicago problems have a way of keeping Detroit men home.
    option("$MEGAMOD_PURPLEGANG_dismiss")
end

--[[------------------------------------------------------------------------------
    PURPLE GANG RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PURPLEGANG_RESULT"
_event = "MegaModPurpleGangResult"
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
    option("$MEGAMOD_PURPLEGANG_dismiss")
end

--[[------------------------------------------------------------------------------
    MegaMod: Marker's Due (EventDirector: CREW_GAMBLING)
    One of the crew is into a South Side policy racket for real money. Pay the
    marker quietly, make them work it off on the street, or tell the bookie to
    pound sand and see whether he sends the leg-breakers.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    CREW GAMBLING LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWGAMBLING_LISTENER"
_event = "MegaModCrewGamblingListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "CREW_GAMBLING" then return end

    -- Needs a crew member who can actually be leaned on (HotSprings eligibility)
    local playerFaction = WorldUtils:getPlayerFaction()
    local candidates = {}
    if playerFaction and playerFaction.members then
        for i = 1, #playerFaction.members do
            local member = playerFaction.members[i]
            if member and member ~= playerFaction.boss and not member:isDead()
                    and not member:hasState("SentAway")
                    and not member:hasState("Incarcerated") then
                candidates[#candidates + 1] = member
            end
        end
    end
    if #candidates == 0 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "CREW_GAMBLING")
        return
    end

    -- Actor rides the delay queue as an iid, re-resolved on arrival (LoyaltyEvents)
    local debtor = candidates[math.random(#candidates)]
    WorldUtils:scheduleWithDelay("MegaModCrewGamblingOffer", 5, "TICK",
        "crewGamblingDebtorIid", debtor.iid)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "CREW_GAMBLING")
end

--[[------------------------------------------------------------------------------
    CREW GAMBLING OFFER - the bookie's man comes calling
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWGAMBLING_OFFER"
_event = "MegaModCrewGamblingOffer"
_category = "Misc"

persist{}
crewGamblingDebtorIid = nil -- Expected Param

function crewGamblingGetDebtor()
    local rpc = crewGamblingDebtorIid and ActorUtils:getActorFromId(crewGamblingDebtorIid)
    if rpc and not rpc:isDead() and rpc.faction == WorldUtils:getPlayerFaction() then
        return rpc
    end
    return nil
end

-- $900 marker scaled by the config cost knob, clamped to a routine band
function crewGamblingDebt()
    local debt = math.floor(900 * (fact.MegaModCfgCost or 1))
    return math.max(300, math.min(debt, 2700))
end

function canTrigger()
    return crewGamblingDebtorIid ~= nil
end

function onTrigger()
    local debtor = crewGamblingGetDebtor()
    if not debtor then return end -- debtor died/left before the knock; auto-completes

    setModal(true)
    setCharacterPortrait(debtor)
    title("$MEGAMOD_CREWGAMBLING_title") --$ Marker's Due
    text({"$MEGAMOD_CREWGAMBLING_text", debtor, crewGamblingDebt()}) --$ A soft-spoken man in a hard-worn derby stops by and asks after {0:name} by name. Policy racket, South Side wheel -- the numbers game. Seems {0:name} has been chasing a hunch, and the hunch has been winning. The marker stands at ${1}, and the wheel wants it settled. "Nothing personal, understand. But the book balances one way or the other. How it balances is up to you."
    if BRScript:PlayerCanAfford(crewGamblingDebt()) then
        option({"$MEGAMOD_CREWGAMBLING_pay", crewGamblingDebt()}, crewGamblingPayQuiet) --$ Pay the marker quietly (${0})
    end
    option("$MEGAMOD_CREWGAMBLING_workoff", crewGamblingWorkOff) --$ They ran it up. They can work it off.
    option("$MEGAMOD_CREWGAMBLING_refuse", crewGamblingPoundSand) --$ Tell the bookie to pound sand
end

-- MEGAMOD: pages set in option callbacks never display (pooled event completes on
-- click), so results run as a separate event (Milaflores/RivalProvocations pattern)
function crewGamblingShowResult(titleKey, textKey, char, amount)
    WorldUtils:triggerEvent("MegaModCrewGamblingResult",
        "crewGamblingResultTitle", titleKey,
        "crewGamblingResultText", textKey,
        "crewGamblingResultAmount", amount or 0,
        "crewGamblingResultChar", char)
end

function crewGamblingPayQuiet()
    local debtor = crewGamblingGetDebtor()
    if not debtor then return end
    local debt = crewGamblingDebt()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < debt then
        crewGamblingShowResult("$MEGAMOD_CREWGAMBLING_broke_title", "$MEGAMOD_CREWGAMBLING_broke_text", debtor, debt) --$ Light in the Pocket / You reach for the roll and come up holding air. The man in the derby watches you count it twice, then tips his hat with terrible politeness. "The wheel will be in touch." Not the way you wanted this to go.
        return
    end
    BRScript:PlayerSubtractCash(debt, "CASH.EXPENSES")
    if debtor.loyalty then
        debtor.loyalty:add(10, "$MEGAMOD_CREWGAMBLING_loyalty_paid") --$ The boss covered my marker
    end
    crewGamblingShowResult("$MEGAMOD_CREWGAMBLING_paid_title", "$MEGAMOD_CREWGAMBLING_paid_text", debtor, debt) --$ The Book Balances / Quietly settled, no audience, no lecture.
end

function crewGamblingWorkOff()
    local debtor = crewGamblingGetDebtor()
    if not debtor then return end
    -- A week on the street collecting for the wheel (Moonshiners SentAway pattern)
    debtor:addState("SentAway", "timeAway", 7, "dontShowReturnEvent", true)
    if debtor.loyalty then
        debtor.loyalty:add(-5, "$MEGAMOD_CREWGAMBLING_loyalty_worked") --$ Sent to sweat off my own marker
    end
    crewGamblingShowResult("$MEGAMOD_CREWGAMBLING_worked_title", "$MEGAMOD_CREWGAMBLING_worked_text", debtor, 0) --$ Working It Off / A week collecting for the wheel to square the marker.
end

function crewGamblingPoundSand()
    local debtor = crewGamblingGetDebtor()
    if not debtor then return end
    if math.random() < 0.40 then
        -- The wheel decides the marker isn't worth the trouble
        crewGamblingShowResult("$MEGAMOD_CREWGAMBLING_bluff_title", "$MEGAMOD_CREWGAMBLING_bluff_text", debtor, 0) --$ The Wheel Blinks / The bookie decides the marker isn't worth a war.
    else
        -- Leg-breakers: precinct read BEFORE the Injury behaviour moves the victim
        local precinct = debtor:getPrecinct()
        debtor:addState("Injury", "configId", "INJURY_DATA.MODERATE", "days", 7, "hideAlert", true)
        if precinct then
            precinct:addTemporaryPoliceActivity(math.floor(5 * (fact.MegaModCfgHeat or 1)))
        end
        crewGamblingShowResult("$MEGAMOD_CREWGAMBLING_thugs_title", "$MEGAMOD_CREWGAMBLING_thugs_text", debtor, 0) --$ Leg-Breakers / The wheel sends collectors of a different kind.
    end
end

--[[------------------------------------------------------------------------------
    CREW GAMBLING RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWGAMBLING_RESULT"
_event = "MegaModCrewGamblingResult"
_category = "Misc"

persist{}
crewGamblingResultTitle = nil

persist{}
crewGamblingResultText = nil

persist{}
crewGamblingResultAmount = 0

persist{}
crewGamblingResultChar = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    if crewGamblingResultChar then
        setCharacterPortrait(crewGamblingResultChar)
    end
    title(crewGamblingResultTitle)
    text({crewGamblingResultText, crewGamblingResultChar, crewGamblingResultAmount})
    option("$MEGAMOD_CREWGAMBLING_dismiss") --$ The house always collects.
end

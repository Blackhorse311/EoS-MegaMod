--[[------------------------------------------------------------------------------
    MegaMod: The Straight and Narrow (EventDirector: CREW_COLD_FEET)
    A shaken crew member found religion at a tent revival and wants out of the
    life. Let them go with a handshake, pay them enough to forget the sermon,
    or remind them what they signed -- and let the word get around.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    CREW COLD FEET LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWCOLDFEET_LISTENER"
_event = "MegaModCrewColdFeetListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "CREW_COLD_FEET" then return end

    -- Needs a crew member around to get cold feet (HotSprings eligibility)
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
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "CREW_COLD_FEET")
        return
    end

    -- Actor rides the delay queue as an iid, re-resolved on arrival (LoyaltyEvents)
    local shaken = candidates[math.random(#candidates)]
    WorldUtils:scheduleWithDelay("MegaModCrewColdFeetOffer", 5, "TICK",
        "crewColdFeetMemberIid", shaken.iid)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "CREW_COLD_FEET")
end

--[[------------------------------------------------------------------------------
    CREW COLD FEET OFFER - the resignation
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWCOLDFEET_OFFER"
_event = "MegaModCrewColdFeetOffer"
_category = "Misc"

persist{}
crewColdFeetMemberIid = nil -- Expected Param

function crewColdFeetGetMember()
    local rpc = crewColdFeetMemberIid and ActorUtils:getActorFromId(crewColdFeetMemberIid)
    if rpc and not rpc:isDead() and rpc.faction == WorldUtils:getPlayerFaction() then
        return rpc
    end
    return nil
end

-- $800 to out-argue the Almighty, scaled by the config cost knob, clamped
function crewColdFeetStayPrice()
    local price = math.floor(800 * (fact.MegaModCfgCost or 1))
    return math.max(300, math.min(price, 2400))
end

function canTrigger()
    return crewColdFeetMemberIid ~= nil
end

function onTrigger()
    local shaken = crewColdFeetGetMember()
    if not shaken then return end -- member died/left before the talk; auto-completes

    setModal(true)
    setCharacterPortrait(shaken)
    title("$MEGAMOD_CREWCOLDFEET_title") --$ The Straight and Narrow
    text({"$MEGAMOD_CREWCOLDFEET_text", shaken}) --$ {0:name} waits until the room clears, then puts a revolver on your desk -- grip first, cylinder open, empty. "I'm out, boss. I went to that tent revival on Halsted to laugh at the rubes, and... I didn't laugh." The eyes are steady in a way you haven't seen on them before. "Preacher says a man can walk out of his old life like walking out of a burning house. I mean to walk. I'm asking you not to make it a running."
    option("$MEGAMOD_CREWCOLDFEET_letgo", crewColdFeetLetThemGo) --$ Shake their hand and open the door
    if BRScript:PlayerCanAfford(crewColdFeetStayPrice()) then
        option({"$MEGAMOD_CREWCOLDFEET_pay", crewColdFeetStayPrice()}, crewColdFeetPayToStay) --$ Make the life worth more (${0})
    end
    option("$MEGAMOD_CREWCOLDFEET_remind", crewColdFeetRemindThem) --$ Remind them what they signed
end

-- MEGAMOD: pages set in option callbacks never display (pooled event completes on
-- click), so results run as a separate event (Milaflores/RivalProvocations pattern)
function crewColdFeetShowResult(titleKey, textKey, char, amount)
    WorldUtils:triggerEvent("MegaModCrewColdFeetResult",
        "crewColdFeetResultTitle", titleKey,
        "crewColdFeetResultText", textKey,
        "crewColdFeetResultAmount", amount or 0,
        "crewColdFeetResultChar", char)
end

function crewColdFeetLetThemGo()
    local shaken = crewColdFeetGetMember()
    if not shaken then return end
    -- The rest of the crew sees a boss who lets a soul out the door standing up
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.members then
        for i = 1, #playerFaction.members do
            local member = playerFaction.members[i]
            if member and member ~= playerFaction.boss and member ~= shaken
                    and not member:isDead() and member.loyalty then
                member.loyalty:add(5, "$MEGAMOD_CREWCOLDFEET_loyalty_decent") --$ The boss let a soul walk out standing up
            end
        end
    end
    crewColdFeetShowResult("$MEGAMOD_CREWCOLDFEET_letgo_title", "$MEGAMOD_CREWCOLDFEET_letgo_text", shaken, 0) --$ Gone to Glory / A handshake, an open door, and a crew that noticed.
    shaken:leaveFaction() -- verified RPC:leaveFaction (LoyaltyEvents pattern)
end

function crewColdFeetPayToStay()
    local shaken = crewColdFeetGetMember()
    if not shaken then return end
    local price = crewColdFeetStayPrice()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < price then
        crewColdFeetShowResult("$MEGAMOD_CREWCOLDFEET_broke_title", "$MEGAMOD_CREWCOLDFEET_broke_text", shaken, price) --$ The Collection Plate Is Empty / You can't outbid the Almighty on credit.
        return
    end
    BRScript:PlayerSubtractCash(price, "CASH.EXPENSES")
    if shaken.loyalty then
        shaken.loyalty:add(10, "$MEGAMOD_CREWCOLDFEET_loyalty_stayed") --$ The boss made the life worth staying in
    end
    crewColdFeetShowResult("$MEGAMOD_CREWCOLDFEET_pay_title", "$MEGAMOD_CREWCOLDFEET_pay_text", shaken, price) --$ The Wages of Sin / The revolver comes back off the desk.
end

function crewColdFeetRemindThem()
    local shaken = crewColdFeetGetMember()
    if not shaken then return end
    if shaken.loyalty then
        shaken.loyalty:add(-10, "$MEGAMOD_CREWCOLDFEET_loyalty_reminded") --$ The boss showed me the door is locked
    end
    -- Word gets around that nobody leaves your outfit -- including to federal ears
    fact.MegaModFedHeat = math.min(100,
        (fact.MegaModFedHeat or 0) + 2 * (fact.MegaModCfgFedHeat or 1))
    crewColdFeetShowResult("$MEGAMOD_CREWCOLDFEET_remind_title", "$MEGAMOD_CREWCOLDFEET_remind_text", shaken, 0) --$ No Exit / They stay. The story travels further than you'd like.
end

--[[------------------------------------------------------------------------------
    CREW COLD FEET RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWCOLDFEET_RESULT"
_event = "MegaModCrewColdFeetResult"
_category = "Misc"

persist{}
crewColdFeetResultTitle = nil

persist{}
crewColdFeetResultText = nil

persist{}
crewColdFeetResultAmount = 0

persist{}
crewColdFeetResultChar = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    if crewColdFeetResultChar then
        setCharacterPortrait(crewColdFeetResultChar)
    end
    title(crewColdFeetResultTitle)
    text({crewColdFeetResultText, crewColdFeetResultChar, crewColdFeetResultAmount})
    option("$MEGAMOD_CREWCOLDFEET_dismiss") --$ Amen to that.
end

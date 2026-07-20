--[[------------------------------------------------------------------------------
    MegaMod: Something Borrowed (EventDirector: CREW_WEDDING)
    One of the crew is getting married and wants the reception at your best
    speakeasy. Host it lavish, host it modest, or decline and be the boss who
    wouldn't spring for the band. Pure warm-fuzzy event -- no tricks.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    CREW WEDDING LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWWEDDING_LISTENER"
_event = "MegaModCrewWeddingListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "CREW_WEDDING" then return end

    -- Needs a crew member around to get married (HotSprings eligibility)
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
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "CREW_WEDDING")
        return
    end

    -- Actor rides the delay queue as an iid, re-resolved on arrival (LoyaltyEvents)
    local happyMember = candidates[math.random(#candidates)]
    WorldUtils:scheduleWithDelay("MegaModCrewWeddingOffer", 5, "TICK",
        "crewWeddingMemberIid", happyMember.iid)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "CREW_WEDDING")
end

--[[------------------------------------------------------------------------------
    CREW WEDDING OFFER - the big ask
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWWEDDING_OFFER"
_event = "MegaModCrewWeddingOffer"
_category = "Misc"

persist{}
crewWeddingMemberIid = nil -- Expected Param

function crewWeddingGetMember()
    local rpc = crewWeddingMemberIid and ActorUtils:getActorFromId(crewWeddingMemberIid)
    if rpc and not rpc:isDead() and rpc.faction == WorldUtils:getPlayerFaction() then
        return rpc
    end
    return nil
end

-- Reception costs scaled by the config cost knob, clamped to routine bands
function crewWeddingLavishCost()
    local cost = math.floor(1200 * (fact.MegaModCfgCost or 1))
    return math.max(400, math.min(cost, 3600))
end

function crewWeddingModestCost()
    local cost = math.floor(400 * (fact.MegaModCfgCost or 1))
    return math.max(150, math.min(cost, 1200))
end

-- Cops love a wedding: find the hottest precinct you operate in so the beat
-- boys can be invited to the buffet (ContractBroker getPrecinct pattern)
function crewWeddingBusiestPrecinct()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return nil end
    local busiest = nil
    local highest = -1
    for i = 1, #playerFaction.buildings do
        local building = playerFaction.buildings[i]
        local precinct = building and building:getPrecinct()
        if precinct then
            local activity = precinct:getPoliceActivity() or 0
            if activity > highest then
                busiest = precinct
                highest = activity
            end
        end
    end
    return busiest
end

function canTrigger()
    return crewWeddingMemberIid ~= nil
end

function onTrigger()
    local happyMember = crewWeddingGetMember()
    if not happyMember then return end -- member died/left before the ask; auto-completes

    setModal(true)
    setCharacterPortrait(happyMember)
    title("$MEGAMOD_CREWWEDDING_title") --$ Something Borrowed
    text({"$MEGAMOD_CREWWEDDING_text", happyMember}) --$ {0:name} shows up in a pressed collar, shoes shined to a mirror, grinning like a kid who cracked a gumball machine. "Boss -- I'm getting married. Sunday. The real thing, priest and all." The hat comes off. "We were hoping... well, there's no finer room in the neighborhood than your joint. Nothing fancy, just family, the crew, a little music. It'd mean the world to have the boss's blessing on it. And the boss's back room."
    if BRScript:PlayerCanAfford(crewWeddingLavishCost()) then
        option({"$MEGAMOD_CREWWEDDING_lavish", crewWeddingLavishCost()}, crewWeddingHostLavish) --$ Throw the wedding of the year (${0})
    end
    if BRScript:PlayerCanAfford(crewWeddingModestCost()) then
        option({"$MEGAMOD_CREWWEDDING_modest", crewWeddingModestCost()}, crewWeddingHostModest) --$ Host it modest but proper (${0})
    end
    option("$MEGAMOD_CREWWEDDING_decline", crewWeddingDecline) --$ The back room's for business
end

-- MEGAMOD: pages set in option callbacks never display (pooled event completes on
-- click), so results run as a separate event (Milaflores/RivalProvocations pattern)
function crewWeddingShowResult(titleKey, textKey, char, amount)
    WorldUtils:triggerEvent("MegaModCrewWeddingResult",
        "crewWeddingResultTitle", titleKey,
        "crewWeddingResultText", textKey,
        "crewWeddingResultAmount", amount or 0,
        "crewWeddingResultChar", char)
end

function crewWeddingHostLavish()
    local happyMember = crewWeddingGetMember()
    if not happyMember then return end
    local cost = crewWeddingLavishCost()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < cost then
        crewWeddingShowResult("$MEGAMOD_CREWWEDDING_broke_title", "$MEGAMOD_CREWWEDDING_broke_text", happyMember, cost) --$ Champagne Pockets, Beer Bankroll / The grand plans outrun the cashbox.
        return
    end
    BRScript:PlayerSubtractCash(cost, "CASH.EXPENSES")
    -- The whole outfit drinks to the couple -- every crew member feels it
    if playerFaction.members then
        for i = 1, #playerFaction.members do
            local member = playerFaction.members[i]
            if member and member ~= playerFaction.boss and not member:isDead()
                    and member.loyalty then
                member.loyalty:add(10, "$MEGAMOD_CREWWEDDING_loyalty_lavish") --$ The boss threw the wedding of the year
            end
        end
    end
    -- Half the precinct danced at the reception; the heat cools off a touch
    local precinct = crewWeddingBusiestPrecinct()
    if precinct then
        precinct:addTemporaryPoliceActivity(-5)
    end
    crewWeddingShowResult("$MEGAMOD_CREWWEDDING_lavish_title", "$MEGAMOD_CREWWEDDING_lavish_text", happyMember, cost) --$ The Wedding of the Year / Flowers, a band, and half the beat cops at the buffet.
end

function crewWeddingHostModest()
    local happyMember = crewWeddingGetMember()
    if not happyMember then return end
    local cost = crewWeddingModestCost()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < cost then
        crewWeddingShowResult("$MEGAMOD_CREWWEDDING_broke_title", "$MEGAMOD_CREWWEDDING_broke_text", happyMember, cost)
        return
    end
    BRScript:PlayerSubtractCash(cost, "CASH.EXPENSES")
    -- The couple gets the big lift; the rest of the crew still enjoyed the party
    if happyMember.loyalty then
        happyMember.loyalty:add(10, "$MEGAMOD_CREWWEDDING_loyalty_couple") --$ The boss stood up at my wedding
    end
    if playerFaction.members then
        for i = 1, #playerFaction.members do
            local member = playerFaction.members[i]
            if member and member ~= playerFaction.boss and member ~= happyMember
                    and not member:isDead() and member.loyalty then
                member.loyalty:add(3, "$MEGAMOD_CREWWEDDING_loyalty_guest") --$ A fine night at the crew wedding
            end
        end
    end
    crewWeddingShowResult("$MEGAMOD_CREWWEDDING_modest_title", "$MEGAMOD_CREWWEDDING_modest_text", happyMember, cost) --$ Small and Proper / One long table, one good toast, one happy couple.
end

function crewWeddingDecline()
    local happyMember = crewWeddingGetMember()
    if not happyMember then return end
    if happyMember.loyalty then
        happyMember.loyalty:add(-10, "$MEGAMOD_CREWWEDDING_loyalty_declined") --$ The boss wouldn't open the room for my wedding
    end
    crewWeddingShowResult("$MEGAMOD_CREWWEDDING_decline_title", "$MEGAMOD_CREWWEDDING_decline_text", happyMember, 0) --$ Strictly Business / The collar wilts. The shine goes out of the shoes.
end

--[[------------------------------------------------------------------------------
    CREW WEDDING RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWWEDDING_RESULT"
_event = "MegaModCrewWeddingResult"
_category = "Misc"

persist{}
crewWeddingResultTitle = nil

persist{}
crewWeddingResultText = nil

persist{}
crewWeddingResultAmount = 0

persist{}
crewWeddingResultChar = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    if crewWeddingResultChar then
        setCharacterPortrait(crewWeddingResultChar)
    end
    title(crewWeddingResultTitle)
    text({crewWeddingResultText, crewWeddingResultChar, crewWeddingResultAmount})
    option("$MEGAMOD_CREWWEDDING_dismiss") --$ Somebody bring me a slice of cake.
end

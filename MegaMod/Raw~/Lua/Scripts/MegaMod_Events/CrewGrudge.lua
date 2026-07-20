--[[------------------------------------------------------------------------------
    MegaMod: Old Scores (EventDirector: CREW_GRUDGE)
    One of the crew has spotted a face from the old country -- now carrying a
    gun for a rival outfit. Let them settle it the old way, forbid it, or buy
    the grudge off before it buys a funeral.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    CREW GRUDGE LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWGRUDGE_LISTENER"
_event = "MegaModCrewGrudgeListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "CREW_GRUDGE" then return end

    -- Needs an available crew member AND a rival outfit for the face to work for
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
    if #candidates == 0 or #activeRivals == 0 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "CREW_GRUDGE")
        return
    end

    -- Actor as iid, faction by factionId (LoyaltyEvents / RivalProvocations)
    local member = candidates[math.random(#candidates)]
    local rival = activeRivals[math.random(#activeRivals)]
    WorldUtils:scheduleWithDelay("MegaModCrewGrudgeOffer", 5, "TICK",
        "crewGrudgeMemberIid", member.iid,
        "crewGrudgeRivalFactionId", rival.factionId,
        "crewGrudgeRivalName", rival.name)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "CREW_GRUDGE")
end

--[[------------------------------------------------------------------------------
    CREW GRUDGE OFFER - the old score surfaces
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWGRUDGE_OFFER"
_event = "MegaModCrewGrudgeOffer"
_category = "Misc"

persist{}
crewGrudgeMemberIid = nil -- Expected Param

persist{}
crewGrudgeRivalFactionId = nil -- Expected Param

persist{}
crewGrudgeRivalName = nil -- Expected Param

function crewGrudgeGetMember()
    local rpc = crewGrudgeMemberIid and ActorUtils:getActorFromId(crewGrudgeMemberIid)
    if rpc and not rpc:isDead() and rpc.faction == WorldUtils:getPlayerFaction() then
        return rpc
    end
    return nil
end

-- $400 to bury the grudge, scaled by the config cost knob, clamped
function crewGrudgePayoff()
    local price = math.floor(400 * (fact.MegaModCfgCost or 1))
    return math.max(150, math.min(price, 1200))
end

function canTrigger()
    return crewGrudgeMemberIid ~= nil
end

function onTrigger()
    local member = crewGrudgeGetMember()
    if not member then return end -- member died/left before the ask; auto-completes

    setModal(true)
    setCharacterPortrait(member)
    title("$MEGAMOD_CREWGRUDGE_title") --$ Old Scores
    text({"$MEGAMOD_CREWGRUDGE_text", member, crewGrudgeRivalName}) --$ {0:name} comes to you white around the mouth. "I saw him, boss. In a coat that cost more than my father's farm. He's muscle for {1} now." The story spills out -- a village, a burned barn, a brother who never made the boat, and a name carried across the ocean like a stone in a coffin pocket. "The old country says blood answers blood. I'm asking your leave to answer it. Three days. He won't be hard to find."
    option("$MEGAMOD_CREWGRUDGE_settle", crewGrudgeSettleIt) --$ Take three days. Settle it.
    option("$MEGAMOD_CREWGRUDGE_forbid", crewGrudgeForbidIt) --$ Forbid it. The old country stays buried.
    if BRScript:PlayerCanAfford(crewGrudgePayoff()) then
        option({"$MEGAMOD_CREWGRUDGE_payoff", crewGrudgePayoff()}, crewGrudgePayItOff) --$ Buy the grudge off (${0})
    end
end

-- MEGAMOD: pages set in option callbacks never display (pooled event completes on
-- click), so results run as a separate event (Milaflores/RivalProvocations pattern)
function crewGrudgeShowResult(titleKey, textKey, char, amount)
    WorldUtils:triggerEvent("MegaModCrewGrudgeResult",
        "crewGrudgeResultTitle", titleKey,
        "crewGrudgeResultText", textKey,
        "crewGrudgeResultAmount", amount or 0,
        "crewGrudgeResultChar", char)
end

function crewGrudgeSettleIt()
    local member = crewGrudgeGetMember()
    if not member then return end
    -- Three days away; the outcome is rolled now and delivered on return
    -- (Milaflores rolled-now-delivered-later; the delay queue is save-persisted)
    member:addState("SentAway", "timeAway", 3, "dontShowReturnEvent", true)
    local success = math.random() < 0.60
    WorldUtils:scheduleWithDelay("MegaModCrewGrudgeReturn", Utils:daysToSecs(3), "TICK",
        "crewGrudgeReturnIid", member.iid,
        "crewGrudgeReturnSuccess", success and 1 or 0,
        "crewGrudgeReturnRivalId", crewGrudgeRivalFactionId,
        "crewGrudgeReturnRivalName", crewGrudgeRivalName)
    crewGrudgeShowResult("$MEGAMOD_CREWGRUDGE_gone_title", "$MEGAMOD_CREWGRUDGE_gone_text", member, 0) --$ Leave Granted / They clean a pistol older than they are and slip out before dawn.
end

function crewGrudgeForbidIt()
    local member = crewGrudgeGetMember()
    if not member then return end
    if member.loyalty then
        member.loyalty:add(-10, "$MEGAMOD_CREWGRUDGE_loyalty_forbidden") --$ The boss made me swallow the old score
    end
    crewGrudgeShowResult("$MEGAMOD_CREWGRUDGE_forbid_title", "$MEGAMOD_CREWGRUDGE_forbid_text", member, 0) --$ The Answer Is No / They obey. The stone in the coffin pocket stays.
end

function crewGrudgePayItOff()
    local member = crewGrudgeGetMember()
    if not member then return end
    local price = crewGrudgePayoff()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < price then
        crewGrudgeShowResult("$MEGAMOD_CREWGRUDGE_broke_title", "$MEGAMOD_CREWGRUDGE_broke_text", member, price) --$ Short of the Price / Old-country honor doesn't take an IOU.
        return
    end
    BRScript:PlayerSubtractCash(price, "CASH.EXPENSES")
    if member.loyalty then
        member.loyalty:add(5, "$MEGAMOD_CREWGRUDGE_loyalty_paidoff") --$ The boss settled my family's score with gold
    end
    crewGrudgeShowResult("$MEGAMOD_CREWGRUDGE_payoff_title", "$MEGAMOD_CREWGRUDGE_payoff_text", member, price) --$ Blood Money / The grudge is bought, weighed, and buried in an envelope.
end

--[[------------------------------------------------------------------------------
    CREW GRUDGE RETURN - three days later (scheduled from the offer)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWGRUDGE_RETURN"
_event = "MegaModCrewGrudgeReturn"
_category = "Misc"

persist{}
crewGrudgeReturnIid = nil -- Expected Param

persist{}
crewGrudgeReturnSuccess = 0 -- Expected Param (1 = settled, 0 = went wrong)

persist{}
crewGrudgeReturnRivalId = nil -- Expected Param

persist{}
crewGrudgeReturnRivalName = nil -- Expected Param

function canTrigger()
    return crewGrudgeReturnIid ~= nil
end

function onTrigger()
    -- Re-resolve; if they died or left while away, the story ends untold
    local member = crewGrudgeReturnIid and ActorUtils:getActorFromId(crewGrudgeReturnIid)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not member or member:isDead() or member.faction ~= playerFaction then return end

    setModal(true)
    setCharacterPortrait(member)
    if crewGrudgeReturnSuccess == 1 then
        if member.loyalty then
            member.loyalty:add(10, "$MEGAMOD_CREWGRUDGE_loyalty_settled") --$ The boss let me answer for my blood
        end
        -- The rival knows exactly whose crew came calling (MurderInc pattern)
        local rival = crewGrudgeReturnRivalId
                and WorldUtils:getFactionByFactionId(crewGrudgeReturnRivalId)
        if rival and rival._active and playerFaction then
            rival.rating:applyEffect(playerFaction, "AMBUSHED")
        end
        -- A body with old-country paperwork draws federal eyes
        fact.MegaModFedHeat = math.min(100,
            (fact.MegaModFedHeat or 0) + 3 * (fact.MegaModCfgFedHeat or 1))
        title("$MEGAMOD_CREWGRUDGE_success_title") --$ The Score Is Settled
        text({"$MEGAMOD_CREWGRUDGE_success_text", member, crewGrudgeReturnRivalName}) --$ {0:name} comes back three days later with river mud on their shoes and thirty years off their shoulders. Nobody asks for details and none are offered -- but the man in the expensive coat stops appearing at his usual corners, and {1} starts asking pointed questions with your outfit's name in them. Down at the federal building, a man with a typewriter opens a file on the kind of murder that crosses oceans. The old country is satisfied. The new one is taking notes.
    else
        member:addState("Injury", "configId", "INJURY_DATA.MODERATE", "days", 7, "hideAlert", true)
        title("$MEGAMOD_CREWGRUDGE_fail_title") --$ The Old Country Shoots Back
        text({"$MEGAMOD_CREWGRUDGE_fail_text", member}) --$ {0:name} comes home folded around a bullet hole, dragged the last block by a milkman with strong opinions about bleeding on his route. The man in the expensive coat was waiting -- turns out the old country teaches the same lessons to both sides of a grudge. A week in bed and a scar to carry with the stone. "I'll heal, boss," they manage. "He won't be so lucky twice." You make a note not to grant that leave again.
    end
    option("$MEGAMOD_CREWGRUDGE_dismiss") --$ The old country keeps its books open.
end

--[[------------------------------------------------------------------------------
    CREW GRUDGE RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWGRUDGE_RESULT"
_event = "MegaModCrewGrudgeResult"
_category = "Misc"

persist{}
crewGrudgeResultTitle = nil

persist{}
crewGrudgeResultText = nil

persist{}
crewGrudgeResultAmount = 0

persist{}
crewGrudgeResultChar = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    if crewGrudgeResultChar then
        setCharacterPortrait(crewGrudgeResultChar)
    end
    title(crewGrudgeResultTitle)
    text({crewGrudgeResultText, crewGrudgeResultChar, crewGrudgeResultAmount})
    option("$MEGAMOD_CREWGRUDGE_dismiss")
end

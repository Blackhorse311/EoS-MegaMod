--[[------------------------------------------------------------------------------
    MegaMod: A Word About Wages (EventDirector: CREW_RAISE)
    Your best earner has had a better offer whispered in their ear and wants a
    word about wages. Pay the bonus, promise them the world, or refuse flat
    and find out what your word is worth.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    CREW RAISE LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWRAISE_LISTENER"
_event = "MegaModCrewRaiseListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "CREW_RAISE" then return end

    -- The best earner = highest loyalty among available crew (loyalty:get, the
    -- LoyaltyEvents read); crew without a readable loyalty rank as 0, so a
    -- random-ish eligible member still surfaces if nothing is readable
    local playerFaction = WorldUtils:getPlayerFaction()
    local star = nil
    local starLoyalty = -1
    if playerFaction and playerFaction.members then
        for i = 1, #playerFaction.members do
            local member = playerFaction.members[i]
            if member and member ~= playerFaction.boss and not member:isDead()
                    and not member:hasState("SentAway")
                    and not member:hasState("Incarcerated") then
                local loyalty = (member.loyalty and member.loyalty:get()) or 0
                if loyalty > starLoyalty then
                    star = member
                    starLoyalty = loyalty
                end
            end
        end
    end
    if not star then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "CREW_RAISE")
        return
    end

    -- Actor rides the delay queue as an iid, re-resolved on arrival (LoyaltyEvents)
    WorldUtils:scheduleWithDelay("MegaModCrewRaiseOffer", 5, "TICK",
        "crewRaiseStarIid", star.iid)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "CREW_RAISE")
end

--[[------------------------------------------------------------------------------
    CREW RAISE OFFER - the sit-down about money
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWRAISE_OFFER"
_event = "MegaModCrewRaiseOffer"
_category = "Misc"

persist{}
crewRaiseStarIid = nil -- Expected Param

function crewRaiseGetStar()
    local rpc = crewRaiseStarIid and ActorUtils:getActorFromId(crewRaiseStarIid)
    if rpc and not rpc:isDead() and rpc.faction == WorldUtils:getPlayerFaction() then
        return rpc
    end
    return nil
end

-- $700 bonus scaled by the config cost knob, clamped to a routine band
function crewRaiseBonus()
    local bonus = math.floor(700 * (fact.MegaModCfgCost or 1))
    return math.max(250, math.min(bonus, 2100))
end

function canTrigger()
    return crewRaiseStarIid ~= nil
end

function onTrigger()
    local star = crewRaiseGetStar()
    if not star then return end -- star died/left before the sit-down; auto-completes

    setModal(true)
    setCharacterPortrait(star)
    title("$MEGAMOD_CREWRAISE_title") --$ A Word About Wages
    text({"$MEGAMOD_CREWRAISE_text", star, crewRaiseBonus()}) --$ {0:name} asks for a minute, hat in hand but chin up. Best earner you've got, and you both know it. "Boss, I'll say it plain. Another outfit's been buying me drinks and talking numbers. Big numbers. I told 'em I ride with you -- but a fella's got rent, and loyalty don't argue with the landlord. A ${1} consideration would settle the matter for good."
    if BRScript:PlayerCanAfford(crewRaiseBonus()) then
        option({"$MEGAMOD_CREWRAISE_pay", crewRaiseBonus()}, crewRaisePayBonus) --$ Pay the bonus (${0})
    end
    option("$MEGAMOD_CREWRAISE_glory", crewRaisePromiseGlory) --$ Promise them the world (free)
    option("$MEGAMOD_CREWRAISE_refuse", crewRaiseRefuseFlat) --$ Refuse flat. Nobody squeezes me.
end

-- MEGAMOD: pages set in option callbacks never display (pooled event completes on
-- click), so results run as a separate event (Milaflores/RivalProvocations pattern)
function crewRaiseShowResult(titleKey, textKey, char, amount)
    WorldUtils:triggerEvent("MegaModCrewRaiseResult",
        "crewRaiseResultTitle", titleKey,
        "crewRaiseResultText", textKey,
        "crewRaiseResultAmount", amount or 0,
        "crewRaiseResultChar", char)
end

function crewRaisePayBonus()
    local star = crewRaiseGetStar()
    if not star then return end
    local bonus = crewRaiseBonus()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < bonus then
        crewRaiseShowResult("$MEGAMOD_CREWRAISE_broke_title", "$MEGAMOD_CREWRAISE_broke_text", star, bonus) --$ Empty Envelope / The bankroll won't cover the promise.
        return
    end
    BRScript:PlayerSubtractCash(bonus, "CASH.EXPENSES")
    if star.loyalty then
        star.loyalty:add(15, "$MEGAMOD_CREWRAISE_loyalty_paid") --$ The boss pays what an earner is worth
    end
    crewRaiseShowResult("$MEGAMOD_CREWRAISE_paid_title", "$MEGAMOD_CREWRAISE_paid_text", star, bonus) --$ Money Talks / The envelope changes hands and the rival's offer dies on the vine.
end

function crewRaisePromiseGlory()
    local star = crewRaiseGetStar()
    if not star then return end
    -- 50/50: some believe in the dream, some hear one more empty promise
    if math.random() < 0.50 then
        if star.loyalty then
            star.loyalty:add(5, "$MEGAMOD_CREWRAISE_loyalty_glory") --$ The boss has plans for me
        end
        crewRaiseShowResult("$MEGAMOD_CREWRAISE_glory_good_title", "$MEGAMOD_CREWRAISE_glory_good_text", star, 0) --$ Sold on the Dream / They walk out taller than they walked in.
    else
        if star.loyalty then
            star.loyalty:add(-10, "$MEGAMOD_CREWRAISE_loyalty_snub") --$ Promises don't pay the landlord
        end
        crewRaiseShowResult("$MEGAMOD_CREWRAISE_glory_bad_title", "$MEGAMOD_CREWRAISE_glory_bad_text", star, 0) --$ Words Are Wind / They've heard this speech before, from better liars.
    end
end

function crewRaiseRefuseFlat()
    local star = crewRaiseGetStar()
    if not star then return end
    if star.loyalty then
        star.loyalty:add(-15, "$MEGAMOD_CREWRAISE_loyalty_refused") --$ Asked for my due and got the door
    end
    -- 25% they take the rival's offer and walk (leaveFaction, LoyaltyEvents pattern)
    if math.random() < 0.25 then
        crewRaiseShowResult("$MEGAMOD_CREWRAISE_walked_title", "$MEGAMOD_CREWRAISE_walked_text", star, 0) --$ Gone by Morning / Their room's cleared out and the rival's got a new earner.
        star:leaveFaction()
    else
        crewRaiseShowResult("$MEGAMOD_CREWRAISE_refused_title", "$MEGAMOD_CREWRAISE_refused_text", star, 0) --$ The Cold Shoulder / They stay -- but something between you doesn't.
    end
end

--[[------------------------------------------------------------------------------
    CREW RAISE RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREWRAISE_RESULT"
_event = "MegaModCrewRaiseResult"
_category = "Misc"

persist{}
crewRaiseResultTitle = nil

persist{}
crewRaiseResultText = nil

persist{}
crewRaiseResultAmount = 0

persist{}
crewRaiseResultChar = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    if crewRaiseResultChar then
        setCharacterPortrait(crewRaiseResultChar)
    end
    title(crewRaiseResultTitle)
    text({crewRaiseResultText, crewRaiseResultChar, crewRaiseResultAmount})
    option("$MEGAMOD_CREWRAISE_dismiss") --$ Everybody's got a price.
end

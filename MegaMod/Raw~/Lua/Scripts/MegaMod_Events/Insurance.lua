--[[------------------------------------------------------------------------------
    MegaMod: The Insurance Racket -- "Honest Abe" Kaplan
    Mutual Assurance of Cook County. A traveling insurance man pitches weekly
    policies through the EventDirector; premiums auto-deduct every week; claims
    auto-pay when other scripts report a covered loss. In this town, fires
    just... happen.

    ===========================================================================
    INTEGRATION CONTRACT -- everything a reporter needs is in this header
    ===========================================================================

    1) REPORTING AN INSURED LOSS (the only call a reporter ever makes):

         Utils:raiseGameEvent("onMegaModInsuredLoss",
             "lossAmount", <dollars>,   -- positive number, BASE dollars
             "lossKind",   <kind>)      -- "raid" | "hijack" | "spoilage" | "damage"

       - lossAmount is the base (unscaled) dollar value of what the player lost.
         Do NOT multiply by fact.MegaModCfgPayout / fact.MegaModCfgCost --
         all config scaling happens inside this file.
       - ALCOHOL losses: convert barrels to dollars BEFORE raising.
         Suggested standard rate: $40 per barrel (lossAmount = barrels * 40).
       - lossKind is flavor/telemetry only; payout math ignores it. Pass it honestly.
       - Raise unconditionally: with no active policy the event is ignored
         silently. (Optional micro-optimization: skip raising when
         fact.MegaModInsTier is nil.)
       - Dispatch is synchronous (vanilla Libs/Events.lua); safe to raise from
         dialog callbacks. The settlement dialog is scheduled a few ticks out,
         never shown inline, so it cannot collide with the reporter's own UI.

    2) WORLD FACTS (owned by this file; read-only everywhere else):
         fact.MegaModInsTier            1|2|3 while a policy is active, else nil
         fact.MegaModInsRate            covered fraction of each loss (0.40/0.60/0.80)
         fact.MegaModInsCap             per-claim payout cap, BASE dollars
         fact.MegaModInsPremium         weekly premium, BASE dollars (any claims
                                        surcharge already baked in; multiplied by
                                        CfgCost only at charge time)
         fact.MegaModInsLapsedUntil     worldTime before which Abe refuses to
                                        pitch again (nil once served / never lapsed)
         fact.MegaModInsClaimsThisMonth claims filed in the current 30-day window
         fact.MegaModInsSurcharged      1 once the permanent +50% claims
                                        surcharge has been applied

    3) LAPSE / ABUSE RULES (enforced here; nothing for reporters to do):
         - Premium unaffordable on collection day -> policy LAPSES: all Ins
           facts cleared, fact.MegaModInsLapsedUntil = worldTime + 30 days.
         - 3 claims inside 30 days -> premium raised 50%, PERMANENT for the
           policy (and the surcharge follows the client through upgrades).
         - 5 claims inside 30 days -> policy CANCELLED outright: facts cleared,
           60-day lapse. The 5th claim is still paid.
         - Claim windows are tracked with persisted worldTime vars in the
           monitor block; fact.MegaModInsClaimsThisMonth mirrors the counter.

    4) DIRECTOR REGISTRATION (required; add this one line to EVENT_REGISTRY in
       EventDirector.lua -- this file only answers the handshake):
         { name = "INSURANCE_PITCH", weight = 3, cooldownDays = 21 },
       The pick handler PASSes while a policy is active, while a lapse is being
       served, or when the player can't afford even the cheapest premium.

    5) CONFIG SCALING (both facts default to 1 until the config system lands):
         premiums (charges)  x (fact.MegaModCfgCost   or 1)  at charge time
         claim payouts       x (fact.MegaModCfgPayout or 1)  at settlement time
       Loc text quotes BASE prices ($150/$300/$500), same as every sibling event.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

-- ---------------------------------------------------------------------------
-- Tunables (BASE dollars; CfgCost/CfgPayout applied at charge/settlement time)
-- ---------------------------------------------------------------------------
local TIER_PREMIUM = { 150, 300, 500 }    -- weekly premium per tier
local TIER_RATE    = { 0.40, 0.60, 0.80 } -- covered fraction of each loss
local TIER_CAP     = { 1500, 3000, 6000 } -- per-claim payout cap
local LAPSE_DAYS           = 30  -- no re-pitch after a missed premium
local CANCEL_LAPSE_DAYS    = 60  -- no re-pitch after Abe cancels you
local CLAIM_WINDOW_DAYS    = 30  -- rolling window for the claim-frequency rules
local CLAIMS_FOR_SURCHARGE = 3   -- claims in window -> +50% premium, permanent
local CLAIMS_FOR_CANCEL    = 5   -- claims in window -> policy cancelled
local SURCHARGE_MULT       = 1.5
local UPGRADE_OFFER_CHANCE = 0.10 -- weekly chance of an upsell while insured

--[[------------------------------------------------------------------------------
    INSURANCE MONITOR - permanent Create-mode listener (EventDirector pattern).
    Owns the director handshake, weekly premium collection, and the claim desk.
    All counter state lives here (script vars are NOT shared across _id blocks;
    dialogs talk to the world through fact.* only).
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_MONITOR"
_event = "MegaModInsuranceMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
insClaimWindowStart = 0 -- worldTime when the current claims window opened (0 = no window)

persist{}
insClaimsInWindow = 0 -- claims filed inside the current window (mirrored to fact)

function onCreate()
    disableAutoComplete() -- permanent listener; must never auto-complete
end

-- MEGAMOD: helpers are plain GLOBAL functions (local function helpers lose the
-- sandbox env, so worldTime / fact / Utils would be unreachable)

function Insurance_refreshClaimWindow()
    if insClaimWindowStart > 0
            and (worldTime - insClaimWindowStart) >= Utils:daysToSecs(CLAIM_WINDOW_DAYS) then
        insClaimWindowStart = 0
        insClaimsInWindow = 0
        if fact.MegaModInsTier then
            fact.MegaModInsClaimsThisMonth = 0
        end
    end
end

function Insurance_dropPolicy(lapseDays)
    fact.MegaModInsTier = nil
    fact.MegaModInsRate = nil
    fact.MegaModInsCap = nil
    fact.MegaModInsPremium = nil
    fact.MegaModInsSurcharged = nil
    fact.MegaModInsClaimsThisMonth = nil
    fact.MegaModInsLapsedUntil = worldTime + Utils:daysToSecs(lapseDays)
    insClaimWindowStart = 0
    insClaimsInWindow = 0
end

-- Director handshake: PASS while covered, while serving a lapse, or while broke
function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "INSURANCE_PITCH" then return end

    if fact.MegaModInsTier then -- already carrying a policy
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "INSURANCE_PITCH")
        return
    end

    if fact.MegaModInsLapsedUntil then
        if worldTime < fact.MegaModInsLapsedUntil then -- lapse still being served
            Utils:raiseGameEvent("onMegaModEventPass", "eventName", "INSURANCE_PITCH")
            return
        end
        fact.MegaModInsLapsedUntil = nil -- time served; Abe forgives
    end

    -- The pitch only makes sense if the cheapest premium is even payable
    local costMult = fact.MegaModCfgCost or 1
    if not BRScript:PlayerCanAfford(math.floor(TIER_PREMIUM[1] * costMult)) then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "INSURANCE_PITCH")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModInsurancePitch", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "INSURANCE_PITCH")
end

-- Weekly premium collection (AldermanSystem upkeep pattern)
function GameEvent.onWeekBegin(e)
    Insurance_refreshClaimWindow() -- keep the window honest even in quiet weeks

    local tier = fact.MegaModInsTier
    if not tier then return end

    local costMult = fact.MegaModCfgCost or 1
    local premium = math.floor((fact.MegaModInsPremium or TIER_PREMIUM[tier]) * costMult)

    if premium > 0 then
        if not BRScript:PlayerCanAfford(premium) then
            -- Can't pay: the policy lapses on the spot
            Insurance_dropPolicy(LAPSE_DAYS)
            WorldUtils:scheduleWithDelay("MegaModInsuranceLapse", 5, "TICK")
            return
        end
        BRScript:PlayerSubtractCash(premium, "CASH.TRADE")
    end

    -- Occasional upsell while covered (one small dialog; canTrigger re-checks)
    if tier < 3 and math.random() < UPGRADE_OFFER_CHANCE then
        WorldUtils:scheduleWithDelay("MegaModInsuranceUpgrade", 5, "TICK")
    end
end

-- THE CLAIM DESK (see INTEGRATION CONTRACT in the file header)
function GameEvent.onMegaModInsuredLoss(e)
    local tier = fact.MegaModInsTier
    if not tier then return end -- no policy: losses are the player's own problem

    local loss = e and e.lossAmount
    if not loss or loss <= 0 then return end

    Insurance_refreshClaimWindow()

    local rate = fact.MegaModInsRate or TIER_RATE[tier]
    local cap = fact.MegaModInsCap or TIER_CAP[tier]
    local payoutMult = fact.MegaModCfgPayout or 1
    local payout = math.floor(math.min(cap, math.floor(loss * rate)) * payoutMult)
    if payout <= 0 then return end

    BRScript:PlayerAddCash(payout, "CASH.TRADE")

    -- Claim-frequency accounting (30-day worldTime window, persisted here)
    if insClaimWindowStart == 0 then
        insClaimWindowStart = worldTime
    end
    insClaimsInWindow = insClaimsInWindow + 1
    fact.MegaModInsClaimsThisMonth = insClaimsInWindow

    -- Settlement first; any actuarial reckoning follows a few ticks later
    WorldUtils:scheduleWithDelay("MegaModInsuranceSettlement", 5, "TICK",
        "insPayoutAmount", payout)

    if insClaimsInWindow >= CLAIMS_FOR_CANCEL then
        -- Five claims in a month: the fifth is paid, then Abe is done with you
        Insurance_dropPolicy(CANCEL_LAPSE_DAYS)
        WorldUtils:scheduleWithDelay("MegaModInsuranceCancelled", 30, "TICK")
    elseif insClaimsInWindow >= CLAIMS_FOR_SURCHARGE and not fact.MegaModInsSurcharged then
        -- Three claims in a month: +50% premium, permanent for this policy
        fact.MegaModInsSurcharged = 1
        fact.MegaModInsPremium =
            math.floor((fact.MegaModInsPremium or TIER_PREMIUM[tier]) * SURCHARGE_MULT)
        local costMult = fact.MegaModCfgCost or 1
        WorldUtils:scheduleWithDelay("MegaModInsuranceSurcharge", 30, "TICK",
            "insNewPremium", math.floor(fact.MegaModInsPremium * costMult))
    end
end

--[[------------------------------------------------------------------------------
    THE PITCH - Abe Kaplan makes his rounds
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_PITCH"
_event = "MegaModInsurancePitch"
_category = "Misc"

function canTrigger()
    return fact.MegaModInsTier == nil -- pick-to-trigger gap safety
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_INSURANCE_pitch_title") --$ The Insurance Man
    text("$MEGAMOD_INSURANCE_pitch_text") --$ The man at your door wears a good black suit gone shiny at the elbows and carries a rate book like a hymnal. "Abe Kaplan, Mutual Assurance of Cook County. Don't get up." He is already sitting. "I'll be brief, friend, because in my line I've learned time is the one thing no policy restores. You own property. Property in this town has a way of catching fire. Trucks get hijacked. Merchandise -- ah -- evaporates. Fires just happen here. I have seen them happen to men who were certain they wouldn't." He opens the rate book tenderly, the way an undertaker folds hands. "Mutual Assurance pays cash on covered losses, prompt as a funeral. Walking-Around Coverage: $150 a week, four dollars back on every ten you lose, up to $1,500 a claim. The Businessman's Special: $300 a week, six on ten, up to $3,000. Or the Full Portfolio: $500 a week, eight on ten, up to $6,000 -- and you sleep like the dead, only warmer. The question is never whether you can afford a policy, friend. It is whether you can afford the alternative. I have buried the alternative. Lovely services. Poorly attended."
    -- Only show tiers the bankroll can carry this week (FedRaids conditional-option pattern)
    local costMult = fact.MegaModCfgCost or 1
    if BRScript:PlayerCanAfford(math.floor(TIER_PREMIUM[1] * costMult)) then
        option("$MEGAMOD_INSURANCE_pitch_tier1", insurancePitchBuyTier1) --$ Walking-Around Coverage ($150 a week)
    end
    if BRScript:PlayerCanAfford(math.floor(TIER_PREMIUM[2] * costMult)) then
        option("$MEGAMOD_INSURANCE_pitch_tier2", insurancePitchBuyTier2) --$ The Businessman's Special ($300 a week)
    end
    if BRScript:PlayerCanAfford(math.floor(TIER_PREMIUM[3] * costMult)) then
        option("$MEGAMOD_INSURANCE_pitch_tier3", insurancePitchBuyTier3) --$ The Full Portfolio ($500 a week)
    end
    option("$MEGAMOD_INSURANCE_pitch_decline", insurancePitchDecline) --$ Not today, Abe.
end

-- MEGAMOD: result pages must be separate events (pooled event auto-completes on
-- option click, pages set in callbacks never display -- see FedRaids/SeagramRun)
function Insurance_showResult(titleKey, textKey)
    WorldUtils:triggerEvent("MegaModInsuranceResult", "resultTitle", titleKey, "resultText", textKey)
end

-- Facts are the only channel to the monitor block; premium stored in BASE
-- dollars (CfgCost applied at charge time). First premium lands next Monday.
function Insurance_bindPolicy(tierIdx, confirmTitleKey, confirmTextKey)
    fact.MegaModInsTier = tierIdx
    fact.MegaModInsRate = TIER_RATE[tierIdx]
    fact.MegaModInsCap = TIER_CAP[tierIdx]
    fact.MegaModInsPremium = TIER_PREMIUM[tierIdx]
    fact.MegaModInsLapsedUntil = nil
    fact.MegaModInsClaimsThisMonth = 0
    Insurance_showResult(confirmTitleKey, confirmTextKey)
end

function insurancePitchBuyTier1()
    Insurance_bindPolicy(1, "$MEGAMOD_INSURANCE_bound1_title", "$MEGAMOD_INSURANCE_bound1_text") --$ Covered, Modestly / Abe fills out the certificate in a fine funeral-parlor hand and tears it off like a receipt for your worries. "Walking-around coverage. It will not make you whole, friend, it will make you less broken -- and in Chicago, less broken is a growth industry." He settles his hat. "First premium comes due Monday morning, regular as church. Mutual Assurance thanks you, I thank you, and neither of us hopes to see the other soon."
end

function insurancePitchBuyTier2()
    Insurance_bindPolicy(2, "$MEGAMOD_INSURANCE_bound2_title", "$MEGAMOD_INSURANCE_bound2_text") --$ A Businessman Now / "The Businessman's Special." Abe writes it up with something close to pride. "Six dollars back on every ten, and a ceiling a man can do arithmetic under. This is the policy I sell to men who plan to still be here in five years." A pause, faintly funereal. "Most of them are." The first premium comes due Monday morning, and every Monday after, regular as church.
end

function insurancePitchBuyTier3()
    Insurance_bindPolicy(3, "$MEGAMOD_INSURANCE_bound3_title", "$MEGAMOD_INSURANCE_bound3_text") --$ The Full Portfolio / Abe takes his hat off for this one. "The Full Portfolio. Eight dollars on every ten, six thousand a claim. Friend, this is the finest paper I write. When the fire comes -- and it is Chicago, so let us say when -- you will stand in the smoke a man of means." He shakes your hand the way a pallbearer takes a corner of the casket, solemn and sure. "Monday mornings, five hundred dollars. Sleep like the insured. It is the closest thing to peace this town sells."
end

function insurancePitchDecline()
    Insurance_showResult("$MEGAMOD_INSURANCE_declined_title", "$MEGAMOD_INSURANCE_declined_text") --$ Not Today / Abe closes the rate book without reproach. "Certainly, certainly. Most men say not today. It is the ones who say it twice I read about in the Tribune." He leaves a card on your desk -- MUTUAL ASSURANCE OF COOK COUNTY, A. KAPLAN, and a telephone exchange. The card smells faintly of lilies. "The fire never asks first, friend. But I always do."
end

--[[------------------------------------------------------------------------------
    PITCH RESULT DIALOG (shared; SeagramRun result pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_RESULT"
_event = "MegaModInsuranceResult"
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
    option("$MEGAMOD_INSURANCE_dismiss") --$ So long, Abe.
end

--[[------------------------------------------------------------------------------
    THE UPSELL - occasional one-page upgrade offer while a policy is active
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_UPGRADE"
_event = "MegaModInsuranceUpgrade"
_category = "Misc"

function canTrigger()
    -- The policy may have lapsed or been cancelled in the scheduling gap
    return fact.MegaModInsTier ~= nil and fact.MegaModInsTier < 3
end

-- Next tier up, and its BASE weekly premium (the claims surcharge follows the client)
function Insurance_upgradeTarget()
    local nextTier = (fact.MegaModInsTier or 1) + 1
    if nextTier > 3 then nextTier = 3 end
    local premiumBase = TIER_PREMIUM[nextTier]
    if fact.MegaModInsSurcharged then
        premiumBase = math.floor(premiumBase * SURCHARGE_MULT)
    end
    return nextTier, premiumBase
end

function onTrigger()
    setModal(true)
    local nextTier, premiumBase = Insurance_upgradeTarget()
    local costMult = fact.MegaModCfgCost or 1
    local shownPremium = math.floor(premiumBase * costMult)
    title("$MEGAMOD_INSURANCE_upgrade_title") --$ A Word About Coverage
    if nextTier >= 3 then
        text({"$MEGAMOD_INSURANCE_upgrade_text3", shownPremium}) --$ Abe Kaplan drops by with his rate book and the expression of a man who has seen the future and priced it. "You've done well, friend. Well is expensive to lose. The Full Portfolio: eight dollars back on every ten, six thousand a claim, ${0} a week." He taps the rate book softly. "This is the last policy I will ever need to sell you. Sleep like the insured. It is the closest thing to peace this town sells."
    else
        text({"$MEGAMOD_INSURANCE_upgrade_text2", shownPremium}) --$ Abe Kaplan drops by with his rate book and a look of gentle worry. "I was reviewing your file" -- Abe reviews files the way widows review photographs -- "and it kept me up nights. A man of your holdings on walking-around coverage. Friend, that is a rowboat policy for a steamship life. Step up to the Businessman's Special: six dollars back on every ten, double the ceiling, ${0} a week. The fire does not check which tier you bought. But you will."
    end
    option("$MEGAMOD_INSURANCE_upgrade_accept", insuranceAcceptUpgrade) --$ Write it up, Abe.
    option("$MEGAMOD_INSURANCE_upgrade_decline") --$ My coverage suits me fine.
end

function insuranceAcceptUpgrade()
    if not fact.MegaModInsTier or fact.MegaModInsTier >= 3 then return end
    local nextTier, premiumBase = Insurance_upgradeTarget()
    fact.MegaModInsTier = nextTier
    fact.MegaModInsRate = TIER_RATE[nextTier]
    fact.MegaModInsCap = TIER_CAP[nextTier]
    fact.MegaModInsPremium = premiumBase -- BASE dollars; claims window and surcharge carry over
end

--[[------------------------------------------------------------------------------
    LAPSE NOTICE - premium missed; coverage suspended for 30 days
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_LAPSE"
_event = "MegaModInsuranceLapse"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    title("$MEGAMOD_INSURANCE_lapse_title") --$ A Policy, Lapsed
    text("$MEGAMOD_INSURANCE_lapse_text") --$ Abe Kaplan appears at your door with his hat already in his hands. "Abe regrets to inform you" -- he says it just like that, in the third person, the way doctors and judges do -- "that Mutual Assurance of Cook County has not received your premium, and coverage is therefore suspended." His face was built for regret; it wears it beautifully. "Money mends, friend. Come find me in a month or so, when your luck turns." At the door he pauses. "Assuming, of course, there is anything left to insure."
    option("$MEGAMOD_INSURANCE_lapse_dismiss") --$ I'll manage.
end

--[[------------------------------------------------------------------------------
    CLAIM SETTLEMENT - compact payout notice (amount rides on the event)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_SETTLEMENT"
_event = "MegaModInsuranceSettlement"
_category = "Misc"

persist{}
insPayoutAmount = nil -- Expected Param

function canTrigger()
    return insPayoutAmount ~= nil
end

function onTrigger()
    title("$MEGAMOD_INSURANCE_settle_title") --$ Mutual Assurance Pays
    text({"$MEGAMOD_INSURANCE_settle_text", insPayoutAmount}) --$ Abe Kaplan arrives before the smoke has finished clearing, rate book under one arm and a bank envelope under the other. He counts out ${0} in clean bills onto whatever furniture survived. "Mutual Assurance honors its obligations. Promptly, and with sympathy." He has the decency not to smile until he is back on the sidewalk. Say what you like about Abe -- the man pays like a slot machine that likes you.
    option("$MEGAMOD_INSURANCE_settle_dismiss") --$ Pleasure doing business, Abe.
end

--[[------------------------------------------------------------------------------
    SURCHARGE NOTICE - 3 claims inside 30 days; premium +50%, permanent
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_SURCHARGE"
_event = "MegaModInsuranceSurcharge"
_category = "Misc"

persist{}
insNewPremium = nil -- Expected Param

function canTrigger()
    return insNewPremium ~= nil
end

function onTrigger()
    title("$MEGAMOD_INSURANCE_surcharge_title") --$ An Actuarial Nightmare
    text({"$MEGAMOD_INSURANCE_surcharge_text", insNewPremium}) --$ "Three claims inside a month." Abe lays the file on your desk like a coroner's report. "Friend, I insure against misfortune. You appear to farm it. You are becoming an actuarial nightmare, and my nightmares carry a price." The pen comes out; the rate goes up. Your premium is now ${0} a week -- permanently. "Nothing personal," he says, and the terrible thing is you believe him.
    option("$MEGAMOD_INSURANCE_surcharge_dismiss") --$ Everybody's a critic.
end

--[[------------------------------------------------------------------------------
    CANCELLATION NOTICE - 5 claims inside 30 days; Abe is through with you
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_INSURANCE_CANCELLED"
_event = "MegaModInsuranceCancelled"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    title("$MEGAMOD_INSURANCE_cancel_title") --$ Policy Cancelled
    text("$MEGAMOD_INSURANCE_cancel_text") --$ Abe comes in person, which with Abe is how you know it is a funeral. "Five claims in thirty days. Friend, you do not have bad luck. You are bad luck. My actuaries have taken to drink, and one of them was a Methodist." He retrieves the certificate from your desk gently, the way you would take a bottle from a sleeping man. "Mutual Assurance wishes you long life -- elsewhere, and uninsured." Do not expect him back for a good two months, if he comes back at all.
    option("$MEGAMOD_INSURANCE_cancel_dismiss") --$ Your loss, Abe.
end

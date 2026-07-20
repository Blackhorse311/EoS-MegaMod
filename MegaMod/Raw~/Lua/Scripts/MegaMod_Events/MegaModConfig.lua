--[[------------------------------------------------------------------------------
    MegaMod: Global Config & Difficulty Profiles          << THE TUNING GUIDE >>

    This file is the single place to tune MegaMod's difficulty. Every knob is a
    world fact (facts are global, save-persisted, and readable from every script
    block -- the ONLY cross-file channel in this engine). Every consumer reads
    its knob as `(fact.X or 1)`, so even if this file never runs, everything
    behaves exactly as before (all-1.0 = untuned).

    THE KNOBS (all default 1.0):
      fact.MegaModCfgCost    - multiplier on player COSTS: fees, bribes, fines,
                               ambush outlays, upkeep, loan REPAYMENTS.
                               (Loan principal received is never scaled.)
      fact.MegaModCfgPayout  - multiplier on event PAYOUTS to the player.
                               Never applied to: HardModeBankroll's $20,000
                               (difficulty compensation), SalBonus's $35,000
                               (fixed by design), alcohol quantities, loyalty.
      fact.MegaModCfgHeat    - multiplier on the police-activity amounts OUR
                               events apply. Positive (heat-adding) amounts
                               only; heat REDUCTIONS are never scaled.
      fact.MegaModCfgEvents  - multiplier on the EventDirector's weekly event
                               chance (base 0.35; the scaled chance is clamped
                               to [0, 0.9] in EventDirector.lua).
      fact.MegaModCfgFedHeat - multiplier on Federal Heat gains (consumed by
                               the Federal Heat system; initialized here).
      fact.MegaModProfile    - 1/2/3 once a profile is chosen; nil = not yet.

    THE PROFILES (chosen once per campaign, in a dialog on day 1):
      1 "Speakeasy Stroll"  (easier)  Cost 0.75  Payout 1.25  Heat 0.75  Events 0.80  FedHeat 0.75
      2 "Business as Usual" (normal)  Cost 1.00  Payout 1.00  Heat 1.00  Events 1.00  FedHeat 1.00
      3 "The Full Capone"   (harder)  Cost 1.35  Payout 0.80  Heat 1.40  Events 1.25  FedHeat 1.50

    VANILLA DIFFICULTY BLEND (applied AFTER the profile multipliers, once, in
    the same option callback): WorldUtils:getWorldDifficulty() returns 1..5
    (5 = Boss). If difficulty >= 4, Heat and FedHeat are multiplied by a
    further 1.15; if difficulty <= 2, by 0.85. Normal (3) leaves them alone.
    So e.g. Full Capone on Boss runs Heat 1.40 * 1.15 = 1.61.

    SAFETY: Block A initializes every knob to 1.0 on the campaign's first
    onDayBegin BEFORE the chooser dialog is even scheduled. If the dialog is
    dismissed, lost, or never shows, the 1.0 defaults simply remain and the
    whole mod plays untuned. Choosing a profile is strictly optional.

    To retune: edit the numbers in the three profileChoose* callbacks below
    (and/or the blend numbers in profileApplyDifficultyBlend). Values take
    effect for NEW campaigns / campaigns that have not chosen a profile yet;
    already-chosen campaigns keep the facts saved in their save file.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    BLOCK A: CONFIG BOOTSTRAP - Create-mode listener (HardModeBankroll pattern).
    First onDayBegin: seed all knobs at 1.0, then schedule the profile chooser.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CONFIG_BOOTSTRAP"
_event = "MegaModConfigBootstrap"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onDayBegin(e)
    if fact.MegaModProfile ~= nil then
        -- Profile already chosen (save created before this listener completed);
        -- nothing left for the bootstrap to do.
        complete()
        return
    end

    -- Seed neutral defaults FIRST so every consumer works even if the chooser
    -- dialog below is never seen (dismissed/lost = play untuned at 1.0).
    fact.MegaModCfgCost = 1.0
    fact.MegaModCfgPayout = 1.0
    fact.MegaModCfgHeat = 1.0
    fact.MegaModCfgEvents = 1.0
    fact.MegaModCfgFedHeat = 1.0

    -- Small delay so the chooser doesn't fight the campaign-opening dialogs.
    -- The delayed-event queue is save-persisted (BlackSoxFixer pattern), so the
    -- chooser survives a save/load between now and when it fires.
    WorldUtils:scheduleWithDelay("MegaModProfileChooser", 30, "TICK")
    complete() -- one-shot bootstrap; defaults are live from this moment
end

--[[------------------------------------------------------------------------------
    BLOCK B: PROFILE CHOOSER - modal, three period-flavored options.
    Each option sets the five knobs + fact.MegaModProfile, then blends in the
    vanilla world difficulty (see header). Result page confirms the choice.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PROFILE_CHOOSER"
_event = "MegaModProfileChooser"
_category = "Misc"

function canTrigger()
    return fact.MegaModProfile == nil -- never re-ask once chosen
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_PROFILE_title") --$ How Do You Want to Run This Town?
    text("$MEGAMOD_PROFILE_text") --$ Before the first barrel rolls and the first palm gets greased, ask yourself what kind of outfit this is going to be. Some bosses like the easy money and the quiet streets. Some like it straight. And some want every cop, fed, and rival gun in Chicago coming at them at once -- just to prove it can be done. Choose how the city treats you. There's no changing it once the word is out.
    option("$MEGAMOD_PROFILE_easy", profileChooseEasy) --$ Speakeasy Stroll -- cheaper fees, fatter takes, cooler heat
    option("$MEGAMOD_PROFILE_normal", profileChooseNormal) --$ Business as Usual -- the town plays it straight
    option("$MEGAMOD_PROFILE_hard", profileChooseHard) --$ The Full Capone -- steeper prices, leaner takes, a hotter town
end

-- Vanilla difficulty blend (see header tuning guide): getWorldDifficulty()
-- returns 1..5 (5 = Boss, same read HardModeBankroll uses). Harder worlds run
-- hotter, easier worlds cooler -- applied on top of the profile multipliers.
function profileApplyDifficultyBlend()
    local difficulty = WorldUtils:getWorldDifficulty() or 3
    if difficulty >= 4 then
        fact.MegaModCfgHeat = fact.MegaModCfgHeat * 1.15
        fact.MegaModCfgFedHeat = fact.MegaModCfgFedHeat * 1.15
    elseif difficulty <= 2 then
        fact.MegaModCfgHeat = fact.MegaModCfgHeat * 0.85
        fact.MegaModCfgFedHeat = fact.MegaModCfgFedHeat * 0.85
    end
end

function profileChooseEasy()
    fact.MegaModCfgCost = 0.75
    fact.MegaModCfgPayout = 1.25
    fact.MegaModCfgHeat = 0.75
    fact.MegaModCfgEvents = 0.8
    fact.MegaModCfgFedHeat = 0.75
    fact.MegaModProfile = 1
    profileApplyDifficultyBlend()
    WorldUtils:triggerEvent("MegaModProfileResult",
        "resultTitle", "$MEGAMOD_PROFILE_easy_done_title", --$ A Gentleman's Racket
        "resultText", "$MEGAMOD_PROFILE_easy_done_text") --$ Word goes out that you're the reasonable sort. The fixers shave their fees, the takes run a little fatter, and the beat cops find other blocks to walk. Chicago can be a friendly town -- for a price everybody's happy to pretend they didn't set.
end

function profileChooseNormal()
    fact.MegaModCfgCost = 1.0
    fact.MegaModCfgPayout = 1.0
    fact.MegaModCfgHeat = 1.0
    fact.MegaModCfgEvents = 1.0
    fact.MegaModCfgFedHeat = 1.0
    fact.MegaModProfile = 2
    profileApplyDifficultyBlend()
    WorldUtils:triggerEvent("MegaModProfileResult",
        "resultTitle", "$MEGAMOD_PROFILE_normal_done_title", --$ Straight Business
        "resultText", "$MEGAMOD_PROFILE_normal_done_text") --$ No favors asked, none given. The city charges what it charges, pays what it pays, and the law leans exactly as hard as the law leans. Whatever you build, you'll have built it on the same crooked ground as everybody else.
end

function profileChooseHard()
    fact.MegaModCfgCost = 1.35
    fact.MegaModCfgPayout = 0.8
    fact.MegaModCfgHeat = 1.4
    fact.MegaModCfgEvents = 1.25
    fact.MegaModCfgFedHeat = 1.5
    fact.MegaModProfile = 3
    profileApplyDifficultyBlend()
    WorldUtils:triggerEvent("MegaModProfileResult",
        "resultTitle", "$MEGAMOD_PROFILE_hard_done_title", --$ The Hard Way
        "resultText", "$MEGAMOD_PROFILE_hard_done_text") --$ You want it the way the big fella had it: every hand out for more, every take squeezed thin, and half the badges in Cook County memorizing your license plate. The town is going to test you every week it can manage. Good. Empires built easy fall easy.
end

--[[------------------------------------------------------------------------------
    PROFILE RESULT DIALOG (generic resultTitle/resultText pattern -- see RumRow)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PROFILE_RESULT"
_event = "MegaModProfileResult"
_category = "Misc"

persist{}
resultTitle = nil

persist{}
resultText = nil

function canTrigger()
    return resultTitle ~= nil
end

function onTrigger()
    setModal(true)
    title(resultTitle)
    text(resultText)
    option("$MEGAMOD_PROFILE_dismiss") --$ That's how we'll play it.
end

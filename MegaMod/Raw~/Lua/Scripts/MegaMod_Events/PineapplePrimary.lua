--[[------------------------------------------------------------------------------
    MegaMod: Pineapple Season (EventDirector: PINEAPPLE_PRIMARY)
    Election season in Chicago, and the primary is being fought with
    "pineapples" -- hand grenades -- as much as with ballots. The Thompson
    machine and the reform crowd are both hiring muscle; Diamond Joe
    Esposito already got his for picking the wrong side. Sixty-two bombings
    and counting. Democracy, Chicago style.

    ONCE-ONLY: gated by fact.MegaModPineappleDone (set at launch). The
    director also enforces this, but the local guard makes it airtight.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass).
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PINEAPPLE_PRIMARY_LISTENER"
_event = "MegaModPineapplePrimaryListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if e.eventName ~= "PINEAPPLE_PRIMARY" then return end

    -- Once-only: never run a second election season
    if fact.MegaModPineappleDone then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "PINEAPPLE_PRIMARY")
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings or #playerFaction.buildings < 1 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "PINEAPPLE_PRIMARY")
        return
    end

    fact.MegaModPineappleDone = 1 -- gate immediately so it can never re-pitch
    WorldUtils:scheduleWithDelay("MegaModPineapplePrimary", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "PINEAPPLE_PRIMARY")
end

--[[------------------------------------------------------------------------------
    ELECTION SEASON
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_PINEAPPLE_PRIMARY_EVENT"
_event = "MegaModPineapplePrimary"
_category = "Misc"

-- Find the precinct where the player has the most buildings (TheUntouchable shape)
function pineappleBusiestPrecinct(playerFaction)
    if not playerFaction or not playerFaction.buildings then return nil end
    local precinctCounts = {}
    local bestPrecinct = nil
    local bestCount = 0
    for _, building in next, playerFaction.buildings do
        if building then
            local p = building:getPrecinct()
            if p then
                precinctCounts[p] = (precinctCounts[p] or 0) + 1
                if precinctCounts[p] > bestCount then
                    bestCount = precinctCounts[p]
                    bestPrecinct = p
                end
            end
        end
    end
    return bestPrecinct
end

-- Pick a random known, active rival gang (RivalProvocations shape)
function pineappleRandomRival(playerFaction)
    if not playerFaction or not playerFaction.diplomacy then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs or #knownGangs == 0 then return nil end
    local activeRivals = {}
    for i = 1, #knownGangs do
        if knownGangs[i]._active then
            activeRivals[#activeRivals + 1] = knownGangs[i]
        end
    end
    if #activeRivals == 0 then return nil end
    return activeRivals[math.random(1, #activeRivals)]
end

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_PINEAPPLE_offer_title") --$ Pineapple Season
    text("$MEGAMOD_PINEAPPLE_offer_text") --$ Primary season is here, and Chicago is celebrating the way only Chicago can: with hand grenades. "Pineapples," the papers call them, and they've been going off all over town -- candidates' porches, ward offices, polling places. Diamond Joe Esposito told the machine he was done running errands, and they found him on his own street with fifty-seven slugs in him and a wife screaming on the curb. Now both sides are shopping for muscle. The machine pays top dollar for men who can make a polling place change its mind. The reform crowd pays less, but they pay in something rarer -- the cops looking kindly on you for a change. Or you can keep your head down until the confetti and the shrapnel settle.
    option("$MEGAMOD_PINEAPPLE_offer_machine", pineappleWorkForMachine) --$ Take the machine's money. Bomb duty pays.
    option("$MEGAMOD_PINEAPPLE_offer_reform", pineappleGuardPolls) --$ Guard the polls for the reformers.
    option("$MEGAMOD_PINEAPPLE_offer_sitout", pineappleSitOut) --$ Sit this dance out.
end

function pineappleWorkForMachine()
    BRScript:PlayerAddCash(2000, "CASH.MISSION_REWARD")

    local playerFaction = WorldUtils:getPlayerFaction()
    local precinct = pineappleBusiestPrecinct(playerFaction)
    if precinct then
        precinct:addTemporaryPoliceActivity(20)
    end

    -- Somebody's ward boss was backing the other slate, and they know who threw for the machine
    local rival = pineappleRandomRival(playerFaction)
    if rival then
        rival.rating:applyEffect(playerFaction, "AGGRESSIVE_BEHAVIOUR")
    end

    title("$MEGAMOD_PINEAPPLE_machine_title") --$ Bomb Duty
    text("$MEGAMOD_PINEAPPLE_machine_text") --$ For two weeks your boys deliver pineapples the way other men deliver milk -- early, quietly, and to the correct address. A reform candidate's garage. A ward office that counted wrong. Nobody gets killed; that's the professionalism you're being paid for. The machine settles up with $2,000 and a handshake from a man who is careful never to give his name. But the blasts have every cop in your best neighborhood shaking doors, and one of the other outfits had money on the reform slate. They know exactly whose boys were throwing, and they won't forget it.
    option("$MEGAMOD_PINEAPPLE_dismiss_machine") --$ Politics is a rough trade.
end

function pineappleGuardPolls()
    BRScript:PlayerAddCash(800, "CASH.MISSION_REWARD")

    local playerFaction = WorldUtils:getPlayerFaction()
    local precinct = pineappleBusiestPrecinct(playerFaction)
    if precinct then
        precinct:addTemporaryPoliceActivity(-10)
    end

    title("$MEGAMOD_PINEAPPLE_reform_title") --$ Honest Muscle
    text("$MEGAMOD_PINEAPPLE_reform_text") --$ There's a first time for everything: your torpedoes spend election day standing outside polling places making sure nobody ELSE steals the vote. The machine's sluggers take one look at your boys and remember appointments elsewhere. The reform committee pays $800 -- from a church collection plate, by the look of it -- and a police captain actually shakes your hand in public. In your best neighborhood, the beat cops have quietly decided your operation is the tolerable kind. It won't last. But it's nice while it does.
    option("$MEGAMOD_PINEAPPLE_dismiss_reform") --$ Don't tell anyone I did this.
end

function pineappleSitOut()
    title("$MEGAMOD_PINEAPPLE_sitout_title") --$ Neutral Territory
    text("$MEGAMOD_PINEAPPLE_sitout_text") --$ You pass the word: nobody in your outfit touches election work, not for the machine's money and not for the reformers' gratitude. Let the politicians blow each other's porches off. The primary comes and goes -- sixty-two bombings, the papers count, a new record even for this town -- and when the dust settles, the same sort of men are running things under a different letterhead. Your name stayed out of every account. In an election like this one, that's its own kind of victory.
    option("$MEGAMOD_PINEAPPLE_dismiss_sitout") --$ The house doesn't bet on politics.
end

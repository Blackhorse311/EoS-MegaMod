--[[------------------------------------------------------------------------------
    MegaMod: Federal Heat -- "The Eyes of Washington"

    A 0-100 pressure meter (fact.MegaModFedHeat) tracking how much attention
    Washington is paying to the player's empire, with four one-way escalation
    stages (fact.MegaModFedStage, 0-4) and a slow road back down for bosses
    who cool off.

    ========================== PUBLIC FEED CONTRACT ============================
    ANY MegaMod script may add Federal Heat with this one line (no listener,
    no handshake -- world facts are save-persisted and visible everywhere):

        fact.MegaModFedHeat = math.min(100, (fact.MegaModFedHeat or 0) + N * (fact.MegaModCfgFedHeat or 1))

    Typical feed sizes: N = 2-5 for minor infractions (shakedowns, bribes gone
    loud, hijackings), N = 8-15 for atrocities (massacres, cop killings, a
    bombing on a public street). The monitor below reacts on the next day/week
    boundary; feeds never touch stage logic themselves.
    ============================================================================

    Stage machine (each stage entered only from the stage directly below it):
      0 -> 1 at meter >= 25  "Field Office Notice"    warning + heat on busiest precinct
      1 -> 2 at meter >= 45  "Padlock Injunctions"    2 precincts hit; pay court costs to halve
      2 -> 3 at meter >= 70  "The Special Squad"      raids every 2 weeks while meter >= 60
      3 -> 4 at meter >= 90  "United States v. You"   the tax trial, ONCE only, then back to stage 2
    De-escalation: meter below (stage threshold - 15) drops one stage per week
    (never from stage 4 -- the trial always resolves through its own dialog).

    Config facts (initialized elsewhere; always read with `or 1` fallback):
      fact.MegaModCfgCost   scales fines/fees     fact.MegaModCfgPayout  scales rewards
      fact.MegaModCfgHeat   scales precinct heat  fact.MegaModCfgFedHeat scales ALL meter gains
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

-- ---------------------------------------------------------------------------
-- Tunables
-- ---------------------------------------------------------------------------
local FEDHEAT_THRESHOLD_S1 = 25      -- meter needed to enter stage 1 (Field Office Notice)
local FEDHEAT_THRESHOLD_S2 = 45      -- stage 2 (Padlock Injunctions)
local FEDHEAT_THRESHOLD_S3 = 70      -- stage 3 (The Special Squad)
local FEDHEAT_THRESHOLD_S4 = 90      -- stage 4 (United States v. You), once only
local FEDHEAT_DROP_MARGIN = 15       -- fall this far below a stage's threshold -> drop one stage
local FEDHEAT_WEEKLY_DECAY = 2       -- meter decay per week (floor 0; decay is NOT config-scaled)
local FEDHEAT_EMPIRE_FREE = 10       -- rackets the feds ignore
local FEDHEAT_EMPIRE_PER = 10        -- +1 meter/week per this many rackets above FEDHEAT_EMPIRE_FREE
local FEDHEAT_S1_HEAT = 5            -- precinct heat on the busiest precinct at stage 1 (x CfgHeat)
local FEDHEAT_S2_HEAT = 20           -- precinct heat per padlocked precinct at stage 2 (x CfgHeat)
local FEDHEAT_S2_COURT_COST = 1500   -- court costs to halve stage 2's effect (x CfgCost)
local FEDHEAT_SQUAD_PERIOD_DAYS = 14 -- days between Special Squad raids
local FEDHEAT_SQUAD_FLOOR = 60       -- squad stands down when the meter falls below this
local FEDHEAT_SQUAD_DUMP = 0.10      -- fraction of stored alcohol destroyed per squad raid
local FEDHEAT_SQUAD_HEAT = 8         -- precinct heat per squad raid (x CfgHeat)
local FEDHEAT_SETTLE_FRACTION = 0.25 -- settle: fraction of cash on hand paid
local FEDHEAT_SETTLE_MIN = 2000      -- settle: minimum payment (x CfgCost, capped at cash on hand)
local FEDHEAT_WIN_CHANCE = 0.50      -- fight it: chance of acquittal
local FEDHEAT_LOSE_FRACTION = 0.35   -- fight and lose: fraction of cash on hand paid
local FEDHEAT_SENTENCE_DAYS = 14     -- fight and lose: boss SentAway (the stretch in Atlanta)
local FEDHEAT_WIN_CASH = 500         -- fight and win: vindication press boon (x CfgPayout)
local FEDHEAT_METER_AFTER_SETTLE = 40
local FEDHEAT_METER_AFTER_WIN = 30
local FEDHEAT_METER_AFTER_LOSE = 25

--[[------------------------------------------------------------------------------
    FEDERAL HEAT MONITOR - permanent Create-mode listener (owns meter movement)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FEDHEAT_MONITOR"
_event = "MegaModFedHeatMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent listener; must never auto-complete
end

-- Helpers are plain GLOBAL functions (local functions lose the sandbox env,
-- so fact / WorldUtils / Utils would be unreachable) -- see EventDirector.lua

function FedHeat_thresholdFor(stage)
    if stage == 1 then return FEDHEAT_THRESHOLD_S1 end
    if stage == 2 then return FEDHEAT_THRESHOLD_S2 end
    if stage == 3 then return FEDHEAT_THRESHOLD_S3 end
    if stage == 4 then return FEDHEAT_THRESHOLD_S4 end
    return nil
end

-- One stage per check, always from the stage directly below. A big meter
-- spike still walks 1 -> 2 -> 3 across consecutive daily checks -- deliberate
-- pacing so each announcement lands on its own.
function FedHeat_checkEscalation()
    local stage = fact.MegaModFedStage or 0
    if stage >= 4 then return end
    if stage == 3 and (fact.MegaModFedTrialDone or 0) ~= 0 then return end -- the trial happens once, ever
    local nextThreshold = FedHeat_thresholdFor(stage + 1)
    if (fact.MegaModFedHeat or 0) >= nextThreshold then
        fact.MegaModFedStage = stage + 1 -- gate immediately so the stage can't double-fire
        WorldUtils:scheduleWithDelay("MegaModFedHeatStage" .. (stage + 1), 5, "TICK")
    end
end

function FedHeat_checkDeescalation()
    local stage = fact.MegaModFedStage or 0
    if stage < 1 or stage >= 4 then return end -- never from 4 mid-chain
    local threshold = FedHeat_thresholdFor(stage)
    if (fact.MegaModFedHeat or 0) < (threshold - FEDHEAT_DROP_MARGIN) then
        fact.MegaModFedStage = stage - 1
        WorldUtils:scheduleWithDelay("MegaModFedHeatCooldown", 5, "TICK")
    end
end

function GameEvent.onWeekBegin(e)
    local meter = fact.MegaModFedHeat or 0

    -- Passive gain: empire size draws eyes. +1/week per 10 owned rackets
    -- above 10, scaled like every other meter gain by CfgFedHeat.
    local rackets = MissionUtils:controlledRackets()
    local count = rackets and #rackets or 0
    if count > FEDHEAT_EMPIRE_FREE then
        local gain = math.floor((count - FEDHEAT_EMPIRE_FREE) / FEDHEAT_EMPIRE_PER)
        meter = meter + gain * (fact.MegaModCfgFedHeat or 1)
    end

    -- Weekly decay: Washington has a short memory when nothing new crosses the wire
    meter = meter - FEDHEAT_WEEKLY_DECAY
    if meter < 0 then meter = 0 end
    if meter > 100 then meter = 100 end
    fact.MegaModFedHeat = meter

    FedHeat_checkEscalation()
    FedHeat_checkDeescalation()
end

-- Other scripts feed the meter at any moment (PUBLIC FEED CONTRACT, header).
-- A daily escalation check keeps the response prompt without waiting for the
-- week boundary. Gain/decay/de-escalation stay weekly.
function GameEvent.onDayBegin(e)
    FedHeat_checkEscalation()
end

--[[------------------------------------------------------------------------------
    STAGE 1: Field Office Notice (meter >= 25)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FEDHEAT_STAGE1"
_event = "MegaModFedHeatStage1"
_category = "Misc"

-- Busiest precinct = where the player has the most buildings (TheUntouchable shape)
function FedHeat_s1BusiestPrecinct()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return nil end
    local counts = {}
    local best = nil
    local bestCount = 0
    for _, building in next, playerFaction.buildings do
        if building then
            local p = building:getPrecinct()
            if p then
                counts[p] = (counts[p] or 0) + 1
                if counts[p] > bestCount then
                    bestCount = counts[p]
                    best = p
                end
            end
        end
    end
    return best
end

function canTrigger() return true end

function onTrigger()
    local precinct = FedHeat_s1BusiestPrecinct()
    if precinct then
        local heat = math.floor(FEDHEAT_S1_HEAT * (fact.MegaModCfgHeat or 1))
        if heat > 0 then
            precinct:addTemporaryPoliceActivity(heat) -- real heat; the game event below is only the UI toast
            Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                "alertKey", "MEGAMOD_FEDHEAT_S1",
                "appliedPoliceActivity", heat,
                "originalValue", precinct:getPoliceActivity() or 0,
                "effectId", "MEGAMOD_FEDHEAT_STAGE1",
                "precinct", precinct,
                "description", {"$Text", "Federal Field Office Notice"})
        end
    end

    setModal(true)
    title("$MEGAMOD_FEDHEAT_s1_title") --$ A Letter from the Field Office
    text("$MEGAMOD_FEDHEAT_s1_text") --$ It arrives on Treasury stationery, polite as a hymn: the Bureau of Internal Revenue has opened a file with your name on the tab. A clerk you pay in a downtown records office says two men from Washington spent a full day pulling deeds, licenses, and newspaper clippings -- everything with your fingerprints on it. The Revenue boys don't kick down doors. They read. And somewhere in an office a thousand miles east, somebody has started reading about you. The local cops, smelling which way the wind blows, have stepped up patrols around your busiest corner of town.
    option("$MEGAMOD_FEDHEAT_s1_dismiss") --$ Let them read. There's nothing in writing.
end

--[[------------------------------------------------------------------------------
    STAGE 2: Padlock Injunctions (meter >= 45)
    Two random racket precincts take heat; the player may pay court costs
    to halve the effect.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FEDHEAT_STAGE2"
_event = "MegaModFedHeatStage2"
_category = "Misc"

persist{}
padlockPrecinctA = nil -- picked in onTrigger; persisted so a save mid-dialog survives

persist{}
padlockPrecinctB = nil

function FedHeat_s2ApplyHeat(mult)
    local heat = math.floor(FEDHEAT_S2_HEAT * mult * (fact.MegaModCfgHeat or 1))
    if heat <= 0 then return end
    local ids = { padlockPrecinctA, padlockPrecinctB }
    for i = 1, #ids do
        local precinct = WorldUtils:getPrecinct(ids[i])
        if precinct then
            precinct:addTemporaryPoliceActivity(heat) -- real heat; the game event below is only the UI toast
            Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                "alertKey", "MEGAMOD_FEDHEAT_S2_" .. tostring(ids[i]),
                "appliedPoliceActivity", heat,
                "originalValue", precinct:getPoliceActivity() or 0,
                "effectId", "MEGAMOD_FEDHEAT_STAGE2",
                "precinct", precinct,
                "description", {"$Text", "Federal Padlock Injunction"})
        end
    end
end

function canTrigger() return true end

function onTrigger()
    -- Pick up to two distinct precincts where the player runs rackets
    local rackets = MissionUtils:controlledRackets()
    local ids = {}
    local seen = {}
    if rackets then
        for i = 1, #rackets do
            local p = rackets[i]:getPrecinct()
            if p and not seen[p.id] then
                seen[p.id] = true
                ids[#ids + 1] = p.id
            end
        end
    end
    if #ids > 0 then
        padlockPrecinctA = ids[math.random(#ids)]
        if #ids > 1 then
            repeat
                padlockPrecinctB = ids[math.random(#ids)]
            until padlockPrecinctB ~= padlockPrecinctA
        end
    end

    local courtCost = math.floor(FEDHEAT_S2_COURT_COST * (fact.MegaModCfgCost or 1))

    setModal(true)
    title("$MEGAMOD_FEDHEAT_s2_title") --$ Padlock Injunctions
    text({"$MEGAMOD_FEDHEAT_s2_text", courtCost}) --$ A federal marshal with a leather folder serves the papers before lunch: injunctions under the Volstead Act, sworn before a federal judge, naming properties in two of your neighborhoods as public nuisances. Padlocks on the doors, a year's closure if the government has its way, and cops crawling over both precincts while the paperwork grinds. Your lawyer says he can gut the worst of it -- keep the doors open, quash half the mess -- but federal court runs on retainers and filing fees. About ${0} worth.
    if BRScript:PlayerCanAfford(courtCost) then
        option({"$MEGAMOD_FEDHEAT_s2_pay", courtCost}, FedHeat_s2PayCourtCosts) --$ Pay the lawyers (${0})
    end
    option("$MEGAMOD_FEDHEAT_s2_eat", FedHeat_s2EatIt) --$ Eat it. Padlocks come off eventually.
end

function FedHeat_s2PayCourtCosts()
    local courtCost = math.floor(FEDHEAT_S2_COURT_COST * (fact.MegaModCfgCost or 1))
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.cash or playerFaction.cash.count < courtCost then
        -- Till emptied between page and click: the full injunctions land
        FedHeat_s2ApplyHeat(1)
        title("$MEGAMOD_FEDHEAT_s2_broke_title") --$ The Retainer Bounces
        text("$MEGAMOD_FEDHEAT_s2_broke_text") --$ The till won't cover the retainer, and federal lawyers don't work on promises. The injunctions go unanswered, the padlocks go on, and both neighborhoods get the full treatment -- marshals, patrolmen, photographers from the papers. An expensive lesson in keeping cash for a rainy day, because in this business it rains.
        option("$MEGAMOD_FEDHEAT_s2_dismiss") --$ Back to business.
        return
    end

    BRScript:PlayerSubtractCash(courtCost, "CASH.EXPENSES")
    FedHeat_s2ApplyHeat(0.5)

    title("$MEGAMOD_FEDHEAT_s2_paid_title") --$ Quashed in Chambers
    text("$MEGAMOD_FEDHEAT_s2_paid_text") --$ Your man in the good suit earns his fee. Half the injunctions die in chambers on technicalities -- a bad affidavit here, a mislaid warrant there -- and the padlocks come off most of the doors by Friday. The neighborhoods still crawl with blue uniforms, but it's half the trouble it might have been. The clerk of the court is very sorry for the inconvenience.
    option("$MEGAMOD_FEDHEAT_s2_dismiss") --$ Back to business.
end

function FedHeat_s2EatIt()
    FedHeat_s2ApplyHeat(1)

    title("$MEGAMOD_FEDHEAT_s2_eat_title") --$ Padlocked
    text("$MEGAMOD_FEDHEAT_s2_eat_text") --$ You let the injunctions stand. Marshals march through both neighborhoods like it's a parade, hanging government padlocks and posting notices, trailed by every beat cop with nothing better to do. The heat in both precincts climbs to something fierce. Padlocks come off eventually -- but Washington has learned that you don't fight back in court, and that's worth remembering too.
    option("$MEGAMOD_FEDHEAT_s2_dismiss") --$ Back to business.
end

--[[------------------------------------------------------------------------------
    STAGE 3: The Special Squad (meter >= 70)
    Announces the task force and starts the recurring raid chain below.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FEDHEAT_STAGE3"
_event = "MegaModFedHeatStage3"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_FEDHEAT_s3_title") --$ The Special Squad
    text("$MEGAMOD_FEDHEAT_s3_text") --$ The papers get the story before you do: the Prohibition Bureau has stood up a special squad for Chicago -- nine young agents, hand-picked, every one of them checked back to the cradle for debts, vices, and relatives who might take a dollar. Their leader is a college boy with a pressed suit and no price anybody can find. They've got trucks, axes, a wiretap man, and a standing warrant list with your operations on it. Until Washington loses interest, they're going to keep coming -- warehouse by warehouse, still by still.
    option("$MEGAMOD_FEDHEAT_s3_dismiss") --$ Find out who picked them. Everybody answers to somebody.

    -- Start the raid chain (only one chain at a time; a pending tick from an
    -- earlier stage-3 episode keeps its own schedule)
    if (fact.MegaModFedSquadActive or 0) == 0 then
        fact.MegaModFedSquadActive = 1
        WorldUtils:scheduleWithDelay("MegaModFedHeatSquadTick",
            Utils:daysToSecs(FEDHEAT_SQUAD_PERIOD_DAYS), "TICK")
    end
end

--[[------------------------------------------------------------------------------
    SPECIAL SQUAD RAID TICK - self-rescheduling chain (every 2 weeks)
    Stops (no reschedule) when the meter drops below FEDHEAT_SQUAD_FLOOR, the
    stage leaves 3 (de-escalation or the trial), or there is nothing to raid.
    scheduleWithDelay chains survive save/load (_delayedEvents is persisted).
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FEDHEAT_SQUAD_TICK"
_event = "MegaModFedHeatSquadTick"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    local stage = fact.MegaModFedStage or 0
    local meter = fact.MegaModFedHeat or 0
    local rackets = MissionUtils:controlledRackets()

    if stage ~= 3 or meter < FEDHEAT_SQUAD_FLOOR or not rackets or #rackets == 0 then
        fact.MegaModFedSquadActive = 0 -- a later stage 3 may start a fresh chain
        title("$MEGAMOD_FEDHEAT_standdown_title") --$ The Squad Stands Down
        text("$MEGAMOD_FEDHEAT_standdown_text") --$ Word from a friendly clerk in the federal building: the special squad's funding didn't survive the month. The trucks are reassigned, the college boy is writing reports, and the standing warrant list is filed in a basement. Washington's eye has wandered elsewhere -- for now. It would be a mistake to give them a reason to look back.
        option("$MEGAMOD_FEDHEAT_standdown_dismiss") --$ Good riddance to the boy scouts.
        return
    end

    -- The raid (FedRaids pattern): smash the barrels, spike the precinct
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.alcohol then
        local loss = math.floor(playerFaction.alcohol.stored * FEDHEAT_SQUAD_DUMP)
        if loss > 0 then
            playerFaction.alcohol:dump(nil, loss)
        end
    end
    local target = rackets[math.random(#rackets)]
    local precinct = target and target:getPrecinct()
    if precinct then
        local heat = math.floor(FEDHEAT_SQUAD_HEAT * (fact.MegaModCfgHeat or 1))
        if heat > 0 then
            precinct:addTemporaryPoliceActivity(heat)
        end
    end

    title("$MEGAMOD_FEDHEAT_raid_title") --$ The Squad Hits Again
    text("$MEGAMOD_FEDHEAT_raid_text") --$ Flatbed trucks and federal axes, right through the front door at dawn. The special squad smashes one of your operations with newspapermen conveniently on hand -- barrels split on the curb, good liquor running in the gutter, a padlock on the door, and a young agent giving the photographers his good side. A tenth of your stock gone and the neighborhood swarming with law. They'll keep this up as long as Washington stays hot.
    option("$MEGAMOD_FEDHEAT_raid_dismiss") --$ Every parade ends sometime.

    WorldUtils:scheduleWithDelay("MegaModFedHeatSquadTick",
        Utils:daysToSecs(FEDHEAT_SQUAD_PERIOD_DAYS), "TICK")
end

--[[------------------------------------------------------------------------------
    STAGE 4: United States v. You (meter >= 90, ONCE only)
    The tax trial. Settle, or roll the dice in front of a federal jury.
    Both roads lead back to stage 2 -- but only one of them through Atlanta.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FEDHEAT_STAGE4"
_event = "MegaModFedHeatStage4"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    fact.MegaModFedTrialDone = 1 -- once only, ever (the monitor never schedules stage 4 again)

    setModal(true)
    title("$MEGAMOD_FEDHEAT_s4_title") --$ United States v. You
    text("$MEGAMOD_FEDHEAT_s4_text") --$ A federal grand jury returns the indictment on a gray morning: income tax evasion, count after count, years of the good life itemized by men with adding machines. It was never the guns that were going to get you -- the Supreme Court settled it in '27: illegal income is taxable income, and the Intelligence Unit has been buying your ledgers off bookkeepers and back-room men for a year. Your lawyer lays it out plain. The government will take a settlement -- a quarter of everything liquid -- and call the ledger square. Or you roll the dice in front of a federal jury, where a man can walk out vindicated, or ride the train to the penitentiary in Atlanta.
    option("$MEGAMOD_FEDHEAT_s4_settle", FedHeat_trialSettle) --$ Settle. Pay the Revenue boys and be done.
    option("$MEGAMOD_FEDHEAT_s4_fight", FedHeat_trialFight) --$ Fight it. No jury in Chicago will convict me.
end

function FedHeat_trialSettle()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cash = (playerFaction and playerFaction.cash and playerFaction.cash.count) or 0
    local fine = math.floor(cash * FEDHEAT_SETTLE_FRACTION)
    local minFine = math.floor(FEDHEAT_SETTLE_MIN * (fact.MegaModCfgCost or 1))
    if fine < minFine then fine = minFine end
    if fine > cash then fine = cash end -- never overdraw the till
    if fine > 0 then
        BRScript:PlayerSubtractCash(fine, "CASH.FINE")
    end
    fact.MegaModFedHeat = FEDHEAT_METER_AFTER_SETTLE
    fact.MegaModFedStage = 2

    title("$MEGAMOD_FEDHEAT_settle_title") --$ The Ledger Squared
    text({"$MEGAMOD_FEDHEAT_settle_text", fine}) --$ The lawyers shake hands in a marble hallway and it's done: ${0} to the Treasury, a signed schedule of back taxes, and no admissions read aloud. The papers call it a scandal; your accountant calls it the best money you ever spent. The file stays open -- files like yours never close -- but the men with adding machines pack up their year of work and go bother somebody else, and you sleep in your own bed.
    option("$MEGAMOD_FEDHEAT_settle_dismiss") --$ Money's cheaper than martyrdom.
end

function FedHeat_trialFight()
    local playerFaction = WorldUtils:getPlayerFaction()

    if math.random() < FEDHEAT_WIN_CHANCE then
        local reward = math.floor(FEDHEAT_WIN_CASH * (fact.MegaModCfgPayout or 1))
        if reward > 0 then
            BRScript:PlayerAddCash(reward, "CASH.MISSION_REWARD")
        end
        fact.MegaModFedHeat = FEDHEAT_METER_AFTER_WIN
        fact.MegaModFedStage = 2

        title("$MEGAMOD_FEDHEAT_win_title") --$ Vindicated
        text({"$MEGAMOD_FEDHEAT_win_text", reward}) --$ The foreman says the words -- not guilty, count after count -- and the courtroom comes apart. The government's ledger men couldn't make their columns speak plainer than your lawyer, and twelve honest citizens decided the government's arithmetic wasn't proof of anything. You walk down the courthouse steps a persecuted businessman, and the papers eat it up. Subscriptions, sympathy, and ${0} in what your man calls 'goodwill appearances.' Washington slinks off to lick its sums.
        option("$MEGAMOD_FEDHEAT_win_dismiss") --$ Let them print THAT.
    else
        local cash = (playerFaction and playerFaction.cash and playerFaction.cash.count) or 0
        local fine = math.floor(cash * FEDHEAT_LOSE_FRACTION)
        if fine > 0 then
            BRScript:PlayerSubtractCash(fine, "CASH.FINE")
        end
        if playerFaction and playerFaction.boss then
            playerFaction.boss:addState("SentAway", "timeAway", FEDHEAT_SENTENCE_DAYS,
                "dontShowReturnEvent", true)
        end
        fact.MegaModFedHeat = FEDHEAT_METER_AFTER_LOSE
        fact.MegaModFedStage = 2

        title("$MEGAMOD_FEDHEAT_lose_title") --$ A Stretch in Atlanta
        text({"$MEGAMOD_FEDHEAT_lose_text", fine}) --$ The jury is out ninety minutes. Guilty. The judge doesn't smile as he hands it down: the fine takes ${0} out of the till, and there's a stretch in the federal penitentiary at Atlanta with your name on it. They'll say it in every speakeasy from here to the coast: the government couldn't get him with the guns, so they got him with a fountain pen. The outfit holds the fort while the boss wears gray -- and every man in it learns exactly how much of the empire runs on your say-so.
        option("$MEGAMOD_FEDHEAT_lose_dismiss") --$ Hold the fort. I'll be back.
    end
end

--[[------------------------------------------------------------------------------
    COOLDOWN NOTICE - shown when the meter falls far enough to drop a stage
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FEDHEAT_COOLDOWN"
_event = "MegaModFedHeatCooldown"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_FEDHEAT_cool_title") --$ The Heat Cools
    text("$MEGAMOD_FEDHEAT_cool_text") --$ A friendly voice in the federal building passes it along: your file has moved down the stack. Budgets are thin, other towns are louder, and the men from Washington have bigger headaches than you this month. The watchers thin out, the wires go quiet. Nobody burns the file, mind -- they never burn the file. But for now, the eyes of Washington are looking somewhere else.
    option("$MEGAMOD_FEDHEAT_cool_dismiss") --$ Keep it that way.
end

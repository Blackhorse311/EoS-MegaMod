--[[------------------------------------------------------------------------------
    MegaMod: Black Sox Fixer
    Multi-stage event chain. A gambler named "Silk" Sullivan offers to fix
    boxing matches at your casino. Invest, profit, then choose: go big or
    cash out.

    Chain state lives in fact.MegaModBlackSoxStage (world facts are save-
    persisted and visible to every _id block, unlike script vars):
      nil/0 = not started, 1 = pitch pending, 2 = invested,
      3 = first payout collected, 4 = chain over
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    STAGE 1: The Pitch
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BLACKSOX_PITCH"
_event = "MegaModBlackSoxPitch"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BSOX_pitch_title") --$ The Pitch
    text("$MEGAMOD_BSOX_pitch_text") --$ A slick character named "Silk" Sullivan slides into your office uninvited. He's wearing a suit that costs more than most people's rent and a grin that says he knows something you don't. "I can fix fights," he says. "Boxing. The real deal. You put up $2000, I make sure the right man goes down in the right round. Your casino takes the bets, we split the winnings. Easy money." He leans back. "Whaddya say, boss?"
    option("$MEGAMOD_BSOX_pitch_invest", investInFix) --$ Invest $2000
    option("$MEGAMOD_BSOX_pitch_pass", passOnFix) --$ Show him the door
end

function investInFix()
    local cost = math.floor(2000 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together; monitor gate matches)
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction.cash.count < cost then
        title("$MEGAMOD_BSOX_pitch_broke_title") --$ Short on Cash
        text("$MEGAMOD_BSOX_pitch_broke_text") --$ You reach for the bankroll but it's lighter than expected. Silk notices and tips his hat. "Maybe next time, boss." He's gone before you can respond.
        option("$MEGAMOD_BSOX_dismiss") --$ Next time.
        fact.MegaModBlackSoxStage = 4 -- done, can't retry
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.INVESTMENT")
    fact.MegaModBlackSoxStage = 2

    title("$MEGAMOD_BSOX_pitch_invested_title") --$ Money Down
    text("$MEGAMOD_BSOX_pitch_invested_text") --$ You peel off twenty crisp hundreds and slide them across the desk. Silk pockets the money with practiced ease. "You won't regret this, boss. First fight is next week. I'll be in touch." He tips his hat and vanishes like smoke.
    option("$MEGAMOD_BSOX_dismiss") --$ We'll see.

    -- MEGAMOD FIX: schedule stage 2 directly; _delayedEvents survives save/load,
    -- unlike worldTimeCallback which died when this event completed
    WorldUtils:scheduleWithDelay("MegaModBlackSoxPayout", Utils:daysToSecs(7), "TICK")
end

function passOnFix()
    fact.MegaModBlackSoxStage = 4

    title("$MEGAMOD_BSOX_pitch_pass_title") --$ Shown the Door
    text("$MEGAMOD_BSOX_pitch_pass_text") --$ "Get out of my office." Silk holds up his hands, still grinning. "Your loss, boss. This kind of deal doesn't come around twice." He straightens his tie and walks out. You've got a feeling he'll find another sucker by sundown.
    option("$MEGAMOD_BSOX_dismiss") --$ Good riddance.
end

--[[------------------------------------------------------------------------------
    STAGE 2: First Payout
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BLACKSOX_PAYOUT"
_event = "MegaModBlackSoxPayout"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    BRScript:PlayerAddCash(math.floor(4000 * (fact.MegaModCfgPayout or 1)), "CASH.MISSION_REWARD") -- MEGAMOD CONFIG: payout knob
    fact.MegaModBlackSoxStage = 3

    setModal(true)
    title("$MEGAMOD_BSOX_payout_title") --$ First Payout
    text("$MEGAMOD_BSOX_payout_text") --$ Silk walks in with an envelope fat enough to choke a horse. "Told you, boss. The kid went down in the fourth, just like I said. The house cleaned up." He tosses $4000 on your desk. "That's your cut. Now, I've got something bigger in mind. Championship bout. But that conversation can wait a few days." He winks and strolls out.
    option("$MEGAMOD_BSOX_dismiss") --$ Not bad, Silk.

    -- Schedule stage 3 in 7 days
    WorldUtils:scheduleWithDelay("MegaModBlackSoxFinal", Utils:daysToSecs(7), "TICK")
end

--[[------------------------------------------------------------------------------
    STAGE 3: Double or Nothing
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BLACKSOX_FINAL"
_event = "MegaModBlackSoxFinal"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BSOX_final_title") --$ Double or Nothing
    text("$MEGAMOD_BSOX_final_text") --$ Silk is back, and this time he's practically vibrating. "Championship bout, boss. Biggest fight Chicago's seen in years. Every high roller in town will be at your casino. I can fix the main event, but it's going to cost -- five grand to buy off the champ. If it works, you'll make twelve thousand easy. If it doesn't..." He trails off. "Well. Let's not think about that."
    option("$MEGAMOD_BSOX_final_gobig", goBig) --$ Go big ($5000)
    option("$MEGAMOD_BSOX_final_cashout", cashOut) --$ Cash out while I'm ahead
    option("$MEGAMOD_BSOX_final_turnin", turnHimIn) --$ Turn Silk in to the cops
end

function goBig()
    local cost = math.floor(5000 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction.cash.count < cost then
        title("$MEGAMOD_BSOX_final_broke_title") --$ Can't Cover It
        text("$MEGAMOD_BSOX_final_broke_text") --$ You don't have $5000 to put up. Silk shrugs. "No hard feelings, boss. Can't play if you can't pay." He tips his hat and disappears. The boxing fix is over.
        option("$MEGAMOD_BSOX_dismiss") --$ Damn.
        fact.MegaModBlackSoxStage = 4
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.INVESTMENT")

    if math.random() < 0.60 then
        -- Success: big payout
        BRScript:PlayerAddCash(math.floor(12000 * (fact.MegaModCfgPayout or 1)), "CASH.MISSION_REWARD") -- MEGAMOD CONFIG: payout knob
        fact.MegaModBlackSoxStage = 4

        title("$MEGAMOD_BSOX_final_win_title") --$ The Big Score
        text("$MEGAMOD_BSOX_final_win_text") --$ The champ hits the canvas in the eighth round and the crowd goes wild. Your casino rakes in a fortune from the betting tables. Silk delivers $12,000 to your office in a leather suitcase. "Pleasure doing business, boss." He tips his hat one last time and walks out of your life. Not bad for a few weeks' work.
        option("$MEGAMOD_BSOX_dismiss") --$ Pleasure was mine.
    else
        -- Failure: lose the investment + police heat
        fact.MegaModBlackSoxStage = 4

        if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
            -- MEGAMOD FIX: heat lands on the casino that hosted the fights, and is
            -- REAL precinct police activity (the game event below is only the UI toast)
            local heatPrecinct = nil
            for _, building in next, playerFaction.buildings do
                if building and building.buildingType and tostring(building.buildingType):lower():find("casino") then
                    heatPrecinct = building:getPrecinct()
                    break
                end
            end
            if not heatPrecinct and playerFaction.buildings[1] then
                heatPrecinct = playerFaction.buildings[1]:getPrecinct()
            end
            if heatPrecinct then
                local heat = math.max(1, math.floor(25 * (fact.MegaModCfgHeat or 1))) -- MEGAMOD CONFIG: heat knob (toast quotes the same figure)
                heatPrecinct:addTemporaryPoliceActivity(heat)
                Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                    "alertKey", "MEGAMOD_BSOX_HEAT",
                    "appliedPoliceActivity", heat,
                    "originalValue", heatPrecinct:getPoliceActivity() or 0,
                    "effectId", "MEGAMOD_BLACKSOX_HEAT",
                    "precinct", heatPrecinct,
                    "description", {"$Text", "Boxing Fix Scandal"})
            end
        end

        title("$MEGAMOD_BSOX_final_lose_title") --$ The Fix Is In... On You
        text("$MEGAMOD_BSOX_final_lose_text") --$ The champ didn't go down. Turns out he took your money AND the other side's money, and decided to fight for real. The crowd smells a rat, someone talks to a reporter, and by morning the papers are running stories about fixed fights at your casino. Your $5000 is gone, Silk has vanished, and the cops are very interested in your gambling operation.
        option("$MEGAMOD_BSOX_dismiss") --$ Should've quit while I was ahead.
    end
end

function cashOut()
    fact.MegaModBlackSoxStage = 4

    title("$MEGAMOD_BSOX_final_cashout_title") --$ Smart Money
    text("$MEGAMOD_BSOX_final_cashout_text") --$ "You're up two grand and you want to walk away?" Silk looks genuinely hurt. "Fine. Your call, boss. But you're leaving a fortune on the table." He adjusts his hat and heads for the door. You pocket your profits and sleep well knowing the smart money always knows when to fold.
    option("$MEGAMOD_BSOX_dismiss") --$ Smart move.
end

function turnHimIn()
    fact.MegaModBlackSoxStage = 4

    -- Reduce police heat
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
        local building = playerFaction.buildings[1]
        local precinct = building and building:getPrecinct() -- MEGAMOD FIX: building.precinct doesn't exist
        if precinct then
            precinct:addTemporaryPoliceActivity(-15) -- real heat reduction; decays back to normal over time
            Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                "alertKey", "MEGAMOD_BSOX_GOODWILL",
                "appliedPoliceActivity", -15,
                "originalValue", precinct:getPoliceActivity() or 0,
                "effectId", "MEGAMOD_BLACKSOX_TURNIN",
                "precinct", precinct,
                "description", {"$Text", "Turned in boxing fixer"})
        end
    end

    title("$MEGAMOD_BSOX_final_turnin_title") --$ Civic Duty
    text("$MEGAMOD_BSOX_final_turnin_text") --$ You make an anonymous call to the precinct. An hour later, Silk Sullivan is in handcuffs, looking bewildered. "I thought we were partners!" he shouts as the cops drag him out. The police are grateful for the tip, and the heat on your operations cools down a few degrees. Sometimes the best play is giving the law a bigger fish.
    option("$MEGAMOD_BSOX_dismiss") --$ Better him than me.
end

--[[------------------------------------------------------------------------------
    BLACK SOX MONITOR - director-driven listener
    MEGAMOD FIX: "Schedule" events are created inactive so GameEvent listeners
    never fired; converted to the Create-listener pattern (see HardModeBankroll).
    MEGAMOD DIRECTOR: cadence (weekly 20% roll) now lives in EventDirector.lua
    (registry: BLACK_SOX, onceOnly). This block answers director picks: pass
    when ineligible, launch when eligible. The stage fact stays the source of
    truth for eligibility; the director's once-flag is a second layer.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BLACKSOX_MONITOR"
_event = "MegaModBlackSoxMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BLACK_SOX" then return end

    -- Only trigger the initial pitch; later stages chain via scheduleWithDelay
    -- (listener stays alive here so the director always gets a pass reply)
    if (fact.MegaModBlackSoxStage or 0) ~= 0 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BLACK_SOX")
        return
    end
    if worldTime < 250 then -- MEGAMOD FIX: preserves the old _triggerDelay = 250
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BLACK_SOX")
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BLACK_SOX")
        return
    end

    -- Require enough for the pitch's investment (MEGAMOD CONFIG: gate scales with the cost knob so the pitch stays affordable)
    if not playerFaction.cash or playerFaction.cash.count < math.floor(2000 * (fact.MegaModCfgCost or 1)) then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BLACK_SOX")
        return
    end

    -- Require at least one casino building
    local buildings = playerFaction.buildings
    if not buildings then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BLACK_SOX")
        return
    end

    local hasCasino = false
    for _, building in next, buildings do
        if building and building.buildingType then
            local btype = tostring(building.buildingType):lower()
            if btype:find("casino") then
                hasCasino = true
                break
            end
        end
    end
    if not hasCasino then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BLACK_SOX")
        return
    end

    fact.MegaModBlackSoxStage = 1 -- gate immediately so we can't double-pitch
    WorldUtils:scheduleWithDelay("MegaModBlackSoxPitch", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BLACK_SOX")
    complete() -- chain is self-driving from here; listener no longer needed
end

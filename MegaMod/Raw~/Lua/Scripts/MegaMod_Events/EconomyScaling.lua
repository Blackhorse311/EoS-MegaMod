--[[------------------------------------------------------------------------------
    MegaMod: Harder Economy Scaling
    Background system that increases difficulty as your empire grows.
    Bigger empires face more police pressure and rival aggression.

    Real effects per tier (MEGAMOD FIX -- was flavor-only, currentTier never read):
    - Weekly overhead payoffs: $250 x tier via CASH.BRIBE (skipped if you can't afford it)
    - Sustained police attention: +2/week temp activity in every precinct with a
      player building (matches the vanilla weekly decay of 2, so it holds ~+2)
    - One-time heat pulse of +3 x tier on reaching each tier (decays away)
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_ECONOMY_SCALING"
_event = "MegaModEconomyScaling"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: Schedule+complete() unregistered onWeekBegin before it ever ran
_category = "Misc"

persist{}
currentTier = 0
persist{}
tier1Warned = false
persist{}
tier2Warned = false
persist{}
tier3Warned = false

-- Tier thresholds (building count)
local TIER_1_THRESHOLD = 5
local TIER_2_THRESHOLD = 10
local TIER_3_THRESHOLD = 15

-- MEGAMOD FIX: must be a GLOBAL function -- local helpers don't get the sandbox env
function addHeatToPlayerPrecincts(amount)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return end
    local seen = {}
    local buildings = playerFaction.buildings
    for i = 1, #buildings do
        local precinct = buildings[i] and buildings[i]:getPrecinct()
        if precinct and not seen[precinct] then
            seen[precinct] = true
            precinct:addTemporaryPoliceActivity(amount)
        end
    end
end

function GameEvent.onWeekBegin(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return end

    local buildingCount = #playerFaction.buildings
    local newTier = 0

    if buildingCount >= TIER_3_THRESHOLD then
        newTier = 3
    elseif buildingCount >= TIER_2_THRESHOLD then
        newTier = 2
    elseif buildingCount >= TIER_1_THRESHOLD then
        newTier = 1
    end

    -- Show warning on tier transition (plus a one-time heat pulse)
    -- MEGAMOD CONFIG: heat knob scales the pulses and the weekly pressure below
    local heatMult = fact.MegaModCfgHeat or 1
    if newTier >= 1 and not tier1Warned and buildingCount >= TIER_1_THRESHOLD then
        tier1Warned = true
        addHeatToPlayerPrecincts(math.max(1, math.floor(3 * heatMult)))
        WorldUtils:scheduleWithDelay("MegaModScalingTier1", 5, "TICK")
    end
    if newTier >= 2 and not tier2Warned and buildingCount >= TIER_2_THRESHOLD then
        tier2Warned = true
        addHeatToPlayerPrecincts(math.max(1, math.floor(6 * heatMult)))
        WorldUtils:scheduleWithDelay("MegaModScalingTier2", 5, "TICK")
    end
    if newTier >= 3 and not tier3Warned and buildingCount >= TIER_3_THRESHOLD then
        tier3Warned = true
        addHeatToPlayerPrecincts(math.max(1, math.floor(9 * heatMult)))
        WorldUtils:scheduleWithDelay("MegaModScalingTier3", 5, "TICK")
    end

    currentTier = newTier

    -- Weekly pressure while at tier 1+
    if currentTier >= 1 then
        local overhead = math.floor(250 * currentTier * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
        if playerFaction.cash.count >= overhead then
            BRScript:PlayerSubtractCash(overhead, "CASH.BRIBE")
        end
        addHeatToPlayerPrecincts(math.max(1, math.floor(2 * heatMult)))
    end
end

--[[------------------------------------------------------------------------------
    TIER 1 WARNING: Rising Empire
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SCALING_TIER1"
_event = "MegaModScalingTier1"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_SCALE_T1_title") --$ Rising Empire
    text("$MEGAMOD_SCALE_T1_text") --$ Your operations are growing and people are starting to notice. The cops are paying more attention to your neighborhoods, and the other gangs are keeping a closer eye on you. Keep expanding, but watch your back.
    option("$MEGAMOD_SCALE_T1_option") --$ Let them watch
end

--[[------------------------------------------------------------------------------
    TIER 2 WARNING: Criminal Kingpin
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SCALING_TIER2"
_event = "MegaModScalingTier2"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_SCALE_T2_title") --$ Criminal Kingpin
    text("$MEGAMOD_SCALE_T2_text") --$ You're now one of the biggest operators in Chicago. The police commissioner has your name on his desk, the feds are asking questions, and rival bosses are getting nervous. The pressure is real -- raids are more likely, and your enemies are bolder.
    option("$MEGAMOD_SCALE_T2_option") --$ I didn't come this far to stop now
end

--[[------------------------------------------------------------------------------
    TIER 3 WARNING: Public Enemy #1
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SCALING_TIER3"
_event = "MegaModScalingTier3"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_SCALE_T3_title") --$ Public Enemy #1
    text("$MEGAMOD_SCALE_T3_text") --$ Congratulations -- you're the most wanted person in Chicago. The feds have a task force dedicated to bringing you down, every cop in the city knows your face, and your rivals are openly plotting against you. This is the price of empire. Can you hold it all together?
    option("$MEGAMOD_SCALE_T3_option") --$ They'll have to pry it from my cold, dead hands
end

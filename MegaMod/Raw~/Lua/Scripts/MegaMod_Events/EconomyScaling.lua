--[[------------------------------------------------------------------------------
    MegaMod: Harder Economy Scaling
    Background system that increases difficulty as your empire grows.
    Bigger empires face more police pressure and rival aggression.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_ECONOMY_SCALING"
_event = "MegaModEconomyScaling"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 300
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

function canTrigger()
    return true
end

function onTrigger()
    complete()
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

    -- Show warning on tier transition
    if newTier >= 1 and not tier1Warned and buildingCount >= TIER_1_THRESHOLD then
        tier1Warned = true
        WorldUtils:scheduleWithDelay("MegaModScalingTier1", 5, "TICK")
    end
    if newTier >= 2 and not tier2Warned and buildingCount >= TIER_2_THRESHOLD then
        tier2Warned = true
        WorldUtils:scheduleWithDelay("MegaModScalingTier2", 5, "TICK")
    end
    if newTier >= 3 and not tier3Warned and buildingCount >= TIER_3_THRESHOLD then
        tier3Warned = true
        WorldUtils:scheduleWithDelay("MegaModScalingTier3", 5, "TICK")
    end

    currentTier = newTier
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
    complete()
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
    complete()
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
    complete()
end

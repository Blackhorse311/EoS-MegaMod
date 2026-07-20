--[[------------------------------------------------------------------------------
    MegaMod: Prohibition Agent Raids
    Periodic federal raids targeting your highest-earning racket.
    Bigger empires attract more attention.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Fed Raid Monitor - Background listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FED_RAID_MONITOR"
_event = "MegaModFedRaidMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: Schedule+complete() unregistered onWeekBegin before it ever ran
_category = "Misc"

persist{}
weeksSinceLastRaid = 0

function GameEvent.onWeekBegin(e)
    weeksSinceLastRaid = weeksSinceLastRaid + 1

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return end

    local buildingCount = #playerFaction.buildings
    if buildingCount < 3 then return end

    -- Base chance increases with empire size and time
    local baseChance = 0.02 + (buildingCount * 0.008) + (weeksSinceLastRaid * 0.005)
    baseChance = math.min(baseChance, 0.25) -- cap at 25%

    if math.random() < baseChance then
        weeksSinceLastRaid = 0
        WorldUtils:scheduleWithDelay("MegaModFedRaidWarning", 5, "TICK")
    end
end

--[[------------------------------------------------------------------------------
    Fed Raid Warning - Player gets a heads-up with options
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_FED_RAID_WARNING"
_event = "MegaModFedRaidWarning"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_FED_RAID_title") --$ Feds Are Sniffing Around
    text("$MEGAMOD_FED_RAID_text") --$ Word on the street is the Bureau of Prohibition has your operations in their sights. A reliable source says they're planning a raid on your biggest earner. You've got a narrow window to act.
    -- MEGAMOD FIX: only offer the bribe when affordable (vanilla RIGGED_TABLES_CAUGHT pattern);
    -- this also fixes the old bribe path which never completed the event (leak)
    if BRScript:PlayerCanAfford(500) then
        option("$MEGAMOD_FED_RAID_bribe", bribeFeds) --$ Grease some palms ($500)
    end
    option("$MEGAMOD_FED_RAID_hide", hideGoods) --$ Hide the good stuff (lose some alcohol)
    option("$MEGAMOD_FED_RAID_fight", letThemCome) --$ Let them come
end

function bribeFeds()
    BRScript:PlayerSubtractCash(500, "CASH.BRIBE")
    WorldUtils:triggerEvent("MegaModFedRaidBribed")
end

function hideGoods()
    -- MEGAMOD FIX: "lost some product in the rush" is now real -- dump 15% of stored alcohol
    local alcohol = WorldUtils:getPlayerFaction().alcohol
    local loss = math.floor(alcohol.stored * 0.15)
    if loss > 0 then
        alcohol:dump(nil, loss)
    end
    WorldUtils:triggerEvent("MegaModFedRaidHidden")
end

function letThemCome()
    -- MEGAMOD FIX: real penalty -- feds confiscate 30% of stored alcohol and precinct heat spikes
    local playerFaction = WorldUtils:getPlayerFaction()
    local alcohol = playerFaction.alcohol
    local loss = math.floor(alcohol.stored * 0.30)
    if loss > 0 then
        alcohol:dump(nil, loss)
    end
    if playerFaction.buildings and #playerFaction.buildings > 0 then
        local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
        local precinct = building and building:getPrecinct()
        if precinct then
            precinct:addTemporaryPoliceActivity(15) -- 3x a cop killing; decays 2/week
        end
    end
    WorldUtils:triggerEvent("MegaModFedRaidRaided")
end

--[[------------------------------------------------------------------------------
    Fed Raid Results
--------------------------------------------------------------------------------]]
-- MEGAMOD FIX: result pages must be separate events -- rebuilding the warning dialog
-- after complete() released the pooled event, so the result text never displayed.
_id = "MEGAMOD_FED_RAID_BRIBED_RESULT"
_event = "MegaModFedRaidBribed"
_category = "Misc"

function onTrigger()
    title("$MEGAMOD_FED_RAID_bribe_result_title") --$ Money Talks
    text("$MEGAMOD_FED_RAID_bribe_result_text") --$ A few crisp bills change hands and suddenly the feds have bigger fish to fry. The raid has been called off -- for now.
    option("$MEGAMOD_FED_RAID_dismiss") --$ Good.
end

_id = "MEGAMOD_FED_RAID_HIDDEN_RESULT"
_event = "MegaModFedRaidHidden"
_category = "Misc"

function onTrigger()
    title("$MEGAMOD_FED_RAID_hide_result_title") --$ Goods Stashed
    text("$MEGAMOD_FED_RAID_hide_result_text") --$ Your boys work through the night moving barrels and hiding the evidence. The feds show up, toss the place, and leave with nothing to show for it. But you lost some product in the rush.
    option("$MEGAMOD_FED_RAID_dismiss") --$ Could've been worse.
end

_id = "MEGAMOD_FED_RAID_RAIDED_RESULT"
_event = "MegaModFedRaidRaided"
_category = "Misc"

function onTrigger()
    title("$MEGAMOD_FED_RAID_fight_result_title") --$ Raided!
    text("$MEGAMOD_FED_RAID_fight_result_text") --$ The feds hit your operation hard. They smash barrels, confiscate goods, and make a big show of it for the papers. The heat in the area is through the roof.
    option("$MEGAMOD_FED_RAID_dismiss") --$ We'll rebuild.
end

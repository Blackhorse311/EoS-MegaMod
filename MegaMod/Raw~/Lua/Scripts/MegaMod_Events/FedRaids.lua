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
_autoStartMode = "Schedule"
_triggerDelay = 200
_category = "Misc"

persist{}
weeksSinceLastRaid = 0

function canTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    return playerFaction and playerFaction.buildings and #playerFaction.buildings > 2
end

function onTrigger()
    complete()
end

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
    option("$MEGAMOD_FED_RAID_bribe", bribeFeds) --$ Grease some palms ($500)
    option("$MEGAMOD_FED_RAID_hide", hideGoods) --$ Hide the good stuff (lose some alcohol)
    option("$MEGAMOD_FED_RAID_fight", letThemCome) --$ Let them come
end

function bribeFeds()
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction.cash.count >= 500 then
        BRScript:PlayerSubtractCash(500, "CASH.BRIBE")
        title("$MEGAMOD_FED_RAID_bribe_result_title") --$ Money Talks
        text("$MEGAMOD_FED_RAID_bribe_result_text") --$ A few crisp bills change hands and suddenly the feds have bigger fish to fry. The raid has been called off -- for now.
        option("$MEGAMOD_FED_RAID_dismiss") --$ Good.
    else
        title("$MEGAMOD_FED_RAID_broke_title") --$ Can't Afford the Bribe
        text("$MEGAMOD_FED_RAID_broke_text") --$ You don't have $500 to spare. The feds are coming whether you like it or not.
        option("$MEGAMOD_FED_RAID_brace", letThemCome) --$ Brace for impact
    end
end

function hideGoods()
    title("$MEGAMOD_FED_RAID_hide_result_title") --$ Goods Stashed
    text("$MEGAMOD_FED_RAID_hide_result_text") --$ Your boys work through the night moving barrels and hiding the evidence. The feds show up, toss the place, and leave with nothing to show for it. But you lost some product in the rush.
    option("$MEGAMOD_FED_RAID_dismiss") --$ Could've been worse.
    complete()
end

function letThemCome()
    title("$MEGAMOD_FED_RAID_fight_result_title") --$ Raided!
    text("$MEGAMOD_FED_RAID_fight_result_text") --$ The feds hit your operation hard. They smash barrels, confiscate goods, and make a big show of it for the papers. The heat in the area is through the roof.
    option("$MEGAMOD_FED_RAID_dismiss") --$ We'll rebuild.
    complete()
end

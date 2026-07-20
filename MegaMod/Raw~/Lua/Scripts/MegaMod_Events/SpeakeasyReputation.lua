--[[------------------------------------------------------------------------------
    MegaMod: Speakeasy Reputation
    Tracks how long player-owned bars have been running and triggers
    milestone events as they build a reputation.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Reputation Monitor - Background listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SPEAKEASY_REP_MONITOR"
_event = "MegaModSpeakeasyRepMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
barWeeks = {}

persist{}
barMilestones = {}

local MILESTONE_WORD_OF_MOUTH = 4
local MILESTONE_HOT_SPOT = 8
local MILESTONE_UNWANTED_ATTENTION = 12
local MILESTONE_LEGENDARY = 16

-- MEGAMOD FIX: global helpers (local functions don't get the sandbox env)
function isBar(building)
    if not building or not building.buildingData then return false end
    local id = building.buildingData.id
    return id == "BUILDING_DATA.BAR"
end

function getMilestoneKey(iid, weeks)
    return tostring(iid) .. "_" .. tostring(weeks)
end

-- MEGAMOD FIX: Create-mode listener (Schedule-mode created inactive + complete() in
-- onTrigger meant the weekly handler never stayed registered)
function GameEvent.onWeekBegin(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return end

    -- Build set of currently owned bar iids
    local ownedBars = {}
    for i = 1, #playerFaction.buildings do
        local building = playerFaction.buildings[i]
        if building and isBar(building) and building.isRacket then
            ownedBars[building.iid] = building
        end
    end

    -- Prune bars we no longer own
    for iid, _ in next, barWeeks do
        if not ownedBars[iid] then
            barWeeks[iid] = nil
        end
    end

    -- Increment weeks for each owned bar and check milestones
    for iid, building in next, ownedBars do
        barWeeks[iid] = (barWeeks[iid] or 0) + 1
        local weeks = barWeeks[iid]

        local milestones = {MILESTONE_WORD_OF_MOUTH, MILESTONE_HOT_SPOT, MILESTONE_UNWANTED_ATTENTION, MILESTONE_LEGENDARY}
        for _, threshold in next, milestones do
            if weeks == threshold then
                local key = getMilestoneKey(iid, threshold)
                if not barMilestones[key] then
                    barMilestones[key] = true
                    -- MEGAMOD FIX: state doesn't cross _id blocks; pass it on the
                    -- scheduled event as varargs (save-persisted with the event)
                    WorldUtils:scheduleWithDelay("MegaModSpeakeasyMilestone", 5, "TICK", "milestone", threshold, "barIid", iid)
                    return -- One milestone per week
                end
            end
        end
    end
end

--[[------------------------------------------------------------------------------
    Milestone Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SPEAKEASY_MILESTONE"
_event = "MegaModSpeakeasyMilestone"
_category = "Misc"

persist{}
milestone = nil

persist{}
barIid = nil

function canTrigger()
    return milestone ~= nil
end

function onTrigger()
    setModal(true)

    if milestone == MILESTONE_WORD_OF_MOUTH then
        title("$MEGAMOD_SPEKREP_wom_title") --$ Word of Mouth
        text("$MEGAMOD_SPEKREP_wom_text") --$ Your speakeasy is getting a reputation around the neighborhood. The regulars are telling their friends, and new faces are showing up every night. Keep the drinks flowing and the music playing, and this place could really be something.
        option("$MEGAMOD_SPEKREP_dismiss") --$ Good to hear.

    elseif milestone == MILESTONE_HOT_SPOT then
        title("$MEGAMOD_SPEKREP_hot_title") --$ The Hot Spot
        text("$MEGAMOD_SPEKREP_hot_text") --$ Everybody wants in. Your speakeasy has become the place to be, and the money is rolling in. Jazz bands are lining up to play, flappers are dancing on the tables, and the bootleg is flowing like the Chicago River. Here's $500 from the extra business.
        BRScript:PlayerAddCash(500, "CASH.SPEAKEASY_REPUTATION")
        option("$MEGAMOD_SPEKREP_dismiss_cash") --$ Pour another round.

    elseif milestone == MILESTONE_UNWANTED_ATTENTION then
        title("$MEGAMOD_SPEKREP_heat_title") --$ Unwanted Attention
        text("$MEGAMOD_SPEKREP_heat_text") --$ The cops have noticed your booming speakeasy. A joint this popular can't stay under the radar forever. The local precinct is increasing patrols in the area, and the beat cops are asking questions. The price of success.
        applyPoliceHeat()
        option("$MEGAMOD_SPEKREP_dismiss_heat") --$ Let them sniff around.

    elseif milestone == MILESTONE_LEGENDARY then
        title("$MEGAMOD_SPEKREP_legend_title") --$ Legendary Joint
        text("$MEGAMOD_SPEKREP_legend_text") --$ Your speakeasy is legendary. People come from all over Chicago just to say they've been here. The name is whispered in every barbershop, taxi, and jazz club in the city. Even the out-of-towners know about it. Here's $1500 from the overflow crowds.
        BRScript:PlayerAddCash(1500, "CASH.SPEAKEASY_REPUTATION")
        option("$MEGAMOD_SPEKREP_dismiss_legend") --$ This is what we built.
    end
    -- MEGAMOD FIX: no complete() in UI onTrigger (use-after-release); auto-complete
    -- handles both the dialog and the unknown-milestone (no UI) case
end

-- MEGAMOD FIX: real police heat via the precinct (the old raiseGameEvent call was a
-- UI toast only and applied nothing)
function applyPoliceHeat()
    if not barIid then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings then return end

    for i = 1, #playerFaction.buildings do
        local building = playerFaction.buildings[i]
        if building and building.iid == barIid then
            local precinct = building:getPrecinct()
            if precinct then
                precinct:addTemporaryPoliceActivity(15)
            end
            return
        end
    end
end

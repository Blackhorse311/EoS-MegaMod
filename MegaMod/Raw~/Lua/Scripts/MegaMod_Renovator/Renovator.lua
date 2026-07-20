--[[------------------------------------------------------------------------------
    MegaMod: Chloe "Big Brains" Shapleigh - The Renovator
    An Irish architect who can convert any racket you own into a different type.
    Came to Chicago from Dublin to work with Daniel Burnham's firm, found the
    architecture world was a boys' club, and discovered the mob pays better
    and doesn't care about your gender -- just your blueprints.

    Now supports ALL player neighborhoods, not just the starting one.
    If the player has buildings in multiple neighborhoods, they first pick
    the neighborhood, then the building within it.

    Architecture:
    - BEHAVIOURS pre-builds a neighborhood -> buildings list every day
    - CONVERSATIONS reads them.renoHoods[N] for neighborhoods, then
      them.renoHoods[N].buildings[M] for buildings within
    - Renovation execution is deferred to a WORLD_EVENT via scheduleWithDelay
      because getWorld() is only available in WORLD_EVENTS, not BEHAVIOURS
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: Define Chloe "Big Brains" Shapleigh
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_RENOVATOR"
_includes = {"NPC.BASE_MISSION_FEMALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bureau_Female_02_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bureau_Female_02_Profile"
prefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Female_02"
ragdollPrefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Female_02_Ragdoll"

name = "$MEGAMOD_RENO_fullname" --$ Chloe "Big Brains" Shapleigh
firstName = "$MEGAMOD_RENO_firstname" --$ Chloe
lastName = "$MEGAMOD_RENO_lastname" --$ Shapleigh
profession = "NoProfession"
commands =
{
    Talk = true,
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    Step 2: Spawn event
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_RENOVATOR_SPAWN"
_event = "MegaModRenovatorSpawn"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 250
_category = "Misc"

persist{}
renovatorActor = nil

function canTrigger()
    return true
end

function onTrigger()
    renovatorActor = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_RENOVATOR")
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    safehouse:enter(renovatorActor, "IDLE", true)
    renovatorActor.behaviours:add("MegaModRenovatorBehaviour")

    title("$MEGAMOD_RENO_arrive_title") --$ The Architect Has Arrived
    text("$MEGAMOD_RENO_arrive_text") --$ A sharp-eyed redhead in a man's work shirt with rolled-up sleeves has taken over a corner of your safehouse...
    option("$MEGAMOD_RENO_arrive_option") --$ A woman with a plan. I like it.
end

--[[------------------------------------------------------------------------------
    Step 3: Renovation execution event
    Triggered by BEHAVIOURS via scheduleWithDelay. getWorld() IS available here.
    Reads pending data from the renovator actor stored during spawn.
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_RENOVATE_EXECUTE"
_event = "MegaModRenovateBuilding"

function onTrigger()
    if not renovatorActor then
        complete()
        return
    end

    local building = renovatorActor.pendingRenoBuilding
    local configId = renovatorActor.pendingRenoConfig
    renovatorActor.pendingRenoBuilding = nil
    renovatorActor.pendingRenoConfig = nil

    if building and configId then
        local newName = getWorld().pickRandomRacketName(configId)
        local faction = building:getOwnerFaction()
        if faction then
            faction:changeRacketType(building, configId, newName)
        end
    end
    complete()
end

--[[------------------------------------------------------------------------------
    Step 4: The Renovator conversation
    CONVERSATIONS sandbox: no WorldUtils, no getWorld().
    Data pre-built by BEHAVIOURS:
      them.renoHoods = { {name="...", buildings={b1,b2,...}}, ... }
    If only one neighborhood has buildings, skip straight to building list.
    Otherwise show neighborhoods first, then buildings within.
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_RENOVATOR_CONVERSATION"
EntryPoint = "MegaMod_Renovator_Start"

local RENOVATION_COSTS = {
    Brewery = 1500,
    Bar     = 800,
    Casino  = 1200,
    Brothel = 1000,
}

local TYPE_CONFIG_IDS = {
    Brewery = "BUILDING_DATA.BREWERY",
    Bar     = "BUILDING_DATA.BAR",
    Casino  = "BUILDING_DATA.CASINO",
    Brothel = "BUILDING_DATA.BROTHEL",
}

local selectedHoodIdx = nil
local selectedBuilding = nil
local selectedTypeName = nil
local selectedTypeConfig = nil
local selectedCost = nil

function onStart()
    selectedHoodIdx = nil
    selectedBuilding = nil
    selectedTypeName = nil
    selectedTypeConfig = nil
    selectedCost = nil
    go(MainMenu)
end

function MainMenu()
    say("$MEGAMOD_RENO_greeting") --$ Right then. I've been looking over your properties and I can work in any neighborhood you control. Brewery, speakeasy, casino, brothel -- I designed better versions of all of them in my head on the boat over from Dublin. Burnham would have wept. Which area are we talking about?

    local hoods = them.renoHoods
    if not hoods or #hoods == 0 then
        say("$MEGAMOD_RENO_no_buildings") --$ You haven't got any rackets for me to work with yet. I didn't leave Dublin to sit about. Come back when you've expanded your empire and I'll put my degree to proper use.
        option("$MEGAMOD_RENO_leave", LeaveConversation)
        return
    end

    -- If only one neighborhood, skip directly to building selection
    if #hoods == 1 then
        selectedHoodIdx = 1
        go(ShowBuildings)
        return
    end

    -- Show neighborhoods (up to 8)
    if hoods[1] then option(hoods[1].name, SelectHood1) end
    if hoods[2] then option(hoods[2].name, SelectHood2) end
    if hoods[3] then option(hoods[3].name, SelectHood3) end
    if hoods[4] then option(hoods[4].name, SelectHood4) end
    if hoods[5] then option(hoods[5].name, SelectHood5) end
    if hoods[6] then option(hoods[6].name, SelectHood6) end
    if hoods[7] then option(hoods[7].name, SelectHood7) end
    if hoods[8] then option(hoods[8].name, SelectHood8) end
    option("$MEGAMOD_RENO_leave", LeaveConversation)
end

-- Neighborhood selection callbacks
function SelectHood1() selectedHoodIdx = 1; go(ShowBuildings) end
function SelectHood2() selectedHoodIdx = 2; go(ShowBuildings) end
function SelectHood3() selectedHoodIdx = 3; go(ShowBuildings) end
function SelectHood4() selectedHoodIdx = 4; go(ShowBuildings) end
function SelectHood5() selectedHoodIdx = 5; go(ShowBuildings) end
function SelectHood6() selectedHoodIdx = 6; go(ShowBuildings) end
function SelectHood7() selectedHoodIdx = 7; go(ShowBuildings) end
function SelectHood8() selectedHoodIdx = 8; go(ShowBuildings) end

function ShowBuildings()
    local hoods = them.renoHoods
    if not hoods or not hoods[selectedHoodIdx] then
        go(MainMenu)
        return
    end

    local bldgs = hoods[selectedHoodIdx].buildings
    if not bldgs or #bldgs == 0 then
        go(MainMenu)
        return
    end

    say("$MEGAMOD_RENO_pick_building") --$ Grand. Now which place in that area are we redesigning?

    if bldgs[1] then option(bldgs[1].name, SelectBldg1) end
    if bldgs[2] then option(bldgs[2].name, SelectBldg2) end
    if bldgs[3] then option(bldgs[3].name, SelectBldg3) end
    if bldgs[4] then option(bldgs[4].name, SelectBldg4) end
    if bldgs[5] then option(bldgs[5].name, SelectBldg5) end
    if bldgs[6] then option(bldgs[6].name, SelectBldg6) end
    if bldgs[7] then option(bldgs[7].name, SelectBldg7) end
    if bldgs[8] then option(bldgs[8].name, SelectBldg8) end
    option("$MEGAMOD_RENO_back", MainMenu)
end

-- Building selection callbacks
function SelectBldg1() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[1]; go(ChooseNewType) end
function SelectBldg2() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[2]; go(ChooseNewType) end
function SelectBldg3() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[3]; go(ChooseNewType) end
function SelectBldg4() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[4]; go(ChooseNewType) end
function SelectBldg5() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[5]; go(ChooseNewType) end
function SelectBldg6() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[6]; go(ChooseNewType) end
function SelectBldg7() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[7]; go(ChooseNewType) end
function SelectBldg8() selectedBuilding = them.renoHoods[selectedHoodIdx].buildings[8]; go(ChooseNewType) end

function ChooseNewType()
    if not selectedBuilding then
        go(MainMenu)
        return
    end

    say("$MEGAMOD_RENO_choose_type") --$ Good choice. Now what do you want me to turn it into? I've got plans for all of them.

    local currentType = selectedBuilding.buildingType
    if currentType ~= "Brewery" then
        option("$MEGAMOD_RENO_opt_brewery", SelectBrewery)
    end
    if currentType ~= "Bar" then
        option("$MEGAMOD_RENO_opt_bar", SelectBar)
    end
    if currentType ~= "Casino" then
        option("$MEGAMOD_RENO_opt_casino", SelectCasino)
    end
    if currentType ~= "Brothel" then
        option("$MEGAMOD_RENO_opt_brothel", SelectBrothel)
    end
    option("$MEGAMOD_RENO_back", ShowBuildings)
end

-- Type selection callbacks
function SelectBrewery()
    selectedTypeName = "Brewery"
    selectedTypeConfig = TYPE_CONFIG_IDS.Brewery
    selectedCost = RENOVATION_COSTS.Brewery
    go(ConfirmRenovation)
end
function SelectBar()
    selectedTypeName = "Bar"
    selectedTypeConfig = TYPE_CONFIG_IDS.Bar
    selectedCost = RENOVATION_COSTS.Bar
    go(ConfirmRenovation)
end
function SelectCasino()
    selectedTypeName = "Casino"
    selectedTypeConfig = TYPE_CONFIG_IDS.Casino
    selectedCost = RENOVATION_COSTS.Casino
    go(ConfirmRenovation)
end
function SelectBrothel()
    selectedTypeName = "Brothel"
    selectedTypeConfig = TYPE_CONFIG_IDS.Brothel
    selectedCost = RENOVATION_COSTS.Brothel
    go(ConfirmRenovation)
end

function ConfirmRenovation()
    if you.faction.cash.count < selectedCost then
        say("$MEGAMOD_RENO_cant_afford") --$ Construction costs money, and you haven't got enough. I didn't get a degree to work on credit. Come back when your finances are in better shape.
        option("$MEGAMOD_RENO_back_type", ChooseNewType)
        option("$MEGAMOD_RENO_leave", LeaveConversation)
        return
    end

    say("$MEGAMOD_RENO_confirm") --$ Right. I'll tear the place down to the studs and rebuild it from the ground up. Fair warning -- any upgrades on the building will be lost. But you'll have a brand new operation, properly designed this time. Burnham's firm couldn't do it better. We have a deal?
    option("$MEGAMOD_RENO_confirm_yes", ExecuteRenovation)
    option("$MEGAMOD_RENO_confirm_no", ChooseNewType)
end

function ExecuteRenovation()
    BRScript:PlayerSubtractCash(selectedCost, "CASH.RENOVATION")

    -- Store renovation request on NPC for BEHAVIOURS to pick up
    them.pendingRenoBuilding = selectedBuilding
    them.pendingRenoConfig = selectedTypeConfig
    them.pendingRenovation = true

    say("$MEGAMOD_RENO_success") --$ Brilliant. My crew will start demolition straightaway. I've already drawn up the plans. This is what I was trained for -- even if the client list is a bit different than what they had in mind at university.
    option("$MEGAMOD_RENO_another", MainMenu)
    option("$MEGAMOD_RENO_done", LeaveConversation)
end

function LeaveConversation()
    say("$MEGAMOD_RENO_goodbye") --$ You know where to find me. I'll be here with my blueprints. It's not the career I planned, but at least someone appreciates good architecture.
    option("$MEGAMOD_RENO_done", Leave)
end

function Leave()
    endConversation()
end

--[[------------------------------------------------------------------------------
    Step 5: Renovator behaviour
    - Pre-builds neighborhood -> building list for conversation
    - Processes pending renovation via scheduleWithDelay to WORLD_EVENT
    - Uses WorldUtils:getExteriorLocations() to map buildings to neighborhoods
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_RENOVATOR_BEHAVIOUR"
_name = "MegaModRenovatorBehaviour"

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_Renovator_Start")
    refreshBuildingList()
end

function GameEvent.onDayBegin(e)
    refreshBuildingList()
end

function GameEvent.frame(e)
    -- Process pending renovation from conversation
    if thisActor.pendingRenovation then
        thisActor.pendingRenovation = nil
        -- Proxy data through primary actor so the execute event can read it
        if renovatorActor and thisActor ~= renovatorActor then
            renovatorActor.pendingRenoBuilding = thisActor.pendingRenoBuilding
            renovatorActor.pendingRenoConfig = thisActor.pendingRenoConfig
            thisActor.pendingRenoBuilding = nil
            thisActor.pendingRenoConfig = nil
        end
        -- Defer to WORLD_EVENT where getWorld() is available
        WorldUtils:scheduleWithDelay("MegaModRenovateBuilding", 1, "TICK")
    end
end

function refreshBuildingList()
    -- Build locationId -> neighborhood name mapping
    local hoodNameMap = {}
    local neighborhoods = WorldUtils:getExteriorLocations()
    if neighborhoods then
        for i = 1, #neighborhoods do
            local hood = neighborhoods[i]
            if hood.name and hood.buildings then
                for j = 1, #hood.buildings do
                    local b = hood.buildings[j]
                    if b.locationId then
                        hoodNameMap[b.locationId] = hood.name
                    end
                end
            end
        end
    end

    -- Group player buildings by neighborhood
    local hoodsMap = {}
    local hoodsOrder = {}
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.buildings then
        for i = 1, #playerFaction.buildings do
            local b = playerFaction.buildings[i]
            local bType = b.buildingType
            if bType == "Brewery" or bType == "Bar" or bType == "Casino" or bType == "Brothel" then
                local hoodName = hoodNameMap[b.locationId] or "$MEGAMOD_RENO_unknown_hood"
                if not hoodsMap[hoodName] then
                    hoodsMap[hoodName] = { name = hoodName, buildings = {} }
                    hoodsOrder[#hoodsOrder + 1] = hoodsMap[hoodName]
                end
                local hood = hoodsMap[hoodName]
                if #hood.buildings < 8 then
                    hood.buildings[#hood.buildings + 1] = b
                end
            end
        end
    end

    -- Cap at 8 neighborhoods
    if #hoodsOrder > 8 then
        local trimmed = {}
        for i = 1, 8 do trimmed[i] = hoodsOrder[i] end
        hoodsOrder = trimmed
    end

    thisActor.renoHoods = hoodsOrder

    -- Keep legacy renoSlots for backward compatibility with any old save data
    local flatSlots = {}
    for _, hood in ipairs(hoodsOrder) do
        for _, b in ipairs(hood.buildings) do
            flatSlots[#flatSlots + 1] = b
            if #flatSlots >= 8 then break end
        end
        if #flatSlots >= 8 then break end
    end
    thisActor.renoSlots = flatSlots
end

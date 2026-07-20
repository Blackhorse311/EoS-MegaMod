--[[------------------------------------------------------------------------------
    MegaMod: The Cleaner - Evodio "Smokes" Zinna
    A chain-smoking Italian fixer who offers contracts to weaken rival factions.
    Player selects the service type AND the target faction from a list.
    A follow-up report popup fires the next day with results.

    Hitman ($1000, 50% success): kills a random non-boss member of a chosen
      rival faction, weakening their crew.
    Rattle ($500, 70% success): sends agitators into a chosen rival faction's
      territory, adding +15 police heat to one of their neighborhoods.
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: Define The Cleaner NPC - Evodio "Smokes" Zinna
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_CONTRACT_BROKER"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
prefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01"
ragdollPrefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01_Ragdoll"

name = "$MEGAMOD_CONTRACTOR_fullname" --$ Evodio "Smokes" Zinna
firstName = "$MEGAMOD_CONTRACTOR_firstname" --$ Evodio
lastName = "$MEGAMOD_CONTRACTOR_lastname" --$ Zinna
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
_id = "MEGAMOD_BROKER_SPAWN"
_event = "MegaModBrokerSpawn"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 200
_category = "Misc"

persist{}
contractorActor = nil

function canTrigger()
    return true
end

function onTrigger()
    contractorActor = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_CONTRACT_BROKER")
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    safehouse:enter(contractorActor, "IDLE", true)
    contractorActor.behaviours:add("MegaModBrokerBehaviour")

    title("$MEGAMOD_CONTRACTOR_arrive_title") --$ The Cleaner Has Arrived
    text("$MEGAMOD_CONTRACTOR_arrive_text") --$ You smell him before you see him. A thick cloud of acrid, foreign tobacco smoke drifts around the corner...
    option("$MEGAMOD_CONTRACTOR_arrive_option") --$ ...I'll hold my breath.
end

--[[------------------------------------------------------------------------------
    Step 3: Follow-up report event
    Reads the result stored on the contractor actor by the behaviour.
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_CONTRACTOR_REPORT"
_event = "MegaModContractorReport"

function onTrigger()
    if not contractorActor then
        complete()
        return
    end

    local result = contractorActor.contractResult
    contractorActor.contractResult = nil

    if not result then
        complete()
        return
    end

    setModal(true)
    if result == "hitman_win" then
        title("$MEGAMOD_CONTRACTOR_rpt_hitman_win_title") --$ Contract Report: Hit Successful
        text("$MEGAMOD_CONTRACTOR_rpt_hitman_win_text") --$ Word from The Contractor: "My man got the job done. Walked right in, found the target, and put him down clean. One less soldier in their crew. Their boss is going to feel that hole in his operation -- fewer guns when the next fight breaks out, fewer eyes on the street. You just bought yourself an edge."
    elseif result == "hitman_lose" then
        title("$MEGAMOD_CONTRACTOR_rpt_hitman_lose_title") --$ Contract Report: Hit Failed
        text("$MEGAMOD_CONTRACTOR_rpt_hitman_lose_text") --$ Word from The Contractor: "Bad news. The hit went sideways. My man got spotted before he could make the move and had to disappear. Your money's spent, and worse, that outfit knows somebody's gunning for them. They'll be tightening security and watching their backs. Don't expect them to let their guard down anytime soon."
    elseif result == "rattle_win" then
        title("$MEGAMOD_CONTRACTOR_rpt_rattle_win_title") --$ Contract Report: Rattle Successful
        text("$MEGAMOD_CONTRACTOR_rpt_rattle_win_text") --$ Word from The Contractor: "My boys did their job. Smashed up some storefronts, roughed up a couple of their runners, left threatening notes all over the neighborhood. The cops came running and now that whole territory is crawling with badges. That rival outfit is going to have a hell of a time running their rackets with all that police heat on their doorstep."
    elseif result == "rattle_lose" then
        title("$MEGAMOD_CONTRACTOR_rpt_rattle_lose_title") --$ Contract Report: Rattle Failed
        text("$MEGAMOD_CONTRACTOR_rpt_rattle_lose_text") --$ Word from The Contractor: "Didn't go as planned. Their boys were tougher than expected and mine had to pull back before they could do real damage. Your money's gone and word might have gotten back to that outfit that someone was trying to stir things up. No police heat, no disruption. Sometimes it goes that way."
    end
    option("$MEGAMOD_CONTRACTOR_rpt_dismiss") --$ Noted.
    complete()
end

--[[------------------------------------------------------------------------------
    Step 4: Contractor conversation
    Faction list pre-built by BEHAVIOURS, stored on them.contractFactions.
    Player picks a service, then picks the target faction from a list.
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_BROKER_CONVERSATION"
EntryPoint = "MegaMod_Broker_Start"

local HITMAN_COST = 1000
local RATTLE_COST = 500

local selectedServiceType = nil
local selectedFactionIdx = nil

function onStart()
    selectedServiceType = nil
    selectedFactionIdx = nil
    go(MainMenu)
end

function MainMenu()
    say("$MEGAMOD_CONTRACTOR_greeting") --$ I make problems disappear -- for a price. Two kinds of work: I can send a hitman to thin out a rival's crew, or I can rattle their territory and bring the law down on them. What's your pleasure?
    option("$MEGAMOD_CONTRACTOR_hitman", HitmanExplain)
    option("$MEGAMOD_CONTRACTOR_rattle", RattleExplain)
    option("$MEGAMOD_CONTRACTOR_leave", Leave)
end

function HitmanExplain()
    if you.faction.cash.count < HITMAN_COST then
        say("$MEGAMOD_CONTRACTOR_cantafford") --$ You don't have the cash. Come back when you can afford my services.
        option("$MEGAMOD_CONTRACTOR_backtomenu", MainMenu)
        option("$MEGAMOD_CONTRACTOR_leave", Leave)
        return
    end

    selectedServiceType = "hitman"
    say("$MEGAMOD_CONTRACTOR_hitman_explain") --$ For a thousand dollars, I send my best man after a key member of a rival gang. Not the boss -- that's suicide. But someone who matters. A lieutenant, an enforcer, a top earner. When they go down, that crew gets weaker. Fewer guns in a fight, fewer hands running their rackets, and their boss loses sleep wondering who's next. Fifty-fifty odds of success. If it fails, you lose the money and they know someone's coming for them. Now -- which outfit do you want to hit?

    local factions = them.contractFactions
    if not factions or #factions == 0 then
        say("$MEGAMOD_CONTRACTOR_no_rivals") --$ No rival outfits to go after right now. Come back when the competition heats up.
        option("$MEGAMOD_CONTRACTOR_leave", Leave)
        return
    end

    if factions[1] then option(factions[1].name, SelectFaction1) end
    if factions[2] then option(factions[2].name, SelectFaction2) end
    if factions[3] then option(factions[3].name, SelectFaction3) end
    if factions[4] then option(factions[4].name, SelectFaction4) end
    if factions[5] then option(factions[5].name, SelectFaction5) end
    if factions[6] then option(factions[6].name, SelectFaction6) end
    if factions[7] then option(factions[7].name, SelectFaction7) end
    if factions[8] then option(factions[8].name, SelectFaction8) end
    option("$MEGAMOD_CONTRACTOR_back", MainMenu)
end

function RattleExplain()
    if you.faction.cash.count < RATTLE_COST then
        say("$MEGAMOD_CONTRACTOR_cantafford")
        option("$MEGAMOD_CONTRACTOR_backtomenu", MainMenu)
        option("$MEGAMOD_CONTRACTOR_leave", Leave)
        return
    end

    selectedServiceType = "rattle"
    say("$MEGAMOD_CONTRACTOR_rattle_explain") --$ Five hundred dollars. I send some boys into a rival's territory to raise hell. Broken windows, threatening messages, roughed-up runners -- the whole show. The cops come running and that neighborhood gets fifteen points of police heat dumped right on their doorstep. Their rackets slow down, their income drops, and their boss has to spend time and money dealing with the law instead of expanding. Seventy percent chance it works. If it doesn't, word might get back to them that you were behind it. Which outfit's territory do you want rattled?

    local factions = them.contractFactions
    if not factions or #factions == 0 then
        say("$MEGAMOD_CONTRACTOR_no_rivals")
        option("$MEGAMOD_CONTRACTOR_leave", Leave)
        return
    end

    if factions[1] then option(factions[1].name, SelectFaction1) end
    if factions[2] then option(factions[2].name, SelectFaction2) end
    if factions[3] then option(factions[3].name, SelectFaction3) end
    if factions[4] then option(factions[4].name, SelectFaction4) end
    if factions[5] then option(factions[5].name, SelectFaction5) end
    if factions[6] then option(factions[6].name, SelectFaction6) end
    if factions[7] then option(factions[7].name, SelectFaction7) end
    if factions[8] then option(factions[8].name, SelectFaction8) end
    option("$MEGAMOD_CONTRACTOR_back", MainMenu)
end

-- Faction selection callbacks
function SelectFaction1() selectedFactionIdx = 1; go(ConfirmContract) end
function SelectFaction2() selectedFactionIdx = 2; go(ConfirmContract) end
function SelectFaction3() selectedFactionIdx = 3; go(ConfirmContract) end
function SelectFaction4() selectedFactionIdx = 4; go(ConfirmContract) end
function SelectFaction5() selectedFactionIdx = 5; go(ConfirmContract) end
function SelectFaction6() selectedFactionIdx = 6; go(ConfirmContract) end
function SelectFaction7() selectedFactionIdx = 7; go(ConfirmContract) end
function SelectFaction8() selectedFactionIdx = 8; go(ConfirmContract) end

function ConfirmContract()
    if selectedServiceType == "hitman" then
        say("$MEGAMOD_CONTRACTOR_confirm_hitman") --$ My man will infiltrate that outfit and take out one of their key people. Not the boss -- too risky -- but someone who matters. Their crew gets smaller, their operations suffer, and their boss loses sleep. One thousand dollars. We got a deal?
        option("$MEGAMOD_CONTRACTOR_confirm_yes", ExecuteContract)
        option("$MEGAMOD_CONTRACTOR_confirm_diff", GoBackToFactions)
        option("$MEGAMOD_CONTRACTOR_confirm_cancel", MainMenu)
    else
        say("$MEGAMOD_CONTRACTOR_confirm_rattle") --$ I'll send my boys into their territory to raise hell. Enough noise to bring the cops running. That neighborhood gets fifteen points of police heat -- their rackets slow down, their income takes a hit, and their boss has bigger problems than you for a while. Five hundred dollars. Sound good?
        option("$MEGAMOD_CONTRACTOR_confirm_yes", ExecuteContract)
        option("$MEGAMOD_CONTRACTOR_confirm_diff", GoBackToFactions)
        option("$MEGAMOD_CONTRACTOR_confirm_cancel", MainMenu)
    end
end

function GoBackToFactions()
    if selectedServiceType == "hitman" then
        go(HitmanExplain)
    else
        go(RattleExplain)
    end
end

function ExecuteContract()
    local cost = HITMAN_COST
    if selectedServiceType == "rattle" then
        cost = RATTLE_COST
    end

    if you.faction.cash.count < cost then
        say("$MEGAMOD_CONTRACTOR_cantafford")
        option("$MEGAMOD_CONTRACTOR_backtomenu", MainMenu)
        option("$MEGAMOD_CONTRACTOR_leave", Leave)
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.CONTRACT")

    them.pendingContractType = selectedServiceType
    them.pendingContractFaction = selectedFactionIdx

    say("$MEGAMOD_CONTRACTOR_execute") --$ Consider it done. My people are already on the move. I'll have a report for you by tomorrow. In the meantime, keep your hands clean and let me handle the dirty work.
    option("$MEGAMOD_CONTRACTOR_more", MainMenu)
    option("$MEGAMOD_CONTRACTOR_leave", Leave)
end

function Leave()
    say("$MEGAMOD_CONTRACTOR_goodbye") --$ You know where to find me.
    endConversation()
end

--[[------------------------------------------------------------------------------
    Step 5: Contractor behaviour
    - Pre-builds rival faction list for conversation (WorldUtils available here)
    - Processes pending contracts from conversation
    - Stores result and schedules follow-up report event next day
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_BROKER_BEHAVIOUR"
_name = "MegaModBrokerBehaviour"

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_Broker_Start")
    refreshFactionList()
end

function GameEvent.onDayBegin(e)
    refreshFactionList()

    -- Fire follow-up report if a contract result is pending
    if thisActor.pendingReport then
        thisActor.pendingReport = nil
        -- Proxy result through primary actor so the report event can read it
        if contractorActor and thisActor ~= contractorActor then
            contractorActor.contractResult = thisActor.contractResult
            thisActor.contractResult = nil
        end
        WorldUtils:scheduleWithDelay("MegaModContractorReport", 5, "TICK")
    end
end

function GameEvent.frame(e)
    local contractType = thisActor.pendingContractType
    local factionIdx = thisActor.pendingContractFaction

    if not contractType or not factionIdx then return end

    thisActor.pendingContractType = nil
    thisActor.pendingContractFaction = nil

    local factions = thisActor.contractFactions
    if not factions or not factions[factionIdx] then return end

    local targetFaction = factions[factionIdx].faction
    if not targetFaction or targetFaction:isDead() then return end

    if contractType == "hitman" then
        processHitman(targetFaction)
    elseif contractType == "rattle" then
        processRattle(targetFaction)
    end
end

function processHitman(targetFaction)
    if math.random() < 0.5 then
        local boss = targetFaction.boss
        local targets = {}
        if targetFaction.members then
            for _, member in next, targetFaction.members do
                if member ~= boss and not member:isDead() then
                    targets[#targets + 1] = member
                end
            end
        end
        if #targets > 0 then
            local victim = targets[math.random(#targets)]
            victim:kill()
            thisActor.contractResult = "hitman_win"
        else
            -- No valid targets found, treat as failure
            thisActor.contractResult = "hitman_lose"
        end
    else
        thisActor.contractResult = "hitman_lose"
    end
    thisActor.pendingReport = true
end

function processRattle(targetFaction)
    if math.random() < 0.7 then
        local buildings = targetFaction.buildings
        if buildings and #buildings > 0 then
            local building = buildings[math.random(#buildings)]
            if building and building.neighborhood then
                Utils:raiseGameEvent("onPoliceActivityEffectApplied", {
                    neighborhood = building.neighborhood,
                    amount = 15,
                })
                thisActor.contractResult = "rattle_win"
            else
                thisActor.contractResult = "rattle_lose"
            end
        else
            thisActor.contractResult = "rattle_lose"
        end
    else
        thisActor.contractResult = "rattle_lose"
    end
    thisActor.pendingReport = true
end

function refreshFactionList()
    local factions = {}
    local rivalIds = WorldUtils:getOtherGangFactionsIds()
    if rivalIds then
        for i = 1, #rivalIds do
            local faction = WorldUtils:getFactionById(rivalIds[i])
            if faction and not faction:isDead() then
                factions[#factions + 1] = {
                    id = rivalIds[i],
                    name = faction.name,
                    faction = faction,
                }
                if #factions >= 8 then break end
            end
        end
    end
    thisActor.contractFactions = factions
end

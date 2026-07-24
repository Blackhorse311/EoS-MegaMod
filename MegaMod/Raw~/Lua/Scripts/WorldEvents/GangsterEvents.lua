-- --------------------------------------------------
-- GangsterEvents.lua
-- --------------------------------------------------
_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
THE MONKS FAMILY CIRCUS
--------------------------------------------------------------------------------]]
_id = "FAMILY_CIRCUS"
_event = "FamilyCircus"
_gameStage = "Early"
_autoStartMode = "Schedule"
_category = "GangsterEvent"
_triggerDelay = 200

rpc = nil
grover = nil
function canTrigger()
    local MaeSkinRPCId = Utils:getRPCSkinId("RPC.MONKS.RPC_02")
    local playerFaction = WorldUtils:getPlayerFaction()
    grover = grover or MissionUtils:rpcWithId("RPC.MONKS.RPC_10")
    local rpcs = playerFaction:getRPCs()

    if grover.faction ~= playerFaction or not MissionUtils:isGangsterAvailable(grover) then
        return false
    end

    local foundRPC = false
    for i = 1, #rpcs do
        rpc = rpcs[i]
        local configId = rpc.configId
        if configId == "RPC.MONKS.RPC_01" or configId == MaeSkinRPCId or configId == "RPC.MONKS.RPC_03" then
            if MissionUtils:isGangsterAvailable(rpc) then
                foundRPC = true
                break
            end
        end
    end

    return foundRPC
end

function onTrigger()
    Utils:startConversation(WorldUtils:getPlayerFaction().boss, rpc, "EVENT_CONVERSATION", "FamilyCircus_Start", false)
    WorldUtils:createEvent("FamilyCircusGroverState")
end

--[[------------------------------------------------------------------------------
THE MONKS FAMILY CIRCUS GROVER STATE
--------------------------------------------------------------------------------]]
_id = "FAMILY_CIRCUS_GROVER_STATE"
_event = "FamilyCircusGroverState"

function onCreate()
    worldTimeCallback(onTrigger, Utils:daysToSecs(1))
end

function onTrigger()
    local grover = MissionUtils:rpcWithId("RPC.MONKS.RPC_10")
    if grover:hasState("Fearful") then
        grover:removeState("Fearful")
    end

    return false
end

--[[------------------------------------------------------------------------------
THE PYRAMID
--------------------------------------------------------------------------------]]
_id = "THE_PYRAMID"
_event = "ThePyramid"
_gameStage = "Mid"
_autoStartMode = "Schedule"
_category = "GangsterEvent"
_triggerDelay = 300

rpc = nil
function canTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    local rpcs = playerFaction:getRPCs()

    local foundRPC = false
    for i = 1, #rpcs do
        rpc = rpcs[i]
        if rpc:hasState("Naive") and (rpc.loyalty:get() >= 70 or (rpc.memory.worldTimeWhenHired and (worldTime - rpc.memory.worldTimeWhenHired) > Utils:yearsToSecs(2))) then
            if MissionUtils:isGangsterAvailable(rpc) then
                foundRPC = true
                break
            end
        end
    end

    return foundRPC
end

function onTrigger()
    Utils:startConversation(WorldUtils:getPlayerFaction().boss, rpc, "EVENT_CONVERSATION", "ThePyramid_Start", false)
    WorldUtils:createEvent("ThePyramid2", "rpc", rpc)
end

--[[------------------------------------------------------------------------------
THE PYRAMID 2
--------------------------------------------------------------------------------]]
_id = "THE_PYRAMID_2"
_event = "ThePyramid2"

rpc = nil
function onCreate()
    worldTimeCallback(checkEvent, Utils:monthsToSecs(1))
end

function checkEvent()
    if canTrigger() then
        trigger()
        return false
    else
        return false
    end
end

function canTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not MissionUtils:isGangsterAvailable(rpc) then
        return false
    end

    if rpc.faction == playerFaction then
        if fact.Pyramid_Choice == 4 then
            local roll = Utils:roll(100)
            if roll < 60 then
                return true
            end
        elseif fact.Pyramid_Choice == 1 or fact.Pyramid_Choice == 2 then
            return true
        end
    end

    return false
end

function onTrigger()
    Utils:startConversation(WorldUtils:getPlayerFaction().boss, rpc, "EVENT_CONVERSATION", "ThePyramid2_Start", false)
end

--[[------------------------------------------------------------------------------
POACHED
--------------------------------------------------------------------------------]]
_id = "POACHED"
_event = "Poached"
_gameStage = "Early"
_autoStartMode = "Schedule"
_category = "GangsterEvent"
_triggerDelay = 250

rpc = nil
faction = nil
playerFaction = nil
function canTrigger()
    playerFaction = playerFaction or WorldUtils:getPlayerFaction()
    local rpcs = playerFaction:getRPCs()

    local foundRpc = false
    for i = 1, #rpcs do
        rpc = rpcs[i]
        if rpc.loyalty:get() >= 70 then
            if rpc.currentTalentTier >= rpc.maxTalentTier then
                if MissionUtils:isGangsterAvailable(rpc) then
                    foundRpc = true
                    break
                end
            end
        end
    end

    local foundFaction = false
    local factions = WorldUtils:getActiveOtherGangFactions()
    for i = 1, #factions do
        faction = factions[i]
        if not BRScript:HasAlliance(playerFaction, faction) then
            foundFaction = true
            break
        end
    end

    return foundRpc and foundFaction
end

function onTrigger()
    if not playerFaction:knowsAbout(faction) then
        playerFaction:learnAbout(faction)
    end
    rpc.memory.Poached_Faction = faction
    Utils:startConversation(WorldUtils:getPlayerFaction().boss, rpc, "EVENT_CONVERSATION", "Poached_Start", false)
end

--[[------------------------------------------------------------------------------
GANGSTER RESURRECTION
--------------------------------------------------------------------------------]]
_id = "GANGSTER_RESURRECTION"
_event = "GangsterResurrection"
_gameStage = "Bridging"
_autoStartMode = "Create"

persist{}
gangster = nil

timerStarted = nil
function onCreate()
    fact.GangsterResurrectionEvent = thisInstanceId
end

function GameEvent.onCharacterDeath(e)
    if gangster or timerStarted then
        return
    end

    local target = e.target

    if Character:isARPC(target) and target.faction.isPlayerFaction then
        gangster = target
        startTimerToRevive()
    end
end


function startTimerToRevive()
    timerStarted = true
    worldTimeCallback(attemptRevive, Utils:weeksToSecs(3))
end

function attemptRevive()
    trigger()
end

function onTrigger()
    if not fact.GangsterResurrectionEvent then
        return
    end
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction:getAvailableCrewSlot() == nil then
        return
    end
    disableAutoComplete()
    local racketGuardConfigId = MissionUtils:getRacketGuardConfigId()
    local racketGuard = MissionUtils:placeActorAtLocationId(racketGuardConfigId, 0, Character:getPlayer():get3DPos())
    racketGuard.memory.gangster = gangster
    Utils:startConversation(playerFaction.boss, racketGuard, "EVENT_CONVERSATION", "GangsterResurrection_Start", true, gangster)
end

function reviveGangster()

    gangster.anims:removeRagdoll()
    gangster.anims:resurrect()

    gangster:removeTag("Dead")
    gangster:removeState("Dead")
    gangster:removeState("Immobile")

    gangster.health:heal(gangster.maxHealth, false)
    gangster.health:startAutoHealing()

    gangster.worldActor:setIconVisible(true)
    gangster.visionTarget:setActive(true)

    if gangster.gunHandler.activeWeapon then
        gangster.shooter:holsterWeapon()
    end
    gangster.anims:setCombatAnim(false)
    gangster.navigation:resetSpeed()
    gangster.navigation:setActive(true)

    gangster:dispatchPooledEvent("onExitCombat", "survivingFaction", nil, "wasFullCombat", true, "resurrecting", true)
    Utils:raiseGameEvent("onResurrect", "actor", gangster)

    gangster:addState("ForceHireable")
    local doNotShowAlert = true
    WorldUtils:getPlayerFaction():attemptHire(gangster, nil, 0, doNotShowAlert, true)

    if gangster:hasState("FadeToVoid") then
        gangster:removeState("FadeToVoid")
    end

    if gangster:hasState("RemoveIfIdleAndOffScreen") then
        gangster:removeState("RemoveIfIdleAndOffScreen")
    end

    if not gangster.commands:has("Talk") then
        gangster.commands:add("Talk", 100)
    end

    -- MEGAMOD FIX: vanilla hides this alert, so the player is never told the revived
    -- gangster spends 7 days in the hospital before returning to the safehouse
    gangster:addState("Injury", "configId", "INJURY_DATA.MODERATE", "days", 7, "hideAlert", false)
    gangster:revive()
    complete()
end

function onComplete()

    fact.GangsterResurrectionEvent = nil
end

--[[------------------------------------------------------------------------------
    MegaMod: Crew Nicknames
    Tracks combats survived by player RPCs and assigns escalating nicknames
    as they prove themselves in battle.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Nickname Monitor - Background listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREW_NICKNAMES_MONITOR"
_event = "MegaModCrewNicknamesMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
combatCounts = {}

persist{}
nicknameAssigned = {}

local TIER_1_THRESHOLD = 5
local TIER_2_THRESHOLD = 15

-- Shuffle a copy of a table and return it
-- MEGAMOD FIX: global function (local helpers don't get the sandbox env)
function shufflePool(pool)
    local copy = {}
    for i = 1, #pool do copy[i] = pool[i] end
    for i = #copy, 2, -1 do
        local j = math.random(1, i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    return copy
end

local tier1Nicknames = {
    "$MEGAMOD_NICK_trigger",       --$ Trigger
    "$MEGAMOD_NICK_hotlead",       --$ Hot Lead
    "$MEGAMOD_NICK_cannon",        --$ The Cannon
    "$MEGAMOD_NICK_smokestack",    --$ Smokestack
    "$MEGAMOD_NICK_ironside",      --$ Ironside
    "$MEGAMOD_NICK_knuckles",      --$ Knuckles
    "$MEGAMOD_NICK_brasstacks",    --$ Brass Tacks
    "$MEGAMOD_NICK_hammer",        --$ The Hammer
}

local tier2Nicknames = {
    "$MEGAMOD_NICK_reaper",        --$ The Reaper
    "$MEGAMOD_NICK_angelofdeath",  --$ Angel of Death
    "$MEGAMOD_NICK_widowmaker",    --$ Widowmaker
    "$MEGAMOD_NICK_executioner",   --$ The Executioner
    "$MEGAMOD_NICK_hellfire",      --$ Hellfire
    "$MEGAMOD_NICK_butcher",       --$ The Butcher
    "$MEGAMOD_NICK_gravedigger",   --$ Gravedigger
    "$MEGAMOD_NICK_oldscratch",    --$ Old Scratch
}

function GameEvent.onCombatEnd(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    -- Build a lookup of surviving combat actor iids for fast checking
    local inCombat = {}
    if e.autoResolved then
        -- MEGAMOD FIX: count auto-resolved combats too (vanilla World.lua raises
        -- onCombatEnd with autoResolved=true; state still holds the participants)
        local autoResolveState = WorldUtils:getAutoResolveState()
        if not autoResolveState then return end
        for iid, _ in next, autoResolveState.attackingPlayerGangsters do
            inCombat[iid] = true
        end
        for iid, _ in next, autoResolveState.defendingPlayerGangsters do
            inCombat[iid] = true
        end
    else
        -- Don't count cancelled combats (entered/exited ambush mode without fighting)
        local combatContext = WorldUtils:getCombatContext()
        if combatContext.combatCancelled then return end
        local combatActors = combatContext.combatActors
        if not combatActors then return end
        for i = 1, #combatActors do
            local actor = combatActors[i]
            if actor then
                inCombat[actor.iid] = true
            end
        end
    end

    -- Check each RPC
    local rpcs = playerFaction:getRPCs() -- MEGAMOD FIX: faction.rpcs is legacy (nil after load)
    for i = 1, #rpcs do
        local rpc = rpcs[i]
        if rpc and inCombat[rpc.iid] then
            local iid = rpc.iid
            combatCounts[iid] = (combatCounts[iid] or 0) + 1
            local count = combatCounts[iid]
            local currentTier = nicknameAssigned[iid] or 0

            -- MEGAMOD FIX: don't fight vanilla NicknameManager over characters it
            -- already named (it likewise skips anyone whose nickName is set)
            if not (rpc.nickName and currentTier == 0) then
                -- Check for tier 2 upgrade
                if count >= TIER_2_THRESHOLD and currentTier < 2 then
                    -- MEGAMOD FIX: mark the tier here (the dialog block can't write this
                    -- table) and pass everything on the scheduled event as varargs, so
                    -- the award survives save/load and the dialog always has options
                    nicknameAssigned[iid] = 2
                    local shuffled = shufflePool(tier2Nicknames)
                    WorldUtils:scheduleWithDelay("MegaModCrewNicknameEarned", 5, "TICK",
                        "nickIid", iid, "nickTier", 2,
                        "choice1", shuffled[1], "choice2", shuffled[2], "choice3", shuffled[3], "choice4", shuffled[4])
                    return -- One nickname event per combat

                -- Check for tier 1
                elseif count >= TIER_1_THRESHOLD and currentTier < 1 then
                    nicknameAssigned[iid] = 1
                    local shuffled = shufflePool(tier1Nicknames)
                    WorldUtils:scheduleWithDelay("MegaModCrewNicknameEarned", 5, "TICK",
                        "nickIid", iid, "nickTier", 1,
                        "choice1", shuffled[1], "choice2", shuffled[2], "choice3", shuffled[3], "choice4", shuffled[4])
                    return
                end
            end
        end
    end
end

--[[------------------------------------------------------------------------------
    Nickname Earned Notification
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_CREW_NICKNAME_EARNED"
_event = "MegaModCrewNicknameEarned"
_category = "Misc"

persist{}
nickIid = nil

persist{}
nickTier = 0

persist{}
choice1 = nil

persist{}
choice2 = nil

persist{}
choice3 = nil

persist{}
choice4 = nil

function canTrigger()
    return nickIid ~= nil
end

function getNickRpc()
    local rpc = nickIid and ActorUtils:getActorFromId(nickIid)
    if rpc and not rpc:isDead() and rpc.faction == WorldUtils:getPlayerFaction() then
        return rpc
    end
    return nil
end

function onTrigger()
    -- MEGAMOD FIX: never open a modal with zero options; if the character or the
    -- choices are gone, show nothing and let the event auto-complete
    if not getNickRpc() or not choice1 then return end

    setModal(true)
    if nickTier == 2 then
        title("$MEGAMOD_NICK_tier2_title") --$ A Legend Is Born
        text("$MEGAMOD_NICK_tier2_text") --$ After surviving 15 firefights, one of your crew has earned a fearsome new reputation on the streets. Rivals cross the road when they see this one coming. Even your own boys talk about them in whispers. What name will stick?
    else
        title("$MEGAMOD_NICK_tier1_title") --$ Earning a Name
        text("$MEGAMOD_NICK_tier1_text") --$ One of your crew has survived 5 firefights and lived to brag about it. The boys are tossing around a few names. Which one sticks?
    end

    -- Present the nickname choices to the player
    option(choice1, applyNick1)
    if choice2 then option(choice2, applyNick2) end
    if choice3 then option(choice3, applyNick3) end
    if choice4 then option(choice4, applyNick4) end
end

function applyNick1()
    applyNickname(choice1)
end

function applyNick2()
    applyNickname(choice2)
end

function applyNick3()
    applyNickname(choice3)
end

function applyNick4()
    applyNickname(choice4)
end

function applyNickname(nickKey)
    local rpc = getNickRpc()
    if rpc and nickKey then
        -- Same fields vanilla NicknameManager writes; it skips anyone already named
        rpc.nickName = nickKey
        rpc.nickNameOrder = "infix"
    end
end

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
_autoStartMode = "Schedule"
_triggerDelay = 200
_category = "Misc"

persist{}
combatCounts = {}

persist{}
nicknameAssigned = {}

persist{}
pendingNickIid = nil

persist{}
pendingNickTier = 0

persist{}
pendingNickKey = nil

persist{}
pendingNickName = nil

local TIER_1_THRESHOLD = 5
local TIER_2_THRESHOLD = 15

pendingChoices = nil
pendingRpc = nil

-- Shuffle a copy of a table and return it
local function shufflePool(pool)
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

function canTrigger()
    return true
end

function onTrigger()
    complete()
end

function GameEvent.onCombatEnd(eventData)
    -- Don't count cancelled combats (entered/exited ambush mode without fighting)
    local combatContext = WorldUtils:getCombatContext()
    if combatContext.combatCancelled then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    local rpcs = playerFaction.rpcs
    if not rpcs then return end

    -- Get actors who were in this combat
    local combatActors = combatContext.combatActors
    if not combatActors then return end

    -- Build a lookup of combat actor iids for fast checking
    local inCombat = {}
    for i = 1, #combatActors do
        local actor = combatActors[i]
        if actor then
            inCombat[actor.iid] = true
        end
    end

    -- Check each RPC
    for _, rpc in next, rpcs do
        if rpc and inCombat[rpc.iid] then
            local iid = rpc.iid
            combatCounts[iid] = (combatCounts[iid] or 0) + 1
            local count = combatCounts[iid]
            local currentTier = nicknameAssigned[iid] or 0

            -- Check for tier 2 upgrade
            if count >= TIER_2_THRESHOLD and currentTier < 2 then
                pendingNickIid = iid
                pendingNickTier = 2
                pendingNickName = rpc.name or "your crew member"
                -- Pick 4 random choices from the tier 2 pool
                local shuffled = shufflePool(tier2Nicknames)
                pendingChoices = {shuffled[1], shuffled[2], shuffled[3], shuffled[4]}
                pendingRpc = rpc
                WorldUtils:scheduleWithDelay("MegaModCrewNicknameEarned", 5, "TICK")
                return -- One nickname event per combat

            -- Check for tier 1
            elseif count >= TIER_1_THRESHOLD and currentTier < 1 then
                pendingNickIid = iid
                pendingNickTier = 1
                pendingNickName = rpc.name or "your crew member"
                -- Pick 4 random choices from the tier 1 pool
                local shuffled = shufflePool(tier1Nicknames)
                pendingChoices = {shuffled[1], shuffled[2], shuffled[3], shuffled[4]}
                pendingRpc = rpc
                WorldUtils:scheduleWithDelay("MegaModCrewNicknameEarned", 5, "TICK")
                return
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

function canTrigger()
    return pendingNickIid ~= nil
end

function onTrigger()
    setModal(true)
    if pendingNickTier == 2 then
        title("$MEGAMOD_NICK_tier2_title") --$ A Legend Is Born
        text("$MEGAMOD_NICK_tier2_text") --$ After surviving 15 firefights, one of your crew has earned a fearsome new reputation on the streets. Rivals cross the road when they see this one coming. Even your own boys talk about them in whispers. What name will stick?
    else
        title("$MEGAMOD_NICK_tier1_title") --$ Earning a Name
        text("$MEGAMOD_NICK_tier1_text") --$ One of your crew has survived 5 firefights and lived to brag about it. The boys are tossing around a few names. Which one sticks?
    end

    -- Present 4 nickname choices to the player
    if pendingChoices and pendingRpc then
        option(pendingChoices[1], applyNick1)
        option(pendingChoices[2], applyNick2)
        option(pendingChoices[3], applyNick3)
        option(pendingChoices[4], applyNick4)
    end
end

function applyNick1()
    applyNickname(pendingChoices[1])
end

function applyNick2()
    applyNickname(pendingChoices[2])
end

function applyNick3()
    applyNickname(pendingChoices[3])
end

function applyNick4()
    applyNickname(pendingChoices[4])
end

function applyNickname(nickKey)
    if pendingRpc then
        pendingRpc.nickName = nickKey
        pendingRpc.nickNameOrder = "infix"
    end
    nicknameAssigned[pendingNickIid] = pendingNickTier
    pendingNickIid = nil
    pendingNickTier = 0
    pendingNickName = nil
    pendingChoices = nil
    pendingRpc = nil
    complete()
end

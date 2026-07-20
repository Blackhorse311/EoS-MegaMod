--[[------------------------------------------------------------------------------
    MegaMod: Newspaper Headlines
    Background listener that generates headlines from significant player actions.
    Headlines affect police heat, notoriety, and public perception.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_HEADLINE_LISTENER"
_event = "MegaModHeadlineListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
lastHeadlineTime = 0
persist{}
racketCount = 0

local headlineCooldownSeconds = 7 * 24 * 60 * 60  -- 7 days in seconds

-- MEGAMOD FIX: global function (local helpers don't get the sandbox env) reading the
-- worldTime special var (`client` is unreachable from script context)
function canShowHeadline()
    if not lastHeadlineTime or lastHeadlineTime == 0 then return true end
    return (worldTime - lastHeadlineTime) > headlineCooldownSeconds
end

function GameEvent.onWarDeclared(e)
    if not canShowHeadline() then return end
    local playerFaction = WorldUtils:getPlayerFaction()
    -- MEGAMOD FIX: payload is attackers/defenders faction lists (vanilla War.lua)
    local involved = false
    if e.attackers then
        for i = 1, #e.attackers do
            if e.attackers[i] == playerFaction then involved = true end
        end
    end
    if not involved and e.defenders then
        for i = 1, #e.defenders do
            if e.defenders[i] == playerFaction then involved = true end
        end
    end
    if involved then
        lastHeadlineTime = worldTime
        WorldUtils:scheduleWithDelay("MegaModHeadlineWar", Utils:daysToSecs(1), "DAILY_TICK")
    end
end

-- MEGAMOD FIX: was onCharacterDeath + LateRequires (unreachable in sandbox, asserted on
-- every death); onBossDeath carries the dead boss as e.target (vanilla Boss.lua)
function GameEvent.onBossDeath(e)
    if not canShowHeadline() then return end
    local boss = e.target
    if not boss or boss.isPlayer then return end
    local deathInformation = boss:getState("Dead")
    local killerFaction = deathInformation and deathInformation.killerFaction
    local playerInvolved = (killerFaction and killerFaction.isPlayerFaction) and true or false
    lastHeadlineTime = worldTime
    WorldUtils:scheduleWithDelay("MegaModHeadlineBossDeath", Utils:daysToSecs(1), "DAILY_TICK", "playerInvolved", playerInvolved)
end

function GameEvent.onRacketAcquired(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if e.faction == playerFaction then -- MEGAMOD FIX: payload field is e.faction (vanilla Faction.lua)
        racketCount = racketCount + 1
        if racketCount % 5 == 0 and canShowHeadline() then
            lastHeadlineTime = worldTime
            WorldUtils:scheduleWithDelay("MegaModHeadlineEmpire", Utils:daysToSecs(1), "DAILY_TICK")
        end
    end
end

function GameEvent.onBuildingRaidedByPolice(e)
    if not canShowHeadline() then return end
    local playerFaction = WorldUtils:getPlayerFaction()
    if e.targetFaction == playerFaction then -- MEGAMOD FIX: payload field is e.targetFaction (vanilla BuildingAttackedEvents.lua)
        lastHeadlineTime = worldTime
        WorldUtils:scheduleWithDelay("MegaModHeadlineCrackdown", Utils:daysToSecs(1), "DAILY_TICK")
    end
end

--[[------------------------------------------------------------------------------
    HEADLINE: Gang War
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HEADLINE_WAR"
_event = "MegaModHeadlineWar"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_HEAD_WAR_title") --$ EXTRA! EXTRA! Gang War Erupts!
    text("$MEGAMOD_HEAD_WAR_text") --$ The morning papers are screaming about open warfare on the streets of Chicago. Rival gangs are settling scores with lead and dynamite. The mayor is demanding action and the cops are out in force. Every racket in the city is feeling the heat.
    option("$MEGAMOD_HEAD_WAR_option") --$ Toss the paper aside
    -- MEGAMOD FIX: no complete() in UI onTrigger (use-after-release); auto-complete handles it
end

--[[------------------------------------------------------------------------------
    HEADLINE: Boss Death
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HEADLINE_BOSS_DEATH"
_event = "MegaModHeadlineBossDeath"
_category = "Misc"

persist{}
playerInvolved = false

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_HEAD_DEATH_title") --$ CRIME LORD SLAIN!
    text("$MEGAMOD_HEAD_DEATH_text") --$ A gang boss has been killed and the papers are having a field day. Every reporter in Chicago is digging for details, and the public is demanding that the police crack down on organized crime. Your notoriety is rising.
    option("$MEGAMOD_HEAD_DEATH_option") --$ Let them write what they want
    -- MEGAMOD FIX: notoriety only when the player's faction made the kill
    if playerInvolved then
        local playerFaction = WorldUtils:getPlayerFaction()
        if playerFaction and playerFaction.boss then
            playerFaction.boss:addNotoriety(3, "$MEGAMOD_HEAD_DEATH_noto") --$ Headline: Crime Lord Slain
        end
    end
end

--[[------------------------------------------------------------------------------
    HEADLINE: Empire Grows
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HEADLINE_EMPIRE"
_event = "MegaModHeadlineEmpire"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_HEAD_EMPIRE_title") --$ CRIMINAL EMPIRE GROWS!
    text("$MEGAMOD_HEAD_EMPIRE_text") --$ The Tribune is running a front-page exposé on the rapid expansion of criminal operations across the city. Your name is mentioned more than once. The police commissioner has vowed to put a stop to it.
    option("$MEGAMOD_HEAD_EMPIRE_option") --$ Good publicity is still publicity
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.boss then
        playerFaction.boss:addNotoriety(2, "$MEGAMOD_HEAD_EMPIRE_noto") --$ Headline: Empire Grows
    end
end

--[[------------------------------------------------------------------------------
    HEADLINE: Police Crackdown
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HEADLINE_CRACKDOWN"
_event = "MegaModHeadlineCrackdown"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_HEAD_CRACK_title") --$ FEDS CRACK DOWN!
    text("$MEGAMOD_HEAD_CRACK_text") --$ Federal agents raided one of your operations and the newspapers are eating it up. "BOOTLEGGER'S EMPIRE UNDER SIEGE" reads the headline. The increased attention means tighter margins for a while.
    option("$MEGAMOD_HEAD_CRACK_option") --$ This too shall pass
end

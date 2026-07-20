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

local function canShowHeadline()
    if not lastHeadlineTime or lastHeadlineTime == 0 then return true end
    return (client.time.worldTime - lastHeadlineTime) > headlineCooldownSeconds
end

function GameEvent.onWarDeclared(e)
    if not canShowHeadline() then return end
    local playerFaction = WorldUtils:getPlayerFaction()
    if e.declarer == playerFaction or e.target == playerFaction then
        lastHeadlineTime = client.time.worldTime
        WorldUtils:scheduleWithDelay("MegaModHeadlineWar", Utils:daysToSecs(1), "DAILY_TICK")
    end
end

function GameEvent.onCharacterDeath(e)
    if not canShowHeadline() then return end
    if e.target and e.target:isA(LateRequires and LateRequires.getBoss and LateRequires.getBoss()) then
        lastHeadlineTime = client.time.worldTime
        WorldUtils:scheduleWithDelay("MegaModHeadlineBossDeath", Utils:daysToSecs(1), "DAILY_TICK")
    end
end

function GameEvent.onRacketAcquired(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if e.newOwner == playerFaction then
        racketCount = racketCount + 1
        if racketCount % 5 == 0 and canShowHeadline() then
            lastHeadlineTime = client.time.worldTime
            WorldUtils:scheduleWithDelay("MegaModHeadlineEmpire", Utils:daysToSecs(1), "DAILY_TICK")
        end
    end
end

function GameEvent.onBuildingRaidedByPolice(e)
    if not canShowHeadline() then return end
    local playerFaction = WorldUtils:getPlayerFaction()
    if e.faction == playerFaction then
        lastHeadlineTime = client.time.worldTime
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
    complete()
end

--[[------------------------------------------------------------------------------
    HEADLINE: Boss Death
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HEADLINE_BOSS_DEATH"
_event = "MegaModHeadlineBossDeath"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_HEAD_DEATH_title") --$ CRIME LORD SLAIN!
    text("$MEGAMOD_HEAD_DEATH_text") --$ A gang boss has been killed and the papers are having a field day. Every reporter in Chicago is digging for details, and the public is demanding that the police crack down on organized crime. Your notoriety is rising.
    option("$MEGAMOD_HEAD_DEATH_option") --$ Let them write what they want
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.boss then
        playerFaction.boss:addNotoriety(3, "$MEGAMOD_HEAD_DEATH_noto") --$ Headline: Crime Lord Slain
    end
    complete()
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
    complete()
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
    complete()
end

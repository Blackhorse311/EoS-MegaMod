--[[------------------------------------------------------------------------------
    MegaMod: Sal's Bonus
    After a boss kill, Sal follows up with a bonus offer for a clean job.
    Supplements the vanilla Sweet Home Chicago $15,000 with an extra $35,000.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_SAL_BONUS_LISTENER"
_event = "MegaModSalBonusListener"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 100
_category = "Misc"

persist{}
bossesKilled = 0

function canTrigger()
    return true
end

function onTrigger()
    complete()
end

function GameEvent.onBossDeath(e)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    -- Only trigger if the dead boss was from a rival faction, not the player's
    if e.target and e.target.faction and not e.target.faction.isPlayerFaction then
        bossesKilled = bossesKilled + 1
        -- Short delay to let Sal's vanilla dialog close first
        WorldUtils:scheduleWithDelay("MegaModSalBonusDialog", 10, "TICK")
    end
end

--[[------------------------------------------------------------------------------
    Sal's Bonus Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_SAL_BONUS_DIALOG"
_event = "MegaModSalBonusDialog"
_category = "Misc"

function onTrigger()
    setModal(true)
    title("$MEGAMOD_SAL_BONUS_title") --$ A Call from Sal
    text("$MEGAMOD_SAL_BONUS_text") --$ Your phone rings. It's Sal. "Hey, hey, nice work out there! Listen, I didn't wanna say nothin' in front of everybody, but the people upstairs are real impressed with how clean that was. They're throwing in an extra thirty-five grand as a bonus. Consider it a tip for good service, capisce?"
    option("$MEGAMOD_SAL_BONUS_accept", collectBonus) --$ Tell Sal I appreciate the business.
end

function collectBonus()
    BRScript:PlayerAddCash(35000, "CASH.SAL_BONUS")
    complete()
end

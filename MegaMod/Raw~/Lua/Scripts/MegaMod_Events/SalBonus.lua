--[[------------------------------------------------------------------------------
    MegaMod: Sal's Bonus
    After a boss kill, Sal follows up with a bonus offer for a clean job.
    Supplements the vanilla Sweet Home Chicago $15,000 with an extra $35,000.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_SAL_BONUS_LISTENER"
_event = "MegaModSalBonusListener"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: Schedule+complete() released this event before onBossDeath could ever fire
_category = "Misc"

function GameEvent.onBossDeath(e)
    -- Only trigger if the dead boss was from a rival faction, not the player's
    if not e.target or e.target.isPlayer then return end
    if e.target.faction and e.target.faction.isPlayerFaction then return end

    -- MEGAMOD FIX: only pay out when the PLAYER's faction made the kill.
    -- The Dead state stores killerFaction (vanilla Health.lua DEAD onAdd).
    local deathInformation = e.target:getState("Dead")
    local killerFaction = deathInformation and deathInformation.killerFaction
    if not killerFaction or not killerFaction.isPlayerFaction then return end

    -- Short delay to let Sal's vanilla dialog close first
    WorldUtils:scheduleWithDelay("MegaModSalBonusDialog", 10, "TICK")
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
    -- MEGAMOD FIX: CASH.SAL_BONUS is not a defined CASH config id; auto-complete closes the event after the option
    BRScript:PlayerAddCash(35000, "CASH.MISSION_REWARD")
end

--[[------------------------------------------------------------------------------
    MegaMod: Boss Mode Bankroll
    On Boss difficulty (5), gives the player $20,000 starting cash on day 2.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_HARD_BANKROLL_LISTENER"
_event = "MegaModHardBankrollListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
dayCount = 0

function GameEvent.onDayBegin(eventData)
    dayCount = dayCount + 1
    if dayCount >= 2 then
        if WorldUtils:getWorldDifficulty() == 5 then  -- MEGAMOD FIX: `World` is unreachable in script sandbox (was silently never granting)
            BRScript:PlayerAddCash(20000, "CASH.MISSION_REWARD")
        end
        complete()
    end
end

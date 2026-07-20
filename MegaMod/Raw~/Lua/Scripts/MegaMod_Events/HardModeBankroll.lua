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
        if World and World.difficulty and World.difficulty == 5 then
            BRScript:PlayerAddCash(20000, "CASH.MISSION_REWARD")
        end
        complete()
    end
end

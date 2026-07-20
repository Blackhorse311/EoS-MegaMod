_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
PROTECTION MONEY
--------------------------------------------------------------------------------]]
_id = "PROTECTION_MONEY"
_event = "ProtectionMoney"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_category = "UnionMission"
_triggerDelay = 250

function canTrigger()
    local year = 1921
    local month = 1

    local correctDate = true
    if month ~= WorldUtils:getGameMonth() then correctDate = false end
    if year ~= WorldUtils:getGameYear() then correctDate = false end
    return correctDate
end

function onTrigger()
    title("$ProtectionMoney") --$ Protection Money
    text({"$ProtectionMoney_text"}) --$ A local thug approaches you after a brief stint in the clink. "I was pardoned by Lennington Small and I think it’s time to clean up my act. He told me about your gang though, so here’s some money to look the other way." How do you want to deal with the thug?
    option("$ProtectionMoney_ResponseA", getCash) --$ [ACCEPT +$500] Take the money and let him go.
    option("$ProtectionMoney_ResponseB", getNotoriety) --$ [REFUSE +NOTORIETY] Not in my town. Get out.
end

function getCash()
    BRScript:PlayerAddCash(500, "CASH.MISSION_REWARD")
    complete()
end

function getNotoriety()
    WorldUtils:getPlayerFaction().boss:addNotoriety(10, "$KickedOutThugInProtectionMoneyEvent") --$ Chose second option
    complete()
end

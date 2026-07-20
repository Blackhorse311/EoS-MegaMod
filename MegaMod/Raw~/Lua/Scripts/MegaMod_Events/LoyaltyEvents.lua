--[[------------------------------------------------------------------------------
    MegaMod: Crew Loyalty Events
    Low loyalty triggers defection events, high loyalty triggers bonus perks.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_LOYALTY_MONITOR"
_event = "MegaModLoyaltyMonitor"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 300
_category = "Misc"

persist{}
lastLoyaltyCheckTime = 0

local loyaltyDefectionThreshold = 15
local loyaltyBonusThreshold = 80

function canTrigger()
    return true
end

function onTrigger()
    complete()
end

function GameEvent.onWeekBegin(e)
    -- Cooldown: 1 week minimum between loyalty events
    local cooldownSeconds = Utils:daysToSecs(7)
    if lastLoyaltyCheckTime > 0 and (worldTime - lastLoyaltyCheckTime) < cooldownSeconds then
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    local rpcs = playerFaction.rpcs
    if not rpcs then return end

    for _, rpc in next, rpcs do
        if rpc and rpc.loyalty then
            local loyalty = rpc.loyalty.count or 50

            -- Low loyalty: chance of defection
            if loyalty <= loyaltyDefectionThreshold and math.random() < 0.15 then
                lastLoyaltyCheckTime = worldTime
                WorldUtils:scheduleWithDelay("MegaModLoyaltyDefection", 5, "TICK")
                return -- One event per week max
            end

            -- High loyalty: chance of bonus
            if loyalty >= loyaltyBonusThreshold and math.random() < 0.05 then
                lastLoyaltyCheckTime = worldTime
                WorldUtils:scheduleWithDelay("MegaModLoyaltyBonus", 5, "TICK")
                return
            end
        end
    end
end

--[[------------------------------------------------------------------------------
    DEFECTION EVENT
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LOYALTY_DEFECTION"
_event = "MegaModLoyaltyDefection"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_LOYAL_DEFECT_title") --$ Trouble in the Ranks
    text("$MEGAMOD_LOYAL_DEFECT_text") --$ One of your crew has been seen talking to a rival outfit. Word is they're unhappy and thinking about jumping ship. If you don't act fast, you could lose them -- or worse, they could take your secrets with them.
    option("$MEGAMOD_LOYAL_DEFECT_bribe", tryBribe) --$ Pay them to stay ($200)
    option("$MEGAMOD_LOYAL_DEFECT_letgo", letThemGo) --$ Good riddance
end

function tryBribe()
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction.cash.count >= 200 then
        BRScript:PlayerSubtractCash(200, "CASH.LOYALTY_BRIBE")
        title("$MEGAMOD_LOYAL_DEFECT_bribed_title") --$ Loyalty Bought
        text("$MEGAMOD_LOYAL_DEFECT_bribed_text") --$ A bonus and a pat on the back go a long way. Your crew member reconsiders and decides to stick around -- for now. Money can't buy loyalty forever, but it buys enough time.
        option("$MEGAMOD_LOYAL_DEFECT_dismiss") --$ Keep your eyes open
    else
        title("$MEGAMOD_LOYAL_DEFECT_broke_title") --$ Can't Afford It
        text("$MEGAMOD_LOYAL_DEFECT_broke_text") --$ You don't have the cash to throw around. Your crew member takes the silence as an answer and starts packing their bags.
        option("$MEGAMOD_LOYAL_DEFECT_dismiss") --$ Damn.
    end
    complete()
end

function letThemGo()
    title("$MEGAMOD_LOYAL_DEFECT_gone_title") --$ They're Gone
    text("$MEGAMOD_LOYAL_DEFECT_gone_text") --$ You cut them loose. Better to have an enemy you know than a traitor you don't. They'll land somewhere else, and they'll remember how you treated them.
    option("$MEGAMOD_LOYAL_DEFECT_dismiss") --$ Next.
    complete()
end

--[[------------------------------------------------------------------------------
    LOYALTY BONUS EVENT
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LOYALTY_BONUS"
_event = "MegaModLoyaltyBonus"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    title("$MEGAMOD_LOYAL_BONUS_title") --$ Loyal Crew Member
    text("$MEGAMOD_LOYAL_BONUS_text") --$ One of your most trusted crew members approaches you with a gift. "Been saving this up, boss. Figured you could use it more than me." Their loyalty is beyond question -- and they want to prove it.
    option("$MEGAMOD_LOYAL_BONUS_cash", bonusCash) --$ Accept the tribute
    option("$MEGAMOD_LOYAL_BONUS_intel", bonusIntel) --$ Ask them to dig up some dirt
end

function bonusCash()
    local cash = math.random(150, 300)
    BRScript:PlayerAddCash(cash, "CASH.LOYALTY_TRIBUTE")
    title("$MEGAMOD_LOYAL_BONUS_cash_title") --$ Tribute Received
    text({"$MEGAMOD_LOYAL_BONUS_cash_text", cash}) --$ Your loyal crew member hands over ${0}. It's not a fortune, but it's earned, and that makes it worth more than any shakedown.
    option("$MEGAMOD_LOYAL_BONUS_dismiss") --$ Good work.
    complete()
end

function bonusIntel()
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.boss then
        playerFaction.boss:addNotoriety(2, "$MEGAMOD_LOYAL_BONUS_intel_noto") --$ Crew intel gathering
    end
    title("$MEGAMOD_LOYAL_BONUS_intel_title") --$ Intel Gathered
    text("$MEGAMOD_LOYAL_BONUS_intel_text") --$ Your crew member spends a few days working their contacts and comes back with useful information about rival operations. Knowledge is power, and now you've got a little more of both.
    option("$MEGAMOD_LOYAL_BONUS_dismiss") --$ Excellent.
    complete()
end

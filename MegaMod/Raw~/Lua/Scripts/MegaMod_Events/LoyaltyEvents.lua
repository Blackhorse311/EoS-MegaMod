--[[------------------------------------------------------------------------------
    MegaMod: Crew Loyalty Events
    Low loyalty triggers defection events, high loyalty triggers bonus perks.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

_id = "MEGAMOD_LOYALTY_MONITOR"
_event = "MegaModLoyaltyMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
lastLoyaltyCheckTime = 0

local loyaltyDefectionThreshold = 15
local loyaltyBonusThreshold = 80

-- MEGAMOD FIX: Create-mode listener (Schedule-mode events are created inactive and
-- complete() in onTrigger unregistered the weekly handler, so checks never ran)
function GameEvent.onWeekBegin(e)
    -- Cooldown: 1 week minimum between loyalty events
    local cooldownSeconds = Utils:daysToSecs(7)
    if lastLoyaltyCheckTime > 0 and (worldTime - lastLoyaltyCheckTime) < cooldownSeconds then
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    local rpcs = playerFaction:getRPCs() -- MEGAMOD FIX: faction.rpcs is legacy (nil after load)

    for i = 1, #rpcs do
        local rpc = rpcs[i]
        if rpc and rpc.loyalty then
            local loyalty = rpc.loyalty:get() -- MEGAMOD FIX: loyalty.count doesn't exist

            -- Low loyalty: chance of defection
            if loyalty <= loyaltyDefectionThreshold and math.random() < 0.15 then
                lastLoyaltyCheckTime = worldTime
                WorldUtils:scheduleWithDelay("MegaModLoyaltyDefection", 5, "TICK", "defectorIid", rpc.iid)
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

persist{}
defectorIid = nil

function canTrigger() return true end

function getDefector()
    local rpc = defectorIid and ActorUtils:getActorFromId(defectorIid)
    if rpc and not rpc:isDead() and rpc.faction == WorldUtils:getPlayerFaction() then
        return rpc
    end
    return nil
end

function onTrigger()
    -- MEGAMOD FIX: if the defector is already gone, show nothing (event auto-completes)
    if not getDefector() then return end
    setModal(true)
    title("$MEGAMOD_LOYAL_DEFECT_title") --$ Trouble in the Ranks
    text("$MEGAMOD_LOYAL_DEFECT_text") --$ One of your crew has been seen talking to a rival outfit. Word is they're unhappy and thinking about jumping ship. If you don't act fast, you could lose them -- or worse, they could take your secrets with them.
    option("$MEGAMOD_LOYAL_DEFECT_bribe", tryBribe) --$ Pay them to stay ($200)
    option("$MEGAMOD_LOYAL_DEFECT_letgo", letThemGo) --$ Good riddance
end

-- MEGAMOD FIX: content set inside option callbacks never renders (engine completes the
-- event first), so outcomes use Utils:alertDialog; bribe/defection now have real effects
function tryBribe()
    local cost = math.floor(200 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
    local playerFaction = WorldUtils:getPlayerFaction()
    local rpc = getDefector()
    if playerFaction.cash.count >= cost then
        BRScript:PlayerSubtractCash(cost, "CASH.LOYALTY_BRIBE")
        if rpc then
            rpc.loyalty:add(25, "$MEGAMOD_LOYAL_DEFECT_bribed_title")
        end
        Utils:alertDialog({
            title = "$MEGAMOD_LOYAL_DEFECT_bribed_title", --$ Loyalty Bought
            text = "$MEGAMOD_LOYAL_DEFECT_bribed_text", --$ A bonus and a pat on the back go a long way. Your crew member reconsiders and decides to stick around -- for now. Money can't buy loyalty forever, but it buys enough time.
            usesNoButton = false
        })
    else
        if rpc then
            rpc:leaveFaction()
        end
        Utils:alertDialog({
            title = "$MEGAMOD_LOYAL_DEFECT_broke_title", --$ Can't Afford It
            text = "$MEGAMOD_LOYAL_DEFECT_broke_text", --$ You don't have the cash to throw around. Your crew member takes the silence as an answer and starts packing their bags.
            usesNoButton = false
        })
    end
end

function letThemGo()
    local rpc = getDefector()
    if rpc then
        rpc:leaveFaction() -- MEGAMOD FIX: they actually leave now
    end
    Utils:alertDialog({
        title = "$MEGAMOD_LOYAL_DEFECT_gone_title", --$ They're Gone
        text = "$MEGAMOD_LOYAL_DEFECT_gone_text", --$ You cut them loose. Better to have an enemy you know than a traitor you don't. They'll land somewhere else, and they'll remember how you treated them.
        usesNoButton = false
    })
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
    local cash = math.floor(math.random(150, 300) * (fact.MegaModCfgPayout or 1)) -- MEGAMOD CONFIG: payout knob
    BRScript:PlayerAddCash(cash, "CASH.LOYALTY_TRIBUTE")
    Utils:alertDialog({
        title = "$MEGAMOD_LOYAL_BONUS_cash_title", --$ Tribute Received
        text = {"$MEGAMOD_LOYAL_BONUS_cash_text", cash}, --$ Your loyal crew member hands over ${0}. It's not a fortune, but it's earned, and that makes it worth more than any shakedown.
        usesNoButton = false
    })
end

function bonusIntel()
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.boss then
        playerFaction.boss:addNotoriety(2, "$MEGAMOD_LOYAL_BONUS_intel_noto") --$ Crew intel gathering
    end
    Utils:alertDialog({
        title = "$MEGAMOD_LOYAL_BONUS_intel_title", --$ Intel Gathered
        text = "$MEGAMOD_LOYAL_BONUS_intel_text", --$ Your crew member spends a few days working their contacts and comes back with useful information about rival operations. Knowledge is power, and now you've got a little more of both.
        usesNoButton = false
    })
end

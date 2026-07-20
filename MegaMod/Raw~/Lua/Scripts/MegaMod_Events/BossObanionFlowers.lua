--[[------------------------------------------------------------------------------
    MegaMod: Flowers from Schofield's (EventDirector: BOSS_OBANION_FLOWERS)
    Dean O'Banion runs the Northside from behind the counter of Schofield's
    flower shop on State Street -- florist to every mob funeral in town, a
    grin, a limp, and three guns under the apron. When an arrangement arrives
    with an unsigned card, that's not a gift. That's an old-country warning.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). Eligible only
    while the Northside Mob is in the campaign, known to the player, and
    O'Banion is still among his chrysanthemums.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSOBANION_LISTENER"
_event = "MegaModBossObanionListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

-- Northside Mob in campaign + known to player (getKnownGangs + _active) + boss alive
function bossObanionFindNorthside()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.diplomacy then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return nil end
    for i = 1, #knownGangs do
        local gang = knownGangs[i]
        if gang and gang._active and gang.configId == "FACTION.THE_NORTHSIDE_MOB"
                and gang.boss and not gang.boss:isDead() then
            return gang
        end
    end
    return nil
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BOSS_OBANION_FLOWERS" then return end

    local northside = bossObanionFindNorthside()
    if not northside then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOSS_OBANION_FLOWERS")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModBossObanionOffer", 5, "TICK",
        "obanionFlowersFactionId", northside.factionId)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BOSS_OBANION_FLOWERS")
end

--[[------------------------------------------------------------------------------
    THE ARRANGEMENT
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSOBANION_OFFER"
_event = "MegaModBossObanionOffer"
_category = "Misc"

persist{}
obanionFlowersFactionId = nil -- Expected Param

function bossObanionGetNorthside()
    local northside = WorldUtils:getFactionByFactionId(obanionFlowersFactionId)
    if northside and northside._active then return northside end
    return nil
end

function bossObanionRespectsCost()
    return math.floor(300 * (fact.MegaModCfgCost or 1) + 0.5)
end

function bossObanionWatchCost()
    return math.floor(500 * (fact.MegaModCfgCost or 1) + 0.5)
end

function bossObanionShowResult(titleKey, textKey, arg)
    WorldUtils:triggerEvent("MegaModBossObanionResult",
        "bossObanionResultTitle", titleKey,
        "bossObanionResultText", textKey,
        "bossObanionResultArg", arg)
end

function canTrigger()
    return obanionFlowersFactionId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BOSSOBANION_title") --$ Flowers from Schofield's
    text("$MEGAMOD_BOSSOBANION_text") --$ A delivery boy in a clean cap sets it on your desk and is gone before anybody thinks to stop him: an arrangement from Schofield's, State Street -- lilies, carnations, a spray of chrysanthemums tied like they were going to a bishop's funeral. The card is heavy cream stock and blank on both sides. Everybody in Chicago knows whose shop that is. Deanie O'Banion clips stems and wires wreaths behind that counter with a grin and a bad leg and three revolvers under the apron, and half the funerals his flowers dress are funerals his boys arranged. An unsigned arrangement from Schofield's is the old country talking: somebody on the North Side is thinking about you. Whether it's a courtesy or a measurement for the casket depends entirely on what you do next.
    if BRScript:PlayerCanAfford(bossObanionRespectsCost()) then
        option({"$MEGAMOD_BOSSOBANION_respects", bossObanionRespectsCost()}, bossObanionPayRespects) --$ Go to the shop. Pay respects in person (${0})
    end
    option("$MEGAMOD_BOSSOBANION_sendback", bossObanionSendBack) --$ Send the flowers back where they grew.
    if BRScript:PlayerCanAfford(bossObanionWatchCost()) then
        option({"$MEGAMOD_BOSSOBANION_watch", bossObanionWatchCost()}, bossObanionWatchShop) --$ Have the shop watched (${0})
    end
end

function bossObanionPayRespects()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cost = bossObanionRespectsCost()
    if not playerFaction or playerFaction.cash.count < cost then
        bossObanionShowResult("$MEGAMOD_BOSSOBANION_broke_title", "$MEGAMOD_BOSSOBANION_broke_text") --$ Empty Pockets / You count the roll twice and it doesn't get any bigger. Whatever you were going to do about Deanie's flowers, you're doing it broke -- and showing up at Schofield's without a tribute in hand would be worse than not showing up at all. The arrangement sits on your desk, sweet and patient, quietly going brown.
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.EXPENSES")

    local northside = bossObanionGetNorthside()
    if northside then
        northside.rating:applyEffect(playerFaction, "FAVOR_GRANTED_HALF")
    end

    bossObanionShowResult("$MEGAMOD_BOSSOBANION_respects_title", "$MEGAMOD_BOSSOBANION_respects_text") --$ Among the Chrysanthemums / You go yourself, hat in hand, tribute folded in an envelope, and buy the biggest wreath in the window while you're at it. O'Banion comes out from the back wiping soil off his fingers, that famous grin already working. He talks flowers for ten minutes -- what travels, what wilts, what a man should send to a christening -- and business for two, and the envelope disappears into the apron without either of you mentioning it. At the door he claps your shoulder with a florist's gentle hand. "You're all right," he says, which from Deanie is a treaty, signed and notarized. On the North Side, respect paid in person is the only currency that never inflates.
end

function bossObanionSendBack()
    local playerFaction = WorldUtils:getPlayerFaction()
    local northside = bossObanionGetNorthside()
    if northside and playerFaction then
        northside.rating:applyEffect(playerFaction, "THREATENED")
    end

    bossObanionShowResult("$MEGAMOD_BOSSOBANION_sendback_title", "$MEGAMOD_BOSSOBANION_sendback_text") --$ Return to Sender / You put the arrangement back in a truck and send it up State Street with no card of your own -- the message being, in any language, we don't scare. It's a fine gesture right up until you remember who you sent it to. Word comes back that Deanie took the flowers in stride, grinning, and told his boys to put them on the next funeral out -- "waste not." Then he stopped grinning. The North Side keeps books on this sort of thing, and somewhere behind that flower counter, next to the shears and the ribbon and the revolvers, your name just moved to a different page.
end

function bossObanionWatchShop()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cost = bossObanionWatchCost()
    if not playerFaction or playerFaction.cash.count < cost then
        bossObanionShowResult("$MEGAMOD_BOSSOBANION_broke_title", "$MEGAMOD_BOSSOBANION_broke_text")
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.EXPENSES")

    if math.random() < 0.60 then
        -- The watchers earn their keep: something a rival outfit pays well for
        local payout = math.floor(1200 * (fact.MegaModCfgPayout or 1) + 0.5)
        BRScript:PlayerAddCash(payout, "CASH.TRADE")
        bossObanionShowResult("$MEGAMOD_BOSSOBANION_watch_win_title", "$MEGAMOD_BOSSOBANION_watch_win_text", payout) --$ The Flower Ledger / Two of your quieter boys spend a week nursing coffees across from Schofield's, and it pays like a slot machine with a broken cam. Who comes in the front for roses and out the back without them. Which alderman's car idles at the curb on Thursdays. Which North Side faces do the talking and which just stand by the door. None of it is evidence, all of it is merchandise -- and there's a fellow on the South Side who pays cash for exactly this kind of gardening news. ${0}, and Deanie none the wiser. Flowers, it turns out, tell everything.
    else
        local northside = bossObanionGetNorthside()
        if northside then
            northside.rating:applyEffect(playerFaction, "AGGRESSIVE_BEHAVIOUR")
        end
        bossObanionShowResult("$MEGAMOD_BOSSOBANION_watch_made_title", "$MEGAMOD_BOSSOBANION_watch_made_text") --$ Made in a Doorway / Your watchers last four days. On the fifth, a Schofield's delivery truck double-parks beside their doorway and three men who have never once held flowers get out of it. Nobody's hurt -- that's the message, delivered with terrifying courtesy: your boys are walked to the corner, handed a boutonniere apiece, and told to give their boss Deanie's regards. O'Banion spotted the tail from behind his own counter, because of course he did; the man reads his street the way a florist reads frost. The North Side now knows you were peeping through their window, and they take that the way the old country takes everything -- personally.
    end
end

--[[------------------------------------------------------------------------------
    RESULT DIALOG (generic title/text + optional format arg)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSOBANION_RESULT"
_event = "MegaModBossObanionResult"
_category = "Misc"

persist{}
bossObanionResultTitle = nil

persist{}
bossObanionResultText = nil

persist{}
bossObanionResultArg = nil

function canTrigger()
    return bossObanionResultTitle ~= nil
end

function onTrigger()
    setModal(true)
    title(bossObanionResultTitle)
    if bossObanionResultArg ~= nil then
        text({bossObanionResultText, bossObanionResultArg})
    else
        text(bossObanionResultText)
    end
    option("$MEGAMOD_BOSSOBANION_dismiss") --$ Never trust a smiling florist.
end

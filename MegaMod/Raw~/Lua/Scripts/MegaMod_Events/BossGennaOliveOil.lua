--[[------------------------------------------------------------------------------
    MegaMod: The Olive Oil Concern (EventDirector: BOSS_GENNA_OLIVE_OIL)
    The Terrible Gennas of Little Italy -- six brothers, a federal license to
    handle industrial alcohol, and a still bubbling in every second tenement
    kitchen off Taylor Street. When their emissary comes around offering
    "olive oil" by the barrel, it is not olive oil. Buy the lot, tip off the
    Prohibition Bureau, or send him home with his hat on straight.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). Eligible only
    while the Genna family is in the campaign, known to the player, and the
    boss is still alive.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSGENNA_LISTENER"
_event = "MegaModBossGennaListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

-- Genna family in campaign + known to player (getKnownGangs + _active) + boss alive
function bossGennaFindFamily()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.diplomacy then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return nil end
    for i = 1, #knownGangs do
        local gang = knownGangs[i]
        if gang and gang._active and gang.configId == "FACTION.GENNA_CRIME_FAMILY"
                and gang.boss and not gang.boss:isDead() then
            return gang
        end
    end
    return nil
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BOSS_GENNA_OLIVE_OIL" then return end

    local family = bossGennaFindFamily()
    if not family then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOSS_GENNA_OLIVE_OIL")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModBossGennaOffer", 5, "TICK",
        "gennaOilFactionId", family.factionId)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BOSS_GENNA_OLIVE_OIL")
end

--[[------------------------------------------------------------------------------
    THE SHIPMENT
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSGENNA_OFFER"
_event = "MegaModBossGennaOffer"
_category = "Misc"

persist{}
gennaOilFactionId = nil -- Expected Param

function bossGennaGetFamily()
    local family = WorldUtils:getFactionByFactionId(gennaOilFactionId)
    if family and family._active then return family end
    return nil
end

function bossGennaLotCost()
    return math.floor(450 * (fact.MegaModCfgCost or 1) + 0.5)
end

function bossGennaShowResult(titleKey, textKey, arg)
    WorldUtils:triggerEvent("MegaModBossGennaResult",
        "bossGennaResultTitle", titleKey,
        "bossGennaResultText", textKey,
        "bossGennaResultArg", arg)
end

function canTrigger()
    return gennaOilFactionId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BOSSGENNA_title") --$ The Olive Oil Concern
    text("$MEGAMOD_BOSSGENNA_text") --$ The man who calls on you smells faintly of anise and speaks in the soft, patient voice of somebody who has explained this many times. He represents, he says, an importing concern on Taylor Street -- olive oil, cheeses, the good things from the old country. The Gennas' concern. Everybody knows the Gennas: six brothers out of Marsala with a federal license to handle industrial alcohol and a still simmering in every second tenement kitchen in Little Italy, tended by grandmothers at fifteen dollars a day. What comes out is raw alky -- cut, colored, and christened whiskey by the time it hits the bar. He produces a sample bottle labeled OLIO D'OLIVA and sets it on your desk without a flicker of irony. The price he quotes is very good. The Gennas' prices are always very good; that is how Little Italy stays theirs.
    if BRScript:PlayerCanAfford(bossGennaLotCost()) then
        option({"$MEGAMOD_BOSSGENNA_buy", bossGennaLotCost()}, bossGennaBuy) --$ Buy the lot (${0})
    end
    option("$MEGAMOD_BOSSGENNA_tip", bossGennaTipBureau) --$ Send the Prohibition Bureau a shopping list.
    option("$MEGAMOD_BOSSGENNA_decline", bossGennaDecline) --$ Send him home, hat on straight.
end

function bossGennaBuy()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cost = bossGennaLotCost()
    if not playerFaction or playerFaction.cash.count < cost then
        bossGennaShowResult("$MEGAMOD_BOSSGENNA_broke_title", "$MEGAMOD_BOSSGENNA_broke_text") --$ Empty Pockets / You count the roll twice and it doesn't get any bigger. The emissary watches you do it with the mild, unhurried sympathy of a man whose family has seen every empty pocket in Little Italy. He caps the sample bottle, wishes you better weeks ahead, and leaves the way he came. The Gennas will sell to somebody else before supper. The Gennas always sell to somebody.
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.TRADE")

    local barrels = math.random(14, 22)
    WorldUtils:addAlcoholToFaction(playerFaction, barrels, 2) -- type 2 = ALCOHOL.SWILL

    local family = bossGennaGetFamily()
    if family then
        family.rating:applyEffect(playerFaction, "FAVOR_GRANTED_HALF")
    end

    bossGennaShowResult("$MEGAMOD_BOSSGENNA_buy_title", "$MEGAMOD_BOSSGENNA_buy_text", barrels) --$ Olio d'Oliva / The truck comes at dusk, {0} barrels stenciled OLIO D'OLIVA in fresh paint, and not one of them has ever been within a nautical mile of an olive. It's alky -- raw, throat-scouring, honest in its dishonesty -- and at the Gennas' price it will pour just fine once your people cut it and dress it up with a respectable label. The emissary shakes your hand at the tailgate. "The family is pleased," he says, and means it; Taylor Street likes a customer who doesn't ask questions with an Italian accent. Cheap goods, good terms, and the Terrible Gennas smiling in your direction. In this town that is nearly a friendship.
end

function bossGennaTipBureau()
    local playerFaction = WorldUtils:getPlayerFaction()

    -- A gift for the Bureau: the Federal Heat meter cools (FederalHeat.lua owns the meter)
    fact.MegaModFedHeat = math.max(0, (fact.MegaModFedHeat or 0) - 12)

    if math.random() < 0.35 then
        -- Little Italy has more ears than the Bureau has agents
        local family = bossGennaGetFamily()
        if family and playerFaction then
            family.rating:applyEffect(playerFaction, "THREATENED")
        end
        bossGennaShowResult("$MEGAMOD_BOSSGENNA_tip_leak_title", "$MEGAMOD_BOSSGENNA_tip_leak_text") --$ Taylor Street Hears Everything / The raids come off beautifully -- three kitchens padlocked, a walloping headline, a Bureau man photographed with his axe in a barrel -- and for a week the federal building thinks kindly of whoever furnished the addresses. Then the week ends. A Bureau clerk owes a Taylor Street bookmaker; the bookmaker owes the Gennas; arithmetic happens. Word crosses Little Italy in an afternoon: the shopping list came from your desk. Six brothers out of Marsala, and not one of them has ever been described as forgiving. The federal men got their photographs. You got something too -- a place in the family's ledger, written in red.
    else
        bossGennaShowResult("$MEGAMOD_BOSSGENNA_tip_win_title", "$MEGAMOD_BOSSGENNA_tip_win_text") --$ A Gift for the Bureau / You send it the careful way -- a typed page, no signature, mailed from a drugstore three neighborhoods over: addresses, delivery nights, which stairwells smell of mash. The Prohibition Bureau falls on Little Italy like Christmas morning. Three kitchens padlocked, a photograph of an agent axing a barrel on the front page, and somewhere in the federal building a file with your name on it quietly moves down the stack -- the Bureau is warmly disposed toward whoever hands it victories. The Gennas absorb the loss the way the family absorbs everything, patiently, and start new kitchens by Friday. They never learn where the list came from. Taylor Street hears everything, but this once, it heard nothing at all.
    end
end

function bossGennaDecline()
    bossGennaShowResult("$MEGAMOD_BOSSGENNA_decline_title", "$MEGAMOD_BOSSGENNA_decline_text") --$ Regrets, Signor / You tell him your cellars are full and your bartenders particular, and you say it with just enough courtesy that nobody's honor has to get up from its chair. The emissary takes it well; the Gennas' men always take it well, which is one of the several unsettling things about them. He recorks the sample, settles his hat, and pauses at the door. "The price holds until it doesn't," he says pleasantly, and is gone. No offense given, none taken. The olive oil concern rolls on down the street to the next thirsty operator, and Little Italy stays exactly what it has always been: somebody else's country, three blocks wide.
end

--[[------------------------------------------------------------------------------
    RESULT DIALOG (generic title/text + optional format arg)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSGENNA_RESULT"
_event = "MegaModBossGennaResult"
_category = "Misc"

persist{}
bossGennaResultTitle = nil

persist{}
bossGennaResultText = nil

persist{}
bossGennaResultArg = nil

function canTrigger()
    return bossGennaResultTitle ~= nil
end

function onTrigger()
    setModal(true)
    title(bossGennaResultTitle)
    if bossGennaResultArg ~= nil then
        text({bossGennaResultText, bossGennaResultArg})
    else
        text(bossGennaResultText)
    end
    option("$MEGAMOD_BOSSGENNA_dismiss") --$ Never trust the label.
end

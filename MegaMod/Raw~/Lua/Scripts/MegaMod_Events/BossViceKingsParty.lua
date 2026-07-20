--[[------------------------------------------------------------------------------
    MegaMod: An Evening at the Parlor (EventDirector: BOSS_VICE_KINGS_PARTY)
    Daniel McKee Jackson buries the South Side's dead by day and runs its
    pleasures by night -- undertaker, policy king, and the smoothest political
    hand south of the Loop. An engraved invitation to one of his affairs is
    half honor and half examination. Everyone who matters will be there.
    Everyone who matters will be watching what you do with it.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). Eligible only
    while the Vice Kings are in the campaign, known to the player, and the
    boss is still on the right side of his own caskets.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSVICEKINGS_LISTENER"
_event = "MegaModBossViceKingsListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

-- Vice Kings in campaign + known to player (getKnownGangs + _active) + boss alive
function bossViceKingsFindGang()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.diplomacy then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return nil end
    for i = 1, #knownGangs do
        local gang = knownGangs[i]
        if gang and gang._active and gang.configId == "FACTION.VICE_KINGS"
                and gang.boss and not gang.boss:isDead() then
            return gang
        end
    end
    return nil
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BOSS_VICE_KINGS_PARTY" then return end

    local gang = bossViceKingsFindGang()
    if not gang then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOSS_VICE_KINGS_PARTY")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModBossViceKingsOffer", 5, "TICK",
        "viceKingsPartyFactionId", gang.factionId)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BOSS_VICE_KINGS_PARTY")
end

--[[------------------------------------------------------------------------------
    THE INVITATION
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSVICEKINGS_OFFER"
_event = "MegaModBossViceKingsOffer"
_category = "Misc"

persist{}
viceKingsPartyFactionId = nil -- Expected Param

function bossViceKingsGetGang()
    local gang = WorldUtils:getFactionByFactionId(viceKingsPartyFactionId)
    if gang and gang._active then return gang end
    return nil
end

function bossViceKingsGiftCost()
    return math.floor(350 * (fact.MegaModCfgCost or 1) + 0.5)
end

function bossViceKingsContactPayout()
    return math.floor(1000 * (fact.MegaModCfgPayout or 1) + 0.5)
end

function bossViceKingsShowResult(titleKey, textKey, arg)
    WorldUtils:triggerEvent("MegaModBossViceKingsResult",
        "bossViceKingsResultTitle", titleKey,
        "bossViceKingsResultText", textKey,
        "bossViceKingsResultArg", arg)
end

function canTrigger()
    return viceKingsPartyFactionId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BOSSVICEKINGS_title") --$ An Evening at the Parlor
    text("$MEGAMOD_BOSSVICEKINGS_text") --$ The invitation arrives by liveried messenger: heavy card, engraved, your name in a copperplate hand that cost somebody real money. Mr. Daniel McKee Jackson requests the pleasure of your company -- an evening of music and refreshment at the Jackson establishment, which is to say the funeral parlor, which is to say the finest room on the South Side once the lids are on and the lilies cleared. Everybody knows how Jackson's affairs run: a wake upstairs if the week demanded one, and downstairs the aldermen, the policy men, the club owners, the fixers, all balancing cut glass and ambition under the electric chandeliers. Jackson buries the South Side's dead and finances its living, and there is no better room in Chicago for meeting the people who decide things. An invitation like this is half honor, half examination. The whole South Side will notice who came, what they brought, and how they carried themselves among the caskets.
    if BRScript:PlayerCanAfford(bossViceKingsGiftCost()) then
        option({"$MEGAMOD_BOSSVICEKINGS_gift", bossViceKingsGiftCost()}, bossViceKingsAttendGift) --$ Attend, with a proper gift for the host (${0})
    end
    option("$MEGAMOD_BOSSVICEKINGS_work", bossViceKingsWorkRoom) --$ Attend, and work the room for business.
    option("$MEGAMOD_BOSSVICEKINGS_regrets", bossViceKingsSendRegrets) --$ Send regrets and a decent bottle.
end

function bossViceKingsAttendGift()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cost = bossViceKingsGiftCost()
    if not playerFaction or playerFaction.cash.count < cost then
        bossViceKingsShowResult("$MEGAMOD_BOSSVICEKINGS_broke_title", "$MEGAMOD_BOSSVICEKINGS_broke_text") --$ Empty Pockets / You count the roll twice and it doesn't get any bigger. Arriving at Daniel Jackson's affair with empty hands would be remarked upon -- everything at Jackson's is remarked upon, that's what the room is for -- and remarked upon is one thing you cannot afford this week either. The invitation goes in a drawer, engraved side down.
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.TRIBUTE")

    local gang = bossViceKingsGetGang()
    if gang then
        gang.rating:applyEffect(playerFaction, "FAVOR_GRANTED_HALF")
    end

    bossViceKingsShowResult("$MEGAMOD_BOSSVICEKINGS_gift_title", "$MEGAMOD_BOSSVICEKINGS_gift_text") --$ Received With Pleasure / You arrive at a civilized hour with a gift chosen to be admired aloud, and Daniel McKee Jackson receives you the way he receives everything -- gravely, graciously, with the calm of a man who has seen every human vanity laid out on satin and buried it by appointment. He walks you the length of the room himself, which is the real gift: past the aldermen, past the policy bankers, one hand light on your shoulder, pronouncing your name clearly each time. Nothing is promised. Nothing at Jackson's is ever promised. But the South Side keeps books on who stood where, and tonight you stood beside the undertaker while the band played something slow and expensive. There are cheaper endorsements in Chicago. There are none better.
end

function bossViceKingsWorkRoom()
    local playerFaction = WorldUtils:getPlayerFaction()
    local gang = bossViceKingsGetGang()

    if math.random() < 0.55 then
        local payout = bossViceKingsContactPayout()
        BRScript:PlayerAddCash(payout, "CASH.TRADE")
        bossViceKingsShowResult("$MEGAMOD_BOSSVICEKINGS_work_win_title", "$MEGAMOD_BOSSVICEKINGS_work_win_text", payout) --$ The Right Handshake / You come to be seen and stay to be useful. By the second hour you've found him: a club owner from down near the Stroll, drowning in success, desperate for cases of the good stuff and a partner who can move quietly. The arrangement is sketched on the back of a dance card between numbers -- terms, quantities, a handshake dry as a banker's. ${0} on the front end and the promise of more where discretion holds. Jackson himself glides past as you conclude, and the look he gives you is worth framing: mild, amused, proprietary. His room did what his room does. He'll remember that you knew how to use it -- and that, at Jackson's, is how careers begin.
    else
        if gang and playerFaction then
            gang.rating:applyEffect(playerFaction, "THREATENED")
        end
        bossViceKingsShowResult("$MEGAMOD_BOSSVICEKINGS_work_lose_title", "$MEGAMOD_BOSSVICEKINGS_work_lose_text") --$ Bad Form Among the Lilies / You push too hard, too early, too loud. The club owner you corner turns out to be Jackson's cousin; the policy banker you brace has paid Jackson for protection from exactly this sort of evening; and the room -- the whole listening, glittering room -- notes every word. Daniel McKee Jackson says nothing. Jackson never says anything; that is the terror of the man. He simply stops introducing you, and by midnight you are as alone in that crowd as a man in a display casket. The message finds you at the door, delivered by a waiter with a bishop's poise: Mr. Jackson thanks you for coming. On the South Side, that sentence, spoken just so, closes more doors than a padlock.
    end
end

function bossViceKingsSendRegrets()
    bossViceKingsShowResult("$MEGAMOD_BOSSVICEKINGS_regrets_title", "$MEGAMOD_BOSSVICEKINGS_regrets_text") --$ Regrets, Politely / You send a courteous note and a bottle good enough to apologize for itself. It's the safe play: no gift to be judged, no room to misread, no chance of ending the night as the story everybody dines out on next week. Jackson's reply comes two days later, engraved, three lines, immaculate: he regrets your absence and hopes business keeps treating you well. Read it twice and you notice what a South Side man would have caught at once -- it does not mention a next time. The parlor's doors aren't closed to you. But nobody is holding them open, either, and at Daniel Jackson's establishment that distinction is the whole of politics.
end

--[[------------------------------------------------------------------------------
    RESULT DIALOG (generic title/text + optional format arg)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSVICEKINGS_RESULT"
_event = "MegaModBossViceKingsResult"
_category = "Misc"

persist{}
bossViceKingsResultTitle = nil

persist{}
bossViceKingsResultText = nil

persist{}
bossViceKingsResultArg = nil

function canTrigger()
    return bossViceKingsResultTitle ~= nil
end

function onTrigger()
    setModal(true)
    title(bossViceKingsResultTitle)
    if bossViceKingsResultArg ~= nil then
        text({bossViceKingsResultText, bossViceKingsResultArg})
    else
        text(bossViceKingsResultText)
    end
    option("$MEGAMOD_BOSSVICEKINGS_dismiss") --$ The undertaker always collects.
end

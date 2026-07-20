--[[------------------------------------------------------------------------------
    MegaMod: Polack Joe's Peace (EventDirector: BOSS_SALTIS_TRUCE)
    Joe Saltis runs beer through Back of the Yards and runs for Wisconsin the
    minute anybody starts shooting. His partner Frank McErlane brought the
    first Tommy gun to Chicago and is the reason anybody takes the outfit
    seriously. When Saltis wants a quiet border he does what he always does:
    he pays for it. The envelope is real. The question is what it costs later.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). Eligible only
    while Saltis-McErlane is in the campaign, known to the player, and the
    boss is still above ground.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSSALTIS_LISTENER"
_event = "MegaModBossSaltisListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

-- Saltis-McErlane in campaign + known to player (getKnownGangs + _active) + boss alive
function bossSaltisFindGang()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.diplomacy then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return nil end
    for i = 1, #knownGangs do
        local gang = knownGangs[i]
        if gang and gang._active and gang.configId == "FACTION.SALTIS_MCERLANE"
                and gang.boss and not gang.boss:isDead() then
            return gang
        end
    end
    return nil
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BOSS_SALTIS_TRUCE" then return end

    local gang = bossSaltisFindGang()
    if not gang then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOSS_SALTIS_TRUCE")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModBossSaltisOffer", 5, "TICK",
        "saltisTruceFactionId", gang.factionId)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BOSS_SALTIS_TRUCE")
end

--[[------------------------------------------------------------------------------
    THE ENVELOPE
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSSALTIS_OFFER"
_event = "MegaModBossSaltisOffer"
_category = "Misc"

persist{}
saltisTruceFactionId = nil -- Expected Param

function bossSaltisGetGang()
    local gang = WorldUtils:getFactionByFactionId(saltisTruceFactionId)
    if gang and gang._active then return gang end
    return nil
end

function bossSaltisPeaceAmount()
    return math.floor(800 * (fact.MegaModCfgPayout or 1) + 0.5)
end

function bossSaltisShowResult(titleKey, textKey, arg)
    WorldUtils:triggerEvent("MegaModBossSaltisResult",
        "bossSaltisResultTitle", titleKey,
        "bossSaltisResultText", textKey,
        "bossSaltisResultArg", arg)
end

function canTrigger()
    return saltisTruceFactionId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BOSSSALTIS_title") --$ Polack Joe's Peace
    text({"$MEGAMOD_BOSSSALTIS_text", bossSaltisPeaceAmount()}) --$ The envoy is a big, apologetic man in a suit cut for a smaller decade, and he sets a fat envelope on your desk before he's finished saying hello. Compliments of Mr. Saltis. Everybody knows Polack Joe: he moves more beer through Back of the Yards than anybody south of the river, and the first crack of gunfire in any war finds him already on a train to his Wisconsin lodge, fishing rod in hand, patriotically absent. Everybody also knows his partner -- Frank McErlane, who introduced Chicago to the Thompson submachine gun and has the disposition of a man who regrets nothing. The proposition is simple, the envoy says. A quiet border. No hijacking, no poaching, no misunderstandings. Mr. Saltis finds peace cheaper than war and has priced it accordingly: ${0}, today, with his compliments. Mr. McErlane, the envoy adds carefully, was not consulted.
    option({"$MEGAMOD_BOSSSALTIS_take", bossSaltisPeaceAmount()}, bossSaltisTake) --$ Take the envelope (${0})
    option("$MEGAMOD_BOSSSALTIS_squeeze", bossSaltisSqueeze) --$ Tell him the price of peace just doubled.
    option("$MEGAMOD_BOSSSALTIS_refuse", bossSaltisRefuse) --$ Send the envelope back unopened.
end

function bossSaltisTake()
    local playerFaction = WorldUtils:getPlayerFaction()
    local amount = bossSaltisPeaceAmount()
    BRScript:PlayerAddCash(amount, "CASH.TRUCE")

    local gang = bossSaltisGetGang()
    if gang and playerFaction then
        gang.rating:applyEffect(playerFaction, "FAVOR_GRANTED_HALF")
    end

    bossSaltisShowResult("$MEGAMOD_BOSSSALTIS_take_title", "$MEGAMOD_BOSSSALTIS_take_text", amount) --$ Cheaper Than War / You take the envelope -- ${0}, in the soft old bills of a man who genuinely hates spending new ones -- and the envoy beams like a priest at a christening. Word goes back to Back of the Yards that the border is quiet, and Joe Saltis sleeps the sleep of a man who has never once been ashamed of buying his way out of anything. It's the rarest thing in Chicago: everybody got what they wanted and nobody bled for it. The beer trucks roll, the envelope sits in your safe, and somewhere up in Wisconsin the muskies can rest easy for a season. Peace, it turns out, has a market price. Joe always could spot a bargain.
end

function bossSaltisSqueeze()
    local playerFaction = WorldUtils:getPlayerFaction()
    local gang = bossSaltisGetGang()

    if math.random() < 0.60 then
        local amount = bossSaltisPeaceAmount() * 2
        BRScript:PlayerAddCash(amount, "CASH.TRUCE")
        if gang and playerFaction then
            gang.rating:applyEffect(playerFaction, "AGGRESSIVE_BEHAVIOUR")
        end
        bossSaltisShowResult("$MEGAMOD_BOSSSALTIS_squeeze_win_title", "$MEGAMOD_BOSSSALTIS_squeeze_win_text", amount) --$ The Price Doubles / The envoy's smile dies by inches while you explain the new arithmetic. He makes a telephone call from your outer office, speaking Polish, quietly, the way men speak when the news is bad and the listener is worse. Then he comes back, sits down, and counts out the rest -- ${0} all told, every bill surrendered like a hostage. Joe Saltis pays. Joe Saltis always pays; it's the secret of his longevity and the ruin of his reputation. But understand what you've bought: peace, yes, at double rate -- and a line in Joe's little book, because even a coward keeps accounts. Cowards, in fact, keep the best ones.
    else
        if gang and playerFaction then
            gang.rating:applyEffect(playerFaction, "THREATENED")
        end
        bossSaltisShowResult("$MEGAMOD_BOSSSALTIS_squeeze_lose_title", "$MEGAMOD_BOSSSALTIS_squeeze_lose_text") --$ McErlane Answers / The envoy makes his telephone call, and it is not Joe Saltis who answers it. The voice on the line is flat and unhurried and asks the envoy to repeat the number twice, not because he didn't hear it, but because he wanted you to watch the envoy say it again. Frank McErlane does not negotiate; Frank McErlane brought the Tommy gun to this town as a personal statement of philosophy. The envoy retrieves the envelope with trembling courtesy and leaves at a speed just short of undignified. No deal, no peace, no envelope -- and down in Back of the Yards, a man who regrets nothing has written your name on the wall above his bed. Joe will be in Wisconsin by Thursday. He knows what he's partnered with.
    end
end

function bossSaltisRefuse()
    bossSaltisShowResult("$MEGAMOD_BOSSSALTIS_refuse_title", "$MEGAMOD_BOSSSALTIS_refuse_text") --$ Return to Sender / You slide the envelope back across the desk unopened, which takes more willpower than you'd admit in company. No insult intended, you tell the envoy -- you just don't sell what isn't for sale, and your border was never for sale. He receives this with the weary patience of a man who has delivered many envelopes and had a surprising number of them slid back. Word returns to Back of the Yards that you can't be bought, which Joe Saltis finds baffling and Frank McErlane finds mildly interesting, and neither reaction costs you anything today. Nothing gained, nothing owed. Though a man does wonder, some nights, what was in it.
end

--[[------------------------------------------------------------------------------
    RESULT DIALOG (generic title/text + optional format arg)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSSALTIS_RESULT"
_event = "MegaModBossSaltisResult"
_category = "Misc"

persist{}
bossSaltisResultTitle = nil

persist{}
bossSaltisResultText = nil

persist{}
bossSaltisResultArg = nil

function canTrigger()
    return bossSaltisResultTitle ~= nil
end

function onTrigger()
    setModal(true)
    title(bossSaltisResultTitle)
    if bossSaltisResultArg ~= nil then
        text({bossSaltisResultText, bossSaltisResultArg})
    else
        text(bossSaltisResultText)
    end
    option("$MEGAMOD_BOSSSALTIS_dismiss") --$ Everybody's got a price. His is reasonable.
end

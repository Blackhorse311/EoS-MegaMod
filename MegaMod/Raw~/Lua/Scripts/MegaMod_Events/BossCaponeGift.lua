--[[------------------------------------------------------------------------------
    MegaMod: With Al's Compliments (EventDirector: BOSS_CAPONE_GIFT)
    Al Capone the showman-philanthropist -- soup kitchens on State Street,
    milk for the schoolkids, and grand gestures nobody dared refuse. A truck
    of Templeton Rye arrives "with Al's compliments." Accept it graciously,
    return it with respect, or sell the lot and brag to the papers.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). Eligible only
    while The Outfit is in the campaign, known to the player, and Capone is
    still breathing.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSCAPONE_LISTENER"
_event = "MegaModBossCaponeListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

-- The Outfit must be in this campaign, KNOWN to the player (getKnownGangs +
-- _active, the RivalProvocations idiom), and Capone himself still alive
-- (faction.configId verified sandbox-readable in Tactic_PoliceExploreMore.lua)
function bossCaponeFindOutfit()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.diplomacy then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return nil end
    for i = 1, #knownGangs do
        local gang = knownGangs[i]
        if gang and gang._active and gang.configId == "FACTION.THE_OUTFIT"
                and gang.boss and not gang.boss:isDead() then
            return gang
        end
    end
    return nil
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BOSS_CAPONE_GIFT" then return end

    local outfit = bossCaponeFindOutfit()
    if not outfit then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOSS_CAPONE_GIFT")
        return
    end

    -- Factions are identified across _id blocks by factionId (script vars are
    -- not shared across blocks -- RivalProvocations payload pattern)
    WorldUtils:scheduleWithDelay("MegaModBossCaponeOffer", 5, "TICK",
        "caponeGiftFactionId", outfit.factionId)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BOSS_CAPONE_GIFT")
end

--[[------------------------------------------------------------------------------
    THE GIFT TRUCK
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSCAPONE_OFFER"
_event = "MegaModBossCaponeOffer"
_category = "Misc"

persist{}
caponeGiftFactionId = nil -- Expected Param

-- Re-resolve at click time; the Outfit could have folded between pick and dialog
function bossCaponeGetOutfit()
    local outfit = WorldUtils:getFactionByFactionId(caponeGiftFactionId)
    if outfit and outfit._active then return outfit end
    return nil
end

function bossCaponeSellAmount()
    return math.floor(900 * (fact.MegaModCfgPayout or 1) + 0.5)
end

function bossCaponeShowResult(titleKey, textKey, arg)
    WorldUtils:triggerEvent("MegaModBossCaponeResult",
        "bossCaponeResultTitle", titleKey,
        "bossCaponeResultText", textKey,
        "bossCaponeResultArg", arg)
end

function canTrigger()
    return caponeGiftFactionId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BOSSCAPONE_title") --$ With Al's Compliments
    text("$MEGAMOD_BOSSCAPONE_text") --$ A truck idles outside your safehouse at ten in the morning, broad daylight, horn honking like a parade. The driver hands over a manifest with a flourish he's clearly practiced: a full load of Templeton Rye -- the good stuff, the Iowa article Al pours for judges -- "with Mr. Capone's compliments." That's the big fellow all over. He feeds half the South Side from a soup kitchen and gets his picture taken doing it; he sends milk to schoolkids and gifts to men he's measuring. There's no card, because a card would imply you might say no. Everybody in Chicago knows what happened to the last man who embarrassed Al in public. The driver waits, smiling, engine running.
    option("$MEGAMOD_BOSSCAPONE_accept", bossCaponeAccept) --$ Accept it graciously. Unload the truck.
    option("$MEGAMOD_BOSSCAPONE_ret", bossCaponeReturn) --$ Return it, with every courtesy.
    option({"$MEGAMOD_BOSSCAPONE_sell", bossCaponeSellAmount()}, bossCaponeSell) --$ Sell the lot and let the papers know (${0})
end

function bossCaponeAccept()
    local playerFaction = WorldUtils:getPlayerFaction()
    local amount = math.random(16, 24)
    if playerFaction then
        WorldUtils:addAlcoholToFaction(playerFaction, amount, 4) -- type 4 = ALCOHOL.TOP_SHELF
    end

    local outfit = bossCaponeGetOutfit()
    if outfit and playerFaction then
        outfit.rating:applyEffect(playerFaction, "FAVOR_GRANTED_HALF")
    end

    -- The Bureau keeps a list of the people Al likes (Federal Heat, clamp 100)
    local fedGain = math.floor(2 * (fact.MegaModCfgFedHeat or 1) + 0.5)
    fact.MegaModFedHeat = math.min(100, (fact.MegaModFedHeat or 0) + fedGain)

    bossCaponeShowResult("$MEGAMOD_BOSSCAPONE_accept_title", "$MEGAMOD_BOSSCAPONE_accept_text", amount) --$ The Good Stuff / Your boys roll {0} barrels of Templeton Rye into the cellar and the driver departs with a wave like a departing relative. It's tremendous whiskey and it cost you nothing but a handshake -- which is, of course, exactly what it cost you. Word will reach the Lexington Hotel by supper that you took Al's gift like a gentleman, and Al is warm toward men who let him be generous. One thing, though: a federal man across the street wrote down the truck's plates in a little book. The Bureau keeps a file on everybody Capone likes, and you just made the list.
end

function bossCaponeReturn()
    bossCaponeShowResult("$MEGAMOD_BOSSCAPONE_ret_title", "$MEGAMOD_BOSSCAPONE_ret_text") --$ Regrets, With Respect / You send the truck back with a case of your own best riding shotgun and a note thanking Mr. Capone for thinking of you -- but a man in your position prefers to drink what he sells and sell what he knows. It's the kind of refusal Al can live with: full of respect, empty of insult, and delivered quietly enough that no reporter will ever hear about it. The driver shrugs, guns the engine, and takes the rye back to the Lexington. Honor even. Nothing gained, nothing owed -- and with the big fellow, nothing owed is its own kind of treasure.
end

function bossCaponeSell()
    local amount = bossCaponeSellAmount()
    BRScript:PlayerAddCash(amount, "CASH.TRADE")

    local outfit = bossCaponeGetOutfit()
    local playerFaction = WorldUtils:getPlayerFaction()
    if outfit and playerFaction then
        outfit.rating:applyEffect(playerFaction, "THREATENED") -- nobody embarrasses Al
    end

    bossCaponeShowResult("$MEGAMOD_BOSSCAPONE_sell_title", "$MEGAMOD_BOSSCAPONE_sell_text", amount) --$ Rye on the Open Market / You wholesale Al's gift to three joints on the North Side by nightfall -- ${0}, cash, and you make sure the story travels with the barrels: Capone's own rye, bought and sold like anybody's bathtub gin. A columnist runs it as a wisecrack. At the Lexington Hotel, nobody laughs. Al Capone hands the mayor's town gifts in front of photographers; what he does not do is get retailed for a punchline by some operator across town. The word that comes back is short and secondhand and all the worse for its calm: "Al heard." You've got his money in your pocket and his eyes on your back.
end

--[[------------------------------------------------------------------------------
    RESULT DIALOG (generic title/text + optional format arg)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSCAPONE_RESULT"
_event = "MegaModBossCaponeResult"
_category = "Misc"

persist{}
bossCaponeResultTitle = nil

persist{}
bossCaponeResultText = nil

persist{}
bossCaponeResultArg = nil

function canTrigger()
    return bossCaponeResultTitle ~= nil
end

function onTrigger()
    setModal(true)
    title(bossCaponeResultTitle)
    if bossCaponeResultArg ~= nil then
        text({bossCaponeResultText, bossCaponeResultArg})
    else
        text(bossCaponeResultText)
    end
    option("$MEGAMOD_BOSSCAPONE_dismiss") --$ That's Chicago hospitality.
end

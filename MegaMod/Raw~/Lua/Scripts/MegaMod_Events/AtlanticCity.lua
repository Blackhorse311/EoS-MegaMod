--[[------------------------------------------------------------------------------
    MegaMod: The Boardwalk Summit (EventDirector: ATLANTIC_CITY)
    An invitation on heavy card stock: the big outfits are sitting down
    together in Atlantic City under Nucky Johnson's protection -- Luciano,
    Lansky, Torrio's people, the whole national picture. After the Clark
    Street garage mess, the watchword is "less blood, more business."
    Territories carved, tributes set, grudges parked at the city line.

    ONCE-ONLY: gated by fact.MegaModAtlanticCityDone (set at launch). The
    director also enforces this, but the local guard makes it airtight.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). The delegate
    returns 5 days later via scheduleWithDelay (save-persisted); the boon
    scale (2 = boss went, 1 = lieutenant went) rides on the event payload.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ATLANTIC_CITY_LISTENER"
_event = "MegaModAtlanticCityListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if e.eventName ~= "ATLANTIC_CITY" then return end

    -- Once-only: there is only one Boardwalk summit
    if fact.MegaModAtlanticCityDone then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "ATLANTIC_CITY")
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.boss then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "ATLANTIC_CITY")
        return
    end

    -- A summit needs somebody to make peace with
    local hasRival = false
    local knownGangs = playerFaction.diplomacy and playerFaction.diplomacy:getKnownGangs()
    if knownGangs then
        for i = 1, #knownGangs do
            if knownGangs[i]._active then
                hasRival = true
                break
            end
        end
    end
    if not hasRival then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "ATLANTIC_CITY")
        return
    end

    fact.MegaModAtlanticCityDone = 1 -- gate immediately so it can never re-pitch
    WorldUtils:scheduleWithDelay("MegaModAtlanticCityInvite", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "ATLANTIC_CITY")
end

--[[------------------------------------------------------------------------------
    THE INVITATION
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ATLANTIC_CITY_INVITE"
_event = "MegaModAtlanticCityInvite"
_category = "Misc"

-- Apply a rating effect from every known active rival toward the player
-- (direction verified in vanilla LootCrateEvents: X.rating:applyEffect(Y) moves X's opinion OF Y)
function atlanticApplyToAllRivals(playerFaction, effectId)
    if not playerFaction or not playerFaction.diplomacy then return end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return end
    for i = 1, #knownGangs do
        local rival = knownGangs[i]
        if rival and rival._active then
            rival.rating:applyEffect(playerFaction, effectId)
        end
    end
end

-- First crew member fit to travel (Moonshiners shape)
function atlanticFindLieutenant(playerFaction)
    local members = playerFaction and playerFaction.members
    if not members then return nil end
    for i = 1, #members do
        local member = members[i]
        if member and member ~= playerFaction.boss
                and not member:hasState("SentAway")
                and not member:hasState("Incarcerated") then
            return member
        end
    end
    return nil
end

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_ATLANTIC_invite_title") --$ The Boardwalk Summit
    text("$MEGAMOD_ATLANTIC_invite_text") --$ The envelope is heavy cream stock, no return address, hand-delivered by a man who left before your doorman could blink. Inside, an invitation: a sit-down in Atlantic City, under Nucky Johnson's personal protection. The names attending read like a map of the whole business -- Luciano and the Lansky crowd out of New York, Torrio's people, delegations from Philadelphia, Detroit, Kansas City. After that Valentine's morning on Clark Street, the smart men have decided the trade needs rules: territories drawn, disputes arbitrated, less blood, more business. Attendance means a thousand in travel and tribute, and five days pressing flesh on the Boardwalk. Or you can stay home and let the country's new syndicate carve the map without you.
    option("$MEGAMOD_ATLANTIC_invite_attend", atlanticAttend) --$ Attend in person ($1,000, boss away 5 days)
    option("$MEGAMOD_ATLANTIC_invite_send", atlanticSendLieutenant) --$ Send a lieutenant to represent you.
    option("$MEGAMOD_ATLANTIC_invite_snub", atlanticSnub) --$ Snub the summit. Chicago carves its own map.
end

function atlanticAttend()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.cash or playerFaction.cash.count < 1000 then
        title("$MEGAMOD_ATLANTIC_attend_broke_title") --$ Regrets Only
        text("$MEGAMOD_ATLANTIC_attend_broke_text") --$ Between the train, the hotel, and the tribute Nucky expects from every delegation, the trip runs a thousand dollars -- and the till won't carry it. You send a courteous wire pleading pressing business in Chicago. It's the truth, in its way: the pressing business is that you're broke. The summit convenes without you, and you read about the new order of things in the papers like everybody else.
        option("$MEGAMOD_ATLANTIC_dismiss_broke") --$ Next time, gentlemen.
        return
    end

    BRScript:PlayerSubtractCash(1000, "CASH.EXPENSES")

    local boss = playerFaction.boss
    if boss then
        boss:addState("SentAway", "timeAway", 5, "dontShowReturnEvent", true)
    end

    -- Full-strength boon when the boss goes in person
    WorldUtils:scheduleWithDelay("MegaModAtlanticCityReturn", Utils:daysToSecs(5), "TICK",
        "summitBoonScale", 2)

    title("$MEGAMOD_ATLANTIC_attend_title") --$ Boardwalk Bound
    text("$MEGAMOD_ATLANTIC_attend_text") --$ You pack the good suit and take the eastbound train. Atlantic City in season is a fever dream -- salt air, rolling chairs, and half the underworld of America strolling the Boardwalk in shirtsleeves like insurance men at a convention. Nucky Johnson greets every delegation like a maitre d' with a private army. For five days the trade gets itself organized: who supplies whom, who arbitrates what, and why nobody profits from another Clark Street. Being seen at that table, shaking those hands yourself -- that's worth more than the train fare home.
    option("$MEGAMOD_ATLANTIC_dismiss_attend") --$ Mind the store while I'm gone.
end

function atlanticSendLieutenant()
    local playerFaction = WorldUtils:getPlayerFaction()
    local lieutenant = playerFaction and atlanticFindLieutenant(playerFaction)

    if not lieutenant then
        title("$MEGAMOD_ATLANTIC_send_none_title") --$ Nobody to Send
        text("$MEGAMOD_ATLANTIC_send_none_text") --$ You look around the room for somebody presentable enough to sit at a table with Luciano's people, and the room looks back. Every hand you've got is spoken for, locked up, or the kind of face that starts wars rather than ends them. The wire goes out with your regrets, and the summit carves the map without a Chicago chair for you at the table.
        option("$MEGAMOD_ATLANTIC_dismiss_none") --$ A thin bench is a dangerous thing.
        return
    end

    lieutenant:addState("SentAway", "timeAway", 5, "dontShowReturnEvent", true)

    -- Half-strength boon: a proxy shakes colder hands
    WorldUtils:scheduleWithDelay("MegaModAtlanticCityReturn", Utils:daysToSecs(5), "TICK",
        "summitBoonScale", 1)

    title("$MEGAMOD_ATLANTIC_send_title") --$ The Proxy
    text({"$MEGAMOD_ATLANTIC_send_text", lieutenant.name}) --$ You put {0} on the eastbound train with a new suit, a letter of introduction, and strict instructions: listen twice, speak once, agree to nothing bigger than dinner. A lieutenant at the table keeps your name in the conversation, but the big men notice who came in person and who sent a proxy -- and they set their offers accordingly. Five days on the Boardwalk. You'll know soon enough what they brought back.
    option("$MEGAMOD_ATLANTIC_dismiss_send") --$ Don't embarrass me out there.
end

function atlanticSnub()
    local playerFaction = WorldUtils:getPlayerFaction()
    atlanticApplyToAllRivals(playerFaction, "THREATENED")

    title("$MEGAMOD_ATLANTIC_snub_title") --$ The Empty Chair
    text("$MEGAMOD_ATLANTIC_snub_text") --$ You drop the cream-colored invitation in the fire. Chicago doesn't take the train to New Jersey to be told its own business by New York men in beach chairs. It feels grand for about a week -- right up until word gets back of what the summit made of your empty chair. The outfits that attended came home with understandings, arrangements, friends in six cities. What they understand about you is that you sat alone when the whole trade sat together. Every boss in town has read the same message into it: the map got carved, and you're the part that's still up for carving.
    option("$MEGAMOD_ATLANTIC_dismiss_snub") --$ Let them come and try.
end

--[[------------------------------------------------------------------------------
    THE RETURN (5 days later): choose your boon
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ATLANTIC_CITY_RETURN"
_event = "MegaModAtlanticCityReturn"
_category = "Misc"

persist{}
summitBoonScale = nil -- Expected Param: 2 = boss attended, 1 = lieutenant

-- Same helper, this block's own instance (script vars/functions are per-_id block)
function atlanticReturnApplyToAllRivals(playerFaction, effectId)
    if not playerFaction or not playerFaction.diplomacy then return end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return end
    for i = 1, #knownGangs do
        local rival = knownGangs[i]
        if rival and rival._active then
            rival.rating:applyEffect(playerFaction, effectId)
        end
    end
end

function canTrigger()
    return summitBoonScale ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_ATLANTIC_return_title") --$ Back from the Boardwalk
    text("$MEGAMOD_ATLANTIC_return_text") --$ The eastbound delegation is home, sunburned and smelling faintly of salt taffy, with a trunk full of understandings. The syndicate's goodwill is real but it isn't unlimited -- the arrangement on the table lets you call in exactly one of the courtesies discussed on the Boardwalk. Choose what Chicago needs most.
    option("$MEGAMOD_ATLANTIC_return_liquor", atlanticBoonAlcohol) --$ The trade pact: a shipment of the good stuff.
    option("$MEGAMOD_ATLANTIC_return_peace", atlanticBoonPeace) --$ The peace terms: goodwill with every outfit.
    option("$MEGAMOD_ATLANTIC_return_cash", atlanticBoonCash) --$ The capital pool: cold syndicate cash.
end

function atlanticBoonAlcohol()
    local playerFaction = WorldUtils:getPlayerFaction()
    local amount = (summitBoonScale == 2) and 60 or 30
    if playerFaction then
        WorldUtils:addAlcoholToFaction(playerFaction, amount, 4)
    end

    title("$MEGAMOD_ATLANTIC_liquor_title") --$ The Real McCoy
    text("$MEGAMOD_ATLANTIC_liquor_text") --$ Two weeks later a produce truck with New Jersey plates backs up to your warehouse in the small hours. Under the cabbage crates: the genuine article, straight off the boats at Rum Row -- bonded Scotch and Canadian rye that has never seen a bathtub in its life. The syndicate moves product the way railroads move coal, and for one shipment, you were on the schedule. Your best joints will pour like it's 1916 again.
    option("$MEGAMOD_ATLANTIC_dismiss_liquor") --$ Now THAT'S the good stuff.
end

function atlanticBoonPeace()
    local playerFaction = WorldUtils:getPlayerFaction()
    local effectId = (summitBoonScale == 2) and "FAVOR_GRANTED" or "FAVOR_GRANTED_HALF"
    atlanticReturnApplyToAllRivals(playerFaction, effectId)

    title("$MEGAMOD_ATLANTIC_peace_title") --$ Less Blood, More Business
    text("$MEGAMOD_ATLANTIC_peace_text") --$ The word goes out along the syndicate's wires, city by city, and it reaches Chicago inside the week: your outfit sat at the table, honored the terms, and is to be treated as a house in good standing. It's remarkable what that does to a town. Bosses who wouldn't take your telephone calls are suddenly sending over bottles with their compliments. Grudges don't vanish -- this is still Chicago -- but they've been marked down considerably. Less blood. More business.
    option("$MEGAMOD_ATLANTIC_dismiss_peace") --$ Handshakes are cheaper than funerals.
end

function atlanticBoonCash()
    local amount = (summitBoonScale == 2) and 2500 or 1250
    BRScript:PlayerAddCash(amount, "CASH.MISSION_REWARD")

    title("$MEGAMOD_ATLANTIC_cash_title") --$ The Capital Pool
    text({"$MEGAMOD_ATLANTIC_cash_text", amount}) --$ Among the Boardwalk understandings was a fund -- every house pays in, and houses in good standing may draw out for "expansion, contingency, and the general health of the trade." The little Jewish fellow from New York who keeps the ledger is said never to have written a number down wrong in his life. Your draw arrives by courier in a false-bottomed suitcase: ${0}, unmarked, no interest, no questions. The only string is the one you already knew about -- someday the trade may ask Chicago for a courtesy in return.
    option("$MEGAMOD_ATLANTIC_dismiss_cash") --$ Money in the bank. So to speak.
end

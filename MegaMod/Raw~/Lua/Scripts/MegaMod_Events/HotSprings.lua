--[[------------------------------------------------------------------------------
    MegaMod: Hot Springs (The Spa Treatment)
    Director event "HOT_SPRINGS". A fixer books crew into Owney Madden's
    sanctuary town -- Hot Springs, Arkansas -- where wanted men take the waters
    untouched. Send the wounded to heal, or send anyone for a morale soak.
    Dialog is built dynamically from the crew's condition (Veterinarian pattern).
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    HOT SPRINGS LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HOTSPRINGS_LISTENER"
_event = "MegaModHotSpringsListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "HOT_SPRINGS" then return end

    -- Needs at least one sendable non-boss crew member and the cheapest fare
    local playerFaction = WorldUtils:getPlayerFaction()
    local sendable = false
    if playerFaction and playerFaction.members then
        for i = 1, #playerFaction.members do
            local member = playerFaction.members[i]
            if member and member ~= playerFaction.boss and not member:isDead()
                    and not member:hasState("SentAway")
                    and not member:hasState("Incarcerated") then
                sendable = true
                break
            end
        end
    end
    if not sendable or not BRScript:PlayerCanAfford(math.floor(250 * (fact.MegaModCfgCost or 1))) then -- MEGAMOD CONFIG: cost knob (paired with the cheapest fare below)
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "HOT_SPRINGS")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModHotSpringsOffer", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "HOT_SPRINGS")
end

--[[------------------------------------------------------------------------------
    HOT SPRINGS OFFER - options assembled from the crew's actual condition
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HOTSPRINGS_OFFER"
_event = "MegaModHotSpringsOffer"
_category = "Misc"

function canTrigger()
    return true
end

-- Injured = hurt or carrying the formal Injury state, and actually sendable
-- (mirrors the Veterinarian's injured scan, minus crew already away or jailed)
function hotSpringsGetInjured()
    local injured = {}
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.members then return injured end
    for i = 1, #playerFaction.members do
        local member = playerFaction.members[i]
        if member and member ~= playerFaction.boss and not member:isDead()
                and not member:hasState("SentAway")
                and not member:hasState("Incarcerated")
                and (member:isDamaged() or member:hasState("Injury")) then
            injured[#injured + 1] = member
        end
    end
    return injured
end

function hotSpringsGetHealthy()
    local healthy = {}
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.members then return healthy end
    for i = 1, #playerFaction.members do
        local member = playerFaction.members[i]
        if member and member ~= playerFaction.boss and not member:isDead()
                and not member:hasState("SentAway")
                and not member:hasState("Incarcerated")
                and not member:hasState("Injury")
                and not member:isDamaged() then
            healthy[#healthy + 1] = member
        end
    end
    return healthy
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_HOTSPRINGS_title") --$ The Spa Treatment
    text("$MEGAMOD_HOTSPRINGS_text") --$ A dapper fixer with a suntan you don't get in Illinois lays a railroad timetable on your desk. "Hot Springs, Arkansas. Owney Madden's town. Bathhouses on Central Avenue, ponies at Oaklawn, and a police chief who couldn't pick Capone out of a two-man lineup. Wanted men golf there under their own names, friend -- it's like the O'Connor setup in St. Paul, only with sulphur water and better weather. I book the tickets, I grease the right palms, your people take the waters and come back new men. No cops, no rivals, no questions. The Springs takes care of its guests."
    -- Only show what's actually possible right now (Veterinarian dynamic-menu pattern)
    local injured = hotSpringsGetInjured()
    if #injured > 0 and BRScript:PlayerCanAfford(400) then
        option("$MEGAMOD_HOTSPRINGS_send_injured", hotSpringsSendInjured) --$ Send the wounded to take the cure ($400 a head, up to 2)
    end
    if #hotSpringsGetHealthy() > 0 and BRScript:PlayerCanAfford(250) then
        option("$MEGAMOD_HOTSPRINGS_soak", hotSpringsMoraleSoak) --$ Treat one of the boys to a soak ($250)
    end
    option("$MEGAMOD_HOTSPRINGS_pass", hotSpringsPass) --$ Chicago's spa enough for us
end

-- Heal exactly as the Veterinarian does: full HP, bring them home from the
-- hospital if they carry the formal Injury state, then clear it
function hotSpringsHealMember(member)
    member.health:reset()
    member.health:processCurrentHealth()
    if member:hasState("Injury") then
        local destinationBuilding = TravelUtils:safeGetNearestSafehouse(member)
        if destinationBuilding then
            local pos, rot = destinationBuilding:getFreeStation(member)
            member:setLocationId(destinationBuilding.interiorLocationId, pos, rot)
        end
        member:removeState("Injury")
    end
end

function hotSpringsSendInjured()
    local playerFaction = WorldUtils:getPlayerFaction()
    local injured = hotSpringsGetInjured()
    if not playerFaction or #injured == 0 then
        WorldUtils:triggerEvent("MegaModHotSpringsResult",
            "resultTitle", "$MEGAMOD_HOTSPRINGS_nobody_title", --$ Nobody to Send
            "resultText", "$MEGAMOD_HOTSPRINGS_nobody_text") --$ By the time the tickets are drawn up, there's nobody left fit to travel who needs the trip. The fixer shrugs and pockets the timetable. "The Springs will still be there, friend."
        return
    end

    -- Up to 2 wounded, clamped by the bankroll ($400 a head)
    local count = math.min(2, #injured, math.floor(playerFaction.cash.count / 400))
    if count < 1 then
        WorldUtils:triggerEvent("MegaModHotSpringsResult",
            "resultTitle", "$MEGAMOD_HOTSPRINGS_broke_title", --$ Fare Comes First
            "resultText", "$MEGAMOD_HOTSPRINGS_broke_text") --$ The fixer counts what you put on the desk and slides it back with two fingers. "Friend, the Springs runs on cash and courtesy, and I'm fresh out of courtesy." No money, no tickets, no cure.
        return
    end

    local cost = count * 400
    BRScript:PlayerSubtractCash(cost, "CASH.GENERIC")
    for i = 1, count do
        hotSpringsHealMember(injured[i])
        -- A week taking the waters (Moonshiners SentAway pattern; the behaviour
        -- guarantees their return and survives save/load)
        injured[i]:addState("SentAway", "timeAway", 7, "dontShowReturnEvent", true)
    end

    WorldUtils:triggerEvent("MegaModHotSpringsSent", "hotSpringsSentCount", count, "hotSpringsSentCost", cost)
end

function hotSpringsMoraleSoak()
    local playerFaction = WorldUtils:getPlayerFaction()
    local healthy = hotSpringsGetHealthy()
    if not playerFaction or #healthy == 0 or playerFaction.cash.count < 250 then
        WorldUtils:triggerEvent("MegaModHotSpringsResult",
            "resultTitle", "$MEGAMOD_HOTSPRINGS_broke_title",
            "resultText", "$MEGAMOD_HOTSPRINGS_broke_text")
        return
    end

    local member = healthy[math.random(#healthy)]
    BRScript:PlayerSubtractCash(250, "CASH.GENERIC")
    member.loyalty:add(15, "$MEGAMOD_HOTSPRINGS_loyalty") --$ A week at the Springs on the boss
    member:addState("SentAway", "timeAway", 5, "dontShowReturnEvent", true)

    WorldUtils:triggerEvent("MegaModHotSpringsSoaked", "hotSpringsSoakChar", member)
end

function hotSpringsPass()
    WorldUtils:triggerEvent("MegaModHotSpringsResult",
        "resultTitle", "$MEGAMOD_HOTSPRINGS_pass_title", --$ No Vacation
        "resultText", "$MEGAMOD_HOTSPRINGS_pass_text") --$ "Some other time. My people work for a living." The fixer folds his timetable away without a hint of offense -- in his business, no is just yes on a delay. "When the lead starts flying, friend, you know where the water's warm." He strolls out whistling something with palm trees in it.
end

--[[------------------------------------------------------------------------------
    HOT SPRINGS RESULT - wounded sent to take the cure
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HOTSPRINGS_SENT_RESULT"
_event = "MegaModHotSpringsSent"
_category = "Misc"

persist{}
hotSpringsSentCount = 0

persist{}
hotSpringsSentCost = 0

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_HOTSPRINGS_sent_title") --$ Taking the Waters
    text({"$MEGAMOD_HOTSPRINGS_sent_text", hotSpringsSentCount, hotSpringsSentCost}) --$ {0} of your wounded board the southbound Pullman with new luggage and names that aren't theirs, ${1} lighter for the fare. A week of sulphur baths, rubdowns, clean sheets, and a croaker who stitches bullet holes without filing paperwork. In Hot Springs nobody looks twice at a man who winces when he laughs -- half the town got shot somewhere more interesting. They'll come home rested, mended, and ready to work.
    option("$MEGAMOD_HOTSPRINGS_dismiss") --$ Don't bet the ponies.
end

--[[------------------------------------------------------------------------------
    HOT SPRINGS RESULT - morale soak
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HOTSPRINGS_SOAK_RESULT"
_event = "MegaModHotSpringsSoaked"
_category = "Misc"

persist{}
hotSpringsSoakChar = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    if hotSpringsSoakChar then
        setCharacterPortrait(hotSpringsSoakChar)
    end
    title("$MEGAMOD_HOTSPRINGS_soak_title") --$ On the House
    text({"$MEGAMOD_HOTSPRINGS_soak_text", hotSpringsSoakChar}) --$ You put {0:name} on the southbound train with pocket money and orders to come back sunburned. Five days of hot water, cold beer, ponies at Oaklawn, and not one solitary soul to shoot at. The crew takes notice: this outfit looks after its own. {0:name} will come home walking taller -- and telling everybody about the bathhouse with the marble floors.
    option("$MEGAMOD_HOTSPRINGS_dismiss")
end

--[[------------------------------------------------------------------------------
    HOT SPRINGS RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_HOTSPRINGS_RESULT"
_event = "MegaModHotSpringsResult"
_category = "Misc"

persist{}
resultTitle = nil

persist{}
resultText = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title(resultTitle)
    text(resultText)
    option("$MEGAMOD_HOTSPRINGS_dismiss")
end

--[[------------------------------------------------------------------------------
    MegaMod: Moonshiners (Tennessee Connection)
    A contact in Tennessee offers moonshine supply, but needs your help
    keeping operations running. Send crew, send money, or risk losing access.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Moonshiner Monitor - director-driven listener
--------------------------------------------------------------------------------]]
-- MEGAMOD DIRECTOR: cadence (weekly 30% roll + own 42-day cooldown) now lives in
-- EventDirector.lua (registry: MOONSHINERS, cooldownDays 21). This block answers
-- director picks: pass when ineligible, launch when eligible.
_id = "MEGAMOD_MOONSHINER_MONITOR"
_event = "MegaModMoonshinerMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: Schedule-mode events are created inactive so GameEvent listeners never register; Create keeps the monitor alive (see HardModeBankroll.lua)
_category = "Misc"

local minFactionMembers = 4 -- also used by the dialog block's sendCrewOption below

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "MOONSHINERS" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "MOONSHINERS")
        return
    end

    -- Need at least 4 faction members
    local members = playerFaction.members
    if not members or #members < minFactionMembers then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "MOONSHINERS")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModMoonshinerEvent", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "MOONSHINERS")
end

--[[------------------------------------------------------------------------------
    Moonshiner Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MOONSHINER_EVENT"
_event = "MegaModMoonshinerEvent"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_MOON_title") --$ Tennessee Moonshiners
    text("$MEGAMOD_MOON_text") --$ A contact down in Tennessee gets word to you: his moonshine operation is under pressure from the local sheriff. He needs help keeping the still running and the law off his back. In return, he'll keep the white lightning flowing north. How do you want to handle it?
    option("$MEGAMOD_MOON_send_crew", sendCrewOption) --$ Send two of your crew (2 weeks)
    option("$MEGAMOD_MOON_send_money", sendMoneyOption) --$ Send money ($800)
    option("$MEGAMOD_MOON_ignore", ignoreOption) --$ Don't send anyone
end

-- MEGAMOD FIX: pages set inside option callbacks never display (the event window doesn't
-- re-render and the event auto-completes on option click), so results are shown as a
-- separate event like vanilla racket events do
function showMoonResult(titleKey, textKey)
    WorldUtils:scheduleWithDelay("MegaModMoonshinerResult", 5, "TICK", "resultTitle", titleKey, "resultText", textKey)
end

function sendCrewOption()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        showMoonResult("$MEGAMOD_MOON_fail_title", "$MEGAMOD_MOON_fail_text") --$ Something Went Wrong / The operation fell through before it even started. Bad timing, bad luck, or both.
        return
    end

    local members = playerFaction.members
    if not members or #members < minFactionMembers then
        showMoonResult("$MEGAMOD_MOON_nocrew_title", "$MEGAMOD_MOON_nocrew_text") --$ Not Enough Crew / You look around the room and realize you can't spare anyone right now. You need every hand you've got just to keep your own operation running.
        return
    end

    -- Find first 2 available non-boss members
    local crewToSend = {}
    for i = 1, #members do
        local member = members[i]
        if member and member ~= playerFaction.boss
                and not member:hasState("SentAway")
                and not member:hasState("Incarcerated") then -- MEGAMOD FIX: don't send crew who are already away or jailed
            crewToSend[#crewToSend + 1] = member
            if #crewToSend >= 2 then
                break
            end
        end
    end

    if #crewToSend < 2 then
        showMoonResult("$MEGAMOD_MOON_nocrew_title", "$MEGAMOD_MOON_nocrew_text") --$ Not Enough Crew
        return
    end

    -- MEGAMOD FIX: crew used to be permanently lost: removeCrewCharacter() took them out of
    -- the faction and the worldTimeCallback that was supposed to bring them back died when
    -- this pooled event completed. Use the vanilla SentAway state instead (see vanilla
    -- Behaviours/SentAway.lua): the crew never leave the faction and the behaviour itself
    -- guarantees their return after timeAway days, persisting across save/load and safely
    -- handling crew that die or leave in the meantime.
    -- 80% moonshine saved, 20% crew delayed
    local delayed = math.random() >= 0.80
    local daysAway = delayed and 21 or 14
    for i = 1, #crewToSend do
        crewToSend[i]:addState("SentAway", "timeAway", daysAway, "dontShowReturnEvent", true)
    end

    if not delayed then
        -- Success: crew returns in 2 weeks with moonshine (delivery event is save-persisted)
        WorldUtils:scheduleWithDelay("MegaModMoonshinerReturn", Utils:daysToSecs(daysAway), "TICK")
        showMoonResult("$MEGAMOD_MOON_crew_sent_title", "$MEGAMOD_MOON_crew_sent_text") --$ Crew Dispatched / Two of your boys pack their bags and head south. They know the score: keep the still running, keep the sheriff looking the other way, and don't drink all the product. They should be back in about two weeks.
    else
        -- Delayed: crew comes back a week late with a fine
        WorldUtils:scheduleWithDelay("MegaModMoonshinerReturnLate", Utils:daysToSecs(daysAway), "TICK")
        showMoonResult("$MEGAMOD_MOON_crew_sent_title", "$MEGAMOD_MOON_crew_delay_text") --$ Crew Dispatched / Two of your boys head south, but you've got a bad feeling about this one. Tennessee law doesn't mess around, and your guys aren't exactly subtle. You'll have to wait and see how it plays out.
    end
end

function sendMoneyOption()
    local cost = math.floor(800 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < cost then
        showMoonResult("$MEGAMOD_MOON_broke_title", "$MEGAMOD_MOON_broke_text") --$ Can't Afford It / You don't have $800 to send south. The moonshiner will have to fend for himself this time.
        return
    end

    BRScript:PlayerSubtractCash(cost, "CASH.MOONSHINE_OPS")

    -- 70% success, 30% fail
    if math.random() < 0.70 then
        local amount = math.random(20, 35)
        WorldUtils:addAlcoholToFaction(playerFaction, amount, 3) -- MEGAMOD FIX: getWorldLibs() is unreachable from the script sandbox
        showMoonResult("$MEGAMOD_MOON_money_win_title", "$MEGAMOD_MOON_money_win_text") --$ Investment Pays Off / Your cash greased the right palms. The sheriff found something else to worry about, the still kept running, and a fresh batch of Tennessee moonshine is on its way to your warehouses. Good business all around.
    else
        showMoonResult("$MEGAMOD_MOON_money_lose_title", "$MEGAMOD_MOON_money_lose_text") --$ Money Down the Drain / The sheriff couldn't be bought, or your contact pocketed the bribe money and ran. Either way, $800 is gone and you've got nothing to show for it. The moonshine supply is going to take a hit.
    end
end

function ignoreOption()
    showMoonResult("$MEGAMOD_MOON_ignore_title", "$MEGAMOD_MOON_ignore_text") --$ Left Them Hanging / You tell the messenger you've got your own problems. The Tennessee operation will have to sort itself out. Word comes back a week later that the sheriff busted the still. Your moonshine pipeline is shut down for now, and the supply coming into the city is going to dry up.
end

--[[------------------------------------------------------------------------------
    Crew Return Notification (Success)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MOONSHINER_RETURN"
_event = "MegaModMoonshinerReturn"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    -- MEGAMOD FIX: the moonshine delivery is granted here; the SentAway behaviour brings
    -- the crew back on its own, and this event (created via the save-persisted delayed
    -- event queue) delivers the reward even across save/load
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction then
        WorldUtils:addAlcoholToFaction(playerFaction, math.random(25, 40), 3)
    end

    setModal(true)
    title("$MEGAMOD_MOON_return_title") --$ Crew's Back From Tennessee
    text("$MEGAMOD_MOON_return_text") --$ Your boys just rolled in from the south, dusty but grinning. They kept the still running, dodged the law, and brought back a healthy supply of moonshine. They're ready to get back to work.
    option("$MEGAMOD_MOON_dismiss") --$ Welcome home.
end

--[[------------------------------------------------------------------------------
    Crew Return Notification (Delayed)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MOONSHINER_RETURN_LATE"
_event = "MegaModMoonshinerReturnLate"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    -- MEGAMOD FIX: fine + reduced delivery granted here (same reasoning as the on-time return)
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction then
        -- Fine for the trouble
        local fine = math.floor(200 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
        if playerFaction.cash.count >= fine then
            BRScript:PlayerSubtractCash(fine, "CASH.MOONSHINE_FINE")
        end

        -- Still get some moonshine, just less
        WorldUtils:addAlcoholToFaction(playerFaction, math.random(10, 20), 2)
    end

    setModal(true)
    title("$MEGAMOD_MOON_return_late_title") --$ Crew Finally Back
    text("$MEGAMOD_MOON_return_late_text") --$ Your boys finally showed up, a week late and looking rough. Turns out the sheriff got too close and they had to lay low in a barn for days. On top of that, they had to pay a $200 fine to a local deputy to get out of the county. They brought back some moonshine, but less than you hoped.
    option("$MEGAMOD_MOON_dismiss") --$ At least they're alive.
end

--[[------------------------------------------------------------------------------
    Moonshiner Result Dialog
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MOONSHINER_RESULT"
_event = "MegaModMoonshinerResult"
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
    option("$MEGAMOD_MOON_dismiss")
end

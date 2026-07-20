--[[------------------------------------------------------------------------------
    MegaMod: Moonshiners (Tennessee Connection)
    A contact in Tennessee offers moonshine supply, but needs your help
    keeping operations running. Send crew, send money, or risk losing access.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    Moonshiner Monitor - Background listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MOONSHINER_MONITOR"
_event = "MegaModMoonshinerMonitor"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 200
_category = "Misc"

persist{}
lastMoonshineTime = 0

persist{}
sentCrew = {}

local moonshineCooldownDays = 42
local moonshineChance = 0.30
local minFactionMembers = 4

function canTrigger()
    return true
end

function onTrigger()
    complete()
end

function GameEvent.onWeekBegin(e)
    -- Cooldown check
    if lastMoonshineTime > 0 and (worldTime - lastMoonshineTime) < Utils:daysToSecs(moonshineCooldownDays) then
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    -- Need at least 4 faction members
    local members = playerFaction.members
    if not members or #members < minFactionMembers then return end

    -- Roll for trigger
    if math.random() >= moonshineChance then return end

    lastMoonshineTime = worldTime
    WorldUtils:scheduleWithDelay("MegaModMoonshinerEvent", 5, "TICK")
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

function sendCrewOption()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        showFailure()
        return
    end

    local members = playerFaction.members
    if not members or #members < minFactionMembers then
        title("$MEGAMOD_MOON_nocrew_title") --$ Not Enough Crew
        text("$MEGAMOD_MOON_nocrew_text") --$ You look around the room and realize you can't spare anyone right now. You need every hand you've got just to keep your own operation running.
        option("$MEGAMOD_MOON_dismiss") --$ We'll figure something else out.
        complete()
        return
    end

    -- Find first 2 non-boss members
    local crewToSend = {}
    for i = 1, #members do
        local member = members[i]
        if member and member ~= playerFaction.boss then
            crewToSend[#crewToSend + 1] = member
            if #crewToSend >= 2 then
                break
            end
        end
    end

    if #crewToSend < 2 then
        title("$MEGAMOD_MOON_nocrew_title") --$ Not Enough Crew
        text("$MEGAMOD_MOON_nocrew_text") --$ You look around the room and realize you can't spare anyone right now. You need every hand you've got just to keep your own operation running.
        option("$MEGAMOD_MOON_dismiss") --$ We'll figure something else out.
        complete()
        return
    end

    -- Store crew references and remove them from faction
    sentCrew = {}
    for i = 1, #crewToSend do
        sentCrew[#sentCrew + 1] = crewToSend[i]
        playerFaction:removeCrewCharacter(crewToSend[i], true, "Fired")
    end

    -- 80% moonshine saved, 20% crew delayed
    if math.random() < 0.80 then
        -- Success: crew returns in 2 weeks with moonshine
        title("$MEGAMOD_MOON_crew_sent_title") --$ Crew Dispatched
        text("$MEGAMOD_MOON_crew_sent_text") --$ Two of your boys pack their bags and head south. They know the score: keep the still running, keep the sheriff looking the other way, and don't drink all the product. They should be back in about two weeks.
        option("$MEGAMOD_MOON_dismiss") --$ Bring me back something good.
        worldTimeCallback(returnCrew, Utils:daysToSecs(14))
    else
        -- Delayed: crew comes back a week late with a fine
        title("$MEGAMOD_MOON_crew_sent_title") --$ Crew Dispatched
        text("$MEGAMOD_MOON_crew_delay_text") --$ Two of your boys head south, but you've got a bad feeling about this one. Tennessee law doesn't mess around, and your guys aren't exactly subtle. You'll have to wait and see how it plays out.
        option("$MEGAMOD_MOON_dismiss") --$ Hope they don't get pinched.
        worldTimeCallback(returnCrewDelayed, Utils:daysToSecs(21))
    end
    complete()
end

function returnCrew()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        sentCrew = {}
        return
    end

    -- Add crew back to faction
    for i = 1, #sentCrew do
        if sentCrew[i] then
            playerFaction:addCrewCharacter(sentCrew[i])
        end
    end
    sentCrew = {}

    -- Reward: moonshine delivery
    local amount = math.random(25, 40)
    getWorldLibs().addAlcoholToFaction(playerFaction, amount, 3)

    -- Schedule a notification dialog
    WorldUtils:scheduleWithDelay("MegaModMoonshinerReturn", 5, "TICK")
end

function returnCrewDelayed()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then
        sentCrew = {}
        return
    end

    -- Add crew back to faction
    for i = 1, #sentCrew do
        if sentCrew[i] then
            playerFaction:addCrewCharacter(sentCrew[i])
        end
    end
    sentCrew = {}

    -- Fine for the trouble
    if playerFaction.cash.count >= 200 then
        BRScript:PlayerSubtractCash(200, "CASH.MOONSHINE_FINE")
    end

    -- Still get some moonshine, just less
    local amount = math.random(10, 20)
    getWorldLibs().addAlcoholToFaction(playerFaction, amount, 2)

    -- Schedule a notification dialog
    WorldUtils:scheduleWithDelay("MegaModMoonshinerReturnLate", 5, "TICK")
end

function sendMoneyOption()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 800 then
        title("$MEGAMOD_MOON_broke_title") --$ Can't Afford It
        text("$MEGAMOD_MOON_broke_text") --$ You don't have $800 to send south. The moonshiner will have to fend for himself this time.
        option("$MEGAMOD_MOON_dismiss") --$ Maybe next time.
        complete()
        return
    end

    BRScript:PlayerSubtractCash(800, "CASH.MOONSHINE_OPS")

    -- 70% success, 30% fail
    if math.random() < 0.70 then
        local amount = math.random(20, 35)
        getWorldLibs().addAlcoholToFaction(playerFaction, amount, 3)
        title("$MEGAMOD_MOON_money_win_title") --$ Investment Pays Off
        text("$MEGAMOD_MOON_money_win_text") --$ Your cash greased the right palms. The sheriff found something else to worry about, the still kept running, and a fresh batch of Tennessee moonshine is on its way to your warehouses. Good business all around.
        option("$MEGAMOD_MOON_dismiss") --$ Money well spent.
    else
        title("$MEGAMOD_MOON_money_lose_title") --$ Money Down the Drain
        text("$MEGAMOD_MOON_money_lose_text") --$ The sheriff couldn't be bought, or your contact pocketed the bribe money and ran. Either way, $800 is gone and you've got nothing to show for it. The moonshine supply is going to take a hit.
        option("$MEGAMOD_MOON_dismiss") --$ Should've sent my boys.
    end
    complete()
end

function ignoreOption()
    title("$MEGAMOD_MOON_ignore_title") --$ Left Them Hanging
    text("$MEGAMOD_MOON_ignore_text") --$ You tell the messenger you've got your own problems. The Tennessee operation will have to sort itself out. Word comes back a week later that the sheriff busted the still. Your moonshine pipeline is shut down for now, and the supply coming into the city is going to dry up.
    option("$MEGAMOD_MOON_dismiss") --$ We'll manage.
    complete()
end

function showFailure()
    title("$MEGAMOD_MOON_fail_title") --$ Something Went Wrong
    text("$MEGAMOD_MOON_fail_text") --$ The operation fell through before it even started. Bad timing, bad luck, or both.
    option("$MEGAMOD_MOON_dismiss") --$ Move on.
    complete()
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
    setModal(true)
    title("$MEGAMOD_MOON_return_title") --$ Crew's Back From Tennessee
    text("$MEGAMOD_MOON_return_text") --$ Your boys just rolled in from the south, dusty but grinning. They kept the still running, dodged the law, and brought back a healthy supply of moonshine. They're ready to get back to work.
    option("$MEGAMOD_MOON_dismiss") --$ Welcome home.
    complete()
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
    setModal(true)
    title("$MEGAMOD_MOON_return_late_title") --$ Crew Finally Back
    text("$MEGAMOD_MOON_return_late_text") --$ Your boys finally showed up, a week late and looking rough. Turns out the sheriff got too close and they had to lay low in a barn for days. On top of that, they had to pay a $200 fine to a local deputy to get out of the county. They brought back some moonshine, but less than you hoped.
    option("$MEGAMOD_MOON_dismiss") --$ At least they're alive.
    complete()
end

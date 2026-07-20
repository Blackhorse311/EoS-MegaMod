--[[------------------------------------------------------------------------------
    MegaMod: Contract on You (EventDirector: MURDER_INC)
    The Brownsville troop out of Brooklyn -- the papers will get around to
    calling them Murder, Incorporated -- kill strictly on assignment and
    strictly for cash, as enforcement for the national Syndicate. No
    freelancing, no passion, no witnesses. An informant says a rival outfit
    has bought a contract on one of your people. The boys from Brooklyn are
    already on a train.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). If the hit
    squad is allowed to come, this file's permanent listener also acts as the
    monitor: it watches the squad via MissionUtils:isSquadDead on onDayBegin
    and pays out the bounty when the player wipes it (their $1,000 expense
    money) plus an AMBUSHED rating hit on the rival who hired them.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER + HIT-SQUAD MONITOR (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MURDER_INC_LISTENER"
_event = "MegaModMurderIncListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
murderIncHitSquadRef = nil -- live hit squad being watched (vanilla missions persist squads the same way)

persist{}
murderIncHiredRivalId = nil -- factionId of the rival who bought the contract

function GameEvent.onMegaModEventPick(e)
    if e.eventName ~= "MURDER_INC" then return end

    -- One contract at a time
    if murderIncHitSquadRef then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "MURDER_INC")
        return
    end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction:getPrimarySafehouse() then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "MURDER_INC")
        return
    end

    -- Need a rival to buy the contract...
    local activeRivals = {}
    local knownGangs = playerFaction.diplomacy and playerFaction.diplomacy:getKnownGangs()
    if knownGangs then
        for i = 1, #knownGangs do
            if knownGangs[i]._active then
                activeRivals[#activeRivals + 1] = knownGangs[i]
            end
        end
    end
    if #activeRivals == 0 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "MURDER_INC")
        return
    end

    -- ...and somebody worth taking a contract out on
    local hasCrew = false
    local members = playerFaction.members
    if members then
        for i = 1, #members do
            local member = members[i]
            if member and member ~= playerFaction.boss
                    and not member:hasState("SentAway")
                    and not member:hasState("Incarcerated") then
                hasCrew = true
                break
            end
        end
    end
    if not hasCrew then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "MURDER_INC")
        return
    end

    local rival = activeRivals[math.random(1, #activeRivals)]
    WorldUtils:scheduleWithDelay("MegaModMurderIncWarning", 5, "TICK",
        "murderIncRivalFactionId", rival.factionId,
        "murderIncRivalName", rival.name)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "MURDER_INC")
end

-- Dialog callbacks report the spawned squad back here (AldermanSystem pattern:
-- dialog blocks can't touch this block's vars, so state rides a custom game event)
function GameEvent.onMegaModMurderIncHit(e)
    murderIncHitSquadRef = e.squad
    murderIncHiredRivalId = e.rivalFactionId
end

function GameEvent.onDayBegin(e)
    if not murderIncHitSquadRef then return end

    if MissionUtils:isSquadDead(murderIncHitSquadRef) then
        local playerFaction = WorldUtils:getPlayerFaction()

        -- Their expense money, your pockets
        BRScript:PlayerAddCash(1000, "CASH.MISSION_REWARD")

        -- The rival who bought the contract knows exactly who buried it
        if murderIncHiredRivalId and playerFaction then
            local rival = WorldUtils:getFactionByFactionId(murderIncHiredRivalId)
            if rival and rival._active then
                rival.rating:applyEffect(playerFaction, "AMBUSHED")
            end
        end

        murderIncHitSquadRef:removeFromSquads()
        murderIncHitSquadRef = nil
        murderIncHiredRivalId = nil

        WorldUtils:scheduleWithDelay("MegaModMurderIncAftermath", 5, "TICK")
    end
end

--[[------------------------------------------------------------------------------
    THE TIP-OFF
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MURDER_INC_WARNING"
_event = "MegaModMurderIncWarning"
_category = "Misc"

persist{}
murderIncRivalFactionId = nil -- Expected Param

persist{}
murderIncRivalName = nil -- Expected Param

-- Spawn the Brooklyn boys outside the primary safehouse and hand them to the
-- monitor block. FACTION.THUGS (spawnSquad default) -- a fight, not a faction war.
function murderIncSpawnHitSquad(rivalFactionId)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end

    local hitSquad = MissionUtils:spawnSquad(6)
    if hitSquad then
        -- Building.locationId is the exterior street location the building sits in
        MissionUtils:placeSquad(hitSquad, safehouse.locationId, safehouse:getPos())
        Utils:raiseGameEvent("onMegaModMurderIncHit",
            "squad", hitSquad,
            "rivalFactionId", rivalFactionId)
    end
end

function canTrigger()
    return murderIncRivalFactionId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_MURDERINC_warn_title") --$ Contract on You
    text({"$MEGAMOD_MURDERINC_warn_text", murderIncRivalName}) --$ Your informant won't sit down and won't take his hat off. "The troop from Brownsville. The Brooklyn boys. They don't kill for grudges, they kill for invoices -- and somebody just paid one with a name from YOUR outfit on it." He glances at the door. "Word is {0} put up the money and the Syndicate cleared the job. Once the boys from Brooklyn take a contract, it doesn't get cancelled cheap. It gets outbid, it gets dodged, or it gets carried out. That's the whole menu." He's gone before you can ask how he knows. They always are.
    option("$MEGAMOD_MURDERINC_warn_pay", murderIncPayOff) --$ Outbid it. Pay the Syndicate $1,500.
    option("$MEGAMOD_MURDERINC_warn_hide", murderIncHideTarget) --$ Get the target out of town, quiet.
    option("$MEGAMOD_MURDERINC_warn_fight", murderIncLetThemCome) --$ Let them come. We'll be waiting.
end

function murderIncPayOff()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.cash or playerFaction.cash.count < 1500 then
        -- The Syndicate doesn't do layaway: the contract proceeds
        murderIncSpawnHitSquad(murderIncRivalFactionId)

        title("$MEGAMOD_MURDERINC_pay_broke_title") --$ Short of the Asking Price
        text("$MEGAMOD_MURDERINC_pay_broke_text") --$ You get word to the right ears in Brooklyn: you'll top whatever was paid. The answer comes back the same night, polite as a bank letter -- the price to void a cleared contract is fifteen hundred, cash, in advance, and the Syndicate does not extend credit on this particular service. You can't cover it. Which means the boys are still coming, and the only arrangement left to make is the reception. Word from the street says they're already outside your safehouse.
        option("$MEGAMOD_MURDERINC_dismiss_broke") --$ Get everybody heeled. Now.
        return
    end

    BRScript:PlayerSubtractCash(1500, "CASH.EXPENSES")

    title("$MEGAMOD_MURDERINC_pay_title") --$ Business Is Business
    text("$MEGAMOD_MURDERINC_pay_text") --$ Fifteen hundred travels east in a cigar box, and the answer comes back in a two-word telegram: CONTRACT CLOSED. That's the thing about the Brooklyn troop -- no hard feelings, no loyalty, no memory. They're not killers who take money, they're money men who kill, and today the money said don't. Somewhere across town, a rival boss learns his purchase was cancelled and his deposit is not refundable. The Syndicate keeps both fees, of course. Business is business.
    option("$MEGAMOD_MURDERINC_dismiss_pay") --$ Cheaper than a funeral.
end

function murderIncHideTarget()
    local playerFaction = WorldUtils:getPlayerFaction()
    local target = nil
    local members = playerFaction and playerFaction.members
    if members then
        for i = 1, #members do
            local member = members[i]
            if member and member ~= playerFaction.boss
                    and not member:hasState("SentAway")
                    and not member:hasState("Incarcerated") then
                target = member
                break
            end
        end
    end

    if not target then
        -- Nobody can slip away: the contract proceeds
        murderIncSpawnHitSquad(murderIncRivalFactionId)

        title("$MEGAMOD_MURDERINC_hide_none_title") --$ Nowhere to Run
        text("$MEGAMOD_MURDERINC_hide_none_text") --$ You start making arrangements -- a farmhouse downstate, a cousin in Milwaukee, a berth on a freighter -- and discover there's nobody free to send. Every hand you've got is committed, locked up, or already gone. The lying-low plan dies on the table, and the boys from Brooklyn don't wait on your scheduling problems. Street word says they've taken up positions outside your safehouse.
        option("$MEGAMOD_MURDERINC_dismiss_none") --$ Then we do this the loud way.
    else
        target:addState("SentAway", "timeAway", 10, "dontShowReturnEvent", true)

        title("$MEGAMOD_MURDERINC_hide_title") --$ Lying Low
        text({"$MEGAMOD_MURDERINC_hide_text", target.name}) --$ That night, {0} leaves town in the back of a produce truck with a suitcase, a new hat, and instructions to be somebody boring for a while. Ten days on a farm downstate -- no telephone calls, no card games, no visits to anywhere with a liquor license. The Brooklyn boys are professionals: they don't hunt, they appear where the target is supposed to be. When the target is nowhere, the contract goes cold, the invoice gets marked unserviceable, and the troop goes home to Brownsville. Nothing personal. It never is, with them.
        option("$MEGAMOD_MURDERINC_dismiss_hide") --$ Enjoy the fresh air, kid.
    end
end

function murderIncLetThemCome()
    murderIncSpawnHitSquad(murderIncRivalFactionId)

    title("$MEGAMOD_MURDERINC_fight_title") --$ The Reception Committee
    text("$MEGAMOD_MURDERINC_fight_text") --$ "Let them come," you say, and start moving furniture. Shotguns behind the bar, a man in the upstairs window, the lights arranged so the doorway glows like a stage. The Brooklyn troop is good -- nobody says otherwise -- but they're used to targets who don't know they're targets. Yours know. Street word says the out-of-town talent has already set up outside your safehouse: nice coats, patient faces, a sedan with the engine warm. They're carrying their expense money with them, the way traveling men do. Wipe them out and it's yours -- along with a message to the man who hired them.
    option("$MEGAMOD_MURDERINC_dismiss_fight") --$ Nobody hunts my people.
end

--[[------------------------------------------------------------------------------
    THE AFTERMATH (hit squad wiped -- paid out by the monitor block)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MURDER_INC_AFTERMATH"
_event = "MegaModMurderIncAftermath"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_MURDERINC_after_title") --$ Return to Sender
    text("$MEGAMOD_MURDERINC_after_text") --$ It's over by suppertime. The patient faces weren't patient enough, and the sedan with the warm engine is now a sedan with several new ventilation features. Going through their coats, your boys find rail tickets, clean shirts, and an envelope of Syndicate expense money -- $1,000, which you consider fair compensation for the inconvenience. The bodies go where bodies go. By morning, the boss who bought the contract knows it came back marked RETURN TO SENDER, and he knows you know whose signature was on the order. Let him sweat about what that costs.
    option("$MEGAMOD_MURDERINC_dismiss_after") --$ Send Brooklyn the laundry bill.
end

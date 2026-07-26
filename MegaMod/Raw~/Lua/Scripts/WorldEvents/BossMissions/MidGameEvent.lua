_namespace = "WORLD_EVENTS"
--[[------------------------------------------------------------------------------
MID GAME EVENT - ELECTION
MEGAMOD OVERRIDE: vanilla copy + fixes.
- VANILLA BUG: the engine deletes a worldTimeCallback whose function returns
  falsy (Game.lua callback loop). HELP_DEMOCRATS/HELP_REPUBLICANS
  checkPlacements returned nothing when mission placements weren't available
  that day, so ONE bad daily check silently killed the whole election chain --
  the player donated but the follow-up missions never appeared. Both checkers
  now return true to keep retrying daily.
- MEGAMOD_ELECTION_REPAIR: one-shot rescue for saves where the chain already
  died -- detects the donation via the $ChicagoStylePolitics earnings modifier
  (casinos = Democrats, bars = Republicans; save-persisted) and re-creates the
  party event. Skipped when the chain ran under the fixed code
  (fact.MegaModElectionChainAlive) or already concluded (fact.MegaModElectionDone).
--------------------------------------------------------------------------------]]
_id = "MID_GAME_EVENT"
_event = "MidGameEvent"
_gameStage = "Early"
_autoStartMode = "Create"
_category = "MidGameEvent"

persist{}
year = 1920

persist{}
month = 8

derelictPlacement = nil
function onCreate()
    worldTimeCallback(checkYear, Utils:monthsToSecs(1))
end

function checkYear()
    --If not passed August 1920
    if ((WorldUtils:getGameYear() == year) and (WorldUtils:getGameMonth() < month)) then
        return true
    end

    if canTrigger() then
        trigger()
        return false
    end

    return Utils:daysToSecs(1)
end

function canTrigger()
    if not BRScript:PlayerCanAfford(5000) then
        return false
    end

    return true
end

function onTrigger()
    local cash = 5000
    local moreCash = 9000
    --"$MidGameEvent_MoneyToDemSmallReward" --$ Casino earnings are increased by 10%
    --"$MidGameEvent_MoneyToDemBigReward" --$ Casino earnings are increased by 20%
    --"$MidGameEvent_MoneyToRepSmallReward" --$ Speakeasy earnings are increased by 10%
    --"$MidGameEvent_MoneyToRepBigReward" --$ Speakeasy earnings are increased by 20%
    title("$ChicagoStylePolitics") --$ Chicago Style Politics
    text({"$MidGameElection_text"}) --$ The Gubernatorial elections are taking place in November this year, and you have a chance to sway the city's vote. The Democrats could help your rackets, but the Republicans have the police in their pocket... How much do you want to invest in this election?
    option({"$MidGameElection_ResponseA", cash}, {StartDemocrats, 0.1, cash}, nil, "$MidGameEvent_MoneyToDemSmallReward") --$ {0:C0} to the Democrats.
    option({"$MidGameElection_ResponseB", cash}, {StartRepublicans, 0.1, cash}, nil, "$MidGameEvent_MoneyToRepSmallReward") --$ {0:C0} to the Republicans.
    if BRScript:PlayerCanAfford(moreCash) then
        option({"$MidGameElection_ResponseC", moreCash}, {StartDemocrats, 0.2, moreCash}, nil, "$MidGameEvent_MoneyToDemBigReward") --$ {0:C0} to the Democrats.
        option({"$MidGameElection_ResponseD", moreCash}, {StartRepublicans, 0.2, moreCash}, nil, "$MidGameEvent_MoneyToRepBigReward") --$ {0:C0} to the Republicans.
    end
    option("$MidGameElection_ResponseE") --$ Nothing. I'd rather invest in myself.
end

function StartDemocrats(modifier, cash)
    BRScript:PlayerSubtractCash(cash, "CASH.BRIBE")
    local rackets = MissionUtils:controlledRackets("CASINO")
    for i = 1, #rackets do
        rackets[i].data:setModifier("earnings", "$ChicagoStylePolitics", modifier)
    end
    WorldUtils:createEvent("HelpDemocrats")
end

function StartRepublicans(modifier, cash)
    BRScript:PlayerSubtractCash(cash, "CASH.BRIBE")
    local rackets = MissionUtils:controlledRackets("BAR")
    for i = 1, #rackets do
        rackets[i].data:setModifier("earnings", "$ChicagoStylePolitics", modifier)
    end
    WorldUtils:createEvent("HelpRepublicans")
end

--[[------------------------------------------------------------------------------
HELP DEMOCRATS - ELECTION
--------------------------------------------------------------------------------]]
_id = "HELP_DEMOCRATS"
_event = "HelpDemocrats"

derelictPlacement = nil
brothelPlacement = nil
strangerPlacement = nil
womanPlacement = nil
function onCreate()
    -- MEGAMOD: marks a chain running under the fixed retry code so the repair
    -- event knows it doesn't need to intervene in this campaign
    fact.MegaModElectionChainAlive = true
    worldTimeCallback(checkPlacements, Utils:daysToSecs(1))
end

function checkPlacements()
    if canTrigger() then
        trigger()
        return false
    end
    -- MEGAMOD FIX: returning nil here deleted the callback after a single day
    -- without valid placements, killing the chain forever. Keep retrying daily.
    return true
end

function canTrigger()
    derelictPlacement = WorldUtils:acquirePlacement(
        MissionUtils:derelictRacketInPlayerOrThugPrecinct()
    )
    if not derelictPlacement then
        return false
    end

    strangerPlacement = WorldUtils:acquirePlacement(
        MissionUtils:genericMissionPlacementRules()
    )
    if not strangerPlacement then
        derelictPlacement:release()
        return false
    end

    womanPlacement = WorldUtils:acquirePlacement(
        MissionUtils:genericMissionPlacementRules()
    )
    if not womanPlacement then
        derelictPlacement:release()
        strangerPlacement:release()
        return false
    end

    brothelPlacement = WorldUtils:acquirePlacement({
        factionIds = MissionUtils:getKnownActiveFactionIds(),
        racketType = "Brothel",
        featureType = "MissionArea",
    })
    return true
end

function onTrigger()
    --"$MidGameEvent_HelpDemocratsAReward" --$ Brothel earnings are increased by 10%
    --"$MidGameEvent_HelpDemocratsBReward" --$ Speakeasy earnings are increased by 10%
    local roll = Utils:roll(100)
    title("$ChicagoStylePolitics")
    if roll < 50 and brothelPlacement then
        text("$HelpDemocratsB_text") --$ Since you're helping out the Democrats, they have two small tasks for you. If you complete them, your relationship and all that comes with it will improve.
        option("$HelpDemocratsB_ResponseA", startMissionB, nil, "$MidGameEvent_HelpDemocratsBReward") --$ I'll look into it.
        option("$HelpDemocratsB_ResponseB") --$ I don't want to bother.
    else
        if brothelPlacement then
            brothelPlacement:release()
        end
        text("$HelpDemocratsA_text") --$ Since you're helping out the Democrats, they have two small tasks for you. If you complete them, together you can do a lot of good for the city. And yourself.
        option("$HelpDemocratsA_ResponseA", startMissionA, nil, "$MidGameEvent_HelpDemocratsAReward") --$ Let's see what they want at least.
        option("$HelpDemocratsA_ResponseB") --$ Get someone else. They're meant to serve me, not the other way around.
    end
end

function startMissionA()
    local rackets = MissionUtils:controlledRackets("BAR")
    for i = 1, #rackets do
        rackets[i].data:setModifier("earnings", "$ChicagoStylePolitics", 0.1)
    end
    WorldUtils:startMission("HelpDemocratsA", "derelictPlacement", derelictPlacement, "strangerPlacement", strangerPlacement, "womanPlacement", womanPlacement)
end

function startMissionB()
    local rackets = MissionUtils:controlledRackets("BROTHEL")
    for i = 1, #rackets do
        rackets[i].data:setModifier("earnings", "$ChicagoStylePolitics", 0.1)
    end
    WorldUtils:startMission("HelpDemocratsB", "derelictPlacement", derelictPlacement, "brothelPlacement", brothelPlacement, "strangerPlacement", strangerPlacement, "womanPlacement", womanPlacement)
end

--[[------------------------------------------------------------------------------
HELP REPUBLICANS - ELECTION
--------------------------------------------------------------------------------]]
_id = "HELP_REPUBLICANS"
_event = "HelpRepublicans"

witnessPlacement = nil
brothelPlacement = nil
casinoPlacement = nil
strangerPlacement = nil
businessPersonPlacement = nil
function onCreate()
    -- MEGAMOD: see HELP_DEMOCRATS
    fact.MegaModElectionChainAlive = true
    worldTimeCallback(checkPlacements, Utils:daysToSecs(1))
end

function checkPlacements()
    if canTrigger() then
        trigger()
        return false
    end
    -- MEGAMOD FIX: returning nil here deleted the callback after a single day
    -- without valid placements, killing the chain forever. Keep retrying daily.
    return true
end

function canTrigger()
    witnessPlacement = WorldUtils:acquirePlacement(
        MissionUtils:genericMissionPlacementRules()
    )
    if not witnessPlacement then
        return false
    end

    strangerPlacement = WorldUtils:acquirePlacement(
        MissionUtils:genericMissionPlacementRules()
    )
    if not strangerPlacement then
        witnessPlacement:release()
        return false
    end

    businessPersonPlacement = WorldUtils:acquirePlacement(
        MissionUtils:genericMissionPlacementRules()
    )
    if not businessPersonPlacement then
        witnessPlacement:release()
        strangerPlacement:release()
        return false
    end

    brothelPlacement = WorldUtils:acquirePlacement({
            factionIds = MissionUtils:getKnownActiveFactionIds(),
            racketType = "Brothel",
            featureType = "MissionArea",
        })

    return true
end

function onTrigger()
    --"$MidGameEvent_HelpRepublicanAReward" --$ Security upgrade to casinos
    --"$MidGameEvent_HelpRepublicanBReward" --$ Games upgrades to casinos
    local roll = Utils:roll(100)
    title("$ChicagoStylePolitics")
    if (roll < 50 and brothelPlacement) then
        text("$HelpRepublicanA_text") --$ Since you're helping out the Republicans, they have two small tasks for you. If you complete them, your relationship with the party and all that comes with it will improve.
        option("$HelpRepublicanA_ResponseA", startMissionA, nil, "$MidGameEvent_HelpRepublicanAReward") --$ I'll look into it.
        option("$HelpRepublicanA_ResponseB") --$ I don't want to bother.
    else
        if brothelPlacement then
            brothelPlacement:release()
        end
        text("$HelpRepublicanB_text") --$ Since you're helping out the Republicans, they have two small tasks for you. If you complete them, together you can do a lot of good for the city. And yourself.
        option("$HelpRepublicanB_ResponseA", startMissionB, nil, "$MidGameEvent_HelpRepublicanBReward") --$ Let's see what they want at least.
        option("$HelpRepublicanB_ResponseB") --$ Get someone else. They're meant to serve me, not the other way around.
    end
end

function startMissionA()
    local buildings = MissionUtils:controlledRackets("CASINO")
    for i = 1, #buildings do
        local upgrades = buildings[i].upgrades:getUpgradeOfType("security")
        upgrades:upgrade(1)
    end
    WorldUtils:startMission("HelpRepublicansA", "brothelPlacement", brothelPlacement, "strangerPlacement", strangerPlacement, "businessPersonPlacement", businessPersonPlacement, "witnessPlacement", witnessPlacement)
end

function startMissionB()
    local buildings = MissionUtils:controlledRackets("CASINO")
    for i = 1, #buildings do
        local upgrades = buildings[i].upgrades:getUpgradeOfType("game")
        upgrades:upgrade(1)
    end
    WorldUtils:startMission("HelpRepublicansB", "strangerPlacement", strangerPlacement, "businessPersonPlacement", businessPersonPlacement, "witnessPlacement", witnessPlacement)
end

--[[------------------------------------------------------------------------------
MID GAME EVENT A END
--------------------------------------------------------------------------------]]
_id = "MID_GAME_EVENT_A_END"
_event = "MidGameEventAEnd"


helpedDemocrats = nil
didTask1 = false
didTask2 = false
function onTrigger()
    fact.MegaModElectionDone = true -- MEGAMOD: chain concluded; repair must never re-run it
    didTask1 = not fact.ChicagoPolitics_RejectedTask1
    didTask2 = not fact.ChicagoPolitics_RejectedTask2

    local outcomeOption
    local outcomeResponse1
    local outcomeReward
    -----------------------------------
    --- Helped neither
    -----------------------------------
    if not didTask1 and not didTask2 then
        outcomeOption = "$MidGameEventAEndHelpedNeither_text" --$ Your party barely scraped by, but managed a few wins here and there. You'll need to try harder next time around if you want them to win the next election.
        outcomeResponse1 = "$MidGameEventAEndHelpedNeither_response" --$ Fine.

    -----------------------------------
    --- Helped 1 of 2
    -----------------------------------
    elseif (didTask1 and not didTask2) or (not didTask1 and didTask2) then
        outcomeOption = "$MidGameEventAEndHelpedOne_text" --$ You didn't get all of your seats filled, but you made huge waves on the political scene. Your party thanks you for your help.
        outcomeResponse1 = "$MidGameEventAEndHelpedBoth_option" --$ Happy to help.
        outcomeReward = "$MidGameEventAEndHelpedOne_Reward" --$ +1 Leadership, Deflection upgrade to brothels and casinos

    -----------------------------------
    --- Helped both
    -----------------------------------
    else
        outcomeOption = "$MidGameEventAEndHelpedBoth_text" --$ Your help with the party has really made waves. And when the election rolled around, all of your candidates won! They're grateful for the help, and they want you to know it.
        outcomeResponse1 = "$MidGameEventAEndHelpedBoth_option"
        outcomeReward = "$MidGameEventAEndHelpedBoth_Reward" --$ +1 Leadership, +1 Persuasion, +1 Intimidation and Deflection upgrade to all rackets

    end

    title("$ChicagoStylePolitics")
    text(outcomeOption)
    option(outcomeResponse1, rewards, nil, outcomeReward)
end

function rewards()
    -- --------------------------------
    -- Helped 1 of 2
    -- --------------------------------
    if (didTask1 and not didTask2) or (not didTask1 and didTask2) then
        BRScript:AddSkillPoints("leadership", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Leadership", 1)
        local upgradeType = "deflect"
        local rackets = MissionUtils:controlledRackets("BROTHEL")
        for i = 1, #rackets do
            local upgrade = rackets[i].upgrades:getUpgradeOfType(upgradeType)
            upgrade:upgrade(1)
        end
        rackets = MissionUtils:controlledRackets("CASINO")
        for i = 1, #rackets do
            local upgrade = rackets[i].upgrades:getUpgradeOfType(upgradeType)
            upgrade:upgrade(1)
        end
    -- --------------------------------
    -- Helped both
    -- --------------------------------
    elseif didTask1 and didTask2 then
        BRScript:AddSkillPoints("leadership", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Leadership", 1)
        BRScript:AddSkillPoints("persuasion", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Persuasion", 1)
        BRScript:AddSkillPoints("intimidation", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Intimidation", 1)
        local upgradeType = "deflect"
        local rackets = MissionUtils:controlledRackets()
        for i = 1, #rackets do
            local upgrade = rackets[i].upgrades:getUpgradeOfType(upgradeType)
            if upgrade then
                upgrade:upgrade(1)
            end
        end
    end
end

--[[------------------------------------------------------------------------------
MID GAME EVENT B END
--------------------------------------------------------------------------------]]
_id = "MID_GAME_EVENT_B_END"
_event = "MidGameEventBEnd"

didTask1 = false
didTask2 = false
missionId = nil
function onTrigger()
    fact.MegaModElectionDone = true -- MEGAMOD: chain concluded; repair must never re-run it
    didTask1 = not fact.ChicagoPolitics_RejectedTask1
    didTask2 = not fact.ChicagoPolitics_RejectedTask2

    local outcomeOption
    local outcomeResponse1
    local outcomeReward
    -----------------------------------
    --- Helped neither
    -----------------------------------
    if not didTask1 and not didTask2 then
        outcomeOption = "$MidGameEventBEndHelpedNeitherB_text" --$ We've had worse years... but I don't know when. Try doing something next time and you might benefit yourself.
        outcomeResponse1 = "$MidGameEventBEndHelpedNeither_response" --$ Benefit yourself by shutting your mouth.

    -----------------------------------
    --- Helped 1 of 2
    -----------------------------------
    elseif (didTask1 and not didTask2) or (not didTask1 and didTask2) then
        outcomeOption = "$MidGameEventBEndHelpedOne_text" --$ Your candidate didn't win, but the party did well. But don't you think you could have done a little more?
        outcomeResponse1 = "$MidGameEventBEndHelpedOne_response" --$ I'm satisfied.
        outcomeReward = "$MidGameEventBEndHelpedOne_Reward" --$ +1 Leadership, Security or Deflection upgrade to brothels and casinos

    -----------------------------------
    --- Helped both
    -----------------------------------
    else
        outcomeOption = "$MidGameEventBEndHelpedBoth_text" --$ Your candidate won. The system works for you when you work with it. And you reap the benefits.
        outcomeResponse1 = "$MidGameEventBEndHelpedBoth_option" --$ We are mighty when we work together.
        outcomeReward = "$MidGameEventBEndHelpedBoth_Reward" --$ +1 Leadership, +1 Persuasion, +1 Intimidation and Security or Deflection upgrade to all rackets
    end

    title("$ChicagoStylePolitics")
    text(outcomeOption)
    option(outcomeResponse1, rewards, nil, outcomeReward)
end

function rewards()
    -- --------------------------------
    -- Helped 1 of 2
    -- --------------------------------
    if (didTask1 and not didTask2) or (not didTask1 and didTask2) then
        BRScript:AddSkillPoints("leadership", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Leadership", 1)
        local rackets = MissionUtils:controlledRackets("BROTHEL")
        local upgradeType = "deflect"
        for i = 1, #rackets do
            local upgrade = rackets[i].upgrades:getUpgradeOfType(upgradeType)
            upgrade:upgrade(1)
        end
        rackets = MissionUtils:controlledRackets("CASINO")
        for i = 1, #rackets do
            local upgrade = rackets[i].upgrades:getUpgradeOfType(upgradeType)
            upgrade:upgrade(1)
        end

    -- --------------------------------
    -- Helped both
    -- --------------------------------
    elseif didTask1 and didTask2 then
        BRScript:AddSkillPoints("leadership", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Leadership", 1)
        BRScript:AddSkillPoints("persuasion", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Persuasion", 1)
        BRScript:AddSkillPoints("intimidation", 1)
        BRScript:ShowGameAlert("ADD_TO_SKILL", "$Skill_Intimidation", 1)
        local upgradeType = "deflect"
        local rackets = MissionUtils:controlledRackets()
        for i = 1, #rackets do
            local upgrade = rackets[i].upgrades:getUpgradeOfType(upgradeType)
            if upgrade then
                upgrade:upgrade(1)
            end
        end
    end
end

--[[------------------------------------------------------------------------------
MEGAMOD ELECTION REPAIR
One-shot rescue for saves where the election chain silently died before the
checkPlacements fix existed (the vanilla callback-suicide bug above). Detects
which party took the player's money via the save-persisted
$ChicagoStylePolitics earnings modifier (StartDemocrats stamps casinos,
StartRepublicans stamps bars; Democrat task A also stamps bars, so casinos are
checked first) and re-creates that party's event, which now retries daily
until placements exist. Clears the leftover ChicagoPolitics_* task facts so
the restarted missions begin clean.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ELECTION_REPAIR"
_event = "MegaModElectionRepair"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "MidGameEvent"

function onCreate()
    disableAutoComplete()
    -- Tells the SafehouseManager bootstrap an instance already exists (auto-
    -- created at Bridging entry in new games, or bootstrapped into old saves)
    fact.MegaModElectionRepairHosted = true
end

function GameEvent.onDayBegin(e)
    if fact.MegaModElectionRepairDone then return end
    if fact.MegaModElectionDone or fact.MegaModElectionChainAlive then
        -- Chain concluded, or it runs under the fixed retry code: nothing to rescue
        fact.MegaModElectionRepairDone = true
        return
    end

    local party = nil
    local casinos = MissionUtils:controlledRackets("CASINO")
    if casinos then
        for i = 1, #casinos do
            local data = casinos[i].data
            if data and data:hasModifier("earnings", "$ChicagoStylePolitics") then
                party = "HelpDemocrats"
                break
            end
        end
    end
    if not party then
        local bars = MissionUtils:controlledRackets("BAR")
        if bars then
            for i = 1, #bars do
                local data = bars[i].data
                if data and data:hasModifier("earnings", "$ChicagoStylePolitics") then
                    party = "HelpRepublicans"
                    break
                end
            end
        end
    end
    if not party then return end -- no donation in this save (yet); keep watching

    fact.MegaModElectionRepairDone = true
    fact.ChicagoPolitics_MetStranger = false
    fact.ChicagoPolitics_ReturnedToStranger = false
    fact.ChicagoPolitics_MetWoman = false
    fact.ChicagoPolitics_ReturnedToWoman = false
    fact.ChicagoPolitics_MetSmith = false
    fact.ChicagoPolitics_ReturnedToSmith = false
    fact.ChicagoPolitics_RejectedTask1 = false
    fact.ChicagoPolitics_RejectedTask2 = false

    WorldUtils:createEvent(party)
    WorldUtils:scheduleWithDelay("MegaModElectionRepairNotice", 10, "TICK")
end

--[[------------------------------------------------------------------------------
MEGAMOD ELECTION REPAIR NOTICE
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_ELECTION_REPAIR_NOTICE"
_event = "MegaModElectionRepairNotice"

function onTrigger()
    title("$MEGAMOD_ELECTION_repair_title") --$ The Party Hasn't Forgotten You
    text("$MEGAMOD_ELECTION_repair_text") --$ A ward boss corners you outside your safehouse. "That contribution of yours didn't go unnoticed, friend. The party's been meaning to call on you for those favors we discussed -- there was some... clerical confusion. Expect word from us again soon. Chicago politics, eh?"
    option("$MEGAMOD_ELECTION_repair_dismiss") --$ About time.
end

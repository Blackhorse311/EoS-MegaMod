-- --------------------------------------------------
-- MoleEvents.lua
-- --------------------------------------------------

-- "$MoleFailTitle" --$ Mole Failed!
-- "$MoleCaughtAndKilledTitle" --$ Mole Caught And Killed!
-- "$MoleCaughtAndKilledDescription" --$ {0} got caught and has been executed by {1}!
-- "$MoleFailReasonNoValidTarget" --$ No valid target!
-- "$MoleFailUnlucky" --$ {0} did not succeed in their mole mission and is returning.
-- "$MoleFailReasonNotEnoughCash" --$ They're broke!
-- "$MoleFailReasonNoMates" --$ They don't know anybody to piss off!
-- "$MoleSuccessTitle" --$ Mole Succeeded!

_namespace = "WORLD_EVENTS"

_id = "BASE_MOLE_EVENT"
_name = "BaseMoleEvent"
_abstract = true

months = 1



persist{}
mole = nil
persist{}
targetFaction = nil
persist{}
chanceOfBeingCaught = 0
persist{}
chanceOfSuccess = 1
persist{}
invalidActionFailReason = nil
persist{}
infiltrator = nil
persist{}
isAIAction = false
persist{}
canceled = false
persist{}
incrementalSuccessChance = 0
newMission = true
daysToTrigger = 30
persist{}
maxEvents = 4  -- including 1 before triggering first and 1 after triggering last will make 6 x daysToTrigger in total
persist{}
eventCount = 0


function onCreate()
    print("Created a mole event with ", mole.name, " doing a ", _name, " on ", targetFaction.name, "and chance of success", chanceOfSuccess, "and chance of being killed if caught", chanceOfBeingCaught) --FOR TESTING
    if isAIAction then
        trigger()
    else
        --MODIFIED
        local timeToTrigger = Utils:daysToSecs(daysToTrigger) 
        local maxEmbedPeriod = timeToTrigger * maxEvents
        if newMission then
            incrementalSuccessChance = chanceOfSuccess / (maxEvents + 1)
            chanceOfSuccess = incrementalSuccessChance
            eventCount = 0
        end
        worldTimeCallback(onTrigger, timeToTrigger)
        if not mole:hasState("Mole") then         
            mole:addState("Mole", "timeBeforeTriggering", maxEmbedPeriod + (timeToTrigger * 2))
        end
    end
end

function onTrigger()
    if canceled or not mole:hasState("Mole") or not mole:hasState("Employed") then
        return
    end
    if targetFaction:isDead() then
        returnMole()
        return
    end
    if isAIAction then
        onAITrigger()
        return
    end
    local actionValid, optionalParam = validAction()
    if actionValid then
        --[[ OLD CODE - MODIFIED
        if moleSucceedAction() then
            doSuccessfulAction(optionalParam)
        elseif moleGetCaught() then
            caught()
        else
            fail({"$MoleFailUnlucky", mole.name})
        end --]]
        --MODIFIED NEW CODE
        if chanceOfBeingCaught == -1 then
            local roll = math.random()
            local success = roll <= chanceOfSuccess
            if success then
                doSuccessfulAction(optionalParam)
            else
                fail({"$MoleFailUnlucky", mole.name})
            end
        else
            local persuasion = mole:getModifierValue("persuasion")
            chanceOfBeingCaught = (50 - persuasion) / (maxEvents * 100)
            if moleGetCaught() then
                WorldUtils:triggerEvent("moleCaughtEvent", "mole", mole, "targetFaction", targetFaction)
            else
                -- increase chance of discovering faction safehouse
                local random = math.random()
                if random < 0.25 then
                    local playerFaction = mole.faction
                    local safehouse = targetFaction.primarySafehouse
                    local safehouseMixin = safehouse and safehouse._buildingMixin
                    if safehouseMixin and safehouseMixin.isHiddenToFaction then
                        safehouseMixin:addDiscoveryChance(playerFaction, 0.25)
                    end
                end
                -- trigger new event
                eventCount = eventCount + 1
                if eventCount > maxEvents then
                    eventCount = -1
                end
                WorldUtils:triggerEvent("newMoleEvent", "eventCount", eventCount, "mole", mole, "chanceOfSuccess", chanceOfSuccess, "incrementalSuccessChance", incrementalSuccessChance, "targetFaction", targetFaction, "eventId", _id, "infiltrator", infiltrator)
            end
        end
        --END OF MOD
    else
        fail(invalidActionFailReason)
    end
end

function onAITrigger()
    local actionValid, optionalParam = validActionForAI()
    mole:addState("EnemyMole")
    if actionValid and moleSucceedAction() then
        -- print("Success!")
        doSuccessfulAIAction(optionalParam)
    else
        -- print("Fail!")
        failAI(optionalParam)
    end
end

function validAction()
    logError("Mole event's validAction validation function has not been overridden!")
end

function validActionForAI()
    logError("Mole event's validActionForAI validation function has not been overridden!")
end

function doSuccessfulAction(optionalParam)
    logError("Mole event's doSuccessfulAction function has not been overridden!")
end

function doSuccessfulAIAction(optionalParam)
    logError("Mole event's doSuccessfulAction function has not been overridden!")
end

function caught()
    local params =
    {
        title = "$MoleCaughtAndKilledTitle",
        text = {"$MoleCaughtAndKilledDescription", mole.name, targetFaction.name},
        image = mole.characterIcon,
        wide = true,
        usesNoButton = false
    }
    Utils:alertDialog(params)
end

function fail(reason)
    local params =
    {
        title = "$MoleFailTitle",
        text = reason,
        image = mole.characterIcon,
        wide = true,
        usesNoButton = false
    }
    Utils:alertDialog(params)
    returnMole() 
end

function failAI(param)
    logError(infiltrator.name, "failed to", _name, ". This is where we should be starting a mole hunt!")
end

function successAI(...)
    logError("Mole event's successAI function has not been overridden!")
end

function success(successMessage, ...)
    returnMole()
    local params =
    {
        title = "$MoleSuccessTitle",
        text = {successMessage, ...},
        image = mole.characterIcon,
        wide = true,
        usesNoButton = false
    }
    Utils:alertDialog(params)
end

function moleSucceedAction()
    local roll = math.random()
    local success = roll <= chanceOfSuccess
    print("Succeed Roll is ", roll, " and chance is ", chanceOfSuccess, "so success is", success) -- FOR TESTING
    return success
end

function moleGetCaught()
    local roll = math.random()
    local caught = roll <= chanceOfBeingCaught
    print("Caught Roll is ", roll, " and chance is ", chanceOfBeingCaught, "so caught is", caught) -- FOR TESTING
    return caught
end

function returnMole()
    mole:removeState("Mole")
end

function killMole()
    mole:addState("Dead")
end

function viewAccuseScreen()
    Utils:viewAccuseScreen(mole)
end

function GameEvent.onFactionLoss(e)
    if e.faction == targetFaction then
        returnMole()
        canceled = true
    end
end

-- -------------------------------------------------------------------
-- NEW CODE
-- -------------------------------------------------------------------
_namespace = "WORLD_EVENTS"
_id = "NEW_MOLE_EVENT"
_includes = "BASE_AI_MESSAGE_EVENT"
_event = "newMoleEvent"

mole = nil
chanceOfSuccess = nil
targetFaction = nil
eventId = nil
infiltrator = nil
eventCount = 0

function onTrigger()
    setModal(true)
    title("$Mole_Undiscovered_title") --$ Your mole remains undiscovered
    setCharacterPortrait(mole)
    if eventCount < 0 then
        text({"$Mole_Undiscovered_Final_text", mole.name, targetFaction.name, chanceOfSuccess}) --$ {0} is still embedded with the {1} faction, but time is running out.\nYou have the choice of going for it now ({2:P0} chance of success) or asking your mole to abandon their mission and return to your crew.
    else
        text({"$Mole_Undiscovered_text", mole.name, targetFaction.name, chanceOfSuccess}) --$ {0} is still embedded with the {1} faction.\nYou have the choice of going for it now ({2:P0} chance of success), biding your time for another month, or asking your mole to abandon their mission and return to your crew. \nThe mole's chance of success increases the longer they are in place, but so does their chance of being caught!
        option("$Stay_In_Place", stayInPlace) --$ Bide your time for now
    end
    option("$Go_For_It", checkSuccess) --$ Go For It!
    option("$TimeToLeave", abandonMission) --$ I need you back, get out of there.
end

function stayInPlace()
	--trigger new mole event with increased chance of success
    chanceOfSuccess = chanceOfSuccess + incrementalSuccessChance
    WorldUtils:createEvent(eventId, "newMission", false, "eventCount", eventCount, "targetFaction", targetFaction, "mole", mole, "chanceOfBeingCaught", 0, "chanceOfSuccess", chanceOfSuccess,"incrementalSuccessChance", incrementalSuccessChance, "infiltrator", infiltrator, "isAIAction", false)
end

function checkSuccess()
    WorldUtils:createEvent(eventId, "newMission", false, "targetFaction", targetFaction, "mole", mole, "chanceOfBeingCaught", -1, "chanceOfSuccess", chanceOfSuccess, "infiltrator", infiltrator, "isAIAction", false)
end

function abandonMission()
    mole:removeState("Mole")
end

_namespace = "WORLD_EVENTS"
_id = "MOLE_CAUGHT_EVENT"
_includes = "BASE_AI_MESSAGE_EVENT"
_event = "moleCaughtEvent"

targetFaction = nil
mole = nil

function onTrigger()
    setModal(true)
    title("$MoleCaughtAndKilledTitle")
    text({"$MoleCaughtAndKilledMessage", mole.name}) --$ We found your mole, {0}. So we got them to dig a hole, and then we buried them in it!
    setFactionPortrait(targetFaction)
    option("$Damn", killMole) --$ Damn
end

function killMole()
    -- Reduce faction rating with target faction 
    targetFaction.rating:applyEffect(mole.faction, "MOLE_DISCOVERED")
    mole:addState("Dead")
end
-- ----------------------------------------------------------------------
-- END OF NEW CODE
-- ----------------------------------------------------------------------
_id = "SABOTAGE_A_RACKET"
_name = "SabotageARacket"
_includes = "BASE_MOLE_EVENT"

successMessage = "$MoleActionSabotageARacketSuccessMessage" --$ Success! {0} sabotaged {1}, a {2} {3} owned by {4}! == 0 is the attacking mole, 1 is the racket name, 2 is the racket size, 3 is the racket type and 4 is the name of the faction that owns the racket.
invalidActionFailReason = "$MoleFailReasonNoValidTarget"
thugThreshold = 10

function doSuccessfulAction(racket)
    sabotageBuilding(racket)
    success(successMessage, mole.name, racket.name, racket.localizedSize, racket.buildingData.racketName, targetFaction.name)
end

function doSuccessfulAIAction(racket)
    local message = sabotageBuilding(racket)
    setModal(true)
    text({"$EVENTS_Mole_Business_Sabotage_Success_text", racket.name, message})
    option("$Unfortunate", viewAccuseScreen)
end

function sabotageBuilding(racket)
    local factionRacketCount = #targetFaction.buildings

    if factionRacketCount >= thugThreshold then
        racket.buildingData:changeOwner(targetFaction, WorldUtils:thugFaction())
        return "$EVENTS_Mole_Business_Sabotage_ThugControl_text"
    else
        racket:smashUp(infiltrator)
        return "$EVENTS_Mole_Business_Sabotage_SmashedUp_text"
    end
end

function failAI(building)
    setModal(true)
    if building == nil then
        --print("Failing with no building")
        text({"$EVENTS_Mole_Business_Sabotage_NoBuildingFail_text"})
    else
        --print("Failing with", building.name)
        text({"$EVENTS_Mole_Business_Sabotage_Fail_text", building.name})
    end

    option("$Unfortunate", viewAccuseScreen)
end

function viewAccuseScreen()
    Utils:viewAccuseScreen(mole)
end

function validAction()
    local targetFactionRackets = targetFaction.buildings

    local targetSize
    local moleTier = 6 - mole.tier

    if moleTier <= 2 then
        targetSize = 1
    elseif moleTier <= 4 then
        targetSize = 2
    else
        targetSize = 3
    end

    for i = 1, #targetFactionRackets do
        local racket = targetFactionRackets[i]
        if racket.size <= targetSize and not (racket.isSafehouseOrDepot) then
            return true, racket
        end
    end
    return false
end

function validActionForAI()
    return validAction()
end

_id = "STEAL_CASH"
_name = "StealCash"
_includes = "BASE_MOLE_EVENT"

invalidActionFailReason = "$MoleFailReasonNotEnoughCash"
successMessage = "$MoleActionStealCashSuccessMessage" --$ Success! {0} stole {1:C0} from {2}!

function validAction()
    return targetFaction.cash.count > 0
end

function validActionForAI()
    return validAction()
end

function doSuccessfulAIAction()
    local sum = stealCash()
    setModal(true)
    text({"$EVENTS_Mole_Cash_Sabotage_Success_text", sum})
    option("$Unfortunate", viewAccuseScreen)
end

function doSuccessfulAction()
    local sum = stealCash()
    success(successMessage, mole.name, sum, targetFaction.name)
end

function failAI(param)
    setModal(true)
    text({"$EVENTS_Mole_Cash_Sabotage_Fail_text"})
    option("$Unfortunate", viewAccuseScreen)
end

function viewAccuseScreen()
    Utils:viewAccuseScreen(mole)
end

function stealCash()
    local invertedTier = 6 - mole.tier
    local randomPercentage = math.range(0.01, 0.05)
    local stealingPercentage = randomPercentage * invertedTier
    local moleFactionCash = infiltrator.cash
    local targetFactionCash = targetFaction.cash
    local sum = math.round(targetFactionCash.count * stealingPercentage)
    targetFactionCash:subtract(sum, "CASH.STOLEN_BY_MOLE")
    moleFactionCash:add(sum, "CASH.STOLEN_BY_MOLE")
    return sum
end


_id = "MISINFORMATION"
_name = "Misinformation"
_includes = "BASE_MOLE_EVENT"

successMessage = "$MoleActionMisinformationSuccessMessage" --$ Success! {0} sabotaged the relationship between {1} and {2} by {3} points!
invalidActionFailReason = "$MoleFailReasonNoMates"
moleFaction = nil

function validAction()
    local targetDiplomacyManager = targetFaction.diplomacy
    moleFaction = infiltrator
    local targetFactionContacts = targetDiplomacyManager:getKnownGangs()
    local sortedTargetFactionContacts = table.sort(targetFactionContacts, function (factionA, factionB)
        local aScore = factionA.rating:getScore(moleFaction)
        local bScore = factionB.rating:getScore(moleFaction)
        return aScore < bScore
    end)
    if sortedTargetFactionContacts == nil then
        return false
    end
    for i = 1, #sortedTargetFactionContacts do
        local factionToMalign = sortedTargetFactionContacts[i]
        if factionToMalign:knowsAbout(moleFaction) then
            return true, factionToMalign
        end
    end
    return false
end

function validActionForAI()
    local valid, faction = validAction()
    if valid then
        return valid, faction
    end

    local targetDiplomacyManager = targetFaction.diplomacy
    local targetFactionContacts = targetDiplomacyManager:getKnownGangs()

    for i = 1, #targetFactionContacts do
        local factionToMalign = targetFactionContacts[i]
        if factionToMalign.iid ~= infiltrator.iid then
            return true, factionToMalign
        end
    end
    return false
end

function doSuccessfulAction(factionToMalign)
    local fallout = malignFaction(factionToMalign, targetFaction)
    success(successMessage, mole.name, targetFaction.name, factionToMalign.name, fallout)
end

function doSuccessfulAIAction(factionToMalign)
    malignFaction(factionToMalign, targetFaction)
    setModal(true)
    text({"$EVENTS_Mole_Misinformation_Sabotage_Success_text", factionToMalign.name})
    option("$Unfortunate", viewAccuseScreen)
end

function failAI(param)
    setModal(true)
    text({"$EVENTS_Mole_Misinformation_Sabotage_Fail_text"})
    option("$Unfortunate", viewAccuseScreen)
end

function viewAccuseScreen()
    Utils:viewAccuseScreen(mole)
end

function malignFaction(factionToMalign, otherFaction)
    local invertedTier = 6 - mole.tier
    local fallout = 100 * invertedTier
    otherFaction.rating:applyEffect(factionToMalign, "MOLE_MISINFORMATION_ATTACK", fallout)
    return fallout
end

_id = "BOSS_HIT"
_name = "BossHit"
_includes = "BASE_MOLE_EVENT"

successMessage = "$MoleActionBossHitSuccessMessage" --$ Success! {0} assassinated {1}!
invalidActionFailReason = nil

--[[ Not sure why this was overridden here
function fail(reason)
    returnMole() 
end]]

function validAction()
    return not targetFaction.boss:isDead()
end

function validActionForAI()
    return false
end

function doSuccessfulAction()
    local targetBoss = targetFaction.boss
    targetBoss._recentDamageSource = mole
    targetBoss:addState("Dead")
    success(successMessage, mole.name, targetFaction.boss.name)
end
--[[ MODIFIED - OLD CODE
function moleGetCaught()
    local roll = math.random()
    local modifiedChance = chanceOfBeingCaught + 0.33
    local caught = roll <= modifiedChance
    return caught
end
--]]

function GameEvent.onBossDeath(e)
    local targetBoss = targetFaction.boss
    if e.target == targetBoss then
        if targetBoss._recentDamageSource ~= mole then
            -- The target boss has died, return mole.
            returnMole()
        end
    end
end

-- --------------------------------------------------
_id = "FAILED_MOLE_FLIP"
_name = "FailedMoleFlip"

failedMoleFlipTitle = "$MoleFlipFailTitle" --$ Attempted Gangster Flip
failedMoleFlipDescription = "$MoleFlipFailDescription" --$ Hey, boss. {0} tried to turn {1} against you and the rest of the crew.
sourceFaction = nil
targetMole = nil

function onCreate()
    local params =
    {
        title = failedMoleFlipTitle,
        text = {failedMoleFlipDescription, sourceFaction.name, targetMole.name},
        usesNoButton = false,
        onAlertYes = function()
            WorldUtils:getPlayerFaction().rating:applyEffect(sourceFaction, "MOLE_FLIP_FAIL")
        end
    }
    Utils:alertDialog(params)
end

-- --------------------------------------------------
-- MOLE INTRODUCTION
-- Introduces how moles work to the player
-- --------------------------------------------------

_id = "MOLE_INTRODUCTION"
_event = "MoleIntroduction"

mole = nil

function onTrigger()
    local moleManager = WorldUtils:getMoleManager()
    moleManager.introShown = true
    title("$EVENTS_Mole_Event_Introduction_title") --$ Mole Suspected
    text("$EVENTS_Mole_Event_Introduction_text")
    option("$EVENTS_Mole_Event_Introduction_button_1", viewAccuseScreen)
end

function viewAccuseScreen()
    Utils:viewAccuseScreen(mole)
end

-- --------------------------------------------------
-- MOLE ACCUSATION CORRECT
-- --------------------------------------------------

_id = "MOLE_ACCUSATION_CORRECT"
_event = "MoleAccusationCorrect"

mole = nil
loyaltyBonus = 5

function onTrigger()
    mole.behaviours:add("Blackballed")
    local playerFaction = WorldUtils:getPlayerFaction()
    if mole.faction.isPlayerFaction then
        local members = playerFaction.members
        local inRange = false
        for i=1, #members do
            local member = members[i]
            if member.iid ~= mole.iid then
                if member.shooter:canShoot(mole) and Utils:inRange(20, member, mole) then
                    inRange = true
                    mole.faction:fireCrewMemberDontLeave(mole)
                    Utils:startCombat(member, mole, {skipPreparation = true})
                    break
                end
            end
        end
        if not inRange then
            mole.faction:fireCrewMember(mole)
        end
    end
    setModal(true)
    title("$EVENTS_Mole_Accusation_Correct_title") --$ Mole Identified
    text({"$EVENTS_Mole_Accusation_Correct_text", mole, loyaltyBonus})
    option("$Good_Riddance", Success) --$ Good Riddance!
end

function Success()
    -- Go through each RPC and grant them loyalty
    local faction = WorldUtils:getPlayerFaction()
    for k, v in next, faction.characters do  -- MEGAMOD FIX: faction.rpcs is legacy (nil after load)
        v:applyMoraleConfig("MOLE_DISCOVERED")
        v.loyalty:add(loyaltyBonus, "$Loyalty_FoundMole")
    end
end

-- --------------------------------------------------
-- MOLE ACCUSATION INCORRECT
-- --------------------------------------------------

_id = "MOLE_ACCUSATION_INCORRECT"
_event = "MoleAccusationIncorrect"

mole = nil

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()

    if mole.faction.isPlayerFaction then
        mole:leaveFaction()
    end

    mole.behaviours:add("JoinRivalRevenge", "hatedFaction", playerFaction)

    setModal(true)
    title("$EVENTS_Mole_Accusation_Incorrect_title") --$ Falsely Accused
    text({"$EVENTS_Mole_Accusation_Incorrect_text", mole})
    option("$Unfortunate")
end

-- --------------------------------------------------

_id = "ACTIVE_MOLE_DEATH"
_event = "ActiveMoleDeath"

rpc = nil

function onTrigger()
    beginMinimized()

    setModal(true)
    title("$EVENTS_Mole_Death_During_Hunt_title") --$ We've Buried a Mole
    text({"$EVENTS_Mole_Death_During_Hunt_text", rpc})
    option("$Good_Riddance")
end

_namespace = "RATING_EFFECTS"

--[[------------------------------------------------------------------------------
Mole Discovered
--------------------------------------------------------------------------------]]

_id = "MOLE_DISCOVERED"
value = -100
name = "$RATING_EFFECTS_MOLE_DISCOVERED_name" --$ Mole Discovered
description = "$RATING_EFFECTS_MOLE_DISCOVERED_description" --$ Mole discovered and killed

-- --------------------------------------------------
-- Alternative Mole.lua
-- --------------------------------------------------
_namespace = "BEHAVIOURS"
_id = "ALTERNATIVE_MOLE"
_name = "AlternativeMole"
_includes = "MOLE"

function getTimeLeftString()
    local daysEmbedded = Utils:convertDuration(worldTime - startTime, "Seconds", "Days")
    daysEmbedded = math.round(daysEmbedded)
    if daysEmbedded == 1 then
        return "$Mole_TimeEmbedded_OneDay", thisActor --$ {0:name} has been embedded for 1 day.
    else
        return "$Mole_TimeEmbedded", thisActor, daysEmbedded --$ {0:name} has been embedded for {1} days.
    end
end

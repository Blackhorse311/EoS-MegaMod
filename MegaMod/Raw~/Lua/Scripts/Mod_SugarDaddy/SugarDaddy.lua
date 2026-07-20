--[[------------------------------------------------------------------------------
    Hey there! In this modding tutorial we're going to learn how to:
        - Listen for when a particular mission is successful.
        - Spawn a customized character in the world.
        - Add/Remove a conversation on a character.
        - Create a new source of weekly income.
        - Add a "follow" behaviour.
        - Set up combat AI parameters.
        - And much more!
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: First off lets make a config for Lord Sugarfather II.
    Since we're in the scripts folder we can declare a number of scripts in this same file, and configs can be written as scripts.
--------------------------------------------------------------------------------]]
_namespace = "NPC" -- The namespace for all NPC configs
_id = "LORD_CHARLES_SUGARFATHER_II" -- Our full configId now will be NPC.LORD_CHARLES_SUGARFATHER_II
_includes = {"NPC.BASE_MISSION_MALE"} -- A boilerplate config to 'include' (kind of like inheriting, we copy in all of those scripts data)

-- The bartender looks dapper enough to use for our character, so lets use his prefab.
characterIcon = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_01_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_01_Profile"
prefab = "Models/Characters/Extras/MissionNPCs/Prefabs/MissionNPC_Bartender_Male_01"
ragdollPrefab = "Models/Characters/Extras/Bartenders/Prefabs/Bartender_Male_01_Ragdoll"

name = "$Mod_SugarDaddy_LordSugar_Fullname" --$ Lord Charles Sugarfather II
firstName = "$Mod_SugarDaddy_LordSugar_Firstname" --$ Charles
lastName = "$Mod_SugarDaddy_LordSugar_Lastname" --$ Sugarfather
-- In honor of Spooky Season, lets give him the best Charles nickname:
nickName = "$Mod_SugarDaddy_LordSugar_Nickname" --$ Chucky
profession = "NoProfession" -- Override the "HiredGun" default profession for Mission NPCs
combatPersonality = { SUGAR_DADDY_COMBAT_AI = true } -- This is a custom combatPersonality we'll define at the bottom this file.

--[[------------------------------------------------------------------------------
    Step 2: We want Sugarfather to show up after reading the article by Veronica. So lets make sure that mission was successful.
    Lets make a World Event that hangs around and listens for completed missions.
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS" -- This indicates the following script(s) will be world event scripts
_id = "MOD_SUGAR_DADDY_LISTEN_FOR_INTERVIEW_COMPLETE"
_event = "ModSugarDaddyListenForInterviewComplete"
_gameStage = "Bridging" -- Changed from Early (Early stage events don't fire for modded events)
_autoStartMode = "Create" -- Create or Schedule? Since we're just listening for a GameEvent we can create right away and start listening in the background.
_category = "CitizenMission" -- Lets add this to the same category as the interview mission

function GameEvent.onMissionComplete(eventData)
    local mission = eventData.mission
    if mission._scriptName == "GettingPersonal" then -- Interview mission completed!
        if mission._status == "Success" then
            -- Successful interview! Lets give it a couple days and then spawn our Sugar Daddy!
            local daysUntilLordSugarArrives = 5 -- Five days should do the trick
            local secondsUntilLordSugarArrives = Utils:daysToSecs(daysUntilLordSugarArrives)
            -- This delayed event needs the time in seconds, so we do a quick conversion before passing the value along
            WorldUtils:scheduleWithDelay("ModSugarDaddyIntroducingLordSugar", secondsUntilLordSugarArrives, "TICK")
            -- "TICK" means that after the delay its going to check every frame if it can trigger, other options are "DAILY_TICK" and "WEEKLY_TICK"
        end
        -- Either way, we're done with this event now, so we can complete it.
        complete()
    end
end

--[[------------------------------------------------------------------------------
    Step 3: Lets give our Lord Sugarfather a bit of an introduction, lets spawn the event that kicks off the story.
    We're still in the WORLD_EVENTS namespace, so lets just declare the new event
--------------------------------------------------------------------------------]]
_id = "MOD_SUGAR_DADDY_INTRODUCING_LORD_SUGAR"
_event = "ModSugarDaddyIntroducingLordSugar" -- Same as was scheduled just above

-- We don't want to trigger if the player is somewhere lord Sugarfather wouldn't show up, like in their safehouse.
-- To keep it simple, lets trigger this when the player is outside somewhere.
function canTrigger() -- Every "TICK", or frame, this will be checked, and if it returns 'true' the event will trigger.
    local player = Character:getPlayer()
    if not Utils:isSelected(player) then
        return false -- If the player isn't selected then we don't want to run up to a crew member
    end
    local location = player:getLocation()
    if location and location.isExterior then -- we check "if location" first to make sure the player has a location before checking what kind of location it is.
        return true
    else
        return false
    end
end

function onTrigger()
    spawnLordSugar()
    title("$ModSugarDaddy_Introduction_Title") --$ "Hey! You there, I know you!"
    text("$ModSugarDaddy_Introduction_Text") --$ From several yards away you see a man shout and begin to run toward you.
    option("$ModSugarDaddy_Introduction_Option", runUpToPlayer) --$ "What the hell is this now?"
end

lordSugarfather = nil -- We'll declare his reference here so both functions below can use him

function spawnLordSugar()
    -- Lets go ahead and create him in the void first and set his reference.
    lordSugarfather = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.LORD_CHARLES_SUGARFATHER_II")
    -- We don't want him to have anything in his inventory
    lordSugarfather.inventory:clear()

    -- Now we need to pick a spot for him to spawn.
    local player = Character:getPlayer()
    local posX, posY, posZ = player:get3DPosXYZ()
    local rotation = 0 -- Don't care as he's about to start running
    local minDistance = 10 -- He can't spawn closer to the player position than this.
    local maxDistance = 20 -- He can't spawn further from the player position than this.
    lordSugarfather:setupSafeSpawnPosXYZ(posX, posY, posZ, rotation, minDistance, maxDistance)
    -- The above will set up a spawn position for when he comes out of the void and into a location, which we will now do.
    lordSugarfather:setLocationId(player:getLocationId())
end

function runUpToPlayer()
    -- Now we trigger a ready-made scenario that has him run up to the player and start a conversation:
    local conversationEntryPoint = "SugarDaddy_Introduction_Start" -- This will be the EntryPoint we'll use to access our conversation below.
    WorldUtils:startScenario("NPCApproachesPlayer", lordSugarfather, conversationEntryPoint)
end

--[[------------------------------------------------------------------------------
    Step 4: Lets switch namespace to make our Conversation!
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS" -- This indicates the following script(s) will be conversations
_id = "SUGAR_DADDY_INTRODUCTION_START"
EntryPoint = "SugarDaddy_Introduction_Start" -- This has to match the conversationEntryPoint above for this conversation to be used.

startingWeeklyCash = 300 -- This is the amount we'll use in the conversation below for how much he'll initially pay you per week.

-- I'm not going to cover conversations in detail in this tutorial. For that I recommend checking out the "Chatty Advisor" mod.
function onStart()
    go(GreetingsOldChap)
end

function GreetingsOldChap()
    say("$SugarDaddy_Introduction_GreetingsOldChap_Say") --$ Good Heavens, it <i>IS</i> you! The famous '{you:name}'! I've read all about your exploits in a recent article by one Veronica Lockhart...
    option("$SugarDaddy_Introduction_GreetingsOldChap_Option1", WhoAreYou) --$ Yadda yadda yadda, yeah it's me. Who the hell are you?
    option("$SugarDaddy_Introduction_GreetingsOldChap_Option2", HowDidYouRecognizeMe) --$ Wait a minute, how were you able to recognize me?! The papers didn't print a picture.
end

function HowDidYouRecognizeMe()
    say("$SugarDaddy_Introduction_HowDidYouRecognizeMe_Say") --$ Well, my good {you:gender?fellow|madam|chum}, as a picture paints a thousand words so can a thousand words paint a picture!.. and Ms Lockhart was generous in her lexicon!
    option("$SugarDaddy_Introduction_HowDidYouRecognizeMe_Option1", WhoAreYou) --$ Alright, you got a picture of who I am so who the hell are you?
end

function WhoAreYou()
    say("$SugarDaddy_Introduction_WhoAreYou_Say") --$ Ah, where are my manners? My name is Lord Charles Sugarfather the Second. I hail from across the Atlantic and have journeyed to Chicago in pursuit of the true <i>American Gangster</i> experience!
    option("$SugarDaddy_Introduction_WhoAreYou_Option1", WhatDoYouWant) --$ The true... What the?...
end

function WhatDoYouWant()
    say("$SugarDaddy_Introduction_WhatDoYouWant_Say") --$ Wait, that's it! I've just had a marvelous idea! I tell you what, you let me tag along on your criminal escapades and I'll see if I can't find a good use for all this dosh in my wallet.
    option("$SugarDaddy_Introduction_WhatDoYouWant_Option1", ItsADeal) --$ So you want to risk your own neck and I get paid? Sounds like a deal I'm alright with, {them:nickName}.
    option("$SugarDaddy_Introduction_WhatDoYouWant_Option2", HowMuch) --$ Forget about it, I'm not hav... wait, how much are we talking about?
end

function HowMuch()
    say({"$SugarDaddy_Introduction_HowMuch_Say", startingWeeklyCash}) --$ Well that entirely depends on what kind of excitement I can expect. I assure you the more I experience, the more patronage you'll get. How about we start with say, {0:C0} a week and go from there?
    option("$SugarDaddy_Introduction_HowMuch_Option1", ItsADeal) --$ Excitement eh? Lets hope you can survive it. You got a deal, Sugarfather!
    option("$SugarDaddy_Introduction_HowMuch_Option2", NoDeal) --$ I'm no babysitter, pal. No Deal!
end

function ItsADeal()
    say("$SugarDaddy_Introduction_ItsADeal_Say") --$ Splendid! Just marvelous! Oh I'm so excited!
    option("$SugarDaddy_Introduction_ItsADeal_Option1", SetupBehaviourOnLordSugarAndLeave) --$ Alright, come along then...
end

function NoDeal()
    say("$SugarDaddy_Introduction_NoDeal_Say") --$ Oh bobbins! You rotten thing! Wait, are you entirely certain?
    option("$SugarDaddy_Introduction_NoDeal_Option1", ItsADeal) --$ <i>Sigh</i>. Fine, I guess you can tag along.
    option("$SugarDaddy_Introduction_NoDeal_Option2", SendLordSugarAwayAndLeave) --$ Yeah, get the hell outta here.
end

-- So here we've decided to accept his deal. We're going to add a behaviour to him that will run the rest of this mod.
function SetupBehaviourOnLordSugarAndLeave()
    them:removeConversationEntryPoint("SugarDaddy_Introduction_Start") -- Also we don't need this any more.
    them.behaviours:add("SugarDaddy", "weeklyCash", startingWeeklyCash) -- We'll write this behaviour below.
    -- '"weeklyCash", startingWeeklyCash' here means we're going to set the behaviour's weeklyCash to the same thing we set our startingWeeklyCash to, 300
    go(Leave)
end

-- And here we decided to turn him away, so lets make him leave and exit the conversation.
function SendLordSugarAwayAndLeave()
    them:removeConversationEntryPoint("SugarDaddy_Introduction_Start") -- Also we don't need this any more.
    them.brain:addGoal("LeaveLocationAndVoid", 10001) -- Walk away and disappear
    go(Leave)
end

--[[------------------------------------------------------------------------------
    Step 5: The 'Sugar Daddy' Behaviour.
    Lets switch namespace to make our Behaviour
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "SUGAR_DADDY"
_name = "SugarDaddy" -- This is used so we can add the behaviour like we did above, else we'd use the whole configId

persist{} -- This means that we want to weeklyCash to be able to save and load. If you have script values that you know are going to change, you'll want to do this.
weeklyCash = nil -- We're expecting this to be passed in when the behaviour is added above so we're setting it to nil here.
persist{}
followTarget = nil

persist{} -- We want to save `lastCombatTime` since it changes.
lastCombatTime = 0 -- This is going to keep track of how long its been since the last combat.
-- The next 2 never change so we don't need to persist{} them.
daysUntilBored = 21 -- If its been a while since the last combat, he'll get bored and give you less money.
daysUntilLeave = 42 -- If its been a very long time, he'll leave.

persist{}
bored = false -- To start with we're not bored, but this could change.

function onAdd() -- This function automatically gets called when a behaviour is added to an actor
    setWeeklyCash() -- Lets add our weekly income from our Sugar Daddy
    local player = Character:getPlayer()
    followTarget = player
    thisActor:setFaction(player.faction) -- This is the easiest way to make them join the player in combat, just have them part of the player faction.
    -- Since we've only just added the sugar daddy, lets set this time to the current worldTime.
    lastCombatTime = worldTime
end

-- And this makes sure we can't control the SugarDaddy in combat.
function Modifier.usesCombatAI()
    return true
end

-- Lets set up the weekly income, we'll call this when adding the behaviour above or if we want to update the amount.
function setWeeklyCash()
    local incomeCategory = "$Patronage" --$ Patronage
    local playerFaction = WorldUtils:getPlayerFaction()
    playerFaction.cash:setWeeklyIncome(incomeCategory, thisScriptInterface, weeklyCash)
    -- By passing in 'thisScriptInterface' we let the cash manager know that this is the source of income.
    -- The cash manager now expects us to write a getName() function on this script in case the player needs to see a breakdown of this income category.
end

function getName() -- This will be used when seeing a breakdown of the 'Patronage' category of income
    -- thisActor is the actor our behaviour lives on, in this case, Lord Sugarfather
    return "$SugarDaddy_name", thisActor --$ Sugar Daddy: {0:name}
end

-- When we die we remove this behaviour
function ObjectEvent.onCharacterDeath(eventData) -- ObjectEvent means an event that only happens to this Object/Actor, unlike a GameEvent that happens globally.
    WorldUtils:triggerEvent("ModSugarDaddyDies")
    thisActor.behaviours:remove(handle) -- handle is a built-in variable on behaviour scripts that is the identifier for this behaviour
end

-- When we remove this behaviour, remove the weekly income
function onRemove() -- This function automatically gets called when a behaviour is removed from an actor
    -- We already defined the string key above, so we don't need to (and aren't allowed to) define it again.
    local incomeCategory = "$Patronage"
    local playerFaction = WorldUtils:getPlayerFaction()
    playerFaction.cash:removeWeeklyIncome(incomeCategory, thisScriptInterface)
end

-- Every Day lets check if we're getting bored.
function GameEvent.onDayBegin(eventData)
    local secondsUntilBored = Utils:convertDuration(daysUntilBored, "Days", "Seconds")
    local secondsUntilLeave = Utils:convertDuration(daysUntilLeave, "Days", "Seconds")
    local secondsSinceLastCombat = (worldTime - lastCombatTime)
    if (secondsSinceLastCombat > secondsUntilBored) and not bored then
        bored = true
        weeklyCash = 10 -- Set the weekly cash to 10 bucks
        setWeeklyCash() -- Update it in the cash manager
        -- Trigger the bored event
        WorldUtils:triggerEvent("ModSugarDaddyGetsBored", "newWeeklyAmount", weeklyCash)
    elseif secondsSinceLastCombat > secondsUntilLeave then
        -- Trigger the leave event
        WorldUtils:triggerEvent("ModSugarDaddyLeaves")
        thisActor.brain:addGoal("LeaveLocationAndVoid", 10001) -- Walk away and disappear
        thisActor.behaviours:remove(handle) -- Remove this behaviour
    end
end

-- Every time we end combat reset the boredom clock and add more weekly cash
function GameEvent.onCombatEnd(eventData)
    local combatContext = WorldUtils:getCombatContext()
    if combatContext.combatCancelled then
        return -- We don't count it if we just entered and exited ambush mode.
    end
    -- Are we in this combat?
    local weAreInCombat = false
    local actors = combatContext.combatActors
    for i = 1, #actors do
        if thisActor == actors[i] then
            weAreInCombat = true
            break
        end
    end
    if weAreInCombat then
        lastCombatTime = worldTime
        if bored then -- If we were bored
            bored = false
            weeklyCash = 300 -- Reset weekly cash to 300
        end
        weeklyCash = weeklyCash + 50 -- Add another 50 bucks to our weekly patronage
        setWeeklyCash()
        WorldUtils:triggerEvent("ModSugarDaddyEnjoyedCombat", "newWeeklyAmount", weeklyCash)
    end
end

-- This is what we'll use to track our follow movement:
movePosX = 0
movePosY = 0

-- Instead of saving the above, we're going to set it to our own position when this behaviour activates (adds or loads)
function onActivate()
    movePosX, movePosY = thisActor:getPosXY()
end

-- The custom follow behaviour, this will update every frame.
function GameEvent.frame(e)
    if followTarget:getLocationId() ~= thisActor:getLocationId() then -- They've entered a new location, teleport us near them
        thisActor:setLocationId(0)
        local posX, posY, posZ = followTarget:get3DPosXYZ()
        local rotation = math.random(360) -- pick a random rotation in degrees to face
        local minDistance = 1
        local maxDistance = 3
        thisActor:setupSafeSpawnPosXYZ(posX, posY, posZ, rotation, minDistance, maxDistance)
        thisActor:setLocationId(followTarget:getLocationId())
        movePosX, movePosY = thisActor:getPosXY()
    else
        local targetPosX, targetPosY = followTarget:getPosXY()
        local distToTarget = Utils:calcDistance(movePosX, movePosY, targetPosX, targetPosY)
        if distToTarget > 20 then -- They've likely taken a taxi, or some other fast travel method, teleport us near them
            local posX, posY, posZ = followTarget:get3DPosXYZ()
            local rotation = math.random(360) -- pick a random rotation in degrees to face
            local minDistance = 1
            local maxDistance = 3
            thisActor:setupSafeSpawnPosXYZ(posX, posY, posZ, rotation, minDistance, maxDistance)
            movePosX, movePosY = thisActor:getPosXY()
        elseif distToTarget > 5 then
            -- Update our moveTo position and navigate to it
            -- Pick a random orbit 1 unit radius away from the followTarget (i.e. player)
            -- This random rotation is in radians instead of degrees, as we're using it with the math library sin and cos functions
            local randomRotation = math.random() * 3.14 -- Doesn't have to be perfect PI as this is just a random value
            local randomSin = math.sin(randomRotation) -- This gives us the sine of a unit circle, i.e. 1 unit away
            local randomCos = math.cos(randomRotation) -- And the cosine, also 1 unit away

            movePosX = targetPosX + randomCos -- This should put our moveTo target at a random orbit 1 unit away.
            movePosY = targetPosY + randomSin -- This should put our moveTo target at a random orbit 1 unit away.
            thisActor.behaviours:doCommand("Move", Vector2(movePosX, movePosY), false, thisActor:getLocationId(), 0, true)
        end
    end
end

--[[------------------------------------------------------------------------------
    Step 6: Create the 'Bored', 'Leave', 'EnjoyedCombat', and 'Dies' events.
    Lets switch back to the World Event namespace
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MOD_SUGAR_DADDY_GETS_BORED"
_event = "ModSugarDaddyGetsBored"

newWeeklyAmount = nil -- This will be the lowered weekly income from the sugar daddy

function onTrigger()
    title("$ModSugarDaddy_GetsBored_Title") --$ Lord is getting bored.
    text("$ModSugarDaddy_GetsBored_Text") --$ "What is this? I'm supposed to be having the Gangster experience, yet I've not seen even a pea shooter fired for weeks now. This is not what I've been paying you for, so maybe I'll start paying a little less."
    addBonusText({"$ModSugarDaddy_GetsBored_BonusText", newWeeklyAmount}) --$ Your weekly patronage has been reduced to {0:C0}. If Lord Sugarfather II doesn't see some action in the next couple of weeks he will leave and no longer be your patron.
    option("$ModSugarDaddy_GetsBored_Option") --$ Fine, I'll see what I can do.
end

_id = "MOD_SUGAR_DADDY_LEAVES"
_event = "ModSugarDaddyLeaves"

function onTrigger()
    title("$ModSugarDaddy_Leaves_Title") --$ No more Sugar
    text("$ModSugarDaddy_Leaves_Text") --$ "What a rip-off. Its been months now with no action in sight. I'm sorry old pal but I've got better things to do"
    addBonusText("$ModSugarDaddy_Leaves_BonusText") --$ Lord Sugarfather II is no longer your patron.
    option("$ModSugarDaddy_Leaves_Option") --$ Was kind of tired of him following me around anyway.
end

_id = "MOD_SUGAR_DADDY_ENJOYED_COMBAT"
_event = "ModSugarDaddyEnjoyedCombat"

newWeeklyAmount = nil -- This will be the increased weekly income from the sugar daddy

function onTrigger()
    title("$ModSugarDaddy_EnjoyedCombat_Title") --$ Lord Sugarfather is living the dream!
    text("$ModSugarDaddy_EnjoyedCombat_Text") --$ "Oh boy, that was exciting! Here, have some more money!"
    addBonusText({"$ModSugarDaddy_EnjoyedCombat_BonusText", newWeeklyAmount}) --$ Your weekly patronage has been increased to {0:C0}.
    option("$ModSugarDaddy_EnjoyedCombat_Option") --$ Thanks, Sugar.
end

_id = "MOD_SUGAR_DADDY_DIES"
_event = "ModSugarDaddyDies"

function onTrigger()
    title("$ModSugarDaddy_Dies_Title") --$ Lord Sugarfather has passed away.
    text("$ModSugarDaddy_Dies_Text") --$ "Aaarrrhhggg..."
    addBonusText("$ModSugarDaddy_Dies_BonusText") --$ Lord Sugarfather and his weekly patronage is no more.
    option("$ModSugarDaddy_Dies_Option") --$ So long, Sugar.
end

--[[------------------------------------------------------------------------------
    Step 7: Adding AI parameters for combat personality. This was added in Lord Sugarfather's NPC config up at the top.
    Lets switch namespace again to set up our combat AI
--------------------------------------------------------------------------------]]
_namespace = "COMBAT_AI"
_id = "SUGAR_DADDY_COMBAT_AI"

target = {}
target.targetSelf = 100 -- The only "target" we want, self to move
-- Setting all of these to 0 so the sugar daddy ignores them:
target.targetAlly = 0
target.targetFlankedEnemy = 0
target.targetWeakEnemy = 0
target.targetStrongestEnemy = 0
target.targetRandomEnemy = 0
target.targetNearestEnemy = 0
target.targetFurthestEnemy = 0
target.targetLowFactionRating = 0
target.targetSubduedCharacter = 0
movement = {}
movement.SeekCoverFilter = 50
-- We don't care about any of these, we just want to run around into cover spots, even if that puts us close to enemies.
movement.RangeBandFilter = 0
movement.MoveTowardsEnemiesFilter = 0
movement.SeekFlankingFilter = 0
movement.GroupWithAlliesFilter = 0
movement.MaintainGoodRangeFilter = 0
-- We don't want to do these actions, so set them to 0.
action = {}
action.LeaveCombatArea = 0
-- Don't want to go punch anyone.
action.GeneralMelee = 0

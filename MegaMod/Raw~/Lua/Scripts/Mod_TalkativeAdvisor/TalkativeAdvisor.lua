--[[------------------------------------------------------------------------------
    Welcome! In this modding tutorial we're going to learn how to:
    - Create a world event that will run in the background and listen for GameEvents
    - Add/Remove a conversation on a character
    - Create a conversation that will be adapt to the game using a powerful feature: 'MatchingRules'
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: First off lets make our World Event.
    This is going to listen for whenever we add or remove an Advisor
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS" -- This indicates the following script will be a world event script
_id = "MOD_TALKATIVE_ADVISOR_SETUP_CONVERSATION"
_event = "ModTalkativeAdvisor_SetupConversation"
_gameStage = "Bridging" -- At what game stage do we create/trigger this event? (Bridging, Early, Mid, Late..etc)
_autoStartMode = "Create" -- Do we "Create" or "Schedule" this event with a delay?
-- (Note: "Create" won't automatically trigger, and so won't call onTrigger, but that's fine cause we're not triggering this, we're just using it for its listeners)
_category = "Misc" -- Don't really need a category for this, lets use "Misc"

-- These next two functions are the events that get called when the Advisor is set and removed.
-- In the codebase you'll often see the parameter 'eventData' just written as 'e'
function GameEvent.onSetAdvisor(eventData)
    -- In a couple places, like here, the gangsters are refered to as "RPCs" or "Recruitable Player Characters"
    local advisor = eventData.rpc
    -- Lets add a conversation to our Advisor, we'll create the conversation below

    -- This is our entryPoint into the conversation, multiple conversation scripts can use the same entry point, which we'll see below.
    local entryPoint = "TalkToAdvisor_Start"
    -- This is used in case we start jumping between conversation scripts to get us back on track, we're not going to explore that in this tutorial though.
    local talkingAbout = "GettingAdviceFromAdvisor"
    -- This is how much priority our entry point has, in case another entryPoint is also on the advisor (Like from a mission)
    -- We're going to keep it fairly low so it doesn't interfere with other conversations.
    local priority = 10
    advisor:setConversationEntryPoint(entryPoint, talkingAbout, priority)
end

-- And when the advisor gets removed, lets remove the entry point
function GameEvent.onRemoveAdvisor(eventData)
    local advisor = eventData.rpc
    advisor:removeConversationEntryPoint("TalkToAdvisor_Start")
end

--[[------------------------------------------------------------------------------
    Step 2: Lets make our first conversation script.
    To cover all our bases, lets make the most generic version of this conversation that could work in any context.
    This will be used as a fallback if there is no specific conversation that makes sense to use.
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS" -- This indicates the following scripts will be conversations
_id = "MOD_TALKATIVE_ADVISOR_START" -- We want to make sure this is unique, so lets use our mod name in the id
-- Make sure these are the same as the ones we added above.
EntryPoint = "TalkToAdvisor_Start"
TalkingAbout = "GettingAdviceFromAdvisor"

-- This is the function all conversations start with, you can run any script code you want to set up here
function onStart()
    -- We're just going to use this to go to our first conversation block, 'HiBoss'
    go(HiBoss)
end

-- Conversation blocks are made up of say() and option() calls. As we can see here:
function HiBoss()
    say("$Mod_TalkativeAdvisor_Start_HiBoss_Say") --$ Hi Boss, anything you wanted to talk to me about?
    option("$Mod_TalkativeAdvisor_Start_HiBoss_Option1", AskForAdvice) --$ I wanted to ask you for advice.
    option("$Mod_TalkativeAdvisor_Start_HiBoss_Option2", NothingAtTheMoment) --$ Nothing at the moment.

    -- Huh? What's going on with those "$text" things up there?
    -- To add text to the game, we use pairs of string keys (i.e: "$StringKey") and strings (i.e: -- $ This is some text)
    -- These get converted to files that can be translated when the mod is built.
    -- You can reuse these string keys, just don't declare the same pair of string key + string in two places
end

-- You'll notice that in the second option above we added NothingAtTheMoment as the second parameter, this means that option will go here:
function NothingAtTheMoment()
    say("$Mod_TalkativeAdvisor_Start_NothingAtTheMoment_Say") --$ No problem, just come talk to me if you'd like any advice!
    option("$Mod_TalkativeAdvisor_Start_NothingAtTheMoment_Option1", Leave) --$ Will do.
    -- Leave is a built-in option to end the conversation.
end

-- Then in the first option of HiBoss we added AskForAdvice as the second parameter:
function AskForAdvice()
    -- We're going to do something a little different now.
    -- Instead of continuing the conversation in this script, we're going to jump to a new script
    callConversationEntry("TalkToAdvisor_Advice")
    -- This part of the conversation is going to change depending on what advice they have for us.
end

--[[------------------------------------------------------------------------------
    Step 3: Lets make a new script for the middle "Advice" part of the conversation.
    We're making this a separate script so we can make lots of different versions of this middle part.
    To cover all our bases, lets make a script that is the most generic version that could work in any context.
    This will be used as a fallback if there is no specific advice that makes sense to use.
    And the most generic case would be: they don't have any advice.
--------------------------------------------------------------------------------]]
_id = "MOD_TALKATIVE_ADVISOR_NO_ADVICE"
EntryPoint = "TalkToAdvisor_Advice" -- This is what we used in our callConversationEntry() above
TalkingAbout = "GettingAdviceFromAdvisor"

function onStart()
    go(NoAdvice)
end

function NoAdvice()
    -- Now what if we want to refer to the player by name? Well there's a built in parameter {you:name} we can use that will change to your character's name.
    say("$Mod_TalkativeAdvisor_NoAdvice_Say") --$ I'm sorry, {you:name}, I can't think of anything new to tell you.

    -- And yes, there's also a matching {them:name}. Along with 'name', you can also use 'firstName' and 'lastName'.
    option("$Mod_TalkativeAdvisor_NoAdvice_Option1", CheckForMoreAdvice) --$ That's ok, {them:firstName}, you've given me plenty of advice already.
end

function CheckForMoreAdvice()
    callConversationEntry("TalkToAdvisor_End")
end

--[[------------------------------------------------------------------------------
    Step 4: Now we make the end part of the conversation where we can ask for more advice or leave.
--------------------------------------------------------------------------------]]
_id = "MOD_TALKATIVE_ADVISOR_END"
EntryPoint = "TalkToAdvisor_End"
TalkingAbout = "GettingAdviceFromAdvisor"

function onStart()
    go(AnythingElse)
end

function AnythingElse()
    say("$Mod_TalkativeAdvisor_End_AnythingElse_Say") --$ Anything else you wanted to ask me about?
    option("$Mod_TalkativeAdvisor_End_AnythingElse_Option1", AskForAdviceAgain) --$ Do you have any other advice?
    option("$Mod_TalkativeAdvisor_End_AnythingElse_Option2", Leave) --$ I'm good thanks, talk to you later.
end

function AskForAdviceAgain()
    callConversationEntry("TalkToAdvisor_Advice")
end

--[[------------------------------------------------------------------------------
    Step 5: Alright, so now lets go back and make an "Advice" part of the conversation that would actually be useful advice.
    If the player is Capone, he has empire bonuses that make his Brothel and Brewery upgrades cheaper.
    Lets remind him of that.
--------------------------------------------------------------------------------]]
_id = "MOD_TALKATIVE_ADVISOR_CAPONE_EMPIRE_BONUSES" -- New conversation, new _id
EntryPoint = "TalkToAdvisor_Advice" -- Same as the one above
TalkingAbout = "GettingAdviceFromAdvisor"
-- We don't want to be annoying about our advice, so lets make sure we only ever run this particular script once.
OnlyUseOnce = true

-- So we don't want this conversation to run unless the player is Capone. How do we do that?
-- This is where we use a cool feature of conversation scripts, MatchingRules:
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.OUTFIT_BOSS") end,
}
-- Now this conversation will only run if the above is true.

function onStart()
    go(GiveAdvice)
end

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_CaponeBonuses_GiveAdvice_Say") --$ Here's some advice for you, {you:firstName}. You've got a skill at knocking the price down on your Brothel and Brewery upgrades. I'd make the most of that if I were you!
    option("$Mod_TalkativeAdvisor_CaponeBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Thanks for the tip, {them:lastName}. I'll keep it in mind.
end

function CheckForMoreAdvice()
    callConversationEntry("TalkToAdvisor_End")
end

--[[------------------------------------------------------------------------------
    Step 6: Lets do the same for Genna.
--------------------------------------------------------------------------------]]
_id = "MOD_TALKATIVE_ADVISOR_GENNA_EMPIRE_BONUSES"
EntryPoint = "TalkToAdvisor_Advice"
TalkingAbout = "GettingAdviceFromAdvisor"
OnlyUseOnce = true
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.GENNA_BOSS") end,
}

function onStart()
    go(GiveAdvice)
end

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_GennaBonuses_GiveAdvice_Say") --$ Compared to the other gangs in Chicago your Breweries are well guarded and your Speakeasies are cheap to upgrade. I'd make the most of that if I were you!
    option("$Mod_TalkativeAdvisor_GennaBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Good thinking, {them:lastName}!
end

function CheckForMoreAdvice()
    callConversationEntry("TalkToAdvisor_End")
end

-- We can do more of these but I'll put them into the other script file so they don't take up tutorial space here.

--[[------------------------------------------------------------------------------
    Step 7: So we've done some YouAre rules. Lets try something a little fancier, a custom rule.
    Lets tell the player to go find some other major factions if they've not met anyone yet.
--------------------------------------------------------------------------------]]
_id = "MOD_TALKATIVE_ADVISOR_FIND_OTHER_BOSSES"
EntryPoint = "TalkToAdvisor_Advice"
TalkingAbout = "GettingAdviceFromAdvisor"
OnlyUseOnce = true
-- Matching Rules are just functions that expect to return true or false, so we can just make one of our own.
MatchingRules =
{
    function()
        -- 'you' and 'them' are built-in variables in conversation scripts.
        local knownGangs = you.faction.diplomacy:getKnownGangs()
        return (#knownGangs == 0) -- If the count of known gangs is 0, this will return true.
    end,
}

function onStart()
    go(GiveAdvice)
end

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_FindOtherBosses_GiveAdvice_Say") --$ You should probably go find some of the other gangs in Chicago. It would be good to get an idea of your competition, and there may even be some lucrative deals to make.
    option("$Mod_TalkativeAdvisor_FindOtherBosses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Hmm.. I'll start looking around then, thanks.
end

function CheckForMoreAdvice()
    callConversationEntry("TalkToAdvisor_End")
end

--[[------------------------------------------------------------------------------
    Step 8: Now lets try doing multiple rules, where something VERY specific has happened.
    If ANY of these rules fail this conversation won't be picked. So you can assume in the script that all of the rules are true!
    The conversation with the most amount of rules (all passing of course) will always be the one that is picked.
    This means that you can surprise the player with a conversation that is super specific to what they're doing. Its like the game knows!
--------------------------------------------------------------------------------]]
_id = "MOD_TALKATIVE_ADVISOR_TELL_MAGGIE_TO_END_WAR"
EntryPoint = "TalkToAdvisor_Advice"
TalkingAbout = "GettingAdviceFromAdvisor"
OnlyUseOnce = true

MatchingRules =
{
    -- You are Maggie Dyer...
    function() return BRScript:YouAre("CHARACTER.BOSS.WHITECITY_BOSS") end,

    -- And they are a Doctor...
    function() return them.profession:is("Doctor") end,

    -- And you're losing a War...
    function()
        for war in you.faction.diplomacy:iterateOverInterfaces("WAR") do
            if war:isLosingWar(you.faction) then
                return true
            end
        end
        return false
    end,

    -- And someone in your crew is recovering from an injury...
    function()
        local crewMembers = you.faction.members
        for i = 1, #crewMembers do
            if crewMembers[i].injury then
                return true
            end
        end
        return false
    end,

    -- And you have a private clinic in one of your precincts.
    function()
        local neighborhoods = WorldUtils:getExteriorLocations()
        for i = 1, #neighborhoods do
            if neighborhoods[i]:hasImprovementSlotForFaction("IMPROVEMENT_SLOTS.PRIVATE_CLINIC", you.faction) then
                return true
            end
        end
        return false
    end,
}

-- If we get this far we can assume ALL of the above is true!
-- So lets collect all the information to talk about.
enemyFaction = nil
recoveringGangster = nil
precinctWithPrivateClinic = nil
-- We set all of these to nil to say that they're in this script, but we don't know what they are yet.

-- We use this function to set all those values up.
function onStart()
    -- Who is the war against?
    for war in you.faction.diplomacy:iterateOverInterfaces("WAR") do
        if war:isLosingWar(you.faction) then
            -- If we're the attacker then they're the defender, and vice versa
            if war:isAttacker(you.faction) then
                enemyFaction = war.defendersInstigator -- The primary faction on the defenders side
            else
                enemyFaction = war.attackersInstigator -- The primary faction on the attackers side
            end
            break
        end
    end

    -- Who is recovering from an injury?
    local crewMembers = you.faction.members
    for i = 1, #crewMembers do
        if crewMembers[i].injury then
            -- Found them!
            recoveringGangster = crewMembers[i]
            break
        end
    end

    -- Where is the Private Clinic?
    local neighborhoods = WorldUtils:getExteriorLocations()
    for i = 1, #neighborhoods do
        -- This function returns 2 results: both if it has an improvement, and the precinct its in.
        local hasImprovement, precinct = neighborhoods[i]:hasImprovementSlotForFaction("IMPROVEMENT_SLOTS.PRIVATE_CLINIC", you.faction)
        if hasImprovement then
            precinctWithPrivateClinic = precinct
            break
        end
    end

    -- Now we're all set, lets give Maggie some advice!
    go(TellMaggieToEndTheWar)
end

function TellMaggieToEndTheWar()
    -- Along with the custom conversation, we can make it even more custom by wrapping the text and custom parameters in {} braces.
    say( {"$Mod_TalkativeAdvisor_TellMaggieToEndTheWar_Say", enemyFaction, precinctWithPrivateClinic.name, recoveringGangster} ) --$ I don't know how you manage your circus lions, Maggie, but looking at the way the war is going it seems {0:name} is a lion you're not going to tame. Now I'm a doctor, not a lion tamer, and I'm glad for the private clinic you set up in {1} to help me get {2:name} on the mend, but we just can't keep taking these casualties. You're going to need to end this war.
    -- enemyFaction becomes parameter 0, precinct name is 1, and recoveringGangster is 2, in the string we use them for {0:name}, {1}, and {2:name}
    option("$Mod_TalkativeAdvisor_TellMaggieToEndTheWar_Option1", CheckForMoreAdvice) --$ Wow, I did not expect that coming from you.
end

function CheckForMoreAdvice()
    callConversationEntry("TalkToAdvisor_End")
end

-- And that's it for this tutorial!
-- Check out the MoreConversationExamples.lua in this mod for even more custom Advice scripts.

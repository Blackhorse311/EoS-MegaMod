--[[------------------------------------------------------------------------------
    MegaMod: Top Jimmy
    "Top Jimmy" Malone - the king of the safehouse scene. Everybody knows him,
    and everybody knows if you need muscle, you gotta go see Top Jimmy.
    Inspired by the Van Halen song and the real Top Jimmy of LA's club scene.

    Spawns hired guards at the player's safehouse to bolster defenses.
    Three tiers of muscle available at different price points.
    Camera focuses on each new recruit so the player sees them arrive.
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: Define Top Jimmy NPC
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_RECRUITER"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_02_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_02_Profile"
prefab = "Models/Characters/Extras/MissionNPCs/Prefabs/MissionNPC_Bartender_Male_02"
ragdollPrefab = "Models/Characters/Extras/Bartenders/Prefabs/Bartender_Male_02_Ragdoll"

name = "$MEGAMOD_RECRUITER_fullname" --$ "Top Jimmy" Malone
firstName = "$MEGAMOD_RECRUITER_firstname" --$ Jimmy
lastName = "$MEGAMOD_RECRUITER_lastname" --$ Malone
profession = "NoProfession"
commands =
{
    Talk = true,
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    Recruit NPC configs - armed guards spawned at safehouse
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_RECRUIT_STREET"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
prefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01"
ragdollPrefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01_Ragdoll"

name = "$MEGAMOD_RECRUIT_STREET_name" --$ Hired Muscle
firstName = "$MEGAMOD_RECRUIT_STREET_first" --$ Hired
lastName = "$MEGAMOD_RECRUIT_STREET_last" --$ Muscle
profession = "NoProfession"
commands =
{
    CivilianAttack = false,
}

_namespace = "NPC"
_id = "MEGAMOD_RECRUIT_VETERAN"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_02_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bartender_Male_02_Profile"
prefab = "Models/Characters/Extras/MissionNPCs/Prefabs/MissionNPC_Bartender_Male_02"
ragdollPrefab = "Models/Characters/Extras/Bartenders/Prefabs/Bartender_Male_02_Ragdoll"

name = "$MEGAMOD_RECRUIT_VETERAN_name" --$ Veteran Gun
firstName = "$MEGAMOD_RECRUIT_VETERAN_first" --$ Veteran
lastName = "$MEGAMOD_RECRUIT_VETERAN_last" --$ Gun
profession = "NoProfession"
commands =
{
    CivilianAttack = false,
}

_namespace = "NPC"
_id = "MEGAMOD_RECRUIT_ELITE"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
prefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01"
ragdollPrefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01_Ragdoll"

name = "$MEGAMOD_RECRUIT_ELITE_name" --$ Professional
firstName = "$MEGAMOD_RECRUIT_ELITE_first" --$ The
lastName = "$MEGAMOD_RECRUIT_ELITE_last" --$ Professional
profession = "NoProfession"
commands =
{
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    Step 2: Spawn event - Top Jimmy arrives early game
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_RECRUITER_SPAWN"
_event = "MegaModRecruiterSpawn"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 80
_category = "Misc"

persist{}
recruiterActor = nil

function canTrigger()
    return true
end

function onTrigger()
    -- MEGAMOD FIX: check preconditions before spawning so an early return can't leak a location-less actor
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    recruiterActor = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_RECRUITER")
    safehouse:enter(recruiterActor, "IDLE", true)
    recruiterActor.behaviours:add("MegaModRecruiterBehaviour")

    title("$MEGAMOD_RECRUITER_arrive_title") --$ Gotta Go See Top Jimmy
    text("$MEGAMOD_RECRUITER_arrive_text") --$ A wiry Irishman has claimed a corner of your safehouse, sitting on the top stool at the end of the bar like he owns the place. "Top Jimmy," he says. "I'm the king of this scene, pal. You need somebody? I know everybody, and everybody knows me." He cracks his knuckles and grins. "I been running this from sundown to sunup for years. You got problems? I'll set you straight."
    option("$MEGAMOD_RECRUITER_arrive_option") --$ Good to know.
end

--[[------------------------------------------------------------------------------
    Step 3: Hire result events
    Each spawns a recruit, focuses the camera on them, and shows an arrival
    popup so the player absolutely sees their new guard arrive.
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_RECRUIT_STREET_HIRE"
_event = "MegaModRecruitStreetHire"

-- MEGAMOD FIX: the target safehouse arrives as a scheduleWithDelay vararg;
-- cross-block script vars (recruiterActor) are never shared
persist{}
targetSafehouse = nil

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = targetSafehouse
    if not safehouse then
        safehouse = playerFaction:getPrimarySafehouse()
    end
    if not safehouse then return end
    local recruit = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_RECRUIT_STREET")
    recruit:setFaction(playerFaction)
    safehouse:enter(recruit, "IDLE", true)

    -- Pan camera to the new recruit so the player sees them
    WorldUtils:focusOnActor(recruit, false, "goto_location")

    setModal(true)
    title("$MEGAMOD_RECRUIT_arrive_title") --$ New Recruit On Duty
    text("$MEGAMOD_RECRUIT_STREET_arrive") --$ Top Jimmy cooks, Top Jimmy swings -- and here's the proof. A street tough has shown up at your safehouse, armed and ready. He's not much to look at, but he's one more gun between you and trouble. He'll hold his post and fight for you when the time comes. Another satisfied customer of Top Jimmy's operation.
    option("$MEGAMOD_RECRUIT_arrive_ok") --$ Welcome aboard.
end

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_RECRUIT_VETERAN_HIRE"
_event = "MegaModRecruitVeteranHire"

persist{}
targetSafehouse = nil

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = targetSafehouse
    if not safehouse then
        safehouse = playerFaction:getPrimarySafehouse()
    end
    if not safehouse then return end
    local recruit = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_RECRUIT_VETERAN")
    recruit:setFaction(playerFaction)
    safehouse:enter(recruit, "IDLE", true)

    WorldUtils:focusOnActor(recruit, false, "goto_location")

    setModal(true)
    title("$MEGAMOD_RECRUIT_arrive_title") --$ New Recruit On Duty
    text("$MEGAMOD_RECRUIT_VETERAN_arrive") --$ Top Jimmy delivers again. A veteran gun has arrived at your safehouse, battle-tested and ready. This one's got the look of a man who's seen real action and lived to tell about it. He'll hold his ground when the lead starts flying. Your safehouse just got a lot harder to crack.
    option("$MEGAMOD_RECRUIT_arrive_ok") --$ Welcome aboard.
end

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_RECRUIT_ELITE_HIRE"
_event = "MegaModRecruitEliteHire"

persist{}
targetSafehouse = nil

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = targetSafehouse
    if not safehouse then
        safehouse = playerFaction:getPrimarySafehouse()
    end
    if not safehouse then return end
    local recruit = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_RECRUIT_ELITE")
    recruit:setFaction(playerFaction)
    safehouse:enter(recruit, "IDLE", true)

    WorldUtils:focusOnActor(recruit, false, "goto_location")

    setModal(true)
    title("$MEGAMOD_RECRUIT_arrive_title") --$ New Recruit On Duty
    text("$MEGAMOD_RECRUIT_ELITE_arrive") --$ Top shelf muscle for a top shelf operation. The professional Top Jimmy lined up has arrived at your safehouse. Cold eyes, steady hands, the kind of man who makes other men think twice about kicking your door in. This is what a thousand dollars buys you. Anybody tries to take this safehouse now, they're going to have a very bad day.
    option("$MEGAMOD_RECRUIT_arrive_ok") --$ Welcome aboard.
    complete()
end

--[[------------------------------------------------------------------------------
    Step 4: Conversation - hire menu with Van Halen-inspired dialogue
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_RECRUITER_CONVERSATION"
EntryPoint = "MegaMod_Recruiter_Start"

function onStart()
    go(MainMenu)
end

function MainMenu()
    say("$MEGAMOD_RECRUITER_greeting") --$ You got problems? Top Jimmy'll set you straight. Everybody from Bridgeport to the Gold Coast knows where to find me -- right here, every night, about this time. I got muscle, I got guns, I got experience. Need somebody? Let me show you what I got.
    option("$MEGAMOD_RECRUITER_street", StreetOffer)
    option("$MEGAMOD_RECRUITER_veteran", VeteranOffer)
    option("$MEGAMOD_RECRUITER_elite", EliteOffer)
    option("$MEGAMOD_RECRUITER_leave", Leave)
end

function StreetOffer()
    if you.faction.cash.count < 200 then
        say("$MEGAMOD_RECRUITER_cantafford") --$ Even Top Jimmy can't set you straight on an empty wallet. Come back when you're holding.
        option("$MEGAMOD_RECRUITER_backtomenu", MainMenu)
        option("$MEGAMOD_RECRUITER_leave", Leave)
        return
    end

    say("$MEGAMOD_RECRUITER_street_desc") --$ Two hundred bucks gets you a street tough. Not exactly a sharpshooter, but he'll hold a gun the right way around and stand where you tell him to. These boys swing when the time comes. He'll be right here on guard duty at this safehouse. Good enough?
    option("$MEGAMOD_RECRUITER_hire_yes", HireStreet)
    option("$MEGAMOD_RECRUITER_hire_no", MainMenu)
end

function HireStreet()
    BRScript:PlayerSubtractCash(200, "CASH.RECRUITMENT")
    them.pendingHireTier = 1
    say("$MEGAMOD_RECRUITER_street_done") --$ Done deal. Top Jimmy cooks, Top Jimmy swings. I'll have a guy here before the day's out. You'll see him when he shows up.
    option("$MEGAMOD_RECRUITER_more", MainMenu)
    option("$MEGAMOD_RECRUITER_leave", Leave)
end

function VeteranOffer()
    if you.faction.cash.count < 500 then
        say("$MEGAMOD_RECRUITER_cantafford")
        option("$MEGAMOD_RECRUITER_backtomenu", MainMenu)
        option("$MEGAMOD_RECRUITER_leave", Leave)
        return
    end

    say("$MEGAMOD_RECRUITER_veteran_desc") --$ Five hundred gets you someone who's been in the game a while. Knows his way around a Thompson, won't panic when the lead starts flying. This one's been running it from sundown to sunup, if you catch my drift. Solid investment for keeping this safehouse locked down.
    option("$MEGAMOD_RECRUITER_hire_yes", HireVeteran)
    option("$MEGAMOD_RECRUITER_hire_no", MainMenu)
end

function HireVeteran()
    BRScript:PlayerSubtractCash(500, "CASH.RECRUITMENT")
    them.pendingHireTier = 2
    say("$MEGAMOD_RECRUITER_veteran_done") --$ Good choice. Everybody knows Top Jimmy delivers. This one's a war vet, knows which end of a gun gets the job done. He'll be here shortly and he'll be ready to earn his keep.
    option("$MEGAMOD_RECRUITER_more", MainMenu)
    option("$MEGAMOD_RECRUITER_leave", Leave)
end

function EliteOffer()
    if you.faction.cash.count < 1000 then
        say("$MEGAMOD_RECRUITER_cantafford")
        option("$MEGAMOD_RECRUITER_backtomenu", MainMenu)
        option("$MEGAMOD_RECRUITER_leave", Leave)
        return
    end

    say("$MEGAMOD_RECRUITER_elite_desc") --$ A thousand gets you the real deal. Former military, crack shot, nerves of steel. One look at this guy and you know he ain't right -- in all the best ways. The kind of man who makes other men think twice about kicking your door in. Worth every penny for a top shelf operation.
    option("$MEGAMOD_RECRUITER_hire_yes", HireElite)
    option("$MEGAMOD_RECRUITER_hire_no", MainMenu)
end

function HireElite()
    BRScript:PlayerSubtractCash(1000, "CASH.RECRUITMENT")
    them.pendingHireTier = 3
    say("$MEGAMOD_RECRUITER_elite_done") --$ Now we're talking. Top shelf muscle for a top shelf operation. I know just the man -- former Bureau agent, fell out with the feds over some disagreement about whose money was whose. He'll be at your safehouse by sundown. Another satisfied customer.
    option("$MEGAMOD_RECRUITER_more", MainMenu)
    option("$MEGAMOD_RECRUITER_leave", Leave)
end

function Leave()
    say("$MEGAMOD_RECRUITER_goodbye") --$ Gotta go see Top Jimmy? That's me, pal. I'm always here.
    endConversation()
end

--[[------------------------------------------------------------------------------
    Step 5: Behaviour - manages conversation entry point and hire processing
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_RECRUITER_BEHAVIOUR"
_name = "MegaModRecruiterBehaviour"

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_Recruiter_Start")
end

function GameEvent.frame(e)
    local tier = thisActor.pendingHireTier
    if tier then
        thisActor.pendingHireTier = nil
        -- MEGAMOD FIX: resolve this NPC's safehouse (clone-aware, save-durable) and hand
        -- it to the hire event as a persisted vararg; the old recruiterActor proxy was a no-op
        local safehouse = thisActor.memory.megamodHomeSafehouse
        if not safehouse then
            local location = WorldUtils:getLocationFromId(thisActor:getLocationId())
            if location and location.isInterior then
                safehouse = location.building
            end
        end
        local eventName
        if tier == 1 then
            eventName = "MegaModRecruitStreetHire"
        elseif tier == 2 then
            eventName = "MegaModRecruitVeteranHire"
        elseif tier == 3 then
            eventName = "MegaModRecruitEliteHire"
        end
        if eventName and safehouse then
            WorldUtils:scheduleWithDelay(eventName, 1, "TICK", "targetSafehouse", safehouse)
        elseif eventName then
            WorldUtils:scheduleWithDelay(eventName, 1, "TICK")
        end
    end
end

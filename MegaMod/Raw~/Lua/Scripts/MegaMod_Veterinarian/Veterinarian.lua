--[[------------------------------------------------------------------------------
    MegaMod: Doc Stitches - The Veterinarian
    A shady former doctor turned veterinarian who patches up your crew for cash,
    or accepts favors from those who can't pay.
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: Define the NPC
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_VETERINARIAN"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_02_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_02_Profile"
prefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_02"
ragdollPrefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_02_Ragdoll"

name = "$MEGAMOD_VET_fullname" --$ Doc Stitches
firstName = "$MEGAMOD_VET_firstname" --$ Doc
lastName = "$MEGAMOD_VET_lastname" --$ Stitches
profession = "NoProfession"
commands =
{
    Talk = true,
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    Step 2: Spawn event - appears early game after first fights
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_VET_SPAWN"
_event = "MegaModVetSpawn"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 120
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    -- MEGAMOD FIX: check preconditions BEFORE spawning so an early return can't leak a location-less actor
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    local vet = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_VETERINARIAN")
    safehouse:enter(vet, "IDLE", true)
    vet.behaviours:add("MegaModVetBehaviour")

    title("$MEGAMOD_VET_arrive_title") --$ A Doctor of Sorts
    text("$MEGAMOD_VET_arrive_text") --$ A man with rolled-up sleeves and what looks like horse blood on his apron has set up in a corner of your safehouse. He says his name is "Doc Stitches" and he's a veterinarian. But the way he's looking at your crew, he's not here to treat any dog. Talk to him when someone needs patching up.
    option("$MEGAMOD_VET_arrive_option") --$ A horse doctor. Sure, why not.
end

--[[------------------------------------------------------------------------------
    Step 3: Conversation - healing services and favor system

    Injury detection is done in BEHAVIOURS (where WorldUtils works) and stored
    on the actor. Conversation reads them.vetInjuredCount (number). Paid heals
    increment them.vetHealCount (counter, so each payment heals exactly one);
    favors/heal-all set them.vetHealAll. Both picked up by BEHAVIOURS
    GameEvent.frame.
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_VET_CONVERSATION"
EntryPoint = "MegaMod_Vet_Start"

function onStart()
    go(MainMenu)
end

function MainMenu()
    say("$MEGAMOD_VET_greeting") --$ Welcome to my practice. Don't mind the smell -- formaldehyde, mostly. I'm a veterinarian by trade, but between you and me, a bullet hole is a bullet hole whether it's in a racehorse or a gangster. What can I do for you?
        option("$MEGAMOD_VET_check_crew", CheckInjuries)  --$ My crew needs patching up
        option("$MEGAMOD_VET_backstory_ask", Backstory)  --$ How'd a vet end up in a safehouse?
        option("$MEGAMOD_VET_leave", Leave)  --$ Nothing right now
end

function CheckInjuries()
    local count = them.vetInjuredCount or 0

    if count == 0 then
        say("$MEGAMOD_VET_no_injuries") --$ I gave your herd a once-over. Everybody's walking upright and breathing without assistance. Come back when that changes. And knowing this line of work, it will.
                option("$MEGAMOD_VET_backtomenu", MainMenu)  --$ What else you got?
            option("$MEGAMOD_VET_leave", Leave)  --$ Nothing right now
        return
    end

    if count == 1 then
        say("$MEGAMOD_VET_one_injured") --$ I see one of yours is laid up. I can have them back on their feet for $750. Interested?
                option("$MEGAMOD_VET_heal_one", HealFirst)  --$ Fix them up ($750)
            option("$MEGAMOD_VET_cant_pay", OfferFavor)  --$ I can't afford that right now
            option("$MEGAMOD_VET_not_now", MainMenu)  --$ Not right now
    else
        say("$MEGAMOD_VET_multi_injured") --$ You've got some of your people out of commission right now. I can patch them up for $750 a head. Your call.
                option("$MEGAMOD_VET_heal_one_next", HealFirst)  --$ Heal the next one ($750)
            option("$MEGAMOD_VET_heal_all", HealAll)  --$ Heal all of them
            option("$MEGAMOD_VET_cant_pay", OfferFavor)  --$ I can't afford that right now
            option("$MEGAMOD_VET_not_now", MainMenu)  --$ Not right now
    end
end

function HealFirst()
    if you.faction.cash.count < 750 then
        say("$MEGAMOD_VET_cant_afford") --$ Your wallet's lighter than a canary with consumption. Can't treat what you can't pay for. Unless you're open to a different kind of arrangement.
                option("$MEGAMOD_VET_favor_ask", OfferFavor)  --$ What kind of arrangement?
            option("$MEGAMOD_VET_backtomenu", MainMenu)  --$ What else you got?
            option("$MEGAMOD_VET_leave", Leave)  --$ Nothing right now
        return
    end

    local count = them.vetInjuredCount or 0
    if count == 0 then
        say("$MEGAMOD_VET_no_injuries") --$ I gave your herd a once-over. Everybody's walking upright and breathing without assistance. Come back when that changes. And knowing this line of work, it will.
                option("$MEGAMOD_VET_leave_healed", Leave)  --$ Thanks, Doc
        return
    end

    BRScript:PlayerSubtractCash(750, "CASH.VET_HEALING")
    -- MEGAMOD FIX: counter instead of boolean so rapid repeat purchases can't
    -- double-charge for a single heal; decrement the count for the next menu
    them.vetHealCount = (them.vetHealCount or 0) + 1
    them.vetInjuredCount = count - 1

    say("$MEGAMOD_VET_healed_one") --$ Patched up and ready to go. Not my prettiest work, but the stitches will hold. Probably. Don't let them do anything stupid for a day or two.

    if count > 1 then
                option("$MEGAMOD_VET_next_patient", CheckInjuries)  --$ Next patient
            option("$MEGAMOD_VET_leave_healed", Leave)  --$ Thanks, Doc
    else
                option("$MEGAMOD_VET_leave_healed", Leave)  --$ Thanks, Doc
    end
end

function HealAll()
    local count = them.vetInjuredCount or 0
    local totalCost = count * 750

    if you.faction.cash.count < totalCost then
        say("$MEGAMOD_VET_cant_afford") --$ Your wallet's lighter than a canary with consumption. Can't treat what you can't pay for. Unless you're open to a different kind of arrangement.
                option("$MEGAMOD_VET_favor_ask", OfferFavor)  --$ What kind of arrangement?
            option("$MEGAMOD_VET_backtomenu", MainMenu)  --$ What else you got?
            option("$MEGAMOD_VET_leave", Leave)  --$ Nothing right now
        return
    end

    BRScript:PlayerSubtractCash(totalCost, "CASH.VET_HEALING")
    them.vetHealAll = true
    them.vetInjuredCount = 0

    say("$MEGAMOD_VET_healed_all") --$ All of your people are patched up. I used more catgut than I'd normally burn through in a month. You're keeping me in business, I'll give you that.

        option("$MEGAMOD_VET_leave_healed", Leave)  --$ Thanks, Doc
end

--[[------------------------------------------------------------------------------
    Favor System - 3 types with different success rates
--------------------------------------------------------------------------------]]

function OfferFavor()
    say("$MEGAMOD_VET_favor_intro") --$ Look, I'm not a charity. But I'm also a practical man. I've got some problems of my own -- the kind that a person with your resources could solve. You handle one of these for me, I'll patch up your whole crew. Free of charge.
        option("$MEGAMOD_VET_favor_debt", FavorDebt)  --$ Collect a debt for you
        option("$MEGAMOD_VET_favor_delivery", FavorDelivery)  --$ Deliver a package
        option("$MEGAMOD_VET_favor_lookaway", FavorLookAway)  --$ Turn a blind eye to something
        option("$MEGAMOD_VET_favor_decline", MainMenu)  --$ I'll pass on the favors
end

function FavorDebt()
    say("$MEGAMOD_VET_favor_debt_desc") --$ There's a gambler named Pinky Malone who owes me three hundred dollars for patching up his dog after a fight. Except Pinky doesn't have a dog, if you catch my drift. He's been dodging me for weeks. Send your boys to explain that debts have a way of compounding. Sixty-forty odds they find him.
        option("$MEGAMOD_VET_favor_accept", ExecuteFavorDebt)  --$ You've got a deal
        option("$MEGAMOD_VET_favor_other", OfferFavor)  --$ What else you got?
end

function ExecuteFavorDebt()
    if math.random() < 0.60 then
        them.vetHealAll = true
        say("$MEGAMOD_VET_favor_debt_success") --$ Your people tracked down Pinky at a flophouse on the South Side. He paid up -- every cent, plus interest. I'm feeling generous. Get your wounded in here and I'll have them fixed up by morning.
    else
        say("$MEGAMOD_VET_favor_debt_fail") --$ Your boys couldn't pin him down. Pinky's slippery as a greased eel. No payment means no treatment. Come back when you've got cash or I've got another problem for you to solve.
    end
        option("$MEGAMOD_VET_leave", Leave)  --$ Nothing right now
end

function FavorDelivery()
    say("$MEGAMOD_VET_favor_delivery_desc") --$ I've got a crate of "medical supplies" that needs to get across town to an associate of mine. No peeking inside, no asking questions. It's about a seventy-five percent chance your runner makes it without trouble. The other twenty-five percent involves cops, and I don't cover bail.
        option("$MEGAMOD_VET_favor_accept", ExecuteFavorDelivery)  --$ You've got a deal
        option("$MEGAMOD_VET_favor_other", OfferFavor)  --$ What else you got?
end

function ExecuteFavorDelivery()
    if math.random() < 0.75 then
        them.vetHealAll = true
        say("$MEGAMOD_VET_favor_delivery_success") --$ Your runner got the package there in one piece. My associate is happy, I'm happy, and now your crew is about to be very happy. Let me get my kit.
    else
        say("$MEGAMOD_VET_favor_delivery_fail") --$ Bad luck. Your courier got stopped at a checkpoint and had to dump the goods in the river. That was six months' worth of supplies. I'm out of pocket, and I'm out of charity. Better luck next time.
    end
        option("$MEGAMOD_VET_leave", Leave)  --$ Nothing right now
end

function FavorLookAway()
    say("$MEGAMOD_VET_favor_lookaway_desc") --$ I'm running a little side operation out of a building in your territory. Nothing that'll cause you problems, but it's not exactly above board. All I need is for you and your people to pretend you don't see anything for a while. Ninety percent chance nobody notices. The other ten percent, well, somebody gets nosy.
        option("$MEGAMOD_VET_favor_accept", ExecuteFavorLookAway)  --$ You've got a deal
        option("$MEGAMOD_VET_favor_other", OfferFavor)  --$ What else you got?
end

function ExecuteFavorLookAway()
    if math.random() < 0.90 then
        them.vetHealAll = true
        say("$MEGAMOD_VET_favor_lookaway_success") --$ Nobody saw a thing. Just the way I like it. You've got discretion, and I respect that. Now, let's take care of your people -- a deal's a deal.
    else
        say("$MEGAMOD_VET_favor_lookaway_fail") --$ One of your boys decided to play detective and shut my whole setup down. I appreciate the enthusiasm, but that wasn't the arrangement. No operation, no goodwill, no free treatment. We're done here.
    end
        option("$MEGAMOD_VET_leave", Leave)  --$ Nothing right now
end

--[[------------------------------------------------------------------------------
    Backstory
--------------------------------------------------------------------------------]]

function Backstory()
    say("$MEGAMOD_VET_backstory") --$ I had a practice once. A real one -- stethoscope, waiting room, the whole bit. Then a patient died on my table and the medical board had questions I didn't feel like answering. Turns out a veterinary license is easier to get and harder to lose. Now I treat dogs, cats, horses, and the occasional gangster who doesn't want to explain a bullet wound to a real hospital. Your safehouse has better lighting than most barns I've worked in. I like it here.
        option("$MEGAMOD_VET_backstory_react", MainMenu)  --$ I'm not going to ask any more questions
end

--[[------------------------------------------------------------------------------
    Leave
--------------------------------------------------------------------------------]]

function Leave()
    say("$MEGAMOD_VET_goodbye") --$ I'll be here. Animals, gangsters -- somebody always needs stitching up.
    endConversation()
end

--[[------------------------------------------------------------------------------
    Step 4: Behaviour - injury detection and healing execution
    WorldUtils IS available here. The injured count is refreshed daily, after
    heals, and after save/load, then stored on the actor for the conversation.
    Healing requests set by conversation are processed here too.
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_VET_BEHAVIOUR"
_name = "MegaModVetBehaviour"

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_Vet_Start")
    refreshInjuredList()
end

function GameEvent.onDayBegin(e)
    refreshInjuredList()
end

function GameEvent.frame(e)
    -- MEGAMOD FIX: ad-hoc actor fields aren't saved; re-derive the count after load
    if thisActor.vetInjuredCount == nil then
        refreshInjuredList()
    end

    -- Process paid heals from conversation (counter: one heal per payment)
    local healCount = thisActor.vetHealCount
    if healCount and healCount > 0 then
        thisActor.vetHealCount = nil
        local injured = getInjuredFromFaction()
        local numToHeal = math.min(healCount, #injured)
        for i = 1, numToHeal do
            healMember(injured[i])
        end
        refreshInjuredList()
    end

    -- Process heal-all flag from conversation
    if thisActor.vetHealAll then
        thisActor.vetHealAll = nil
        local injured = getInjuredFromFaction()
        for i = 1, #injured do
            healMember(injured[i])
        end
        refreshInjuredList()
    end
end

function getInjuredFromFaction()
    local injured = {}
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return injured end
    local members = playerFaction.members
    if not members then return injured end
    for i = 1, #members do
        local member = members[i]
        -- MEGAMOD FIX: also catch members carrying the formal Injury state
        if member and not member:isDead() and (member:isDamaged() or member:hasState("Injury")) then
            injured[#injured + 1] = member
        end
    end
    return injured
end

function refreshInjuredList()
    thisActor.vetInjuredCount = #getInjuredFromFaction()
end

function healMember(member)
    -- Reset health to full (same calls as vanilla Injury.lua resetMaxHP)
    member.health:reset()
    member.health:processCurrentHealth()
    -- MEGAMOD FIX: member.injury = nil did nothing; clear the real "Injury" state
    -- and bring the member back from the hospital (mirrors vanilla Injury.lua
    -- recoverFromInjury: return to nearest safehouse, then remove the state)
    if member:hasState("Injury") then
        local destinationBuilding = TravelUtils:safeGetNearestSafehouse(member)
        if destinationBuilding then
            local pos, rot = destinationBuilding:getFreeStation(member)
            member:setLocationId(destinationBuilding.interiorLocationId, pos, rot)
        end
        member:removeState("Injury")
    end
end

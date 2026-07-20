--[[------------------------------------------------------------------------------
    MegaMod: "Slippery" Pete Kowalski - The Fence
    A shifty NPC who buys your stolen goods for cash. Payout scales with
    your empire size. Occasional "hot buyer" special deals pay double.
    Cooldown: 7 days between sales.
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: Define the Fence NPC
--------------------------------------------------------------------------------]]
_namespace = "NPC"
_id = "MEGAMOD_FENCE"
_includes = {"NPC.BASE_MISSION_MALE"}

characterIcon = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
characterMugshot = "Sprites/Images/Characters/Profile/Extras/Bureau_Male_01_Profile"
prefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01"
ragdollPrefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Male_01_Ragdoll"

name = "$MEGAMOD_FENCE_fullname" --$ "Slippery" Pete Kowalski
firstName = "$MEGAMOD_FENCE_firstname" --$ Pete
lastName = "$MEGAMOD_FENCE_lastname" --$ Kowalski
profession = "NoProfession"
commands =
{
    Talk = true,
    CivilianAttack = false,
}

--[[------------------------------------------------------------------------------
    Step 2: Spawn event - appears early game
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_FENCE_SPAWN"
_event = "MegaModFenceSpawn"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 150
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    local fence = ActorUtils:spawnActorWithNoLocation("NPC", "NPC.MEGAMOD_FENCE")
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end
    local safehouse = playerFaction:getPrimarySafehouse()
    if not safehouse then return end
    safehouse:enter(fence, "IDLE", true)
    fence.behaviours:add("MegaModFenceBehaviour")

    title("$MEGAMOD_FENCE_arrive_title") --$ A Shady Character
    text("$MEGAMOD_FENCE_arrive_text") --$ A shifty-looking man with a long coat has set up in your safehouse. Says he's "Slippery Pete" and he can move anything -- no questions asked. Says he can find buyers for the extra product your rackets kick out.
    option("$MEGAMOD_FENCE_arrive_option") --$ Could come in handy.
end

--[[------------------------------------------------------------------------------
    Step 3: Fence conversation
    Conversation sandbox: no WorldUtils, no getWorld().
    Data prepared by behaviour is read via 'them' (the NPC actor).

    them.fenceOnCooldown   - boolean, set by behaviour if < 7 days since last sell
    them.hasSpecialDeal    - boolean, 40% chance refreshed periodically
    them.fencePendingSell   - boolean, signals behaviour to start cooldown

    Building count for payout uses you.faction.buildings (available in sandbox).
--------------------------------------------------------------------------------]]
_namespace = "CONVERSATIONS"
_id = "MEGAMOD_FENCE_CONVERSATION"
EntryPoint = "MegaMod_Fence_Start"

-- NOTE: Can't use local function here because local functions can't access
-- namespace globals like 'you' in the CONVERSATIONS sandbox.
-- Payout calculation is inlined in SellGoods() and CheckSpecialDeal() instead.

function onStart()
    go(MainMenu)
end

function MainMenu()
    say("$MEGAMOD_FENCE_greeting") --$ Your rackets always kick out more product than you can use. I know buyers all over the city who'll pay top dollar for the extra. Interested?
        option("$MEGAMOD_FENCE_sell", SellGoods)  --$ What can you get for me?
        option("$MEGAMOD_FENCE_special", CheckSpecialDeal)  --$ Any special deals?
        option("$MEGAMOD_FENCE_leave", Leave)  --$ Not today
end

function SellGoods()
    -- Check cooldown
    if them.fenceOnCooldown then
        say("$MEGAMOD_FENCE_cooldown") --$ I just moved your last batch. Give me a week to find more buyers. Come back later.
                option("$MEGAMOD_FENCE_backtomenu", MainMenu)  --$ Anything else?
            option("$MEGAMOD_FENCE_leave", Leave)  --$ I'll be back
        return
    end

    -- Calculate payout: buildings * 50 + random(50..150), rounded to $100, clamped 100..800
    local buildingCount = 0
    if you.faction.buildings then
        buildingCount = #you.faction.buildings
    end
    local payout = buildingCount * 50 + math.random(50, 150)
    payout = math.floor(payout / 100 + 0.5) * 100
    if payout < 100 then payout = 100 end
    if payout > 800 then payout = 800 end

    them.pendingPayout = payout

    -- Show offer with quoted amount (sandbox can't display dynamic numbers,
    -- so we use per-tier localization keys)
    if payout <= 100 then say("$MEGAMOD_FENCE_offer_100")
    elseif payout <= 200 then say("$MEGAMOD_FENCE_offer_200")
    elseif payout <= 300 then say("$MEGAMOD_FENCE_offer_300")
    elseif payout <= 400 then say("$MEGAMOD_FENCE_offer_400")
    elseif payout <= 500 then say("$MEGAMOD_FENCE_offer_500")
    elseif payout <= 600 then say("$MEGAMOD_FENCE_offer_600")
    elseif payout <= 700 then say("$MEGAMOD_FENCE_offer_700")
    else say("$MEGAMOD_FENCE_offer_800")
    end
    option("$MEGAMOD_FENCE_sell_yes", DoSell) --$ Make the deal
    option("$MEGAMOD_FENCE_sell_no", MainMenu) --$ Let me think about it
end

function DoSell()
    local payout = them.pendingPayout or 100
    them.pendingPayout = nil
    BRScript:PlayerAddCash(payout, "CASH.FENCE_SALE")
    them.fencePendingSell = true
    them.fenceOnCooldown = true
    say("$MEGAMOD_FENCE_sell_done") --$ Done. Your extra product's on its way to my buyers and the cash is yours. Clean as a whistle. Well, clean enough.
    option("$MEGAMOD_FENCE_backtomenu", MainMenu) --$ Anything else?
    option("$MEGAMOD_FENCE_leave", Leave) --$ Pleasure doing business
end

function CheckSpecialDeal()
    if them.fenceOnCooldown then
        say("$MEGAMOD_FENCE_cooldown") --$ I just moved your last batch. Give me a week to find more buyers. Come back later.
                option("$MEGAMOD_FENCE_backtomenu", MainMenu)
            option("$MEGAMOD_FENCE_leave", Leave)
        return
    end

    if not them.hasSpecialDeal then
        say("$MEGAMOD_FENCE_no_special") --$ Nothing special right now. My contacts are keeping their heads down. Check back next time, I might have something cooking.
                option("$MEGAMOD_FENCE_backtomenu", MainMenu)  --$ Anything else?
            option("$MEGAMOD_FENCE_leave", Leave)  --$ I'll be back
        return
    end

    -- Special deal: double the base payout
    local buildingCount = 0
    if you.faction.buildings then
        buildingCount = #you.faction.buildings
    end
    local basePayout = buildingCount * 50 + math.random(50, 150)
    basePayout = math.floor(basePayout / 100 + 0.5) * 100
    if basePayout < 100 then basePayout = 100 end
    if basePayout > 800 then basePayout = 800 end
    local payout = basePayout * 2

    them.pendingPayout = payout

    -- Show special offer with quoted amount (doubled payouts are always multiples of 200)
    if payout <= 200 then say("$MEGAMOD_FENCE_soffer_200")
    elseif payout <= 400 then say("$MEGAMOD_FENCE_soffer_400")
    elseif payout <= 600 then say("$MEGAMOD_FENCE_soffer_600")
    elseif payout <= 800 then say("$MEGAMOD_FENCE_soffer_800")
    elseif payout <= 1000 then say("$MEGAMOD_FENCE_soffer_1000")
    elseif payout <= 1200 then say("$MEGAMOD_FENCE_soffer_1200")
    elseif payout <= 1400 then say("$MEGAMOD_FENCE_soffer_1400")
    else say("$MEGAMOD_FENCE_soffer_1600")
    end
    option("$MEGAMOD_FENCE_special_yes", DoSpecialSell) --$ Take the special deal
    option("$MEGAMOD_FENCE_special_no", MainMenu) --$ Not right now
end

function DoSpecialSell()
    local payout = them.pendingPayout or 200
    them.pendingPayout = nil
    BRScript:PlayerAddCash(payout, "CASH.FENCE_SALE")
    them.fencePendingSell = true
    them.fenceOnCooldown = true
    them.hasSpecialDeal = false
    say("$MEGAMOD_FENCE_special_done") --$ Beautiful. My buyer is thrilled, you're flush with cash, and I get my cut. Everybody wins. Well, everybody except whoever you stole all that from.
    option("$MEGAMOD_FENCE_backtomenu", MainMenu) --$ Anything else?
    option("$MEGAMOD_FENCE_leave", Leave) --$ Pleasure doing business
end

function Leave()
    say("$MEGAMOD_FENCE_goodbye") --$ You know where to find me.
    endConversation()
end

--[[------------------------------------------------------------------------------
    Step 4: Fence behaviour
    - Sets conversation entry point
    - Periodically refreshes special deal availability (40% chance)
    - Manages 7-day cooldown between sales
    WorldUtils IS available in behaviours.
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MEGAMOD_FENCE_BEHAVIOUR"
_name = "MegaModFenceBehaviour"

function onAdd()
    thisActor:setConversationEntryPoint("MegaMod_Fence_Start")
    -- Initialize special deal on spawn
    thisActor.hasSpecialDeal = math.random() < 0.4
    thisActor.fenceOnCooldown = false
end

function GameEvent.onDayBegin(e)
    -- If a sell happened, record the cooldown timestamp
    if thisActor.fencePendingSell and not thisActor.fenceSellTimestamp then
        thisActor.fencePendingSell = nil
        thisActor.fenceSellTimestamp = client.time.worldTime
    end

    -- Check if cooldown has expired (7 days)
    if thisActor.fenceSellTimestamp then
        local elapsed = client.time.worldTime - thisActor.fenceSellTimestamp
        if elapsed >= (7 * 24 * 60 * 60) then
            thisActor.fenceOnCooldown = false
            thisActor.fenceSellTimestamp = nil
            thisActor.hasSpecialDeal = math.random() < 0.4
        end
    end

    -- Small daily chance to gain a special deal if not on cooldown
    if not thisActor.fenceOnCooldown and not thisActor.hasSpecialDeal then
        if math.random() < 0.15 then
            thisActor.hasSpecialDeal = true
        end
    end
end

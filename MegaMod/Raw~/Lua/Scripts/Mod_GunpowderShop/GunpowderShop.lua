--[[------------------------------------------------------------------------------
    Welcome! In this modding tutorial we're going to learn how to:
    - Set up a character to spawn
    - Create a world event that will spawn the character
    - Add a shop to the character
    - Create a unique behaviour on the character
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
    Step 1: First off lets make our Gunpowder Trader Config.
    Since we're in the scripts folder we can declare a number of scripts in this same file, and configs can be written as scripts.
--------------------------------------------------------------------------------]]
_namespace = "NPC" -- The namespace for all NPC configs
_id = "GARRY_THE_GUNPOWDER_TRADER" -- Our full configId now will be NPC.GARRY_THE_GUNPOWDER_TRADER
_includes = {"NPC.BASE_MALE", "CHARACTER.COMBAT_BRAIN_BASE"} -- Some boilerplate configs to 'include' (kind of like inheriting, we copy in all of those scripts data)

characterIcon = "Sprites/Images/Characters/Profile/Guards/Tier5/Guard_04_Tier5_Demolitionist_Profile" -- The round portrait seen in places like the combat queue
characterFullbody = "Sprites/Images/Characters/FullBody/Extras/CharacterSheet_Male_Pose" -- The full body portrait seen in the character's inventory
prefab = "Models/Characters/Extras/Guards/Tier5/Prefabs/Guard_04_Tier5_Demolitionist" -- The model to use
ragdollPrefab = "Models/Characters/Extras/Guards/Tier5/Prefabs/Guard_04_Tier5_Demolitionist_Ragdoll" -- The ragdoll to use when dying

-- New strings for his name:
name = "$Mod_GunpowderShop_Gary_Fullname" --$ Gary 'Bomb-maker' Powderman
firstName = "$Mod_GunpowderShop_Gary_Firstname" --$ Gary
lastName = "$Mod_GunpowderShop_Gary_Lastname" --$ Powderman

profession = "Demolitionist" -- Makes sense, if he's selling explosives
commands =
{
    Shop = true, -- Most important. The command wheel action to "Shop"
    CivilianAttack = false, -- I want to get rid of this from the included config so setting to false.
}

--[[------------------------------------------------------------------------------
    Step 2: Lets spawn him in the game.
    Since we're still in the scripts folder, we can start a new script just by declaring an _id or changing to a new _namespace.
    We're going to make a world event that spawns Gary
--------------------------------------------------------------------------------]]
_namespace = "WORLD_EVENTS"
_id = "MOD_GUNPOWDER_SHOP_SPAWN_GARY"
_event = "ModGunpowderShop_SpawnGary" -- Unique name, like the id, but is used to track events.
_gameStage = "Bridging" -- At what game stage do we trigger this event? (Bridging, Early, Mid, Late..etc)
_autoStartMode = "Schedule" -- How soon in the stage do we trigger this event? (Create or Schedule, where you would also add a delay)
_triggerDelay = 10 -- Spawn him 10 seconds after starting the Early stage
_category = "Misc" -- Don't really need a category for this, lets use "Misc"

function canTrigger()
    return true -- Here's where the game will check before triggering the event in case we're waiting for anything, we're not so lets just return true
end

-- Lets spawn Gary when this event triggers
function onTrigger()
    -- These are our parameters for the spawn function
    local actorClass = "NPC"
    local configId = "NPC.GARRY_THE_GUNPOWDER_TRADER"
    local chinatown = WorldUtils:getExteriorLocation("neighborhood_04") -- Chinatown
    local locationId = chinatown.id -- Need the location id for the spawnActor function

    -- These next two params I got from the debug panel when moving the camera to this spot.
    local spawnPosition = Vector3(-244.55, 0, -849.9)
    local spawnRotation = 197 -- degrees, a little more than 180

    -- And we spawn him!
    local gary = ActorUtils:spawnActor(actorClass, configId, locationId, spawnPosition, spawnRotation)
    -- Now lets add a shop to gary.
    WorldUtils:mixinShopToActor(gary, "STORES.MOD_GUNPOWDER_SHOP")
    -- And a behaviour that I'll explain in a second
    gary.behaviours:add("ModGunpowderShopResupply")
    -- But wait, we don't have a shop yet..? That brings us to...
end

--[[------------------------------------------------------------------------------
    Step 3: Lets make a shop.
    Still in the scripts folder, lets switch _namespace.
--------------------------------------------------------------------------------]]
_namespace = "STORES"
_id = "MOD_GUNPOWDER_SHOP"
-- These are used on the shop screen:
name = "$Mod_GunpowderShop_GarysShop" --$ The Gunpowder Shop
resupplyFrequency = 21 -- Number of days shown until resupply

-- And that's it.
-- Right now the shop resupply functionality is a little bit hardcoded, so we're going to make our own custom one.

--[[------------------------------------------------------------------------------
    Step 4: Lets make a resupply behaviour on Gary. (This is the behaviour we added in the world event when spawning gary)
    Switch _namespace again!
--------------------------------------------------------------------------------]]
_namespace = "BEHAVIOURS"
_id = "MOD_GUNPOWDER_SHOP_RESUPPLY"
_name = "ModGunpowderShopResupply" -- This is used so we can add the behaviour like we did above, else we'd use the whole configId

persist{} -- This means we're saving 'daysUntilResupply' when the game saves. In scripts this is all you need to do to save/load data!
daysUntilResupply = 21

-- These are the item ids we're going to be resupplying with. We don't need to save these cause they won't change.
explosiveIdsToAdd =
{
    "ITEM.WEAPON.EXPLOSIVE_01",
    "ITEM.WEAPON.EXPLOSIVE_02",
    "ITEM.WEAPON.EXPLOSIVE_03",
    "ITEM.WEAPON.EXPLOSIVE_04",
    "ITEM.WEAPON.EXPLOSIVE_05",
}

function resupply()
    local shop = thisActor.store -- thisActor is the actor this behaviour is on, in our case, Gary.
    shop.stock = {} -- This is a small workaround for the way we're manually resupplying
    for i = 1, #explosiveIdsToAdd do
        -- Lets add 3 of each explosive to the shop
        local explosiveId = explosiveIdsToAdd[i]
        local explosive = Utils:createNewItem(explosiveId)
        -- We're fine to add the same item multiple times
        for _ = 1, 3 do
            shop:addToStock(explosive)
        end
    end
end

-- First off, we want to resupply as soon as the shop is set up.
function onAdd() -- This function automatically gets called when a behaviour is added to an actor
    resupply()
    daysUntilResupply = 21
end

-- The one hacky bit we're doing, but hey, its modding!
function onActivate() -- This function gets called both on adding and loading the behaviour
    -- Overwriting the refresh function with an empty function since we're handling it ourselves
    thisActor.store.refresh = function() end
end

-- Finally we want to be able to count down our day tracker every day.
-- This function will call every time the GameEvent 'onDayBegin' fires.
function GameEvent.onDayBegin(e)
    daysUntilResupply = daysUntilResupply - 1
    if daysUntilResupply <= 0 then
        resupply()
        daysUntilResupply = 21
    end
end
-- Note: not all scripts will automatically register events. Behaviours are one of the most powerful scripts for this kind of functionality.

-- And that's it! All you need to make an in-game character with a unique shop.

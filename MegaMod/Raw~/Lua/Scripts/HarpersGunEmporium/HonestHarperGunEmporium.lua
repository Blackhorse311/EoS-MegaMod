
--[[------------------------------------------------------------------------------
    Step 1: First off lets make our Honest Harper character!
    Since we're in the scripts folder we can declare a number of scripts in this same file, and configs can be written as scripts.
--------------------------------------------------------------------------------]]

_namespace = "NPC" -- The namespace for all NPC configs
_id = "HONEST_HARPER" -- Our full configId now will be NPC.HONEST_HARPER
_includes = {"NPC.BASE_FEMALE", "CHARACTER.COMBAT_BRAIN_BASE"} -- Some boilerplate configs to 'include' (kind of like inheriting, we copy in all of those scripts data)
characterIcon = "Sprites/Images/Characters/Profile/Extras/Bureau_Female_02_Profile" -- The round portrait seen in places like the combat queue
characterFullbody = "Sprites/Images/Characters/FullBody/Extras/CharacterSheet_Female_Pose" -- The full body portrait seen in the character's inventory
prefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Female_02" --
ragdollPrefab = "Models/Characters/Extras/Bureau/Prefabs/Bureau_Female_02_Ragdoll" -- The ragdoll to use when dying

-- New strings for her name:
name = "$Mod_Honest_Harper_Fullname" --$ Honest Harper
firstName = "$Mod_GunEmporium_Harper_Firstname" --$ Honest
lastName = "$Mod_GunEmporium_Harper_Lastname" --$ Harper
profession = "HiredGun" -- Makes sense, if she's selling guns
commands =
{
    Shop = true, -- Most important. The command wheel action to "Shop"
    CivilianAttack = false, -- I want to get rid of this from the included config so setting to false.
}

--[[------------------------------------------------------------------------------
    Step 2: Lets spawn her in the game.
    Since we're still in the scripts folder, we can start a new script just by declaring an _id or changing to a new _namespace.
    We're going to make a world event that spawns Honest Harper
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"
_id = "MOD_GUN_EMPORIUM_SPAWN"
_event = "ModGunEmporium_SpawnHarper" -- Unique name, like the id, but is used to track events.
_gameStage = "Bridging" -- At what game stage do we trigger this event? (Bridging, Early, Mid, Late..etc)
_autoStartMode = "Schedule" -- How soon in the stage do we trigger this event? (Create or Schedule, where you would also add a delay)
_triggerDelay = 10 -- Spawn her 10 seconds after starting the Bridging stage
_category = "Misc" -- Don't really need a category for this, lets use "Misc"


function canTrigger()
    return true -- Here's where the game will check before triggering the event in case we're waiting for anything, we're not so lets just return true
end
-- Lets spawn Harper when this event triggers
function onTrigger()
    print("Spawning Harper")
    -- These are our parameters for the spawn function
    local actorClass = "NPC"
    local configId = "NPC.HONEST_HARPER"
    -- And we spawn her!
    local harper = ActorUtils:spawnActorWithNoLocation(actorClass, configId)
    -- The actor you want to spawn in your interior
    local playerFaction = WorldUtils:getPlayerFaction()
    -- Reference safehouse so that we can grab the player's safehouse and not a safehouse tied to another faction
    local safehouse = playerFaction:getPrimarySafehouse()
    -- This will spawn our Harper NPC inside the Safehouse at an idle station
    safehouse:enter(harper, "IDLE", true)
    -- IDLE is a reference to the tag on the station and the TRUE is to ensure that our Harper NPC has an exclusive station to spawn on.
    WorldUtils:mixinShopToActor(harper, "STORES.MOD_GUN_EMPORIUM")
    -- And a behaviour that I'll explain in a second
    harper.behaviours:add("ModGunEmporiumResupply")
    -- But wait, we don't have a shop yet..? That brings us to...

end

--[[------------------------------------------------------------------------------
    Step 3: Lets make a shop.
    Still in the scripts folder, lets switch _namespace.
--------------------------------------------------------------------------------]]
_namespace = "STORES"
_id = "MOD_GUN_EMPORIUM"
-- These are used on the shop screen:
name = "$Mod_Harpers_GunEmporium" --$ Harper's Gun Emporium
-- And that's it.

-- And that's it! All you need to make an in-game character with a unique shop.

--[[------------------------------------------------------------------------------
    Step 4: Lets make a resupply behaviour on Harper. (This is the behaviour we added in the world event when spawning Harper)
    Switch _namespace again!
--------------------------------------------------------------------------------]]

_namespace = "BEHAVIOURS"
_id = "MOD_GUN_EMPORIUM_RESUPPLY"
_name = "ModGunEmporiumResupply" -- This is used so we can add the behaviour like we did above, else we'd use the whole configId
-- These are the item ids we're going to be resupplying with. We don't need to save these cause they won't change.

gunIdsToAdd = -- Add the weapons IDs to the store so that they appear for sale.
{
    "ITEM.WEAPON.UNIQUE_HARPER_HANDGUN_01",
    "ITEM.WEAPON.UNIQUE_HARPER_SHOTGUN_01",
    "ITEM.WEAPON.UNIQUE_HARPER_RIFLE_01",
}

-- First off, we want to resupply as soon as the shop is set up.
function onAdd() -- This function automatically gets called when a behaviour is added to an actor
    local shop = thisActor.store -- thisActor is the actor this behaviour is on, in our case, Harper.
    shop.refresh = function() end -- Stops the store from attempting to refesh its stock and wipe the store inventory.
    shop.stock = {} -- This is a small workaround for the way we're manually resupplying
    for i = 1, #gunIdsToAdd do
        -- This makes sure that there is only ever 1 of each gun in our store.
        local gunId = gunIdsToAdd[i]
        local gun = Utils:createNewItem(gunId)
        -- We're fine to add the same item multiple times
        shop:addToStock(gun)
        -- Add 1 of each gun to the stores stock
    end
end


--[[------------------------------------------------------------------------------
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    Honest Harper's Unique Weapons Tutorial

<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--------------------------------------------------------------------------------]]

_namespace = "ITEM.WEAPON" -- Setup a new namespace for your new weapons

--[[------------------------------------------------------------------------------
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    BRIMSTONE REVOLVER DATA

<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
BRIMSTONE REVOLVER - DATA
--------------------------------------------------------------------------------]]
_id = "UNIQUE_HARPER_HANDGUN_01" -- The base ID for the weapon. This is used to spawn and attach the weapon to the game world. Each weapon ID must be unique.
_includes = {"ITEM.WEAPON.HAND_GUN"} -- An inclusion that adds base attributes from a base class for all handguns. Each category of weapon has a base.
inventoryTooltip = desc

--[[------------------------------------------------------------------------------
BRIMSTONE REVOLVER - STRINGS
--------------------------------------------------------------------------------]]
name = "$WEAPON_STATS_UNIQUE_HARPER_HANDGUN_01_name" --$ Brimstone Revolver
imageCaption = "$UNIQUE_HARPER_HANDGUN_01_WeaponImageCaption"  --$ Brimstone Revolver
modifierName = "$WEAPON_STATS_UNIQUE_HARPER_HANDGUN_01_modifierName" --$ Brimstone Revolver
desc = "$WEAPON_STATS_UNIQUE_HARPER_HANDGUN_01_desc" --$ The handle is faintly warm to touch and there's a distinctive smell of sulfur emanating from the barrel.

--[[------------------------------------------------------------------------------
BRIMSTONE REVOLVER - BASE STATS
--------------------------------------------------------------------------------]]
item = {}
item.rarity = "Unique" -- What rarity of weapon it is.
item.type = "Handgun" -- States which category of weapon this weapon belongs to.
item.slotType = "Secondary" -- Controls which slot on the character sheet that this weapon will occupy
animatorBool = "Weapon_HANDGUN_01" -- Signifies the animation group that this weapon belongs to. Each weapon group uses a custom animatorBool

minDamage = 20 -- The minimum amount of damage that this weapon will deal
maxDamage = 32 -- The maximum amount of damage that this weapon will deal
baseCritChance = 30 -- The % chance for a shot from this weapon to be a critical hit.
critMod = 150 -- The crit damage modifier. Controls hoe much critical damage this weapon deals when it scores a critical hit. 100% = Base Weapon Damage. So it much be a value great than 100.
actionCost = 1 -- How many AP does this weapon cost to fire
clipSize = 6 -- How many rounds are in this weapons clip
ammoPerShot = 1 -- How many rounds are consumed when this weapon fires

burstFire = 3 -- Adjusts the number of rounds a weapon can fire in a single attack.
burstFireMarksmanshipPenalty = -10 -- Adjusts the marksmanship penalty for burstfire weapons.

range = "CLOSE" -- Defines which range table a weapon will use. These can be found @ WeaponRanges.lua. Feel free to tweak and adjust weapon ranges based on your own preferences.
Modifier.overwatchAngle = function() return 60, modifierName end -- Controls the width of the Overwatch cone when a character equipped with this weapon uses the Overwatch ability.
Modifier.overwatchRange = function() return 10, modifierName end -- Controls the range of the Overwatch cone when a character equipped with this weapon uses the Overwatch ability.

score = 415 -- This score is used for auto-resolve calculations and Faction AI calculations when creating squads.
price = 6255 -- The purchase price of the weapon if it were to appear rin a vendor. Note: Sale prices are always a fraction of the purchase price.

--[[------------------------------------------------------------------------------
BRIMSTONE REVOLVER - Modifiers
--------------------------------------------------------------------------------]]
-- Below are a number of modifiers that can be used to give a weapon a unique perk. Most of them are commented out, so they are being used right now, but I'm using the knockback modifier in this example,

-- Modifier.Poisoned = function() return 15, modifierName end
-- Modifier.Slow = function() return 25, modifierName end
-- Modifier.marksmanship = function() return 10, modifierName end
Modifier.knockBackChance = function() return 100, modifierName end -- The 100 value you see listed here is the chance for this modifier to trigger whenever a shot hits a target. Right now this is set to 100%.
-- Modifier.Bleeding = function() return 25, modifierName end

--[[------------------------------------------------------------------------------
BRIMSTONE REVOLVER - AUDIO -- Controls the sounds for the weapon.
--------------------------------------------------------------------------------]]
audio =
{
    onFire = { "AUDIO.COMBAT.LP08_PISTOL_SHOT_1", "AUDIO.COMBAT.LP08_PISTOL_SHOT_2", "AUDIO.COMBAT.LP08_PISTOL_SHOT_3", "AUDIO.COMBAT.LP08_PISTOL_SHOT_4", },
    onBurstFire = "AUDIO.COMBAT.LP08_PISTOL_BURST",
    onReload = { "AUDIO.COMBAT.LP08_PISTOL_RELOAD_1", "AUDIO.COMBAT.LP08_PISTOL_RELOAD_2", },
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}
--[[------------------------------------------------------------------------------
BRIMSTONE REVOLVER - VISUAL -- Controls the visual elements for the weapon.
--------------------------------------------------------------------------------]]
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultNewService"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultNewService"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_CultNewService"
combatAbility = {"GeneralBurstFire", "PistolDoubleShot"} -- Adding burst fire action to the action bar instead of standard fire action.

--[[------------------------------------------------------------------------------
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    CROOKED TOOTH SHOTGUN DATA

<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
CROOKED TOOTH - DATA
--------------------------------------------------------------------------------]]
_id = "UNIQUE_HARPER_SHOTGUN_01" -- The base ID for the weapon. This is used to spawn and attach the weapon to the game world. Each weapon ID must be unique.
_includes = {"ITEM.WEAPON.SHOTGUN"} -- An inclusion that adds base attributes from a base class for all shotguns. Each category of weapon has a base.
inventoryTooltip = desc

--[[------------------------------------------------------------------------------
CROOKED TOOTH - STRINGS
--------------------------------------------------------------------------------]]
name = "$WEAPON_STATS_UNIQUE_HARPER_SHOTGUN_01_name" --$ Crooked Tooth Shotgun
imageCaption = "$UNIQUE_HARPER_SHOTGUN_01_WeaponImageCaption"  --$ Crooked Tooth Shotgun
modifierName = "$WEAPON_STATS_UNIQUE_HARPER_SHOTGUN_01_modifierName" --$ Crooked Tooth Shotgun
desc = "$WEAPON_STATS_UNIQUE_HARPER_SHOTGUN_01_desc" --$ This beast kicks so hard that an ornery mule would be proud.

--[[------------------------------------------------------------------------------
CROOKED TOOTH - BASE STATS
--------------------------------------------------------------------------------]]
item = {}
item.rarity = "Unique" -- What rarity of weapon it is.
item.type = "Shotgun" -- States which category of weapon this weapon belongs to.
item.slotType = "Primary" -- Controls which slot on the character sheet that this weapon will occupy
animatorBool = "Weapon_SHOTGUN_02" -- Signifies the animation group that this weapon belongs to. Each weapon group uses a custom animatorBool

minDamage = 10 -- The minimum amount of damage that this weapon will deal
maxDamage = 40 -- The maximum amount of damage that this weapon will deal
baseCritChance = 15 -- The % chance for a shot from this weapon to be a critical hit.
critMod = 160 -- The crit damage modifier. Controls hoe much critical damage this weapon deals when it scores a critical hit. 100% = Base Weapon Damage. So it much be a value great than 100.
actionCost = 1 -- How many AP does this weapon cost to fire
clipSize = 6 -- How many rounds are in this weapons clip
ammoPerShot = 1 -- How many rounds are consumed when this weapon fires

range = "POINTBLANK_SHOTGUN" -- Defines which range table a weapon will use. These can be found @ WeaponRanges.lua. Feel free to tweak and adjust weapon ranges based on your own preferences.
Modifier.overwatchAngle = function() return 20, modifierName end -- Controls the width of the Overwatch cone when a character equipped with this weapon uses the Overwatch ability.
Modifier.overwatchRange = function() return 20, modifierName end -- Controls the range of the Overwatch cone when a character equipped with this weapon uses the Overwatch ability.

score = 565 -- This score is used for auto-resolve calculations and Faction AI calculations when creating squads.
price = 7000 -- The purchase price of the weapon if it were to appear rin a vendor. Note: Sale prices are always a fraction of the purchase price.

--[[------------------------------------------------------------------------------
CROOKED TOOTH - Modifiers
--------------------------------------------------------------------------------]]
-- Below are a number of modifiers that can be used to give a weapon a unique perk. Most of them are commented out, so they are being used right now, but I'm using the knockback modifier in this example,

-- Modifier.Poisoned = function() return 15, modifierName end
-- Modifier.Slow = function() return 25, modifierName end
-- Modifier.marksmanship = function() return 10, modifierName end
-- Modifier.knockBackChance = function() return 100, modifierName end
Modifier.Bleeding = function() return 100, modifierName end -- The 100 value you see listed here is the chance for this modifier to trigger whenever a shot hits a target. Right now this is set to 100%.
Modifier.damageReduction = function() return 20, modifierName end

--[[------------------------------------------------------------------------------
CROOKED TOOTH - AUDIO -- Controls the sounds for the weapon.
--------------------------------------------------------------------------------]]
audio =
{
    onFire = { "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_1", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_2", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_3", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_4", },
    onReload = "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}
--[[------------------------------------------------------------------------------
CROOKED TOOTH - VISUAL -- Controls the visual elements for the weapon.
--------------------------------------------------------------------------------]]
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel1897"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel1897"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Shotgun_WinstonModel1897"

--[[------------------------------------------------------------------------------
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    DISPATCH RIFLE DATA

<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--------------------------------------------------------------------------------]]

--[[------------------------------------------------------------------------------
DISPATCH RIFLE - DATA
--------------------------------------------------------------------------------]]
_id = "UNIQUE_HARPER_RIFLE_01" -- The base ID for the weapon. This is used to spawn and attach the weapon to the game world. Each weapon ID must be unique.
_includes = {"ITEM.WEAPON.RIFLE"} -- An inclusion that adds base attributes from a base class for all Rifles. Each category of weapon has a base.
inventoryTooltip = desc

--[[------------------------------------------------------------------------------
DISPATCH RIFLE - STRINGS
--------------------------------------------------------------------------------]]
name = "$WEAPON_STATS_UNIQUE_HARPER_RIFLE_01_name" --$ Dispatch Rifle
imageCaption = "$UNIQUE_HARPER_RIFLE_01_WeaponImageCaption"  --$ Dispatch Rifle
modifierName = "$WEAPON_STATS_UNIQUE_HARPER_RIFLE_01_modifierName" --$ Dispatch Rifle
desc = "$WEAPON_STATS_UNIQUE_HARPER_RIFLE_01_desc" --$ This Dispatch Rifle is said to have sent many final regards.

--[[------------------------------------------------------------------------------
DISPATCH RIFLE - BASE STATS
--------------------------------------------------------------------------------]]
item = {}
item.rarity = "Unique" -- What rarity of weapon it is.
item.type = "Rifle" -- States which category of weapon this weapon belongs to.
item.slotType = "Primary" -- Controls which slot on the character sheet that this weapon will occupy
animatorBool = "Weapon_RIFLE_02" -- Signifies the animation group that this weapon belongs to. Each weapon group uses a custom animatorBool

minDamage = 52 -- The minimum amount of damage that this weapon will deal
maxDamage = 68 -- The maximum amount of damage that this weapon will deal
baseCritChance = 30 -- The % chance for a shot from this weapon to be a critical hit.
critMod = 140 -- The crit damage modifier. Controls hoe much critical damage this weapon deals when it scores a critical hit. 100% = Base Weapon Damage. So it much be a value great than 100.
actionCost = 1 -- How many AP does this weapon cost to fire
clipSize = 20 -- How many rounds are in this weapons clip
ammoPerShot = 1 -- How many rounds are consumed when this weapon fires

range = "MEDIUM" -- Defines which range table a weapon will use. These can be found @ WeaponRanges.lua. Feel free to tweak and adjust weapon ranges based on your own preferences.
Modifier.overwatchAngle = function() return 60, modifierName end -- Controls the width of the Overwatch cone when a character equipped with this weapon uses the Overwatch ability.
Modifier.overwatchRange = function() return 10, modifierName end -- Controls the range of the Overwatch cone when a character equipped with this weapon uses the Overwatch ability.

score = 765 -- This score is used for auto-resolve calculations and Faction AI calculations when creating squads.
price = 11025 -- The purchase price of the weapon if it were to appear rin a vendor. Note: Sale prices are always a fraction of the purchase price.

--[[------------------------------------------------------------------------------
DISPATCH RIFLE - Modifiers
--------------------------------------------------------------------------------]]
-- Below are a number of modifiers that can be used to give a weapon a unique perk. Most of them are commented out, so they are being used right now, but I'm using the knockback modifier in this example,

-- Modifier.Poisoned = function() return 15, modifierName end
-- Modifier.Slow = function() return 25, modifierName end
-- Modifier.marksmanship = function() return 10, modifierName end
-- Modifier.knockBackChance = function() return 20, modifierName end
-- Modifier.Bleeding = function() return 20, modifierName end
Modifier.ignoreArmorChance = function() return 100, modifierName end -- The 100 value you see listed here is the chance for this modifier to trigger whenever a shot hits a target. Right now this is set to 100%.
Modifier.injuryChance = function() return -100, modifierName end -- The -100 value you see here means that you can now never be injured regardless of how much damage you receive.

--[[------------------------------------------------------------------------------
DISPATCH RIFLE - AUDIO -- Controls the sounds for the weapon.
--------------------------------------------------------------------------------]]
audio =
{
    onFire = { "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_1", "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_2", "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_3", "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_4", },
    onReload = "AUDIO.COMBAT.FAR_HILL_RIFLE_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}
--[[------------------------------------------------------------------------------
DISPATCH RIFLE - VISUAL -- Controls the visual elements for the weapon.
--------------------------------------------------------------------------------]]
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_FarquharHillRifle"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_FarquharHillRifle"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Rifle_FarquharHillRifle"
combatAbility = "GeneralBurstFire"
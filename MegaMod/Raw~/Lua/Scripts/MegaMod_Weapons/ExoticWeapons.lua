--[[------------------------------------------------------------------------------
    MegaMod: Exotic Weapons
    6 period-appropriate exotic weapons available in the black market
--------------------------------------------------------------------------------]]

_namespace = "ITEM.WEAPON"

--[[------------------------------------------------------------------------------
    SAWED-OFF SPECIAL - Close range devastation
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_EXOTIC_SAWEDOFF"
_includes = {"ITEM.WEAPON.SHOTGUN"}
inventoryTooltip = desc

name = "$MEGAMOD_EXOTIC_SAWEDOFF_name" --$ Sawed-Off Special
imageCaption = "$MEGAMOD_EXOTIC_SAWEDOFF_caption" --$ Sawed-Off Special
modifierName = "$MEGAMOD_EXOTIC_SAWEDOFF_modifierName" --$ Sawed-Off Special
desc = "$MEGAMOD_EXOTIC_SAWEDOFF_desc" --$ A shotgun with its barrel crudely hacked short. What it loses in range it makes up for in sheer close-quarters terror. The spread is so wide you could clear a room without aiming.

item = {}
item.rarity = "Epic"
item.type = "Shotgun"
item.slotType = "Primary"
animatorBool = "Weapon_SHOTGUN_01"

minDamage = 18
maxDamage = 52
baseCritChance = 12
critMod = 170
actionCost = 1
clipSize = 2
ammoPerShot = 1

range = "POINTBLANK_SHOTGUN"
Modifier.overwatchAngle = function() return 40, modifierName end
Modifier.overwatchRange = function() return 6, modifierName end
Modifier.knockBackChance = function() return 75, modifierName end

score = 480
price = 5500

audio =
{
    onFire = "AUDIO.COMBAT.SHOTGUN_SHOT",
    onReload = "AUDIO.COMBAT.SHOTGUN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_ShortBarreled"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_ShortBarreled"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Shotgun_ShortBarreled"

--[[------------------------------------------------------------------------------
    POCKET DERRINGER - Concealed high-crit sidearm
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_EXOTIC_DERRINGER"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_EXOTIC_DERRINGER_name" --$ Pocket Derringer
imageCaption = "$MEGAMOD_EXOTIC_DERRINGER_caption" --$ Pocket Derringer
modifierName = "$MEGAMOD_EXOTIC_DERRINGER_modifierName" --$ Pocket Derringer
desc = "$MEGAMOD_EXOTIC_DERRINGER_desc" --$ A tiny two-shot pistol that fits in a vest pocket. Favored by gamblers and ladies of the evening, the Derringer is the ultimate last resort. Two shots is all you get, so make them count.

item = {}
item.rarity = "Rare"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_01"

minDamage = 28
maxDamage = 38
baseCritChance = 40
critMod = 200
actionCost = 1
clipSize = 2
ammoPerShot = 1

range = "POINTBLANK"
Modifier.overwatchAngle = function() return 30, modifierName end
Modifier.overwatchRange = function() return 6, modifierName end

score = 350
price = 3800

audio =
{
    onFire = "AUDIO.COMBAT.CULT_SINGLE_SHOT",
    onReload = "AUDIO.COMBAT.REVOLVER_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_SW38"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_SW38"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_SW38"

--[[------------------------------------------------------------------------------
    STREET HOWITZER - Double-barreled beast
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_EXOTIC_HOWITZER"
_includes = {"ITEM.WEAPON.SHOTGUN"}
inventoryTooltip = desc

name = "$MEGAMOD_EXOTIC_HOWITZER_name" --$ Street Howitzer
imageCaption = "$MEGAMOD_EXOTIC_HOWITZER_caption" --$ Street Howitzer
modifierName = "$MEGAMOD_EXOTIC_HOWITZER_modifierName" --$ Street Howitzer
desc = "$MEGAMOD_EXOTIC_HOWITZER_desc" --$ A reinforced double-barrel shotgun loaded with heavy slugs. It kicks like a mule and hits like a freight train. One blast and whatever was standing in front of you isn't anymore.

item = {}
item.rarity = "Epic"
item.type = "Shotgun"
item.slotType = "Primary"
animatorBool = "Weapon_SHOTGUN_02"

minDamage = 25
maxDamage = 60
baseCritChance = 10
critMod = 180
actionCost = 1
clipSize = 4
ammoPerShot = 2

range = "CLOSE_SHOTGUN"
Modifier.overwatchAngle = function() return 30, modifierName end
Modifier.overwatchRange = function() return 8, modifierName end
Modifier.knockBackChance = function() return 100, modifierName end

score = 550
price = 7200

audio =
{
    onFire = "AUDIO.COMBAT.SHOTGUN_SHOT",
    onReload = "AUDIO.COMBAT.SHOTGUN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_Remmy10"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_Remmy10"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Shotgun_Remmy10"

--[[------------------------------------------------------------------------------
    WHIPPET GUN - Compact, fast-firing SMG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_EXOTIC_WHIPPET"
_includes = {"ITEM.WEAPON.SUB_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_EXOTIC_WHIPPET_name" --$ Whippet Gun
imageCaption = "$MEGAMOD_EXOTIC_WHIPPET_caption" --$ Whippet Gun
modifierName = "$MEGAMOD_EXOTIC_WHIPPET_modifierName" --$ Whippet Gun
desc = "$MEGAMOD_EXOTIC_WHIPPET_desc" --$ A cut-down submachine gun small enough to hide under a coat. It rattles off rounds so fast the barrel glows red. Low damage per hit, but when you're putting that much lead in the air, accuracy is optional.

item = {}
item.rarity = "Rare"
item.type = "SubGun"
item.slotType = "Primary"
animatorBool = "Weapon_SUBGUN_01"

minDamage = 8
maxDamage = 14
baseCritChance = 8
critMod = 130
actionCost = 1
clipSize = 30
ammoPerShot = 1

burstFire = 5
burstFireMarksmanshipPenalty = -15

range = "CLOSE"
Modifier.overwatchAngle = function() return 60, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end

score = 420
price = 4800

audio =
{
    onFire = "AUDIO.COMBAT.SUBMACHINE_BURST",
    onReload = "AUDIO.COMBAT.TOMMY_GUN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_SubmachineGun_OVP1918"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_SubmachineGun_OVP1918"
prefab = "Models/Items/Weapons/Prefabs/Weapon_SubmachineGun_OVP1918"
combatAbility = "GeneralBurstFire"

--[[------------------------------------------------------------------------------
    MARE'S LEG - Cut-down lever-action rifle
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_EXOTIC_MARESLEG"
_includes = {"ITEM.WEAPON.RIFLE"}
inventoryTooltip = desc

name = "$MEGAMOD_EXOTIC_MARESLEG_name" --$ Mare's Leg
imageCaption = "$MEGAMOD_EXOTIC_MARESLEG_caption" --$ Mare's Leg
modifierName = "$MEGAMOD_EXOTIC_MARESLEG_modifierName" --$ Mare's Leg
desc = "$MEGAMOD_EXOTIC_MARESLEG_desc" --$ A lever-action rifle with the stock and barrel chopped down to pistol size. Fast to draw, easy to handle in tight spaces, and still packs the punch of a full rifle round. A favorite of bounty hunters and stagecoach guards.

item = {}
item.rarity = "Rare"
item.type = "Rifle"
item.slotType = "Primary"
animatorBool = "Weapon_RIFLE_01"

minDamage = 30
maxDamage = 45
baseCritChance = 18
critMod = 150
actionCost = 1
clipSize = 6
ammoPerShot = 1

range = "CLOSE"
Modifier.overwatchAngle = function() return 45, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end

score = 400
price = 4200

audio =
{
    onFire = "AUDIO.COMBAT.SM99_SHOT",
    onReload = "AUDIO.COMBAT.SM99_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_Salvage99"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_Salvage99"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Rifle_Salvage99"

--[[------------------------------------------------------------------------------
    TRENCH RAIDER - Military burst-fire pistol
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_EXOTIC_TRENCHRAIDER"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_EXOTIC_TRENCHRAIDER_name" --$ Trench Raider
imageCaption = "$MEGAMOD_EXOTIC_TRENCHRAIDER_caption" --$ Trench Raider
modifierName = "$MEGAMOD_EXOTIC_TRENCHRAIDER_modifierName" --$ Trench Raider
desc = "$MEGAMOD_EXOTIC_TRENCHRAIDER_desc" --$ A modified military pistol with a hair trigger and extended magazine. Veterans brought these back from the trenches of the Great War, and the ones who kept them tend to sleep with one eye open. Double-tap capability makes it lethal up close.

item = {}
item.rarity = "Epic"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_03"

minDamage = 18
maxDamage = 26
baseCritChance = 18
critMod = 145
actionCost = 1
clipSize = 10
ammoPerShot = 1

burstFire = 2
burstFireMarksmanshipPenalty = -8

range = "CLOSE"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 8, modifierName end
Modifier.Bleeding = function() return 20, modifierName end

score = 440
price = 5800

audio =
{
    onFire = "AUDIO.COMBAT.CULT_M1911_SHOT",
    onReload = "AUDIO.COMBAT.M1911_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_Cult1911"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_Cult1911"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_Cult1911"
combatAbility = {"GeneralBurstFire", "PistolDoubleShot"}

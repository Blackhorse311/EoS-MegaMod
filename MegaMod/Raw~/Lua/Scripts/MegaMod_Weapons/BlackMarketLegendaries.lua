--[[------------------------------------------------------------------------------
    MegaMod: Black Market Legendary Weapons
    8 named legendary weapons available as rare black market finds
--------------------------------------------------------------------------------]]

_namespace = "ITEM.WEAPON"

--[[------------------------------------------------------------------------------
    "THE UNDERTAKER" - Legendary Handgun, Bleeding
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_UNDERTAKER"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_UNDERTAKER_name" --$ The Undertaker
imageCaption = "$MEGAMOD_LEG_UNDERTAKER_caption" --$ The Undertaker
modifierName = "$MEGAMOD_LEG_UNDERTAKER_modifierName" --$ The Undertaker
desc = "$MEGAMOD_LEG_UNDERTAKER_desc" --$ A jet-black revolver with a coffin etched into the grip. Its previous owner was a mortician who moonlighted as an enforcer. He always said business was good either way.

item = {}
item.rarity = "Legendary"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_06"

minDamage = 26
maxDamage = 40
baseCritChance = 25
critMod = 175
actionCost = 1
clipSize = 6
ammoPerShot = 1

range = "CLOSE"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end
Modifier.Bleeding = function() return 45, modifierName end

score = 600
price = 10000

audio = { onFire = "AUDIO.COMBAT.CULT_SINGLE_SHOT", onReload = "AUDIO.COMBAT.REVOLVER_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultNewService"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultNewService"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_CultNewService"

--[[------------------------------------------------------------------------------
    "CHICAGO LIGHTNING" - Legendary SubGun, high fire rate
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_LIGHTNING"
_includes = {"ITEM.WEAPON.SUB_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_LIGHTNING_name" --$ Chicago Lightning
imageCaption = "$MEGAMOD_LEG_LIGHTNING_caption" --$ Chicago Lightning
modifierName = "$MEGAMOD_LEG_LIGHTNING_modifierName" --$ Chicago Lightning
desc = "$MEGAMOD_LEG_LIGHTNING_desc" --$ A Thompson with every moving part polished to perfection. It fires so fast and so smooth that witnesses describe the sound as one continuous thunderclap. When the lightning strikes, nobody's left standing.

item = {}
item.rarity = "Legendary"
item.type = "SubGun"
item.slotType = "Primary"
animatorBool = "Weapon_SUBGUN_02"

minDamage = 14
maxDamage = 22
baseCritChance = 16
critMod = 150
actionCost = 1
clipSize = 50
ammoPerShot = 1
burstFire = 5
burstFireMarksmanshipPenalty = -10

range = "MEDIUM"
Modifier.overwatchAngle = function() return 65, modifierName end
Modifier.overwatchRange = function() return 14, modifierName end

score = 720
price = 14000

audio = { onFire = "AUDIO.COMBAT.TOMMY_GUN_BURST", onReload = "AUDIO.COMBAT.TOMMY_GUN_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_SubGun_Thompson1921_Drum"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_SubGun_Thompson1921_Drum"
prefab = "Models/Items/Weapons/Prefabs/Weapon_SubGun_Thompson1921_Drum"
combatAbility = "GeneralBurstFire"

--[[------------------------------------------------------------------------------
    "THE LAST WORD" - Legendary Shotgun, massive close damage
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_LASTWORD"
_includes = {"ITEM.WEAPON.SHOTGUN"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_LASTWORD_name" --$ The Last Word
imageCaption = "$MEGAMOD_LEG_LASTWORD_caption" --$ The Last Word
modifierName = "$MEGAMOD_LEG_LASTWORD_modifierName" --$ The Last Word
desc = "$MEGAMOD_LEG_LASTWORD_desc" --$ A custom-bored shotgun that fires slugs the size of your thumb. It's called The Last Word because in any argument, this gun always gets the final say. Devastating at close range. Useless everywhere else.

item = {}
item.rarity = "Legendary"
item.type = "Shotgun"
item.slotType = "Primary"
animatorBool = "Weapon_SHOTGUN_05"

minDamage = 30
maxDamage = 65
baseCritChance = 15
critMod = 185
actionCost = 1
clipSize = 4
ammoPerShot = 1

range = "POINTBLANK_SHOTGUN"
Modifier.overwatchAngle = function() return 40, modifierName end
Modifier.overwatchRange = function() return 8, modifierName end
Modifier.knockBackChance = function() return 100, modifierName end

score = 620
price = 11000

audio = { onFire = "AUDIO.COMBAT.SHOTGUN_SHOT", onReload = "AUDIO.COMBAT.SHOTGUN_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_Sjogren"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_Sjogren"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Shotgun_Sjogren"

--[[------------------------------------------------------------------------------
    "WHISPER" - Legendary Sniper, armor piercing
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_WHISPER"
_includes = {"ITEM.WEAPON.SNIPER_RIFLE"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_WHISPER_name" --$ Whisper
imageCaption = "$MEGAMOD_LEG_WHISPER_caption" --$ Whisper
modifierName = "$MEGAMOD_LEG_WHISPER_modifierName" --$ Whisper
desc = "$MEGAMOD_LEG_WHISPER_desc" --$ A precision sniper rifle with a custom-machined barrel that's eerily quiet. The shot arrives before the sound does. Armor means nothing to this weapon -- the rounds punch through steel plate like paper.

item = {}
item.rarity = "Legendary"
item.type = "SniperRifle"
item.slotType = "Primary"
animatorBool = "Weapon_SNIPER_01"

minDamage = 55
maxDamage = 75
baseCritChance = 32
critMod = 175
actionCost = 1
clipSize = 5
ammoPerShot = 1

range = "VERY_FAR"
Modifier.overwatchAngle = function() return 25, modifierName end
Modifier.overwatchRange = function() return 18, modifierName end
Modifier.ignoreArmorChance = function() return 75, modifierName end

score = 750
price = 15000

audio = { onFire = { "AUDIO.COMBAT.SPRINGFIELD_SHOT_1", "AUDIO.COMBAT.SPRINGFIELD_SHOT_2", "AUDIO.COMBAT.SPRINGFIELD_SHOT_3", }, onReload = "AUDIO.COMBAT.SPRINGFIELD_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_SpringfieldM1903"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_SpringfieldM1903"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Rifle_SpringfieldM1903"

--[[------------------------------------------------------------------------------
    "THE NEGOTIATOR" - Legendary Rifle, knockback + slow
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_NEGOTIATOR"
_includes = {"ITEM.WEAPON.RIFLE"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_NEGOTIATOR_name" --$ The Negotiator
imageCaption = "$MEGAMOD_LEG_NEGOTIATOR_caption" --$ The Negotiator
modifierName = "$MEGAMOD_LEG_NEGOTIATOR_modifierName" --$ The Negotiator
desc = "$MEGAMOD_LEG_NEGOTIATOR_desc" --$ A heavy-caliber rifle that hits so hard it rearranges the furniture. The Negotiator doesn't ask twice. One shot puts them on the floor, the next keeps them there.

item = {}
item.rarity = "Legendary"
item.type = "Rifle"
item.slotType = "Primary"
animatorBool = "Weapon_RIFLE_04"

minDamage = 45
maxDamage = 62
baseCritChance = 22
critMod = 160
actionCost = 1
clipSize = 5
ammoPerShot = 1

range = "FAR"
Modifier.overwatchAngle = function() return 45, modifierName end
Modifier.overwatchRange = function() return 14, modifierName end
Modifier.knockBackChance = function() return 60, modifierName end
Modifier.Slow = function() return 30, modifierName end

score = 680
price = 12000

audio = { onFire = { "AUDIO.COMBAT.GEWEHR_SHOT_1", "AUDIO.COMBAT.GEWEHR_SHOT_2", "AUDIO.COMBAT.GEWEHR_SHOT_3", "AUDIO.COMBAT.GEWEHR_SHOT_4", }, onReload = "AUDIO.COMBAT.GEWEHR_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_Gewehr98"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_Gewehr98"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Rifle_Gewehr98"

--[[------------------------------------------------------------------------------
    "TRENCH SWEEPER" - Legendary Shotgun, wide spread
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_SWEEPER"
_includes = {"ITEM.WEAPON.SHOTGUN"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_SWEEPER_name" --$ Trench Sweeper
imageCaption = "$MEGAMOD_LEG_SWEEPER_caption" --$ Trench Sweeper
modifierName = "$MEGAMOD_LEG_SWEEPER_modifierName" --$ Trench Sweeper
desc = "$MEGAMOD_LEG_SWEEPER_desc" --$ A military-grade trench shotgun brought back from the Great War. It was designed to clear dugouts and it's just as good at clearing speakeasies. The wide spread means you don't need to aim -- just point and pull.

item = {}
item.rarity = "Legendary"
item.type = "Shotgun"
item.slotType = "Primary"
animatorBool = "Weapon_SHOTGUN_02"

minDamage = 14
maxDamage = 45
baseCritChance = 12
critMod = 155
actionCost = 1
clipSize = 6
ammoPerShot = 1

range = "CLOSE_SHOTGUN"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 12, modifierName end
Modifier.Bleeding = function() return 30, modifierName end

score = 590
price = 10500

audio = { onFire = { "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_1", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_2", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_3", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_4", }, onReload = "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel1897"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel1897"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Shotgun_WinstonModel1897"

--[[------------------------------------------------------------------------------
    "THE TYPEWRITER" - Legendary Machine Gun, huge clip
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_TYPEWRITER"
_includes = {"ITEM.WEAPON.MACHINE_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_TYPEWRITER_name" --$ The Typewriter
imageCaption = "$MEGAMOD_LEG_TYPEWRITER_caption" --$ The Typewriter
modifierName = "$MEGAMOD_LEG_TYPEWRITER_modifierName" --$ The Typewriter
desc = "$MEGAMOD_LEG_TYPEWRITER_desc" --$ A Lewis Gun with a custom oversized drum magazine. They call it The Typewriter because it writes your name in lead on the wall behind you. Forty rounds of continuous fire will level just about anything.

item = {}
item.rarity = "Legendary"
item.type = "MachineGun"
item.slotType = "Primary"
animatorBool = "Weapon_MACHINEGUN_03"

minDamage = 12
maxDamage = 20
baseCritChance = 10
critMod = 140
actionCost = 1
clipSize = 40
ammoPerShot = 1
burstFire = 5
burstFireMarksmanshipPenalty = -15

range = "FAR"
Modifier.overwatchAngle = function() return 75, modifierName end
Modifier.overwatchRange = function() return 16, modifierName end

score = 740
price = 15000

audio = { onFire = "AUDIO.COMBAT.LEWIS_GUN_BURST", onReload = "AUDIO.COMBAT.LEWIS_GUN_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_MachineGun_LewisGun"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_MachineGun_LewisGun"
prefab = "Models/Items/Weapons/Prefabs/Weapon_MachineGun_LewisGun"
combatAbility = "GeneralBurstFire"

--[[------------------------------------------------------------------------------
    "DEVIL'S RIGHT HAND" - Legendary Handgun, Poisoned + high crit
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_LEGENDARY_DEVILSHAND"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_LEG_DEVILSHAND_name" --$ Devil's Right Hand
imageCaption = "$MEGAMOD_LEG_DEVILSHAND_caption" --$ Devil's Right Hand
modifierName = "$MEGAMOD_LEG_DEVILSHAND_modifierName" --$ Devil's Right Hand
desc = "$MEGAMOD_LEG_DEVILSHAND_desc" --$ A blood-red M1911 with a pearl grip carved in the shape of a grinning skull. Legend has it the gun was won in a poker game from a man who died the next day. Every owner since has had impeccable aim and terrible luck.

item = {}
item.rarity = "Legendary"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_03"

minDamage = 24
maxDamage = 36
baseCritChance = 30
critMod = 180
actionCost = 1
clipSize = 7
ammoPerShot = 1

range = "CLOSE"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end
Modifier.Poisoned = function() return 35, modifierName end

score = 580
price = 11000

audio = { onFire = "AUDIO.COMBAT.CULT_M1911_SHOT", onReload = "AUDIO.COMBAT.M1911_RELOAD", onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE" }
hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_Cult1911"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_Cult1911"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_Cult1911"

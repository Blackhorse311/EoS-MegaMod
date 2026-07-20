--[[------------------------------------------------------------------------------
    MegaMod: Signature Boss Weapons
    14 unique weapons, one for each playable faction boss.
    A gift event delivers the weapon early in the game.
--------------------------------------------------------------------------------]]

_namespace = "ITEM.WEAPON"

--[[------------------------------------------------------------------------------
    THE OUTFIT - Alphonse Capone: "Big Fella" (Thompson SMG)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_OUTFIT"
_includes = {"ITEM.WEAPON.SUB_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_OUTFIT_name" --$ Big Fella
imageCaption = "$MEGAMOD_BOSS_OUTFIT_caption" --$ Big Fella
modifierName = "$MEGAMOD_BOSS_OUTFIT_modifierName" --$ Big Fella
desc = "$MEGAMOD_BOSS_OUTFIT_desc" --$ Capone's personal Thompson, engraved with his initials and fitted with a custom drum magazine. They say the gun has a mind of its own -- it doesn't miss, and it doesn't forgive.

item = {}
item.rarity = "Unique"
item.type = "SubGun"
item.slotType = "Primary"
animatorBool = "Weapon_SUBGUN_02"

minDamage = 16
maxDamage = 24
baseCritChance = 18
critMod = 155
actionCost = 1
clipSize = 50
ammoPerShot = 1
burstFire = 4
burstFireMarksmanshipPenalty = -8

range = "MEDIUM"
Modifier.overwatchAngle = function() return 60, modifierName end
Modifier.overwatchRange = function() return 12, modifierName end
Modifier.intimidation = function() return 15, modifierName end

score = 700
price = 12000

audio =
{
    onFire = "AUDIO.COMBAT.TOMMY_GUN_BURST",
    onReload = "AUDIO.COMBAT.TOMMY_GUN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_SubGun_Thompson1921_Drum"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_SubGun_Thompson1921_Drum"
prefab = "Models/Items/Weapons/Prefabs/Weapon_SubGun_Thompson1921_Drum"
combatAbility = "GeneralBurstFire"

--[[------------------------------------------------------------------------------
    NORTHSIDE MOB - Dion O'Banion: "Florist's Shears" (Poisoned Handgun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_NORTHSIDE"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_NORTHSIDE_name" --$ Florist's Shears
imageCaption = "$MEGAMOD_BOSS_NORTHSIDE_caption" --$ Florist's Shears
modifierName = "$MEGAMOD_BOSS_NORTHSIDE_modifierName" --$ Florist's Shears
desc = "$MEGAMOD_BOSS_NORTHSIDE_desc" --$ O'Banion's silver-plated revolver, always tucked behind the flower arrangements. The bullets are tipped with something foul -- one graze and you'll be pushing up daisies.

item = {}
item.rarity = "Unique"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_06"

minDamage = 22
maxDamage = 34
baseCritChance = 22
critMod = 160
actionCost = 1
clipSize = 6
ammoPerShot = 1

range = "CLOSE"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end
Modifier.Poisoned = function() return 40, modifierName end

score = 500
price = 8000

audio =
{
    onFire = "AUDIO.COMBAT.CULT_SINGLE_SHOT",
    onReload = "AUDIO.COMBAT.REVOLVER_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultNewService"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultNewService"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_CultNewService"

--[[------------------------------------------------------------------------------
    WHITE CITY CIRCUS - Maggie Dyer: "Ringmaster" (Precision Rifle)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_WHITECITY"
_includes = {"ITEM.WEAPON.RIFLE"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_WHITECITY_name" --$ The Ringmaster
imageCaption = "$MEGAMOD_BOSS_WHITECITY_caption" --$ The Ringmaster
modifierName = "$MEGAMOD_BOSS_WHITECITY_modifierName" --$ The Ringmaster
desc = "$MEGAMOD_BOSS_WHITECITY_desc" --$ Maggie's pride and joy -- a custom rifle with ivory inlays and a hair trigger. She learned to shoot in the circus, and every shot is a performance. The audience never applauds twice.

item = {}
item.rarity = "Unique"
item.type = "Rifle"
item.slotType = "Primary"
animatorBool = "Weapon_RIFLE_02"

minDamage = 40
maxDamage = 58
baseCritChance = 28
critMod = 165
actionCost = 1
clipSize = 8
ammoPerShot = 1

range = "FAR"
Modifier.overwatchAngle = function() return 40, modifierName end
Modifier.overwatchRange = function() return 14, modifierName end
Modifier.marksmanship = function() return 15, modifierName end

score = 650
price = 10000

audio =
{
    onFire = { "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_1", "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_2", "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_3", "AUDIO.COMBAT.FAR_HILL_RIFLE_SHOT_4", },
    onReload = "AUDIO.COMBAT.FAR_HILL_RIFLE_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_FarquharHillRifle"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_FarquharHillRifle"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Rifle_FarquharHillRifle"

--[[------------------------------------------------------------------------------
    RAGENS COLTS - Frank Ragen: "The Derby" (Brutal Melee)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_RAGENS"
_includes = {"ITEM.WEAPON.MELEE"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_RAGENS_name" --$ The Derby
imageCaption = "$MEGAMOD_BOSS_RAGENS_caption" --$ The Derby
modifierName = "$MEGAMOD_BOSS_RAGENS_modifierName" --$ The Derby
desc = "$MEGAMOD_BOSS_RAGENS_desc" --$ A lead-filled baseball bat wrapped in leather and studs. Ragen's boys use these to settle disputes at the stockyards, and the disputes always end the same way -- with somebody on the ground.

item = {}
item.rarity = "Unique"
item.type = "Melee"
item.slotType = "Secondary"
animatorBool = "Weapon_MELEE_06"

minDamage = 35
maxDamage = 55
baseCritChance = 25
critMod = 180
actionCost = 1
clipSize = 1
ammoPerShot = 0

range = "MELEE"
Modifier.knockBackChance = function() return 80, modifierName end
Modifier.Slow = function() return 30, modifierName end

score = 480
price = 6000

audio =
{
    onFire = { "AUDIO.COMBAT.BASEBALL_BAT_HIT_1", "AUDIO.COMBAT.BASEBALL_BAT_HIT_2", "AUDIO.COMBAT.BASEBALL_BAT_HIT_3", },
    onMiss = "AUDIO.COMBAT.BASEBALL_BAT_MISS",
    onCrit = { "AUDIO.COMBAT.BASEBALL_BAT_HIT_1", },
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Melee_BaseballBat"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Melee_BaseballBat"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Melee_BaseballBat"

--[[------------------------------------------------------------------------------
    THE DONOVANS - Frankie Donovan: "Irish Persuader" (Shotgun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_DONOVANS"
_includes = {"ITEM.WEAPON.SHOTGUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_DONOVANS_name" --$ Irish Persuader
imageCaption = "$MEGAMOD_BOSS_DONOVANS_caption" --$ Irish Persuader
modifierName = "$MEGAMOD_BOSS_DONOVANS_modifierName" --$ Irish Persuader
desc = "$MEGAMOD_BOSS_DONOVANS_desc" --$ Frankie brought this trench shotgun back from the Easter Rising. It's been modified with a bayonet lug and a hair trigger. When negotiations fail, the Persuader does the talking.

item = {}
item.rarity = "Unique"
item.type = "Shotgun"
item.slotType = "Primary"
animatorBool = "Weapon_SHOTGUN_02"

minDamage = 15
maxDamage = 48
baseCritChance = 14
critMod = 160
actionCost = 1
clipSize = 6
ammoPerShot = 1

range = "CLOSE_SHOTGUN"
Modifier.overwatchAngle = function() return 30, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end
Modifier.Bleeding = function() return 35, modifierName end

score = 560
price = 8500

audio =
{
    onFire = { "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_1", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_2", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_3", "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_SHOT_4", },
    onReload = "AUDIO.COMBAT.WL_TRENCH_SHOTGUN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel1897"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel1897"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Shotgun_WinstonModel1897"

--[[------------------------------------------------------------------------------
    VICE KINGS - Daniel McKee Jackson: "The Verdict" (Rifle)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_VICEKINGS"
_includes = {"ITEM.WEAPON.RIFLE"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_VICEKINGS_name" --$ The Verdict
imageCaption = "$MEGAMOD_BOSS_VICEKINGS_caption" --$ The Verdict
modifierName = "$MEGAMOD_BOSS_VICEKINGS_modifierName" --$ The Verdict
desc = "$MEGAMOD_BOSS_VICEKINGS_desc" --$ Jackson's personal rifle, polished to a mirror shine. He calls it The Verdict because once he lines up the shot, the sentence is final. No appeals, no stays of execution.

item = {}
item.rarity = "Unique"
item.type = "Rifle"
item.slotType = "Primary"
animatorBool = "Weapon_RIFLE_04"

minDamage = 42
maxDamage = 56
baseCritChance = 25
critMod = 155
actionCost = 1
clipSize = 5
ammoPerShot = 1

range = "FAR"
Modifier.overwatchAngle = function() return 45, modifierName end
Modifier.overwatchRange = function() return 14, modifierName end
Modifier.marksmanship = function() return 12, modifierName end
Modifier.ignoreArmorChance = function() return 25, modifierName end

score = 640
price = 9500

audio =
{
    onFire = { "AUDIO.COMBAT.GEWEHR_SHOT_1", "AUDIO.COMBAT.GEWEHR_SHOT_2", "AUDIO.COMBAT.GEWEHR_SHOT_3", "AUDIO.COMBAT.GEWEHR_SHOT_4", },
    onReload = "AUDIO.COMBAT.GEWEHR_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_Gewehr98"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_Gewehr98"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Rifle_Gewehr98"

--[[------------------------------------------------------------------------------
    SALTIS-MCERLANE - Joseph Saltis: "Polka Dot Special" (Machine Gun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_SALTIS"
_includes = {"ITEM.WEAPON.MACHINE_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_SALTIS_name" --$ Polka Dot Special
imageCaption = "$MEGAMOD_BOSS_SALTIS_caption" --$ Polka Dot Special
modifierName = "$MEGAMOD_BOSS_SALTIS_modifierName" --$ Polka Dot Special
desc = "$MEGAMOD_BOSS_SALTIS_desc" --$ Saltis had this BAR customized with a polished walnut stock and extended magazine. He says the polka dots are the bullet holes he leaves in people's front doors. The neighbors have learned not to complain.

item = {}
item.rarity = "Unique"
item.type = "MachineGun"
item.slotType = "Primary"
animatorBool = "Weapon_MACHINEGUN_01"

minDamage = 14
maxDamage = 22
baseCritChance = 10
critMod = 140
actionCost = 1
clipSize = 30
ammoPerShot = 1
burstFire = 4
burstFireMarksmanshipPenalty = -12

range = "MEDIUM"
Modifier.overwatchAngle = function() return 70, modifierName end
Modifier.overwatchRange = function() return 14, modifierName end
Modifier.Bleeding = function() return 25, modifierName end

score = 680
price = 11000

audio =
{
    onFire = "AUDIO.COMBAT.BAR_BURST",
    onReload = "AUDIO.COMBAT.BAR_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_MachineGun_BAR1918"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_MachineGun_BAR1918"
prefab = "Models/Items/Weapons/Prefabs/Weapon_MachineGun_BAR1918"
combatAbility = "GeneralBurstFire"

--[[------------------------------------------------------------------------------
    LOS LUCEROS - Elvira Duarte: "El Relampago" (Fast SubGun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_LOSLUCEROS"
_includes = {"ITEM.WEAPON.SUB_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_LOSLUCEROS_name" --$ El Relampago
imageCaption = "$MEGAMOD_BOSS_LOSLUCEROS_caption" --$ El Relampago
modifierName = "$MEGAMOD_BOSS_LOSLUCEROS_modifierName" --$ El Relampago
desc = "$MEGAMOD_BOSS_LOSLUCEROS_desc" --$ "The Lightning" -- Duarte's chrome-plated submachine gun fires so fast the muzzle flash looks like a thunderstorm. She had it smuggled across the border piece by piece, and she's never let it out of her sight since.

item = {}
item.rarity = "Unique"
item.type = "SubGun"
item.slotType = "Primary"
animatorBool = "Weapon_SUBGUN_04"

minDamage = 12
maxDamage = 20
baseCritChance = 15
critMod = 145
actionCost = 1
clipSize = 32
ammoPerShot = 1
burstFire = 3
burstFireMarksmanshipPenalty = -6

range = "MEDIUM"
Modifier.overwatchAngle = function() return 55, modifierName end
Modifier.overwatchRange = function() return 12, modifierName end
Modifier.Slow = function() return 20, modifierName end

score = 580
price = 9000

audio =
{
    onFire = "AUDIO.COMBAT.SUBMACHINE_BURST",
    onReload = "AUDIO.COMBAT.MP18_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_SubmachineGun_MP18"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_SubmachineGun_MP18"
prefab = "Models/Items/Weapons/Prefabs/Weapon_SubmachineGun_MP18"
combatAbility = "GeneralBurstFire"

--[[------------------------------------------------------------------------------
    FORTUNE TELLERS - Goldie Garneau: "Crystal Ball" (High-crit Handgun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_FORTUNE"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_FORTUNE_name" --$ Crystal Ball
imageCaption = "$MEGAMOD_BOSS_FORTUNE_caption" --$ Crystal Ball
modifierName = "$MEGAMOD_BOSS_FORTUNE_modifierName" --$ Crystal Ball
desc = "$MEGAMOD_BOSS_FORTUNE_desc" --$ Goldie's pearl-handled revolver, said to be charmed by a Voodoo priestess. She claims the gun tells her where to aim. Whether it's magic or marksmanship, the results speak for themselves.

item = {}
item.rarity = "Unique"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_01"

minDamage = 24
maxDamage = 36
baseCritChance = 35
critMod = 190
actionCost = 1
clipSize = 6
ammoPerShot = 1

range = "CLOSE"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end

score = 520
price = 8500

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
    GENNA CRIME FAMILY - Angelo Genna: "The Sicilian" (Slow+Poison Handgun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_GENNA"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_GENNA_name" --$ The Sicilian
imageCaption = "$MEGAMOD_BOSS_GENNA_caption" --$ The Sicilian
modifierName = "$MEGAMOD_BOSS_GENNA_modifierName" --$ The Sicilian
desc = "$MEGAMOD_BOSS_GENNA_desc" --$ Angelo's family heirloom -- a Vendetta pistol passed down from the old country. The Gennas coat the bullets in something they brew in the back of their distillery. Nobody knows what it is, but nobody wants to find out the hard way.

item = {}
item.rarity = "Unique"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_04"

minDamage = 20
maxDamage = 32
baseCritChance = 20
critMod = 155
actionCost = 1
clipSize = 8
ammoPerShot = 1

range = "CLOSE"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end
Modifier.Poisoned = function() return 30, modifierName end
Modifier.Slow = function() return 20, modifierName end

score = 490
price = 7500

audio =
{
    onFire = "AUDIO.COMBAT.CULT_SINGLE_SHOT",
    onReload = "AUDIO.COMBAT.M1915_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_Vendetta1915"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_Vendetta1915"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_Vendetta1915"

--[[------------------------------------------------------------------------------
    CARD SHARKS - Stephanie St. Clair: "Ace in the Hole" (Armor-piercing Handgun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_CARDSHARKS"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_CARDSHARKS_name" --$ Ace in the Hole
imageCaption = "$MEGAMOD_BOSS_CARDSHARKS_caption" --$ Ace in the Hole
modifierName = "$MEGAMOD_BOSS_CARDSHARKS_modifierName" --$ Ace in the Hole
desc = "$MEGAMOD_BOSS_CARDSHARKS_desc" --$ St. Clair's custom Mauser, fitted with armor-piercing rounds. She keeps it in a hidden holster and only draws it when the game is already won. By the time you see it, the hand's been dealt.

item = {}
item.rarity = "Unique"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_05"

minDamage = 22
maxDamage = 30
baseCritChance = 22
critMod = 150
actionCost = 1
clipSize = 10
ammoPerShot = 1

range = "MEDIUM"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 12, modifierName end
Modifier.ignoreArmorChance = function() return 50, modifierName end

score = 530
price = 8000

audio =
{
    onFire = "AUDIO.COMBAT.CULT_M1911_SHOT",
    onReload = "AUDIO.COMBAT.MAUSER_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_MauserC96"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_MauserC96"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_MauserC96"

--[[------------------------------------------------------------------------------
    LOS HIJOS - Salazar Reyna: "La Justicia" (Injury Rifle)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_LOSHIJOS"
_includes = {"ITEM.WEAPON.SNIPER_RIFLE"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_LOSHIJOS_name" --$ La Justicia
imageCaption = "$MEGAMOD_BOSS_LOSHIJOS_caption" --$ La Justicia
modifierName = "$MEGAMOD_BOSS_LOSHIJOS_modifierName" --$ La Justicia
desc = "$MEGAMOD_BOSS_LOSHIJOS_desc" --$ "Justice" -- Reyna's scoped Mosin-Nagant, etched with the names of those who wronged his family. He takes his time lining up each shot, and when the bullet finds its mark, there's no recovering from it.

item = {}
item.rarity = "Unique"
item.type = "SniperRifle"
item.slotType = "Primary"
animatorBool = "Weapon_SNIPER_06"

minDamage = 50
maxDamage = 70
baseCritChance = 30
critMod = 170
actionCost = 1
clipSize = 5
ammoPerShot = 1

range = "VERY_FAR"
Modifier.overwatchAngle = function() return 30, modifierName end
Modifier.overwatchRange = function() return 16, modifierName end
Modifier.injuryChance = function() return 50, modifierName end

score = 720
price = 13000

audio =
{
    onFire = { "AUDIO.COMBAT.MOSIN_SHOT_1", "AUDIO.COMBAT.MOSIN_SHOT_2", "AUDIO.COMBAT.MOSIN_SHOT_3", },
    onReload = "AUDIO.COMBAT.MOSIN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_MosinM91"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Rifle_MosinM91"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Rifle_MosinM91"

--[[------------------------------------------------------------------------------
    HIP SING TONG - Sai Wing Mock: "Dragon's Breath" (Fire Shotgun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_HIPSING"
_includes = {"ITEM.WEAPON.SHOTGUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_HIPSING_name" --$ Dragon's Breath
imageCaption = "$MEGAMOD_BOSS_HIPSING_caption" --$ Dragon's Breath
modifierName = "$MEGAMOD_BOSS_HIPSING_modifierName" --$ Dragon's Breath
desc = "$MEGAMOD_BOSS_HIPSING_desc" --$ Mock's custom shotgun, loaded with incendiary shells smuggled from overseas. The muzzle flash is blinding and the payload burns through anything. His enemies call it the Dragon for good reason.

item = {}
item.rarity = "Unique"
item.type = "Shotgun"
item.slotType = "Primary"
animatorBool = "Weapon_SHOTGUN_04"

minDamage = 16
maxDamage = 44
baseCritChance = 12
critMod = 155
actionCost = 1
clipSize = 5
ammoPerShot = 1

range = "CLOSE_SHOTGUN"
Modifier.overwatchAngle = function() return 35, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end
Modifier.Poisoned = function() return 30, modifierName end
Modifier.Bleeding = function() return 25, modifierName end

score = 570
price = 9000

audio =
{
    onFire = "AUDIO.COMBAT.SHOTGUN_SHOT",
    onReload = "AUDIO.COMBAT.SHOTGUN_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel12"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Shotgun_WinstonModel12"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Shotgun_WinstonModel12"

--[[------------------------------------------------------------------------------
    ALLEY CATS - Mabel Ryley: "Nine Lives" (Damage Reduction Handgun)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_ALLEYCATS"
_includes = {"ITEM.WEAPON.HAND_GUN"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_ALLEYCATS_name" --$ Nine Lives
imageCaption = "$MEGAMOD_BOSS_ALLEYCATS_caption" --$ Nine Lives
modifierName = "$MEGAMOD_BOSS_ALLEYCATS_modifierName" --$ Nine Lives
desc = "$MEGAMOD_BOSS_ALLEYCATS_desc" --$ Mabel's lucky revolver -- she's survived nine assassination attempts with this gun in her hand. It's nothing special on paper, but whoever's holding it just seems to walk away from trouble. Every time.

item = {}
item.rarity = "Unique"
item.type = "Handgun"
item.slotType = "Secondary"
animatorBool = "Weapon_HANDGUN_02"

minDamage = 18
maxDamage = 28
baseCritChance = 20
critMod = 150
actionCost = 1
clipSize = 6
ammoPerShot = 1

range = "CLOSE"
Modifier.overwatchAngle = function() return 50, modifierName end
Modifier.overwatchRange = function() return 10, modifierName end
Modifier.damageReduction = function() return 15, modifierName end

score = 460
price = 7000

audio =
{
    onFire = "AUDIO.COMBAT.CULT_SINGLE_SHOT",
    onReload = "AUDIO.COMBAT.REVOLVER_RELOAD",
    onCantFire = "AUDIO.COMBAT.GUN_CANT_FIRE",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultPolicePositiveSpecial"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Handgun_CultPolicePositiveSpecial"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Handgun_CultPolicePositiveSpecial"

--[[------------------------------------------------------------------------------
    MEATPACKERS - Ronnie O'Neill: "The Butcher's Bill" (Bleeding Melee)
    (Non-playable but included for completeness if player encounters them)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSS_MEATPACKERS"
_includes = {"ITEM.WEAPON.MELEE"}
inventoryTooltip = desc

name = "$MEGAMOD_BOSS_MEATPACKERS_name" --$ The Butcher's Bill
imageCaption = "$MEGAMOD_BOSS_MEATPACKERS_caption" --$ The Butcher's Bill
modifierName = "$MEGAMOD_BOSS_MEATPACKERS_modifierName" --$ The Butcher's Bill
desc = "$MEGAMOD_BOSS_MEATPACKERS_desc" --$ O'Neill's favorite meat cleaver from the stockyards. He sharpens it every morning and carries it everywhere. Some say it's never been properly cleaned, and the stains on the blade aren't all from livestock.

item = {}
item.rarity = "Unique"
item.type = "Melee"
item.slotType = "Secondary"
animatorBool = "Weapon_MELEE_05"

minDamage = 30
maxDamage = 48
baseCritChance = 22
critMod = 175
actionCost = 1
clipSize = 1
ammoPerShot = 0

range = "MELEE"
Modifier.Bleeding = function() return 60, modifierName end

score = 440
price = 5500

audio =
{
    onFire = "AUDIO.COMBAT.KNIFE_HIT",
    onCrit = "AUDIO.COMBAT.KNIFE_CRIT",
    onMiss = "AUDIO.COMBAT.KNIFE_MISS",
    onKill = "AUDIO.COMBAT.KNIFE_KILL",
}

hudIcon = "Sprites/Images/Items/Weapons/Weapon_Melee_CutThroatRazor"
inventoryIcon = "Sprites/Images/Items/Weapons/Weapon_Melee_CutThroatRazor"
prefab = "Models/Items/Weapons/Prefabs/Weapon_Melee_CutThroatRazor"

--[[------------------------------------------------------------------------------
    BOSS WEAPON GIFT EVENT
    Delivers the signature weapon to the player's boss early in the game.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_BOSS_WEAPON_GIFT"
_event = "MegaModBossWeaponGift"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 30
_category = "Misc"

-- Maps faction configIds to their boss weapon item IDs
local bossWeaponMap = {
    ["FACTION.THE_OUTFIT"]            = "ITEM.WEAPON.MEGAMOD_BOSS_OUTFIT",
    ["FACTION.THE_NORTHSIDE_MOB"]     = "ITEM.WEAPON.MEGAMOD_BOSS_NORTHSIDE",
    ["FACTION.WHITE_CITY_CIRCUS"]     = "ITEM.WEAPON.MEGAMOD_BOSS_WHITECITY",
    ["FACTION.RAGENS_COLTS"]          = "ITEM.WEAPON.MEGAMOD_BOSS_RAGENS",
    ["FACTION.THE_DONOVANS"]          = "ITEM.WEAPON.MEGAMOD_BOSS_DONOVANS",
    ["FACTION.VICE_KINGS"]            = "ITEM.WEAPON.MEGAMOD_BOSS_VICEKINGS",
    ["FACTION.SALTIS_MCERLANE"]       = "ITEM.WEAPON.MEGAMOD_BOSS_SALTIS",
    ["FACTION.LOS_LUCEROS"]           = "ITEM.WEAPON.MEGAMOD_BOSS_LOSLUCEROS",
    ["FACTION.FORTUNE_TELLERS"]       = "ITEM.WEAPON.MEGAMOD_BOSS_FORTUNE",
    ["FACTION.GENNA_CRIME_FAMILY"]    = "ITEM.WEAPON.MEGAMOD_BOSS_GENNA",
    ["FACTION.CARD_SHARKS"]           = "ITEM.WEAPON.MEGAMOD_BOSS_CARDSHARKS",
    ["FACTION.LOS_HIJOS"]             = "ITEM.WEAPON.MEGAMOD_BOSS_LOSHIJOS",
    ["FACTION.HIP_SING_TONG"]        = "ITEM.WEAPON.MEGAMOD_BOSS_HIPSING",
    ["FACTION.ALLEY_CATS"]            = "ITEM.WEAPON.MEGAMOD_BOSS_ALLEYCATS",
}

function canTrigger()
    return true
end

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    local weaponId = bossWeaponMap[playerFaction.configId]
    if weaponId then
        local boss = playerFaction.boss
        local weapon = Utils:createNewItem(weaponId)
        boss.inventory:addItem(weapon)
        title("$MEGAMOD_BOSS_GIFT_title") --$ A Package Arrives
        text("$MEGAMOD_BOSS_GIFT_text") --$ One of your boys drops a long wooden crate on your desk. "This came for you, boss. No return address, but there's a note inside." You crack it open and find a weapon -- your weapon. One you've been waiting to get your hands on for a long time.
        option("$MEGAMOD_BOSS_GIFT_option", onDismiss) --$ "About damn time."
    else
        complete()
    end
end

function onDismiss()
    complete()
end

--[[------------------------------------------------------------------------------
    MegaMod: Military Vest Gift
    Day-one gift event: an anonymous "friend" delivers two military grade
    protective vests (highest-tier vanilla armor) to the boss's inventory.
    Pattern: BossWeapons.lua MEGAMOD_BOSS_WEAPON_GIFT (Bridging/Schedule one-shot).
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_VEST_GIFT"
_event = "MegaModVestGift"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 60
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.boss then
        complete()
        return
    end

    local boss = playerFaction.boss
    local vest1 = Utils:createNewItem("ITEM.ARMOR.ARMOR_07")
    local vest2 = Utils:createNewItem("ITEM.ARMOR.ARMOR_07_2")
    if vest1 then boss.inventory:addItem(vest1) end
    if vest2 then boss.inventory:addItem(vest2) end

    title("$MEGAMOD_VESTGIFT_title") --$ A Gift from the Great War
    text("$MEGAMOD_VESTGIFT_text") --$ A doughboy in a threadbare Army coat leaves a heavy canvas bundle with one of your guys and vanishes down the alley. Inside: two military issue protective vests, the real thing, straight off a quartermaster's truck in France. A note pinned to the canvas reads: "For services rendered. Keep your people breathing." No name. No return address.
    option("$MEGAMOD_VESTGIFT_option", onDismiss) --$ Somebody upstairs likes us.
end

function onDismiss()
    complete()
end

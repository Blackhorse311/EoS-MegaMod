--$$ General
-- --------------------------------------------------
-- BasicAttackData.lua
-- MEGAMOD OVERRIDE: vanilla copy + NPC friendly fire.
-- An AI-controlled shooter whose firing line crosses a tile occupied by a
-- same-faction ally has a 15% chance (per intervening ally, rolled once per
-- attack) to hit that ally instead of the intended target. Player-controlled
-- units are exempt, matching vanilla (players shoot through their own freely).
-- Patch points: onPoolAcquire (cache reset), megamodResolveFriendlyFire (new),
-- applyHit (target redirect). Everything else is untouched vanilla.
-- --------------------------------------------------
local CombatCalculations = require("Combat.CombatCalculations")
local DefaultTargetData = require("Combat.AbilityData.DefaultTargetData")
local SkillCheckPool = require("Libs.SkillCheckPool")
local Behaviour = require("Mixins.Behaviour")
local LateRequires = require("Libs.LateRequires")
local getWorld = LateRequires.getWorld

local DefaultTargetDataClass = DefaultTargetData:getClass()

local _overkillMultiplier = Config.DEFAULTS.CHARACTER.overkillMultiplier
local _tablePool = newTablePool({initialCapacity = 32, incrementalCapacity = 16})
local _basicAttackDataPool

local Behaviour_getBehaviourNamesFromTag = Behaviour.getBehaviourNamesFromTag
local math_round = math.round
local math_random = math.random
local math_max = math.max
local math_min = math.min

local string_format = string.format
local clearTable = clearTable

local automaticHitThreshold = Config.COMBAT.DEFAULTS.automaticHitThreshold

local _damageReductionCache = {}
local _effectResistanceCache = {}
local _effectImmunityCache = {}

local function getDamageReductionString(key)
    local result = _damageReductionCache[key]
    if result == nil then
        result = key .. "DamageReduction"
        _damageReductionCache[key] = result
    end
    return result
end

local function getEffectResistanceString(key)
    local result = _effectResistanceCache[key]
    if result == nil then
        result = key .. "Resistance"
        _effectResistanceCache[key] = result
    end
    return result
end

local function getEffectImmunityString(key)
    local result = _effectImmunityCache[key]
    if result == nil then
        result = key .. "Immunity"
        _effectImmunityCache[key] = result
    end
    return result
end

-- --------------------------------------------------
-- Hit Info
-- --------------------------------------------------
local HitInfo = {}

function HitInfo:onPoolAcquire()
    self._stateCallbacks = _tablePool:acquire()
    self.damageTypes = _tablePool:acquire()
end

function HitInfo:onPoolRelease()
    local stateCallbacks = self._stateCallbacks
    for i = #stateCallbacks, 1, -1 do
        local cur = stateCallbacks[i]
        stateCallbacks[i] = nil
        clearTable(cur)
        _tablePool:release(cur)
    end
    _tablePool:release(stateCallbacks)
    self._stateCallbacks = nil

    local damageTypes = self.damageTypes
    clearTable(damageTypes)
    _tablePool:release(damageTypes)
    self.damageTypes = nil

    clearTable(self)
end

function HitInfo:allDamageTypes()
    return next, self.damageTypes
end

function HitInfo:addStateFunction(state, func, ...)
    local stateCallbacks = self._stateCallbacks

    local callbackData = _tablePool:acquire()
    callbackData[1] = state
    callbackData[2] = func

    local argCount = select("#", ...)
    if argCount > 0 then
        for i = 1, argCount do
            callbackData[i + 2] = select(i, ...)
        end
    end

    stateCallbacks[#stateCallbacks + 1] = callbackData
end

newClass("RomeroGames.Combat.BasicAttackData.HitInfo", HitInfo)
local _hitInfoPool = newPool(HitInfo, {initialCapacity = 8, incrementalCapacity = 4})

-- --------------------------------------------------
-- Basic Attack Data
-- --------------------------------------------------

local BasicAttackData = {}

BasicAttackData._get = {}
BasicAttackData._set = {}

function BasicAttackData:getCheckers(source, target, weapon)
    -- Get the relevant skill checkers
    local sightMap = require("World.World").combatContext.sightMap
    local x, y
    if sightMap then
        x, y = sightMap:getActionPosition(source, target)
    else
        x, y = source:getGridPosXY()
    end

    local ability = self._ability
    local hitCheck = ability and ability:getHitChecker(source, target, weapon, x, y) or CombatCalculations.getDefaultHitCheckerForPosition(source, target, x + 0.5, y + 0.5, weapon)
    local critCheck = ability and ability:getCritChecker(source, target, weapon, x, y) or CombatCalculations.getDefaultCritCheckerForPosition(source, target, x + 0.5, y + 0.5, weapon)
    local knockBackCheck = ability and ability:getKnockbackChecker(source, target, weapon) or CombatCalculations.getKnockBackCheck(source, target, weapon)

    self.hitCheck = hitCheck
    self.critCheck = critCheck
    self.knockBackCheck = knockBackCheck

    local statusEffectCheckers = self.statusEffectCheckers
    for name in Behaviour_getBehaviourNamesFromTag("WeaponEffect") do
        local check = source:getSkillCheck(name, weapon)
        if check:total() > 0 then
            check:addCharacterModifiers(source, "applyEffectChance", weapon)
            check:subtractCharacterModifiers(target, "effectResistance", weapon)
            check:subtractCharacterModifiers(target, getEffectResistanceString(name), weapon)

            local immunityCheck = target:getSkillCheck(getEffectImmunityString(name))
            if immunityCheck:checkIfAny() then
                for _, reason in immunityCheck:getAllWithReasons() do
                    self.immunitiesToApply[name] = reason
                end
            end

            statusEffectCheckers[name] = check
        else
            check:releaseSelf()
        end
    end
end

function BasicAttackData:getDamage(source, target, weapon)
    -- Get the normal damage range
    local minDamage, maxDamage, modDamageMin, modDamageMax = CombatCalculations.getDamageRange(source, target, weapon, false)
    self.minDamage = minDamage
    self.maxDamage = maxDamage
    self.modDamageMin = modDamageMin
    self.modDamageMax = modDamageMax

    -- Get the crit damage range
    local minCritDamage, maxCritDamage, critModDamageMin, critModDamageMax = CombatCalculations.getDamageRange(source, target, weapon, true)
    self.minCritDamage = minCritDamage
    self.maxCritDamage = maxCritDamage
    self.critModDamageMin = critModDamageMin
    self.critModDamageMax = critModDamageMax

    -- Get the armor damage
    local armorDamageValue = source:getSkillCheck("armorDamage", weapon)
    armorDamageValue:addCharacterModifiers(target, "armorVulnerability")
    self.armorDamageValue = armorDamageValue
end

function BasicAttackData:onPoolAcquire(source, target, weapon, attackCount, ability)
    DefaultTargetDataClass.onPoolAcquire(self, source, target)

    -- MEGAMOD: attack data objects are pooled; clear the friendly-fire cache so
    -- a reused object re-rolls for its new source/target pair
    self._megamodFFResolved = nil
    self._megamodFFTarget = nil

    self._ability = ability
    self._ignoresArmor = ability and ability:getIgnoresArmor() or false
    self.weapon = weapon

    local attacks = _tablePool:acquire()
    for i = 1, attackCount do
        attacks[#attacks + 1] = _hitInfoPool:acquire()
    end
    self.attacks = attacks

    self.statusEffectCheckers = _tablePool:acquire()
    self.statusEffectsToApply = _tablePool:acquire()
    self.immunitiesToApply = _tablePool:acquire()

    -- Populate the hit, crit, and knock back checkers
    self:getCheckers(source, target, weapon)

    -- Get the attack post processors
    local hitProcessors = SkillCheckPool:acquire()
    hitProcessors:addContextVariable("source", source)
    hitProcessors:addContextVariable("target", target)
    hitProcessors:addContextVariable("weapon", weapon)
    hitProcessors:addContextVariable("abilityClass", ability and ability.actionClass or nil)

    hitProcessors:gatherFunctions(source, "getHitProcessor")
    hitProcessors:gatherFunctions(target, "getHitProcessor")
    hitProcessors:gatherFunctions(weapon, "getHitProcessor")
    local ammo = weapon.gun and source.shooter:getWeaponAmmo(weapon)
    if ammo then
        hitProcessors:gatherFunctions(ammo, "getHitProcessor")
    end
    self.hitProcessors = hitProcessors

    -- Populate the min, max, and crit damage ranges
    self:getDamage(source, target, weapon)

    self.armorDamage = 0
    self.damage = 0
end


function BasicAttackData:onPoolRelease()
    -- Clear out the targetData, release the skill checkers
    if self.hitCheck then
        self.hitCheck:releaseSelf()
        self.hitCheck = nil
    end

    if self.critCheck then
        self.critCheck:releaseSelf()
        self.critCheck = nil
    end

    if self.knockBackCheck then
        self.knockBackCheck:releaseSelf()
        self.knockBackCheck = nil
    end

    if self.hitProcessors then
        self.hitProcessors:releaseSelf()
        self.hitProcessors = nil
    end

    local statusEffectCheckers = self.statusEffectCheckers
    for id, checker in next, statusEffectCheckers do
        checker:releaseSelf()
        statusEffectCheckers[id] = nil
    end
    self.statusEffectCheckers = nil
    _tablePool:release(statusEffectCheckers)

    _tablePool:releaseAndClear(self.statusEffectsToApply)
    self.statusEffectsToApply = nil

    _tablePool:releaseAndClear(self.immunitiesToApply)
    self.immunitiesToApply = nil

    local attacks = self.attacks
    local count = #attacks
    for i = count, 1, -1 do
        local cur = attacks[i]
        attacks[i] = nil
        _hitInfoPool:release(cur)
    end
    self.attacks = nil
    _tablePool:release(attacks)

    -- Always do this last as DefaultTargetData will clear anything left on the table when it releases
    DefaultTargetDataClass.onPoolRelease(self)
end

function BasicAttackData:getReducedDamage(damage)
    local target = self.target
    local source = self.source

    -- get checker, initialize with full damage
    local damageReduction = SkillCheckPool:acquire()
    damageReduction:addContextVariable("source", source)
    damageReduction:addValue(damage)

    damageReduction:subtractCharacterModifiers(target, "damageReduction")

    -- Get damage resistances for the damage types being dealt by the current weapon
    local damageTypes = self.weapon.damage.damageTypes
    if damageTypes then
        for curType, v in next, damageTypes do
            if v then
                damageReduction:subtractCharacterModifiers(target, getDamageReductionString(curType))
            end
        end
    end

    local reducedDamage = damageReduction:total()

    -- Percentage based modifiers are applied after the effects of the raw modifiers.

    -- Check if ability ignores armor
    if not self._ignoresArmor then
        -- check if target has armor
        local armorValue = target:getArmorModifier()
        if armorValue ~= "0%" then
            -- check if source of attack has a chance of ignoring armor
            local ignoreArmorChance = source:getSkillCheck("ignoreArmorChance")
            local ignoreArmor = ignoreArmorChance:check()

            -- if source failed the check, apply the armorReduction to the target
            if not ignoreArmor then
                damageReduction:subtractValue(armorValue, "$Modifier_Armor") --$ Armor
            end
        end
    end

    local result = math_max(damageReduction:total(), 0)
    damageReduction:releaseSelf()
    return result
end

function BasicAttackData:displayPotentialEffects(startingDamage)
    if not getWorld().uiData.playerCombatTurn then return end
    local target = self.target
    local maxPossibleDamage = self:getMaxPossibleDamage()
    
    if startingDamage ~= nil then
        maxPossibleDamage = maxPossibleDamage + startingDamage
    end
    
    -- Only one armor damage effect per ability activation, not per attack count.
    -- Armor damage needs to be multiplied by 10 to account for the need to specify it from 0 - 10 in data sheets vs 0 - 100 in code
    local potentialArmorDamage = self.armorDamageValue:total() * 10

    target.combatStatus:setPotentialDamage(maxPossibleDamage)
    target.combatStatus:setPotentialArmorDamage(potentialArmorDamage)
    target.combatStatus:setHitCritChance( math_min(self.hitCheck:total()/100, 1), math_min(self.critCheck:total()/100, 1) )
    target.combatStatus:setHitCritActive(true)
end

function BasicAttackData:getMaxPossibleDamage()
    if not getWorld().uiData.playerCombatTurn then return 0 end

    -- Get the maximum possible damage from the attack
    local maxPossibleDamage = 0
    local attackCount = #self.attacks
    for i = 1, attackCount do
        local hitInfo = self.attacks[i]
    
        local minDamage = hitInfo.minDamage or self.minDamage
        local maxDamage = hitInfo.maxDamage or self.maxDamage

        -- Clamp min and max damage
        minDamage = math_max(minDamage, 0)
        maxDamage = math_max(minDamage, maxDamage)

        maxDamage = self:getReducedDamage(maxDamage)
        maxPossibleDamage = maxPossibleDamage + maxDamage
    end

    return maxPossibleDamage
end

function BasicAttackData:hidePotentialEffects()
    local target = self.target
    target.combatStatus:setPotentialDamage(0)
    target.combatStatus:setPotentialArmorDamage(0)
    target.combatStatus:setHitCritActive(false)
end

function BasicAttackData:addAttack()
    local attacks = self.attacks
    attacks[#attacks + 1] = _hitInfoPool:acquire()
end

function BasicAttackData:attackCount()
    return #self.attacks
end

function BasicAttackData:removeAttack()
    local attacks = self.attacks
    local attack = attacks[#attacks]
    attacks[#attacks] = nil
    _hitInfoPool:release(attack)
end

function BasicAttackData:preProcess()
    DefaultTargetDataClass.preProcess(self)

    local source = self.source
    local target = self.target

    if #self.attacks > 0 then
        target:dispatchPooledEvent("onPreCharacterAttacked", "source", source, "targetData", self)
        game:dispatchPooledEvent("onPreCharacterAttacked", "source", source, "target", target, "targetData", self)
    end
end

function BasicAttackData:processHit()
    DefaultTargetDataClass.processHit(self)

    -- Process each attack
    local attacks = self.attacks
    local attackCount = #attacks
    for i = 1, attackCount do
        local hitInfo = attacks[i]
        self:processAttackHit(hitInfo)
    end
end

function BasicAttackData:hasFirstLethalAttack()
    local attacks = self.attacks
    local attackCount = #attacks
    
    for i = 1, attackCount do
        local hitInfo = attacks[i]

        if hitInfo.isFirstLethalAttack then
            return true
        end
    end
    
    return false
end

function BasicAttackData:processDamage()
    DefaultTargetDataClass.processDamage(self)

    local attacks = self.attacks
    local attackCount = #attacks
    local lastHitIdx = 0
    for i = 1, attackCount do
        local hitInfo = attacks[i]
        self:processAttackDamage(hitInfo)
        if hitInfo.didHit then
            lastHitIdx = i
        end
    end

    if self.hit then
        if self.damage > 0 or self.knockedBack or (self._ability and self._ability:getDisruptsOverwatch(self.source, self.target)) then
            self.disruptsOverwatch = true
        end

        -- Check for any states to apply
        if not self.isAttackLethal then
            self.statusEffectsToApply.lastHitIdx = lastHitIdx
            for name, checker in next, self.statusEffectCheckers do
                if checker:check() then
                    self.statusEffectsToApply[name] = true
                end
            end
        end
    end
end

function BasicAttackData:processAttackHit(hitInfo)
    local hitCheck = self.hitCheck
    local critCheck = self.critCheck
    local knockBackCheck = self.knockBackCheck
    local source = self.source
    -- Check to see if we hit, crit, or knocked back
    local didHit = hitCheck:check(automaticHitThreshold)
    
    if not didHit then
        local luck = require("Mixins.Luck").getFinalValue(source)

        if luck > 0 then
            local chanceToRecheckHit = math_random(100)
            local needRecheck = chanceToRecheckHit <= luck

            if Dev and Dev.toggles.showLogsForLuckDoubleChecks then
                print(string.format("Double check for hit by character: %s, Luck value: %i, Recheck chance: %s. " ..
                        "Need recheck: %s", source.name, luck, tostring(chanceToRecheckHit), tostring(needRecheck)))
            end

            if needRecheck then
                didHit = hitCheck:check(automaticHitThreshold)
            end
        else
            if Dev and Dev.toggles.showLogsForLuckDoubleChecks then
                print(string.format("Do not recheck hit, because character [%s] has too low luck value: %i", 
                        source.name, luck))
            end
        end
    end
    
    local didCrit = didHit and critCheck:check()
    if didCrit then
        source:dispatchPooledEvent("onCharacterDidCrit")
    end
    
    local didKnockBack = didHit and knockBackCheck:check()

    hitInfo.didHit = didHit
    hitInfo.didCrit = didCrit
    hitInfo.didKnockBack = didKnockBack

    self.hit = self.hit or didHit
    self.crit = self.crit or didCrit
    self.knockedBack = self.knockedBack or didKnockBack
end

function BasicAttackData:processAttackDamage(hitInfo)
    local didCrit = hitInfo.didCrit
    local weapon = self.weapon
    local target = self.target

    -- If we did hit, process damage and other effects
    if hitInfo.didHit then
        local minDamage
        local maxDamage
    
        if didCrit then
            minDamage = hitInfo.minCritDamage or self.minCritDamage
            maxDamage = hitInfo.maxCritDamage or self.maxCritDamage
        else
            minDamage = hitInfo.minDamage or self.minDamage
            maxDamage = hitInfo.maxDamage or self.maxDamage
        end

        -- Make sure min damage is valid, it can be no less than 0
        minDamage = math_max(minDamage, 0)

        -- Make sure max damage is valid, it can be no less than the min damage
        maxDamage = math_max(minDamage, maxDamage)

        -- Calculate the damage
        local delta = maxDamage - minDamage
        local damage = math_round(minDamage + (math_random() * delta))

        -- Get the damage after taking into account any damage reducing effects (armor etc.)
        hitInfo.damage = self:getReducedDamage(damage)
        hitInfo.armorDamage = self.armorDamageValue:total() * 10

        -- Populate the damage type from the weapon
        for damageType, value in next, weapon.damage.damageTypes do
            if value then
                hitInfo.damageTypes[damageType] = true
            end
        end

        -- Call the hit processors
        self.hitProcessors:call(self, hitInfo)

        -- Apply the modified damage to the target data
        self.damage = self.damage + hitInfo.damage

        -- Only one armor damage effect per ability activation, not per attack count.
        -- Apply the armorDamage to the target data
        -- Armor damage needs to be multiplied by 10 to account for the need to specify it from 0 - 10 in data sheets vs 0 - 100 in code
        self.armorDamage = hitInfo.armorDamage

        -- Mark if the attack was lethal
        self.isAttackLethal = self.isAttackLethal or (self.damage > 0 and self.damage >= target.hp)

        -- Mark if the attack one-shotted the target from full health
        self.isOneHitKill = self.isAttackLethal and target.hp == target.maxHealth

        -- Mark whether this attack was lethal (or was made after lethal damage was dealt)
        hitInfo.isAttackLethal = self.isAttackLethal

        -- Calculate if this attack should trigger bleed out
        if not self.bleedOut then
            local world = getWorld()
            local combatSession = world and world.combatSession
            local isControlledByPlayer = combatSession and (not combatSession:isHostileTowards(target, world.player))
            local passesOverkillCheck = isControlledByPlayer or (self.damage < (target.hp * _overkillMultiplier))

            self.bleedOut = self.isAttackLethal and
                    target:hasTag("InCombat") and
                    not target:hasState("BleedingOut") and
                    ((target.behaviours:performSkillCheck("bleedOutChance") and passesOverkillCheck or (Dev and Dev.toggles.alwaysBleedOut)))
        end
    end
end

function BasicAttackData:postProcess()
    DefaultTargetDataClass.postProcess(self)

    local source = self.source
    local target = self.target

    if self.hit then
        -- Apply morale bonuses / penalties based on attack type melee
        if self.weapon:get("damageTypes").melee then
            if target.addMorale then
                local moralePenalty = target:getModifierValue("receiveMeleeAttackMoraleLoss")
                target:subtractMorale(moralePenalty, "$Morale_ReceivedMeleeAttack")
            end
        else
            if source.subtractMorale then
                local moralePenalty = source:getModifierValue("performNonMeleeAttackMoraleLoss")
                source:subtractMorale(moralePenalty, "$Morale_PerformedNonMeleeAttack")
            end
        end
    end

    target:dispatchPooledEvent("onPostCharacterAttacked", "source", source, "targetData", self)
    game:dispatchPooledEvent("onPostCharacterAttacked", "source", source, "target", target, "targetData", self)
    target:takeArmorDamage(self.armorDamage)
end

function BasicAttackData:getIsLethal(startAttackIdx, endAttackIdx)
    local attacks = self.attacks
    startAttackIdx = startAttackIdx or 1
    endAttackIdx = endAttackIdx or #attacks

    for i = startAttackIdx, endAttackIdx do
        local hitInfo = attacks[i]
        if hitInfo.isAttackLethal then
            return true
        end
    end

    return false
end

function BasicAttackData:getKnockedBack(startAttackIdx, endAttackIdx)
    local attacks = self.attacks
    startAttackIdx = startAttackIdx or 1
    endAttackIdx = endAttackIdx or #attacks

    for i = startAttackIdx, endAttackIdx do
        local hitInfo = attacks[i]
        if hitInfo.didKnockBack then
            return true
        end
    end

    return false
end

function BasicAttackData:getDidHit(startAttackIdx, endAttackIdx)
    local attacks = self.attacks
    startAttackIdx = startAttackIdx or 1
    endAttackIdx = endAttackIdx or #attacks

    for i = startAttackIdx, endAttackIdx do
        local hitInfo = attacks[i]
        if hitInfo.didHit then
            return true
        end
    end

    return false
end

function BasicAttackData:getDidCrit(startAttackIdx, endAttackIdx)
    local attacks = self.attacks
    startAttackIdx = startAttackIdx or 1
    endAttackIdx = endAttackIdx or #attacks

    for i = startAttackIdx, endAttackIdx do
        local hitInfo = attacks[i]
        if hitInfo.didCrit then
            return true
        end
    end

    return false
end

-- MEGAMOD: NPC friendly fire. Resolved once per attack data (the whole burst
-- redirects if triggered) and cached; onPoolAcquire clears the cache on reuse.
-- Chance per intervening same-faction ally on the firing line. Damage was
-- computed against the intended target, so the ally's own armor is not
-- re-applied -- acceptable approximation for a stray round.
local MEGAMOD_FF_CHANCE = 0.15

function BasicAttackData:megamodResolveFriendlyFire()
    if self._megamodFFResolved then
        return self._megamodFFTarget
    end
    self._megamodFFResolved = true
    self._megamodFFTarget = nil

    local source = self.source
    local target = self.target
    local weapon = self.weapon
    if not source or not target or not weapon or source == target then
        return nil
    end

    -- Firearms only: excludes melee/punch, grenades (explosive), and molotovs.
    -- All firearm type keys are checked in case _includes replaces rather than
    -- merges the damageTypes table for a given weapon.
    local damageTypes = weapon:get("damageTypes")
    if not damageTypes then
        return nil
    end
    local isGun = damageTypes.gun or damageTypes.handgun or damageTypes.submachineGun
        or damageTypes.shotgun or damageTypes.rifle or damageTypes.sniperRifle
        or damageTypes.machineGun or damageTypes.tommyGun
    if not isGun then
        return nil
    end

    local world = getWorld()
    local session = world and world.combatSession
    if not session then
        return nil
    end

    local sourceAgent = session:getCombatAgent(source)
    if not sourceAgent or not sourceAgent:isAI() then
        return nil
    end

    local sourceFaction = source.faction
    if not sourceFaction then
        return nil
    end

    local x1, y1 = source:getGridPosXY()
    local x2, y2 = target:getGridPosXY()
    if not x1 or not y1 or not x2 or not y2 then
        return nil
    end
    if x1 == x2 and y1 == y2 then
        return nil
    end

    -- Bresenham grid walk from shooter toward target, endpoints excluded
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = (x1 < x2) and 1 or -1
    local sy = (y1 < y2) and 1 or -1
    local err = dx - dy
    local x, y = x1, y1
    local steps = 0

    while steps < 200 do
        steps = steps + 1
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x = x + sx
        end
        if e2 < dx then
            err = err + dx
            y = y + sy
        end
        if x == x2 and y == y2 then
            break
        end

        local _, actor = session:getValidAgentAtXY(x, y)
        if actor and actor ~= source and actor ~= target
            and not actor:isDead() and actor.faction == sourceFaction then
            if math_random() < MEGAMOD_FF_CHANCE then
                self._megamodFFTarget = actor
                return actor
            end
        end
    end

    return nil
end

--return true if the hit killed the target
function BasicAttackData:applyHit(hitIdx)
    local source = self.source
    local target = self.target

    local attack = self.attacks[hitIdx]
    if not attack then
        --print("No attack found by idx")
        --print(hitIdx)
        --print(target.name)

        logError(string_format("No attack found by idx %s for target %s.", tostring(hitIdx), tostring(target.name)))
        return false
    end
    local didHit = attack.didHit
    local didCrit = attack.didCrit

    -- MEGAMOD: NPC friendly fire -- a triggered roll swaps the whole hit
    -- (damage, alerts, state callbacks, status effects) onto the ally.
    -- Only actual hits redirect; misses stay misses. If the ally already
    -- dropped mid-burst, remaining rounds go back to the intended target.
    if didHit then
        local megamodFFTarget = self:megamodResolveFriendlyFire()
        if megamodFFTarget and not megamodFFTarget:isDead() then
            target = megamodFFTarget
        end
    end

    local damage = attack.damage
    --print("Dealing damage: ")
    --print(damage)
    if damage then
        if damage > 0 then
            if damage <= (target.maxHealth * 2) then
                target.icon:showDamageAlert(damage, didCrit)
            end
            target.health:takeDamage(damage, source, self.bleedOut)
        elseif damage < 0 then
            target.health:heal(-damage)
        end
    end

    -- Apply any hit effects or functions
    local callbacks = attack._stateCallbacks
    local callbackCount = #callbacks
    for i = 1, callbackCount do
        local cur = callbacks[i]
        callbacks[i] = nil
        local state = cur[1]
        local func = cur[2]

        local handle = target.behaviours:getHandle(state)
        if handle then
            if #cur > 2 then
                target.behaviours:executeFunction(handle, func, unpack(cur, 3))
            else
                target.behaviours:executeFunction(handle, func)
            end
        end

        clearTable(cur)
        _tablePool:release(cur)
    end

    -- If this was a hit then apply any statusEffects
    if self.statusEffectsToApply.lastHitIdx == hitIdx then
        self.statusEffectsToApply.lastHitIdx = nil
        for effectName in next, self.statusEffectsToApply do
            if self.immunitiesToApply[effectName] then
                local immuneReason = self.immunitiesToApply[effectName]
                target.icon:showImmuneAlert(immuneReason)
            elseif target.behaviours:hasStackingTag(effectName) then
                target:addStackFromSource(effectName, source)
            elseif not target:hasState(effectName) then
                target:addStateFromSource(effectName, source)
            end
        end
    end

    return target.health:getHP() <= 0
end

function BasicAttackData:releaseSelf()
    _basicAttackDataPool:release(self)
end

newClass("RomeroGames.Combat.AbilityData.BasicAttackData", BasicAttackData, DefaultTargetDataClass)
_basicAttackDataPool = newPool(BasicAttackData, {initialCapacity = 8, incrementalCapacity = 4})

return _basicAttackDataPool

local CombatAction = require( "Combat.CombatAction" )
local ConfigBuilder = require("Libs.ConfigBuilder")
local AbilityInformation = require("Combat.AbilityInformation")
local ActionDispatcher = require("Libs.ActionDispatcher")
local InputProcessor = require("Libs.InputProcessor")
local World = require("World.World")
local AbilityFilterUtils = require("Combat.AbilityFilterUtils")
local Effect = require("Libs.Effect")
local Audio = require( "Libs.Audio" )
local ActiveWeaponController = require("UI.Combat.ActiveWeaponController")

local Super = CombatAction

local Vector3 = UnityEngine.Vector3
local MoveInfo = RomeroGames.Move.MoveInfo
local ConfigBuilder_hasTag = ConfigBuilder.hasTag
local selection = client.selection

local math_floor = math.floor

local _tablePool = newTablePool({initialCapacity = 16, incrementalCapacity = 8})

local actionEvents =
{
    "onEmptySelection",
    "onPathHover",
    "onAgentHoverEnter",
    "onAgentHoverExit",
    "onAgentCursorEnter",
    "onAgentCursorExit",
}

local AbilityAction = {}
AbilityAction._get = {}
AbilityAction._set = {}

-- This overrides the getter, the setter in CombatAction is still valid
function AbilityAction._get:id()
    return self._id
end

function AbilityAction._get:ability()
    return self._ability
end

function AbilityAction._set:ability()
    logError("AbilityAction.ability is read only")
end

function AbilityAction._set:costOverride(v)
    if self.ability then
        self.ability.costOverride = v
    end

    self._costOverride = v
end

function AbilityAction._set:endsTurnOverride(v)
    if self.ability then
        self.ability.endsTurnOverride = v
    end
    
    self._endsTurnOverride = v
end

function AbilityAction._set:isSpendableOverride(v)
    if self.ability then
        self.ability.isSpendableOverride = v
    end
    
    self._isSpendableOverride = v
end

function AbilityAction._get:cost()
    return self.ability:getCostFinal()
end

function AbilityAction._set:cost()
    logError("AbilityAction.cost is read only")
end

function AbilityAction._get:endsTurn()
    return self.ability:getEndsTurnFinal()
end

function AbilityAction._set:endsTurn()
    logError("AbilityAction.endsTurn is read only")
end

function AbilityAction._get:isSpendable()
    return self.ability:getIsSpendable()
end

function AbilityAction._set:isSpendable()
    logError("AbilityAction.isSpendable is read only")
end

function AbilityAction:resetOverrides()
    Super.resetOverrides(self)
    
    if self._ability and self._ability.resetOverrides then
        self._ability:resetOverrides()
    end
end

function AbilityAction:getRange()
    return self.ability:getRange()
end

function AbilityAction:getCursor()
    return self.ability:getSelectionCursor()
end

function AbilityAction:getSelectionIcon()
    return self.ability:getSelectionIcon()
end

function AbilityAction:getDisabledCursor()
    return "Sprites/Cursors/Cursor_Null"
end

function AbilityAction:getDisabledStatusIcon()

end

-- is the location chosen for a boss ability attack a valid one?
-- if so, make the correct sound
function AbilityAction:makeErrorSound( damageItem )
    if damageItem and damageItem.projectile and not damageItem.projectile.valid and not self.ability.ignoreProjectilePath then
        Audio.playInvalidTarget()
    else
        Audio.playUIClick()
     end
end

function AbilityAction:onEmptySelection(e)
    if self.ability:getSelectionMode() == "AREA_SELECT" and self:isActionValid() then
        local damageItem = self.ability:getDamageItems() and self.ability:getDamageItems()[1]
        self:makeErrorSound( damageItem )
        if not damageItem or ((not damageItem.projectile) or damageItem.projectile.valid) then
            self._ready = self:isValidForEmptyTarget()
        end
        e.used = true
    end
end

function AbilityAction:isValidForEmptyTarget()
    local valid, reason = AbilityFilterUtils.validForFilterOfType(self.ability, "empty")
    return valid, reason
end

function AbilityAction:createAbilityInfoObjectWithTarget(target)
    local mode = self.ability:getSelectionMode()
    if mode == "AREA_SELECT" then
        local x, y, z
        if target.x and target.y and target.z then
            x = target.x
            y = target.y
            z = target.z
        else
            x, y, z = target:getActor():get3DPosXYZ()
        end
        self:createAbilityInfoObjectWithAoE(x, y, z)
        return
    end

    local targetActor = target:getActor()
    local curAbilityInfoObject = self._potentialAbilityInfoObject
    if curAbilityInfoObject then
        logError(string.format("About to overwrite the current attack object with the new confirmation object for %s executing %s.", self.actor.name, self._id))
        AbilityInformation:release(curAbilityInfoObject)
        self._potentialAbilityInfoObject = nil
    end

    local abilityInfoObject = AbilityInformation:acquire(self.actor, self.ability, self.ability:getDamageItems())
    abilityInfoObject:addActionPosition(self._turnContext.sightMap:getActionPosition(self.agent, target))
    local aoe = self.ability:constructAoE(abilityInfoObject)
    if aoe then
        abilityInfoObject:addAreaOfEffect(aoe)
        abilityInfoObject:setAreaOfEffectTarget(targetActor:get3DPosXYZ())
    end
    abilityInfoObject:addTarget(targetActor)

    self._potentialAbilityInfoObject = abilityInfoObject
end

function AbilityAction:createAbilityInfoObjectWithAoE(x, y, z)
    local ability = self.ability
    local curAbilityInfoObject = self._potentialAbilityInfoObject
    if curAbilityInfoObject then
        logError(string.format("About to overwrite the current attack object with the new confirmation object for %s executing %s.", self.actor.name, self._id))
        AbilityInformation:release(curAbilityInfoObject)
        self._potentialAbilityInfoObject = nil
    end

    local abilityInfoObject = AbilityInformation:acquire(self.actor, ability, ability:getDamageItems())
    self._confirmedPosition = Vector3(x, y, z)

    abilityInfoObject:addAreaOfEffect(ability:constructAoE(abilityInfoObject))
    abilityInfoObject:setAreaOfEffectTarget(x, y, z)
    abilityInfoObject:refreshTargetsFromAoE()

    self._potentialAbilityInfoObject = abilityInfoObject
end

-- TODO: The AI will need to know how to use modifierBehaviours
function AbilityAction:getAbilityInfoObject()
    if self._confirmedAbilityInfoObject ~= nil then
        return self._confirmedAbilityInfoObject
    end

    if not self._potentialAbilityInfoObject then
        local abilityInfoObject = AbilityInformation:acquire(self.actor, self.ability, self.ability:getDamageItems())
        self._potentialAbilityInfoObject = abilityInfoObject
    end

    return self._potentialAbilityInfoObject
end

function AbilityAction:confirmTarget(target)
    local ability = self.ability
    local mode = ability:getSelectionMode()

    if mode == "AREA_SELECT" and not self._confirmedPosition then
        self._confirmedPosition = target and target:getActor():get3DPos()
    end

    self._confirmedTarget = target
    local damageItem = ability:getDamageItems() and ability:getDamageItems()[1]
    self:makeErrorSound( damageItem )
    self._ready = self.ability.ignoreProjectilePath or not damageItem or ((not damageItem.projectile) or damageItem.projectile.valid)
end

function AbilityAction:onFocusDone()
    self._focusScenario = nil

    if self._pendingFocusScenario then
        local focusScenario = self._pendingFocusScenario
        local s = focusScenario and World.createScenario(focusScenario)
        self._pendingFocusScenario = nil

        self._focusScenario = s

        local params = self._pendingFocusScenarioParams
        local actor = params and params["actor"]
        local target = params and params["target"]
        local previousTarget = params and params["previousTarget"]
        local infoObject = params and params["infoObject"]

        self._focusScenario:setOnComplete(self.onFocusDone, self)
        self._focusScenario:start(actor, target, previousTarget, infoObject)
    else
        -- If we have a scenario execution callback then we need to execute it as soon as the LAST target focus has finished
        if self._doAbilityScenario then
            local callback = self._doAbilityScenario
            self._doAbilityScenario = nil
            callback()
        end
    end
end

function AbilityAction:focusTarget(target, previousTarget)
    if previousTarget then
        local previousActor = previousTarget:getActor()
        local anims = previousActor and previousActor.anims
        if anims then
            anims:setPeek(false)
        end

        local potentialOldTarget = self._pendingFocusScenarioParams and self._pendingFocusScenarioParams["previousTarget"]
        if potentialOldTarget and not potentialOldTarget.isDeleted then
            anims = potentialOldTarget.anims
            if anims then
                anims:setPeek(false)
            end
        end
    end

    local focusScenario = self.ability:getAbilityFocus()
    local s = focusScenario and World.createScenario(focusScenario)
    if s then
        if self._focusScenario then
                -- replace the old pending scenario if it exists, it shouldn't have even started yet
                self._pendingFocusScenario = focusScenario
                self._pendingFocusScenarioParams =
                {
                    ["actor"] = self.actor,
                    ["target"] = target and target:getActor(),
                    ["previousTarget"] = previousTarget and previousTarget:getActor(),
                    ["infoObject"] = self._potentialAbilityInfoObject,
                }
        else
            self._focusScenario = s
        end

        -- only start it if there's no other pending scenario
        if not self._pendingFocusScenario then
            s:setOnComplete(self.onFocusDone, self)
            s:start(self.actor, target and target:getActor(), previousTarget and previousTarget:getActor(), self._potentialAbilityInfoObject)
        end
    end
end

function AbilityAction:setTarget(t)
    Super.setTarget(self, t)

    local ability = self.ability
    local potentialAbilityInfoObject = self._potentialAbilityInfoObject
    local mode = ability:getSelectionMode()
    local self_target = self._target
    if mode == "AREA_SELECT" then
        if self_target ~= self._previousTarget then
            if self_target ~= nil then
                -- self_target might be a Vector3
                local targetPos = self_target.getActor and self_target:getActor():get3DPos() or self_target

                if (potentialAbilityInfoObject:getAreaOfEffect() == nil) then
                    return
                end 
                potentialAbilityInfoObject:setAreaOfEffectTarget(targetPos.x, targetPos.y, targetPos.z)
                potentialAbilityInfoObject:refreshTargetsFromAoE()
                ability:showAbilityUI(potentialAbilityInfoObject)

                self._confirmedPosition = targetPos
            end
        else
            if self_target ~= nil then
                -- self_target might be a Vector3
                local damageItem = ability:getDamageItems() and ability:getDamageItems()[1]
                self:makeErrorSound( damageItem )
                if not damageItem or ((not damageItem.projectile) or damageItem.projectile.valid) then
                    local targetPos = self_target.getActor and self_target:getActor():get3DPos() or self_target
                    self._confirmedPosition = targetPos
                    self._confirmedTarget = self_target
                    self._ready = true
                end
            end
        end
    elseif mode == "CHARACTER_SELECT" then
        if self_target ~= self._previousTarget then
            -- If we have an attack object then remove the old target and add the new target
            if potentialAbilityInfoObject then
                if self._previousTarget then
                    ability:hideAbilityUI(potentialAbilityInfoObject)

                    local isValid, _ = self:isValidTarget(self._previousTarget)
                    if isValid then
                        potentialAbilityInfoObject:removeTarget(self._previousTarget:getActor())
                    end


                    potentialAbilityInfoObject:clearActionPosition()
                    local selectionReticleId = self._activeSelectionReticle
                    if selectionReticleId then

                        -- Go through the selected targets to see if this agent already has a selected reticle
                        local previousTargetActor = self._previousTarget:getActor()
                        local found = false
                        for i = 1, #self._selectedTargets do
                            if previousTargetActor == self._selectedTargets[i] then
                                found = true
                                break
                            end
                        end

                        -- If this agent doesn't have a reticle then we need to get rid of this one
                        if not found then
                            Effect.removeCombatTargetReticle(selectionReticleId)
                        end

                        self._activeSelectionReticle = nil
                    end
                end

                if self_target then
                    local targetActor = self_target:getActor()
                    local x, y = self._turnContext.sightMap:getActionPosition(self.agent, self_target)
                    potentialAbilityInfoObject:addActionPosition(x, y)

                    local isValid, _ = self:isValidTarget(self_target)
                    if isValid then
                        potentialAbilityInfoObject:addTarget(self_target:getActor())
                    end

                    if self._potentialSelectedAgent == self_target then
                        self._activeSelectionReticle = self._potentialSelectedReticle
                        self._potentialSelectedReticle = nil
                        self._potentialSelectedAgent = nil
                        Effect.updateCombatTargetReticle(self._activeSelectionReticle, false)
                    else
                        -- Go through the selected targets to see if we can find this agent
                        local found = false
                        for i = 1, #self._selectedTargets do
                            if targetActor == self._selectedTargets[i] then
                                self._activeSelectionReticle = self._selectedReticles[i]
                                found = true
                                break
                            end
                        end
                        -- If the agent does not already have a reticle, then we need to get a new one
                        if not found then
                            self._activeSelectionReticle = Effect.spawnCombatTargetReticle(targetActor, false)
                        end
                    end
                end
            end
            if self_target then
                game:dispatchPooledEvent("onDisplayActionInformation", "action", self, "agent", self_target, "attackInfo", potentialAbilityInfoObject)
                ability:onAbilitySetTarget(self.actor, self_target:getActor(), potentialAbilityInfoObject)
                ability:showAbilityUI(potentialAbilityInfoObject)
            else
                -- Todo: display information that there is no target
                game:dispatchPooledEvent("onHideActionInformation")
            end

            -- TODO: we need a better system for determining if an action has been selected
            if (potentialAbilityInfoObject ~= nil) then
                self:focusTarget(self_target, self._previousTarget)
            end
        else
            if self_target ~= nil then
                self._confirmedTarget = self_target
                self._ready = true
            end
        end
    end
end

function AbilityAction:copyTargetToInfoObject()
    if self._target then
        -- Target is not used for some aoe abilities.
        self._potentialAbilityInfoObject:addTarget(self._target:getActor())
    end
end

function AbilityAction:getConfirmation()
    local source = self._agent

    if source then
        return self.ability:getConfirmation(source:getActor(), self._potentialAbilityInfoObject)
    end
end

function AbilityAction:isValidAsDefault()
    return self.ability:isValidAsDefault()
end

function AbilityAction:isPointValidForCursorSelectionXY(x, y)
    local ability = self.ability
    local mode = ability:getSelectionMode()
    if mode == "AREA_SELECT" then
        local range = ability:getRange()
        if range <= 0 then
            return true
        end

        local source = self._agent and self._agent:getActor()
        if source then
            local sx, sy = source:getGridPosXY()
            sx, sy = sx, sy
            local xDiff = sx - x
            local yDiff = sy - y
            local distSqr = (xDiff * xDiff) + (yDiff * yDiff)
            return distSqr <= (range * range)
        end
    end
    return true
end

function AbilityAction:isActionValid()
    local valid, reason = Super.isActionValid(self)
    if not valid then
        return false, reason
    end
    
    local ability = self.ability

    valid, reason = AbilityFilterUtils.validForFilterOfType(ability, "general")
    if not valid then
        return false, reason
    end

    valid, reason = AbilityFilterUtils.validForFilterOfType(ability, "validity")
    if not valid then
        return false, reason
    end

    if ability:getRequiresValidTargets() then
        valid, reason = self:anyValidTargets()
        return valid, reason
    else
        return true
    end
end

function AbilityAction:anyValidTargets()
    -- Otherwise loop through all possible targets
    local combatSession = self._turnContext.combatSession
    local isValid, reason = false, "$NoValidTargets" --$ No valid targets
    local tempValid, tempReason
    local closestEnemyDist = 999999

    for target in combatSession:allValidCombatAgents() do
        local abilityName = self._ability._name

        if (abilityName == "Stampede") or
            (abilityName == "BullRush") or
            (abilityName == "LastRites") or
            (abilityName == "GunEmDown") or
            (abilityName == "MeatHook") then
            local targetActor = target:getActor()
            local selfActor = self.actor

            local selfAgent = combatSession:getCombatAgent(selfActor)
            local isHostile = target:isHostileTowards(selfAgent)

            if isHostile then
                local sx, xy = selfActor:getGridPosXY()
                local tx, ty = targetActor:getGridPosXY()
                local xDiff = sx - tx
                local yDiff = xy - ty
                local dist = (xDiff * xDiff) + (yDiff * yDiff)

                tempValid, tempReason = self:isValidTarget(target)
                if not tempValid then
                    if not closestEnemyDist then
                        closestEnemyDist = dist
                        isValid, reason = tempValid, tempReason
                    elseif dist < closestEnemyDist then
                        closestEnemyDist = dist
                        isValid, reason = tempValid, tempReason
                    end
                else
                    isValid, reason = tempValid, tempReason
                    break
                end
            end
        else
            isValid, reason = self:isValidTarget(target)
        end

        if isValid then
            isValid, reason = self:isValidTarget(target)
            break
        end
    end

    return isValid, reason
end

function AbilityAction:isValidBeforeCombat()
    return self.ability:isValidBeforeCombat()
end

function AbilityAction:isValidTarget(target)
    local valid, reason = self:isPotentialTarget(target)
    if not valid then
        return false, reason
    end

    local mode = self.ability:getSelectionMode()
    local targetActor = target:getActor()
    if mode == "SELF_SELECT" and (targetActor ~= self.actor) then return false, "$MustTargetSelf" end

    valid, reason = AbilityFilterUtils.validForFilterOfType(self.ability, "target", self.actor, targetActor)
    if not valid then
        return false, reason
    end

    return true
end

function AbilityAction:isValidTargetFromPosition(target, position)
    local isValid, reason = self:isValidTarget(target)
    return (self.ability:getSelectionMode() == "AREA_SELECT"), reason or isValid, reason
end

function AbilityAction:isPotentialTarget(target)
    local targetActor = target:getActor()

    if not target:isValidCombatant() then
        return false,  "$NotValidCombatant" --$ Target is not an active combatant
    end

    local valid, reason = AbilityFilterUtils.validForFilterOfType(self.ability, "potentialTarget", self.actor, targetActor)
    if not valid then
        return false, reason
    end
    return true
end

-- TODO: The AI will need to know how to use the modifierBehaviours
function AbilityAction:onActionAdded()
    local abilityInfoObject = self._potentialAbilityInfoObject
    if abilityInfoObject then
        self._potentialAbilityInfoObject = nil
        self._confirmedAbilityInfoObject = abilityInfoObject
    end

    self.ability:onAbilitySelected(abilityInfoObject)
end

function AbilityAction:interrupt()
    if self._activeScenario ~= nil then
        self._activeScenario:pause()
    end

    if self._abilityScenario ~= nil then
        self._abilityScenario:pause()
    end
end

function AbilityAction:resume()
    if self._activeScenario ~= nil then
        self._activeScenario:resume()
    end

    if self._abilityScenario ~= nil then
        self._abilityScenario:resume()
    end
end

function AbilityAction:onExecuteDone()
    self.actionCancelled = false

    client.transition:disableLayer("ScenarioLayer")

    self._activeScenario = nil
    self._abilityScenario = nil

    if self._onExecuteDone then
        local fc = self._onExecuteDone
        self._onExecuteDone = nil
        fc()
    end

    local abilityInfoObject = self._confirmedAbilityInfoObject
    if abilityInfoObject then
        abilityInfoObject:postProcessAttack()

        self._confirmedAbilityInfoObject = nil
        AbilityInformation:release(abilityInfoObject)
    end
end

function AbilityAction:getTarget()
    local target
    local mode = self.ability:getSelectionMode()
    if mode == "AREA_SELECT" then
        if self._confirmedPosition then
            target = self._confirmedPosition
        elseif self._confirmedTarget then
            target = self._confirmedTarget:getActor():get3DPos()
        end
    elseif self._confirmedTarget then
        target = self._confirmedTarget:getActor()
    end

    return target
end

function AbilityAction:execute(onExecuteDone)
    self.actor.icon:showAbilityActivationAlert(self._ability.tooltipName, self._ability.abilityIcon)

    self._onExecuteDone = onExecuteDone

    local ability = self._ability
    local target = self:getTarget() or false

    if target and ability:getStartsCombat() then
        self.agent:setRecentTarget(self._confirmedTarget)
    end

    -- Process the attack object if there is one
    if self._confirmedAbilityInfoObject then
        self._confirmedAbilityInfoObject:preProcessAttack()
        self._confirmedAbilityInfoObject:process()
        ability:onAbilityInfoProcessed(self._confirmedAbilityInfoObject)
    end

    -- If there is a cooldown then apply it
    local cooldown = self.actor:getModifierValue("abilityCooldown", nil, self.ability:getCooldown())
    if cooldown > 0 then
        self.ability:set("currentCooldown", cooldown + 1) -- We need to add one since ending this turn will cause it to tick down
    end

    local s = World.createScenario(ability:getAbilityExecute())
    if s then
        self._activeScenario = s
        client.transition:enableLayer("ScenarioLayer")

        local abilityScenario = World.createScenario("AbilityExecution")
        self._abilityScenario = abilityScenario

        abilityScenario:setOnComplete(self.onExecuteDone, self)
        if self._focusScenario then
            self._doAbilityScenario = abilityScenario:callback("start", self.actor, target, self.ability, self._confirmedAbilityInfoObject, s, ability:getNeedsStepOutAssistance(), ability:getStepType())
        else
            abilityScenario:start(self.actor, target, self.ability, self._confirmedAbilityInfoObject, s, ability:getNeedsStepOutAssistance(), ability:getStepType())
        end
    end
end

function AbilityAction:mustHaveTarget()
    return true
end

function AbilityAction:startsCombat()
    return self.ability:getStartsCombat()
end

function AbilityAction:readiesPreCombat()
    return self.ability:getReadiesPreCombat()
end

function AbilityAction:getReadyIcon()
    return self.ability:getReadyIcon()
end

function AbilityAction:getConfirmedTarget()
    return self:getTarget()
end

function AbilityAction:onAgentHoverEnter(e)
    self:onAgentCursorEnter(e)
end

function AbilityAction:onAgentHoverExit(e)
    self:onAgentCursorExit(e)
end

function AbilityAction:onAgentCursorEnter(e)
    if self._ability:getSelectionMode() == "CHARACTER_SELECT" then
        local agent = e.target
        -- Make sure the target is not currently selected, and is valid for this ability
        if agent ~= self._target and self:isValidTarget(agent) then
            local found = false
            local actor = agent:getActor()
            -- Go through to see if they have been selected previously by this ability, this means we will reuse the reticle they already have
            for i = 1, #self._selectedTargets do
                if actor == self._selectedTargets[i] then
                    -- We have found an actor and will reuse its reticle
                    self._potentialSelectedReticle = self._selectedReticles[i]
                    self._potentialSelectedAgent = agent
                    Effect.updateCombatTargetReticle(self._potentialSelectedReticle, true)
                    found = true
                    break
                end
            end
            -- If we did not find a reticle then we need to grab one from the effects service
            if not found then
                self._potentialSelectedAgent = agent
                self._potentialSelectedReticle = Effect.spawnCombatTargetReticle(agent:getActor(), true)
            end
        end
    end
end

function AbilityAction:onAgentCursorExit(e)
    if self._ability:getSelectionMode() == "CHARACTER_SELECT" then
        local selectedReticle = self._potentialSelectedReticle
        -- If we have a potential selected reticle, then we need to hide it
        if selectedReticle then
            local agent = e.target
            local found = false
            -- Go through all the selected targets to make sure this reticle isn't in use by one of them
            local actor = agent:getActor()
            for i = 1, #self._selectedTargets do
                if actor == self._selectedTargets[i] then
                    -- If one of the selected targets needs this reticle then stop it animating
                    Effect.updateCombatTargetReticle(self._potentialSelectedReticle, false)
                    found = true
                    break
                end
            end

            -- If no target was found then remove this reticle
            if not found then
                Effect.removeCombatTargetReticle(selectedReticle)
            end

            -- Either way nil out the potential reticle data
            self._potentialSelectedReticle = nil
            self._potentialSelectedAgent = nil
        end
    end
end

function AbilityAction:onPathHover(e)
    local pos = e.hoverPos
    local pathEnd = self._turnContext.moveSet:getPathFromLocation(pos)
    -- Test to see if we should draw one move or two
    local isExtended = pathEnd and pathEnd:hasFlag(MoveInfo.ExtendedMove)
    client.rendering:showExtendedCombatPathGrid(isExtended)
end

function AbilityAction:cursorMoved(pos)
    if not self:isActionValid() then
        return
    end
    local ability = self._ability
    local hit, height = selection:getNavMeshHeightAtPoint(pos)
    if hit then
        self._savedCursorHeight = height
    end
    if ability:getSelectionMode() == "AREA_SELECT" then
        local potentialAbilityInfoObject = self._potentialAbilityInfoObject
        pos = Vector3(pos.x, self._savedCursorHeight, pos.y)

        if ability.snapToGrid then
            pos.x, pos.z = math_floor(pos.x) + 0.5, math_floor(pos.z) + 0.5
        end

        potentialAbilityInfoObject:setAreaOfEffectTarget(pos.x, pos.y, pos.z)
        potentialAbilityInfoObject:refreshTargetsFromAoE()
        ability:showAbilityUI(potentialAbilityInfoObject)

        self._confirmedPosition = pos
    else
        -- Here the cursor has been moved so cancel the ability
        self:deactivateAndClear()
    end
end

function AbilityAction:getDefaultCursorPos()
    local pos
    local actor = self._agent:getActor()
    if actor then
        pos = actor:getPos()
    end
    local ability = self._ability
    local mode = ability and ability:getSelectionMode()
    if mode == "AREA_SELECT" then
        local damageItem = ability:getDamageItems() and ability:getDamageItems()[1]
        local projectile = damageItem and damageItem.projectile
        if projectile then
            -- If we have a projectile then the default cursor pos can't be our own position.
            pos.x = pos.x + 1
        end
    end
    return pos
end

function AbilityAction:updateSelection()
    if not self:isActionValid() then
        return
    end
    local ability = self._ability
    if ability:getSelectionMode() == "AREA_SELECT" then
        local abilityInfoObject = self:getAbilityInfoObject()
        local aoe = abilityInfoObject:getAreaOfEffect()
        if aoe then
            local aoePosX, aoePosY = aoe:getTargetPos()
            local pos = Vector3(aoePosX, self._savedCursorHeight, aoePosY)
            if InputProcessor.getInputMode() == "mouseKeyboard" and self:requiresAdditionalTargets() then
                local success, hitNavMesh, pickX, pickY = selection:getPositionAtMouseXY()
                if success then
                    if hitNavMesh then
                        local hit, height = selection:getNavMeshHeightAtPointXY(pickX, pickY)
                        if hit then
                            self._savedCursorHeight = height
                        end
                    end
                    pos = Vector3(pickX, self._savedCursorHeight, pickY)

                    if ability.snapToGrid then
                        pos.x, pos.z = math_floor(pos.x) + 0.5, math_floor(pos.z) + 0.5
                    end

                    self._confirmedPosition = pos
                end
            end
            abilityInfoObject:setAreaOfEffectTarget(pos.x, pos.y, pos.z)
            abilityInfoObject:refreshTargetsFromAoE()
            ability:showAbilityUI(abilityInfoObject)

            if ability:showAoeFirstTargetBreakdown() then
                local firstTarget = abilityInfoObject:getFirstTarget()
                if self._prevRefreshAoeFirstTargetSelection ~= firstTarget then
                    self._prevRefreshAoeFirstTargetSelection = firstTarget
                    game:dispatchPooledEvent("onDisplayActionInformation", "action", self, "source", self.actor, "targetActor", firstTarget, "attackInfo", abilityInfoObject)
                end
            end
        end
    end
end

function AbilityAction:onActionReadied()
    -- When the action is readied in combat, it is being deferred and will be created again when activated.
    local abilityInfo = self._confirmedAbilityInfoObject
    if abilityInfo then
        self._confirmedAbilityInfoObject = nil
        AbilityInformation:release(abilityInfo)
    end
end

function AbilityAction:onSetActionActive()
    local ability = self._ability
    local mode = ability:getSelectionMode()
    -- If this ability is an attack then grab an attack information object
    self._potentialAbilityInfoObject = AbilityInformation:acquire(self.actor, ability, ability:getDamageItems())
    self._potentialAbilityInfoObject:addAbilityModifiers()

    self._prevRefreshAoeFirstTargetSelection = nil

    ActionDispatcher:addMultiEventListener(actionEvents, self)
    self.actor.combatStatus:setPotentialActionPointsSpent(self:isActionValid() and self.cost or 0)

    local self_target = self._target
    if mode == "AREA_SELECT" then
        game:dispatchPooledEvent("onDisplayActionInformation", "action", self)

        local isValid, reason = self:isActionValid()
        if not isValid then
            return false, reason
        end
    elseif mode == "SELF_SELECT" then
        game:dispatchPooledEvent("onDisplayActionInformation", "action", self, "targetActor", self.actor)
    elseif mode == "CHARACTER_SELECT" then
        local isValid, reason = self:isActionValid()
        if not isValid and reason then
            game:dispatchPooledEvent("onDisplayActionInformation", "action", self, "agent", self_target, "attackInfo", self._potentialAbilityInfoObject)
            return false, reason
        end
    end

    -- If this ability has an Area Of Effect, go ahead and construct it.
    local aoe = ability:constructAoE(self._potentialAbilityInfoObject)
    if aoe then
        self._potentialAbilityInfoObject:addAreaOfEffect(aoe)
    end

    local targetActor = nil
    if self_target and self_target:getActor() then
        targetActor = self_target:getActor()
    end

    if self:isActionValid() then
        ability:onAbilityActivated(self.actor, targetActor)
    end
end

function AbilityAction:onSetActionInactive()
    ActionDispatcher:removeMultiEventListener(actionEvents, self)
    local abilityInfoObject = self._potentialAbilityInfoObject
    local confirmedInfoObject = self._confirmedAbilityInfoObject

    local ability = self._ability
    local agent = self._agent

    client.rendering:hideCombatPathGrid()

    self.actor.combatStatus:setAvailableActions(agent:getRemainingActionPoints(), agent:getMaxActionPoints())

    game:dispatchPooledEvent("onHideActionInformation")

    if self:isActionValid() then
        -- Regardless of why this ability is being deactivated, hide the UI
        -- Improvement: We will likely need to move this if we want to support showing the AoE for invalid actions
        local abilityInfo = abilityInfoObject or confirmedInfoObject
        if abilityInfo then
            ability:hideAbilityUI(abilityInfo)
        end
        -- The ability info object will be nil here if the action was confirmed
        ability:onAbilityDeactivated(self.actor, abilityInfoObject)
    end

    local selectionReticleId = self._activeSelectionReticle
    if selectionReticleId then
        Effect.removeCombatTargetReticle(selectionReticleId)
        self._activeSelectionReticle = nil
    end

    selectionReticleId = self._potentialSelectedReticle
    if selectionReticleId then
        Effect.removeCombatTargetReticle(selectionReticleId)
        self._potentialSelectedReticle = nil
        self._potentialSelectedAgent = nil
    end

    local selectedReticles = self._selectedReticles
    for i = #selectedReticles, 1, -1 do
        Effect.removeCombatTargetReticle(selectedReticles[i])
        selectedReticles[i] = nil
    end

    if abilityInfoObject then
        self._potentialAbilityInfoObject = nil
        AbilityInformation:release(abilityInfoObject)
        -- abilityInfoObject ~= nil means the ability was cancelled
        ActiveWeaponController.onAbilityDeselected()
    end
end

function AbilityAction:onAISelected(source)
    self._ability:onAISelected(source, self:getAbilityInfoObject())
end

function AbilityAction:addConfirmedTarget()
    -- TODO: Need to see about clearing the confirmed target at some point, possibly adjusting the interface for abilities now that all abilities get an info object
    local confirmedTarget = self:getTarget()
    if confirmedTarget == nil then
        logError(string.format("Unable to add confirmed target"))
        return
    end

    local ability = self._ability
    ability:onAddConfirmedTarget(confirmedTarget, self._potentialAbilityInfoObject)
    self._selectedTargets[#self._selectedTargets + 1] = confirmedTarget

    if ability:getSelectionMode() == "CHARACTER_SELECT" then
        self._selectedReticles[#self._selectedReticles + 1] = self._activeSelectionReticle
        self._activeSelectionReticle = nil
    end
end

function AbilityAction:removeLastConfirmedTarget()
    local lastTarget = self._selectedTargets[#self._selectedTargets]
    if self._ability.deactivateOnCancel then
        self:deactivateAndClear()
        return
    end
    if lastTarget then
        self._selectedTargets[#self._selectedTargets] = nil
        self._ability:onRemoveConfirmedTarget(lastTarget.getActor and lastTarget:getActor() or lastTarget, self._potentialAbilityInfoObject)
    end
end

function AbilityAction:requiresAdditionalTargets()
    local targetCount = #self._selectedTargets
    return targetCount < self.ability:getRequiredTargetCount()
end

function AbilityAction:getSelectedTargetCount()
    return #self._selectedTargets
end

function AbilityAction:clear()
    Super.clear(self)
    clearTable(self._selectedTargets)
    if World.uiData.selectedAbility == self.ability then
        World.uiData.selectedAbility = nil
    end
end

function AbilityAction:setContext(ctx)
    Super.setContext(self, ctx)
    self._ability:set("turnContext", ctx)
end

function AbilityAction:getBattleScript()
    if self._ability == nil then
        logError("Attempting to access the ability ")
        return
    end
    return self._ability.aiScript
end

function AbilityAction:clearPotentialInfoObject()
    local curAbilityInfoObject = self._potentialAbilityInfoObject
    if curAbilityInfoObject then
        AbilityInformation:release(curAbilityInfoObject)
        self._potentialAbilityInfoObject = nil
    end
end

function AbilityAction:onCombatEnd()
    self._ability:set("turnContext", nil)
    self._ability:set("actionContext", nil)
    game:removeEventListener("onCombatEnd", self)
    if self._ability:isOnCooldown() then
        self._ability:set("currentCooldown", 0)
    end
end

function AbilityAction:onCombatTurnEnd()
    if self._ability:isOnCooldown() then
        self._ability:set("currentCooldown", self._ability.currentCooldown - 1)
    end
end

function AbilityAction:getUIOrder()
    return self._ability.uiOrder or 0
end

function AbilityAction:consumesItem()
    -- MEGAMOD FIX: a weapon switch can pool-release this action while its attack
    -- scenario is still executing, leaving self.ability nil; erroring here stalls
    -- the turn state machine every frame (hard freeze). Treat as "no item".
    local ability = self.ability
    return ability ~= nil and ability:getConsumesItem()
end

function AbilityAction:getItems()
    -- MEGAMOD FIX: nil-safe for the same pool-release race as consumesItem
    local ability = self.ability
    return ability and ability.items
end

function AbilityAction:validForFilter(filterTag)
    local id = self._id
    -- We might need a tag which allows abilities to always be valid
    return filterTag == id or self._name == filterTag or self._executeName == filterTag or ConfigBuilder_hasTag(id, filterTag)
end

function AbilityAction:onPoolAcquire(agent, ability)
    ability:set("actionContext", self)

    self._ability = ability
    self._id = ability.scriptId

    self._maxPerTurn = ability.maxPerTurn
    self._endsTurn = ability.endsTurn
    self._executeName = ability:getAbilityExecute()
    self._name = ability._name
    
    self._isSpendable = ability:getIsSpendable()
    
    self._costOverride = ability.costOverride
    self._endsTurnOverride = ability.endsTurnOverride
    self._isSpendableOverride = ability.isSpendableOverride

    self._ready = false
    self._agent = agent

    self._selectedTargets = _tablePool:acquire()
    self._selectedReticles = _tablePool:acquire()

    game:addEventListener("onCombatEnd", self)
    agent:getActor():addEventListener("onCombatTurnEnd", self)
    self._savedCursorHeight = 0
end

function AbilityAction:onPoolRelease()
    game:removeEventListener("onCombatEnd", self)
    self._agent:getActor():removeEventListener("onCombatTurnEnd", self)

    self._ability:set("actionContext", nil)
    self._ability = nil
    self._id = nil

    self._maxPerTurn = nil
    self._endsTurn = nil
    self._name = nil

    local selectedTargets = self._selectedTargets
    self._selectedTargets = nil
    _tablePool:releaseAndClear(selectedTargets)

    local selectedReticles = self._selectedReticles
    self._selectedReticles = nil
    for i = #selectedReticles, 1, -1 do
        Effect.removeCombatTargetReticle(selectedReticles[i])
        selectedReticles[i] = nil
    end
    _tablePool:release(selectedReticles)

    self._confirmedTarget = nil
    self._confirmedPosition = nil
    local curAbilityInfoObject = self._potentialAbilityInfoObject
    if curAbilityInfoObject then
        AbilityInformation:release(curAbilityInfoObject)
        self._potentialAbilityInfoObject = nil
    end
    self._activeScenario = nil
    self._focusScenario = nil
    self._doAbilityScenario = nil

    self._ready = nil
    self._agent = nil
    self._savedCursorHeight = nil
    self._pendingFocusScenario = nil
    if self._pendingFocusScenarioParams then
        clearTable(self._pendingFocusScenarioParams)
        self._pendingFocusScenarioParams = nil
    end
end

function AbilityAction:init(agent, ability)
    self.kind = "ITEM_ACTION"
    return self
end

return newClass("RomeroGames.Combat.Actions.AbilityAction", AbilityAction, Super )

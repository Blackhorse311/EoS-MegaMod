local CombatAction = require( "Combat.CombatAction" )
local AbilityInformation = require("Combat.AbilityInformation")
local ActionDispatcher = require("Libs.ActionDispatcher")
local CursorActionsController = require("UI.Combat.CursorActionsController")
local CombatCalculations = require("Combat.CombatCalculations")
local ConfigBuilder = require("Libs.ConfigBuilder")
local InputProcessor = require("Libs.InputProcessor")
local World = require("World.World")
local Jobs = require("Libs.Jobs")
local AbilityFilterUtils = require("Combat.AbilityFilterUtils")
local Effect = require("Libs.Effect")
local ActiveWeaponController = require("UI.Combat.ActiveWeaponController")

local CoverState = RomeroGames.CoverState
local CombatCalculations_canSeeXY = CombatCalculations.canSeeXY
local CombatCalculations_getHeightXY = CombatCalculations.getHeightXY
local ConfigBuilder_hasTag = ConfigBuilder.hasTag
local CombatReticles_getMeleeReticle
local CombatReticles_releaseMeleeReticle

local function getCombatReticleFunctions()
    if CombatReticles_getMeleeReticle == nil then
        local reticles = require("Libs.CombatReticles")
        CombatReticles_getMeleeReticle = reticles.getMeleeReticle
        CombatReticles_releaseMeleeReticle = reticles.releaseMeleeReticle
    end
end

local Super = CombatAction

local MoveInfo = RomeroGames.Move.MoveInfo

local Vector2 = UnityEngine.Vector2
local selection = client.selection
local math_floor = math.floor
local math_approx = math.approx
local _tablePool = newTablePool({initialCapacity = 32, incrementalCapacity = 8})
local _minRunStartAnimPathDist = 2

local actionEvents =
{
    "onEmptySelection",
    "onPathHover",
    "onAgentHoverEnter",
    "onAgentHoverExit",
    "onAgentCursorEnter",
    "onAgentCursorExit",
    "onAgentSelected",
}

local cameraEvents =
{
    "onCameraLeft",
    "onCameraRight",
    "onCameraForward",
    "onCameraBack",
}

local MeleeAbilityAction = {}
MeleeAbilityAction._get = {}
MeleeAbilityAction._set = {}

-- This overrides the getter, the setter in CombatAction is still valid
function MeleeAbilityAction._get:id()
    return self._id
end

function MeleeAbilityAction._get:ability()
    return self._ability
end

function MeleeAbilityAction._set:ability()
    logError("MeleeAbilityAction.ability is read only")
end

function MeleeAbilityAction._set:costOverride(v)
    if self.ability then
        self.ability.costOverride = v
    end
    
    self._costOverride = v
end

function MeleeAbilityAction._set:endsTurnOverride(v)
    if self.ability then
        self.ability.endsTurnOverride = v
    end
    
    self._endsTurnOverride = v
end

function MeleeAbilityAction._set:isSpendableOverride(v)
    if self.ability then
        self.ability.isSpendableOverride = v
    end
    
    self._isSpendableOverride = v
end

function MeleeAbilityAction._get:cost()
    local abilityCost = self.ability:getCostFinal()

    if self.ability.useExplicitCost then
        return abilityCost
    else
        if not self._curPath then
            return abilityCost
        end

        local pathCost = self._curPath.cost

        if pathCost == nil or pathCost <= 0 then
            return abilityCost
        end

        local movement = self.actor:getModifierValue("movement")

        if movement == nil or movement <= 0 then
            return abilityCost
        end

        local movementCost = math.ceil(pathCost / movement)

        -- If you move a single distance, the movement increment is 0. 
        -- If you move a double distance, the movement increment is 1, and so on.
        local movementIncrement = movementCost - 1

        if movementIncrement < 0 then
            movementIncrement = 0
        end

        return abilityCost + movementIncrement
    end
end

function MeleeAbilityAction._get:endsTurn()
    return self.ability:getEndsTurnFinal()
end

function MeleeAbilityAction._set:endsTurn()
    logError("AbilityAction.endsTurn is read only")
end

function MeleeAbilityAction._get:isSpendable()
    return self.ability:getIsSpendable()
end

function MeleeAbilityAction._set:isSpendable()
    logError("AbilityAction.isSpendable is read only")
end

function MeleeAbilityAction:resetOverrides()
    Super.resetOverrides(self)
    
    if self._ability and self._ability.resetOverrides then
        self._ability:resetOverrides()
    end
end

function MeleeAbilityAction:getCursor()
    return self.ability:getSelectionCursor()
end

function MeleeAbilityAction:getSelectionIcon()
    return self.ability:getSelectionIcon()
end

function MeleeAbilityAction:getDisabledCursor()
    return "Sprites/Cursors/Cursor_Null"
end

function MeleeAbilityAction:getDisabledStatusIcon()
end

function MeleeAbilityAction:onEmptySelection(e)
    local turnContext = self._turnContext
    local hit, pos
    if self._mode == "mouseKeyboard" then
        hit, pos = client.selection:performGroundPick()
    elseif turnContext then
        hit, pos = true, turnContext.cursor
    else
        hit = false
    end

    if hit then
        local moveSet = turnContext.moveSet
        if self:useCustomMove() then
            moveSet = turnContext.moveThroughActorsMoveSet or turnContext.moveSet
        end
        local pathEnd = moveSet:getPathFromLocation(pos)
        if pathEnd and pathEnd == self._curPath then
            self._ready = true
            self._confirmedTarget = self._target
        end
    end

    if self:isActionValid() then
        e.used = true
    end
end

function MeleeAbilityAction:setCurPath(path)
    self._curPath = path
    local target = self._target or self._confirmedTarget
    if target then
        self:updateAoePath(self:getAbilityInfoObject(), target:getActor())
    end
end

function MeleeAbilityAction:createAbilityInfoObjectWithTarget(target)
    local curAbilityInfoObject = self._potentialAbilityInfoObject
    if curAbilityInfoObject then
        logError(string.format("About to overwrite the current attack object with the new confirmation object for %s executing %s.", self.actor.name, self._id))
        AbilityInformation:release(curAbilityInfoObject)
        self._potentialAbilityInfoObject = nil
    end

    local abilityInfoObject = AbilityInformation:acquire(self.actor, self.ability, self.ability:getDamageItems())
    abilityInfoObject:addTarget(target:getActor())
    local aoe = self.ability:constructAoE(abilityInfoObject)
    if aoe then
        abilityInfoObject:addAreaOfEffect(aoe)
    end
    self._potentialAbilityInfoObject = abilityInfoObject
end

function MeleeAbilityAction:getAbilityInfoObject()
    if self._confirmedAbilityInfoObject ~= nil then
        return self._confirmedAbilityInfoObject
    end

    if not self._potentialAbilityInfoObject then
        local abilityInfoObject = AbilityInformation:acquire(self.actor, self.ability, self.ability:getDamageItems())
        self._potentialAbilityInfoObject = abilityInfoObject
    end

    return self._potentialAbilityInfoObject
end

function MeleeAbilityAction:confirmTarget(target)
    self._confirmedTarget = target
    self._ready = true
end

function MeleeAbilityAction:updateAoePath(abilityInfoObject, targetActor, showPath)
    local ability = self.ability
    if abilityInfoObject and targetActor then
        local aoe = abilityInfoObject:getAreaOfEffect()
        if aoe then
            aoe:setPathEnd(self._curPath)
            aoe:populateAffectedCells(ability:getIgnoreSource(), ability:getCheckTargetSteps())
            aoe:populateTargetsFromCombatSession(self._turnContext.combatSession, self._source, self.ability)
            abilityInfoObject:refreshTargetsFromAoE(targetActor)
        end
    end
end

function MeleeAbilityAction:setTarget(t)
    Super.setTarget(self, t)
    if self._target and (self._target == self._previousTarget) then
        self._confirmedTarget = self._target
        self._ready = true
    elseif self._target ~= self._previousTarget then
        local showActionInformation
        local target = self._target
        local targetActor = target and target:getActor()
        local targetData = targetActor and self._targetsData[targetActor]

        local selectedReticle = self._selectedReticle
        if selectedReticle then
            Effect.removeCombatTargetReticle(selectedReticle)
            self._selectedReticle = nil
        end

        if target then
            if self._potentialSelectedAgent == target then
                self._selectedReticle = self._potentialSelectedReticle
                self._potentialSelectedReticle = nil
                self._potentialSelectedAgent = nil
                Effect.updateCombatTargetReticle(self._selectedReticle, false)
            else
                self._selectedReticle = Effect.spawnCombatTargetReticle(targetActor, false)
            end
        end

        if targetData == true then
            self._curPath = nil
            self.actor.meleeDistance = 0
            
            if self._targetReticle then
                client.ui:drawPath(nil, false, false)
                CombatReticles_releaseMeleeReticle(self._targetReticle)
                self._targetReticle = nil
            end
            if self.pointList then
                client.ui:removeAreaOfEffectPointList(self.pointList)
                self.pointList = nil
            end
            client.ui:updateAreaOfEffect()

            client.ui:showCursorActions(CursorActionsController.layout)
            CursorActionsController.setActionPointCost(self.cost)
            self.actor.combatStatus:setPotentialActionPointsSpent(self.cost)
            self.actor.combatStatus:setAvailableActions(self.agent:getRemainingActionPoints(), self.agent:getMaxActionPoints())
            showActionInformation = true
            self.ability:onAbilitySetTarget(self.actor, targetActor, self._potentialAbilityInfoObject)

        elseif targetData then
            if not self._targetReticle then
                self._targetReticle = CombatReticles_getMeleeReticle(self.ability:getMeleeMoveCursor())
            end
            if self.pointList then
                client.ui:removeAreaOfEffectPointList(self.pointList)
                self.pointList = nil
            end
            self.pointList = client.rendering:getPointList()
            local pointList = self.pointList

            -- Go through and get the closest path as default, also add all the points to the AoE display
            local count = #targetData
            local bestPath = targetData[1]
            local bestCost = bestPath.cost
            local x, y = bestPath.pos.x, bestPath.pos.y

            local height, heightValid = CombatCalculations_getHeightXY(math_floor(x), math_floor(y))
            if heightValid then
                pointList:addPoint(x, height, y, "empty")
            end

            for i = 2, count do
                local cur = targetData[i]
                x, y = cur.pos.x, cur.pos.y
                height, heightValid = CombatCalculations_getHeightXY(math_floor(x), math_floor(y))
                if heightValid then
                    pointList:addPoint(x, height, y, "empty")
                end

                if cur.cost < bestCost then
                    bestCost = cur.cost
                    bestPath = cur
                end
            end

            self._curPath = bestPath
            self._targetReticle:setPosition(self._curPath.pos)

            client.ui:showCursorActions(CursorActionsController.layout)
            CursorActionsController.setActionPointCost(self.cost)

            self.actor.combatStatus:setPotentialActionPointsSpent(self.cost)

            self.actor.meleeDistance = math.ceil(self._curPath.cost)

            if type(bestPath) == "userdata" then
                local isExtended = bestPath and bestPath:hasFlag(MoveInfo.ExtendedMove)
                client.rendering:showExtendedCombatPathGrid(isExtended)
                if self.ability.drawCustomPath then
                    self.ability:drawCustomPath(bestPath, true, false)
                else
                    client.ui:drawPath(bestPath, true, false)
                end
            else
                client.ui:drawPath(nil, true, false)
            end
            client.ui:addAreaOfEffectPointList(pointList)
            client.ui:showAreaOfEffect()
            local abilityInfo = self._potentialAbilityInfoObject
            if abilityInfo and targetActor then
                self:updateAoePath(abilityInfo, targetActor)
                self.ability:showAbilityUI(abilityInfo)
            end
            self.ability:onAbilitySetTarget(self.actor, targetActor, abilityInfo)
            showActionInformation = true
        else
            if self._targetReticle then
                client.ui:drawPath(nil, false, false)
                CombatReticles_releaseMeleeReticle(self._targetReticle)
                self._targetReticle = nil
            end

            -- Should we always show the info? (YES!)
            showActionInformation = true
        end
        -- If we have an attack object then remove the old target and add the new target
        if self._potentialAbilityInfoObject then
            if self._previousTarget then
                local isValid, _ = self:isValidTarget(self._previousTarget)
                if isValid then
                    self._potentialAbilityInfoObject:removeTarget(self._previousTarget:getActor())
                end
            end

            if self._target then
                local isValid, _ = self:isValidTarget(self._target)
                if isValid then
                    self._potentialAbilityInfoObject:addTarget(self._target:getActor())
                end
            end
        end
        if showActionInformation then
            game:dispatchPooledEvent("onDisplayActionInformation", "action", self, "agent", self._target, "attackInfo", self._potentialAbilityInfoObject)
        else
            game:dispatchPooledEvent("onHideActionInformation")
        end
    end
end

function MeleeAbilityAction:getConfirmation()
    local source = self._agent

    if source then
        return self.ability:getConfirmation(source:getActor(), self._potentialAbilityInfoObject)
    end
end

function MeleeAbilityAction:isValidAsDefault()
    local source = self._agent
    local thisActor = source:getActor()
    local shooter = thisActor.shooter
    local activeWeapon = shooter and shooter.activeWeapon
    local meleeWeapon = shooter and shooter.meleeWeapon
    local isMeleeActiveWeapon = activeWeapon and (activeWeapon == meleeWeapon)
    return isMeleeActiveWeapon and self.ability:isValidAsDefault()
end

function MeleeAbilityAction:isPointValidForCursorSelectionXY(x, y)
    if self._target then
        local targetActor = self._target:getActor()
        if targetActor then
            local tx, ty = targetActor:getGridPosXY()
            local xDiff = tx - x
            local yDiff = ty - y
            local distSqr = (xDiff * xDiff) + (yDiff * yDiff)
            if distSqr < 4 then
                return true
            end
        end
    end
    return false
end

function MeleeAbilityAction:isActionValid()
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

function MeleeAbilityAction:isValidBeforeCombat()
    return self.ability:isValidBeforeCombat()
end

local function pathEndXY(self)
    return self.pos.x, self.pos.y
end

local function setIsValidPath(x, y, px, py, sx, sy, moveSet, validityTable, canSeeTable, index)
    if CombatCalculations_canSeeXY(x, y, px, py, false, true) then
        canSeeTable[index] = true
        local pathEnd = moveSet:getPathFromLocationXY(x, y)
        local isSourcePos = (x == sx and y == sy)
        if pathEnd or isSourcePos then
            if pathEnd == nil and isSourcePos then
                -- Not using the table pool since it might not be easy to release these tables
                pathEnd = {}
                pathEnd.cost = 0
                pathEnd.pos = Vector2(x + 0.5, y + 0.5)
                pathEnd.XY = pathEndXY
            end
            validityTable[#validityTable + 1] = pathEnd
        end
    end
end

local Left = 1
local Right = 2
local Down = 3
local Up = 4
local BottomLeft = 5
local BottomRight = 6
local TopLeft = 7
local TopRight = 8
function MeleeAbilityAction:calculateTargetValidity(actor)
    local targetsData = self._targetsData
    if actor == self._agent:getActor() then
        targetsData[actor] = true
        return true
    end
    local turnContext = self._turnContext
    local moveSet = turnContext.moveSet
    if self:useCustomMove() then
        moveSet = turnContext.moveThroughActorsMoveSet or turnContext.moveSet
    end
    local sourcePos = self.actor:getGridPos()
    local pos = actor:getGridPos()
    local px, py = pos.x, pos.y
    local sx, sy = sourcePos.x, sourcePos.y

    local validPaths = _tablePool:acquire()
    local canSee = _tablePool:acquire()

    if moveSet == nil then
        logError("NIL MOVE SET", self._agent:getActor().name, self._id, "target:", actor.name)
    end

    -- Check the cardinal directions first, we will need this data when checking diagonals
    setIsValidPath(px - 1, py, px, py, sx, sy, moveSet, validPaths, canSee, Left) -- Left
    setIsValidPath(px + 1, py, px, py, sx, sy, moveSet, validPaths, canSee, Right) -- Right
    setIsValidPath(px, py - 1, px, py, sx, sy, moveSet, validPaths, canSee, Down) -- Down
    setIsValidPath(px, py + 1, px, py, sx, sy, moveSet, validPaths, canSee, Up) -- Up

    -- Check the diagonals, making sure that the adjacent cardinals are true first
    if canSee[Left] and canSee[Down] then
        setIsValidPath(px - 1, py - 1, px, py, sx, sy, moveSet, validPaths, canSee, BottomLeft) -- Bottom Left
    end

    if canSee[Right] and canSee[Down] then
        setIsValidPath(px + 1, py - 1, px, py, sx, sy, moveSet, validPaths, canSee, BottomRight) -- Bottom Right
    end

    if canSee[Left] and canSee[Up] then
        setIsValidPath(px - 1, py + 1, px, py, sx, sy, moveSet, validPaths, canSee, TopLeft) -- Top Left
    end

    if canSee[Right] and canSee[Up] then
        setIsValidPath(px + 1, py + 1, px, py, sx, sy, moveSet, validPaths, canSee, TopRight) -- Top Right
    end

    _tablePool:releaseAndClear(canSee)

    if #validPaths > 0 then
        targetsData[actor] = validPaths
        return true
    else
        targetsData[actor] = false
        _tablePool:release(validPaths)
        return false, "$OutOfMovementRange" --$ Out of Movement Range
    end
end

function MeleeAbilityAction:clearTargetsData()
    local targetsData = self._targetsData
    for k, v in next, targetsData do
        -- if V is TRUE then we can't treat it like a table
        if type(v) == "table" then
            clearTable(v)
            _tablePool:release(v)
        end
        targetsData[k] = nil
    end
end

function MeleeAbilityAction:getDataForTarget(target)
    return self._targetsData[target]
end

function MeleeAbilityAction:anyValidTargets()
    -- Otherwise loop through all possible targets
    if not self._turnContext then return false end
    if not self._turnContext.moveSet then return false, "$NoValidTargets" end

    local combatSession = self._turnContext.combatSession
    local isValid, reason = false, "$NoValidTargets"

    for target in combatSession:allValidCombatAgents() do
        isValid, reason = self:isValidTarget(target)
        if isValid then
            isValid, reason = self:isValidTarget(target)
            break
        end
    end
    return isValid, reason
end

function MeleeAbilityAction:isValidTarget(target)
    local valid, reason = self:isPotentialTarget(target)
    if not valid then
        return false, reason
    end

    local targetActor = target:getActor()
    valid, reason = AbilityFilterUtils.validForFilterOfType(self.ability, "target", self.actor, targetActor)
    if not valid then
        return false, reason
    end

    local targetsData = self._targetsData
    local actorData = targetsData[targetActor]
    if actorData then
        return true
    end

    if actorData == false then
        return false, "$OutOfMovementRange"
    end
    -- Finally, if actorData is nil then we need to calculate if the actor is valid
    return self:calculateTargetValidity(targetActor)
end

function MeleeAbilityAction:isValidTargetFromPosition(target, position)
    local isValid, reason = self:isValidTarget(target)
    return isValid, reason
end

function MeleeAbilityAction:isPotentialTarget(target)
    local targetActor = target:getActor()

    if not target:isValidCombatant() then
        return false,  "$NotValidCombatant"
    end

    local valid, reason = AbilityFilterUtils.validForFilterOfType(self.ability, "potentialTarget", self.actor, targetActor)
    if not valid then
        return false, reason
    end
    return true
end

function MeleeAbilityAction:onActionAdded()
    local abilityInfoObject = self._potentialAbilityInfoObject
    if abilityInfoObject then
        self._potentialAbilityInfoObject = nil
        self._confirmedAbilityInfoObject = abilityInfoObject
    end

    self.ability:onAbilitySelected(abilityInfoObject)
end

function MeleeAbilityAction:onExecuteDone()
    self.actionCancelled = false

    client.transition:disableLayer("ScenarioLayer")
    self._activeScenario = nil

    local combatSession = World.combatSession
    combatSession:updateActorPosition(self.actor)
    CombatCalculations.setCoverDirection(self.actor)

    -- Reset the camera follow flag
    self._doCameraFollow = true

    self.actor.anims:enterCover()

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

    self.actor.meleeDistance = 0
end

function MeleeAbilityAction:onPathEnd()
    -- print("MoveAction:onPathEnd", self._moveOption)
    self._pathComplete = true
    self._curPath = nil

    if self.actor.combatTemp.isMeleeMove then
        ActionDispatcher:removeMultiEventListener(cameraEvents, self._cameraEventCallback)
        self.actor.combatTemp.isMeleeMove = nil
    end

    CombatCalculations.updateCoverState(self.actor)

    local target = self._confirmedTarget and (self._confirmedTarget.getActor and self._confirmedTarget:getActor() or self._confirmedTarget)
    target = target ~= nil and target or false

    local s = World.createScenario(self.ability:getAbilityExecute())
    if s then
        self._activeScenario = s
        client.transition:enableLayer("ScenarioLayer")

        s:setOnComplete(self.onExecuteDone, self)
        s:start(self.actor, target, self.ability, self._confirmedAbilityInfoObject)
    end
end

function MeleeAbilityAction:interrupt()
    -- If the path is complete and there is a scenario then use the regular ability action interrupt
    if self._pathComplete then
        if self._activeScenario ~= nil then
            self._activeScenario:pause()
        end
    else
        self._cameraFollow = false

        self._jobList:pause()
        CombatCalculations.setCoverDirection(self.actor)
        CombatCalculations.updateCoverState(self.actor)
    end
end

function MeleeAbilityAction:resume()
    if self._pathComplete then
        if self._activeScenario ~= nil then
            self._activeScenario:resume()
        end
        return
    end

    self._cameraFollow = self._doCameraFollow

    if self.actor.health:isActive() and self.actor.navigation:getActive() and not self.actionCancelled then
        self._jobList:resume()
    else
        if self._jobList then
            self.actor.navigation:resumeMovement()
            self.actor.navigation:stopPath()
            self._jobList:stop()
            self._jobList:clear()
            self:onExecuteDone()
        end
    end
end

function MeleeAbilityAction:cancel()
    Super.cancel(self)

    local ability = self._ability
    local previousWeaponIndex = ability.previousActiveWeaponIdx
    if previousWeaponIndex then
        self.actor.shooter:setActiveWeaponIndex(previousWeaponIndex)
    end

    local attackHasStarted = ability.attackHasStarted
    if attackHasStarted then
        ability.attackHasStarted = false
    end
end

function MeleeAbilityAction:onCameraEvent()
    self._cameraFollow = false
    self._doCameraFollow = false
end


local function handleDelayedRunStart(self)
    self.actor.anims:setAnimTrigger("RunStart")
end

function MeleeAbilityAction:execute(onExecuteDone)
    self.actor.icon:showAbilityActivationAlert(self._ability.tooltipName, self._ability.abilityIcon)

    game:dispatchPooledEvent("onCombatAgentMoveStarted", "target", self.agent)

    local actor = self.actor

    if not actor.health:isActive() or self.actionCancelled then
        local function finishExecution()
            -- Don't call self:onExecuteDone() here since the ability never got a chance to get set up
            onExecuteDone()
            AbilityInformation:release(self._confirmedAbilityInfoObject)
            self._confirmedAbilityInfoObject = nil
            self.actor.meleeDistance = 0
        end
        local jobs = Jobs.newJobList()
        jobs:wait(2)
            :invoke(finishExecution)
            :start()

        actor:dispatchPooledEvent("onActorStopMovingInCombat", "kind", "MoveAction")
        game:dispatchPooledEvent("onActorStopMovingInCombat", "kind", "MoveAction", "target", actor)
        return
    end

    self._onExecuteDone = onExecuteDone

    -- Process the attack object if there is one
    if self._confirmedAbilityInfoObject then
        self._confirmedAbilityInfoObject:preProcessAttack()
        self._confirmedAbilityInfoObject:process()
        self._ability:onAbilityInfoProcessed(self._confirmedAbilityInfoObject)
    end

    -- If there is a cooldown then apply it
    local cooldown = self.actor:getModifierValue("abilityCooldown", nil, self.ability:getCooldown())
    if cooldown > 0 then
        self.ability:set("currentCooldown", cooldown + 1) -- We need to add one since ending this turn will cause it to tick down
    end

    -- Todo: set movement speed depending on config, items, status etc
    if self:shouldMove() and not self:useCustomMove() then

        -- make the onMove sound, unless this character is going to heal someone
        local snd = "onMove"
        if self._ability:getAbilityCategory() == "healing" then
            if actor:doesCharacterSoundExist( "onGetHealed" ) then
                snd = "onGetHealed"
            else
                snd = "onGrunt"
            end
        end

        -- if the snd exists, play it
        if actor:doesCharacterSoundExist( snd ) then
            actor:playCharacterSound( snd )
        else
            actor:playCharacterNegative()
        end

        self._cameraFollow = true
        ActionDispatcher:addMultiEventListener(cameraEvents, self._cameraEventCallback)

        self.actor.combatTemp.isMeleeMove = true
        self._pathComplete = false
        self.actor.navigation:setSpeedRun()

        self.actor.anims:cancelIdle()
        self.actor.anims:exitCover()

        local m = self._curPath
        local prev = m.p

        while prev.p ~= nil do
            m, prev = prev, prev.p
        end

        local mx, my = m:XY()
        local px, py = prev:XY()

        local playStartAnim = true
        -- If m is still pathEnd at this point then the path is a straight line
        if m == self._curPath then
            -- Make sure the path is long enough for the animation
            playStartAnim = math.sqrMagnitude(mx, my, px, py) >= (_minRunStartAnimPathDist * _minRunStartAnimPathDist)
        end

        local jobs = Jobs.newJobList()
        if playStartAnim then
            jobs:invoke(handleDelayedRunStart, self)
                :waitForEvent(self.actor, "onMovementStart", 2)
        end

        jobs:task(self.actor.navigation:getCombatMoveJob(self._curPath))
            :invoke(self.onPathEnd, self)
            :start()
        self._jobList = jobs

        CombatCalculations.setCoverState(self.actor, CoverState.None)

        self._curX, self._curY = self.actor:getGridPosXY()

    else
        self:onPathEnd()
    end
end

function MeleeAbilityAction:shouldMove()
    return type(self._curPath) == "userdata"
end

function MeleeAbilityAction:useCustomMove()
    return self.ability.useCustomMove
end

function MeleeAbilityAction:updateExecution()
    CombatCalculations.updateCoverState(self.actor)

    if self._cameraFollow then
        client.camera:getActiveCamera():moveToFocalPoint(self.actor:getPos(), 0.5)
    end

    local selfCurX = self._curX
    local selfCurY = self._curY
    local x, y = self.actor:getGridPosXY()
    if x ~= selfCurX or y ~= selfCurY then
        self._curX = x
        self._curY = y
        if selfCurX and selfCurY then
            game:dispatchPooledEvent("onCombatAgentMoved", "target", self.agent, "x", x, "y", y, "action", self)
        end
    end
end

function MeleeAbilityAction:mustHaveTarget()
    return true
end

function MeleeAbilityAction:startsCombat()
    return self.ability:getStartsCombat()
end

function MeleeAbilityAction:readiesPreCombat()
    return self.ability:getReadiesPreCombat()
end

function MeleeAbilityAction:onActionReadied()
    -- When the action is readied in combat, it is being deferred and will be created again when activated.
    local abilityInfo = self._confirmedAbilityInfoObject
    if abilityInfo then
        self._confirmedAbilityInfoObject = nil
        AbilityInformation:release(abilityInfo)
    end
end

function MeleeAbilityAction:onSetActionActive()
    game:addEventListener("onInputSourceChanged", self)
    self._mode = InputProcessor.getInputMode()

    self._potentialAbilityInfoObject = AbilityInformation:acquire(self.actor, self.ability, self.ability:getDamageItems())
    self._potentialAbilityInfoObject:addAbilityModifiers()

    ActionDispatcher:addMultiEventListener(actionEvents, self)
    self.actor.combatStatus:setPotentialActionPointsSpent(self.cost)

    game:dispatchPooledEvent("onDisplayActionInformation", "action", self, "agent", self._target, "attackInfo", self._potentialAbilityInfoObject)

    local targetActor = nil
    if self._target and self._target:getActor() then
        targetActor = self._target:getActor()
    end

    local ability = self.ability
    -- If this ability has an Area Of Effect, go ahead and construct it.
    local aoe = ability:constructAoE(self._potentialAbilityInfoObject)
    if aoe then
        self._potentialAbilityInfoObject:addAreaOfEffect(aoe)
    end

    ability:onAbilityActivated(self.actor, targetActor)

    client.rendering:showCombatPathGrid()
    self._curPath = nil
end

function MeleeAbilityAction:onSetActionInactive()
    game:removeEventListener("onInputSourceChanged", self)
    ActionDispatcher:removeMultiEventListener(actionEvents, self)

    self.actor.combatStatus:setAvailableActions(self.agent:getRemainingActionPoints(), self.agent:getMaxActionPoints())

    game:dispatchPooledEvent("onHideActionInformation")
    local abilityInfoObject = self._potentialAbilityInfoObject

    -- The ability info object will be nil here if the action was confirmed
    self.ability:onAbilityDeactivated(self.actor, abilityInfoObject)
    if self:isActionValid() then
        self.ability:hideAbilityUI(abilityInfoObject or self._confirmedAbilityInfoObject)
    end
    if abilityInfoObject then -- Note: the action was cancelled if abilityInfoObject is not nil
        self._potentialAbilityInfoObject = nil
        self._curPath = nil
        AbilityInformation:release(abilityInfoObject)

        ActiveWeaponController.onAbilityDeselected()
    end

    if self._targetReticle then
        client.ui:drawPath(nil, false, false)
        CombatReticles_releaseMeleeReticle(self._targetReticle)
        self._targetReticle = nil
    end

    client.rendering:hideCombatPathGrid()
    if self.pointList then
        client.ui:removeAreaOfEffectPointList(self.pointList)
        self.pointList = nil
        client.ui:updateAreaOfEffect()
    end
    client.ui:hideReticleCursor()
    client.ui:hideCursorActions()

    local selectedReticle = self._selectedReticle
    if selectedReticle then
        Effect.removeCombatTargetReticle(selectedReticle)
        self._selectedReticle = nil
    end

    selectedReticle = self._potentialSelectedReticle
    if selectedReticle then
        Effect.removeCombatTargetReticle(selectedReticle)
        self._potentialSelectedReticle = nil
        self._potentialSelectedAgent = nil
    end

    if self._targetReticle then
        CombatReticles_releaseMeleeReticle(self._targetReticle)
        self._targetReticle = nil
    end
end

function MeleeAbilityAction:onAISelected(source)
    self.ability:onAISelected(source)
end

function MeleeAbilityAction:clear()
    Super.clear(self)
    if World.uiData.selectedAbility == self.ability then
        World.uiData.selectedAbility = nil
    end
end

function MeleeAbilityAction:setContext(ctx)
    Super.setContext(self, ctx)
    self._ability:set("turnContext", ctx)
end

function MeleeAbilityAction:getBattleScript()
    return self._ability.aiScript
end

function MeleeAbilityAction:clearPotentialInfoObject()
    local curAbilityInfoObject = self._potentialAbilityInfoObject
    if curAbilityInfoObject then
        self._potentialAbilityInfoObject = nil
        AbilityInformation:release(curAbilityInfoObject)
    end
end

function MeleeAbilityAction:onCombatEnd()
    self._ability:set("turnContext", nil)
    self._ability:set("actionContext", nil)
    game:removeEventListener("onCombatEnd", self)
    if self._ability:isOnCooldown() then
        self._ability:set("currentCooldown", 0)
    end
end

function MeleeAbilityAction:onCombatTurnEnd()
    if self._ability:isOnCooldown() then
        self._ability:set("currentCooldown", self._ability.currentCooldown - 1)
    end
end

function MeleeAbilityAction:updateSelection()
    if not self:isActionValid() then
        return
    end
    if self._mode == "mouseKeyboard" then
        local hit, x, y = client.selection:performGroundPickXY()
        if hit and self._target then
            local px, py = math_floor(x), math_floor(y)
            local targetActor = self._target:getActor()
            local targetData = self._targetsData[targetActor]
            local ability = self.ability
            local abilityInfo = self._potentialAbilityInfoObject
            -- If target data is true then there is no need to draw a path or reticle
            if type(targetData) == "table" then
                local count = #targetData
                for i = 1, count do
                    local cur = targetData[i]
                    -- If the data is not userdata then it is a "fake" move and will not trigger onPathHover
                    if type(cur) == "table" then
                        local cx, cy = math_floor(cur.pos.x), math_floor(cur.pos.y)
                        if math_approx(cx, px) and math_approx(cy, py) then
                            self._curPath = cur
                            self._targetReticle:setPosition(cur.pos)
                            client.ui:drawPath(nil, true, false)
                            if abilityInfo and targetActor then
                                self:updateAoePath(abilityInfo, targetActor)
                                self.ability:showAbilityUI(abilityInfo)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end

function MeleeAbilityAction:onPathHover(e)
    if not self:isActionValid() then
        return
    end
    local hoverPos = e.hoverPos
    local turnContext = self._turnContext
    local moveSet = turnContext.moveSet
    if self:useCustomMove() then
        moveSet = turnContext.moveThroughActorsMoveSet or turnContext.moveSet
    end
    local pathEnd = moveSet:getPathFromLocation(hoverPos)
    local ability = self.ability
    local abilityInfo = self._potentialAbilityInfoObject
    -- Loop through the active data and see if we can update the target reticle
    if self._target then
        local pickActor = selection:performSelection()
        local targetActor = self._target:getActor()
        if pickActor ~= targetActor then
            local targetData = self._targetsData[targetActor]

            -- If the target data is TRUE then there is no need to draw a reticle
            if type(targetData) == "table" then
                local count = #targetData
                for i = 1, count do
                    local cur = targetData[i]
                    if cur == pathEnd and cur ~= self._curPath then
                        self._curPath = cur
                        self._targetReticle:setPosition(cur.pos)
                        if abilityInfo and targetActor then
                            self:updateAoePath(abilityInfo, targetActor)
                            ability:showAbilityUI(abilityInfo)
                        end
                        break
                    end
                end
            end
        end
    end

    if self._curPath then
        client.ui:showCursorActions(CursorActionsController.layout)
        if type(self._curPath) == "userdata" then
            if self.ability.drawCustomPath then
                self.ability:drawCustomPath(self._curPath, true, false)
            else
                client.ui:drawPath(self._curPath, true, false)
            end
        else
            client.ui:drawPath(nil, true, false)
        end
        CursorActionsController.setActionPointCost(self.cost)
        self.actor.combatStatus:setPotentialActionPointsSpent(self.cost)
        self.actor.meleeDistance = math.ceil(self._curPath.cost)
    end
end

function MeleeAbilityAction:cursorMoved(pos)
    if not self:isActionValid() then
        return
    end
    local turnContext = self._turnContext
    local moveSet = turnContext.moveSet
    if self:useCustomMove() then
        moveSet = turnContext.moveThroughActorsMoveSet or turnContext.moveSet
    end
    local pathEnd = moveSet:getPathFromLocation(pos)
    if self._target then
        local targetActor = self._target:getActor()
        local targetData = self._targetsData[targetActor]

        if type(targetData) == "table" then
            local count = #targetData
            for i = 1, count do
                local cur = targetData[i]
                if type(cur) == "userdata" then
                    if cur == pathEnd and cur ~= self._curPath then
                        self._curPath = cur
                        self._targetReticle:setPosition(cur.pos)
                        break
                    end
                else
                    local px, py = math_floor(pos.x), math_floor(pos.y)
                    local cx, cy = math_floor(cur.pos.x), math_floor(cur.pos.y)
                    if math_approx(cx, px) and math_approx(cy, py) then
                        self._curPath = cur
                        self._targetReticle:setPosition(cur.pos)
                        break
                    end
                end
            end
        end
    end

    if self._curPath then
        client.ui:showCursorActions(CursorActionsController.layout)
        if type(self._curPath) == "userdata" then
            if self.ability.drawCustomPath then
                self.ability:drawCustomPath(self._curPath, true, false)
            else
                client.ui:drawPath(self._curPath, true, false)
            end
        else
            client.ui:drawPath(nil, true, false)
        end
        CursorActionsController.setActionPointCost(self.cost)
        self.actor.combatStatus:setPotentialActionPointsSpent(self.cost)
        self.actor.meleeDistance = math.ceil(self._curPath.cost)
    end
end

function MeleeAbilityAction:onAgentHoverEnter(e)
    local agent = e.target
    if agent ~= self._target and self:isValidTarget(agent) then
        self._potentialSelectedAgent = agent
        self._potentialSelectedReticle = Effect.spawnCombatTargetReticle(agent:getActor(), true)
    end
end

function MeleeAbilityAction:onAgentHoverExit(e)
    local selectedReticle = self._potentialSelectedReticle
    -- If we have a potential selected reticle, then we need to hide it
    if selectedReticle then
        Effect.removeCombatTargetReticle(selectedReticle)
        self._potentialSelectedReticle = nil
        self._potentialSelectedAgent = nil
    end
end

-- Just swallow this event so that PlayerTurn does not handle it
function MeleeAbilityAction:onAgentCursorEnter(e)
    self:onAgentHoverEnter(e)
    self._turnContext.highlightedAgent = e.target
    e.used = true
end

-- Just swallow this event so that PlayerTurn does not handle it
function MeleeAbilityAction:onAgentCursorExit(e)
    self:onAgentHoverExit(e)
    self._turnContext.highlightedAgent = nil
    e.used = true
end

function MeleeAbilityAction:onAgentSelected(e)
    if e.target == self._agent and not self:isValidTarget(e.target) then
        e.used = true
    end
end

function MeleeAbilityAction:onBeginPrepareAction()
    self:clearTargetsData()
end

function MeleeAbilityAction:onInputSourceChanged(e)
    self._mode = e.mode
    if self._mode == "mouseKeyboard" then
        client.ui:hideReticleCursor()
    end
end

function MeleeAbilityAction:getUIOrder()
    return self._ability.uiOrder or 0
end

function MeleeAbilityAction:consumesItem()
    -- MEGAMOD FIX: a weapon switch can pool-release this action while its attack
    -- scenario is still executing, leaving self.ability nil; erroring here stalls
    -- the turn state machine every frame (hard freeze). Treat as "no item".
    local ability = self.ability
    return ability ~= nil and ability:getConsumesItem()
end

function MeleeAbilityAction:getItems()
    -- MEGAMOD FIX: nil-safe for the same pool-release race as consumesItem
    local ability = self.ability
    return ability and ability.items
end

function MeleeAbilityAction:validForFilter(filterTag)
    local id = self._id
    -- We might need a tag which allows abilities to always be valid
    return filterTag == id or filterTag == self._name or filterTag == self._executeName or ConfigBuilder_hasTag(id, filterTag)
end

function MeleeAbilityAction:onPoolAcquire(agent, ability)
    getCombatReticleFunctions()
    ability:set("actionContext", self)

    self._ability = ability
    self._id = ability.scriptId

    self._maxPerTurn = ability.maxPerTurn
    self._endsTurn = ability.endsTurn
    self._executeName = ability:getAbilityExecute()
    self._name = ability._name
    self._cost = ability.cost

    self._isSpendable = ability:getIsSpendable()

    self._costOverride = ability.costOverride
    self._endsTurnOverride = ability.endsTurnOverride
    self._isSpendableOverride = ability.isSpendableOverride

    self._ready = false
    self._agent = agent

    game:addEventListener("onCombatEnd", self)
    local actor = agent:getActor()
    actor:addEventListener("onCombatTurnEnd", self)
    actor:addEventListener("onBeginPrepareAction", self)
    self._savedCursorHeight = 0
    self._targetsData = _tablePool:acquire()
    self._cameraEventCallback = self:callback("onCameraEvent")
end

function MeleeAbilityAction:onPoolRelease()
    self._cameraEventCallback = nil
    game:removeEventListener("onCombatEnd", self)

    local actor = self._agent:getActor()
    actor:removeEventListener("onCombatTurnEnd", self)
    actor:removeEventListener("onBeginPrepareAction", self)

    self._ability:set("actionContext", nil)

    self._ability = nil
    self._id = nil

    self._maxPerTurn = nil
    self._endsTurn = nil
    self._name = nil
    self._cost = nil
    self._curX = nil
    self._curY = nil

    self._ready = nil
    self._agent = nil
    self._savedCursorHeight = nil

    self._potentialAbilityInfoObject = nil
    self._activeScenario = nil

    self._confirmedTarget = nil
    local selectedReticle = self._selectedReticle
    if selectedReticle then
        Effect.removeCombatTargetReticle(selectedReticle)
        self._selectedReticle = nil
    end

    selectedReticle = self._potentialSelectedReticle
    if selectedReticle then
        Effect.removeCombatTargetReticle(selectedReticle)
        self._potentialSelectedReticle = nil
        self._potentialSelectedAgent = nil
    end

    self:clearTargetsData()
    _tablePool:release(self._targetsData)
    self._targetsData = nil
end

-- This does not and should not call Super.init
function MeleeAbilityAction:init()
    self._doCameraFollow = true
end

return newClass("RomeroGames.Combat.Actions.MeleeAbilityAction", MeleeAbilityAction, Super )

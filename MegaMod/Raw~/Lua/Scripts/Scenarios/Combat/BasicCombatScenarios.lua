_namespace = "SCENARIOS"

-- --------------------------------------------------
-- Combat Move
-- --------------------------------------------------
_id = "COMBAT_MOVE"
_name = "CombatMove"

curX = nil
curY = nil

function onStart(actor, x, y, sendMoveEvents)
    actor.anims:cancelIdle()

    Utils:raiseGameEvent("onCombatAgentMoveStarted", "target", CombatUtils:getCombatAgent(actor))
    curX, curY = actor:getGridPosXY()
    x, y = x + 0.5, y + 0.5
    actor.navigation:moveToXY(x, y, 0.15)
    addWaitUntil(MoveCheck, actor, x, y, 0.15 * 0.15, sendMoveEvents).timeout(5, "MoveCheck")
    start(Cleanup)

    onPause(onMovePaused, actor, sendMoveEvents)
    onResume(onMoveResume, actor, x, y)
end

function MoveCheck(source, x, y, r, sendMoveEvents)
    if sendMoveEvents then
        local gx, gy = source:getGridPosXY()
        if gx ~= curX or gy ~= curY then
            curX, curY = gx, gy
            local agent = CombatUtils:getCombatAgent(source)
            Utils:raiseGameEvent("onCombatAgentMoved", "target", agent, "x", gx, "y", gy)
        end
    end

    -- If the actor does not have active navigation then just end.
    if not source.navigation:getAgentEnabled() then
        return true
    end

    local sx, sy = source:getPosXY()
    local dx, dy = x - sx, y - sy
    return (dx * dx + dy * dy) <= r
end

function Cleanup(actor, sendMoveEvents)
    if sendMoveEvents then
        actor:dispatchPooledEvent("onActorStopMovingInCombat", "kind", "CombatMove")
        Utils:raiseGameEvent("onActorStopMovingInCombat", "kind", "CombatMove", "target", actor)
    end
end

function onMovePaused(actor, sendMoveEvents)
    actor.navigation:stopNavigation()
    if sendMoveEvents then
        actor:dispatchPooledEvent("onActorStopMovingInCombat", "kind", "CombatMove")
        Utils:raiseGameEvent("onActorStopMovingInCombat", "kind", "CombatMove", "target", actor)
    end
end

function onMoveResume(actor, x, y)
    actor.anims:cancelIdle()
    actor.navigation:moveToXY(x, y, 0.15)
end
-- --------------------------------------------------
-- Combat Move
-- --------------------------------------------------
_id = "COMBAT_PATH_MOVE"
_name = "CombatPathMove"

curX = nil
curY = nil

function onStart(actor, pathEnd, sendMoveEvents)
    actor.anims:cancelIdle()

    Utils:raiseGameEvent("onCombatAgentMoveStarted", "target", CombatUtils:getCombatAgent(actor))
    curX, curY = actor:getGridPosXY()
    local x, y = pathEnd.pos.x, pathEnd.pos.y
    Move(actor, pathEnd)
    addWait(0.25)
    addWaitUntil(MoveCheck, actor, x, y, 0.15 * 0.15, sendMoveEvents).timeout(10, "MoveCheck")
    start(Cleanup)
end

function Move(actor, pathEnd)
    actor.navigation:startCombatMove(pathEnd)
end

function MoveCheck(source, x, y, r, sendMoveEvents)
    if sendMoveEvents then
        local gx, gy = source:getGridPosXY()
        if gx ~= curX or gy ~= curY then
            curX, curY = gx, gy
            local agent = CombatUtils:getCombatAgent(source)
            Utils:raiseGameEvent("onCombatAgentMoved", "target", agent, "x", gx, "y", gy)
        end
    end

    -- If the actor does not have active navigation then just end.
    if not source.navigation:getAgentEnabled() then
        return true
    end

    local sx, sy = source:getPosXY()
    local dx, dy = x - sx, y - sy
    return (dx * dx + dy * dy) <= r
end

function Cleanup(actor, sendMoveEvents)
    if sendMoveEvents then
        actor:dispatchPooledEvent("onActorStopMovingInCombat", "kind", "CombatMove")
        Utils:raiseGameEvent("onActorStopMovingInCombat", "kind", "CombatMove", "target", actor)
    end
end

-- --------------------------------------------------
-- Kill Target
-- --------------------------------------------------

-- TODO: Kill scenario - Make the target face the attacker before triggering the anim
_id = "KILL_TARGET"
_name = "KillTarget"

function onStart(source, target, _, targetData, burstFire)
    -- TODO: properly find the death position
    local pos = CombatUtils:findDeathPosition(source, target, 2)

    if pos then
        -- step(FaceLethalAttacker, source, target, pos)
        step(PlayLethalAnimation, source, target, targetData, burstFire)
    end
end

function PlayLethalAnimation(source, target, targetData, burstFire)
    if targetData and targetData.bleedOut then
        target.anims:setBleedingOutBool(true)
    else
        target.anims:setDeathBool(true)
        addWait(0.5)
        if not target:hasState("PlotArmor") then
            start( Utils:scenario( "SpawnRagdoll"), source, target )
        end
    end

    if targetData and targetData.crit then
        target.anims:setAnimTrigger("Shot_Critical")
    elseif burstFire then
        target.anims:setAnimTrigger("Shot_Burst")
    else
        target.anims:setAnimTrigger("Shot")
    end
end

-- --------------------------------------------------

_id = "SPAWN_RAGDOLL"
_name = "SpawnRagdoll"

local _bodyFalling = { "AUDIO.COMBAT.BODY_FALL_1", "AUDIO.COMBAT.BODY_FALL_2", "AUDIO.COMBAT.BODY_FALL_3", "AUDIO.COMBAT.BODY_FALL_4",  }
function onStart( source, target )
    local sx, sy = source:getPosXY()
    local tx, ty = target:getPosXY()
    local normalizedDelta = Vector3(tx - sx, 0, ty - sy)
    normalizedDelta:Normalize()
    normalizedDelta.y = 1
    target.anims:spawnRagdoll(normalizedDelta)

    Utils:audioOneShotAtPos( _bodyFalling, source:getPos(), 1, 150 )
end
-- --------------------------------------------------
-- Knock Back
-- --------------------------------------------------

_id = "CHARACTER_KNOCK_BACK"
_name = "KnockBack"

curCellX = nil
curCellY = nil
shouldStop = false

function onStart(source, target, turnBasedCombat, range, pos, knockOutIfNoValidPosition)
    if target:hasTag("Immune:KNOCKBACK") then
        target.icon:showImmuneAlert("$Immune_KNOCKBACK") --$ Knockback
        return
    end

    range = range or Config.COMBAT.DEFAULTS.knockBackTiles
    pos = pos or CombatUtils:findCombatKnockBackPosition(source, target, range)
    if pos then
        if not Utils:viewIsInWorldMap() then
            target.icon:showTextAlert("$Combat_KnockBack")
        end
        target.anims:setCombatAnim(true)

        -- angleBetween2Points returns an angle in "math" coordinates (increasing counter clockwise, starting with 0 at 3 o'clock)
        -- We need it in our coordinates, with 0 at 12 o'clock increasing clockwise. Hence the translation below.
        local targetAngle = (90 - CombatUtils:angleBetween2Points(target:getGridPos(), pos)) % 360
        local delta = ((target:getRot() - targetAngle) % 360)
        local knockForward = delta < 90 or delta > 270
        if not knockForward then
            targetAngle = targetAngle + 180
        end


        CombatUtils:setCoverState(target, CoverState.None)
        addWait(0.1)
        step(Face180Pos, target, targetAngle)
        addWait(0.1)

        local overwatch = target:getState("Overwatch")
        if overwatch then
            start(HandleOverwatchCase, target, overwatch.stepped)
        end

        step(PlayKnockBackAnimation, target, pos, knockForward)
        start(Cleanup, target)

        target:dispatchPooledEvent("onWillKnockBack")

        if turnBasedCombat then
            step(UpdateSightMap, turnBasedCombat)
        end
    elseif knockOutIfNoValidPosition then
        target:addState("KnockedOut")
    end
end

function Face180Pos(target, targetAngle)
    target.navigation:lookAtAngle(targetAngle)
end

function HandleOverwatchCase(target, activeStep)
    -- Trigger the animation that we need
    target.anims:setAimAnim(false)
    if activeStep then
        target.anims:setAnimTrigger("Overwatch_KnockedBack")
        addWait(0.1)
        start(CancelStepOut, target)
    end
end

function CancelStepOut(target)
    target.anims:setBool("StepOut", false)
end

function PlayKnockBackAnimation(target, pos, knockForward)
    local x, y = target:getGridPosXY()
    curCellX, curCellY = x, y
    local knockBackTiles = math.round(math.magnitude(x, y, pos.x, pos.y))
    local destX, destY = math.floor(pos.x) + 0.5, math.floor(pos.y) + 0.5
    target.anims:setTargetPos(destX, destY)
    target.anims:setKnockbackDistance(knockBackTiles)
    target.anims:setAnimTrigger(knockForward and "KnockForward" or "KnockBack")
    target.anims:exitCover()
    target.anims:cancelIdle()
    addWaitUntil(ActorAtPos, target, destX, destY).timeout(5)
    step(ShuffleIfNeeded, target)
    addWait(0.2)

    onPause(onKnockBackPaused, target)
    onResume(onKnockBackResume, target)
end

function onKnockBackPaused(target)
    target.anims:setAnimTrigger("Shot")
end

function onKnockBackResume(target)
    -- center target on the cell
    shouldStop = true
end

function ShuffleIfNeeded(target)
    if shouldStop and not target:hasState("Immobile") then
        local desiredPos = Vector2(curCellX + 0.5, curCellY + 0.5)
        step(Utils:scenario("SetupCombatMove"), target, desiredPos, 0.05 ).failAfter(0.5)
    end
end

function ActorAtPos(actor, destX, destY)
    local x, y = actor:getGridPosXY()
    if (curCellX ~= x) or (curCellY ~= y) then
        curCellX, curCellY = x, y
        local agent = CombatUtils:getCombatAgent(actor)
        Utils:raiseGameEvent("onCombatAgentMoved", "target", agent, "x", x, "y", y)
    end

    local threshold = 0.05
    local sx, sy = actor:getPosXY()
    local dx, dy = destX - sx, destY - sy
    return (dx * dx + dy * dy) <= (threshold * threshold) or shouldStop
end

function UpdateSightMap(tbc)
    tbc:recalculateSightMap()
end

function Cleanup(actor)
    CombatUtils:updateActorPositionForFocus(actor)
    CombatUtils:updateCoverState(actor)
    CombatUtils:setCoverDirection(actor)
    actor.anims:enterCover()
end
-- --------------------------------------------------

-- --------------------------------------------------
-- Interruption Shot
-- --------------------------------------------------
_id = "INTERRUPTION_SHOT"
_name = "InterruptionShot"
function onStart(source, target, _, attackInfo)
    if not target.health:isActive() then
        return
    end

    local targetData = attackInfo:getTargetData(target)
    local firstDataWithLethalAttack, hasCrit, hasHit
    
    for data in attackInfo:getTargetDatasForTarget(target) do
        data:applyHit(1)
        firstDataWithLethalAttack = firstDataWithLethalAttack or data.isAttackLethal and data
        hasCrit = hasCrit or data.crit
        hasHit = hasHit or data.hit
    end

    -- Play the proper animations
    if targetData.isAttackLethal then
        start(Utils:scenario("KillTarget"), source, target, nil, firstDataWithLethalAttack, false)
        addWait(2)
    else
        if hasCrit then
            target.anims:setAnimTrigger("Shot_Critical")
            addWait(2)
        elseif hasHit then
            target.anims:setAnimTrigger("Shot")
            addWait(1)
        else
            if not Utils:viewIsInWorldMap() then
                target.icon:showMissAlert()
            end
        end
    end
end

-- --------------------------------------------------
-- Basic Aim
-- --------------------------------------------------

_id = "BASIC_AIM"
_name = "BasicAim"

function onStart(source, target, oldTarget, abilityInfo)
    if source then source.anims:cancelIdle() end
    if target then target.anims:cancelIdle() end

    local noTarget = ProcessOldTarget(source, target, oldTarget)
    if noTarget then
        source.anims:enterCover()
        return
    end

    -- Do we need to do anything special first time?
    local firstTarget = target and not oldTarget

    local sx, sy = source:getGridPosXY()
    local ax, ay = abilityInfo:getActionPosition()
    if not ax or not ay then
        ax, ay = sx, sy
    end
    local tx, ty = target:getGridPosXY()
    local peek = not (math.approx(ax, sx) and math.approx(ay, sy))

    local _, _, tax, tay = CombatUtils:canSeeXY(ax, ay, tx, ty, true)
    local targetPeek
    if tax and tay then
        targetPeek = not (math.approx(tax, tx) and math.approx(tay, ty))
    end

    local targetPeekWait
    if targetPeek then
        targetPeekWait = ProcessTargetPeek(source, target, tax, tay)
    end

    if peek then
        start(RefreshCover, source)
        step(ProcessSwitchSides, source, ax, ay, firstTarget)
    else
        local switchNeeded = switchNeededForRelativePosition(source, target)
        if switchNeeded then
            step(ProcessSwitchSides, source, ax, ay, firstTarget)
        else
            start(RefreshCover, source)
        end

        if firstTarget then
            start(EnterAim, source, peek)
            addWaitForLookAt(source, target:getPosXY()).timeout(1)
        else
            local startingLookAtSpeed = source.navigation:getLookAtSpeed()
            start(ToggleTarget, source, true, 180)
            step(EnterAim, source, peek)
            addWaitForLookAt(source, target:getPosXY()).timeout(1)
            start(ToggleTarget, source, false, startingLookAtSpeed)
        end
    end

    if targetPeekWait then
        addWaitFor(targetPeekWait).timeout(1.0)
    end
end

function ProcessOldTarget(source, target, oldTarget)
    if oldTarget then
        oldTarget.anims:setPeek(false)
        if not target then
            -- -- We are done and should just stop aiming
            if source.anims:isAiming() then
                start(ExitAim, source)
            end
            return true
        end
    end
end

function ProcessTargetPeek(source, target, tax, tay)
    local targetPeekWait
    local combatant = target:getState("Combatant")
    if combatant and combatant.focusUpdatesEnabled then
        start(RefreshCover, source)
        step(ProcessSwitchSides, target, tax, tay, false, true)
        targetPeekWait = start(SetPeek, target, true)
    end
    return targetPeekWait
end

function ToggleTarget(source, state, lookAtSpeed, isOnStop)
    source.navigation:setLookAtSpeed(lookAtSpeed)
    source.anims:setBool("ToggleTarget", state)
end

-- This table of matrixes represent the relative cover position between the source, marked as 'X' (at the center),
-- and the character the source is targeting.
-- We have 4 matrixes, because, in world coordinates, the default is rotation zero, the first element in the maskPosTable.
-- However, if the source is facing an angle different than zero, the relative positions of [Left] or [Right], as inferred by
-- [getGridPosXY] function call, would not be accurate.
-- For example, a [Left]("L" in the matrix) when the character is facing a wall at a 90 degree angle from the world coordinate origin is actually a [Back], meaning we would see the target standing directly behind the wall or pillar the source is leaning against
-- The possible values are:
-- L, R, T, B ([Left] [Right] [Top] [Bottom])
-- and the expected combinations, like [Top] and [Left], represented as [TL], as the target might have both a smaller x value and higher y.
-- meaning they would be both at the [Top] and the [Left] of the source
local maskPosTable =
{
    [0] =
    {
        {"TL","T","TR"},
        {"L","X","R"},
        {"BL","B","BR"},
    },
    [90] =
    {
        {"BL","L","TL"},
        {"B","X","T"},
        {"BR","R","TR"},
    },
    [180] =
    {
        {"BR","B","BL"},
        {"R","X","L"},
        {"TR","T","TL"},
    },
    [270] =
    {
        {"TR","R","BR"},
        {"T","X","B"},
        {"TL","L","BL"},
    },
}

function isSwitchNeededForRelativeValueAndFacingDirection(angle, worldPosition, facingRight)
    local string_find = string.find
    local indexOfPosInMatrix = TableUtils.posIn2DSquareMatrix
    local mustSwitch

    local original = maskPosTable[0]
    local rotated = maskPosTable[angle]

    local row, col = indexOfPosInMatrix(original, worldPosition)
    local newPosition = (row and col) and rotated[row][col]
    if newPosition then
        -- we need to switch if the direction on the rotated matrix is different than the current direction we're facing,so:
        -- any value of [left]("L", "TL" or "BL") and we're facing [right] OR
        -- any value of [right]("R", "TR" or "BR") and we're facing [left]
        mustSwitch = (string_find(newPosition, "L") and facingRight) or
        (string_find(newPosition, "R") and (not facingRight))
    end

    return mustSwitch
end

function switchNeededForRelativePosition(source, target)

    local sx, sy = source:getGridPosXY()
    local tx, ty = target:getGridPosXY()

    local checkLeft = sx < tx
    local checkRight = sx > tx
    local checkTop = sy > ty
    local checkBottom = sy < ty

    local angle = source.anims._coverAngle or 0

    -- Get the actual relative position between source and target.
    -- For [left], the target might not be directly to left, it might also have a higher "y", which means they are at "TL" or [Top Left]
    -- The same corresponding assumption is made for the other 4 directions, so the possible values are:
    -- [left] = [L, TL, BL] ([Left], [Top Left], [Bottom Left])
    -- [right] = [R, TR, BR] ([Right], [Top Right], [Bottom Right])
    -- [top] = [T, TL, TR] ([Top], [Top Left], [Top Right])
    -- [bottom] = [B, BL, BR] ([Bottom], [Bottom Left], [Bottom Right])
    local left = checkLeft and ((checkTop and "TL") or (checkBottom and "BL") or "L")
    local right = checkRight and ((checkTop and "TR") or (checkBottom and "BR") or "R")
    local top = checkTop and ((checkLeft and "TL") or (checkRight and "TR") or "T")
    local bottom = checkBottom and ((checkLeft and "BL") or (checkRight and "BR") or "B")

    -- We need to know if we need to switch sides.
    -- If we are facing right, we need to switch if our actual relative position towards the target is some value of [left] (L, TL, BL)
    -- likewise, if we are facing left, we need to switch if our relative position towards the target is some value of [right] (R, TR, BR)
    local facingRight = source.anims._coverSwitchSides
    local mustSwitch = (left and facingRight) or (right and (not facingRight))

    -- if [angle] > 0, it means we are not operating in world coordinates
    -- so, we need to translate the relative position of the target into a character coordinates relative position
    -- We can get that by indexing the maskPosTable with the correct angle
    if angle > 0 then
        local direction = left or right or top or bottom
        mustSwitch = isSwitchNeededForRelativeValueAndFacingDirection(angle, direction, facingRight)
    end

    return mustSwitch
end

function RefreshCover(source)
    source.anims:refreshCover()
    addWait(1.0)
end

function ProcessSwitchSides(source, ax, ay, firstTarget, forcePeekAnim)
    local px, py = source.anims:getEstimatedPeekPos()
    local switchSides = not (math.approx(ax, px) and math.approx(ay, py))
    local peekPosVectorX, peekPosVectorY = ax-px, ay-py

    if not firstTarget then
        if source.anims:isAiming() then
            start(ExitAim, source)
        end
    end

    if switchSides then
        local switch90 = (peekPosVectorX ~= 0) and (peekPosVectorY ~= 0)
        step(SwitchSides, source, switch90)
    end

    if forcePeekAnim then
        start(EnterAim, source, forcePeekAnim)
    else
        start(EnterNoAimNoPeekCover, source)
    end
    addWait(0.25)
end

function SetPeek(source, doPeek)
    source.anims:setPeek(doPeek)
    addWait(1.0)
end

function ExitAim(source)
    source.anims:exitAim()
end

function EnterAim(source, peek)
    source.anims:enterAim(peek)
end

function EnterNoAimNoPeekCover(source)
    source.anims:enterNoAimNoPeekCover()
end

function SwitchSides(source, switch90)
    if switch90 then
        source.anims:switchSides90()
    else
        source.anims:switchSides()
    end
    addWaitForActorEvent(source, "onSwitchSidesDone").timeout(1.5, "SwitchSides should be done")
end

-- --------------------------------------------------
-- Target Peek
-- --------------------------------------------------

_id = "TARGET_PEEK"
_name = "TargetPeek"

function onStart(source, target, tx, ty)
    CombatUtils:setCoverDirection(target, source)
    target.anims:enterCover()
    local px, py = target.anims:getEstimatedPeekPos()
    local switchSides = not (math.approx(tx, px) and math.approx(ty, py))
    if switchSides then
        step(SwitchSides, target)
    end
    step(SetPeek, target, true)
end

function SwitchSides(source)
    source.anims:switchSides()
    addWait(0.3)
end

function SetPeek(source, doPeek)
    source.anims:setPeek(doPeek)
    addWait(1.5)
end

-- --------------------------------------------------
-- Full Cover Step Out
-- --------------------------------------------------
_id = "FULL_COVER_STEP_OUT"
_name = "FullCoverStepOut"

function onStart(source, lookX, lookY, x, y)
    local px, py = source.anims:getEstimatedPeekPos()

    if not (math.approx(px, x) and math.approx(py, y)) then
        if source.anims:isAiming() then
            start(ExitAim, source)
        end
        step(SwitchSides, source)
    end


    step(DoStepOut, source, x, y)
    addWaitForLookAt(source, lookX, lookY).timeout(1)
end

function DoStepOut(source, x, y)
    local destX, destY = math.floor(x) + 0.5, math.floor(y) + 0.5

    -- Make sure there is no target rotation
    source.anims:clearTargetRotation()
    source.anims:setTargetPos(destX, destY)
    source.anims:stepOut()
    addWaitUntil(ActorAtPos, source, destX, destY).timeout(2)
    start(AtPosition, source)
end

function AtPosition(source)
    source.anims:exitStep()
end

function ActorAtPos(actor, destX, destY)
    local sx, sy = actor:getPosXY()
    local dx, dy = destX - sx, destY - sy
    return (dx * dx + dy * dy) <= (0.15 * 0.15)
end

function ExitAim(source)
    source.anims:exitAim()
end

function SwitchSides(source)
    source.anims:switchSides()
    addWait(1.4)
end

-- --------------------------------------------------
-- Full Cover Step Back
-- --------------------------------------------------
_id = "FULL_COVER_STEP_BACK"
_name = "FullCoverStepBack"

function onStart(source, lookX, lookY, x, y)
    step(DoStepBack, source, x, y)
    addWaitForLookAt(source, lookX, lookY).timeout(1)
end

function DoStepBack(source, x, y)
    local destX, destY = math.floor(x) + 0.5, math.floor(y) + 0.5

    -- Make sure there is no target rotation
    source.anims:clearTargetRotation()
    source.anims:setTargetPos(destX, destY)
    source.anims:stepBack()

    addWaitUntil(ActorAtPos, source, destX, destY).timeout(2)
    start(AtPosition, source)
end

function AtPosition(source)
    source.anims:exitStepBack()
end

function ActorAtPos(actor, destX, destY)
    local sx, sy = actor:getPosXY()
    local dx, dy = destX - sx, destY - sy
    return (dx * dx + dy * dy) <= (0.15 * 0.15)
end

-- --------------------------------------------------
-- Full Cover Step In
-- --------------------------------------------------
_id = "FULL_COVER_STEP_IN"
_name = "FullCoverStepIn"

function onStart(source, x, y)
    source.anims:resumeStep()
    addWaitForLookAtAngle(source, source.anims:getCoverAngle()).timeout(1)
    step(BackIn, source, x, y)
end

function BackIn(source, x, y)
    local destX, destY = math.floor(x) + 0.5, math.floor(y) + 0.5
    source.anims:setTargetPos(destX, destY)
    source.anims:stepIn()
    addWaitUntil(ActorAtPos, source, destX, destY).timeout(2)
end

function ActorAtPos(actor, destX, destY)
    local sx, sy = actor:getPosXY()
    local dx, dy = destX - sx, destY - sy
    return (dx * dx + dy * dy) <= (0.15 * 0.15)
end

-- --------------------------------------------------
-- Full Cover Step Back In
-- --------------------------------------------------
_id = "FULL_COVER_STEP_BACK_IN"
_name = "FullCoverStepBackIn"

function onStart(source, x, y)
    source.anims:resumeStepBackIn()
    step(BackIn, source, x, y)
    step(BackToCoverAfterBackIn, source)
end

function BackIn(source, x, y)
    local destX, destY = math.floor(x) + 0.5, math.floor(y) + 0.5
    source.anims:setTargetPos(destX, destY)
    source.anims:stepBackIn()
    addWaitUntil(ActorAtPos, source, destX, destY).timeout(2)
end

function BackToCoverAfterBackIn(source)
    source.anims:exitAimNoPeekCover()
end

function ActorAtPos(actor, destX, destY)
    local sx, sy = actor:getPosXY()
    local dx, dy = destX - sx, destY - sy
    return (dx * dx + dy * dy) <= (0.15 * 0.15)
end


-- --------------------------------------------------
-- Ability Execution
-- --------------------------------------------------

_id = "ABILITY_EXECUTION"
_name = "AbilityExecution"

function onStart(actor, target, ability, abilityInfoObject, executeScenario, doSteps, doStepsType)
    local px, py = actor:getGridPosXY()
    local x, y = px, py
    if abilityInfoObject then
        x, y = abilityInfoObject:getActionPosition()
    end

    -- Figure out if we should do step in and out, only do it if doSteps is already true, otherwise executeScenario will handle it.
    doSteps = doSteps and not (math.approx(px, x) and math.approx(py, y))

    if doSteps then
        local lookX, lookY
        if target.getPosXY then
            lookX, lookY = target:getPosXY()
        else
            lookX, lookY = target.x, target.z
        end
        actor.combatTemp.steppingOut = true

        local combatant = actor:getState("Combatant")
        combatant:preventFocusUpdates()

        if doStepsType == "step_out" then
            step(Utils:scenario("FullCoverStepOut"), actor, lookX, lookY, x, y)
        elseif doStepsType == "step_back" then
            step(Utils:scenario("FullCoverStepBack"), actor, lookX, lookY, x, y)
        end

        step(SendPositionEvent, actor, x, y, ability)
    end

    -- We need to handle the rest of the ability in this step since the source could have died as a result of SendPositionEvent
    step(FinishExecution, executeScenario, actor, target, ability, abilityInfoObject, doSteps, doStepsType, px, py)
end

function SendPositionEvent(source, x, y, ability)
    local agent = CombatUtils:getCombatAgent(source)
    local action = agent:getActionFromAbility(ability)

    x, y = math.floor(x), math.floor(y)
    Utils:raiseGameEvent("onCombatAgentMoved", "target", agent, "x", x, "y", y, "action", action)
end

function FinishExecution(executeScenario, actor, target, ability, abilityInfoObject, doSteps, doStepsType, px, py)
    actor.combatTemp.steppingOut = nil
    local agent = CombatUtils:getCombatAgent(actor)
    local action = agent:getActionFromAbility(ability)

    if agent:canContinueCombat() then
        -- MEGAMOD FIX: action can be nil if the agent's ability actions were
        -- rebuilt mid-execution (weapon switch race); skip the shot instead of
        -- erroring, so the step-in/restore steps below still run
        if action and not action.actionCancelled then
            step(executeScenario, actor, target, ability, abilityInfoObject, doStepsType)
        end

        if doSteps then
            if doStepsType == "step_out" then
                step(Utils:scenario("FullCoverStepIn"), actor, px, py)
            elseif doStepsType == "step_back" then
                step(Utils:scenario("FullCoverStepBackIn"), actor, px, py)
            end

            step(RestartFocusUpdates, actor)
        end
    end
end

function RestartFocusUpdates(actor)
    local combatant = actor:getState("Combatant")
    combatant:allowFocusUpdates()
end

-- --------------------------------------------------
-- Spawn Hit Tracer
-- --------------------------------------------------
_id = "SPAWN_HIT_TRACER"
_name = "SpawnHitTracer"

function onStart(tracerConfig, source, target, speed, shortenFactor, srcLocatorId)
    temp.tracerHit = false
    WorldUtils:spawnHitTracerEffect(tracerConfig, source, target, speed, shortenFactor, srcLocatorId, nil, nil, onTracerEnd)
    addWaitUntilFlag(temp, "tracerHit")
end

function onTracerEnd()
    temp.tracerHit = true
end


-- --------------------------------------------------
-- Combat Camera Utils
-- Abstract Scenario to be included by another scenario
-- --------------------------------------------------
_id = "COMBAT_CAMERA_UTILS"
_abstract = true

function BeginCombatCamera(source, target, blendTime)
    blendTime = blendTime or 0.5
    local t3Dx, t3Dy, t3Dz = target:get3DPosXYZ()
    Utils:beginCombatCamera(source, t3Dx, t3Dy, t3Dz, blendTime)
    addWait(blendTime)
end

function UpdateCombatCamera(target, blendTime)
    blendTime = blendTime or 0.5
    local t3Dx, t3Dy, t3Dz = target:get3DPosXYZ()
    Utils:updateCombatCamera(t3Dx, t3Dy, t3Dz, blendTime)
end

function EndCombatCamera(blendTime)
    blendTime = blendTime or 0.5
    Utils:endCombatCamera(blendTime)
    addWait(blendTime)
end

function FocusCameraOnTarget(target)
    -- Does not use the combat camera, but is useful for moving the camera around for scenarios
    WorldUtils:focusOnActor(target, false, "no_location_load", false, false, function()
        temp.focusEnded = true
    end)
    addWaitUntilFlag(temp, "focusEnded").timeout(2)
end

_id = "EXIT_AIM"
_name = "ExitAim"

function onStart(source)
    source.anims:setAimAnim(false)
    addWait(0.5)
    start(EnterCover, source)
end

function EnterCover(source)
    source.anims:exitAimNoPeekCover()
end

-- --------------------------------------------------
-- Begin Combat Turn scenario
-- --------------------------------------------------

_id = "BEGIN_COMBAT_TURN"
_name = "BeginCombatTurn"

sentEvents = false
startedTurn = false

function onStart(turnClass, turnContext, agent, turn)
    local actor = agent and agent:getActor()
    if actor and actor.combatStatus then
        actor.combatStatus:setSelected(true)
    end

    local waitForEvents = ShouldWaitForEvents(agent)
    if waitForEvents then
        step(FocusOnActor, actor).timeout(5)
    end

    start(SendTurnBeginEvents, turnClass, agent, turn)
    if waitForEvents then
        addWait(1) -- This gives us the time to show status effects or bleeding out.
    end

    start(StartTurn, turnClass, turnContext)
    onStop(OnStopCleanup, turnClass, turnContext, agent, turn)
end

function ShouldWaitForEvents(agent)
    if agent:isDeferred() then
        return false
    end

    local actor = agent and agent:getActor()
    if not actor or not actor.hasState then
        return false
    end

    local bleedingOut = actor:getState("BleedingOut")
    if bleedingOut and bleedingOut.turnsToExpire and bleedingOut.turnsToExpire <= 1 then
        return true
    end

    local appliedDamage = actor:getModifierValuesWithSources("damageOverTime")
    if appliedDamage > 0 then
        return true
    end

    local appliedHealing = actor:getModifierValue("healOverTime")
    if appliedHealing > 0 then
        return true
    end
end

function FocusOnActor(actor)
    local blendTime = 0.5
    clientServices.camera:getActiveCamera():moveToFocalPoint(actor:getIconPos(), blendTime)
    addWait(blendTime)
end

function SendTurnBeginEvents(turnClass, agent, turn)
    if sentEvents then
        return
    end

    local actor = agent and agent:getActor()
    if actor then
        actor:dispatchPooledEvent("onCombatTurnBegin", "agent", agent)
    end
    Utils:raiseGameEvent("onCombatTurnBegin", "target", actor, "agent", agent, "turn", turn)
    logGameInfo("Combat", string.format("Turn Start for %s - %s", actor and actor.name or "<nil>", turnClass.__rt))
    sentEvents = true
end

function StartTurn(turnClass, turnContext)
    if startedTurn then
        return
    end
    turnClass:turnStart(turnContext)
    startedTurn = true
end

function OnStopCleanup(turnClass, turnContext, agent, turn)
    -- OnStopCleanup can never have a wait associated with it.
    SendTurnBeginEvents(agent, turn)
    StartTurn(turnClass, turnContext)
end

-- --------------------------------------------------
-- Hide Weapon
-- --------------------------------------------------

_id = "HIDE_WEAPON"
_name = "HideWeapon"

function onStart(source, weapon)
    source.gunHandler:hideWeapon(weapon)
    addWait(2)
end
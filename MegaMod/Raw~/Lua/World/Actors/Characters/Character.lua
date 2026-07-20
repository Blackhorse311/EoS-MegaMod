--$$ Character

local Actor = require("World.Actors.Actor")
local Audio = require("Libs.Audio")
local BrainMixin = require("Mixins.Brain")
local Navigable = require("Mixins.Navigable")
local Pickable = require("Mixins.Pickable")
local ConfigBuilder = require("Libs.ConfigBuilder")
local CharacterInventory = require("Mixins.CharacterInventory")
local Skills = require("Mixins.CharacterSkills")
local Ambidexterity = require("Mixins.Ambidexterity")
local Profession = require("Mixins.Profession")
local Vision = require("Mixins.Vision")
local VisionTarget = require("Mixins.VisionTarget")
local Shooter = require("Mixins.Shooter")
local AmbidexterityShooter = require ("Mixins.AmbidexterityShooter")
local Selectable = require("Mixins.Selectable")
local WorldActor = require("Mixins.WorldActor")
local Icon = require("Mixins.Icon")
local CharacterAnims = require("Mixins.CharacterAnims")
local ActorCommands = require("Libs.ActorCommands")
local MovementIndicator = require("Mixins.MovementIndicator")
local SelectionProcessor = require("Libs.SelectionProcessor")
local WorldAudio = require("World.WorldAudio")
local TrackVisibility = require("Mixins.TrackVisibility")
local Store = require("Mixins.Store")
local CombatStatus = require("Mixins.CombatStatus")
local Feedback = require("Mixins.Feedback")
local Intel = require("Mixins.Intel")
local Relationships = require("Mixins.Relationships")
local SkillCheckPool = require("Libs.SkillCheckPool")
local LimitedLog = require("Libs.LimitedLog")
local LocalizationUtils = require( "Libs.LocalizationUtils" )
local LateRequires = require("Libs.LateRequires")
local TooltipPopulation = require("UI.TooltipPopulation")
local GenericTooltip = require("UI.Floaters.GenericTooltip")
local Effect = require("Libs.Effect")
local TableUtils = require("Libs.TableUtils")

local CombatCalculations = require("Combat.CombatCalculations")

local CoverState = RomeroGames.CoverState
local RomeroGames_ActorLifetime_Persistent = RomeroGames.ActorLifetime.Persistent
local Navigable_MoveSpeed_CombatAdjust = RomeroGames.Navigable.MoveSpeed.CombatAdjust
local math_random = math.random
local _lastPlayTime = 0
local _characterEvents =
{
    "onSelect",
    "onDragSelect",
    "onDeselect",
    "onReselect",
    "onCharacterDeath",
    "onCharacterHealthChanged",
    "onExitCombat",
}

local _playerFactionEvents =
{
    "onPlayerRatingScoreChanged",
    "onPlayerAllianceDeclared",
    "onPlayerAllianceBroken",
    "onPlayerLearnsAboutFaction",
}

local Super = Actor
local Character = { }

local Dev = Dev

Character._get = { }
Character._set = { }

Character.visionRange = 24

local _world
local function getWorld()
    _world = _world or require("World.World")
    return _world
end

local  _interiorClass
local function getInteriorClass()
    _interiorClass = _interiorClass or require("World.InteriorLocation")
    return _interiorClass
end

local function _checkAndSetTints(self)
    local config = self:getConfig()
    local tints = config and config.tints
    if tints then
        local tint = tints[math.random(#tints)]
        self:setTint(tint)
        return true
    end
end

local _tablePool = newTablePool({initialCapacity = 32, incrementalCapacity = 16})

-- -----------------------------------------------------------------------------------
-- Properties
-- -----------------------------------------------------------------------------------

function Character._get:locationName()
    local locationId = self:getLocationId()
    if locationId == 0 then
        return "$Hyphen"
    else
        local location = getWorld().getLocation(locationId)
        if location.building then
            return location.building.name
        else
            return location.name
        end
    end
end

function Character._set:locationName(v)
    logError("setting Location Name is not allowed.")
end

function Character._get:hp()
    return self.health.hp
end

function Character._set:hp()
    logError("Not allowed to set hp on character")
end

-- 1 is lowest, 2 is higher etc
function Character._get:powerLevel()
    if not self._powerLevel then
        local config = self:getConfig()
        local strength = config.squad and config.squad.strength or "Average"
        self._powerLevel = Config.DEFAULTS.CHARACTER.squadStrengthToPower[strength]
        if not self._powerLevel then
            self._powerLevel = config.squad and config.squad.tier or 3
        end
    end
    return self._powerLevel
end

function Character._set:powerLevel()
    logError("Not allowed to set powerLevel on character")
end

function Character._get:combatTemp()
    local combatTemp = self._combatTemp
    if not combatTemp then
        combatTemp = _tablePool:acquire()
        self._combatTemp = combatTemp
    end
    return combatTemp
end

function Character._set:combatTemp()
    throwException( "Unable to set combatTemp on Character as the property is protected." )
end

function Character._get:shouldShowNonCombatHealthBar()
    return self.isRPCOrBoss and self.faction and self.faction.isPlayerFaction and self.health.hp < self.health.maxHp and not self.combatStatus:isCombatStatusVisible()
end

function Character._set:shouldShowNonCombatHealthBar()
    logError("Not allowed to set showNonCombatHealthBar on character")
end

function Character._get:maxHealth()
    return self.health.maxHp
end

function Character._set:maxHealth(v)
    logError("Not allowed to set maxHealth on character")
end

function Character._get:armor()
    local equipmentItem = self.inventory.equipment
    return equipmentItem and equipmentItem.armor and equipmentItem.armor.current or 0
end

function Character._set:armor(v)
    -- logError("Not allowed to set armor on Character")
end

function Character._get:maxArmor() -- TODO: I don't think this is right...
    local equipmentItem = self.inventory.equipment
    return equipmentItem and equipmentItem.armor and equipmentItem.armor.current or 0
end

function Character._set:maxArmor(v)
    logError("Not allowed to set maxArmor on Character")
end

function Character._get:healthPortrait()
    return self._curHealthPortrait or self.characterIcon
end

function Character._set:healthPortrait(v)
    self._curHealthPortrait = v
end

function Character._get:knownName()
    if getWorld().playerFaction:knowsAbout(self.faction) then
        return self.name
    else
        return "$UnknownCharacter" --$ Unknown Character
    end
end

function Character._get:startingTier()
    local config = self:getConfig()
    return config.startingTier
end

function Character._set:startingTier(value)
    logError("Setting startingTier directly is not allowed.")
end

function Character._get:maxTier()
    local config = self:getConfig()
    return config.maxTier
end

function Character._set:maxTier(value)
    logError("Setting maxTier directly is not allowed.")
end

function Character._get:tier()
    local config = self:getConfig()
    return config.tier
end

function Character._set:tier()
    logError("Not allowed to directly set tier on Character")
end

function Character._get:inverseTier()
    return 6 - self.tier
end

function Character._set:inverseTier()
    logError("setting inverseTier is not allowed.")
end

function Character._get:tierColor()
    return Config.DEFAULTS.ITEM.rarities[self.inverseTier]
end

function Character._set:tierColor()
    logError("setting tierColor is not allowed.")
end

function Character._get:weaponProficiencyStartingTier()
    if self.startingTier then
        return self.startingTier
    end
    return self.inverseTier
end

function Character._set:weaponProficiencyStartingTier()
    logError("setting weaponProficiencyStartingTier is not allowed.")
end

function Character._get:weaponProficiencyMaxTier()
    if self.maxTier then
        return self.maxTier
    end
    
    local maxLevel = #Config.DEFAULTS.CHARACTER.weaponProficiencyKillRequirement
    
    return maxLevel  -- MEGAMOD: Remove artificial tier cap, let kills gate progression naturally
end

function Character._set:weaponProficiencyMaxTier()
    logError("setting startingWeaponProficiencyTraits is not allowed.")
end

local _nickNameOrderStringKeys =
{
    prefix = "$Nickname_Prefix",   --$ "{0}" {1:name}
    infix = "$Nickname_Infix",   --$ {1:firstName} "{0}" {1:lastName}
    postfix = "$Nickname_Postfix",  --$ {1:name} "{0}"
}

local _resultTable = {}
function Character._get:nameIncludingNickname()
    if not self.nickName then
        return self.name
    end

    local order = self.nickNameOrder
    if order == "infix" and not client.localization:containsNonEmptyString(_s[self.lastName]) then
        order = "postfix"
    end

    clearTable(_resultTable)
    _resultTable[1] = _nickNameOrderStringKeys[order]
    _resultTable[2] = self.nickName
    _resultTable[3] = self

    return _resultTable
end

function Character._set:knownName(v)
    self.name = v
end

function Character._get:isRPCOrBoss()
    return self.isRPC or self:isBoss()
end

function Character._set:isRPCOrBoss()
    logError("Not allowed to set isRPCOrBoss on Character")
end

-- -----------------------------------------------------------------------------------
-- Conversation Functions
-- -----------------------------------------------------------------------------------

local function entrySort(entry1, entry2)
    return entry1.priority > entry2.priority
end

function Character:hasConversationEntryPoint()
    if self.conversationEntryPoint or self.conversationEntryPoints and #self.conversationEntryPoints > 0 then
        return true
    end
    return false
end

function Character:setConversationEntryPoint(entryPoint, talkingAbout, priority)
    if not talkingAbout and not priority then
        self.conversationEntryPoint = entryPoint
        self.conversationHistory = self.conversationHistory or {}
        self.conversationHistory[entryPoint] = self.conversationHistory[entryPoint] or {}
    else
        if not self.conversationEntryPoints then
            self.conversationEntryPoints = {}
            self.conversationHistory = self.conversationHistory or {}
        end
        priority = priority or 100
        for i = 1, #self.conversationEntryPoints do
            if self.conversationEntryPoints[i].entryPoint == entryPoint and self.conversationEntryPoints[i].talkingAbout == talkingAbout then
                self.conversationEntryPoints[i].priority = priority
                table.sort(self.conversationEntryPoints, entrySort)
                return
            end
        end
        local entry = {}
        entry.entryPoint = entryPoint
        entry.talkingAbout = talkingAbout
        entry.priority = priority
        self.conversationEntryPoints[#self.conversationEntryPoints + 1] = entry
        table.sort(self.conversationEntryPoints, entrySort)
        self.conversationHistory[entryPoint] = self.conversationHistory[entryPoint] or {}
    end
end

function Character:removeConversationEntryPoint(entryPoint)
    if self.conversationEntryPoints then
        self.conversationHistory[entryPoint] = nil
        for i = 1, #self.conversationEntryPoints do
            if self.conversationEntryPoints[i].entryPoint == entryPoint then
                self.conversationEntryPoints[i] = self.conversationEntryPoints[#self.conversationEntryPoints]
                self.conversationEntryPoints[#self.conversationEntryPoints] = nil
                if #self.conversationEntryPoints == 0 then
                    self.conversationEntryPoints = nil
                    if not self.conversationEntryPoint then
                        self.conversationHistory = nil
                    end
                else
                    table.sort(self.conversationEntryPoints, entrySort)
                end
                return
            end
        end
    end

    if entryPoint == self.conversationEntryPoint then
        self.conversationEntryPoint = nil
        self.conversationHistory = nil
    end
end

function Character:removeAllConversationEntryPoints()
    self.conversationEntryPoints = nil
    self.conversationHistory = nil
    self.conversationEntryPoint = nil
end

function Character:getConversationParams()
    if self.conversationEntryPoints then
        local entry = self.conversationEntryPoints[1]
        return entry.entryPoint, entry.talkingAbout
    else
        return self.conversationEntryPoint or "TalkStart"
    end
end

-- -----------------------------------------------------------------------------------
-- Event Listeners
-- -----------------------------------------------------------------------------------

function Character:onActorAttach()
    -- When a character attaches while paused, the Y position won't be updated
    -- until the game is unpaused again. This can leave the character standing in mid-air or
    -- sticking into the floor. To fix this we find the floor height and set it explicitly.
    if clientTime.paused then
        local pos = self:getPos()
        local hit, height = client.selection:getNavMeshHeightAtPoint(pos)
        if hit then
            self:set3DPosXYZPreserveDestination(pos.x, height, pos.y)
        end
    end
    if self.shouldShowNonCombatHealthBar then
        self.combatStatus:setNonCombatVisible(true)
    end
end

function Character:onActorDetach()
    if self.combatStatus ~= nil then
        self.combatStatus:setNonCombatVisible(false)
    end

    if self.temp.bloodPoolHandle then
        local handle = self.temp.bloodPoolHandle
        self.temp.bloodPoolHandle = nil

        -- resume the blood pool effect
        Effect.resumeParticleEffect(handle)
    end
end

function Character:onActorFootstep()
    WorldAudio.playFootstep(self)
end

function Character:onWorldSetupComplete()
    game:removeEventListener("onWorldSetupComplete", self)
    if self.faction then
        self:setFaction(self.faction)
    end
    
    local dogCollars = self.inventory["dogCollars"]
    if dogCollars then
        self:attachDogCollar(dogCollars:get("prefab"))
    end
end

function Character:onPlayerLearnsAboutFaction(e)
    self:updateColors()
end

function Character:updateMinimapIconSortingLayer(forceSelected)
    if self.icon then
        -- Bring selected character icons to the front
        -- Force selected is used when the character is temporarily selected during a drag
        if self._isSelected or forceSelected then
            self.icon:setMinimapSortingLayer(1, "MinimapSelectedCharacter")
            self.icon:setMinimapSortingLayer(2, "MinimapSelectedCharacter")
        else
            self.icon:setMinimapSortingLayer(1, "MinimapCharacter")
            self.icon:setMinimapSortingLayer(2, "MinimapCharacter")
        end
    end
end

function Character:updateWorldActorColors()
    local primaryColor, secondaryColor = self.faction:getKnownIconColors()
    local altSecondaryColor
    if self:hatesPlayer() then
        altSecondaryColor = "enemy"
    else
        altSecondaryColor = "black"
    end
    self.worldActor:setColors(primaryColor, secondaryColor, altSecondaryColor)
end

function Character:updateColors()
    local color = self.faction.rating:getPlayerRelationship()
    self._rgCharacter:setReticleColor(_s[color])
    self:resetOutlineColor()
    self:updateWorldActorColors()
end

function Character:onColorModeChanged(e)
    if not _checkAndSetTints(self) then
        self:updateColors()
        local config = self:getConfig()
        if config.enableFactionTint then
            self:setTint(self.faction.primaryColor)
        end
    end
end

function Character:onPlayerRatingScoreChanged(e)
    local enemy = self:hatesPlayer() and self:hasTag("CanCombat")
    if enemy then
        self._rgCharacter:showReticle()
    end
    self:updateColors()
end

function Character:onPlayerAllianceDeclared()
    self:updateColors()
end

function Character:onPlayerAllianceBroken()
    self:updateColors()
end

function Character:onCombatHostilityChanged()

    local combatSession = getWorld().combatSession
    local color = (combatSession and combatSession:isHostileTowardsFaction(self, getWorld().playerFaction)) and "enemy" or "green"-- self.faction.rating:getPlayerRelationship()
    self._rgCharacter:setReticleColor(_s[color])
    self:resetOutlineColor()
end

-- -----------------------------------------------------------------------------------
-- Floater Tooltips
-- -----------------------------------------------------------------------------------

function Character:isPointerOverStatusIcon()
    return self.icon and self.icon:hasStatusIcon() and self.icon:isPointerOverStatusIcon()
end

function Character:isPointerOverProxyIcon()
    return self.icon and self.icon:hasPortraitIcon() and client.selection.isPointerOverProxyIcon
end

function Character:showFloaterTooltip()
    return self.showTooltip
end

function Character:getTooltipType()
    local tooltipType
    if self:isPointerOverStatusIcon() and self.icon then
        tooltipType = self.icon:getTooltipType()
    end
    return tooltipType or GenericTooltip
end

function Character:populateFloaterTooltip(tooltip, onWorldMap)
    if self:isPointerOverStatusIcon() then
        if self.icon and self.icon:populateFloaterTooltip(tooltip, onWorldMap) then
            return true
        end
        return false
    end

    local positionMode
    if self:isPointerOverProxyIcon() then
        positionMode = RomeroGames.FloaterPositionMode.Pointer
    else
        positionMode = RomeroGames.FloaterPositionMode.WorldActor
    end

    TooltipPopulation.populateCharacterInventory(tooltip, self)
    tooltip:setPositionMode(positionMode)

    return true
end

function Character:populateHUDTooltip(tooltip)
    tooltip:populateHUDTooltip(self)
    tooltip:setPositionMode(RomeroGames.FloaterPositionMode.WorldActor)
end

-- -----------------------------------------------------------------------------------
-- Local Functions
-- -----------------------------------------------------------------------------------

function Character:populateActorParam(actorParam)
    actorParam:setName(_s[self.name])
    if self.firstName then
        actorParam:setFirstName(_s[self.firstName])
    end
    if self.lastName then
        actorParam:setLastName(_s[self.lastName])
    end
    if self.nickName then
        actorParam:setNickName(_s[self.nickName])
    end

    actorParam:setGender(self.genderIndex)
end

function Character:addQuestGiver(description)
    assert(description, "You must provide a description for the quest giver")
    if self.icon then
        self.icon:addStatusIcon("STATUS_ICONS.QUEST_GIVER", description)
    end
    self.questGiverDescription = description
end

function Character:removeQuestGiver()
    if self.icon then
        self.icon:removeStatusIcon("STATUS_ICONS.QUEST_GIVER")
    end
    self.questGiverDescription = nil
end

function Character:getIconPos()
    if client.worldActor.worldMapIsActive then
        local location = getWorld().getLocation(self:getLocationId())
        if location then
            local building = location.building
            if building then
                -- In World Map mode, if the character is inside a building return the building's position
                return building:getIconPos()
            end
        end
    end
    return Super.getIconPos(self)
end

function Character:getIcon3DPos()
    if client.worldActor.worldMapIsActive then
        local location = getWorld().getLocation(self:getLocationId())
        if location then
            local building = location.building
            if building then
                -- In World Map mode, if the character is inside a building return the building's position
                return building:getIcon3DPos()
            end
        end
    end
    return Super.getIcon3DPos(self)
end

function Character:resetReticle()
    local color = self.faction.rating:getPlayerRelationship()
    self._rgCharacter:setReticleColor(_s[color])
    self:setOutlineColor(color)

    local enemy = self:hatesPlayer() and self:hasTag("CanCombat")
    if enemy then
        self._rgCharacter:showReticle()
    else
        self._rgCharacter:hideReticle()
    end

    self:updateWorldActorColors()

    local config = self:getConfig()
    if config.enableFactionTint and not self:isDead() then
        self:setTint(self.faction.primaryColor)
    end
end

function Character:setFactionById(factionId)
    local factionById = getWorld().getFaction(factionId)

    self:setFaction(factionById)
end

function Character:setFaction(faction)

    if self.faction then
        faction:removeMultiEventListener(_playerFactionEvents, self)
    end
    Super.setFaction(self, faction)

    if getWorld().getFact("PlayerFactionSelected") then
        self:resetReticle()
    end

    faction:addMultiEventListener(_playerFactionEvents, self)
end

function Character:clearBuildingEstimatedDefenderStrength(locationId)
    local location = getWorld().getLocation(locationId)
    local building = location and location.building
    if building and building.faction == self.faction then
        building:clearEstimatedDefenderStrength()
    end
end

function Character:registerAsProximityMonitor(range)
    if not range then
        if self.faction and self.faction.isLawEnforcement then
            range = Config.DEFAULTS.AI.lawEnforcementProximityRange
        else
            range = Config.DEFAULTS.AI.defaultProximityRange
        end
    end
    clientAI:registerProximityMonitor(self._rgActor, range)
end

function Character:unregisterAsProximityMonitor()
    clientAI:unregisterProximityMonitor(self._rgActor)
end

function Character:hatesPlayer()
    local player = getWorld().player
    return player and self ~= player and self:hatesTarget(player)
end

function Character:hatesTarget(target)
    -- For now just checking if the character faction hates the target faction
    local combatSession = getWorld().combatSession
    if combatSession and self:hasTag("InCombat") then
        return combatSession:isHostileTowards(self, target)
    else
        return self.faction and self.faction.rating:hates(target.faction)
    end
end

function Character:calcOutlineColor()

    local result
    local World = getWorld()

    if World.inCombat() and World.areCombatActorsKnown() then
        local combatContext = World.combatContext
        local highlightedActors = combatContext.highlightedActors
        local isCombatHighlighted = not highlightedActors or (highlightedActors[self] ~= nil)
        if self.faction.isLawEnforcement then
            result = isCombatHighlighted and "combatLawEnforcementHighlighted" or "combatLawEnforcementNotHighlighted"
        else
            if self:isHostileTowards(World.player) then
                result = isCombatHighlighted and "combatEnemyHighlighted" or "combatEnemyNotHighlighted"
            else
                result = isCombatHighlighted and "combatAllyHighlighted" or "combatAllyNotHighlighted"
            end
        end
    elseif self:hatesPlayer() then
        result = "enemy"
    end
    if not result then
        result = Super.calcOutlineColor(self)
    end

    return result or "white"
end

function Character:setName(name)
    self.name = name
end

function Character:setTint(color)
    self._rgCharacter:setTint(_s[color])
end

function Character:markMissionCharacterForDelete()
    if self.isDeleted then
        logError("trying to delete an already deleted character")
        return
    end

    local World = getWorld()
    --Wait for combat to end before deleting
    if World.inCombat() then
        self._markedForDelete = true
        return
    end

    --If they're in the same location get them to leave the location before deleting
    if self:getLocationId() == World.currentLocationId then
        self.brain:addGoal("LeaveLocationAndDelete", 1001)
        return
    end

    self:delete()
end

function Character:delete()
    self:unregisterAsProximityMonitor()

    if self.brain then
        self.brain:stop()
    end

    local config = self:getConfig()
    if config.characterID then
        LocalizationUtils:setActorAlias(config.characterID, nil)
        LocalizationUtils:setDefaultActorParam(self.configId)
    end

    -- If we are loading, then do not clear the inventory
    -- Todo: prevent characters from deleting themselves during load
    if not client.gameSaves.isLoading then
        self.inventory:clear()
    end
    Super.delete(self)
end

function Character:onActorPrepareDelete()
    self.brain:onActorPrepareDelete()
end

function Character:onActorRecycle()
    self.health:reset()

    Profession.mixout(self)
    Super.onActorRecycle(self)

    self.anims:hideProp()

    if self.squad then
        self.squad:removeMember(self)
    end

    self.anims:resetToDefaults()
    if self.brain then
        self.brain:onActorRecycle()
    end

    -- Mix the profession out and then back in to reset it
    Profession.mixin(self)
    if self._myConfig and self._myConfig.profession then
        self.profession:add(self._myConfig.profession)
    else
        self.profession:add("NoProfession")
    end

    -- Set the female or male animator bool
    self.anims:setBool("Feminine", self.gender == "f")

    self._powerLevel = nil

    if self._myConfig then
        self:applyConfig(self._myConfig)
    end

    if self.navigation then
        self.navigation:setNavAreaMaskEnabled("NoPatronAccess", true)
        self.navigation:unregisterForFootsteps()
        -- Todo: write code to clear appropriate nav-area masks - move to config
    end

    if self._combatTemp then
        clearTable(self._combatTemp)
    end

    _checkAndSetTints(self)
end

function Character:onActorPlayerPrecinctChanged()
    -- print("Character:onActorPlayerPrecinctChanged")
    if not (self.faction and self.faction.isPlayerFaction) then
        return
    end
    game:dispatchPooledEvent("onPlayerFactionMemberChangedPrecinct", "target", self)
end

function Character:resetNoPlayableCharacterAccessNavAreaMask()
    if self.navigation then
        self.navigation:setNavAreaMaskEnabled("NoPlayableCharacterAccess", true)
    end
end

function Character:isControllable()
    return (self:isA(LateRequires.getBoss()) or self:isA(LateRequires.getRPC()) or self:isA(LateRequires.getFollower()))
end

function Character:playAudio(id, force, use2D)
    if not force then
        if (clientTimeElapsedTime - _lastPlayTime < 1.0) or
            (self:getLocationId() ~= getWorld().currentLocationId) then
            return
        end
    end
    _lastPlayTime = clientTimeElapsedTime
    if use2D then
        Audio.oneShot(id)
    else
        Audio.oneShotAtPos(id, self:getPos(), 5, 200)
    end
end

-- check to see if a character sound type is playing to often
local DELAY_BETWEEN_CHAR_SOUNDS = 3.0
Character.char_last_played = {}

function Character:checkLastPlayed( id, force )
    if not id then return true end
    -- if character doesn't exist in table, create entry
    if not self.char_last_played[ self.name ] then
        self.char_last_played[ self.name ] = {}
    end
    -- if character sound type "last time played" doesn't exist in table, create default value
    if not self.char_last_played[ self.name ][ id ] then
        self.char_last_played[ self.name ][ id ] = 0
    end
    -- check if we can play the sound (must be over delay defined above between same sound types)
    if not force and ( clientTimeElapsedTime - self.char_last_played[ self.name ][ id ] < DELAY_BETWEEN_CHAR_SOUNDS ) then
        return false
    end
    -- going to play sound so set the last time played
    self.char_last_played[ self.name ][ id ] = clientTimeElapsedTime
    return true
end

-- play a positive character sound from the 4 types of characters we have
function Character:playCharacterPositive()
    if self:doesCharacterSoundExist( "onHappy" ) then                  -- boss, gangster
        self:playCharacterSound( "onHappy" )
    elseif self:doesCharacterSoundExist( "startInteraction" ) then     -- friendly guard
        self:playCharacterSound( "startInteraction" )
    end
end

-- play a negative character sound from 2 of the 4 types of characters we have
function Character:playCharacterNegative()
    if self:doesCharacterSoundExist( "onFrustration" ) then             -- boss, gangster
        self:playCharacterSound( "onFrustration" )
    elseif self:doesCharacterSoundExist( "onAngry" ) then               -- guards
        self:playCharacterSound( "onAngry" )
    end
end

-- does a particular sound set exist on this character?
-- returns true or false
function Character:doesCharacterSoundExist( id )
    local config = self:getConfig()
    if config.audio and config.audio[id] then return true end
    return false
end

-- kind of ridiculous, but in some cases a character sound might
-- be played somewhere in code that we don't want to hear this time
local _ignore_next_sound = false
function Character:ignoreNextCharacterSound()
    _ignore_next_sound = true
end

-- choose a random character line from the list in the config
function Character:getCharacterSound( id )
    if self.configId then
        local config = self:getConfig()
        -- logInfo( "Trying to play char sound from table: "..id )
        if config.audio and config.audio[ id ] then
            if type( config.audio[ id ] ) == "table" then
                local soundIdx = math_random( #config.audio[ id ] )
                return config.audio[ id ][ soundIdx ]
            else
                return config.audio[ id ]
            end
        end
    end
end


-- play a character sound
-- in a table, it will choose one at random
-- id: the character config path
-- force: disregard the delay (true or false)
-- noAtPos: do not play this 3D positional, do 2D
function Character:playCharacterSound(id, force, noAtPos)

    -- should we ignore this sound?
    if _ignore_next_sound == true then
        _ignore_next_sound = false
        return false
    end

    -- are we trying to play audio for a dead character?
    if self:isDead() and id ~= "onDeath" then
        logInfo( "Cannot play sound for a dead character. Trying to play "..id )
        return
    end

    -- check for valid audio info
    if self.name and id then
--       logInfo("PLAY CHAR SOUND: ", self.name, id)
    else
        logError( "PLAY CHAR SOUND ERROR! self.name is "..tostring( self.name )..", id is "..tostring( id ) )
        return false
    end

    -- there's a delay if it's the same sound
    if not self:checkLastPlayed( id, force ) then return false end

    local snd = self:getCharacterSound( id )
    if not noAtPos and not client.worldActor.worldMapIsActive then
        Audio.oneShotAtPos( snd, self:getPos(), 5, 100 )
    else
        Audio.oneShot( snd )
    end
end

function Character:enterInteriorNear(locationId, desiredPos, desiredRot, minDist, maxDist)
    self:setLocationId(locationId)
    local location = getWorld().getLocation(locationId)
    local entranceStation = LateRequires.getWorldLibs().getInteriorMainDoorEntranceStation(location.building)
    if not entranceStation then
        logError("Unable to find ENTRANCE station in location: " .. tostring(locationId))
        return
    end

    -- If the camera is in currently in the desired location
    if getWorld().currentLocationId == locationId then
        local safeSpawnRadius = 0.3
        -- Find destination inside the building
        local pos = self._rgActor:getSafeSpawnPos(desiredPos.x, 0, desiredPos.y, desiredRot, minDist, maxDist, safeSpawnRadius, false, locationId, false)
        self:setupSafeSpawnPos(entranceStation.pos, math_random() *360, 0, 1)

        -- Move to the required position
        self.brain:removeGoalsWithTag("Navigate")
        self.brain:addGoal("Move", 1000, { targetPos = pos, locationId = locationId })
    else
        self:setupSafeSpawnPos(entranceStation.pos, math_random() *360, minDist, maxDist)
    end
end


function Character:generateLoot(loot, fled, factionGainingLoot)
    --Don't generate loot for a character who is just unconscious
    if self:hasState("PlotArmor") then
        return false
    end

    clearTable(loot)
    loot.lootMoney = 0
    local LootDropLib = require("Libs.LootDropLib")

    if not fled then
        -- Drop inventory loot that must drop
        for item in self.inventory:iterator() do
            if item:get("mustDropAsLoot") then
                item:removeSelfFromInventory()
                loot[#loot + 1] = item
            end
        end

        -- Drop standard loot (Right now only give cash)
        LootDropLib.generateStandardLoot(self.tier, loot, factionGainingLoot)

        -- Drop config loot
        if self.configId then
            local config = self:getConfig()
            local alwaysDropsLoot = config.alwaysDropsLoot
            if alwaysDropsLoot then
                for i = 1, #alwaysDropsLoot do
                    LootDropLib.generateLootItem(alwaysDropsLoot[i], loot, factionGainingLoot)
                end
            end
        end
    end

    -- Drop faction loot

    local checker = SkillCheckPool:acquire()
    self:addModifiers("factionLootRolls", checker)
    checker:addContextVariable("fled", fled)
    checker:evaluate()
    local factionLootRolls = checker:total()
    checker:releaseSelf()

    for i = 1, factionLootRolls do
        LootDropLib.generateFactionLoot(self.faction, self.tier, loot, factionGainingLoot)
    end
    return (#loot > 0) or (loot.lootMoney > 0)
end

function Character:kill(damageSource)
    self:takeDamage(self.hp + 1000, damageSource, nil)
end

function Character:getArmorValue()
    return self.armor
end

local _armorModifierCache = {}
local function getArmorModifierString(key)
    if key % 1 ~= 0 then
        logError("Non-integer armor value passed!", key)
    end

    local result = _armorModifierCache[key]
    if result == nil then
        result = tostring(key) .. "%"
        _armorModifierCache[key] = result
    end
    return result
end
function Character:getArmorModifier()
    return getArmorModifierString(self.armor)
end

-- TODO: Feels like most of this could get moved out...
function Character:onCharacterHealthChanged(e)
    if self.combatStatus ~= nil and not self.combatStatus:isCombatStatusVisible() then
        self.combatStatus:setNonCombatVisible(self.shouldShowNonCombatHealthBar)
    end

    if e.delta >= 0 then return end

    if not LateRequires.getWorldLibs().isInAutoResolveCombat() then

        -- Say ow if we don't die
        local snd = "onHit"

        -- Check for death
        if self:isDead() then
            -- play death audio instead
            snd = "onDeath"
        end

        -- play appropriate audio
        if self:hasTag("Visible") then
            self:playCharacterSound(snd, true, true )
        end
    end
end

function Character:takeArmorDamage(value)
    local armorItem = self.inventory.equipment
    if armorItem and armorItem.armor then
        local armor = armorItem.armor
        armor:takeDamage(value)
        self:dispatchPooledEvent("onCharacterArmorChanged", "target", self, "current", armor.current, "max", 100)
    end
end

function Character:onCharacterDeath(e)
    local rds = self._recentDamageSource
    if rds then
        if rds:isA(LateRequires.getRPC()) or rds:isA(LateRequires.getBoss()) then
            rds.bioRecentHistory:add({"$BioHistory_Killed", self.name}) --$ Killed {0}
            rds.numKills = rds.numKills + 1
        end
        if self.faction then
            self.faction:onMemberKilled(rds, self)
        end
    end

    SelectionProcessor.deselect(self)
    self.visionTarget:setActive(false)
    self:removeTag("Pathing")
    self:removeTag("PlayerFaction")
    if self.squad then
        self:addState("RemoveIfIdleAndOffScreen", "offScreenTimeout", 0)
        self.squad:removeMember(self)
    end

    -- TODO: We need to fix the issue caused by killing actors with grenades as it causes the lua state to throw an exception
    self.worldActor:setIconVisible(false)
end

function Character:onInventoryUpdate(e)
    self:refreshActiveArmor()
end

function Character:takeDamage(amount, source, bleedOut)
    self.health:takeDamage(amount, source, bleedOut)
end

function Character:heal(amount, autoHeal)
    self.health:heal(amount, autoHeal)
end

function Character:getHealthyThreshold()
    return math.ceil(self.maxHealth / 2)
end

function Character:isDamaged()
    return self.hp < self.maxHealth
end

function Character:getEmotion()
    return self._emotion
end

function Character:isSelected()
    return self._isSelected
end

function Character:getHealthBasedIcon()
end

function Character:getHealthString()
    return "$Format_Colon2Elements", "$Stat_Hp", "$Format_Fraction", self.hp, self.maxHealth
end

-- Returns true if the character is selectable in the current view
function Character:isSelectable()
    return self.inPlayerFaction
        and not self:isDead()
        and not self:hasState("Mole")
        and not self:hasState("Subdued")
        and not self:hasState("Incarcerated")
        and not self:hasState("SentAway")
        and not self.injury
        and not self.assignment
        and not self:hatesPlayer()
        and self:isControllable()
        and self:getLocationId() ~= 0
end

function Character:onSelect(e)
    e.showHUD = e.showHUD or false
    self.behaviours:doCommand("Select", e)
    if Dev then
        Dev.selectedChar = self
    end

    if not self._isSelected then
        self._isSelected = true
        self:updateMinimapIconSortingLayer()
    end
end

function Character:onDragSelect(e)
    self:setSelectedIcon(true)
    self._rgCharacter:showReticle()
end

function Character:onDeselect(e)
    self.behaviours:doCommand("Deselect", e)

    if self._isSelected then
        self._isSelected = false

        self:updateMinimapIconSortingLayer()
    end
end

local function displayCombatHUD(self)
    self:setSelectedIcon(true)
    self._rgCharacter:showReticle()
end

function Character:addCombatHighlight()
    self:addTag("CombatHighlight")
end

function Character:removeCombatHighlight()
    self:removeTag("CombatHighlight")
end

function Character:hoverCombatHUD()
    displayCombatHUD(self)
    self:resetOutlineColor()
    client.rendering:setHoveredActor(self._rgActor)
    if self.combatStatus then
        self.combatStatus:setActiveInCombat(true)
    end
end

function Character:hideCombatHUD()
    self._rgCharacter:hideReticle()
    self:setSelectedIcon(false)
    if self._isSelected then
        self._isSelected = false
        self:updateMinimapIconSortingLayer()
    end
    self:resetOutlineColor()
    client.rendering:setHoveredActor(nil)
    if self.combatStatus then
        self.combatStatus:setActiveInCombat(false)
    end
end

function Character:onHoverEnter(e)
    self:dispatchPooledEvent("onHoverEnter")
    if self.combatStatus ~= nil then
        self.combatStatus:setNonCombatVisible(self.shouldShowNonCombatHealthBar)
    end
end

function Character:onHoverExit(e)
    self:dispatchPooledEvent("onHoverExit")
    if self.combatStatus ~= nil then
        self.combatStatus:setNonCombatVisible(self.shouldShowNonCombatHealthBar)
    end
end

function Character:setReticleSelected(v)
    if v then
        self._rgCharacter:setReticleSelected()
    else
        self._rgCharacter:setReticleNormal()
    end
end

function Character:onArriveAtPosition()
    SelectionProcessor.checkForGroup(self)
end

function Character:setAnimSpeed(speed)
    self._rgCharacter:SetAnimSpeed(speed)
end

function Character:isAnimToIgnor(anim)
    if self.animsToIgnore == nil then
        return false
    end

    for _, animationToIgnore in ipairs(self.animsToIgnore) do
        if anim == animationToIgnore then 
            return true 
        end
    end

    return false
end

function Character:getAnimSpeed()
    return self._rgCharacter:GetAnimSpeed()
end

-- Called on all characters when combat starts in the world
function Character:onCombatStart()
    Super.onCombatStart(self)
    if self.brain then
        self.brain:removeGoalsWithTag("RemoveBeforeCombat")
        self.brain:addBlocker("combat")
    end
    if self.navigation then
        self.navigation:pauseMovement()
    end
end

-- Called on all characters when combat ends in the world
function Character:onCombatEnd()
    if self.navigation then
        self.navigation:setIsShrunk(false)
    end
    if self.brain then
        self.brain:removeBlocker("combat")
    end
    if self.navigation then
        self.navigation:resumeMovement()
    end
    Super.onCombatEnd(self)

    if self._markedForDelete then
        self._markedForDelete = nil
        self:markMissionCharacterForDelete()
    end
end

function Character:onCinematicStart()
    if self.brain then
        self.brain:addBlocker("cinematic")
    end
end

function Character:onCinematicEnd()
    if self.brain then
        self.brain:removeBlocker("cinematic")
    end
end

-- Called when this character enters combat
function Character:onPrepareForCombat()
    -- print("Enter Combat Character: " .. self.name .. " speed: " .. tostring(self.navigation:getSpeed()))

    if self:hasTag("PlayerFaction") then
        self.brain:removeGoalsWithTag("Navigate")
    end

    -- Todo: replace with better system
    if self:hasTag("Ambusher") then
        self.navigation:resetSpeed()
    end

    self.combatTemp._preCombatSpeed = self.navigation:getSpeedEnum()

    if self.health:isActive() and not self.gunHandler.activeWeapon then
        self.shooter:drawWeapon()
    end

    self.anims:setCombatAnim(true)

    self:addEventListener("onCombatHostilityChanged")
    self:resetOutlineColor()
end

-- Called when this character exits combat
function Character:onExitCombat(e)
    local preCombatSpeed = self.combatTemp._preCombatSpeed
    if preCombatSpeed then
        if preCombatSpeed == Navigable_MoveSpeed_CombatAdjust then
            self.navigation:resetSpeed()
        else
            self.navigation:setSpeed(preCombatSpeed)
        end
        self.combatTemp._preCombatSpeed = nil
    end
    --print("Exit Combat Character: " .. self.name .. " speed: " .. tostring(self.navigation:getSpeed()))

    -- Reset any hostility coloring
    self:removeEventListener("onCombatHostilityChanged")
    self:onPlayerRatingScoreChanged()

    self.shooter:holsterWeapon()
    local primaryWeapon = self.inventory.primaryWeapon
    if primaryWeapon and primaryWeapon.gun then
        primaryWeapon.gun:reload()
    end
    local secondaryWeapon = self.inventory.secondaryWeapon
    if secondaryWeapon and secondaryWeapon.gun then
        secondaryWeapon.gun:reload()
    end
    local leftHandWeapon = self.inventory.leftHand
    if leftHandWeapon and leftHandWeapon.gun then
        leftHandWeapon.gun:reload()
    end
    self:dispatchPooledEvent("onShooterUpdate", "target", self, "phase", "ammo")

    if self.health:isActive() then
        if not (e.missionNPC or e.resurrecting) then
            CombatCalculations.setCoverState(self, CoverState.None)
        end
        self.anims:setCombatAnim(false)
        self.anims:exitCover()
        self.anims:clearCoverValues()
    end
    if self.combatStatus ~= nil then
        self.combatStatus:setIsVisible(false)
        if self.shouldShowNonCombatHealthBar then
            self.combatStatus:setNonCombatVisible(true)
        end
    end

    if self._combatTemp then
        _tablePool:releaseAndClear(self._combatTemp)
        self._combatTemp = nil
    end
end

function Character:getFullBodyPortrait()
    local config = self:getConfig()
    local portrait
    if config.characterFullbody then
        portrait = config.characterFullbody
    elseif self.gender == "m" then
        portrait = "Sprites/Images/Characters/FullBody/Extras/CharacterSheet_Male_Pose"
    else
        portrait = "Sprites/Images/Characters/FullBody/Extras/CharacterSheet_Female_Pose"
    end
    return portrait
end

function Character:setEmotion(emotion, level)
    local emotionConfig = Config.EMOTIONS[emotion]
    if self._emotion ~= emotion then
        local previousEmotion = self._emotion
        local previousEmotionConfig = Config.EMOTIONS[previousEmotion]

        if self.icon then
            if previousEmotion and previousEmotionConfig.statusIcon then
                self.icon:removeStatusIcon(previousEmotionConfig.statusIcon)
            end
            if emotionConfig.statusIcon then
                self.icon:addStatusIcon(emotionConfig.statusIcon)
                self.icon:setStatusIconScale(emotionConfig.statusIcon, nil, level)
            end
        end
        self._emotion = emotion

        -- if character is not trying to play RELAXED then play the emotion sound
        if emotion ~= "RELAXED" then
            local emotionTable =
            {
                [ "ANGRY" ] = "onStartCombat",
                [ "SUSPICIOUS" ] = "onSight",
            }
            self:playCharacterSound( emotionTable[ emotion ] )
        end
    elseif self.icon and emotionConfig.statusIcon then
        self.icon:setStatusIconScale(emotionConfig.statusIcon, nil, level)
    end
end

function Character:populateControllerStates(uiController, tag, statesTable)
    tag = tag or "Effect"
    uiController:setActive("stateInformation", true)

    local index = 1
    for interface in self.behaviours:allBehavioursWithTag(tag) do

        if interface.getIcon then
            local elementId = "stateIcon" .. index

            if statesTable and type(statesTable) == "table" then
                statesTable[elementId] = interface
            end

            if index > uiController.numStateElements then
                uiController:clone("stateIcon1", elementId, true)
                uiController.numStateElements = uiController.numStateElements + 1
            else
                uiController:setActive(elementId, true)
            end

            uiController.cachedStates[index] = interface
            uiController:setImageInternal(elementId, "image", interface:getIcon())

            index = index + 1
        else
            local name = interface:getName()
            if type(name) == "table" then
                logError("interface for " .. name[1] .. " does not implement getIcon() and/or getColor()")
            else
                logError("interface for " .. name .. " does not implement getIcon() and/or getColor()")
            end
        end
    end
    while index <= uiController.numStateElements do
        uiController:setActive("stateIcon" .. index, false)
        index = index + 1
    end
end

function Character:addStateIcon(icon)
    if self.icon then
        -- TODO: Add in support for multiple states and support for icons on the character tooltip
        self.icon:addStatusIcon(icon)
    end
end

function Character:removeStateIcon(icon)
    if self.icon then
        -- TODO: Add in support for multiple states and support for icons on the character tooltip
        self.icon:removeStatusIcon(icon)
    end
end

function Character:leaveLocationCallback()
    self:setLocationId(0)
    if self.brain then
        self.brain:removeGoalsWithTag("Navigate")
    end
end

function Character:leaveLocation()
    local locationId = self:getLocationId()
    local currentLocationId = getWorld().currentLocationId

    if self.brain then
        self.brain:removeGoalsWithTag("Navigate")
    end

    if self.memory.acquiredStation then -- TODO: have acquired stations deal with releasing themselves.
        local location = getWorld().getLocation(locationId)
        location.locationAI:releaseStation(self.memory.acquiredStation, self)
    end

    if not self:isDead() then
        if locationId == currentLocationId and self.brain then
            local leavePos
            local currentLocation = getWorld().currentLocation
            if currentLocation.isInterior then
                leavePos = LateRequires.getWorldLibs().getInteriorClosestExitStation(currentLocation.building, self:getPos()).pos
            else
                leavePos = getWorld().getSpawnPointNear(self:getPos(), currentLocationId) or self:getPos()
            end
            self.brain:addGoal("MoveAndDo", 100, { leavePos, 0.5, self:callback("leaveLocationCallback")})
        else
            self:setLocationId(0)
        end
    end
end

function Character:getMaxActionPoints()
    return math.min(4, self:getModifierValue("actionPoints"))
end

function Character:canSeeActor(other)
    return self._rgCharacter:canSeeActorFromPosition(other._rgActor, self:getPos(), Character.visionRange) and not self:hasState("BleedingOut")
end

function Character:canSeeActorFromPosition(other, pos)
    return self._rgCharacter:canSeeActorFromPosition(other._rgActor, pos, Character.visionRange)
end

function Character:isUsingDamageTypeWeapon(damageType)
    local usingWeapons = self:getUsingWeaponsWithDamageType(damageType)

    return #usingWeapons > 0
end

function Character:getUsingWeaponsWithDamageType(damageType)
    local usingWeapons = {}

    if self.abilityWeapons then
        for _, abilityWeapon in next, self.abilityWeapons do
            if abilityWeapon:get("damageTypes")[damageType] then
                usingWeapons[#usingWeapons + 1] = abilityWeapon
            end
        end
    end
    if self.shooter and self.shooter.activeWeapons then
        for _, activeWeapon in next, self.shooter.activeWeapons do
            if not TableUtils.icontains(usingWeapons, activeWeapon) and activeWeapon:get("damageTypes")[damageType] then
                usingWeapons[#usingWeapons + 1] = activeWeapon
            end
        end
    end

    return usingWeapons
end

function Character:setAbilityWeapons(weapons)
    self.abilityWeapons = weapons
end

function Character:isUsingAbilityClass(class)
    local abilityClass = self._currentActiveAbilityClass
    return abilityClass and abilityClass == class
end

function Character:setCurrentActiveAbilityClass(class)
    self._currentActiveAbilityClass = class
end

function Character:isArrested()
    return self:hasState("Incarcerated")
end

local numberOfDaysToSpendInJail = {
    [0] = 28,
    [1] = 56,
    [2] = 86,
}
function Character:numberOfDaysInJail()
    local timesJailed = self.memory.timesJailed or 0
    return numberOfDaysToSpendInJail[math.min(#numberOfDaysToSpendInJail, timesJailed)]
end

function Character:processActorInjuryChance()
    if getWorld().isTutorialActive() then return end
    
    if self:hasTag("NoInjuryChance") then return end

    local damageDeltaPercent = -((self.hp - self.hpCombatStart) / self.maxHealth) * 100

    if damageDeltaPercent <= 0 then
        return
    end

    local configId = CombatCalculations.getInjurySeverity(damageDeltaPercent)
    local config = ConfigBuilder.fromId(configId)

    local chance = self:getModifierValue("injuryChance", nil, config.percentInjuryChance)

    if Dev and Dev.logInjurySeverity then
        logGameInfo("Combat", string.format("Injury severity: %s; Injury chance before modifiers: %f; after modifiers: %f",
                getDebugLocalizedString(config.name),
                config.percentInjuryChance,
                chance))
    end

    if math.random(100) <= chance then
        self.pendingInjuryId = configId
        return configId
    end
end

function Character:isDrunk()
    return self:hasState("Drunk")
end

function Character:isAvailable()
    local check = self:getSkillCheck("isAvailable")
    local result = check:checkIfNotFalse()
    check:releaseSelf()
    return result
end

function Character:isCritical()
    return self.health:getState() == "Critical"
end

function Character:isDead()
    return self:hasState("Dead")
end

function Character:isBoss()
    return self.faction and self.faction.boss == self
end

function Character:isInSameFaction(other)
    if other then
        return (self.faction == other.faction)
    end
    return false
end

function Character:isHostileTowards(other)
    return self:hatesTarget(other)
end

function Character:isFriendly(other)
    return not self:isHostileTowards(other)
end

function Character:blocksSightline()
    return false
end

function Character:attachWeapons(weaponRight, weaponLeft, animatorBool)
    local rg_animatorBoolKey = animatorBool and _s[animatorBool] or 0
    local rg_rightHandWeaponKey = weaponRight and _s[weaponRight:get("prefab")] or 0
    local rg_leftHandWeaponKey = weaponLeft and _s[weaponLeft:get("prefab")] or 0
    self._rgCharacter:attachWeapons(rg_rightHandWeaponKey, rg_leftHandWeaponKey, rg_animatorBoolKey)
end

function Character:attachHandProps(handPropR, handPropL, animatorBool)
    local rg_animatorBoolKey = animatorBool and _s[animatorBool] or 0
    local rg_HandPropLKey = handPropL and _s[handPropL] or 0
    local rg_HandPropRKey = handPropR and _s[handPropR] or 0
    self._rgCharacter:attachHandProps(rg_HandPropRKey, rg_HandPropLKey, rg_animatorBoolKey)
end

function Character:attachMouthProps(mouthProp)
    local rg_MouthPropKey = mouthProp and _s[mouthProp] or 0
    self._rgCharacter:attachMouthProps(rg_MouthPropKey)
end

function Character:attachDogCollar(dogCollar, animatorBool)
    local rg_animatorBoolKey = animatorBool and _s[animatorBool] or 0
    local rg_DogCollarKey = dogCollar and _s[dogCollar] or 0
    self._rgCharacter:attachDogCollar(rg_DogCollarKey, rg_animatorBoolKey)
end

function Character:removeWeapon()
    self._rgCharacter:removeWeapon()
end

function Character:removeWeapons(weaponRight, weaponLeft)
    if weaponRight and weaponLeft then
        self._rgCharacter:removeWeapons()
    elseif weaponRight then
        self._rgCharacter:removeRightHandWeapon()
    elseif weaponLeft then
        self._rgCharacter:removeLeftHandWeapon()
    end
end

function Character:removeHandProps()
    self._rgCharacter:removeHandProps()
end

function Character:removeMouthProps()
    self._rgCharacter:removeMouthProps()
end

function Character:removeDogCollar()
    self._rgCharacter:removeDogCollar()
end

function Character:addCombatAnimationPriority()
    self._rgCharacter:addCombatAnimationPriority()
end

function Character:removeCombatAnimationPriority()
    self._rgCharacter:removeCombatAnimationPriority()
end

function Character:addAnimationPriority()
    self._rgCharacter:addAnimationPriority()
end

function Character:removeAnimationPriority()
    self._rgCharacter:removeAnimationPriority()
end

function Character:refreshActiveArmor()
    local armorItem = self.inventory.equipment
    if armorItem ~= self.activeArmor then
        local current = self.armor
        local max = self.maxArmor
        game:dispatchPooledEvent("onCharacterArmorChanged", "target", self, "current", current, "max", max)
        self:dispatchPooledEvent("onCharacterArmorChanged", "target", self, "current", current, "max", max)
        self.activeArmor = armorItem
    end
end

function Character:setSelectedIcon(selected)
    if self.icon then
        self.icon:setPinIconLayerEnabled(1, selected)
        if self.icon:hasPortraitIcon() then
            self.icon:setPortraitSelected(selected)
        end
        self.icon:setMinimapLayerEnabled(2, selected)
        self:updateMinimapIconSortingLayer(selected)
    end
end

function Character:teleportToNearestNavMesh(maxDistance)
    self._rgCharacter:teleportToNearestNavMesh(maxDistance)
end

function Character:allowRotation(v)
    if self.navigation then
        self.navigation:allowRotation(v)
    end

    self._rgCharacter:allowRotation(v)
end

function Character:fadeIn(fadeTime, delay)
    delay = delay or 0
    self._rgCharacter:fade(1, fadeTime, delay)
end

function Character:fadeOut(fadeTime, delay)
    delay = delay or 0
    self._rgCharacter:fade(0, fadeTime, delay)

    if self.temp.bloodPoolHandle then
        local handle = self.temp.bloodPoolHandle
        self.temp.bloodPoolHandle = nil

        -- resume the blood pool effect
        Effect.resumeParticleEffect(handle)
    end
end

function Character:getValue()
    local score = self.inventory.value
    return score
end

-- This function just exists for clarity since stacks are the same as dependencies
function Character:addDependency(statusId, ...)
    local interface = self:getState(statusId)
    if interface then
        self.behaviours:addDependencies(interface.handle, 1)
    else
        interface = self:addState(statusId, ...)
    end
    return interface
end

-- This function just exists for clarity since stacks are the same as dependencies
function Character:removeDependency(statusId)
    local interface = self:getState(statusId)
    if interface then
        self.behaviours:removeDependencies(interface.handle, 1)
    end
end

function Character:addStack(statusId, ...)
    local interface = self:getState(statusId)
    if interface then
        self.behaviours:addStacks(interface.handle, 1)
    else
        interface = self:addState(statusId, ...)
    end
    return interface
end

function Character:removeStack(statusId)
    local interface = self:getState(statusId)
    if interface then
        self.behaviours:removeStacks(interface.handle, 1)
    end
end

function Character:getNumStacks(statusId)
    local interface = self:getState(statusId)
    if interface then
        return self.behaviours:getNumStacks(interface.handle)
    end
    return 0
end

function Character:addState(statusId, ...)
    local id = self.behaviours:addSingleton(statusId, ...)
    if id then
        return self.behaviours:getInterface(id)
    end
end

function Character:addStackFromSource(statusId, source, ...)
    local interface = self:getState(statusId)
    if interface then
        local extraDuration = source and source:getModifierValue("appliedEffectsDuration") or 0
        self.behaviours:addStackWithExtraDuration(interface.handle, 1, extraDuration)
    else
        interface = self:addStateFromSource(statusId, source, ...)
    end
    return interface
end

function Character:addStateFromSource(statusId, source, ...)
    local extraDuration = source and source:getModifierValue("appliedEffectsDuration") or 0
    local id
    if extraDuration > 0 then
        id = self.behaviours:addWithExtraDuration(statusId, extraDuration, ...)
    else
        id = self.behaviours:addSingleton(statusId, ...)
    end

    if id then
        return self.behaviours:getInterface(id)
    end
end

function Character:addStatesWithChance(...)
    local roll = math.random()
    local selectedStateName
    for i = 1, select("#", ...), 2 do
        local stateName = select(i, ...)
        local chance = select(i + 1, ...)

        roll = roll - chance
        if roll <= 0 then
            selectedStateName = stateName
            break
        end
    end

    if selectedStateName then
        if not self:hasState(selectedStateName) then
            self:addState(selectedStateName)
            return selectedStateName
        end
    end
end

function Character:showCharacterMessage(title, ...)
    getWorld().confirmDialog({
        title = title,
        text = {...},
        image = self.characterIcon,
        usesNoButton = false,
        pause = true,
    })
end

function Character:addTraitWithMessage(statusId, ...)
    if self:hasState(statusId) then
        return
    end

    self:addState(statusId)
    self:showCharacterMessage("$Character_TraitGained", ...) --$ Trait Gained
end

function Character:addTraitWithPopup(statusId, ...)
    if self:hasState(statusId) then
        return
    end

    self:addState(statusId)
    game:dispatchPooledEvent("onAcquaintanceInforamtion", 
                            "image", self.characterIcon,
                            "title", "$Character_TraitGained",
                            "description", { ... })
end

function Character:removeTraitWithMessage(statusId, ...)
    if not self:hasState(statusId) then
        return
    end

    self:removeState(statusId)
    self:showCharacterMessage("$Character_TraitLost", ...) --$ Trait Lost
end

function Character:removeTraitWithPopup(statusId, ...)
    if not self:hasState(statusId) then
        return
    end
    
    self:removeState(statusId)
    game:dispatchPooledEvent("onAcquaintanceInforamtion", 
                            "image", self.characterIcon,
                            "title", "$Character_TraitLost",
                            "description", { ... })
end

function Character:getOrAddState(statusId, ...)
    local interface = self:getState(statusId)
    if not interface then
        interface = self:addState(statusId, ...)
    end

    return interface
end

function Character:getOrAddStateFromSource(statusId, source, ...)
    local interface = self:getState(statusId)
    if interface then
        -- because we want to make sure we associate the source to it, since it is possible to add states without a source
        self:removeState(statusId)
    end
    interface = self:addStateFromSource(statusId, source, ...)
    return interface
end

function Character:addStateIfNotAdded(statusId, ...)
    return self:getOrAddState(statusId, ...)
end

function Character:hasState(statusId)
    return self.behaviours:has(statusId)
end

function Character:getState(statusId)
    local handle = self.behaviours:getHandle(statusId)
    if handle then
        return self.behaviours:getInterface(handle)
    end
end

function Character:isAmbidextrous()
    local ambidexterity = self.ambidexterity
    if ambidexterity and #ambidexterity:getAmbidexterityKeys() > 0 then
        return true
    end
    return false
end

local _statesMatchConditionResult = {}
function Character:getStatesThatMatchCondition(condition)
    clearTable(_statesMatchConditionResult)
    self.behaviours:getInterfacesThatMatchCondition(condition, _statesMatchConditionResult)
    return _statesMatchConditionResult
end

function Character:removeState(statusId)
    self.behaviours:removeSingleton(statusId)
end

local function _behaviourSortFn(a, b)
    local aScore = a.getVisualPriority and a:getVisualPriority()
    local bScore = b.getVisualPriority and b:getVisualPriority()

    if aScore ~= bScore then
        return bScore > aScore
    end

    return b.handle > a.handle
end

-- Improvement: This code will break if a call to allWithTagSorted is made from within itself
local _result = {}
function Character:allWithTagSorted(tag)
    for i = 1, #_result do
        _result[i] = nil
    end

    for interface in self.behaviours:allBehavioursWithTag(tag) do
        _result[#_result + 1] = interface
    end

    table.sort(_result, _behaviourSortFn)

    local i = 0
    local n = #_result
    return function()
        i = i + 1
        if i <= n then
            return _result[i]
        end
    end
end

function Character:allTraitsSorted()
    return self:allWithTagSorted("Trait")
end

function Character:allStatusEffectsSorted()
    return self:allWithTagSorted("StatusEffect")
end

function Character:allEffectsSorted()
    return self:allWithTagSorted("Effect")
end

function Character:getGearScore()
    return self.inventory:getGearScore()
end

local _cappedModifiers =
{
    marksmanship = 100,
    intimidation = 100,
    leadership = 100,
    persuasion = 100,
    initiative = 100,
}

function Character:getModifierValue(key, weaponOverride, baseValue, dontCeil)
    local result = self:getUncappedModifierValue(key, weaponOverride, baseValue, dontCeil)
    -- Certain modifiers should not go over 100.
    local cap = _cappedModifiers[key]
    if cap and result > cap then
        result = cap
    end
    return result
end

-- the total value (result) should be capped
function Character:getModifierValuesWithSources(key, weaponOverride, baseValue)
    local checker = SkillCheckPool:acquire()
    if baseValue and baseValue ~= 0 then
        checker:addValue(baseValue)
    end
    self:addModifiers(key, checker, weaponOverride)
    checker:evaluate()
    local result = checker:total()
    local cap = _cappedModifiers[key]
    if cap and result > cap then
        result = cap
    end
    local valuesTable = {}
    for value, reason in checker:getAllWithReasons() do
        valuesTable[reason] = value
    end
    checker:releaseSelf()
    return result, valuesTable
end

function Character:getModifierValuesWithSourcesAndIds(key, weaponOverride, baseValue)
    local checker = SkillCheckPool:acquire()
    if baseValue and baseValue ~= 0 then
        checker:addValue(baseValue)
    end
    self:addModifiers(key, checker, weaponOverride)
    checker:evaluate()
    local result = checker:total()
    local cap = _cappedModifiers[key]
    if cap and result > cap then
        result = cap
    end
    local valuesTable = {}
    for value, id, name in checker:getAllWithReasonsAndIds() do
        valuesTable[id] = { name = name, value = value }
    end
    checker:releaseSelf()
    return result, valuesTable
end

function Character:getUncappedModifierValue(key, weaponOverride, baseValue, dontCeil)
    local checker = SkillCheckPool:acquire()
    if baseValue and baseValue ~= 0 then
        checker:addValue(baseValue)
    end
    self:addModifiers(key, checker, weaponOverride)
    checker:evaluate()
    local result = checker:total(nil, dontCeil)
    checker:releaseSelf()
    return result
end

function Character:getModifierPercentTotal(key, weaponOverride)
    local checker = SkillCheckPool:acquire()
    self:addModifiers(key, checker, weaponOverride)
    checker:evaluate()
    local result = checker:totalPercent()
    checker:releaseSelf()
    return result
end

function Character:getModifierWholeNumberTotal(key, weaponOverride)
    local checker = SkillCheckPool:acquire()
    self:addModifiers(key, checker, weaponOverride)
    checker:evaluate()
    local result = checker:totalWholeNumber()
    checker:releaseSelf()
    return result
end

function Character:getSkillCheck(key, weaponOverride)
    local checker = SkillCheckPool:acquire()
    if key then
        self:addModifiers(key, checker, weaponOverride)
    end
    return checker
end

local skillsToWorldModifiers =
{
    marksmanship = "SKILL_MARKSMANSHIP",
    defense = "SKILL_DEFENSE",
    initiative = "SKILL_INITIATIVE",
    movement = "SKILL_MOVEMENT",
    leadership = "SKILL_LEADERSHIP",
    persuasion = "SKILL_PERSUASION",
    intimidation = "SKILL_INTIMIDATION",
    luck = "SKILL_LUCK",
    badLuck = "SKILL_BAD_LUCK",
}

function Character:getWorldModifierForSkillKey(key)
    if skillsToWorldModifiers[key] then
        return "generic", skillsToWorldModifiers[key]
    end
end

local function getModifiers(self, mode, key, checker, weaponOverride)
    -- Check the character
    checker[mode](checker, self, key)
    -- Check the active weapon, other weapons should not apply effects
    local shooter = self.shooter
    local weapon = weaponOverride or shooter.activeWeapon
    if weapon then
        checker[mode](checker, weapon, key)

        -- Check the ammo
        local ammo = weapon.gun and shooter:getWeaponAmmo(weapon)
        if ammo then
            checker[mode](checker, ammo, key)
        end
    end

    -- Check the equipment
    for item in self.inventory:iterator("Equipment") do
        if not item:get("isWeapon") then
            checker[mode](checker, item, key)
        end
    end

    -- Check the misc and ability slots
    for item in self.inventory:iterator("Misc") do
        if not item:get("isWeapon") then
            checker[mode](checker, item, key)
        end
    end

    for item in self.inventory:iterator("Utility") do
        if not item:get("isWeapon") then
            checker[mode](checker, item, key)
        end
    end

    for item in self.inventory:iterator("Ability") do
        if not item:get("isWeapon") then
            checker[mode](checker, item, key)
        end
    end
    -- Apply any world modifiers
    local category, worldModifier = self:getWorldModifierForSkillKey(key)
    if category and worldModifier then
        checker:registerWorldModifier(category, worldModifier, self.faction.factionId, self:getLocationId(), self:getPrecinctId(), self)
    end
end

function Character:addModifiers(key, checker, weaponOverride)
    getModifiers(self, "addModifiers", key, checker, weaponOverride)
end

function Character:subtractModifiers(key, checker, weaponOverride)
    getModifiers(self, "subtractModifiers", key, checker, weaponOverride)
end

function Character:loadConfig(config)
    local gender, genderIndex = LocalizationUtils:getGenderCode(config.gender)

    self.telemetryId = config.telemetryId
    self.firstName = config.firstName

    -- This is to handle the possible renaming of characters which start with only a first name (R, The Cleaner etc.)
    if config.lastName then
        self.lastName = config.lastName
    elseif self.firstName then
        self.lastName = string.gsub(self.firstName, "_firstName", "_lastName")
    end

    if config.nickName then
        self.nickName = config.nickName
        self.nickNameOrder = config.nickNameOrder or "infix"
    end

    self.gender = gender            -- m, f or n
    self.genderIndex = genderIndex  -- 0, 1 or 2
    self.characterIcon = config.characterIcon
    self.portraitHurt = config.portraitHurt or self.characterIcon
    self.portraitCritical = config.portraitCritical or self.portraitHurt
    self._curHealthPortrait = self.characterIcon
    self.combat = config.combat
    self.age = config.age
    self.heritage = config.heritage
    self.bodyType = config.bodyType
    self.specialCharacteristic = config.specialCharacteristic
    self.clothingAccessories = config.clothingAccessories
    self.cinematicPrefab = config.cinematicPrefab
    self.cinematicRevealPrefab = config.cinematicRevealPrefab or config.cinematicPrefab
    self.tooltipType = config.tooltipType
    self.showTooltip = config.showTooltip
    self.ragdollPrefab = config.ragdollPrefab
    self._combatPersonality = config.combatPersonality
    self.revealConfigId = config.revealConfigId
    if config.isGangster ~= nil then
        self.isGangster = config.isGangster
    else
        self.isGangster = true
    end
end

function Character:applyConfig(config)
    Character.loadConfig(self, config)
    self.name = config.name
    self.temperament = 50
    self:applyTags(config.tags)
    self:applyLabels(config.labels)
    if self._rgCharacter then
        self._rgCharacter:setAnimatorController(_s[config.animatorController])
    end
end

function Character:onFootStep(e)
    WorldAudio.playFootstep(self)
end

function Character:validateCommand(name, other)
    if other == self then
        return false
    end

    if name == "Talk" then
        return self.health:isActive()
    elseif name == "Attack" then
        return (other.shooter and other.shooter:canShoot(self)) and not (self:isDead())
    elseif name == "Shop" then
        return self.memory.canShop and self.health:isActive()
    end

    return true
end

local CharacterSaver = {}
function CharacterSaver.save(character, saveBlock)
    if not character._rgCharacter then
        logError("character has no _rgCharacter attached. Character iid:", character.iid, "character config:", character.configId)
        return
    end
    -- temporary until we can save and load the character's entire animation state
    local currentAnims = {}
    local currentActiveTriggers = {}
    local currentInts = {}
    local currentFloats = {}
    local currentBools = {}
    local SaveState = SaveState
    character._rgCharacter:saveAnimationState(currentAnims, currentActiveTriggers, currentBools, currentFloats, currentInts)
    saveBlock._currAnim = SaveState.saveReference(currentAnims)
    saveBlock._currTriggers = SaveState.saveReference(currentActiveTriggers)
    saveBlock._currInts = SaveState.saveReference(currentInts)
    saveBlock._currFloats = SaveState.saveReference(currentFloats)
    saveBlock._currBools = SaveState.saveReference(currentBools)
end

SaveState.defineSaveKeys(Character,
{
    {Super},
    {Skills},
    {CharacterInventory},
    {Profession},
    {Pickable},
    {Selectable},
    {Navigable},
    {BrainMixin},
    {Store},
    {Relationships},
    {"commands"},
    {"temperament"},
    {"squad"},
    {"hasTalkedToPlayer"},
    {"conversationEntryPoint"},
    {"conversationEntryPoints"},
    {"conversationHistory"},
    {"questGiverDescription"},
    {"log"},
    {"nickName"},
    {"nickNameOrder"},
    {CharacterSaver},
})

function Character:load()

    if Character.checkOrMarkLoaderExecuted(self) then
        return
    end

    -- printR(self, 1 , "Character:load " .. tostring(self._name) .. " " .. tostring(self.configId) .. " " .. tostring(self._locationId))

    -- If the locationId does not exist then send the character to the void
    local locId = self._locationId
    if locId and locId ~= 0 then
        if not getWorld().getLocation(locId) then
            logError("Character has invalid location. Moving to void. ", self.configId, " iid:", self.iid, " locId:", locId, " name:", self._name)
            self._locationId = 0
        end
    end

    local options = self._loadOptions

    local config = self:getConfig()
    self:loadConfig(config)
    self._myConfig = config

    Super.load(self, Super)

    -- Characters should have their visibility tracked
    TrackVisibility.mixin(self)

    local uiConfig = Config.UI.CHARACTER
    if not uiConfig then
        throwException("Unable to find the character UI config")
    end

    if config.characterID then
        LocalizationUtils:setActorAlias(config.characterID, self)
    end

    Skills.load(self, Skills)

    if config.ambidexterity then
        Ambidexterity.mixin(self)
        self.ambidexterity:setData(config.ambidexterity)
    end

    CharacterInventory.load(self, CharacterInventory)
    self:addEventListener("onInventoryUpdate", self)

    -- The priority on this is low since the function used to run after the event of the same name
    self:addEventListener("onPrepareForCombat", self, -1000)

    Profession.load(self, Profession)
    Pickable.load(self, Pickable)
    Selectable.load(self, Selectable)
    self:addEventListener("onClick")

    self:refreshActiveArmor()

    WorldActor.mixin(self, "WORLD_ACTOR.CHARACTER")
    if config.iconLocalPosition then
        self.worldActor:setIconLocalPos(config.iconLocalPosition)
    end

    if not self._noIcons then
        Icon.mixin(self)
        self.icon:mixinPinIcon(config.pinIcon)
        self.icon:mixinMinimapIcon()
        self.icon:setMinimapIcon(1, config.minimapIcon)
        self.icon:setMinimapIcon(2, "MINIMAP_ICONS.CHARACTER_SELECTED")
        self.icon:mixinStatusIcon()
        self.icon:mixinActorAlert()
        CombatStatus.mixin(self)
    end

    local isDead = self:isDead()
    self.worldActor:setIconVisible(not isDead)

    self:addComponent("Character")
    self._rgCharacter:createReticle(_s[uiConfig.reticleSprite], _s[uiConfig.selectedReticleSprite], _s[uiConfig.reticleColor])
    self._rgCharacter:setAnimatorController(_s[config.animatorController])

    if options.isNavigable then
        Navigable.load(self, Navigable)
        self:addEventListener("onFootStep")
    end

    CharacterAnims.mixin(self)
    MovementIndicator.mixin(self)

    VisionTarget.mixin(self)
    self.visionTarget:setActive(true)

    if options.hasVision then
        Vision.mixin(self)
        self.vision:setActive(true)
        -- self.vision.enableDebugDrawing = true
    end
    self:setEmotion("RELAXED")

    if options.isShooter then
        if config.ambidexterity then
            AmbidexterityShooter.mixin(self)
        else
            Shooter.mixin(self) 
        end
    end

    self.commands._thisActor = self
    self.commands:loadInstance()

    Relationships.load(self, Relationships)

    _lastPlayTime = clientTimeElapsedTime

    -- Add all of the events that the character handles
    self:addMultiEventListener(_characterEvents)

    self:setLayer(RomeroGames.GameObjectLayer.Character, true)

    Store.load(self, Store)

    self._rgCharacter:loadAnimationState(self._currAnim, self._currTriggers, self._currBools, self._currFloats, self._currInts)
    self._currAnim = nil
    self._currTriggers = nil
    self._currInts = nil
    self._currFloats = nil
    self._currBools = nil

    BrainMixin.load(self, BrainMixin)

    Feedback.mixin(self)

    self.infoId = self.configId
    Intel.addToDatabase(self)
    game:addEventListener("onWorldSetupComplete", self)
    game:addEventListener("onColorModeChanged", self)

    _checkAndSetTints(self)
end

function Character:postLoad()
    --print("Character:postLoad", self.name)
    Super.postLoad(self)

    if self.questGiverDescription then
        self:addQuestGiver(self.questGiverDescription)
    end


    if self.squad and not self:isDead() then
        if not self:hasTag("PreventProximityMonitor") then
            self:registerAsProximityMonitor()
        end
    end
end

function Character:getActorLifetime()
    return RomeroGames_ActorLifetime_Persistent
end

function Character:init(spawnParams, config, options)
    if not config then
        throwException("Missing config in Character:init")
        return
    end

    if not options then
        throwException("Missing options in Character:init")
        return
    end

    if not config.prefab then
        throwException("Unable to find the character's prefab")
    end

    local skillsConfig = config.skills
    if not skillsConfig then
        throwException("Unable to find the character skill config")
    end

    local uiConfig = Config.UI.CHARACTER
    if not uiConfig then
        throwException("Unable to find the character UI config")
    end
    
    local ambidexterityConfig = config.ambidexterity

    Super.init(self, spawnParams, config)

    if config.characterID then
        LocalizationUtils:setActorAlias(config.characterID, self)
    end

    -- Characters should have their visibility tracked
    TrackVisibility.mixin(self)

    -- Initialize the various stats
    self:applyConfig(config)
    self._myConfig = config

    Skills.mixin(self)
    self.skills:addSkills(skillsConfig)

    if ambidexterityConfig then
        Ambidexterity.mixin(self)
        self.ambidexterity:setData(ambidexterityConfig)
    end

    CharacterInventory.mixin(self)
    self:addEventListener("onInventoryUpdate", self)

    -- The priority on this is low since the function used to run after the event of the same name
    self:addEventListener("onPrepareForCombat", self, -1000)

    Profession.mixin(self)
    if config.profession then
        self.profession:add(config.profession)
    else
        self.profession:add("NoProfession")
    end

    Pickable.mixin(self)

    Selectable.mixin(self)
    self:addEventListener("onClick")

    WorldActor.mixin(self, "WORLD_ACTOR.CHARACTER")
    if config.iconLocalPosition then
        self.worldActor:setIconLocalPos(config.iconLocalPosition)
    end
    self.worldActor:setIconVisible(true)

    if not self._noIcons then
        Icon.mixin(self)
        self.icon:mixinPinIcon(config.pinIcon)
        self.icon:mixinMinimapIcon()
        self.icon:setMinimapIcon(1, config.minimapIcon)
        self.icon:setMinimapIcon(2, "MINIMAP_ICONS.CHARACTER_SELECTED")
        self.icon:mixinStatusIcon()
        self.icon:mixinActorAlert()
        CombatStatus.mixin(self)
    end

    self:addComponent("Character")
    self._rgCharacter:createReticle(_s[uiConfig.reticleSprite], _s[uiConfig.selectedReticleSprite], _s[uiConfig.reticleColor])
    self._rgCharacter:setAnimatorController(_s[config.animatorController])

    if options.isNavigable then
        Navigable.mixin(self, config)
        self.navigation:setActive(true)
        self:addEventListener("onFootStep")
    end

    CharacterAnims.mixin(self)
    -- Set the female or male animator bool
    self.anims:setBool("Feminine", self.gender == "f")

    MovementIndicator.mixin(self)

    self:addTag("NotifyCombat")
    self:addTag("NotifyCinematic")

    VisionTarget.mixin(self)
    self.visionTarget:setActive(true)

    if options.hasVision then
        Vision.mixin(self)
        self.vision:setActive(true)
        -- self.vision.enableDebugDrawing = true
    end
    
    self:setEmotion("RELAXED")

    if options.isShooter then
        if config.ambidexterity then
            AmbidexterityShooter.mixin(self)
        else
            Shooter.mixin(self)
        end
    end

    if config.commands then
        self.commands = ActorCommands:new(self, config.commands)
    end

    self.log = LimitedLog:new(64)

    Relationships.mixin(self)

    -- Add all of the events that the character handles
    self:addMultiEventListener(_characterEvents)


    self:setLayer(RomeroGames.GameObjectLayer.Character, true)

    BrainMixin.mixin(self, spawnParams.configId)
    self.brain:start()

    Feedback.mixin(self)

    self.infoId = self.configId
    Intel.addToDatabase(self)

    self.hasTalkedToPlayer = nil
    game:addEventListener("onWorldSetupComplete", self)
    game:addEventListener("onColorModeChanged", self)

    _checkAndSetTints(self)
end

function Character:onActorDelete()

    if self.squad then
        self.squad:removeMember(self)
    end
    if self.brain then
        self.brain:stop()
    end
    if self._combatTemp then
        _tablePool:releaseAndClear(self._combatTemp)
        self._combatTemp = nil
    end

    self:removeMultiEventListener(_characterEvents)
    if self.faction then
        self.faction:removeMultiEventListener(_playerFactionEvents, self)
    end

    self:removeEventListener("onInventoryUpdate", self)
    self:removeEventListener("onPrepareForCombat", self)
    self:removeEventListener("onClick")
    self:removeEventListener("onFootStep")
    game:removeEventListener("onWorldSetupComplete", self)
    game:removeEventListener("onColorModeChanged", self)

    Super.onActorDelete(self)
end

return newClass("RomeroGames.World.Actors.Characters.Character", Character, Super)

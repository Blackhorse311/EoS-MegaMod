--[[------------------------------------------------------------------------------
    MegaMod: Safehouse NPC Manager
    Spawns copies of MegaMod NPCs into all player safehouses, not just the
    primary one. Listens for onSafehouseAcquired to populate new safehouses.

    NPCs managed:
    - Evodio "Smokes" Zinna (The Cleaner) - NPC.MEGAMOD_CONTRACT_BROKER
    - "Top Jimmy" Malone (Recruiter)       - NPC.MEGAMOD_RECRUITER
    - Chloe "Big Brains" Shapleigh (Reno)  - NPC.MEGAMOD_RENOVATOR
    - "Slippery" Pete Kowalski (Fence)     - NPC.MEGAMOD_FENCE
    - Vincent "The Brief" Moretti (Lawyer) - NPC.MEGAMOD_LAWYER
    - Doc Stitches (Veterinarian)          - NPC.MEGAMOD_VETERINARIAN

    NOT managed: Mr. Smith (ICA Rep) - too tightly coupled to mission system.
    Mr. Smith remains in the primary safehouse only.

    Category A NPCs (Cleaner, Recruiter, Renovator) have support events that
    reference file-scoped persist{} variables. Their behaviours have been
    modified to proxy data through the primary actor, so clones using the same
    behaviour name work correctly.

    Category B NPCs (Fence, Lawyer, Vet) have fully self-contained behaviours
    and need no special handling.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_SAFEHOUSE_MANAGER"
_event = "MegaModSafehouseManager"
_gameStage = "Bridging"
_autoStartMode = "Schedule"
_triggerDelay = 300
_category = "Misc"

persist{}
spawnedSafehouses = {}
initialized = false

-- NPC registry: configId, behaviourName, and whether to set homeSafehouse
local NPC_REGISTRY = {
    { configId = "NPC.MEGAMOD_CONTRACT_BROKER", behaviourName = "MegaModBrokerBehaviour",     setHome = true  },
    { configId = "NPC.MEGAMOD_RECRUITER",       behaviourName = "MegaModRecruiterBehaviour",   setHome = true  },
    { configId = "NPC.MEGAMOD_RENOVATOR",       behaviourName = "MegaModRenovatorBehaviour",   setHome = true  },
    { configId = "NPC.MEGAMOD_FENCE",           behaviourName = "MegaModFenceBehaviour",       setHome = false },
    { configId = "NPC.MEGAMOD_LAWYER",          behaviourName = "MegaModLawyerBehaviour",      setHome = false },
    { configId = "NPC.MEGAMOD_VETERINARIAN",    behaviourName = "MegaModVetBehaviour",         setHome = false },
}

function canTrigger()
    return true
end

function onTrigger()
    -- Initial population: spawn NPCs into all existing non-primary safehouses
    populateAllSafehouses()
    initialized = true
    complete()
end

function GameEvent.onSafehouseAcquired(e)
    if not initialized then return end
    if not e or not e.faction or not e.faction.isPlayerFaction then return end
    local building = e.target
    if not building then return end
    local key = tostring(building)
    if spawnedSafehouses[key] then return end
    spawnNPCsIntoSafehouse(building)
end

function populateAllSafehouses()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    local primarySafehouse = playerFaction:getPrimarySafehouse()
    if not primarySafehouse then return end

    -- Mark primary as already handled (original spawn events put NPCs there)
    spawnedSafehouses[tostring(primarySafehouse)] = true

    -- Get all player safehouses and populate any non-primary ones
    local allSafehouses = {}
    playerFaction:getSafehouses(allSafehouses)
    for i = 1, #allSafehouses do
        local sh = allSafehouses[i]
        local key = tostring(sh)
        if sh ~= primarySafehouse and not spawnedSafehouses[key] then
            spawnNPCsIntoSafehouse(sh)
        end
    end
end

function spawnNPCsIntoSafehouse(safehouse)
    local key = tostring(safehouse)
    spawnedSafehouses[key] = true

    for i = 1, #NPC_REGISTRY do
        local entry = NPC_REGISTRY[i]
        local clone = ActorUtils:spawnActorWithNoLocation("NPC", entry.configId)
        if clone then
            safehouse:enter(clone, "IDLE", true)
            clone.behaviours:add(entry.behaviourName)
            if entry.setHome then
                clone.homeSafehouse = safehouse
            end
        end
    end
end

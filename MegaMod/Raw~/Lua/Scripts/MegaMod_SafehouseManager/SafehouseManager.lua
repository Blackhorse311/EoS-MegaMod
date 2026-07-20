--[[------------------------------------------------------------------------------
    MegaMod: Safehouse NPC Manager
    Spawns copies of MegaMod NPCs into all player safehouses, not just the
    primary one. Listens for onSafehouseAcquired to populate new safehouses
    and onSafehouseUnacquired to despawn clones from lost ones.

    NPCs managed:
    - Evodio "Smokes" Zinna (The Cleaner) - NPC.MEGAMOD_CONTRACT_BROKER
    - "Top Jimmy" Malone (Recruiter)       - NPC.MEGAMOD_RECRUITER
    - Chloe "Big Brains" Shapleigh (Reno)  - NPC.MEGAMOD_RENOVATOR
    - "Slippery" Pete Kowalski (Fence)     - NPC.MEGAMOD_FENCE
    - Vincent "The Brief" Moretti (Lawyer) - NPC.MEGAMOD_LAWYER
    - Doc Stitches (Veterinarian)          - NPC.MEGAMOD_VETERINARIAN

    NOT managed: Mr. Smith (ICA Rep) - too tightly coupled to mission system.
    Mr. Smith remains in the primary safehouse only.

    Category A NPCs (Cleaner, Recruiter, Renovator) have support events. Their
    behaviours hand work to those events via scheduleWithDelay varargs, so
    clones using the same behaviour name work correctly.

    Category B NPCs (Fence, Lawyer, Vet) have fully self-contained behaviours
    and need no special handling.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"
_id = "MEGAMOD_SAFEHOUSE_MANAGER"
_event = "MegaModSafehouseManager"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: "Schedule" events die after first trigger; "Create" + disableAutoComplete = permanent listener
_category = "Misc"

-- MEGAMOD FIX: keyed by safehouse locationId (stable across save/load, unlike
-- tostring()). Primary safehouse maps to true (original spawn events populate it);
-- other safehouses map to the list of spawned clone actor iids so they can be
-- despawned if the safehouse is lost.
persist{}
spawnedSafehouses = {}

-- NPC registry: configId, behaviourName, and whether to set home safehouse
local NPC_REGISTRY = {
    { configId = "NPC.MEGAMOD_CONTRACT_BROKER", behaviourName = "MegaModBrokerBehaviour",     setHome = true  },
    { configId = "NPC.MEGAMOD_RECRUITER",       behaviourName = "MegaModRecruiterBehaviour",   setHome = true  },
    { configId = "NPC.MEGAMOD_RENOVATOR",       behaviourName = "MegaModRenovatorBehaviour",   setHome = true  },
    { configId = "NPC.MEGAMOD_FENCE",           behaviourName = "MegaModFenceBehaviour",       setHome = false },
    { configId = "NPC.MEGAMOD_LAWYER",          behaviourName = "MegaModLawyerBehaviour",      setHome = false },
    { configId = "NPC.MEGAMOD_VETERINARIAN",    behaviourName = "MegaModVetBehaviour",         setHome = false },
}

function onCreate()
    disableAutoComplete()
end

function GameEvent.onDayBegin(e)
    -- Idempotent daily sweep: initial population plus catch-up for anything missed
    populateAllSafehouses()
end

function GameEvent.onSafehouseAcquired(e)
    if not e or not e.faction or not e.faction.isPlayerFaction then return end
    local building = e.target
    if not building then return end
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and building == playerFaction:getPrimarySafehouse() then
        -- Original spawn events put NPCs in the primary safehouse
        spawnedSafehouses[building:getLocationId()] = true
        return
    end
    if spawnedSafehouses[building:getLocationId()] then return end
    spawnNPCsIntoSafehouse(building)
end

-- MEGAMOD FIX: despawn clones when a safehouse is lost; clearing the key lets a
-- re-acquired safehouse repopulate
function GameEvent.onSafehouseUnacquired(e)
    if not e or not e.faction or not e.faction.isPlayerFaction then return end
    local building = e.target
    if not building then return end
    local key = building:getLocationId()
    local clones = spawnedSafehouses[key]
    if type(clones) == "table" then
        for i = 1, #clones do
            local clone = ActorUtils:getActorFromId(clones[i])
            if clone then
                clone:delete()
            end
        end
    end
    spawnedSafehouses[key] = nil
end

function populateAllSafehouses()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    local primarySafehouse = playerFaction:getPrimarySafehouse()
    if not primarySafehouse then return end

    -- Mark primary as already handled (original spawn events put NPCs there)
    spawnedSafehouses[primarySafehouse:getLocationId()] = true

    -- Get all player safehouses and populate any non-primary ones
    local allSafehouses = {}
    playerFaction:getSafehouses(allSafehouses)
    for i = 1, #allSafehouses do
        local sh = allSafehouses[i]
        if sh ~= primarySafehouse and not spawnedSafehouses[sh:getLocationId()] then
            spawnNPCsIntoSafehouse(sh)
        end
    end
end

function spawnNPCsIntoSafehouse(safehouse)
    local clones = {}
    spawnedSafehouses[safehouse:getLocationId()] = clones

    for i = 1, #NPC_REGISTRY do
        local entry = NPC_REGISTRY[i]
        local clone = ActorUtils:spawnActorWithNoLocation("NPC", entry.configId)
        if clone then
            safehouse:enter(clone, "IDLE", true)
            clone.behaviours:add(entry.behaviourName)
            if entry.setHome then
                -- MEGAMOD FIX: actor.memory is save-durable; ad-hoc fields are not
                clone.memory.megamodHomeSafehouse = safehouse
            end
            clones[#clones + 1] = clone.iid
        end
    end
end

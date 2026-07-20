--[[------------------------------------------------------------------------------
    MegaMod: Event Director
    Central random-event scheduler. Once a week it may pick one registered
    event and announce the pick; the chosen event's own monitor block decides
    whether it can actually run right now.

    Handshake contract (all event monitors are built against this):
      - Director picks:      raiseGameEvent("onMegaModEventPick",     "eventName", NAME)
      - Ineligible reply:    raiseGameEvent("onMegaModEventPass",     "eventName", NAME)
                             (director substitute-picks a different event, max 2
                              substitutions per roll, never repeating a name
                              already tried this roll)
      - Actually launched:   raiseGameEvent("onMegaModEventLaunched", "eventName", NAME)
                             (director stamps cooldown/once-flag on LAUNCH, not
                              on pick, so passes never burn cooldowns)

    Dispatch timing (verified in vanilla Libs/Events.lua): Utils:raiseGameEvent
    -> game:dispatchPooledEvent -> dispatchEventProtected runs every listener
    synchronously, and nested dispatch is supported. An entire pick / pass /
    substitute-pick cascade therefore resolves inside a single onWeekBegin
    call, before the outer raiseGameEvent returns. No roll state has to
    survive across frames.

    If a picked event has no registered listener (per the contract, silence is
    not a pass), the roll simply ends with no event that week.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

-- ---------------------------------------------------------------------------
-- Tunables
-- ---------------------------------------------------------------------------
local WEEKLY_EVENT_CHANCE = 0.35 -- chance per week that the director attempts a pick at all
local MAX_PICKS_PER_WEEK = 1     -- independent pick attempts per onWeekBegin
local GRACE_PERIOD = 200         -- no director events before worldTime 200 (world-seconds, same scale as the monitors' worldTime gates)
local GLOBAL_COOLDOWN_DAYS = 4   -- minimum days between any two director-launched events
local MAX_SUBSTITUTIONS = 2      -- contract: max substitute-picks after passes, per roll

-- ---------------------------------------------------------------------------
-- Event registry: name, weight (relative pick chance), cooldownDays, onceOnly
-- Names are the handshake identifiers each monitor matches against.
-- ---------------------------------------------------------------------------
local EVENT_REGISTRY = {
    -- Existing MegaMod events (monitors refactored to the director handshake)
    { name = "BLACK_SOX",         weight = 2, onceOnly = true },
    { name = "UNTOUCHABLE",       weight = 2, onceOnly = true },
    { name = "VALENTINES",        weight = 2, onceOnly = true },
    { name = "SHAKEDOWNS",        weight = 4, cooldownDays = 14 },
    { name = "FED_RAIDS",         weight = 3, cooldownDays = 21 },
    { name = "MOONSHINERS",       weight = 3, cooldownDays = 21 },
    { name = "BOOTLEG_HIJACK",    weight = 4, cooldownDays = 14 },
    { name = "RIVAL_PROVOCATION", weight = 4, cooldownDays = 14 },
    -- New historical events (listener files authored separately)
    { name = "RUM_ROW",           weight = 3, cooldownDays = 28 },
    { name = "PURPLE_GANG",       weight = 2, cooldownDays = 35 },
    { name = "POISON_BATCH",      weight = 2, cooldownDays = 45 },
    { name = "SEAGRAM_RUN",       weight = 3, cooldownDays = 28 },
    { name = "MILAFLORES",        weight = 2, cooldownDays = 35 },
    { name = "HOT_SPRINGS",       weight = 3, cooldownDays = 21 },
    { name = "ROTHSTEIN_LOAN",    weight = 2, cooldownDays = 60 },
    { name = "TAX_MAN",           weight = 2, cooldownDays = 60 },
    { name = "PINEAPPLE_PRIMARY", weight = 2, onceOnly = true },
    { name = "IZZY_MOE",          weight = 2, cooldownDays = 45 },
    { name = "ATLANTIC_CITY",     weight = 2, onceOnly = true },
    { name = "MURDER_INC",        weight = 2, cooldownDays = 45 },
}

--[[------------------------------------------------------------------------------
    Director - Create-mode permanent listener (see HardModeBankroll.lua /
    SafehouseManager.lua). One _id block owns all director state; script vars
    are NOT shared across _id blocks.
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_EVENT_DIRECTOR"
_event = "MegaModEventDirector"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

-- Script:save persists table vars by value (verified vanilla Script.lua:1373),
-- so the two roster tables below survive save/load like scalars do.
persist{}
lastLaunchTimes = {} -- eventName -> worldTime of its last director-driven launch

persist{}
firedOnceFlags = {} -- eventName -> true once a onceOnly event has launched

persist{}
lastDirectorEventTime = 0 -- worldTime of the most recent director-driven launch (global cooldown)

persist{}
lastPickedName = nil -- most recently LAUNCHED director event; never picked twice in a row

persist{}
rollActive = false -- scratch: a pick cascade is in flight (resolves within one frame)

persist{}
rollTriedNames = {} -- scratch: names already picked this roll (never re-tried this roll)

persist{}
rollSubstitutions = 0 -- scratch: substitute-picks consumed this roll

function onCreate()
    disableAutoComplete() -- permanent listener; must never auto-complete
end

-- MEGAMOD: helpers are plain GLOBAL functions (local function helpers lose the
-- sandbox env, so worldTime / Utils / script vars would be unreachable)

function directorGetRegistryEntry(eventName)
    for i = 1, #EVENT_REGISTRY do
        if EVENT_REGISTRY[i].name == eventName then
            return EVENT_REGISTRY[i]
        end
    end
    return nil
end

function directorIsEligible(entry)
    local name = entry.name
    if rollTriedNames[name] then return false end   -- already tried this roll
    if name == lastPickedName then return false end -- not the immediately previous director event
    if entry.onceOnly and firedOnceFlags[name] then return false end
    if entry.cooldownDays then
        local last = lastLaunchTimes[name]
        if last and (worldTime - last) < Utils:daysToSecs(entry.cooldownDays) then
            return false
        end
    end
    return true
end

function directorSelectWeighted()
    local totalWeight = 0
    for i = 1, #EVENT_REGISTRY do
        local entry = EVENT_REGISTRY[i]
        if directorIsEligible(entry) then
            totalWeight = totalWeight + entry.weight
        end
    end
    if totalWeight <= 0 then return nil end -- nothing eligible

    local roll = math.random() * totalWeight -- [0, totalWeight)
    local accumulated = 0
    for i = 1, #EVENT_REGISTRY do
        local entry = EVENT_REGISTRY[i]
        if directorIsEligible(entry) then
            accumulated = accumulated + entry.weight
            if roll < accumulated then
                return entry.name
            end
        end
    end
    return nil
end

function directorPickAndRaise()
    local name = directorSelectWeighted()
    if not name then
        rollActive = false
        return
    end
    rollTriedNames[name] = true
    -- Synchronous dispatch: any pass reply (and the substitute pick it causes)
    -- or launched reply fully resolves before this call returns
    Utils:raiseGameEvent("onMegaModEventPick", "eventName", name)
end

function GameEvent.onWeekBegin(e)
    if worldTime < GRACE_PERIOD then return end

    for i = 1, MAX_PICKS_PER_WEEK do
        -- Global cooldown: minimum spacing between any two director events
        -- (re-checked per pick because a launch this frame re-stamps it)
        if lastDirectorEventTime > 0
                and (worldTime - lastDirectorEventTime) < Utils:daysToSecs(GLOBAL_COOLDOWN_DAYS) then
            return
        end

        if math.random() < WEEKLY_EVENT_CHANCE then
            rollTriedNames = {}
            rollSubstitutions = 0
            rollActive = true
            directorPickAndRaise()
            rollActive = false -- cascade resolved synchronously; close the roll
        end
    end
end

function GameEvent.onMegaModEventPass(e)
    if not rollActive then return end -- no roll in flight; ignore stray passes
    local name = e and e.eventName
    if not name or not rollTriedNames[name] then return end -- only passes for events we picked this roll

    if rollSubstitutions >= MAX_SUBSTITUTIONS then
        rollActive = false -- substitution budget spent; no event this roll
        return
    end
    rollSubstitutions = rollSubstitutions + 1
    directorPickAndRaise()
end

function GameEvent.onMegaModEventLaunched(e)
    local name = e and e.eventName
    if not name then return end
    local entry = directorGetRegistryEntry(name)
    if not entry then return end -- not a director-registered event

    -- Stamp on LAUNCH, never on pick: passes must not burn cooldowns
    lastLaunchTimes[name] = worldTime
    if entry.onceOnly then
        firedOnceFlags[name] = true
    end
    lastDirectorEventTime = worldTime
    lastPickedName = name
    rollActive = false -- roll resolved
end

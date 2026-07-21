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
local WEEKLY_EVENT_CHANCE = 0.35 -- chance per ROLL WEEK that the director attempts a pick at all (scaled by fact.MegaModCfgEvents, clamped to [0, 0.9])
local ROLL_INTERVAL_WEEKS = 6    -- the director only rolls every Nth week (James 2026-07-20: weekly rolls made events feel constant)
local MAX_PICKS_PER_WEEK = 1     -- independent pick attempts per roll week
local GRACE_PERIOD = 200         -- no director events before worldTime 200 (world-seconds, same scale as the monitors' worldTime gates)
local GLOBAL_COOLDOWN_DAYS = 4   -- minimum days between any two director-launched events
local MAX_SUBSTITUTIONS = 2      -- contract: max substitute-picks after passes, per roll

-- MEGAMOD CONFIG: rubber-banding. Prosperity is scored weekly from the player's
-- bankroll and building count; hostile/opportunity pick weights tilt with it
-- (rich empires attract trouble, struggling ones catch breaks).
local PROSPERITY_CASH_POOR = 5000  -- below this bankroll counts as struggling
local PROSPERITY_CASH_RICH = 30000 -- above this bankroll counts as flush
local PROSPERITY_BLDG_POOR = 3     -- at/below this many buildings counts as struggling
local PROSPERITY_BLDG_RICH = 12    -- at/above this many buildings counts as flush
local RICH_HOSTILE_MULT = 1.6      -- hostile event weight when rich
local RICH_OPPORTUNITY_MULT = 0.7  -- opportunity event weight when rich
local POOR_HOSTILE_MULT = 0.6      -- hostile event weight when poor
local POOR_OPPORTUNITY_MULT = 1.5  -- opportunity event weight when poor

-- ---------------------------------------------------------------------------
-- Event registry: name, weight (relative pick chance), cooldownDays, onceOnly,
-- kind ("hostile" | "opportunity" | "neutral" -- drives the rubber-band weight
-- tilt above; unmarked entries are treated as neutral).
-- Names are the handshake identifiers each monitor matches against.
-- ---------------------------------------------------------------------------
local EVENT_REGISTRY = {
    -- Existing MegaMod events (monitors refactored to the director handshake)
    { name = "BLACK_SOX",         weight = 2, onceOnly = true,   kind = "neutral" },
    { name = "UNTOUCHABLE",       weight = 2, onceOnly = true,   kind = "neutral" },
    { name = "VALENTINES",        weight = 2, onceOnly = true,   kind = "neutral" },
    { name = "SHAKEDOWNS",        weight = 4, cooldownDays = 14, kind = "hostile" },
    { name = "FED_RAIDS",         weight = 3, cooldownDays = 21, kind = "hostile" },
    { name = "MOONSHINERS",       weight = 3, cooldownDays = 21, kind = "opportunity" },
    { name = "BOOTLEG_HIJACK",    weight = 4, cooldownDays = 14, kind = "hostile" },
    { name = "RIVAL_PROVOCATION", weight = 4, cooldownDays = 14, kind = "hostile" },
    -- New historical events (listener files authored separately)
    { name = "RUM_ROW",           weight = 3, cooldownDays = 28, kind = "opportunity" },
    { name = "PURPLE_GANG",       weight = 2, cooldownDays = 35, kind = "hostile" },
    { name = "POISON_BATCH",      weight = 2, cooldownDays = 45, kind = "hostile" },
    { name = "SEAGRAM_RUN",       weight = 3, cooldownDays = 28, kind = "opportunity" },
    { name = "MILAFLORES",        weight = 2, cooldownDays = 35, kind = "hostile" },
    { name = "HOT_SPRINGS",       weight = 3, cooldownDays = 21, kind = "opportunity" },
    { name = "ROTHSTEIN_LOAN",    weight = 2, cooldownDays = 60, kind = "hostile" },
    { name = "TAX_MAN",           weight = 2, cooldownDays = 60, kind = "hostile" },
    { name = "PINEAPPLE_PRIMARY", weight = 2, onceOnly = true,   kind = "neutral" },
    { name = "IZZY_MOE",          weight = 2, cooldownDays = 45, kind = "hostile" },
    { name = "ATLANTIC_CITY",     weight = 2, onceOnly = true,   kind = "opportunity" },
    { name = "MURDER_INC",        weight = 2, cooldownDays = 45, kind = "hostile" },
    -- Crew life events (listener files authored separately)
    { name = "CREW_GAMBLING",     weight = 2, cooldownDays = 45, kind = "neutral" },
    { name = "CREW_RAISE",        weight = 2, cooldownDays = 60, kind = "neutral" },
    { name = "CREW_GRUDGE",       weight = 2, cooldownDays = 45, kind = "neutral" },
    { name = "CREW_WEDDING",      weight = 1, cooldownDays = 90, kind = "opportunity" },
    { name = "CREW_COLD_FEET",    weight = 2, cooldownDays = 60, kind = "neutral" },
    { name = "POKER_NIGHT",       weight = 4, cooldownDays = 21, kind = "opportunity" },
    -- Rival boss personality events (listener files authored separately)
    { name = "BOSS_CAPONE_GIFT",      weight = 2, cooldownDays = 60, kind = "neutral" },
    { name = "BOSS_OBANION_FLOWERS",  weight = 2, cooldownDays = 60, kind = "neutral" },
    { name = "BOSS_GENNA_OLIVE_OIL",  weight = 2, cooldownDays = 60, kind = "neutral" },
    { name = "BOSS_SALTIS_TRUCE",     weight = 2, cooldownDays = 60, kind = "opportunity" },
    { name = "BOSS_VICE_KINGS_PARTY", weight = 2, cooldownDays = 60, kind = "opportunity" },
    { name = "BOSS_HIP_SING_TEA",     weight = 2, cooldownDays = 60, kind = "opportunity" },
    -- Insurance racket (listener file authored separately)
    { name = "INSURANCE_PITCH",   weight = 3, cooldownDays = 45, kind = "opportunity" },
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

persist{}
prosperityState = "normal" -- rubber-band state: "poor" | "normal" | "rich"; recomputed each roll week before the roll

persist{}
weeksSinceLastRoll = 0 -- onWeekBegin counter; the director only rolls every ROLL_INTERVAL_WEEKS weeks

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

-- MEGAMOD CONFIG: prosperity score for rubber-banding. Two signals (bankroll,
-- building count) each vote poor (-1) / neutral (0) / rich (+1); the sum picks
-- the state. Reads verified: playerFaction.cash.count (BlackSoxFixer),
-- #playerFaction.buildings (AldermanSystem/TheUntouchable).
function directorComputeProsperity()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.cash then return "normal" end
    local cash = playerFaction.cash.count or 0
    local buildingCount = (playerFaction.buildings and #playerFaction.buildings) or 0

    local score = 0
    if cash > PROSPERITY_CASH_RICH then
        score = score + 1
    elseif cash < PROSPERITY_CASH_POOR then
        score = score - 1
    end
    if buildingCount >= PROSPERITY_BLDG_RICH then
        score = score + 1
    elseif buildingCount <= PROSPERITY_BLDG_POOR then
        score = score - 1
    end

    if score >= 1 then return "rich" end
    if score <= -1 then return "poor" end
    return "normal"
end

-- MEGAMOD CONFIG: registry weight tilted by the current prosperity state
function directorEffectiveWeight(entry)
    local kind = entry.kind
    if prosperityState == "rich" then
        if kind == "hostile" then return entry.weight * RICH_HOSTILE_MULT end
        if kind == "opportunity" then return entry.weight * RICH_OPPORTUNITY_MULT end
    elseif prosperityState == "poor" then
        if kind == "hostile" then return entry.weight * POOR_HOSTILE_MULT end
        if kind == "opportunity" then return entry.weight * POOR_OPPORTUNITY_MULT end
    end
    return entry.weight -- neutral kind, or normal prosperity
end

function directorSelectWeighted()
    local totalWeight = 0
    for i = 1, #EVENT_REGISTRY do
        local entry = EVENT_REGISTRY[i]
        if directorIsEligible(entry) then
            totalWeight = totalWeight + directorEffectiveWeight(entry)
        end
    end
    if totalWeight <= 0 then return nil end -- nothing eligible

    local roll = math.random() * totalWeight -- [0, totalWeight)
    local accumulated = 0
    for i = 1, #EVENT_REGISTRY do
        local entry = EVENT_REGISTRY[i]
        if directorIsEligible(entry) then
            accumulated = accumulated + directorEffectiveWeight(entry)
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

    -- Only roll every Nth week; off-weeks just advance the counter
    weeksSinceLastRoll = weeksSinceLastRoll + 1
    if weeksSinceLastRoll < ROLL_INTERVAL_WEEKS then return end
    weeksSinceLastRoll = 0

    -- MEGAMOD CONFIG: weekly prosperity read for the rubber-band weight tilt
    -- (the whole pick cascade resolves inside this frame, so once per roll is enough)
    prosperityState = directorComputeProsperity()

    -- MEGAMOD CONFIG: event-frequency knob (fact.MegaModCfgEvents), clamped to [0, 0.9]
    local weeklyChance = WEEKLY_EVENT_CHANCE * (fact.MegaModCfgEvents or 1)
    if weeklyChance < 0 then weeklyChance = 0 end
    if weeklyChance > 0.9 then weeklyChance = 0.9 end

    for i = 1, MAX_PICKS_PER_WEEK do
        -- Global cooldown: minimum spacing between any two director events
        -- (re-checked per pick because a launch this frame re-stamps it)
        if lastDirectorEventTime > 0
                and (worldTime - lastDirectorEventTime) < Utils:daysToSecs(GLOBAL_COOLDOWN_DAYS) then
            return
        end

        if math.random() < weeklyChance then
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

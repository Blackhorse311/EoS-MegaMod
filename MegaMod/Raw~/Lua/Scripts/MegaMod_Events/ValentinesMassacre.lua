--[[------------------------------------------------------------------------------
    MegaMod: St. Valentine's Day Massacre
    One-time event: when at war with a faction and crew is 8+, a contact
    offers police uniforms and a plan to hit the rival's safehouse.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    MASSACRE CHOICE EVENT
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_VALENTINES_MASSACRE"
_event = "MegaModValentinesMassacre"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_VALM_title") --$ A Once-in-a-Lifetime Opportunity
    text("$MEGAMOD_VALM_text") --$ A contact pulls you aside at the speakeasy. He's got police uniforms -- real ones -- and a plan. Your biggest rival has a safehouse on the North Side, and every Tuesday morning their top boys meet there to count the week's take. One cold morning, your boys walk in wearing badges. Nobody questions cops. By the time the rivals figure it out, it's too late. It's bold. It's bloody. But if it works, it could break them.
    option("$MEGAMOD_VALM_send", sendHitSquad) --$ Send the hit squad
    option("$MEGAMOD_VALM_calloff", callItOff) --$ Call it off
end

-- MEGAMOD FIX: result pages must be separate events -- rebuilding this dialog after
-- complete() released the pooled event, so the result text never displayed.
function sendHitSquad()
    if math.random() < 0.70 then
        -- Success
        BRScript:PlayerAddCash(2000, "CASH.MISSION_REWARD")

        -- Apply major diplomacy damage to the hostile rival
        local playerFaction = WorldUtils:getPlayerFaction()
        if playerFaction then
            local knownGangs = playerFaction.diplomacy:getKnownGangs()
            for _, faction in next, knownGangs do
                if faction and faction.rating then
                    local rating = faction.rating:getScore(playerFaction) -- MEGAMOD FIX: getRating() doesn't exist
                    if rating and rating < -50 then
                        -- MEGAMOD FIX: DIPLOMACY.MASSACRE_HIT was defined nowhere; AMBUSHED is a real vanilla rating effect (-250)
                        faction.rating:applyEffect(playerFaction, "AMBUSHED")
                        break
                    end
                end
            end
        end

        WorldUtils:triggerEvent("MegaModValentinesSuccess")
    else
        -- Failure: massive police heat
        local playerFaction = WorldUtils:getPlayerFaction()
        if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
            local building = playerFaction.buildings[1]
            local precinct = building and building:getPrecinct() -- MEGAMOD FIX: building.precinct doesn't exist
            if precinct then
                -- MEGAMOD FIX: raiseGameEvent is only a UI toast; apply REAL heat first
                -- (vanilla PoliceActivityWatcher order: toast with pre-add value, then add)
                Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                    "alertKey", "MEGAMOD_VALM_HEAT",
                    "appliedPoliceActivity", 35,
                    "originalValue", precinct:getPoliceActivity(),
                    "effectId", "MEGAMOD_MASSACRE_HEAT",
                    "precinct", precinct,
                    "description", {"$Text", "Valentine's Day Massacre"})
                precinct:addTemporaryPoliceActivity(35)
            end
        end

        WorldUtils:triggerEvent("MegaModValentinesFail")
    end
end

function callItOff()
    WorldUtils:triggerEvent("MegaModValentinesPass")
end

--[[------------------------------------------------------------------------------
    MASSACRE RESULTS
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_VALENTINES_SUCCESS_RESULT"
_event = "MegaModValentinesSuccess"
_category = "Misc"

function onTrigger()
    title("$MEGAMOD_VALM_success_title") --$ Like Clockwork
    text("$MEGAMOD_VALM_success_text") --$ The hit went like clockwork. Your boys walked in wearing blue, lined them up against the wall, and sent a message that'll echo through every speakeasy in Chicago. The rival outfit is reeling, and $2000 from their counting table found its way into your pocket. They won't forget this. Nobody will.
    option("$MEGAMOD_VALM_dismiss") --$ History in the making.
end

_id = "MEGAMOD_VALENTINES_FAIL_RESULT"
_event = "MegaModValentinesFail"
_category = "Misc"

function onTrigger()
    title("$MEGAMOD_VALM_fail_title") --$ They Got Made
    text("$MEGAMOD_VALM_fail_text") --$ Your boys got made before they even pulled their pieces. Someone tipped off the rivals, or maybe the uniforms didn't fit right. Either way, shots were fired, neighbors called the real cops, and now every badge in Chicago is looking for the crew in the stolen police uniforms. The heat is on like never before.
    option("$MEGAMOD_VALM_dismiss") --$ Damn.
end

_id = "MEGAMOD_VALENTINES_PASS_RESULT"
_event = "MegaModValentinesPass"
_category = "Misc"

function onTrigger()
    title("$MEGAMOD_VALM_pass_title") --$ Cold Feet
    text("$MEGAMOD_VALM_pass_text") --$ Maybe another time. The uniforms go back in the trunk, the plan gets filed away, and your contact disappears into the night. Some opportunities only come once, but so do firing squads.
    option("$MEGAMOD_VALM_dismiss") --$ Smart move.
end

--[[------------------------------------------------------------------------------
    MASSACRE MONITOR - Weekly listener
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_VALENTINES_MONITOR"
_event = "MegaModValentinesMonitor"
_gameStage = "Bridging"
_autoStartMode = "Create" -- MEGAMOD FIX: Schedule+complete() unregistered onWeekBegin before it ever ran
_category = "Misc"

persist{}
massacreTriggered = false

function GameEvent.onWeekBegin(e)
    if massacreTriggered then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    -- Require 8+ crew members
    local members = playerFaction.members
    if not members or #members < 8 then return end

    -- Require at war with at least one faction (very negative rating)
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return end

    local hasHostileRival = false
    for _, faction in next, knownGangs do
        if faction and faction.rating then
            local rating = faction.rating:getScore(playerFaction) -- MEGAMOD FIX: getRating() doesn't exist
            if rating and rating < -50 then
                hasHostileRival = true
                break
            end
        end
    end
    if not hasHostileRival then return end

    -- 15% chance per week
    if math.random() < 0.15 then
        massacreTriggered = true
        WorldUtils:scheduleWithDelay("MegaModValentinesMassacre", 5, "TICK")
        complete() -- one-time event fired; this monitor is done
    end
end

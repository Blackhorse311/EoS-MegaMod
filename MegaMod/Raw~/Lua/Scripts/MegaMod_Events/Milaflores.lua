--[[------------------------------------------------------------------------------
    MegaMod: Milaflores (Chopper Squad)
    Director event "MILAFLORES". An informant warns that rivals have imported
    two Thompson guns from Detroit -- Milaflores Apartment Massacre style -- to
    ambush your crew. Meet it head-on, buy the route, or take your chances.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    MILAFLORES LISTENER - permanent director handshake + ambush lifecycle
    (squad refs persist fine in WORLD_EVENTS blocks -- vanilla TwistOfFateEvent
    persists ambushSquad the same way)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MILAFLORES_LISTENER"
_event = "MegaModMilafloresListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

persist{}
milafloresSquad = nil

persist{}
milafloresSquadTime = 0

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "MILAFLORES" then return end

    -- Needs a racket for the ambush to stake out, a crew worth ambushing,
    -- and no leftover chopper squad still on the street
    local playerFaction = WorldUtils:getPlayerFaction()
    local rackets = playerFaction and MissionUtils:controlledRackets()
    if not playerFaction or not rackets or #rackets == 0
            or not playerFaction.members or #playerFaction.members < 2
            or milafloresSquad then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "MILAFLORES")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModMilafloresOffer", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "MILAFLORES")
end

-- Raised by the offer dialog's walk-into-it option (dialog blocks can't share
-- squad state with this block, so the spawn happens here where the ref persists)
function GameEvent.onMegaModMilafloresAmbush(e)
    local rackets = MissionUtils:controlledRackets()
    if not rackets or #rackets == 0 then return end

    local racket = rackets[math.random(#rackets)]
    if not racket then return end

    -- Chopper squad outside one of your rackets (Capone-mission exterior pattern:
    -- building:getLocationId() = street the racket sits on; guard + guardIfFlee)
    local squad = MissionUtils:spawnSquad(6, nil, nil, 4)
    if not squad then return end
    local pos = racket:getInteractionPos3D()
    MissionUtils:placeSquad(squad, racket:getLocationId(), pos, nil, true, pos, true)
    milafloresSquad = squad
    milafloresSquadTime = worldTime
end

function GameEvent.onDayBegin(e)
    if not milafloresSquad then return end

    if MissionUtils:isSquadDead(milafloresSquad) then
        -- FACTION.THUGS fight: no faction war, no notoriety -- and two captured
        -- Thompsons fenced for a tidy sum
        milafloresSquad = nil
        BRScript:PlayerAddCash(1800, "CASH.ITEM_SOLD")
        WorldUtils:triggerEvent("MegaModMilafloresLoot")
    elseif (worldTime - milafloresSquadTime) > Utils:daysToSecs(30) then
        -- The trap went stale; the shooters drift off to find easier work
        MissionUtils:makeSquadLeave(milafloresSquad)
        milafloresSquad = nil
    end
end

--[[------------------------------------------------------------------------------
    MILAFLORES WARNING
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MILAFLORES_OFFER"
_event = "MegaModMilafloresOffer"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_MILAFLORES_title") --$ Chopper Squad
    text("$MEGAMOD_MILAFLORES_text") --$ A nervous little man who sells racing tips finds you in a back booth and talks with his hat in his hands. "You heard what happened at the Milaflores apartments in Detroit? Three fellas walked into a hallway and a Thompson gun cut 'em down before their hats hit the floor. Well -- two of them choppers just came into town on the evening train, and the fellas carrying 'em have been asking about YOUR crew's habits. Where they drink, when they collect." He wets his lips. "For five hundred I can tell you the route they'll take. Or don't pay me, and, well... hallways is bad places, is all I'm saying."
    option("$MEGAMOD_MILAFLORES_ready", milafloresWalkInReady) --$ Let them come. We'll be ready.
    if BRScript:PlayerCanAfford(500) then
        option("$MEGAMOD_MILAFLORES_pay", milafloresPayInformant) --$ Buy the route ($500)
    end
    option("$MEGAMOD_MILAFLORES_ignore", milafloresIgnore) --$ Beat it, tout. Hallways don't scare me.
end

-- MEGAMOD: result pages must be separate events (pooled event auto-completes on
-- option click, pages set in callbacks never display -- see FedRaids/Moonshiners)
function milafloresShowResult(titleKey, textKey)
    WorldUtils:triggerEvent("MegaModMilafloresResult", "resultTitle", titleKey, "resultText", textKey)
end

function milafloresWalkInReady()
    -- Spawn happens in the listener block, which owns the persistent squad ref
    Utils:raiseGameEvent("onMegaModMilafloresAmbush")
    milafloresShowResult("$MEGAMOD_MILAFLORES_ready_title", "$MEGAMOD_MILAFLORES_ready_text") --$ The Counter-Trap / If Detroit wants a massacre, you'll give them one -- pointed the other way. Word goes out to the crew: heaters oiled, vests on, nobody walks alone. The shooters have staked out one of your rackets, loitering across the street with their coats buttoned over something heavy. Put your people on that street and finish it. Two Thompson guns will fetch real money once they're pried out of dead hands.
end

function milafloresPayInformant()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < 500 then
        milafloresShowResult("$MEGAMOD_MILAFLORES_broke_title", "$MEGAMOD_MILAFLORES_broke_text") --$ Empty Pockets / You reach for the bankroll and it isn't there. The tout's face falls like a bad souffle. "No hard feelings, but I don't run a charity." He melts into the crowd, and you're left hoping his story was all smoke.
        return
    end
    BRScript:PlayerSubtractCash(500, "CASH.INFORMATION")
    milafloresShowResult("$MEGAMOD_MILAFLORES_paid_title", "$MEGAMOD_MILAFLORES_paid_text") --$ Cheap at the Price / The tout palms the bills and gives you everything: the flop they're sleeping in, the sedan they hired, the alley they picked, and the hour. Your crews change their routes, double up, and take the long way home for a week. The shooters wait two nights in a cold doorway for men who never come, then wire Detroit for train fare. Five hundred dollars, and nobody had to bleed. The tout tips his hat. "Pleasure, boss. I hear things all the time, you know where to find me."
end

function milafloresIgnore()
    -- 60% the tout was peddling smoke; 40% the choppers are real (rolled now,
    -- delivered later -- the delayed event queue is save-persisted)
    if math.random() < 0.40 then
        WorldUtils:scheduleWithDelay("MegaModMilafloresWound", Utils:daysToSecs(math.random(2, 4)), "TICK")
    end
    milafloresShowResult("$MEGAMOD_MILAFLORES_ignored_title", "$MEGAMOD_MILAFLORES_ignored_text") --$ Tout Shown the Door / "Every week it's something with you tip sellers. Last month it was poisoned beer, now it's Detroit choppers." You send him off with a flea in his ear and a nickel for the streetcar, and go back to your drink. Probably smoke. Touts eat by inventing trouble and selling the cure. Probably.
end

--[[------------------------------------------------------------------------------
    MILAFLORES WOUNDING - the tout wasn't lying
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MILAFLORES_WOUND"
_event = "MegaModMilafloresWound"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    -- Pick an available crew member to take the burst (Moonshiners eligibility)
    local victim = nil
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.members then
        local candidates = {}
        for i = 1, #playerFaction.members do
            local member = playerFaction.members[i]
            if member and member ~= playerFaction.boss and not member:isDead()
                    and not member:hasState("Injury")
                    and not member:hasState("SentAway")
                    and not member:hasState("Incarcerated") then
                candidates[#candidates + 1] = member
            end
        end
        if #candidates > 0 then
            victim = candidates[math.random(#candidates)]
        end
    end

    title("$MEGAMOD_MILAFLORES_wound_title") --$ Lead in a Doorway
    if victim then
        -- Vanilla injury application (GangsterEvents.lua): out for 7 days, then
        -- the Injury behaviour returns them to the safehouse on its own
        victim:addState("Injury", "configId", "INJURY_DATA.MODERATE", "days", 7, "hideAlert", true)
        setCharacterPortrait(victim)
        text({"$MEGAMOD_MILAFLORES_wound_text", victim}) --$ The tout was on the level. A sedan crawled past one of your collections and a Thompson gun opened up from the back seat -- thirty rounds in four seconds, glass and brick flying like confetti. {0:name} took a slug and went down in a doorway. The docs say a week in bed, maybe more, and the tailor says the coat's a total loss. The shooters were smoke before the echo died. Next time a little man offers to sell you a route, maybe listen.
    else
        text("$MEGAMOD_MILAFLORES_wound_lucky_text") --$ The tout was on the level -- a sedan rolled past one of your joints and a Thompson gun chewed the brickwork to powder. But the collection run was late, the doorway was empty, and thirty rounds of Detroit lead killed nothing but a window and a mailbox. Your boys count the holes in the wall and go a little pale. Luck like that doesn't come around twice.
    end
    option("$MEGAMOD_MILAFLORES_dismiss") --$ Hallways is bad places.
end

--[[------------------------------------------------------------------------------
    MILAFLORES LOOT - the choppers change hands
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MILAFLORES_LOOT_RESULT"
_event = "MegaModMilafloresLoot"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_MILAFLORES_loot_title") --$ Trophies from Detroit
    text("$MEGAMOD_MILAFLORES_loot_text") --$ It went the other way from Milaflores: your people were set, the shooters were surprised, and the only massacre on the street was theirs. Your boys came away with the prize -- two Thompson submachine guns, barely fired, hundred-round drums and all. A friendly fence who knows better than to ask questions pays $1,800 for the pair before the serial numbers cool. Detroit can bill the next of kin.
    option("$MEGAMOD_MILAFLORES_dismiss")
end

--[[------------------------------------------------------------------------------
    MILAFLORES RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_MILAFLORES_RESULT"
_event = "MegaModMilafloresResult"
_category = "Misc"

persist{}
resultTitle = nil

persist{}
resultText = nil

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title(resultTitle)
    text(resultText)
    option("$MEGAMOD_MILAFLORES_dismiss")
end

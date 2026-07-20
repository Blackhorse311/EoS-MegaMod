--[[------------------------------------------------------------------------------
    MegaMod: Masters of Disguise (EventDirector: IZZY_MOE)
    Izzy Einstein and Moe Smith -- the Prohibition Bureau's celebrity agents,
    five thousand arrests between them -- work in costume: gravediggers,
    football players, opera singers, whatever gets them past the peephole.
    "Izzy has arrived" can empty a speakeasy in four minutes flat. Word is
    two agents matching their act just hit town.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). The ignore
    branch resolves 3 days later via scheduleWithDelay (save-persisted).
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_IZZY_MOE_LISTENER"
_event = "MegaModIzzyMoeListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if e.eventName ~= "IZZY_MOE" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.buildings or #playerFaction.buildings < 1 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "IZZY_MOE")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModIzzyMoeWarning", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "IZZY_MOE")
end

--[[------------------------------------------------------------------------------
    THE WARNING
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_IZZY_MOE_WARNING"
_event = "MegaModIzzyMoeWarning"
_category = "Misc"

-- The raid lands: dump ~10% of stored alcohol (FedRaids shape) + heat on the
-- precinct of a random player building
function izzyMoeRaid()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction then return end

    local alcohol = playerFaction.alcohol
    if alcohol then
        local loss = math.floor(alcohol.stored * 0.10)
        if loss > 0 then
            alcohol:dump(nil, loss)
        end
    end

    if playerFaction.buildings and #playerFaction.buildings > 0 then
        local building = playerFaction.buildings[math.random(#playerFaction.buildings)]
        local precinct = building and building:getPrecinct()
        if precinct then
            precinct:addTemporaryPoliceActivity(15)
        end
    end
end

-- Cool every precinct where the player operates (dedupe by precinct id)
function izzyMoeCoolAllPrecincts(playerFaction, amount)
    if not playerFaction or not playerFaction.buildings then return end
    local seenPrecincts = {}
    for _, building in next, playerFaction.buildings do
        if building then
            local p = building:getPrecinct()
            if p and not seenPrecincts[p.id] then
                seenPrecincts[p.id] = true
                p:addTemporaryPoliceActivity(amount)
            end
        end
    end
end

function canTrigger() return true end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_IZZYMOE_warn_title") --$ Masters of Disguise
    text("$MEGAMOD_IZZYMOE_warn_text") --$ Every barkeep in town knows the legend: Izzy Einstein and Moe Smith, the Prohibition Bureau's vaudeville act. Five thousand pinches between them, and never once in uniform. They've come through peepholes dressed as gravediggers, football players, opera singers -- Izzy once got served by telling the bartender, straight out, "I'm a Prohibition agent," and the man laughed so hard he poured the drink. Now your doormen are hearing about two agents working that exact routine right here in town. Yesterday a "coal deliveryman" asked one of your bartenders where a thirsty fellow might warm up. He got wise and played dumb. Next man might not.
    option("$MEGAMOD_IZZYMOE_warn_photos", izzyMoePayDoormen) --$ Circulate their photographs ($600)
    option("$MEGAMOD_IZZYMOE_warn_ignore", izzyMoeIgnore) --$ It's two clowns in costumes. Ignore it.
    option("$MEGAMOD_IZZYMOE_warn_trap", izzyMoeSetTrap) --$ Set a trap. Stage a fake speakeasy ($1,000)
end

function izzyMoePayDoormen()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.cash or playerFaction.cash.count < 600 then
        -- Can't cover the doorman network: same exposure as ignoring it
        WorldUtils:scheduleWithDelay("MegaModIzzyMoeVisit", Utils:daysToSecs(3), "TICK")
        title("$MEGAMOD_IZZYMOE_photos_broke_title") --$ Short on Walking-Around Money
        text("$MEGAMOD_IZZYMOE_photos_broke_text") --$ Six hundred dollars, spread across every doorman, barkeep, and busboy on your payroll -- and right now you can't cover it. The word goes out anyway, but words without folding money attached have a way of being forgotten by Thursday. You'll just have to hope the costume boys pick somebody else's joints to play.
        option("$MEGAMOD_IZZYMOE_dismiss_broke") --$ Fingers crossed.
        return
    end

    BRScript:PlayerSubtractCash(600, "CASH.EXPENSES")

    title("$MEGAMOD_IZZYMOE_photos_title") --$ Know Their Faces
    text("$MEGAMOD_IZZYMOE_photos_text") --$ A newspaperman who owes you a favor pulls wire photos of the two agents, and by Friday every doorman, barkeep, and hat-check girl on your payroll has studied those faces the way seminarians study scripture. Fat fellow, round glasses, talks with his hands. Taller partner, always the straight man. Two weeks later a "Bulgarian wool merchant" with a familiar chin gets turned away from three of your joints in one night. Your places stay dry as a sermon whenever strangers knock, and the great detectives move along to easier pickings. Six hundred well spent.
    option("$MEGAMOD_IZZYMOE_dismiss_photos") --$ Worth every nickel.
end

function izzyMoeIgnore()
    WorldUtils:scheduleWithDelay("MegaModIzzyMoeVisit", Utils:daysToSecs(3), "TICK")

    title("$MEGAMOD_IZZYMOE_ignore_title") --$ Two Clowns in Costumes
    text("$MEGAMOD_IZZYMOE_ignore_text") --$ "Opera singers," you say. "Gravediggers. This is what Washington sends us." You toss the report in the wastebasket. Your joints have peepholes, passwords, and doormen who can smell a cop through a brick wall -- no fat man in a rented costume is going to talk his way past all that. Probably. Your head bartender doesn't look convinced, but he keeps it to himself and polishes the glasses a little harder than necessary.
    option("$MEGAMOD_IZZYMOE_dismiss_ignore") --$ Back to business.
end

function izzyMoeSetTrap()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.cash or playerFaction.cash.count < 1000 then
        -- Can't bankroll the sting: same exposure as ignoring it
        WorldUtils:scheduleWithDelay("MegaModIzzyMoeVisit", Utils:daysToSecs(3), "TICK")
        title("$MEGAMOD_IZZYMOE_trap_broke_title") --$ No Budget for Theater
        text("$MEGAMOD_IZZYMOE_trap_broke_text") --$ A proper fake speakeasy needs rent, furnishings, colored water in good bottles, and actors who can hold their nerve -- a thousand dollars, minimum, and the till won't stretch to it. The scheme goes back in the drawer, and your joints take their chances with the costume boys same as everybody else's.
        option("$MEGAMOD_IZZYMOE_dismiss_broke") --$ Fingers crossed.
        return
    end

    BRScript:PlayerSubtractCash(1000, "CASH.EXPENSES")

    if math.random() < 0.65 then
        izzyMoeCoolAllPrecincts(playerFaction, -15)

        title("$MEGAMOD_IZZYMOE_trap_win_title") --$ The Sting Stings Back
        text("$MEGAMOD_IZZYMOE_trap_win_text") --$ You rent a storefront, hang a curtain, hire a "bartender," and let exactly one rumor loose about the hottest new blind pig in town. Three nights later, in come a gravedigger and his solemn friend, ordering rye. What they get is cold tea, a room full of your people toasting lemonade, and a photographer from the morning edition you tipped off yourself. FAMOUS DRY SLEUTHS RAID SODA FOUNTAIN runs above the fold, and the whole city laughs over breakfast. The Bureau is so busy nursing its black eye that the cops ease off every corner you own. Best thousand you ever spent.
        option("$MEGAMOD_IZZYMOE_dismiss_win") --$ Send the Bureau my regards.
    else
        izzyMoeRaid()

        title("$MEGAMOD_IZZYMOE_trap_lose_title") --$ Out-Foxed
        text("$MEGAMOD_IZZYMOE_trap_lose_text") --$ The trouble with trapping a couple of professional actors is that they can smell a stage. The gravedigger takes one look at your too-perfect blind pig, orders a ginger ale, tips his hat, and leaves -- and while your people are congratulating themselves out front, his partner is at the back door of one of your REAL joints, dressed as an iceman, watching the barrels roll in. The axes come out an hour later. Product down the drain, a padlock on the door, and cops thick on the block. In the morning paper, the fat man calls it "the easiest pinch since Brooklyn."
        option("$MEGAMOD_IZZYMOE_dismiss_lose") --$ I hate those two.
    end
end

--[[------------------------------------------------------------------------------
    THE VISIT (3 days after ignoring the warning -- or failing to fund a response)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_IZZY_MOE_VISIT"
_event = "MegaModIzzyMoeVisit"
_category = "Misc"

function canTrigger() return true end

function onTrigger()
    setModal(true)

    if math.random() < 0.50 then
        title("$MEGAMOD_IZZYMOE_visit_clear_title") --$ False Alarm
        text("$MEGAMOD_IZZYMOE_visit_clear_text") --$ Three days pass, and the only strangers at your doors are the ordinary kind of thirsty. Then the papers clear it up: the costume boys spent the week across town, pinching a hotel bar dressed as a honeymooning couple -- one of them in the veil, the reports do not say which. Somebody else's headache, somebody else's padlock. Your bartenders breathe out for the first time all week, and the rye goes back on the top shelf where it belongs.
        option("$MEGAMOD_IZZYMOE_dismiss_clear") --$ Luck of the draw.
    else
        izzyMoeRaid()

        title("$MEGAMOD_IZZYMOE_visit_raid_title") --$ Izzy Has Arrived
        text("$MEGAMOD_IZZYMOE_visit_raid_text") --$ It happens on a Tuesday. A stout musician lugging a tuba case knocks at one of your joints, plays two numbers, buys a round for the band, and then stands on a chair and announces, "Izzy has arrived!" The tuba case is full of axe handles and warrants. By the time the barman reaches the alarm buzzer there are agents at both doors, the good stock is going down the storm drain, and a photographer is arranging your busted barrels into an attractive pile for the morning edition. Word is they left a note for you personally: "Lovely place. -- I. & M."
        option("$MEGAMOD_IZZYMOE_dismiss_raid") --$ Should've circulated the photographs.
    end
end

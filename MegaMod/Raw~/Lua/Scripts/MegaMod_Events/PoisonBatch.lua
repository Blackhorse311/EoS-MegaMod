--[[------------------------------------------------------------------------------
    MegaMod: Poison Batch (The Poisoner's Dram)
    Director event "POISON_BATCH". A batch of badly re-distilled government
    alcohol turns up in your stock -- the "chemist's war" comes to Chicago.
    Dump it, pay a chemist to save it, or sell it and live with what follows.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    POISON BATCH LISTENER - permanent director handshake (EventDirector pattern)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_POISONBATCH_LISTENER"
_event = "MegaModPoisonBatchListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "POISON_BATCH" then return end

    -- Needs actual liquor in storage for a tainted batch to hide in
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.alcohol or playerFaction.alcohol.stored < 10 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "POISON_BATCH")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModPoisonBatchOffer", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "POISON_BATCH")
end

--[[------------------------------------------------------------------------------
    POISON BATCH CHOICE
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_POISONBATCH_OFFER"
_event = "MegaModPoisonBatchOffer"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_POISONBATCH_title") --$ The Poisoner's Dram
    text("$MEGAMOD_POISONBATCH_text") --$ Your cellar man comes up pale as a bedsheet with a tin cup in his hand. "Boss, smell this." It smells like a hospital burning down. Somebody sold you a batch cooked off government industrial alcohol -- the stuff Washington's chemists poison on purpose so nobody drinks it -- and whatever rube re-distilled it didn't cook the death out. Papers say ten thousand poor souls have drunk their last off batches like this one. It's mixed in with your good stock, near a sixth of the cellar. What's the play?
    option("$MEGAMOD_POISONBATCH_dump", poisonBatchDump) --$ Pour it in the river (lose the batch)
    if BRScript:PlayerCanAfford(math.floor(800 * (fact.MegaModCfgCost or 1))) then -- MEGAMOD CONFIG: cost knob (paired with the charge in poisonBatchChemist)
        option("$MEGAMOD_POISONBATCH_chemist", poisonBatchChemist) --$ Hire a real chemist to re-distill it ($800)
    end
    option("$MEGAMOD_POISONBATCH_sell", poisonBatchSell) --$ Sell it anyway ($1,200)
end

-- MEGAMOD: result pages must be separate events (pooled event auto-completes on
-- option click, pages set in callbacks never display -- see FedRaids/Moonshiners)
function poisonBatchShowResult(titleKey, textKey)
    WorldUtils:triggerEvent("MegaModPoisonBatchResult", "resultTitle", titleKey, "resultText", textKey)
end

function poisonBatchDump()
    local playerFaction = WorldUtils:getPlayerFaction()
    if playerFaction and playerFaction.alcohol then
        local loss = math.floor(playerFaction.alcohol.stored * 0.15)
        if loss > 0 then
            playerFaction.alcohol:dump(nil, loss) -- FedRaids dump pattern
        end
    end
    poisonBatchShowResult("$MEGAMOD_POISONBATCH_dumped_title", "$MEGAMOD_POISONBATCH_dumped_text") --$ Down the Drain / Your boys work through the night rolling barrels to the riverbank. The bad batch goes into the water, and the fish of the Chicago River drink better than half the South Side tonight. It stings to watch product pour away, but nobody ever built an outfit on a trail of funerals. The cellar man sleeps easy. So do you.
end

function poisonBatchChemist()
    local cost = math.floor(800 * (fact.MegaModCfgCost or 1)) -- MEGAMOD CONFIG: cost knob (check + charge scale together)
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or playerFaction.cash.count < cost then
        poisonBatchShowResult("$MEGAMOD_POISONBATCH_broke_title", "$MEGAMOD_POISONBATCH_broke_text") --$ Can't Cover the Fee / The chemist wants eight hundred, cash, before he so much as lights a burner -- and the bankroll won't stretch. He packs his glassware and leaves you alone with the barrels and the smell.
        return
    end
    BRScript:PlayerSubtractCash(cost, "CASH.GENERIC")

    if math.random() < 0.75 then
        poisonBatchShowResult("$MEGAMOD_POISONBATCH_chemist_ok_title", "$MEGAMOD_POISONBATCH_chemist_ok_text") --$ Science Prevails / The chemist sets up in your cellar like a priest at an altar -- copper coils, thermometers, little glass bulbs. Two days of careful heat and he hands you a glass. "Clean," he says, and drinks it himself to prove it. The whole batch is saved, every last barrel. Eight hundred well spent. Somewhere, a government chemist is very disappointed.
    else
        -- Botched: the crew watched him fumble it and morale takes the hit
        local victim = nil
        local members = playerFaction.members
        if members then
            local candidates = {}
            for i = 1, #members do
                local member = members[i]
                if member and member ~= playerFaction.boss and not member:isDead() then
                    candidates[#candidates + 1] = member
                end
            end
            if #candidates > 0 then
                victim = candidates[math.random(#candidates)]
            end
        end
        if victim then
            victim.loyalty:add(-10, "$MEGAMOD_POISONBATCH_loyalty_botch") --$ Drank the chemist's "cure"
        end
        poisonBatchShowResult("$MEGAMOD_POISONBATCH_chemist_botch_title", "$MEGAMOD_POISONBATCH_chemist_botch_text") --$ The "Expert" / The chemist talks a fine game right up until his coil bursts and the cellar fills with smoke that peels paint. The batch is saved, more or less, but one of your boys took a "test glass" on the chemist's say-so and spent two days sicker than a mule with the colic. He's on his feet again, but he's telling everyone who'll listen that the boss hires quacks. Eight hundred dollars for a headache and a grudge.
    end
end

function poisonBatchSell()
    BRScript:PlayerAddCash(math.floor(1200 * (fact.MegaModCfgPayout or 1)), "CASH.ITEM_SOLD") -- MEGAMOD CONFIG: payout knob
    -- The bill comes due in 3 days (delayed event queue is save-persisted)
    WorldUtils:scheduleWithDelay("MegaModPoisonBatchFallout", Utils:daysToSecs(3), "TICK")
    poisonBatchShowResult("$MEGAMOD_POISONBATCH_sold_title", "$MEGAMOD_POISONBATCH_sold_text") --$ Sold / You tell the cellar man to cut it thin, label it rye, and move it to joints where nobody asks questions. Twelve hundred dollars finds its way into the till by Friday. The cellar man won't look at you. "It's business," you tell him. He nods the way a man nods when he's already picking out what he'll say to the police.
end

--[[------------------------------------------------------------------------------
    POISON BATCH FALLOUT - 3 days later, the obituaries run long
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_POISONBATCH_FALLOUT"
_event = "MegaModPoisonBatchFallout"
_category = "Misc"

function canTrigger()
    return true
end

function onTrigger()
    setModal(true)
    local playerFaction = WorldUtils:getPlayerFaction()

    -- Big heat lands on your busiest precinct (the one holding most of your buildings)
    if playerFaction and playerFaction.buildings and #playerFaction.buildings > 0 then
        local counts = {}
        local best, bestCount = nil, 0
        for _, building in next, playerFaction.buildings do
            local precinct = building and building:getPrecinct()
            if precinct then
                counts[precinct] = (counts[precinct] or 0) + 1
                if counts[precinct] > bestCount then
                    best, bestCount = precinct, counts[precinct]
                end
            end
        end
        if best then
            -- Toast first with pre-add value, then apply (ValentinesMassacre pattern)
            local heat = math.max(1, math.floor(25 * (fact.MegaModCfgHeat or 1))) -- MEGAMOD CONFIG: heat knob (toast quotes the same figure)
            Utils:raiseGameEvent("onPoliceActivityEffectApplied",
                "alertKey", "MEGAMOD_POISONBATCH_HEAT",
                "appliedPoliceActivity", heat,
                "originalValue", best:getPoliceActivity() or 0,
                "effectId", "MEGAMOD_POISONBATCH_HEAT",
                "precinct", best,
                "description", {"$Text", "Poison Liquor Deaths"})
            best:addTemporaryPoliceActivity(heat)
        end
    end

    -- The crew knows what was in those barrels
    if playerFaction and playerFaction.members then
        for _, member in next, playerFaction.members do
            if member and member ~= playerFaction.boss and not member:isDead() then
                member.loyalty:add(-5, "$MEGAMOD_POISONBATCH_loyalty_sold") --$ Sold poison liquor to the neighborhood
            end
        end
    end

    title("$MEGAMOD_POISONBATCH_fallout_title") --$ The Chemist's War
    text("$MEGAMOD_POISONBATCH_fallout_text") --$ The first one was a stockyard man who went blind at a lunch counter. By the weekend the count is eleven dead and twice that in the charity ward, and every one of them drank at a joint your barrels supply. The papers are calling it "the chemist's war" and demanding somebody hang for it. The precinct is crawling with detectives and federal men, and your own boys are drinking someplace else these days -- and looking at you sideways when they think you can't see.
    option("$MEGAMOD_POISONBATCH_fallout_dismiss") --$ Nobody made them drink it.
end

--[[------------------------------------------------------------------------------
    POISON BATCH RESULT DIALOG
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_POISONBATCH_RESULT"
_event = "MegaModPoisonBatchResult"
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
    option("$MEGAMOD_POISONBATCH_dismiss") --$ Understood.
end

--[[------------------------------------------------------------------------------
    MegaMod: The T-Men Cometh (EventDirector: TAX_MAN)
    The Treasury's Intelligence Unit -- Frank J. Wilson's ledger men -- have
    started building book cases against every big name in the rackets. The
    courts just ruled that illegal money is taxable money, and an auditor
    has flagged yours. You can't shoot a balance sheet.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass).
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_TAX_MAN_LISTENER"
_event = "MegaModTaxManListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function GameEvent.onMegaModEventPick(e)
    if e.eventName ~= "TAX_MAN" then return end

    local playerFaction = WorldUtils:getPlayerFaction()
    -- An audit needs books worth flagging and a precinct to lean on
    if not playerFaction or not playerFaction.cash or playerFaction.cash.count < 1000
            or not playerFaction.buildings or #playerFaction.buildings < 1 then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "TAX_MAN")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModTaxManAudit", 5, "TICK")
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "TAX_MAN")
end

--[[------------------------------------------------------------------------------
    THE AUDIT
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_TAX_MAN_AUDIT"
_event = "MegaModTaxManAudit"
_category = "Misc"

-- Find the precinct where the player has the most buildings (TheUntouchable shape)
function taxManBusiestPrecinct(playerFaction)
    if not playerFaction or not playerFaction.buildings then return nil end
    local precinctCounts = {}
    local bestPrecinct = nil
    local bestCount = 0
    for _, building in next, playerFaction.buildings do
        if building then
            local p = building:getPrecinct()
            if p then
                precinctCounts[p] = (precinctCounts[p] or 0) + 1
                if precinctCounts[p] > bestCount then
                    bestCount = precinctCounts[p]
                    bestPrecinct = p
                end
            end
        end
    end
    return bestPrecinct
end

-- Apply heat to every precinct where the player operates (dedupe by precinct id)
function taxManHeatAllPrecincts(playerFaction, amount)
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
    title("$MEGAMOD_TAXMAN_audit_title") --$ The T-Men Cometh
    text("$MEGAMOD_TAXMAN_audit_text") --$ A man from the Treasury Department is sitting in your front office. Gray suit, gray hat, ink on his fingers. He isn't a cop and he isn't a Prohibition agent -- he's worse. He's from the Intelligence Unit, Frank Wilson's outfit, the boys who take down big shots with adding machines instead of shotguns. The courts just decided that money from the rackets is taxable like any other, and this fellow has been flagging discrepancies in your books all morning. "We can resolve this here," he says, tapping his ledger, "or in front of a federal judge."
    option("$MEGAMOD_TAXMAN_audit_settle", taxManSettle) --$ Settle it quietly. Everyone has a number.
    option("$MEGAMOD_TAXMAN_audit_fight", taxManFight) --$ Fight it in court ($1,000 for the lawyer)
    option("$MEGAMOD_TAXMAN_audit_muscle", taxManIntimidate) --$ Explain how accidents happen to accountants.
end

function taxManSettle()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cash = (playerFaction and playerFaction.cash and playerFaction.cash.count) or 0

    -- 10% of current cash, floor $500, ceiling $5,000, never more than what's on hand
    local settlement = math.floor(cash * 0.10)
    if settlement < 500 then settlement = 500 end
    if settlement > 5000 then settlement = 5000 end
    settlement = math.min(settlement, cash)

    if settlement > 0 then
        BRScript:PlayerSubtractCash(settlement, "CASH.EXPENSES")
    end

    title("$MEGAMOD_TAXMAN_settle_title") --$ Amended Return
    text({"$MEGAMOD_TAXMAN_settle_text", settlement}) --$ Your bookkeeper and the Treasury man spend two hours together with a pot of coffee and a fresh ledger. When the smoke clears, you've filed an "amended return" for ${0} in back taxes, penalties, and what the gray man delicately calls "arithmetic errors." He tips his gray hat on the way out. It stings, but the government sells the cheapest protection in Chicago -- when it's selling.
    option("$MEGAMOD_TAXMAN_dismiss_settle") --$ Cheaper than a trial.
end

function taxManFight()
    local playerFaction = WorldUtils:getPlayerFaction()
    local cash = (playerFaction and playerFaction.cash and playerFaction.cash.count) or 0

    if cash < 1000 then
        -- Can't even retain the lawyer: the case proceeds and lands like a loss
        taxManApplyJudgment(playerFaction)
        return
    end

    BRScript:PlayerSubtractCash(1000, "CASH.EXPENSES")

    if math.random() < 0.60 then
        title("$MEGAMOD_TAXMAN_court_win_title") --$ Case Dismissed
        text("$MEGAMOD_TAXMAN_court_win_text") --$ Your lawyer earns his thousand. He buries the government in motions, gets half the evidence tossed for improper seizure, and produces three witnesses who swear your speakeasies are social clubs with unusually loyal memberships. The judge dismisses with a look that says he knows exactly what just happened and can't do a thing about it. On the courthouse steps, the Treasury man stops you. "We'll be seeing each other again," he says. Not today, though. Not today.
        option("$MEGAMOD_TAXMAN_dismiss_win") --$ God bless the American bar.
    else
        taxManApplyJudgment(playerFaction)
    end
end

-- The judgment lands: fine of 15% of cash (clamped) plus heat on the busiest precinct
function taxManApplyJudgment(playerFaction)
    local cash = (playerFaction and playerFaction.cash and playerFaction.cash.count) or 0
    local fine = math.min(math.floor(cash * 0.15), cash)
    if fine > 0 then
        BRScript:PlayerSubtractCash(fine, "CASH.FINE")
    end

    local precinct = taxManBusiestPrecinct(playerFaction)
    if precinct then
        precinct:addTemporaryPoliceActivity(15)
    end

    title("$MEGAMOD_TAXMAN_court_lose_title") --$ Judgment for the Government
    text({"$MEGAMOD_TAXMAN_court_lose_text", fine}) --$ The government's case is a stack of ledgers a foot high, and every page has your name between the lines. The judge rules for the Treasury: ${0} in back taxes and penalties, payable immediately. Worse, the trial made the papers, and now every beat cop in your best neighborhood is walking taller and looking harder. The T-men don't miss, they say. They got their ruling, and they got it on the ledgers, not the guns.
    option("$MEGAMOD_TAXMAN_dismiss_lose") --$ Burn the ledgers. All of them.
end

function taxManIntimidate()
    if math.random() < 0.50 then
        title("$MEGAMOD_TAXMAN_muscle_win_title") --$ A Nervous Accountant
        text("$MEGAMOD_TAXMAN_muscle_win_text") --$ Two of your larger associates walk the Treasury man to his streetcar. Nobody touches him. Nobody has to. They just discuss, in a general way, how dangerous this city can be for a fellow who works late over other people's arithmetic -- dark stairwells, icy sidewalks, automobiles that jump the curb. The next morning his report gets filed under "insufficient evidence" and he requests a transfer to somewhere with fewer stairwells. Cheap. But these ledger men talk to each other, and someday one of them won't scare.
        option("$MEGAMOD_TAXMAN_dismiss_scared") --$ Everybody scares. Eventually.
    else
        local playerFaction = WorldUtils:getPlayerFaction()
        taxManHeatAllPrecincts(playerFaction, 25)

        title("$MEGAMOD_TAXMAN_muscle_lose_title") --$ Federal Attention
        text("$MEGAMOD_TAXMAN_muscle_lose_text") --$ The Treasury man doesn't scare. He writes down every word your boys said, verbatim, in shorthand, while they're saying it -- then wires Washington that an examination target attempted to intimidate a federal officer. Within the week there are gray suits on every corner you own, taking photographs, copying license plates, buying nickel coffees and nursing them for hours. You wanted the audit to go away. Instead you put your whole operation under the government's magnifying glass.
        option("$MEGAMOD_TAXMAN_dismiss_feds") --$ Swell. Just swell.
    end
end

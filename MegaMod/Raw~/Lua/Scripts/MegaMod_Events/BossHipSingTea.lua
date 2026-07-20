--[[------------------------------------------------------------------------------
    MegaMod: Tea on Cermak Road (EventDirector: BOSS_HIP_SING_TEA)
    Sai Wing Mock -- Mock Duck to the newspapers -- survived every tong war
    and every assassin New York could send before bringing the Hip Sing to
    Chicago. A formal invitation to tea from the Hip Sing is court ceremony:
    the business happens in the pauses, and the pauses are graded.

    Handshake: the MegaMod EventDirector raises onMegaModEventPick; this file
    answers with onMegaModEventLaunched (or onMegaModEventPass). Eligible only
    while the Hip Sing Tong is in the campaign, known to the player, and the
    boss is still pouring.
--------------------------------------------------------------------------------]]

_namespace = "WORLD_EVENTS"

--[[------------------------------------------------------------------------------
    DIRECTOR LISTENER (permanent, Create-mode)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSHIPSING_LISTENER"
_event = "MegaModBossHipSingListener"
_gameStage = "Bridging"
_autoStartMode = "Create"
_category = "Misc"

function onCreate()
    disableAutoComplete() -- permanent handshake listener; must never auto-complete
end

-- Hip Sing Tong in campaign + known to player (getKnownGangs + _active) + boss alive
function bossHipSingFindTong()
    local playerFaction = WorldUtils:getPlayerFaction()
    if not playerFaction or not playerFaction.diplomacy then return nil end
    local knownGangs = playerFaction.diplomacy:getKnownGangs()
    if not knownGangs then return nil end
    for i = 1, #knownGangs do
        local gang = knownGangs[i]
        if gang and gang._active and gang.configId == "FACTION.HIP_SING_TONG"
                and gang.boss and not gang.boss:isDead() then
            return gang
        end
    end
    return nil
end

function GameEvent.onMegaModEventPick(e)
    if not e or e.eventName ~= "BOSS_HIP_SING_TEA" then return end

    local tong = bossHipSingFindTong()
    if not tong then
        Utils:raiseGameEvent("onMegaModEventPass", "eventName", "BOSS_HIP_SING_TEA")
        return
    end

    WorldUtils:scheduleWithDelay("MegaModBossHipSingOffer", 5, "TICK",
        "hipSingTeaFactionId", tong.factionId)
    Utils:raiseGameEvent("onMegaModEventLaunched", "eventName", "BOSS_HIP_SING_TEA")
end

--[[------------------------------------------------------------------------------
    THE INVITATION
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSHIPSING_OFFER"
_event = "MegaModBossHipSingOffer"
_category = "Misc"

persist{}
hipSingTeaFactionId = nil -- Expected Param

function bossHipSingGetTong()
    local tong = WorldUtils:getFactionByFactionId(hipSingTeaFactionId)
    if tong and tong._active then return tong end
    return nil
end

function bossHipSingDealPayout()
    return math.floor(900 * (fact.MegaModCfgPayout or 1) + 0.5)
end

function bossHipSingShowResult(titleKey, textKey, arg)
    WorldUtils:triggerEvent("MegaModBossHipSingResult",
        "bossHipSingResultTitle", titleKey,
        "bossHipSingResultText", textKey,
        "bossHipSingResultArg", arg)
end

function canTrigger()
    return hipSingTeaFactionId ~= nil
end

function onTrigger()
    setModal(true)
    title("$MEGAMOD_BOSSHIPSING_title") --$ Tea on Cermak Road
    text("$MEGAMOD_BOSSHIPSING_text") --$ The letter is delivered by an elderly man who waits, unhurried, while you read it: fine paper, folded once, the characters brushed and the translation typed beneath in a courteous hand. The Hip Sing Tong requests the honor of your company for tea. Everybody who knows anything knows Sai Wing Mock -- Mock Duck, the papers called him in New York, back when rival hatchet men were dying of surprise around him and he walked out of every ambush the tongs could arrange, alive, mild, faintly amused. New York got too interested; Chicago got the benefit. An invitation like this is not refreshment, it is court ceremony. The tea will be poured in a certain order. The silences will be measured. Business, if there is business, will be conducted in the pauses between politenesses -- and how you hold your cup will be reported to people you will never meet.
    option("$MEGAMOD_BOSSHIPSING_attend", bossHipSingAttend) --$ Attend, and honor the forms.
    option("$MEGAMOD_BOSSHIPSING_press", bossHipSingPress) --$ Attend, and press for a trade arrangement.
    option("$MEGAMOD_BOSSHIPSING_decline", bossHipSingDecline) --$ Decline, with formal regrets.
end

function bossHipSingAttend()
    local playerFaction = WorldUtils:getPlayerFaction()

    local cases = math.random(6, 10)
    if playerFaction then
        WorldUtils:addAlcoholToFaction(playerFaction, cases, 6) -- type 6 = ALCOHOL.WHISKEY
    end

    local tong = bossHipSingGetTong()
    if tong and playerFaction then
        tong.rating:applyEffect(playerFaction, "FAVOR_GRANTED_HALF")
    end

    bossHipSingShowResult("$MEGAMOD_BOSSHIPSING_attend_title", "$MEGAMOD_BOSSHIPSING_attend_text", cases) --$ The Guest Who Understood / You arrive precisely on time, accept the chair you are shown, and let the ceremony carry you -- the pour, the pause, the small dry cakes, the conversation that circles business the way a hawk circles a field, never once landing. Sai Wing Mock says perhaps forty words all afternoon and none of them matter; the afternoon itself is the message. You matched the room's patience and the room noticed. At the door, the elderly man who brought the invitation presents a parting courtesy: {0} cases of Canadian whiskey, bonded, beautiful, the kind the tong imports for its own tables. "A gift between neighbors," he says. On Cermak Road, neighbor is a title. It is not given twice.
end

function bossHipSingPress()
    local playerFaction = WorldUtils:getPlayerFaction()
    local tong = bossHipSingGetTong()

    if math.random() < 0.50 then
        local payout = bossHipSingDealPayout()
        BRScript:PlayerAddCash(payout, "CASH.TRADE")
        bossHipSingShowResult("$MEGAMOD_BOSSHIPSING_press_win_title", "$MEGAMOD_BOSSHIPSING_press_win_text", payout) --$ Business in the Pauses / You wait until the third pouring -- long enough to show manners, soon enough to show purpose -- and set your proposition down gently, like a cup. Distribution. Certain streets, certain goods, certain silences kept on both sides. Sai Wing Mock considers it for the length of one entire cup of tea, an eternity measured in steam, and then nods once, a movement you'd miss if you blinked. The terms are settled without a single number spoken aloud; the numbers arrive that evening, by the same elderly man, in the same fine folded paper, along with ${0} as the arrangement's first fruit. The tong's word, once given, is iron. You drank tea with Mock Duck and walked out with a treaty. Few in this town can say the first half, let alone the second.
    else
        if tong and playerFaction then
            tong.rating:applyEffect(playerFaction, "THREATENED")
        end
        bossHipSingShowResult("$MEGAMOD_BOSSHIPSING_press_lose_title", "$MEGAMOD_BOSSHIPSING_press_lose_text") --$ The Cup, Refilled / You raise business on the second pouring, which is one pouring too early, in a tone one shade too direct, and the temperature of the room drops a degree nobody mentions. Sai Wing Mock refills your cup himself -- an honor, technically, and also, in the grammar of that room, a correction. The afternoon continues, flawless and impenetrable, and business is never spoken of again; it has been decided, and you were present for the deciding without being told the verdict. Only at the door do you understand. The elderly man bows exactly one inch less deeply than when you arrived. The Hip Sing survived the tong wars by reading men early and forgetting nothing afterward. You have been read. The file is closed. Reopening it will cost more than tea.
    end
end

function bossHipSingDecline()
    bossHipSingShowResult("$MEGAMOD_BOSSHIPSING_decline_title", "$MEGAMOD_BOSSHIPSING_decline_text") --$ Formal Regrets / You send your answer the way the invitation came: good paper, careful words, a formal regret pleading the press of affairs. It is the correct form and the tong will receive it correctly -- courtesy declined with courtesy leaves no debt on either side of the ledger. But understand what was declined. The Hip Sing does not invite twice lightly, and Sai Wing Mock did not live through four decades of hatchet men by wasting hospitality on the incurious. Somewhere on Cermak Road your name is entered in a book, in beautiful brushwork, under a heading you will never see translated. Not an enemy. Not a neighbor. Merely: declined. In Chinatown, ledgers like that outlive the men they describe.
end

--[[------------------------------------------------------------------------------
    RESULT DIALOG (generic title/text + optional format arg)
--------------------------------------------------------------------------------]]
_id = "MEGAMOD_BOSSHIPSING_RESULT"
_event = "MegaModBossHipSingResult"
_category = "Misc"

persist{}
bossHipSingResultTitle = nil

persist{}
bossHipSingResultText = nil

persist{}
bossHipSingResultArg = nil

function canTrigger()
    return bossHipSingResultTitle ~= nil
end

function onTrigger()
    setModal(true)
    title(bossHipSingResultTitle)
    if bossHipSingResultArg ~= nil then
        text({bossHipSingResultText, bossHipSingResultArg})
    else
        text(bossHipSingResultText)
    end
    option("$MEGAMOD_BOSSHIPSING_dismiss") --$ Mind the pauses.
end

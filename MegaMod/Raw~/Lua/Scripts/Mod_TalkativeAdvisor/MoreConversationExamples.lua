_namespace = "CONVERSATIONS" -- This indicates the following scripts will be conversations
--[[------------------------------------------------------------------------------
    So here's something I didn't cover in the tutorial. I'm going to set up a base conversation that the rest of these will use.
--------------------------------------------------------------------------------]]
_id = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
_abstract = true
EntryPoint = "TalkToAdvisor_Advice"
TalkingAbout = "GettingAdviceFromAdvisor"
OnlyUseOnce = true

function onStart()
    go(GiveAdvice)
end

function GiveAdvice() -- Override in including scripts
end

function CheckForMoreAdvice()
    callConversationEntry("TalkToAdvisor_End")
end

--[[------------------------------------------------------------------------------]]

_id = "MOD_TALKATIVE_ADVISOR_NORTHSIDE_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE" -- Now we don't need to set up all the boilerplate code!
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.NORTHSIDE_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_NorthsideBonuses_GiveAdvice_Say") --$ Deflect upgrades are discounted for your Breweries, and spreading Word of Mouth about your Speakeasies also comes cheap. Keep that in mind when setting up a new racket.
    option("$Mod_TalkativeAdvisor_NorthsideBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ What can I say, the Irish know how to promote a business.
end

_id = "MOD_TALKATIVE_ADVISOR_WHITECITY_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.WHITECITY_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_WhitecityBonuses_GiveAdvice_Say") --$ Your Brothels are cheap to upgrade, and the cops seem to leave your Speakeasies alone, might want to invest in those Rackets!
    -- Another feature of using {you} or {them} in a string is that you can insert a different bit of text depending on the character's gender?male|female|neuter
    option("$Mod_TalkativeAdvisor_WhitecityBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Ha, what did I say, {them:gender?boy|girl|pal}! The cops are all clowns in my ring.
end

_id = "MOD_TALKATIVE_ADVISOR_RAGENCOLTS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.RAGENCOLTS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_RagenColtsBonuses_GiveAdvice_Say") --$ Your Breweries produce more than other gangs and your Speakeasies have discounted Deflect upgrades. Always a good idea to invest in those rackets.
    option("$Mod_TalkativeAdvisor_RagenColtsBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Hmmm...
end

_id = "MOD_TALKATIVE_ADVISOR_DONOVANS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.DONOVANS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_DonovansBonuses_GiveAdvice_Say") --$ Your Breweries have a discount to upgrading their production quality, and your Speakeasies Ambience upgrades are cheaper too. It would be worth putting some money into those upgrades.
    option("$Mod_TalkativeAdvisor_DonovansBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Fair play, I'll keep that in mind so.
end

_id = "MOD_TALKATIVE_ADVISOR_VICEKINGS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.VICEKINGS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_ViceKingsBonuses_GiveAdvice_Say") --$ The cops don't seem to cause much fuss around your Brothels, and the upgrades to Deflect them are also cheaper. I highly recommend investing in Brothels.
    option("$Mod_TalkativeAdvisor_ViceKingsBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ I always have valued discretion.
end

_id = "MOD_TALKATIVE_ADVISOR_SALTIS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.SALTIS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_SaltisBonuses_GiveAdvice_Say") --$ Compared to the other gangs in Chicago your Brothels generate more cash and your Speakeasies start with an additional upgrade level. Sounds like a way to make some fast dough.
    option("$Mod_TalkativeAdvisor_SaltisBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ I like the sound of that.
end

_id = "MOD_TALKATIVE_ADVISOR_LOSLUCEROS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.LOSLUCEROS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_LosLucerosBonuses_GiveAdvice_Say") --$ Your Brothels have discounted Security upgrades and provide an extra reinforcement to your Depots and Safehouses. I think the Brothel racket is where you'll excel, <i>señora</i>.
    -- The <i></i> tags will italicize any words they wrap around, we're using them here to stylize the spanish spoken by Elvira.
    option("$Mod_TalkativeAdvisor_LosLucerosBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ <i>Bueno</i>. I'll have a think about it, <i>{them:gender?chico|chica|chice}</i>.
end

_id = "MOD_TALKATIVE_ADVISOR_ALLEYCATS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.ALLEYCATS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_AlleyCatsBonuses_GiveAdvice_Say") --$ Casinos are the rackets to invest in. The Alley Cats' Casinos don't get as bothered by the cops, and we've got discounts on upgrading Casino Security.
    option("$Mod_TalkativeAdvisor_AlleyCatsBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Seems I know where I'll be placing my bets.
end

_id = "MOD_TALKATIVE_ADVISOR_FORTUNETELLERS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.FORTUNETELLERS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_FortuneTellersBonuses_GiveAdvice_Say") --$ The Fortune Tellers Speakeasies have boosted income, and your Casinos are cheaper to upgrade. I recommend both of those rackets if you're thinking of expanding.
    option("$Mod_TalkativeAdvisor_FortuneTellersBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ <i>Merci</i>. I'll consider it, {them:lastName}.
end

_id = "MOD_TALKATIVE_ADVISOR_HIPSINGTONG_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.HIPSINGTONG_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_HipSingTongBonuses_GiveAdvice_Say") --$ Your Brothels get an additional guard, and you get a discount when upgrading the Word of Mouth at your Casino. Both opportunities to make use of when expanding your empire.
    option("$Mod_TalkativeAdvisor_HipSingTongBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ Hmm... I will consider this when forming my expansion strategy.
end

_id = "MOD_TALKATIVE_ADVISOR_CARDSHARKS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.CARDSHARKS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_CardSharksBonuses_GiveAdvice_Say") --$ Casinos! The Card Sharks get Security discounts to Casinos, and they also provide an extra reinforcement to your depots and safehouses. If you're planning to expand, that's the way I'd do it.
    option("$Mod_TalkativeAdvisor_CardSharksBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ <i>Merveilleuse</i>, a wonderful plan!
end

_id = "MOD_TALKATIVE_ADVISOR_LOSHIJOS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.LOSHIJOS_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_LosHijosBonuses_GiveAdvice_Say") --$ Your Brothels get a discount on upgrading their Ambience, and your Casinos draw more customers to your Precinct. I'd say those are both smart rackets to be running.
    option("$Mod_TalkativeAdvisor_LosHijosBonuses_GiveAdvice_Option1", CheckForMoreAdvice) --$ <i>Sí, estoy de acuerdo.</i>
end

_id = "MOD_TALKATIVE_ADVISOR_MURDER_BOSS_EMPIRE_BONUSES"
_includes = "MOD_TALKATIVE_ADVISOR_ADVICE_BASE"
MatchingRules =
{
    function() return BRScript:YouAre("CHARACTER.BOSS.MURDER_BOSS") end,
}

function GiveAdvice()
    say("$Mod_TalkativeAdvisor_MurderIncBonuses_GiveAdvice_Say") --$ Loan sharks seem to be your best bet. Your Loan Shark rackets start at a higher upgrade level, and your clients are less likely to default on their loans.
    option("$Mod_TalkativeAdvisor_MurderIncBonuses_GiveAdvice_Option1", GangstersWorkUnpaid) --$ I'll add that to the records, {them:lastName}.
end

function GangstersWorkUnpaid()
    say("$Mod_TalkativeAdvisor_MurderIncBonuses_GangstersWorkUnpaid_Say") --$ Also listen, I know you're going to keep everyone paid here, right? But in case you're short on payment, the boys will work a few extra weeks before getting restless.
    option("$Mod_TalkativeAdvisor_MurderIncBonuses_GangstersWorkUnpaid_Option1", GangstersLeave) --$ Good to know my crew is loyal in tough times.
end

function GangstersLeave()
    say("$Mod_TalkativeAdvisor_MurderIncBonuses_GangstersLeave_Say") --$ Not too loyal now, while we might put up with the extra time, if any of us do leave I can tell you for sure there's no way you'll be able to hire us back.
    option("$Mod_TalkativeAdvisor_MurderIncBonuses_GangstersLeave_Option1", GangstersLeave) --$ Don't worry, {them:firstName}, I keep the books around here and nobody's missing a paycheck.
end

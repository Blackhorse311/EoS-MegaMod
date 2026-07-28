# Empire of Sin — MegaMod 🍸

**Seventeen classic Workshop mods, eight new safehouse characters, thirty-plus new world events, difficulty profiles, and a pile of vanilla bug fixes — merged into one zip that just works.**

![Game](https://img.shields.io/badge/game-Empire%20of%20Sin-8b0000)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)
![Made with](https://img.shields.io/badge/made%20with-Lua-2C2D72)

---

## 30 Seconds to Understand

```
Download EoS_MegaMod.zip
        │
        ▼
Drop it in  …\AppData\LocalLow\Paradox Interactive\Empire of Sin\Mods\Unmanaged\
        │
        ▼
Enable it in the Paradox Launcher playset
        │
        ▼
Start (or continue) a campaign
        │
        ├─► Day 1: pick a difficulty profile (Speakeasy Stroll / Business as Usual / The Full Capone)
        ├─► New faces move into your safehouse (broker, recruiter, fence, lawyer, vet, loan shark…)
        ├─► The Event Director starts rolling weekly 1920s events at you
        └─► All the classic Workshop QoL mods are already active
```

---

## Key Features

| Feature | What it does |
|---|---|
| 🧩 **17 Workshop mods merged** | Protection Money, Better Black Market, Increased Crew Size, No Mission Time Limit, Weapon Affinity 6, Neighbourhood Overview, Sugar Daddy, Gunpowder Shop, Chatty Advisor, and more — conflict-free in one package |
| 🏠 **8 new safehouse characters** | The Cleaner (contracts), Top Jimmy (recruiting), The Architect (renovations), The Fence, The Lawyer, Mr. Smith (ICA contracts), Doc Stitches (the Vet), and Mad Sam (juice loans) |
| 🗞️ **30+ new world events** | Historical events (Rum Row, the Pineapple Primary, Izzy & Moe, Murder Inc., Atlantic City summit…), crew life events (weddings, grudges, gambling, nicknames), boss events, and rival provocations |
| ⚖️ **Difficulty profiles** | One-time day-1 choice tunes costs, payouts, police heat, event frequency, and federal heat across the whole mod |
| 🕵️ **Federal Heat & sim layer** | Federal attention, fed raids, insurance, the Tax Man, shakedowns, speakeasy reputation, economy scaling, newspaper headlines |
| 🔫 **New weapon content** | Black-market legendaries, boss weapons, and exotic weapons in the (much bigger) black market |
| 🩹 **Vanilla bug fixes** | Combat freeze on mid-ability weapon switch, stuck targeting arrows, the silently-dying election mission chain, vanishing mission NPCs, hidden 7-day "resurrection" hospital stays, and more |

---

## Quick Start

1. Download `EoS_MegaMod.zip` from the [latest release](../../releases/latest).
2. Copy it — **do not unzip it** — into your unmanaged mods folder:

```
C:\Users\<you>\AppData\LocalLow\
└── Paradox Interactive\
    └── Empire of Sin\
        └── Mods\
            └── Unmanaged\
                └── EoS_MegaMod.zip   ← the whole zip goes here
```

3. Open the **Paradox Launcher**, go to your Empire of Sin playset, and enable **Empire of Sin - Mega Mod**.
4. Play. New campaigns get everything from day 1; existing saves pick up the characters, events, and fixes as their triggers come due.

> ⚠️ **Heads up:** the game reads the *zip*, not a loose folder. If you extracted it, re-zip or just re-download.

---

## The Safehouse Crew

Eight new characters take up residence in your safehouses (Mad Sam and Mr. Smith work from your **primary** safehouse only):

| Character | Who they are | What they offer |
|---|---|---|
| **The Cleaner** | Evodio "Smokes" Zinna | Underworld contracts with real payouts |
| **Top Jimmy** | "Top Jimmy" Malone | Gangster recruiting without the barroom crawl |
| **The Architect** | Chloe "Big Brains" Shapleigh | Racket renovations and upgrades |
| **The Fence** | "Slippery" Pete Kowalski | Moves hot merchandise, cooldown-based deals |
| **The Lawyer** | Vincent "The Brief" Moretti | Legal trouble made to disappear (judges have a price) |
| **ICA Contact** | Mr. Smith | Contract work for a very discreet agency |
| **The Vet** | Doc Stitches | Heals injuries — including pulling "resurrected" gangsters out of their hidden hospital stay early |
| **Juice Man** | "Mad Sam" DeStefano | $10k/$15k/$25k loans at 20% monthly vig. Miss payments and your rackets pay the price. There *is* a way to settle it permanently… |

---

## Difficulty Profiles

On day 1 you choose how Chicago treats you (once per campaign, optional — dismissing it plays untuned):

| Profile | Costs | Payouts | Police Heat | Event Rate | Fed Heat |
|---|---|---|---|---|---|
| 🥂 **Speakeasy Stroll** | 0.75× | 1.25× | 0.75× | 0.80× | 0.75× |
| 🏙️ **Business as Usual** | 1.00× | 1.00× | 1.00× | 1.00× | 1.00× |
| 🔥 **The Full Capone** | 1.35× | 0.80× | 1.40× | 1.25× | 1.50× |

Your vanilla world difficulty blends on top: Hard/Boss worlds run heat 15% hotter, easier worlds 15% cooler.

---

## Vanilla Bug Fixes Included

These fix bugs in the *base game* that you may have hit even without mods:

- **Combat freeze** when a unit switches weapons mid-ability (e.g., sniper to pistol) — no more permanently stuck turns.
- **Stuck targeting arrows** left floating in the world after certain abilities (Swindler's Shot).
- **Election missions never appearing / silently failing** — a vanilla callback bug could permanently kill the Chicago-politics mission chain after your casino/bar donation. The mod keeps the chain alive *and* revives it in saves where it already died.
- **Mission NPCs vanishing** when the neighborhood around them changes hands (Gift and the Grain's Charly gets re-placed instead of lost).
- **"She wasn't dead!" mystery hospital stays** — revived gangsters get a hidden 7-day injury; the mod surfaces an alert so you know where they went (and Doc Stitches can get them back sooner).
- **Sugar Daddy follower** getting stranded or leaving early after save/load.

---

## Configuration Reference

No config files to edit — everything is in-game:

| Setting | Where | Notes |
|---|---|---|
| Difficulty profile | Day-1 dialog | One-time choice per campaign; save-persisted |
| Loan size | Mad Sam's offer dialog | $10,000 / $15,000 / $25,000 (or decline) |
| Event frequency | Driven by profile choice | Weekly roll, base 35% chance |

For modders: all tuning knobs are world facts (`fact.MegaModCfg*`) documented at the top of `Raw~/Lua/Scripts/MegaMod_Events/MegaModConfig.lua`. Every consumer reads `(fact.X or 1)`, so missing knobs degrade to vanilla-neutral behavior.

---

## Compatibility

| Item | Status |
|---|---|
| Empire of Sin (latest Steam build) | ✅ Built and tested against it |
| Make It Count / The Precinct DLC | ✅ Tested with all DLC installed |
| Existing saves | ✅ Designed to bootstrap into mid-campaign saves; several fixes specifically rescue broken saves |
| Other mods overriding the same Lua files | ⚠️ Last-loaded wins — the 17 merged mods are *included*, so remove their standalone Workshop versions |
| Platforms | Windows (Steam + Paradox Launcher). GOG untested but should work — same launcher |

**Remove the standalone Workshop versions of any merged mod** (see Credits below) from your playset to avoid double-loading.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Mod doesn't appear in launcher | Confirm the zip is in `Paradox Interactive\Empire of Sin\Mods\Unmanaged\` — **not** the legacy `RomeroGames\EmpireOfSin\` folder |
| Mod listed but nothing new in game | Make sure it's enabled in the *active* playset, then fully restart the game |
| Extracted the zip | Re-download; the game loads the zip itself |
| Suspected script error | Check `player.log` in `…\AppData\LocalLow\Paradox Interactive\Empire of Sin\` for `stack traceback:` lines |
| Election missions still absent on an old save | Give it ~2 in-game days after loading; watch for "The Party Hasn't Forgotten You" |

---

## Building from Source

```powershell
git clone https://github.com/Blackhorse311/EoS-MegaMod.git
cd EoS-MegaMod
.\build.ps1            # builds EoS_MegaMod.zip and deploys it to your mods folder
.\build.ps1 -NoDeploy  # build only
```

The build script validates required files, zips `MegaMod\ModDescription.json` + `MegaMod\Raw~\`, and (unless `-NoDeploy`) copies the zip into your unmanaged mods folder.

---

## Security & Compliance

- Pure Lua data/script mod — no DLLs, no executables, no game-binary patches, no network calls.
- Overridden game scripts are modified copies of the Lua source Romero Games ships openly with every install (`GameSource_[Custom].zip`).
- **AI collaboration disclosure:** this mod was developed collaboratively with Claude (Anthropic). All changes were human-directed, play-tested, and reviewed.

---

## Credits

### The 17 Original Workshop Mods

This project began as a compatibility merge of these mods. Full credit to their original authors — if you're one of them and want your work removed or credited differently, open an issue and it will be handled promptly.

| Mod | Workshop link |
|---|---|
| Protection Money | [2585451213](https://steamcommunity.com/sharedfiles/filedetails/?id=2585451213) |
| Alternative Moles | [2682888518](https://steamcommunity.com/sharedfiles/filedetails/?id=2682888518) |
| Gift and The Gain | [2625506179](https://steamcommunity.com/sharedfiles/filedetails/?id=2625506179) |
| Better Brothels | [2625447753](https://steamcommunity.com/sharedfiles/filedetails/?id=2625447753) |
| No Mission Time Limit | [2984345694](https://steamcommunity.com/sharedfiles/filedetails/?id=2984345694) |
| Upgrade Notification | [2668995267](https://steamcommunity.com/sharedfiles/filedetails/?id=2668995267) |
| Demographic Tweaks | [2814013173](https://steamcommunity.com/sharedfiles/filedetails/?id=2814013173) |
| Increased Crew Size | [2897516914](https://steamcommunity.com/sharedfiles/filedetails/?id=2897516914) |
| Better Black Market | [2961137561](https://steamcommunity.com/sharedfiles/filedetails/?id=2961137561) |
| Weapon Affinity Max to 6 | [2984118913](https://steamcommunity.com/sharedfiles/filedetails/?id=2984118913) |
| Neighbourhood Overview | [2671716739](https://steamcommunity.com/sharedfiles/filedetails/?id=2671716739) |
| IsTooIrish_can_enter | [2984118779](https://steamcommunity.com/sharedfiles/filedetails/?id=2984118779) |
| Police Explore More | [2625510368](https://steamcommunity.com/sharedfiles/filedetails/?id=2625510368) |
| Chatty Advisor | [2621325215](https://steamcommunity.com/sharedfiles/filedetails/?id=2621325215) |
| The Gunpowder Shop | [2620093592](https://steamcommunity.com/sharedfiles/filedetails/?id=2620093592) |
| Sugar Daddy | [2625553987](https://steamcommunity.com/sharedfiles/filedetails/?id=2625553987) |
| CustomGuns (Honest Harper's) | Workshop ID 2626836637 *(delisted)* |

Everything beyond the merge — the safehouse crew, world events, Event Director, difficulty profiles, Federal Heat, Mad Sam, weapon packs, and all vanilla bug fixes — is original work by this project.

### Community Contributors

*Your name here — issues and PRs welcome.*

---

## Changelog

### v1.0.0 (2026-07-28)
- Initial public release.
- 17 Workshop mods merged and conflict-resolved.
- 8 custom safehouse characters with save-durable state.
- 30+ new world events, Event Director weekly cadence, 12 historical events.
- Difficulty profiles (Speakeasy Stroll / Business as Usual / The Full Capone) with vanilla-difficulty blend.
- Federal Heat, insurance, Tax Man, shakedowns, and the rest of the sim layer.
- Vanilla bug fixes: combat freeze, leaked targeting arrows, dead election chains (with in-save rescue), vanishing mission NPCs, hidden resurrection hospital stays, Sugar Daddy follow repair.

---

## Support

- 🐛 **Bug reports:** [open an issue](../../issues/new) — include your `player.log` if you can.
- 💡 **Feature requests:** [open an issue](../../issues/new) and tag it as an enhancement.
- 💬 Questions welcome in the issues too — there's no dumb question about a 1920s crime sim's Lua internals.

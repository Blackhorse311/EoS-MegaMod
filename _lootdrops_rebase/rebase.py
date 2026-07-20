"""Rebase MegaMod LootDrops.lua onto current vanilla.

Start from current vanilla text, apply only the mod's intended tweaks from
per_block.json, write result over the mod file. CRLF preserved (operate on
\r\n-split lines, rejoin with \r\n).

Intent classification (see session notes):
- APPLY  all "changed" values EXCEPT the exclusions below.
- APPLY  "added" dropWeight.BLACK_MARKET_STORE = 100 fields (Better Black
         Market adds items to the store), incl. the bare `dropWeight = {}`
         initializer on blocks vanilla ships without any dropWeight table
         (required: Lua would nil-index otherwise).
- APPLY  ARMOR_07 added LOOT_CRATE_UNCOMMON = 5 (amplified; vanilla armor
         crate weights are 0.05-0.1 scale).
- SKIP   MELEE_12 POLICE_STORE 3->2: vanilla bumped 2->3 after the mod's
         base; mod never lowers police weights (drift, not intent).
- SKIP   ARMOR_06/07 added faction COMMON/UNCOMMON/RARE tiers: un-amplified
         old-vanilla values (0.5/0.25, 0.1/0.05, 1/0.5, 5/2.5) over the old
         faction set; current vanilla removed these tiers in the armor
         rework that introduced ARMOR_0x_2 (drift, not intent).
- "removed" fields and vanilla-only blocks: keep vanilla (DLC restorations).
"""
import json
import re
from pathlib import Path

BASE = Path(r"I:\EoS_dev\_lootdrops_rebase")
VAN = Path(r"I:\EoS_dev\GameSource_Vanilla\GameData\Lua\Scripts\DataSheets\LootDrops.lua")
MOD_OUT = Path(r"I:\EoS_dev\MegaMod\Raw~\Lua\Scripts\DataSheets\LootDrops.lua")
# read added-field values from the pristine pre-rebase copy (MOD_OUT gets overwritten)
MOD = BASE / "mod_backup_LootDrops.lua"

# (block_id, field) pairs judged as old-vanilla drift, not mod intent.
SKIP_CHANGED: set[tuple[str, str]] = {("ITEM_WEAPON_MELEE_12", "dropWeight.POLICE_STORE")}


def skip_added(block_id: str, field: str) -> bool:
    """Old-vanilla faction low-tier weights on ARMOR_06/07 (drift)."""
    if block_id not in ("ITEM.ARMOR.ARMOR_06", "ITEM.ARMOR.ARMOR_07"):
        return False
    if field.startswith("dropWeight.LOOT_CRATE_"):
        return False  # ARMOR_07 LOOT_CRATE_UNCOMMON=5 is amplified (mod intent)
    return bool(re.search(r"_(COMMON|UNCOMMON|RARE)$", field))


def parse(path: Path) -> tuple[dict[str, tuple[int, int]], list[str]]:
    """Return {block_id: (start, end)} line spans (banner-inclusive) + lines."""
    lines = path.read_bytes().decode("utf-8").split("\r\n")
    id_idx = [i for i, l in enumerate(lines) if l.startswith("_id = ")]
    starts = []
    for i in id_idx:
        s, j = i, i - 1
        while j >= 0 and (lines[j].strip() == "" or lines[j].startswith("--")):
            s = j
            if lines[j].startswith("--[["):
                break
            j -= 1
        starts.append(s)
    blocks: dict[str, tuple[int, int]] = {}
    for k, i in enumerate(id_idx):
        bid = re.match(r'_id = "(.+)"', lines[i]).group(1)
        blocks[bid] = (starts[k], starts[k + 1] if k + 1 < len(id_idx) else len(lines))
    return blocks, lines


def main() -> None:
    pb = json.loads((BASE / "per_block.json").read_text())
    vblocks, vlines = parse(VAN)
    mblocks, mlines = parse(MOD)

    out = list(vlines)  # edited in place by absolute index; inserts tracked per block
    n_changed = n_added = n_skip_changed = n_skip_added = 0
    # collect edits: {line_index: new_line} and {insert_after_index: [lines]}
    replacements: dict[int, str] = {}
    inserts: dict[int, list[str]] = {}

    for bid, d in pb.items():
        vs, ve = vblocks[bid]
        # --- changed values ---
        for field, (van_val, mod_val) in d["changed"].items():
            if (bid, field) in SKIP_CHANGED:
                n_skip_changed += 1
                continue
            hits = [i for i in range(vs, ve) if vlines[i] == f"{field} = {van_val}"]
            assert len(hits) == 1, f"{bid}/{field}: {len(hits)} matches"
            replacements[hits[0]] = f"{field} = {mod_val}"
            n_changed += 1
        # --- added fields (values from the mod block, mod order preserved) ---
        ms, me = mblocks[bid]
        added = [f for f in d["added"] if not skip_added(bid, f)]
        n_skip_added += len(d["added"]) - len(added)
        if not added:
            continue
        vfields = {}  # field -> vanilla line index
        for i in range(vs, ve):
            m = re.match(r"([A-Za-z_][\w.]*) = ", vlines[i])
            if m:
                vfields[m.group(1)] = i
        # walk mod block in order; anchor each added line after the previous
        # field that exists in vanilla (or after a just-inserted line).
        anchor = None  # vanilla line index to insert after
        pending: dict[str, int] = {}  # added field -> anchor used
        for i in range(ms, me):
            m = re.match(r"([A-Za-z_][\w.]*) = ", mlines[i])
            if not m:
                continue
            f = m.group(1)
            if f in added:
                assert anchor is not None, f"{bid}/{f}: no anchor"
                inserts.setdefault(anchor, []).append(mlines[i])
                pending[f] = anchor
                n_added += 1
            elif f in vfields:
                anchor = vfields[f]
        missing = set(added) - set(pending)
        assert not missing, f"{bid}: added fields not found in mod block: {missing}"

    # materialize: rebuild lines with replacements + inserts
    result: list[str] = []
    for i, line in enumerate(vlines):
        result.append(replacements.get(i, line))
        result.extend(inserts.get(i, []))

    MOD_OUT.write_bytes("\r\n".join(result).encode("utf-8"))

    print(f"changed values applied : {n_changed}")
    print(f"added lines inserted   : {n_added}")
    print(f"skipped changed (drift): {n_skip_changed}")
    print(f"skipped added (drift)  : {n_skip_added}")
    print(f"vanilla blocks: {len(vblocks)}  -> result blocks: "
          f"{sum(1 for l in result if l.startswith('_id = '))}")


if __name__ == "__main__":
    main()

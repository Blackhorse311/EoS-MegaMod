import re, json, collections

MOD = r"I:\EoS_dev\MegaMod\Raw~\Lua\Scripts\DataSheets\LootDrops.lua"
VAN = r"I:\EoS_dev\GameSource_Vanilla\GameData\Lua\Scripts\DataSheets\LootDrops.lua"

def parse(path):
    raw = open(path, 'rb').read().decode('utf-8')
    lines = raw.split('\r\n')
    # find _id line indices
    id_idx = [i for i, l in enumerate(lines) if l.startswith('_id = ')]
    # block start = beginning of banner preceding the _id (walk back over blank lines and comment banner)
    starts = []
    for i in id_idx:
        s = i
        j = i - 1
        # walk back over blank lines and banner comment lines
        while j >= 0:
            l = lines[j]
            if l.strip() == '' or l.startswith('--'):
                # stop if we hit the banner opening; include it, then also a preceding blank
                s = j
                if l.startswith('--[[') :
                    # include one preceding blank line if present? No - keep banner start as block start
                    break
                j -= 1
            else:
                break
        starts.append(s)
    blocks = collections.OrderedDict()
    order = []
    for k, i in enumerate(id_idx):
        m = re.match(r'_id = "(.+)"', lines[i])
        bid = m.group(1)
        start = starts[k]
        end = starts[k+1] if k+1 < len(id_idx) else len(lines)
        blocks[bid] = (start, end, lines[start:end])
        order.append(bid)
    header = lines[:starts[0]]
    return header, blocks, order, lines

mh, mb, morder, _ = parse(MOD)
vh, vb, vorder, _ = parse(VAN)

print("mod blocks:", len(mb), "vanilla blocks:", len(vb))
print("header identical:", mh == vh)

mset, vset = set(mb), set(vb)
mod_only = [b for b in morder if b not in vset]
van_only = [b for b in vorder if b not in mset]
print("mod-only blocks:", len(mod_only), mod_only[:10])
print("vanilla-only blocks:", len(van_only))
print(json.dumps(van_only, indent=0)[:2000])

def fields(blines):
    d = collections.OrderedDict()
    for l in blines:
        m = re.match(r'([A-Za-z_][\w.\[\]"\']*) = (.*)$', l)
        if m and not l.startswith('_id'):
            d[m.group(1)] = m.group(2)
    return d

differing = []
for bid in morder:
    if bid in vb:
        if mb[bid][2] != vb[bid][2]:
            differing.append(bid)
print("\nblocks differing (mod vs current vanilla):", len(differing))

# classify each differing block: field-level diff
change_summary = collections.Counter()
per_block = {}
struct_diff = []  # blocks where line structure differs beyond values
for bid in differing:
    mf, vf = fields(mb[bid][2]), fields(vb[bid][2])
    mkeys, vkeys = set(mf), set(vf)
    added = mkeys - vkeys   # fields only in mod
    removed = vkeys - mkeys # fields only in vanilla
    changed = {k: (vf[k], mf[k]) for k in (mkeys & vkeys) if mf[k] != vf[k]}
    per_block[bid] = dict(added=sorted(added), removed=sorted(removed), changed=changed)
    if added or removed:
        struct_diff.append(bid)
    for k, (vv, mv) in changed.items():
        # normalize field name (strip faction prefixes)
        change_summary[k] += 1

print("blocks with added/removed fields (structural):", len(struct_diff), struct_diff[:10])

# changed-field histogram
print("\ntop changed fields:")
for k, c in change_summary.most_common(40):
    print(f"  {c:4d}  {k}")

# sample diffs from 5 blocks
import itertools
print("\n=== SAMPLE DIFFS ===")
for bid in differing[:5]:
    pb = per_block[bid]
    print(f"\n--- {bid} ---")
    for k, (vv, mv) in itertools.islice(pb['changed'].items(), 12):
        print(f"  {k}: vanilla={vv}  mod={mv}")
    if pb['added']: print("  ADDED:", pb['added'][:10])
    if pb['removed']: print("  REMOVED:", pb['removed'][:10])
    print(f"  (total changed fields: {len(pb['changed'])})")

json.dump({bid: {'added': pb['added'], 'removed': pb['removed'],
                 'changed': {k: list(v) for k, v in pb['changed'].items()}}
           for bid, pb in per_block.items()},
          open(r"I:\EoS_dev\_lootdrops_rebase\per_block.json", 'w'), indent=1)
print("\nwrote per_block.json")

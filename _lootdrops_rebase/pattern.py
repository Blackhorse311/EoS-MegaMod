import json, collections

pb = json.load(open(r"I:\EoS_dev\_lootdrops_rebase\per_block.json"))

added_any = {b: d['added'] for b, d in pb.items() if d['added']}
print("blocks with ADDED fields (in mod, not in vanilla):", len(added_any))
for b, a in list(added_any.items())[:10]:
    print(" ", b, a)

# all removed-field names across blocks (should be vanilla-newer additions)
rem = collections.Counter()
for d in pb.values():
    for f in d['removed']:
        rem[f] += 1
print("\nremoved-field name histogram (top 25):")
for f, c in rem.most_common(25):
    print(f"  {c:4d} {f}")

# changed value pairs
pairs = collections.defaultdict(collections.Counter)
blocks_with_changes = []
for b, d in pb.items():
    if d['changed']:
        blocks_with_changes.append(b)
    for f, (vv, mv) in d['changed'].items():
        key = f
        if f.startswith('dropWeight.') and f not in ('dropWeight.BLACK_MARKET_STORE','dropWeight.POLICE_STORE','dropWeight.LOOT_CRATE_RARE','dropWeight.LOOT_CRATE_UNCOMMON'):
            key = 'dropWeight.<FACTION_VENUE_TIER>'
        pairs[key][(vv, mv)] += 1

print("\nblocks with CHANGED values:", len(blocks_with_changes))
total_changed = sum(len(d['changed']) for d in pb.values())
print("total changed field instances:", total_changed)

for key, cnt in pairs.items():
    print(f"\n{key}:")
    for (vv, mv), c in cnt.most_common(30):
        print(f"  {c:4d}x  vanilla={vv} -> mod={mv}")

# which blocks have BLACK_MARKET_STORE / POLICE_STORE changes - list names sample
bm = [b for b, d in pb.items() if 'dropWeight.BLACK_MARKET_STORE' in d['changed']]
ps = [b for b, d in pb.items() if 'dropWeight.POLICE_STORE' in d['changed']]
print("\nBLACK_MARKET_STORE changed blocks:", len(bm), "sample:", bm[:8], "...", bm[-4:])
print("POLICE_STORE changed blocks:", len(ps), "sample:", ps[:8], "...", ps[-4:])

# blocks with misc faction/venue tier changes
misc = [b for b, d in pb.items() if any(f not in ('dropWeight.BLACK_MARKET_STORE','dropWeight.POLICE_STORE') for f in d['changed'])]
print("\nblocks with other changed fields:", len(misc))
for b in misc:
    d = pb[b]['changed']
    others = {f: v for f, v in d.items() if f not in ('dropWeight.BLACK_MARKET_STORE','dropWeight.POLICE_STORE')}
    print(f"  {b}: {len(others)} fields, sample: {list(others.items())[:3]}")

import json, re, glob, sys

LOC = 'MegaMod/Raw~/Localization/EoS_MegaMod_en.json'
loc = json.load(open(LOC, encoding='utf-8'))

extracted = {}   # key -> text (first resolution wins)
referenced = set()

key_re = re.compile(r'"(\$MEGAMOD_[A-Za-z0-9_]+)"')

for path in sorted(glob.glob('MegaMod/Raw~/Lua/Scripts/**/*.lua', recursive=True)):
    for line in open(path, encoding='utf-8'):
        keys = key_re.findall(line)
        if not keys:
            continue
        referenced.update(keys)
        if '--$' not in line:
            continue
        comment = line.split('--$', 1)[1].strip()
        if not comment:
            continue
        if len(keys) == 1:
            extracted.setdefault(keys[0], comment)
        elif len(keys) == 2 and ' / ' in comment:
            title, body = comment.split(' / ', 1)
            extracted.setdefault(keys[0], title.strip())
            extracted.setdefault(keys[1], body.strip())
        else:
            print(f'UNPARSED ({path.split("/")[-1]}): {keys} :: {comment[:60]}')

# Prepped Insurance block overrides comment-extracted text
ins = json.load(open('_scratch/loc_insurance.json', encoding='utf-8'))
for k, v in ins.items():
    extracted[k.lstrip()] = v  # keys carry the $ already
    referenced.add(k)

added, unresolved = [], []
for k in sorted(referenced):
    if k in loc:
        continue
    if k in extracted:
        loc[k] = extracted[k]
        added.append(k)
    else:
        unresolved.append(k)

with open(LOC, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(loc, f, indent=2, ensure_ascii=False)
    f.write('\n')

print(f'added {len(added)} keys, total now {len(loc)}')
if unresolved:
    print('UNRESOLVED (need hand-authoring):')
    for k in unresolved:
        print(' ', k)

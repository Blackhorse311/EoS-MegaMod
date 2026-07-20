import json, re, glob

loc = json.load(open('MegaMod/Raw~/Localization/EoS_MegaMod_en.json', encoding='utf-8'))
key_re = re.compile(r'"(\$[A-Za-z0-9_]+)"')
missing = {}
for path in glob.glob('MegaMod/Raw~/Lua/Scripts/**/*.lua', recursive=True):
    for line in open(path, encoding='utf-8'):
        for k in key_re.findall(line):
            if k not in loc:
                missing.setdefault(k, path)

# keys that vanilla itself defines are fine; filter against vanilla loc if present
van_keys = set()
for vp in glob.glob('GameSource_Vanilla/**/*_en.json', recursive=True):
    try:
        van_keys.update(json.load(open(vp, encoding='utf-8-sig')).keys())
    except Exception:
        pass

true_missing = {k: p for k, p in missing.items() if k not in van_keys}
print('referenced-but-missing (not in mod loc or vanilla loc):', len(true_missing))
for k, p in sorted(true_missing.items()):
    print(' ', k, '<-', p.replace('\\', '/').split('/')[-1])

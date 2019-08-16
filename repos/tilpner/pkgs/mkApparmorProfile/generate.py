import json
from pathlib import Path

with open(".attrs.json") as f:
    attrs = json.load(f)

closure = attrs['closure']
profileArgs = attrs['profileArgs']

subject = profileArgs['subject']
enforce = profileArgs['enforce']
bin_dir = Path(subject) / 'bin'
if not bin_dir.is_dir():
    exit(1)

executables = sorted([e.resolve(strict=True) for e in bin_dir.iterdir()])

with open(attrs['outputs']['out'], "w") as out:
    out.write('include <tunables/global>\n\n')

    # /{nix/store/*-foo/bin/foo,nix/store/*-bar/bin/bar}
    glob = ','.join([p.as_posix().lstrip('/') for p in executables])
    out.write(f"profile {profileArgs['name']} /{{{glob}}}")
    out.write('' if enforce else ' flags=(complain)')
    out.write(" {\n")

    out.write(profileArgs['prepend'])
    for item in closure:
        out.write(f"  {item['path']}** mkrix,\n")
    out.write(profileArgs['append'])
    out.write('}\n')

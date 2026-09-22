#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

# The package tracks the tip of the upstream `main` branch instead of its
# releases/tags, while the user-facing version is taken from README.md
# (`当前版本：**X.Y.Z**`), so neither nix-update-script nor unstableGitUpdater
# can maintain it. Version, revision and hash are rewritten directly here and
# the fetched source is verified by building it.
FILE="$(dirname "$(readlink -f "$0")")/default.nix"
ATTR="${UPDATE_NIX_ATTR_PATH:-uncategorized.witch-weapon}"

python3 - "$FILE" <<'PYEOF'
import json
import re
import subprocess
import sys

REPO = "YANG301/Witch-Weapon-Godot-"
path = sys.argv[1]
content = open(path).read()

feed = subprocess.run(
    ['curl', '-fsSL', f'https://github.com/{REPO}/commits/main.atom'],
    capture_output=True, text=True, check=True).stdout
entry = re.search(r'<entry>.*?</entry>', feed, re.S).group(0)
new_rev = re.search(r'<id>[^<]*?([0-9a-f]{40})</id>', entry).group(1)
new_date = re.search(r'<updated>([0-9-]+)T', entry).group(1)

readme = subprocess.run(
    ['curl', '-fsSL', f'https://raw.githubusercontent.com/{REPO}/{new_rev}/README.md'],
    capture_output=True, text=True, check=True).stdout
new_base = re.search(r'当前版本[：:]\s*\*{0,2}([0-9][^*\s]*)\*{0,2}', readme).group(1)
new_version = f'{new_base}-unstable-{new_date}'

old_rev = re.search(r'rev = "([0-9a-f]{40})"', content).group(1)
old_version = re.search(r'version = "([^"]+)"', content).group(1)

if old_rev == new_rev:
    print(f'witch-weapon already at {new_rev}')
    sys.exit(0)

prefetch = subprocess.run(
    ['nix', 'store', 'prefetch-file', '--json', '--unpack',
     f'https://github.com/{REPO}/archive/{new_rev}.tar.gz'],
    capture_output=True, text=True, check=True)
new_hash = json.loads(prefetch.stdout)['hash']

content = re.sub(r'version = "[^"]+"', f'version = "{new_version}"', content, count=1)
content = re.sub(r'rev = "[0-9a-f]{40}"', f'rev = "{new_rev}"', content, count=1)
content = re.sub(r'hash = "sha256-[^"]+"', f'hash = "{new_hash}"', content, count=1)
open(path, 'w').write(content)
print(f'witch-weapon: {old_version} -> {new_version}')
PYEOF

nix build --no-link ".#$ATTR.src"

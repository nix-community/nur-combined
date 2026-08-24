#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

DIR="$(dirname "$(readlink -f "$0")")"

NEW_VERSION=$(curl -fsSL 'https://db-ip.com/db/download/ip-to-country-lite' |
  grep -oP 'dbip-country-lite-\K[0-9]{4}-[0-9]{2}' | head -n1 || true)
[ -n "$NEW_VERSION" ] || {
  echo "Failed to detect new version"
  exit 1
}
echo "detected version: $NEW_VERSION"

python3 - "$DIR/sources.json" "$NEW_VERSION" <<'PYEOF'
import json
import subprocess
import sys

path, new_ver = sys.argv[1:]
sources = json.load(open(path))

for name, e in sorted(sources.items()):
    if e['version'] == new_ver:
        print(f"{name}: already at {new_ver}")
        continue
    new_url = e['url'].replace(e['version'], new_ver)
    h = subprocess.run(['nix', 'store', 'prefetch-file', '--json', new_url],
                       capture_output=True, text=True, check=True)
    e['version'] = new_ver
    e['url'] = new_url
    e['hash'] = json.loads(h.stdout)['hash']
    print(f"{name} updated to {new_ver}")

with open(path, 'w') as f:
    json.dump(sources, f, indent=2, sort_keys=True)
    f.write('\n')
PYEOF

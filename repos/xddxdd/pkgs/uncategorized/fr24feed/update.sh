#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

DIR="$(dirname "$(readlink -f "$0")")"

detect() {
  # $1 = arch-specific Packages index URL
  curl -fsSL "$1" |
    grep -oP 'fr24feed_\K[0-9.-]+(?=_'"$2"')' |
    sort -V | tail -n1 || true
}

V_AMD64=$(detect 'https://repo-feed.flightradar24.com/dists/flightradar24/linux-stable/binary-amd64/Packages' 'amd64\.deb')
V_ARM64=$(detect 'https://repo-feed.flightradar24.com/dists/flightradar24/raspberrypi-stable/binary-arm64/Packages' 'arm64\.deb')
[ -n "$V_AMD64" ] || {
  echo "Failed to detect amd64 version"
  exit 1
}
[ -n "$V_ARM64" ] || V_ARM64="$V_AMD64"
echo "detected versions: amd64=$V_AMD64 arm64=$V_ARM64"

python3 - "$DIR/sources.json" "$V_AMD64" "$V_ARM64" <<'PYEOF'
import json
import subprocess
import sys

path, v_amd64, v_arm64 = sys.argv[1:]
sources = json.load(open(path))

for name, e in sources.items():
    new_ver = v_arm64 if 'arm64' in name or 'armhf' in name else v_amd64
    if e['version'] == new_ver:
        print(f"{name}: already at {new_ver}")
        continue
    new_url = e['url'].replace(e['version'], new_ver)
    h = subprocess.run(['nix', 'store', 'prefetch-file', '--json', new_url],
                       capture_output=True, text=True, check=True)
    e['version'] = new_ver
    e['url'] = new_url
    e['hash'] = json.loads(h.stdout)['hash']
    print(f"{name}: {e['version']} -> {new_ver}" if False else f"{name} updated to {new_ver}")

with open(path, 'w') as f:
    json.dump(sources, f, indent=2, sort_keys=True)
    f.write('\n')
PYEOF

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

DIR="$(dirname "$(readlink -f "$0")")"

PAGE=$(curl -fsSL 'https://im.qq.com/rainbow/linuxQQDownload/')
AMD64=$(grep -oP '"https://dldir1v6\.qq\.com/qqfile/qq/QQNT/Linux/\K[^"]+(?=")' <<<"$PAGE" |
  grep '_amd64' | head -n1 || true)
ARM64=$(grep -oP '"https://dldir1v6\.qq\.com/qqfile/qq/QQNT/Linux/\K[^"]+(?=")' <<<"$PAGE" |
  grep -E '_aarch64|_arm64' | head -n1 || true)
[ -n "$AMD64" ] && [ -n "$ARM64" ] || {
  echo "Failed to detect versions"
  exit 1
}
echo "detected versions: amd64=$AMD64 arm64=$ARM64"

python3 - "$DIR/sources.json" "$AMD64" "$ARM64" <<'PYEOF'
import json
import subprocess
import sys

path, amd64, arm64 = sys.argv[1:]
sources = json.load(open(path))

strip_deb = lambda v: v[:-4] if v.endswith('.deb') else v
new_ver = {'qq-amd64': strip_deb(amd64), 'qq-arm64': strip_deb(arm64)}
for name, e in sources.items():
    nv = new_ver[name]
    if e['version'] == nv:
        print(f"{name}: already at {nv}")
        continue
    new_url = e['url'].replace(e['version'], nv)
    h = subprocess.run(['nix', 'store', 'prefetch-file', '--json', new_url],
                       capture_output=True, text=True)
    if h.returncode != 0:
        print(f"{name}: {nv} not downloadable, keeping {e['version']}")
        continue
    e['version'] = nv
    e['url'] = new_url
    e['hash'] = json.loads(h.stdout)['hash']
    print(f"{name} updated to {nv}")

with open(path, 'w') as f:
    json.dump(sources, f, indent=2, sort_keys=True)
    f.write('\n')
PYEOF

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

FILE="$(dirname "$(readlink -f "$0")")/default.nix"

TABLE=(
  "librime-charcode|rime/librime-charcode"
  "librime-proto|lotem/librime-proto"
)

for ROW in "${TABLE[@]}"; do
  MARKER="${ROW%%|*}"
  REPO="${ROW##*|}"
  NEW_REV=$(curl -fsSL "https://github.com/$REPO/commits.atom" |
    grep -oP '<id>[^<]*/\K[0-9a-f]{40}' | head -n1 || true)
  [ -n "$NEW_REV" ] || {
    echo "WARN: failed to detect revision for $REPO" >&2
    continue
  }

  python3 - "$FILE" "$MARKER" "$REPO" "$NEW_REV" <<'PYEOF'
import json
import re
import subprocess
import sys

path, marker, repo, new_rev = sys.argv[1:]
content = open(path).read()
m = re.search(
    re.escape(marker) + r'.*?rev = "([0-9a-f]{40})".*?hash = "sha256-[^"]+"',
    content,
    re.S,
)
if not m:
    print(f"WARN: pin not found for {marker}")
    sys.exit(0)
old_rev = m.group(1)
if old_rev == new_rev:
    print(f"{marker} already at {new_rev}")
    sys.exit(0)
url = f"https://github.com/{repo}/archive/{new_rev}.tar.gz"
pr = subprocess.run(['nix', 'store', 'prefetch-file', '--json', '--unpack', url],
                    capture_output=True, text=True)
if pr.returncode != 0:
    print(f"WARN: failed to prefetch {repo} @ {new_rev}")
    sys.exit(0)
h = json.loads(pr.stdout)['hash']
seg = m.group(0).replace(old_rev, new_rev)
seg = re.sub(r'hash = "sha256-[^"]+"', 'hash = "' + h + '"', seg)
open(path, 'w').write(content.replace(m.group(0), seg))
print(f"{marker}: {old_rev[:12]} -> {new_rev[:12]}")
PYEOF
done

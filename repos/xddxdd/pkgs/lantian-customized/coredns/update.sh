#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

FILE="$(dirname "$(readlink -f "$0")")/default.nix"

TABLE=(
  "serverwentdown/alias@|serverwentdown/alias"
  "zhoreeq/coredns-meshname@|zhoreeq/coredns-meshname"
  "zhoreeq/coredns-meship@|zhoreeq/coredns-meship"
)

for ROW in "${TABLE[@]}"; do
  MARKER="${ROW%%|*}"
  REPO="${ROW##*|}"
  NEW_VER=$(curl -fsSL "https://api.github.com/repos/$REPO/tags?per_page=10" |
    jq -r '.[].name' | sort -V | tail -n1 || true)
  [ -n "$NEW_VER" ] || NEW_VER=$(curl -fsSL "https://github.com/$REPO/commits.atom" |
    grep -oP '<id>[^<]*/\K[0-9a-f]{40}' | head -n1 || true)
  [ -n "$NEW_VER" ] || {
    echo "WARN: failed to detect version for $MARKER" >&2
    continue
  }

  python3 - "$FILE" "$MARKER" "$NEW_VER" <<'PYEOF'
import sys

path, marker, new_ver = sys.argv[1:]
content = open(path).read()
needle = marker + '"'
idx = content.find(needle)
if idx < 0:
    print(f"WARN: pin not found for {marker}")
    sys.exit(0)
tail = content[idx + len(needle):]
old = tail[:tail.index('"')]
if old == new_ver:
    print(f"{marker} already at {old}")
    sys.exit(0)
content = content[:idx + len(needle)] + new_ver + tail[len(old):]
open(path, 'w').write(content)
print(f"{marker}: {old} -> {new_ver}")
PYEOF
done

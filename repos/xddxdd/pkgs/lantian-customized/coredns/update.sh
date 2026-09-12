#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p gnused -p nix -p python3
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
  NEW_VER=$(curl -fsSL "https://github.com/$REPO/tags.atom" |
    grep -oP '<id>tag:github\.com,2008:Repository/[0-9]+/\K[^<]+' |
    sort -V | tail -n1 || true)
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
idx = content.find(marker)
if idx < 0:
    print(f"WARN: pin not found for {marker}")
    sys.exit(0)
# pins are written as Nix interpolation: alias@${"1.0.6"}
prefix = '${"'
tail = content[idx + len(marker):]
if not tail.startswith(prefix):
    print(f"WARN: unexpected pin format for {marker}")
    sys.exit(0)
body = tail[len(prefix):]
end = body.index('\"}')
old = body[:end]
if old == new_ver:
    print(f"{marker} already at {old}")
    sys.exit(0)
content = content[:idx + len(marker) + len(prefix)] + new_ver + body[end:]
open(path, 'w').write(content)
print(f"{marker}: {old} -> {new_ver}")
PYEOF
done

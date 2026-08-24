#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p nix-update
# shellcheck shell=bash
set -euo pipefail

# Main qsp source tracks qspgui master (branch convention)
nix-update "$UPDATE_NIX_ATTR_PATH" --version branch

# qsp-wx pins a wxWidgets commit referenced from QSPFoundation/qspgui master
NEW_REV=$(curl -fsSL 'https://github.com/QSPFoundation/qspgui/raw/refs/heads/master/CMakeLists.txt' |
  grep -oP 'GIT_TAG\s+\K[0-9a-f]{40}')
[ -n "$NEW_REV" ] || {
  echo "Failed to detect new revision"
  exit 1
}

FILE="$(dirname "$(readlink -f "$0")")/default.nix"
OLD_REV=$(grep -A8 '"qsp-wx"' "$FILE" | grep -oP 'rev = "\K[0-9a-f]{40}' | head -n1 || true)
if [ "$NEW_REV" = "$OLD_REV" ]; then
  echo "qsp-wx already at $NEW_REV"
  exit 0
fi

URL="https://github.com/wxWidgets/wxWidgets/archive/$NEW_REV.tar.gz"
NEW_HASH=$(nix store prefetch-file --json "$URL" | jq -r .hash)

python3 - "$FILE" "$OLD_REV" "$NEW_REV" "$NEW_HASH" <<'PYEOF'
import re
import sys

path, old_rev, new_rev, new_hash = sys.argv[1:]
content = open(path).read()
m = re.search(r'"qsp-wx"[^}]*?rev = "[0-9a-f]{40}".*?hash = "sha256-[^"]+"', content, re.S)
seg = m.group(0).replace(old_rev, new_rev)
seg = re.sub(r'hash = "sha256-[^"]+"', f'hash = "{new_hash}"', seg)
content = content.replace(m.group(0), seg)
open(path, 'w').write(content)
PYEOF
echo "qsp-wx updated to $NEW_REV"

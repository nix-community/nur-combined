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

# qsp-wx fetches wxWidgets with fetchSubmodules, so the hash must be computed
# with the package's own fetcher (tarball prefetch would miss submodules):
# build the FOD with a dummy hash and parse the "got:" line
REPO_ROOT="$(git rev-parse --show-toplevel)"
NEW_HASH=$(nix build --no-link --impure --expr "
  (builtins.getFlake \"$REPO_ROOT\").inputs.nixpkgs.legacyPackages.x86_64-linux.fetchFromGitHub {
    owner = \"wxWidgets\";
    repo = \"wxWidgets\";
    rev = \"$NEW_REV\";
    fetchSubmodules = true;
    hash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\";
  }" 2>&1 | sed -n 's/.*got: *\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' | head -n1)
[ -n "$NEW_HASH" ] || {
  echo "Failed to prefetch qsp-wx $NEW_REV"
  exit 1
}

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

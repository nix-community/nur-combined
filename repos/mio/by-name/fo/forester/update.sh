#!/usr/bin/env bash
#! nix-shell -i bash -p git nix python3 nixfmt-rfc-style
# shellcheck shell=bash

# forester tracks a git branch, so nix-update cannot derive the version: the
# upstream commit date sets the -unstable- suffix and the fetchgit hash covers
# the tree (not a release tarball). Optional argument: a commit to pin.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
url=https://knot.cl.cam.ac.uk/jonmsterling.com/ocaml-forester
pkg=by-name/fo/forester/package.nix

rev=${1:-$(git ls-remote "$url" HEAD | cut -f1)}
if [ -z "$rev" ]; then
    echo "update.sh: cannot resolve $url HEAD" >&2
    exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
git -C "$tmp" fetch -q --depth=1 "$url" "$rev"
date=$(git -C "$tmp" log -1 --format=%cs FETCH_HEAD)

tree=$(nix eval --impure --raw --expr \
    "builtins.fetchTree { type = \"git\"; url = \"$url\"; rev = \"$rev\"; }")
hash=$(nix hash path "$tree")

python3 - "$pkg" "$rev" "$date" "$hash" <<'PY'
import re
import sys
from pathlib import Path

package, rev, date, tree_hash = sys.argv[1:]
path = Path(package)
text = path.read_text(encoding="utf-8")

base = re.search(r'version = "([0-9.]+)-unstable-\d{4}-\d{2}-\d{2}";', text)
if base is None:
    raise SystemExit(f"update.sh: no -unstable- version in {package}")

text = text.replace(base.group(0), f'version = "{base.group(1)}-unstable-{date}";', 1)
text, n = re.subn(r'commit = "[0-9a-f]+";', f'commit = "{rev}";', text, count=1)
if n != 1:
    raise SystemExit(f"update.sh: no commit pin in {package}")

text, n = re.subn(
    r'(src = fetchgit \{\n(?:.*\n)*?\s+hash = ")[^"]+(";)',
    lambda match: match.group(1) + tree_hash + match.group(2),
    text,
    count=1,
)
if n != 1:
    raise SystemExit(f"update.sh: no fetchgit hash in {package}")

path.write_text(text, encoding="utf-8")
print(f"update.sh: forester {base.group(1)}-unstable-{date} ({rev[:7]})")
PY

nixfmt "$pkg"

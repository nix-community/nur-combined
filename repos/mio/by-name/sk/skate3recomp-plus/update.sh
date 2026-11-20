#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update nixfmt-rfc-style python3
# shellcheck shell=bash

# Bumps Skate 3 Recompiled+.
#
# The SDK commit needs no editing: sdk.nix reads it from
# tools/apply_sdk_patches.py in the released source. Its fixed-output hash
# still has to be recomputed after a bump, because the tree it covers (the
# fork at that commit, with the release's patch applied) changes with it.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/sk/skate3recomp-plus

# The tags are v0.2, v0.2a ... v0.2e, which nix-update's version comparison
# cannot order (it reads 0.2e as older than 0.2). Take the newest release
# from GitHub's feed, which is ordered by release date, and pin that.
version=$(python3 - <<'PY'
import re, urllib.request

url = "https://github.com/dougieprishpreed/skate3recomp-plus/releases.atom"
data = urllib.request.urlopen(url, timeout=60).read().decode()
entry = data.split("<entry>", 1)[1]
print(re.search(r"<title>\s*v?([^<]+?)\s*</title>", entry).group(1))
PY
)

nix-update skate3recomp-plus --version="$version"

system=$(nix eval --raw --impure --expr builtins.currentSystem)
sdk=".#legacyPackages.$system.skate3recomp-plus.passthru.sdk"

log=$(mktemp)
trap 'rm -f "$log"' EXIT

if nix build "$sdk" --no-link -L >"$log" 2>&1; then
    echo "update.sh: the SDK pin still matches"
    exit 0
fi

got=$(grep -oE 'got: +sha256-[A-Za-z0-9+/=]+' "$log" | tail -1 | awk '{print $2}')
if [ -z "$got" ]; then
    echo "update.sh: the SDK build failed for a reason other than its hash:" >&2
    tail -20 "$log" >&2
    exit 1
fi

HASH=$got python3 - "$dir/sdk.nix" <<'PY'
import os, pathlib, re, sys

path = pathlib.Path(sys.argv[1])
path.write_text(
    re.sub(r'outputHash = "[^"]*";', f'outputHash = "{os.environ["HASH"]}";', path.read_text())
)
PY
nixfmt "$dir/sdk.nix"
echo "update.sh: SDK hash -> $got"

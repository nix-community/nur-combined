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

# sdk.nix dates its version by the commit the release names, so refresh that
# date along with the pin. The lookup needs GitHub, which the release check
# above already relies on; if it fails, keep the old date and say so.
SRC=$(nix eval --raw ".#legacyPackages.$system.skate3recomp-plus.src") \
SDK_NIX="$dir/sdk.nix" python3 - <<'PY' || echo "update.sh: could not refresh the SDK version date; left as is" >&2
import json, os, pathlib, re, sys, urllib.request

script = pathlib.Path(os.environ["SRC"], "tools/apply_sdk_patches.py").read_text()
rev = re.search(r"SDK_REVISION = '([0-9a-f]+)'", script).group(1)
url = f"https://api.github.com/repos/mchughalex/rexglue-skate3/commits/{rev}"
with urllib.request.urlopen(url, timeout=60) as response:
    date = json.load(response)["commit"]["committer"]["date"][:10]

path = pathlib.Path(os.environ["SDK_NIX"])
path.write_text(
    re.sub(r'version = "0-unstable-[0-9-]+";', f'version = "0-unstable-{date}";', path.read_text())
)
print(f"update.sh: SDK version -> 0-unstable-{date} ({rev})")
PY
nixfmt "$dir/sdk.nix"

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

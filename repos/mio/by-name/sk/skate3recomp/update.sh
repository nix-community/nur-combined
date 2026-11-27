#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update nixfmt python3
# shellcheck shell=bash

# Bumps Skate 3 Recomp.
#
# The source tag also determines the SDK submodule pin and its date; refresh
# those with the release, then recompute the SDK fixed-output hash. The
# SDK-level thread-race fix is an independent upstream patch pin: pass
# THREAD_SUSPEND_RACE_REV=<commit> to move it, otherwise its URL and fetched
# patch hash are kept pinned and synchronized.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/sk/skate3recomp

version=$(python3 - <<'PY'
import re, urllib.request

url = "https://github.com/mchughalex/skate3recomp/releases.atom"
data = urllib.request.urlopen(url, timeout=60).read().decode()
entry = data.split("<entry>", 1)[1]
print(re.search(r"<title>\s*v?([^<]+?)\s*</title>", entry).group(1))
PY
)

nix-update skate3recomp --version="$version"

THREAD_SUSPEND_RACE_REV="${THREAD_SUSPEND_RACE_REV:-}" PACKAGE_NIX="$dir/package.nix" python3 - <<'PY'
import base64, hashlib, os, pathlib, re, urllib.request

path = pathlib.Path(os.environ["PACKAGE_NIX"])
text = path.read_text()
match = re.search(r'(?m)^  threadSuspendRaceRev = "([0-9a-f]+)";', text)
if not match:
    raise SystemExit("update.sh: threadSuspendRaceRev not found")

old_rev = match.group(1)
rev = os.environ["THREAD_SUSPEND_RACE_REV"] or old_rev
if rev != old_rev:
    text = text[: match.start(1)] + rev + text[match.end(1) :]

url = f"https://github.com/mchughalex/rexglue-skate3/commit/{rev}.patch"
request = urllib.request.Request(url, headers={"User-Agent": "nurpkgs-update"})
patch = urllib.request.urlopen(request, timeout=60).read()
digest = base64.b64encode(hashlib.sha256(patch).digest()).decode()
patch_hash = f"sha256-{digest}"
text, count = re.subn(
    r'(?ms)(  threadSuspendRacePatch = fetchurl \{\n.*?^\s*hash = )"[^"]+"',
    rf'\g<1>"{patch_hash}"',
    text,
    count=1,
)
if count != 1:
    raise SystemExit("update.sh: threadSuspendRacePatch hash not found")

path.write_text(text)
print(f"update.sh: thread-race patch -> {rev} ({patch_hash})")
PY
nixfmt "$dir/package.nix"

system=$(nix eval --raw --impure --expr builtins.currentSystem)
sdk=".#legacyPackages.$system.skate3recomp.passthru.sdk"

# The SDK commit is the release's third_party/rexglue-sdk gitlink. Its date
# comes from that commit, matching the repository's 0-unstable-<date> form.
TAG="v$version" SDK_NIX="$dir/sdk.nix" python3 - <<'PY'
import json, os, pathlib, re, urllib.request

tag = os.environ["TAG"]
headers = {"User-Agent": "nurpkgs-update"}


def get(url):
    request = urllib.request.Request(url, headers=headers)
    return json.load(urllib.request.urlopen(request, timeout=60))


sdk_path = "third_party/rexglue-sdk"
contents = get(
    f"https://api.github.com/repos/mchughalex/skate3recomp/contents/{sdk_path}?ref={tag}"
)
rev = contents["sha"]
commit = get(f"https://api.github.com/repos/mchughalex/rexglue-skate3/commits/{rev}")
date = commit["commit"]["committer"]["date"][:10]

path = pathlib.Path(os.environ["SDK_NIX"])
text = path.read_text()
text = re.sub(r'rev = "[0-9a-f]+";', f'rev = "{rev}";', text)
text = re.sub(r'version = "0-unstable-[0-9-]+";', f'version = "0-unstable-{date}";', text)
path.write_text(text)
print(f"update.sh: SDK -> {rev} ({date})")
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

#!/usr/bin/env bash
#! nix-shell -i bash -p nix nix-update python3 nixfmt-rfc-style
# shellcheck shell=bash

# Bumps Ely Office and refreshes every coupled pin: nix-update handles the
# source tag/hash, and the LibreOffice LOK kernel tarballs that upstream ships
# in the same release (the Arch package on Linux, the arm64 product archive on
# macOS) have
# no tag relation nix-update can follow, so their hashes are re-prefetched here.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/el/elyoffice
pkg=$dir/package.nix

# Dependency hashes need nix-prefetch-git and would rewrite the shared
# cargoLock.outputHashes; the blocks below refresh them themselves.
nix-update elyoffice --src-only "$@"

version=$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$pkg" | head -n 1)
if [ -z "$version" ]; then
    echo "update.sh: no version in $pkg" >&2
    exit 1
fi

python3 - "$pkg" "$version" <<'PY'
import json
import re
import subprocess
import sys
from pathlib import Path

package = Path(sys.argv[1])
version = sys.argv[2]
text = package.read_text(encoding="utf-8")

release_url = "https://github.com/ELY-Open-Source/ElyOffice/releases/download/v${version}/"
blocks = list(re.finditer(r"fetchurl \{\n(.*?)\n(\s*)\};", text, re.DOTALL))
changed = 0
for block in reversed(blocks):
    body = block.group(1)
    if release_url not in body:
        continue
    url = re.search(r'url = "([^"]+)"', body).group(1)
    prefetch = subprocess.run(
        ["nix", "store", "prefetch-file", "--json",
         url.replace("${version}", version)],
        check=True, capture_output=True, text=True,
    )
    new_hash = json.loads(prefetch.stdout)["hash"]
    body, n = re.subn(r'hash = "sha256-[^"]+"', f'hash = "{new_hash}"', body, count=1)
    if n != 1:
        raise SystemExit(f"update.sh: no hash in {url}")
    text = text[: block.start(1)] + body + text[block.end(1):]
    changed += 1

if changed == 0:
    raise SystemExit("update.sh: no release artifact pins found")

package.write_text(text, encoding="utf-8")
print(f"update.sh: refreshed {changed} release artifact hashes for {version}")
PY

# Cargo.lock pulls every in-tree ely-* crate from one git pin, and the shared
# cargoLock.outputHashes hash changes whenever that pin does.
python3 - "$pkg" "$version" <<'PY'
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

package = Path(sys.argv[1])
version = sys.argv[2]
lock_url = f"https://raw.githubusercontent.com/ELY-Open-Source/ElyOffice/v{version}/Cargo.lock"
try:
    lock = urllib.request.urlopen(lock_url, timeout=120).read().decode()
except OSError as err:
    print(f"update.sh: warning: cannot read {lock_url}: {err}; cargoLock.outputHashes not refreshed", file=sys.stderr)
    raise SystemExit(0)

sources = set(re.findall(r'source = "git\+(https://[^?]+)\?rev=([0-9a-f]+)#', lock))
if len(sources) != 1:
    print(f"update.sh: warning: {len(sources)} distinct git sources in Cargo.lock; leaving cargoLock.outputHashes alone", file=sys.stderr)
    raise SystemExit(0)
(url, rev), = sources

tree = subprocess.run(
    ["nix", "eval", "--impure", "--raw", "--expr",
     f'builtins.fetchTree {{ type = "git"; url = "{url}"; rev = "{rev}"; }}'],
    check=True, capture_output=True, text=True,
).stdout
new_hash = subprocess.run(
    ["nix", "hash", "path", tree], check=True, capture_output=True, text=True,
).stdout.strip()

text = package.read_text(encoding="utf-8")
text, n = re.subn(
    r'(outputHashes = lib\.genAttrs \[[^\]]*\] \(_: ")[^"]+(")',
    lambda match: match.group(1) + new_hash + match.group(2),
    text, count=1,
)
if n != 1:
    raise SystemExit("update.sh: no cargoLock.outputHashes pin found")
package.write_text(text, encoding="utf-8")
print(f"update.sh: refreshed cargoLock.outputHashes for {url}@{rev[:7]}")
PY

# The MuPDF patch series is a vendored copy of upstream's patches/mupdf; a
# release can add patches the worker's shim calls into.
python3 - "$dir/patches" "$version" <<'PY'
import json
import sys
import urllib.request
from pathlib import Path

dest = Path(sys.argv[1])
version = sys.argv[2]
url = f"https://api.github.com/repos/ELY-Open-Source/ElyOffice/contents/patches/mupdf?ref=v{version}"
request = urllib.request.Request(
    url, headers={"User-Agent": "nix-update", "Accept": "application/vnd.github+json"}
)
try:
    entries = json.load(urllib.request.urlopen(request, timeout=120))
except OSError as err:
    print(f"update.sh: warning: cannot list {url}: {err}; MuPDF patches not refreshed", file=sys.stderr)
    raise SystemExit(0)

want = {entry["name"]: entry["download_url"] for entry in entries if entry["name"].endswith(".patch")}
for name, download in sorted(want.items()):
    body = urllib.request.urlopen(download, timeout=120).read()
    path = dest / name
    if not path.exists() or path.read_bytes() != body:
        path.write_bytes(body)
for stale in dest.glob("*.patch"):
    if stale.name not in want:
        stale.unlink()
print(f"update.sh: synced {len(want)} MuPDF patches")
PY

nixfmt "$pkg"

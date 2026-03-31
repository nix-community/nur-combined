#!/usr/bin/env bash
set -euo pipefail

# This script updates pkgs/t3code/default.nix with the latest version and SRI hashes
# for all supported upstream desktop release artifacts.

API_URL="https://api.github.com/repos/pingdotgg/t3code/releases/latest"
NIX_FILE="pkgs/t3code/default.nix"

die() {
  echo "error: $*" >&2
  exit 1
}

if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
else
  SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
  REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd -P)
fi

cd "$REPO_ROOT"

[ -f "$NIX_FILE" ] || die "cannot find $NIX_FILE"

require_tools() {
  command -v curl >/dev/null || die "curl is required"
  command -v python3 >/dev/null || die "python3 is required"
  command -v nix >/dev/null || die "nix is required"
}

prefetch_sri() {
  local url="$1"
  nix --extra-experimental-features 'nix-command flakes' \
    store prefetch-file --json "$url" \
    | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("hash") or d["narHash"])'
}

current_version() {
  sed -n -E 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";$/\1/p' "$NIX_FILE"
}

discover_release_json() {
  if [ -n "${FORCE_VERSION:-}" ]; then
    curl -fsSL -H 'Accept: application/vnd.github+json' \
      "https://api.github.com/repos/pingdotgg/t3code/releases/tags/v${FORCE_VERSION}"
    return 0
  fi

  curl -fsSL -H 'Accept: application/vnd.github+json' "$API_URL"
}

json_get() {
  local expr="$1"
  python3 -c "$expr"
}

asset_url_from_release() {
  local asset_name="$1"
  ASSET_NAME="$asset_name" json_get '
import json, os, sys
asset_name = os.environ["ASSET_NAME"]
release = json.load(sys.stdin)
for asset in release.get("assets", []):
    if asset.get("name") == asset_name:
        print(asset["browser_download_url"])
        break
else:
    raise SystemExit(f"missing asset: {asset_name}")
'
}

update_nix_file() {
  local new_version="$1"
  local linux_url="$2"
  local linux_hash="$3"
  local darwin_x64_url="$4"
  local darwin_x64_hash="$5"
  local darwin_arm64_url="$6"
  local darwin_arm64_hash="$7"

  NEW_VERSION="$new_version" \
  LINUX_URL="$linux_url" \
  LINUX_HASH="$linux_hash" \
  DARWIN_X64_URL="$darwin_x64_url" \
  DARWIN_X64_HASH="$darwin_x64_hash" \
  DARWIN_ARM64_URL="$darwin_arm64_url" \
  DARWIN_ARM64_HASH="$darwin_arm64_hash" \
  NIX_FILE="$NIX_FILE" \
  python3 <<'PY'
from pathlib import Path
import os
import re

path = Path(os.environ["NIX_FILE"])
text = path.read_text()

replacements = {
    "x86_64-linux": (os.environ["LINUX_URL"], os.environ["LINUX_HASH"]),
    "x86_64-darwin": (os.environ["DARWIN_X64_URL"], os.environ["DARWIN_X64_HASH"]),
    "aarch64-darwin": (os.environ["DARWIN_ARM64_URL"], os.environ["DARWIN_ARM64_HASH"]),
}

text, count = re.subn(
    r'(^\s*version\s*=\s*")[^"]+(";\s*$)',
    rf'\g<1>{os.environ["NEW_VERSION"]}\2',
    text,
    count=1,
    flags=re.MULTILINE,
)
if count != 1:
    raise SystemExit("failed to update version")

for system, (url, hash_) in replacements.items():
    pattern = re.compile(
        rf'({re.escape(system)} = fetchurl \{{\n\s+url = ")[^"]+(";\n\s+hash = ")[^"]+(";\n\s+\}};)',
        re.MULTILINE,
    )
    text, count = pattern.subn(rf'\1{url}\2{hash_}\3', text, count=1)
    if count != 1:
        raise SystemExit(f"failed to update block for {system}")

path.write_text(text)
PY
}

main() {
  require_tools

  local release_json cur ver linux_url darwin_x64_url darwin_arm64_url
  local linux_hash darwin_x64_hash darwin_arm64_hash

  cur=$(current_version)
  release_json=$(discover_release_json)
  ver=$(printf '%s' "$release_json" | json_get '
import json, sys
tag = json.load(sys.stdin)["tag_name"]
print(tag[1:] if tag.startswith("v") else tag)
')

  if [ -z "$ver" ]; then
    die "could not discover latest t3code version"
  fi

  if [ "$ver" = "$cur" ]; then
    echo "t3code is already up-to-date ($ver)."
    exit 0
  fi

  linux_url=$(printf '%s' "$release_json" | asset_url_from_release "T3-Code-${ver}-x86_64.AppImage")
  darwin_x64_url=$(printf '%s' "$release_json" | asset_url_from_release "T3-Code-${ver}-x64.dmg")
  darwin_arm64_url=$(printf '%s' "$release_json" | asset_url_from_release "T3-Code-${ver}-arm64.dmg")

  echo "Updating t3code: $cur -> $ver"
  echo "Prefetching x86_64-linux from $linux_url ..." >&2
  linux_hash=$(prefetch_sri "$linux_url")
  echo "Prefetching x86_64-darwin from $darwin_x64_url ..." >&2
  darwin_x64_hash=$(prefetch_sri "$darwin_x64_url")
  echo "Prefetching aarch64-darwin from $darwin_arm64_url ..." >&2
  darwin_arm64_hash=$(prefetch_sri "$darwin_arm64_url")

  update_nix_file \
    "$ver" \
    "$linux_url" \
    "$linux_hash" \
    "$darwin_x64_url" \
    "$darwin_x64_hash" \
    "$darwin_arm64_url" \
    "$darwin_arm64_hash"

  echo "Update complete."
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

APP_ID="2601167vjw8xe"
DOWNLOAD_ROOT="https://download.todesktop.com/${APP_ID}"
NIX_FILE="pkgs/paper-design/default.nix"

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

metadata_value() {
  local field="$1"
  local suffix="${2:-}"

  FIELD="$field" SUFFIX="$suffix" python3 -c '
import os, re, sys
field = os.environ["FIELD"]
suffix = os.environ["SUFFIX"]
text = sys.stdin.read()
if field == "version":
    match = re.search(r"^version:\s*[\x27\"]?([^\x27\"\s]+)", text, re.MULTILINE)
    if not match:
        raise SystemExit("missing version in updater metadata")
    print(match.group(1))
else:
    for match in re.finditer(r"^\s*-?\s*url:\s*(.+?)\s*$", text, re.MULTILINE):
        value = match.group(1).strip("\x27\"")
        if value.endswith(suffix):
            print(value)
            break
    else:
        raise SystemExit(f"missing artifact ending in {suffix!r}")
'
}

url_encode_filename() {
  FILENAME="$1" python3 -c \
    'import os, urllib.parse; print(urllib.parse.quote(os.environ["FILENAME"], safe="-._~"))'
}

prefetch_sri() {
  local url="$1"
  local name="$2"

  nix --extra-experimental-features 'nix-command flakes' \
    store prefetch-file --name "$name" --json "$url" \
    | python3 -c 'import sys, json; print(json.load(sys.stdin)["hash"])'
}

current_version() {
  sed -n -E 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";$/\1/p' "$NIX_FILE"
}

update_nix_file() {
  local new_version="$1"
  local linux_url="$2"
  local linux_hash="$3"
  local darwin_url="$4"
  local darwin_hash="$5"

  NEW_VERSION="$new_version" \
  LINUX_URL="$linux_url" \
  LINUX_HASH="$linux_hash" \
  DARWIN_URL="$darwin_url" \
  DARWIN_HASH="$darwin_hash" \
  NIX_FILE="$NIX_FILE" \
  python3 <<'PY'
from pathlib import Path
import os
import re

path = Path(os.environ["NIX_FILE"])
text = path.read_text()

text, count = re.subn(
    r'(^\s*version\s*=\s*")[^"]+(";\s*$)',
    rf'\g<1>{os.environ["NEW_VERSION"]}\2',
    text,
    count=1,
    flags=re.MULTILINE,
)
if count != 1:
    raise SystemExit("failed to update version")

replacements = {
    "x86_64-linux": (
        f'paper-desktop-{os.environ["NEW_VERSION"]}-x86_64.AppImage',
        os.environ["LINUX_URL"],
        os.environ["LINUX_HASH"],
    ),
    "aarch64-darwin": (
        f'paper-desktop-{os.environ["NEW_VERSION"]}-aarch64.dmg',
        os.environ["DARWIN_URL"],
        os.environ["DARWIN_HASH"],
    ),
}

for system, (name, url, hash_) in replacements.items():
    pattern = re.compile(
        rf'({re.escape(system)} = fetchurl \{{\n\s+name = ")[^"]+'
        rf'(";\n\s+url = ")[^"]+(";\n\s+hash = ")[^"]+(";\n\s+\}};)',
        re.MULTILINE,
    )
    replacement = rf'\g<1>{name}\2{url}\3{hash_}\4'
    text, count = pattern.subn(replacement, text, count=1)
    if count != 1:
        raise SystemExit(f"failed to update source block for {system}")

path.write_text(text)
PY
}

main() {
  require_tools

  local linux_metadata mac_metadata version mac_version
  local linux_filename darwin_filename linux_url darwin_url
  local linux_hash darwin_hash cur

  linux_metadata=$(curl -fsSL "$DOWNLOAD_ROOT/latest-linux.yml")
  mac_metadata=$(curl -fsSL "$DOWNLOAD_ROOT/latest-mac.yml")

  version=$(printf '%s' "$linux_metadata" | metadata_value version)
  mac_version=$(printf '%s' "$mac_metadata" | metadata_value version)
  [ "$version" = "$mac_version" ] \
    || die "Linux and macOS versions differ ($version != $mac_version)"

  linux_filename=$(printf '%s' "$linux_metadata" | metadata_value url x86_64.AppImage)
  darwin_filename=$(printf '%s' "$mac_metadata" | metadata_value url arm64.dmg)
  linux_url="$DOWNLOAD_ROOT/$(url_encode_filename "$linux_filename")"
  darwin_url="$DOWNLOAD_ROOT/$(url_encode_filename "$darwin_filename")"
  cur=$(current_version)

  if [ "${FORCE_UPDATE:-0}" != "1" ] \
    && [ "$version" = "$cur" ] \
    && grep -Fq "$linux_url" "$NIX_FILE" \
    && grep -Fq "$darwin_url" "$NIX_FILE"; then
    echo "paper-design is already up-to-date ($version)."
    exit 0
  fi

  echo "Updating paper-design: $cur -> $version"
  echo "Prefetching x86_64-linux from $linux_url ..." >&2
  linux_hash=$(prefetch_sri \
    "$linux_url" "paper-desktop-${version}-x86_64.AppImage")
  echo "Prefetching aarch64-darwin from $darwin_url ..." >&2
  darwin_hash=$(prefetch_sri \
    "$darwin_url" "paper-desktop-${version}-aarch64.dmg")

  update_nix_file \
    "$version" "$linux_url" "$linux_hash" "$darwin_url" "$darwin_hash"

  echo "Update complete."
}

main "$@"

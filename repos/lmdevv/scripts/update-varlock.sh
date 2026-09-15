#!/usr/bin/env bash
set -euo pipefail

# This script updates pkgs/varlock/default.nix with the latest varlock@ tag
# and SRI hashes for all supported platforms. GitHub's /releases/latest is
# not used because this monorepo publishes many packages.

REPO="dmno-dev/varlock"
NIX_FILE="pkgs/varlock/default.nix"

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

discover_latest_version() {
  if [ -n "${FORCE_VERSION:-}" ]; then
    echo "$FORCE_VERSION"
    return 0
  fi

  curl -fsSL -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/${REPO}/releases?per_page=50" \
    | python3 -c '
import json, sys
releases = json.load(sys.stdin)
for rel in releases:
    tag = rel.get("tag_name") or ""
    if not tag.startswith("varlock@"):
        continue
    assets = rel.get("assets") or []
    if not assets:
        continue
    print(tag[len("varlock@"):])
    break
'
}

current_version() {
  sed -n -E 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";$/\1/p' "$NIX_FILE"
}

update_nix_file() {
  local new_version="$1"
  local h_x86_64_linux="$2"
  local h_aarch64_linux="$3"
  local h_x86_64_darwin="$4"
  local h_aarch64_darwin="$5"

  NEW_VERSION="$new_version" \
  H_X86_64_LINUX="$h_x86_64_linux" \
  H_AARCH64_LINUX="$h_aarch64_linux" \
  H_X86_64_DARWIN="$h_x86_64_darwin" \
  H_AARCH64_DARWIN="$h_aarch64_darwin" \
  NIX_FILE="$NIX_FILE" \
  python3 <<'PY'
from pathlib import Path
import os
import re

path = Path(os.environ["NIX_FILE"])
text = path.read_text()

replacements = {
    "x86_64-linux": os.environ["H_X86_64_LINUX"],
    "aarch64-linux": os.environ["H_AARCH64_LINUX"],
    "x86_64-darwin": os.environ["H_X86_64_DARWIN"],
    "aarch64-darwin": os.environ["H_AARCH64_DARWIN"],
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

for system, hash_ in replacements.items():
    text, count = re.subn(
        rf'("{re.escape(system)}"\s*=\s*")[^"]+(";)',
        rf'\g<1>{hash_}\2',
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit(f"failed to update hash for {system}")

path.write_text(text)
PY
}

main() {
  require_tools

  local cur ver
  cur=$(current_version)
  ver=$(discover_latest_version)

  if [ -z "$ver" ]; then
    echo "warning: could not discover latest version automatically." >&2
    if [ -n "${FORCE_VERSION:-}" ]; then
      echo "using FORCE_VERSION=$FORCE_VERSION" >&2
      ver="$FORCE_VERSION"
    else
      echo "nothing to do; exiting successfully" >&2
      exit 0
    fi
  fi

  if [ "$ver" = "$cur" ] && [ -z "${FORCE_VERSION:-}" ]; then
    echo "varlock is already up-to-date ($ver)."
    exit 0
  fi

  if [ "$ver" = "$cur" ]; then
    echo "Refreshing varlock hashes for version $ver"
  else
    echo "Updating varlock: $cur -> $ver"
  fi

  declare -A ASSET_BY_SYSTEM=(
    [x86_64-linux]=linux-x64
    [aarch64-linux]=linux-arm64
    [x86_64-darwin]=macos-x64
    [aarch64-darwin]=macos-arm64
  )

  local systems=(x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin)
  declare -A HASH

  for sys in "${systems[@]}"; do
    asset="${ASSET_BY_SYSTEM[$sys]}"
    url="https://github.com/${REPO}/releases/download/varlock@${ver}/varlock-${asset}.tar.gz"
    echo "Prefetching $sys from $url ..." >&2
    HASH[$sys]=$(prefetch_sri "$url")
  done

  update_nix_file \
    "$ver" \
    "${HASH[x86_64-linux]}" \
    "${HASH[aarch64-linux]}" \
    "${HASH[x86_64-darwin]}" \
    "${HASH[aarch64-darwin]}"

  echo "Update complete."
}

main "$@"

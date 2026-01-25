#!/usr/bin/env bash
set -euo pipefail

# This script updates pkgs/coderabbit-cli/default.nix with the latest version and SRI hashes
# for all supported platforms by prefetching the remote zip files.

BASE_URL="https://cli.coderabbit.ai/releases"
NIX_FILE="pkgs/coderabbit-cli/default.nix"

die() {
  echo "error: $*" >&2
  exit 1
}

# Resolve repository root
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
else
  # Fallback to script directory's parent
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
  # If FORCE_VERSION is set, use that.
  if [ -n "${FORCE_VERSION:-}" ]; then
    echo "$FORCE_VERSION"
    return 0
  fi

  # Fetch latest version from the VERSION file
  local version
  version=$(curl -fsSL "$BASE_URL/latest/VERSION" | tr -d '[:space:]')
  echo "$version"
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

  # Replace version
  sed -i -E "s#(^[[:space:]]*version[[:space:]]*=[[:space:]]*\")([^\"]+)(\";)#\\1${new_version}\\3#" "$NIX_FILE"

  # Replace per-system hashes
  sed -i -E "s#(\"x86_64-linux\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_x86_64_linux}\\2#" "$NIX_FILE"
  sed -i -E "s#(\"aarch64-linux\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_aarch64_linux}\\2#" "$NIX_FILE"
  sed -i -E "s#(\"x86_64-darwin\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_x86_64_darwin}\\2#" "$NIX_FILE"
  sed -i -E "s#(\"aarch64-darwin\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_aarch64_darwin}\\2#" "$NIX_FILE"
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

  if [ "$ver" = "$cur" ]; then
    echo "coderabbit-cli is already up-to-date ($ver)."
    exit 0
  fi

  echo "Updating coderabbit-cli: $cur -> $ver"

  # Matrix of systems → (os, arch)
  declare -A OS_BY_SYSTEM=(
    [x86_64-linux]=linux
    [aarch64-linux]=linux
    [x86_64-darwin]=darwin
    [aarch64-darwin]=darwin
  )
  declare -A ARCH_BY_SYSTEM=(
    [x86_64-linux]=x64
    [aarch64-linux]=arm64
    [x86_64-darwin]=x64
    [aarch64-darwin]=arm64
  )

  local systems=(x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin)
  declare -A HASH

  for sys in "${systems[@]}"; do
    os="${OS_BY_SYSTEM[$sys]}"
    arch="${ARCH_BY_SYSTEM[$sys]}"
    url="$BASE_URL/$ver/coderabbit-$os-$arch.zip"
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

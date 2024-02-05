#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused jq nix-prefetch

set -euo pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
NIX_DRV="$ROOT/next.nix"
if [ ! -f "$NIX_DRV" ]; then
  echo "ERROR: cannot find next in $ROOT"
  exit 1
fi

fetch_arch() {
  VER="$1"; ARCH="$2"
  URL="https://github.com/owncloud/ocis/releases/download/v${VER}/ocis-${VER}-${ARCH}"
  nix-prefetch "{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = \"ocis-bin\"; version = \"${VER}\";
  src = fetchurl { url = \"$URL\"; };
}
"
}

replace_sha() {
  sed -i "s#$1 = \"sha256-.\{44\}\"#$1 = \"$2\"#" "$NIX_DRV"
}

VAULT_VER=$(curl -s https://api.github.com/repos/owncloud/ocis/releases | jq -r 'map(select(.prerelease)) | .[0].tag_name' | sed 's/v//')

VAULT_LINUX_X86_SHA256=$(fetch_arch "$VAULT_VER" "linux-386")
VAULT_LINUX_X64_SHA256=$(fetch_arch "$VAULT_VER" "linux-amd64")
VAULT_DARWIN_X64_SHA256=$(fetch_arch "$VAULT_VER" "darwin-amd64")
VAULT_LINUX_AARCH64_SHA256=$(fetch_arch "$VAULT_VER" "linux-arm64")
VAULT_DARWIN_AARCH64_SHA256=$(fetch_arch "$VAULT_VER" "darwin-arm64")

sed -i "s/version = \".*\"/version = \"$VAULT_VER\"/" "$NIX_DRV"

replace_sha "i686-linux" "$VAULT_LINUX_X86_SHA256"
replace_sha "x86_64-linux" "$VAULT_LINUX_X64_SHA256"
replace_sha "x86_64-darwin" "$VAULT_DARWIN_X64_SHA256"
replace_sha "aarch64-linux" "$VAULT_LINUX_AARCH64_SHA256"
replace_sha "aarch64-darwin" "$VAULT_DARWIN_AARCH64_SHA256"

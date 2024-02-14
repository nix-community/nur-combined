#! /usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

set -eou pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
if [ ! -f "$ROOT/package.nix" ]; then
  echo "ERROR: cannot find package.nix in $ROOT"
  exit 1
fi

update_vscodium () {
  VSCODIUM_VER=$1
  ARCH=$2
  ARCH_LONG=$3
  ARCHIVE_FMT=$4
  VSCODIUM_URL="https://github.com/VSCodium/vscodium-insiders/releases/download\
/${VSCODIUM_VER}/VSCodium-${ARCH}-${VSCODIUM_VER}.${ARCHIVE_FMT}"
  VSCODIUM_SHA256=$(nix-prefetch-url ${VSCODIUM_URL})
  sed -i "s/${ARCH_LONG} = \".\{52\}\"/${ARCH_LONG} = \"${VSCODIUM_SHA256}\"/" \
         "$ROOT/package.nix"
}

# VSCodium

VSCODIUM_VER=$(curl -Ls -w %{url_effective} -o /dev/null \
               https://github.com/VSCodium/vscodium-insiders/releases/latest \
               | awk -F'/' '{print $NF}')
sed -i "s/version = \".*\"/version = \"${VSCODIUM_VER}\"/" "$ROOT/package.nix"

update_vscodium $VSCODIUM_VER linux-x64 x86_64-linux tar.gz
update_vscodium $VSCODIUM_VER darwin-x64 x86_64-darwin zip
update_vscodium $VSCODIUM_VER linux-arm64 aarch64-linux tar.gz
update_vscodium $VSCODIUM_VER darwin-arm64 aarch64-darwin zip
update_vscodium $VSCODIUM_VER linux-armhf armv7l-linux tar.gz

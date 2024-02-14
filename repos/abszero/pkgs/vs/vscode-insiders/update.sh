#! /usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

set -eou pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
if [ ! -f "$ROOT/package.nix" ]; then
  echo "ERROR: cannot find package.nix in $ROOT"
  exit 1
fi

update_vscode () {
  VSCODE_VER=$1
  ARCH=$2
  ARCH_LONG=$3
  VSCODE_URL="https://update.code.visualstudio.com/${VSCODE_VER}/${ARCH}/insider"
  VSCODE_SHA256=$(nix-prefetch-url ${VSCODE_URL})
  sed -i "s/${ARCH_LONG} = \".\{52\}\"/${ARCH_LONG} = \"${VSCODE_SHA256}\"/" \
         "$ROOT/package.nix"
}

# VSCode

VSCODE_VER=$(curl -fs https://update.code.visualstudio.com/api/releases/insider \
             | jq -r .[0])
sed -i "s/version = \".*\"/version = \"${VSCODE_VER}\"/" "$ROOT/package.nix"

update_vscode $VSCODE_VER linux-x64 x86_64-linux
update_vscode $VSCODE_VER darwin x86_64-darwin
update_vscode $VSCODE_VER linux-arm64 aarch64-linux
update_vscode $VSCODE_VER darwin-arm64 aarch64-darwin
update_vscode $VSCODE_VER linux-armhf armv7l-linux

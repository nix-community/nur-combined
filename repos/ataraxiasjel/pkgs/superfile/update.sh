#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gawk nix-prefetch-git jq

set -euo pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
NIX_DRV="$ROOT/default.nix"
if [ ! -f "$NIX_DRV" ]; then
  echo "ERROR: cannot find default in $ROOT"
  exit 1
fi

SUPERFILE_VER=$(curl -Ls -w "%{url_effective}" -o /dev/null https://github.com/MHNightCat/superfile/releases/latest | awk -F'/' '{print $NF}' | sed 's/v//')
SUPERFILE_HASH=$(nix-prefetch-git --url https://github.com/MHNightCat/superfile --rev v$SUPERFILE_VER | jq -r .hash)
sed -i "s/version = \".*\"/version = \"$SUPERFILE_VER\"/" "$NIX_DRV"
sed -i "s#hash = \"sha256-.\{44\}\"#hash = \"$SUPERFILE_HASH\"#" "$NIX_DRV"


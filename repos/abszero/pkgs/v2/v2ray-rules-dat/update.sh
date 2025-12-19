#! /usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

set -eou pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
if [ ! -f "$ROOT/package.nix" ]; then
  echo "ERROR: cannot find package.nix in $ROOT"
  exit 1
fi

VER=$(curl -fs https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest \
      | jq -r .tag_name)
GEOIP_HASH=$(nix-prefetch-url \
  https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$VER/geoip.dat)
GEOSITE_HASH=$(nix-prefetch-url \
  https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$VER/geosite.dat)

sed -i "$ROOT/package.nix" \
  -e "s|version = \".*\"|version = \"$VER\"|" \
  -e "s|geoipHash = \".*\"|geoipHash = \"$GEOIP_HASH\"|" \
  -e "s|geositeHash = \".*\"|geositeHash = \"$GEOSITE_HASH\"|"

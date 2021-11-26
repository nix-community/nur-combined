#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix nodejs-14_x curl jq

set -euo pipefail
# cd to the folder containing this script
cd "$(dirname "$0")"

TARGET_VERSION=$(curl https://api.github.com/repos/Koenkk/zigbee2mqtt/releases/latest | jq -r ".tag_name")
ZIGBEE2MQTT=https://github.com/Koenkk/zigbee2mqtt/raw/$TARGET_VERSION

curl -LO $ZIGBEE2MQTT/package.json
curl -LO $ZIGBEE2MQTT/npm-shrinkwrap.json

node2nix --nodejs-14 \
  --development \
  --lock npm-shrinkwrap.json \
  --output node-packages.nix \
  --composition node.nix

rm npm-shrinkwrap.json

# (
#     cd ../../../..
#     nix-update --version "$TARGET_VERSION" --build zigbee2mqtt
# )

# git add ./default.nix ./node-packages.nix ./node.nix
# git commit -m "zigbee2mqtt: ${CURRENT_VERSION} -> ${TARGET_VERSION}"

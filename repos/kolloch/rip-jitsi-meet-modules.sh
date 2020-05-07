#!/usr/bin/env bash

NIXPKGS=$1

if [ ! -d "$NIXPKGS" ]; then
  echo "rip-jistsi-meet-modules.sh <path to nixpkgs>" >&2
  exit 1
fi

set -euxo pipefail

rm -rf pkgs/jitsi modules/jitsi
mkdir pkgs/jitsi modules/jitsi

echo "Managed by rip-jitsi-meet-modules.sh" > pkgs/jitsi/WARNING.md
echo "Managed by rip-jitsi-meet-modules.sh" > modules/jitsi/WARNING.md

cp -R \
  $NIXPKGS/pkgs/servers/web-apps/jitsi-meet \
  $NIXPKGS/pkgs/servers/jicofo \
  $NIXPKGS/pkgs/servers/jitsi-videobridge \
  pkgs/jitsi

cp -R \
  $NIXPKGS/nixos/modules/services/networking/jicofo.nix \
  $NIXPKGS/nixos/modules/services/web-apps/jitsi-meet.nix \
  $NIXPKGS/nixos/modules/services/networking/jitsi-videobridge.nix \
  modules/jitsi
#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
nix-shell --run "nixpkgs-firefox-addons pkgs/firefox-plugins/addons.json \
        pkgs/firefox-plugins/generated-addons.nix"

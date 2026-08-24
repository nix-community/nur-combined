#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p nix -p nix-update
# shellcheck shell=bash
NEW_VERSION=$(curl -fsSL 'https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=baidunetdisk-electron' |
  jq -r '.results[0].Version' | sed 's/-[^-]*$//')
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"

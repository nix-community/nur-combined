#!/usr/bin/env bash
DEFAULT_PROFILE=$(cat ~/.mozilla/firefox/profiles.ini | grep 'Default=...*' | cut -d = -f 2)
cat "$HOME/.mozilla/firefox/$DEFAULT_PROFILE/addons.json" | jq '.addons|map({slug:(.reviewURL|split("/")|.[6])})'> addons.json
nix run -f "https://github.com/nix-community/NUR/archive/master.tar.gz" repos.rycee.firefox-addons-generator \
	--arg pkgs 'import <nixpkgs> {}' \
	-c nixpkgs-firefox-addons addons.json ./generated.nix
if [[ ! -e ./default.nix ]]; then
cat > ./default.nix << EOF
# Derived from: https://github.com/nix-community/nur-combined/blob/master/repos/ijohanne/pkgs/firefox-plugins/default.nix
{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) fetchFirefoxAddon fetchurl stdenv;
  buildFirefoxXpiAddon = { pname, url, sha256, meta, ... }: let
    inherit (pkgs.stdenv.lib) licenses;
    newMeta = if meta ? license then meta else meta // { license = licenses.unfree; };
  in
    (fetchFirefoxAddon { inherit url sha256; name = pname; }) // { meta = newMeta; };
  generated = import ./generated.nix { inherit buildFirefoxXpiAddon fetchurl stdenv; };
in
  generated // { recurseForDerivations = true; }
EOF
fi

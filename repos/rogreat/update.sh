#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

echo
echo stable
for pkg in ./pkgs/{python/,}stable/*; do
	attribute=$(basename "$pkg")
	echo nix-update "$attribute"
	nix-update "$attribute" &
done

echo
echo unstable
for pkg in ./pkgs/unstable/*; do
	attribute=$(basename "$pkg")
	echo nix-update --version=unstable "$attribute"
	nix-update --version=unstable "$attribute" &
done

echo
echo firefox-addons
echo mozilla-addons-to-nix ./pkgs/firefox-addons/{addons.json,default.nix}
mozilla-addons-to-nix ./pkgs/firefox-addons/{addons.json,default.nix} &

wait

echo
echo hashes
for pkg in ./pkgs/{python/,}{stable,unstable}/*; do
	attribute=$(basename "$pkg")
	echo nix-update --version=skip "$attribute"
	nix-update --version=skip "$attribute" &
done

wait

git status

#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

for pkg in ./pkgs/{python/,}stable/*; do
	attribute=$(basename "$pkg")
	echo nix-update "$attribute"
	nix-update "$attribute" &
done

for pkg in ./pkgs/unstable/*; do
	attribute=$(basename "$pkg")
	echo nix-update --version=unstable "$attribute"
	nix-update --version=unstable "$attribute" &
done

wait

git status

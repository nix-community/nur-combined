#!/usr/bin/env bash

shopt -s nullglob

for pkg in ./pkgs/{python/,}stable/*; do
	pkg=$(basename "$pkg")
	echo nix-update "$pkg"
	nix-update "$pkg" &
done

for pkg in ./pkgs/unstable/*; do
	pkg=$(basename "$pkg")
	echo nix-update --version=unstable "$pkg"
	nix-update --version=unstable "$pkg" &
done

for pkg in ./pkgs/nightly/*; do
	pkg=$(basename "$pkg")
	echo nix-update --version=branch "$pkg"
	nix-update --version=branch "$pkg" &
done

wait

git status

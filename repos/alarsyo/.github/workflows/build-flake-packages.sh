#!/bin/sh

set -xe

PACKAGES=$(nix flake show --json \
	| jq '.packages."x86_64-linux" | keys[]')

for package in $PACKAGES; do
	nix build --verbose -L .#$package
done

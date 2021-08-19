#!/bin/sh

set -xe

PACKAGES=$(nix flake show \
	| grep ': package' \
	| sed 's/\x1b\[[0-9;]*m//g' \
	| sed -E 's/^.*───([A-Za-z/"-]+):.*$/\1/' \
	| sort \
	| uniq)

for package in $PACKAGES; do
	nix build --verbose .#$package
done

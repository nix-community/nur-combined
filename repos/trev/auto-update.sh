#!/usr/bin/env bash

SYSTEM=$(nix eval --impure --raw --expr 'builtins.currentSystem')
readarray -d " " PKGS < <(nix eval --raw ".#packages.${SYSTEM}" --apply "attrs: builtins.toString (builtins.attrNames attrs)")

for PKG in "${PKGS[@]}"; do
    printf "Updating %s...\n" "${PKG}"
    eval nix-update --commit "${PKG}"
    printf "Successfully updated %s\n\n" "${PKG}"
done

#!/usr/bin/env bash

# shamelessly stolen from the following MIT licensed repository:
# https://github.com/selfuryon/nix-update-action/tree/21ef9ccb47eb482821e0502a80e988e0dfe49e6b

set -euo pipefail

determinePackages() {
  # determine packages to update
  PACKAGES=$(nix flake show --json | jq -r '[.packages[] | keys[]] | sort | unique |  join(",")')
}

updatePackages() {
  # update packages
  for PACKAGE in ${PACKAGES//,/ }; do
    echo "Updating package '$PACKAGE'."
    nix-update --flake "$PACKAGE" 1>/dev/null
  done
}

determinePackages
updatePackages

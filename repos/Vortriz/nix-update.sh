#!/usr/bin/env bash
set -euo pipefail

determinePackages() {
    # determine packages to update
    if [[ -z "$PACKAGES" ]]; then
        PACKAGES=$(nix flake show --all-systems --json | jq -r '[.packages[] | keys[]] | sort | unique |  join(",")')
    fi
}

updatePackages() {
  # update packages
    for PACKAGE in ${PACKAGES//,/ }; do
        if [[ ",$BLACKLIST," == *",$PACKAGE,"* ]]; then
            echo "Package '$PACKAGE' is blacklisted, skipping."
            continue
        fi
        echo "Updating package '$PACKAGE'."
        nix-update --version=branch "$PACKAGE" 1>/dev/null
    done
}

determinePackages
updatePackages

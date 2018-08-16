#!/usr/bin/env bash

set -euo pipefail

# Use the ALLVM binary cache in addition to default NixOS cache
# Also, ensure sandbox support is enabled
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
substituters = https://cache.nixos.org https://allvm.cachix.org https://cache.allvm.org
trusted-public-keys = gravity.cs.illinois.edu-1:yymmNS/WMf0iTj2NnD0nrVV8cBOXM9ivAkEdO1Lro3U= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= allvm.cachix.org-1:nz7VuSMfFJDKuOc1LEwUguAqS07FOJHY6M45umrtZdk=
sandbox = true
EOF

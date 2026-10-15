#!/usr/bin/env bash
set -euo pipefail

# Newest GitHub release by date, prereleases included. Upstream's numbering (0.5, 0.51,
# 0.6-pre1) does not sort as versions, so nix-update's own selection would stay on 0.51.
LATEST=$(curl -fsSL https://github.com/deadinside28/bloodborne_pc/releases.atom \
  | grep -oE 'releases/tag/[^"&<]+' | head -1 | sed 's|releases/tag/||')
CURRENT=$(grep -m1 'version = ' pkgs/bbport/default.nix | sed 's/.*"\(.*\)".*/\1/')

if [ "$LATEST" = "$CURRENT" ]; then
  echo "bbport is up to date ($CURRENT)"
  exit 0
fi

nix-update --flake bbport --version "$LATEST"

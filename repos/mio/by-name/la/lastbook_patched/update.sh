#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl nix-update python3
# shellcheck shell=bash

# Bumps the base package (version, source and upstream manifest), then rebuilds
# the manifest this variant ships from the review release the patch adds. The
# patches themselves are not regenerated: rebase them when lastbook moves.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

bash by-name/la/lastbook/update.sh

review=$(mktemp)
trap 'rm -f "$review"' EXIT
curl -fsSL --retry 3 -o "$review" \
  https://github.com/pilkster/lastbook/releases/download/australia-state-maps-review-2026-11-17/AUSTRALIA-STATE-REVIEW-BUILD.json
python3 by-name/la/lastbook_patched/make-manifest.py "$review"

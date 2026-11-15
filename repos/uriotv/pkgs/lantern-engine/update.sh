#!/usr/bin/env bash
set -euo pipefail

# Authenticate GitHub API calls when CI provides a token: the anonymous limit is
# 60 requests per hour for the whole runner address.
api_auth=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  api_auth=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
fi
# Follow stable source tags, never the precompiled Linux release archive.
LATEST=$(curl -fsSL --retry 4 --retry-max-time 60 --max-time 30 "${api_auth[@]}" https://api.github.com/repos/Awakenchan/LanternEngine/releases/latest \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].removeprefix("v"))')
CURRENT=$(grep -m1 'version = ' pkgs/lantern-engine/default.nix | sed 's/.*"\(.*\)".*/\1/')
if [[ "$LATEST" == "$CURRENT" ]]; then
  echo "lantern-engine is up to date ($CURRENT)"
  exit 0
fi
nix-update --flake lantern-engine --version "$LATEST"
# NuGet dependencies are fixed-output inputs; refresh the lock, not binaries.
fetch_deps=$(nix build --no-link --print-out-paths --no-write-lock-file \
  .#packages.x86_64-linux.lantern-engine.launcher.fetch-deps)
"$fetch_deps" pkgs/lantern-engine/deps.json

#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#gh nixpkgs#jq --command bash
set -euo pipefail

if (( $# != 0 )); then
  echo "Usage: $0" >&2
  exit 1
fi
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
for package in rime-ice portop patchelf-unstable mihomo-oix codex-bin; do
  echo "Updating $package..."
  bash "$REPO_ROOT/pkgs/$package/update.sh"
done

#!/usr/bin/env bash
# See https://discourse.nixos.org/t/25274
set -Eeuo pipefail

root="$(readlink --canonicalize -- "$(dirname -- "$0")/..")"

# Mock nixpkgs
trap 'rm -f "$root/_update.nix"' EXIT; cat > "$root/_update.nix" << NIX
{}: import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }
NIX

# Run update scripts
nixpkgs="$(nix-instantiate --eval --expr '<nixpkgs>')"
nix-shell "$nixpkgs/maintainers/scripts/update.nix" --show-trace \
  --arg include-overlays "(import $root/_update.nix { }).overlays" \
  --arg keep-going 'true' \
  --arg predicate "(
    let prefix = \"$root/pkgs/\"; prefixLen = builtins.stringLength prefix;
    in (_: p: (builtins.substring 0 prefixLen p.meta.position) == prefix)
  )"

# Clean up
if [[ -f "$root/update-git-commits.txt" ]]; then
  cat "$root/update-git-commits.txt" && rm "$root/update-git-commits.txt"
fi

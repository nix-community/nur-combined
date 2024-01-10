#!/usr/bin/env bash
# See https://discourse.nixos.org/t/25274
set -Eeuo pipefail

root="$(readlink --canonicalize -- "$(dirname -- "$0")/..")"

# Run update scripts
nixpkgs="$(nix-instantiate --eval --expr '<nixpkgs>')"
nix-shell "$nixpkgs/maintainers/scripts/update.nix" --show-trace \
  --arg include-overlays "(import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }).overlays" \
  --argstr keep-going 'true' \
  --argstr commit 'true' \
  --arg predicate "(
    let prefix = \"$root/pkgs/\"; prefixLen = builtins.stringLength prefix;
    in (_: p: (builtins.substring 0 prefixLen (p.meta.position or (builtins.trace p.meta \"\"))) == prefix)
  )"

# Clean up
if [[ -f "$root/update-git-commits.txt" ]]; then
  cat "$root/update-git-commits.txt" && rm "$root/update-git-commits.txt"
fi

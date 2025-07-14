#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#nvfetcher --command bash
# shellcheck shell=bash
# See https://discourse.nixos.org/t/25274

set -Eeuo pipefail

root="$(readlink --canonicalize -- "$(dirname -- "$0")/..")"

nvfetcher --commit-changes -k ~/.config/nvchecker/keyfile.toml

# Run update scripts
export NIX_PATH="${NIX_PATH:-nixpkgs=flake:nixpkgs}"
nixpkgs="$(nix-instantiate --eval --expr '<nixpkgs>')"
nix-shell "$nixpkgs/maintainers/scripts/update.nix" --show-trace \
	--arg include-overlays "[ (import ./overlay.nix) ]" \
	--argstr keep-going 'true' \
	--argstr commit 'true' \
	--argstr skip-prompt 'true' \
	--arg predicate "(
    let prefix = \"$root/pkgs/\"; prefixLen = builtins.stringLength prefix;
    getPosition = p: p.meta.position or (builtins.trace p.meta \"\");
    in (path: p: (builtins.substring 0 prefixLen (getPosition p)) ==  prefix)
  )"

# Clean up
if [[ -f "$root/update-git-commits.txt" ]]; then
	cat "$root/update-git-commits.txt" && rm "$root/update-git-commits.txt"
fi

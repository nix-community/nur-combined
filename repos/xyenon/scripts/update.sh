#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nvfetcher ast-grep jq nix-prefetch
# shellcheck shell=bash
# See https://discourse.nixos.org/t/25274

set -xeuo pipefail

root="$(readlink --canonicalize -- "$(dirname -- "$0")/..")"

nvfetcher --commit-changes -k ~/.config/nvchecker/keyfile.toml

# Update caddy plugins hash if sources changed
caddy_default="$root/pkgs/caddy/default.nix"
if ! git diff --quiet HEAD~1 -- "$root/_sources/generated.nix"; then
	# shellcheck disable=SC2016
	old_hash=$(ast-grep run --lang nix -p '{ hash = "$$HASH"; }' --selector binding --json "$caddy_default" | jq -r '.[0].metaVariables.single.HASH.text')
	system=$(nix eval --raw --impure --expr builtins.currentSystem)
	new_hash=$(nix-prefetch --option extra-experimental-features flakes \
		"{ sha256 }: (builtins.getFlake \"$root\").packages.$system.caddy.src.overrideAttrs (_: { outputHash = sha256; })")
	if [[ -n $new_hash && $new_hash != "$old_hash" ]]; then
		# shellcheck disable=SC2016
		ast-grep run --lang nix -p '{ hash = "$$HASH"; }' --selector binding -r "hash = \"$new_hash\";" "$caddy_default" --update-all
		git add "$caddy_default"
		git commit --amend --no-edit
	fi
fi

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

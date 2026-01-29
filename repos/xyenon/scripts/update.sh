#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nvfetcher ast-grep jq
# shellcheck shell=bash
# See https://discourse.nixos.org/t/25274

set -xeuo pipefail

root="$(readlink --canonicalize -- "$(dirname -- "$0")/..")"

nvfetcher --commit-changes -k ~/.config/nvchecker/keyfile.toml

if ! git diff --quiet HEAD~1 -- "$root/_sources/generated.nix"; then
	caddy_default="$root/pkgs/caddy/default.nix"
	# shellcheck disable=SC2016
	system=$(nix eval --raw --impure --expr builtins.currentSystem)
	# Set hash to empty string to trigger build error
	# shellcheck disable=SC2016
	ast-grep run --lang nix -p '{ hash = "$$HASH"; }' --selector binding -r 'hash = "";' "$caddy_default" --update-all
	# Build and capture the error output containing the actual hash
	build_output=$(nix build --no-link "$root#packages.$system.caddy" 2>&1 || true)
	# Extract hash from error message (format: "got: sha256-...")
	new_hash=$(echo "$build_output" | grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/=]+')
	ast-grep run --lang nix -p '{ hash = ""; }' --selector binding -r "hash = \"$new_hash\";" "$caddy_default" --update-all
	git add "$caddy_default"

	yazi_plugins_json="$root/pkgs/yazi/plugins/yazi-rs/plugins.json"
	new_yazi_plugins_json=$(nix build --no-link --print-out-paths "$root"#yaziPlugins.yazi-rs.passthru.generate)
	cp "$new_yazi_plugins_json" "$yazi_plugins_json"
	nix fmt "$root"
	git add "$yazi_plugins_json"

	git commit --amend --no-edit
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

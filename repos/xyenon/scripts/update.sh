#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nvfetcher ast-grep nurl
# shellcheck shell=bash
# See https://discourse.nixos.org/t/25274

set -xeuo pipefail

root="$(readlink --canonicalize -- "$(dirname -- "$0")/..")"
nixpkgs=$(nix eval --raw --impure --expr "(builtins.getFlake \"$root\").inputs.nixpkgs.outPath")
export NIX_PATH="nixpkgs=$nixpkgs"
sources_before=$(git rev-parse HEAD)
caddy_src_before=$(nix eval --raw "$root#caddy.src.drvPath")

nvfetcher --commit-changes -k ~/.config/nvchecker/keyfile.toml

caddy_default="$root/pkgs/caddy/default.nix"
yazi_plugins_json="$root/pkgs/yazi/plugins/yazi-rs/plugins.json"

# The workflow commits weekly flake input updates before running this script.
if [ "$caddy_src_before" != "$(nix eval --raw "$root#caddy.src.drvPath")" ] ||
	! git diff --quiet "$sources_before^" "$sources_before" -- "$root/flake.lock"; then
	# nurl overrides outputHash itself; preserve the old hash until it succeeds.
	new_hash=$(nurl -e "(builtins.getFlake \"$root\").packages.\${builtins.currentSystem}.caddy.src")
	# shellcheck disable=SC2016
	ast-grep run --lang nix -p '{ hash = "$$HASH"; }' --selector binding -r "hash = \"$new_hash\";" "$caddy_default" --update-all
fi

if ! git diff --quiet "$sources_before" -- "$root/_sources/generated.nix"; then
	new_yazi_plugins_json=$(nix build --no-link --print-out-paths "$root#yaziPlugins.yazi-rs.passthru.generate")
	cp "$new_yazi_plugins_json" "$yazi_plugins_json"
fi

if ! git diff --quiet -- "$caddy_default" "$yazi_plugins_json"; then
	nix fmt "$root"
	git add "$caddy_default" "$yazi_plugins_json"
	if [ "$(git rev-parse HEAD)" != "$sources_before" ]; then
		git commit --amend --no-edit
	else
		git commit -m 'caddy: update plugins hash' \
			-m 'Regenerate the plugin source hash with the updated flake inputs.'
	fi
fi

# Run update scripts
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

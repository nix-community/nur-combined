#! /usr/bin/env nix-shell
#! nix-shell --quiet -i bash -p nix-prefetch-git jq
set -eo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

old_mainline_version="$(sed -nE '/e/s/\s*version = "(.*)".*/\1/p; /\s*version/q' ./default.nix)"
old_mainline_hash="$(sed -nE 's/^[ \t]*//;1,14 s/s*sha256 = "(.*)".*/\1/p' ./default.nix)"
new_mainline_version="$(curl -s "https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases?per_page=1" | jq -r '.[0].name' | cut -d' ' -f2)"
new_mainline_hash="$(nix-prefetch-git --fetch-submodules https://github.com/yuzu-emu/yuzu-mainline --rev "mainline-0-$new_mainline_version" --quiet | jq -r ".sha256")"

old_ea_version="$(sed -nE 's/^[ \t]*//;15,$ s/s*version = "(.*)".*/\1/p' ./default.nix)"
old_ea_hash="$(sed -nE 's/^[ \t]*//;15,$ s/s*sha256 = "(.*)".*/\1/p' ./default.nix)"
new_ea_version="$(curl -s "https://api.github.com/repos/pineappleEA/pineapple-src/releases?per_page=1" | jq -r '.[0].tag_name' | cut -d'-' -f2)"
new_ea_hash="$(nix-prefetch-git --fetch-submodules https://github.com/pineappleEA/pineapple-src --rev "EA-$new_ea_version" --quiet | jq -r ".sha256")"

if [[ "$new_ea_version" != "$old_ea_version" ]]; then
	echo Updating yuzu early-access from version $old_ea_version to version $new_ea_version.
	sed -i "./default.nix" -re "s|\"$old_ea_version\"|\"$new_ea_version\"|"
	sed -i  "./default.nix" -re "s|\"$old_ea_hash\"|\"$new_ea_hash\"|"
else
	echo "yuzu early-access is already up to date!"
fi

if [[ "$new_mainline_version" != "$old_mainline_version" ]]; then
	echo Updating yuzu mainline from version $old_mainline_version to version $new_mainline_version.
	sed -i "./default.nix" -re "s|\"$old_mainline_version\"|\"$new_mainline_version\"|"
	sed -i "./default.nix" -re "s|\"$old_mainline_hash\"|\"$new_mainline_hash\"|"
else
	echo "yuzu mainline is already up to date!"
fi

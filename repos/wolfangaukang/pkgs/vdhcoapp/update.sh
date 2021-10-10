#!/usr/bin/env nix-shell
#!nix-shell -i bash -p common-updater-scripts coreutils gawk replace nodePackages.node2nix
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

repo=https://github.com/mi-g/vdhcoapp

# Discover the latest version.
current_version=$(sed -ne "s,^.*$repo/archive/v\\(.*\\)\\.tar\\.gz.*\$,\\1,p" packages.json)
new_version=$(list-git-tags "$repo" | sort --reverse --version-sort | awk 'match($0, /^v([0-9.]+)$/, m) { print m[1]; exit; }')
if [[ "$new_version" == "$current_version" ]]; then
    echo "vdhcoapp: no update found"
    exit
fi

# Update the source package in packages.json.
current_source="$repo/archive/v$current_version.tar.gz"
new_source="$repo/archive/v$new_version.tar.gz"
replace-literal -ef "$current_source" "$new_source" packages.json

# Update nodePackages.
node2nix -i packages.json -c composition.nix

echo "vdhcoapp: $current_version -> $new_version"

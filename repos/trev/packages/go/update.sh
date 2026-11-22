#!/usr/bin/env bash

# Updates go_1_XX-latest (the first argument) to the newest patch release of its minor version.
# golang/go has no GitHub releases for nix-update to find, so the version is read from go.dev.
#
# <attr>.pinned is updated, as go_1_XX-latest is nixpkgs' go_1_XX when that's newer,
# so its version and hash aren't the ones in the version file.

set -euo pipefail

attr=$1

current=$(nix eval --raw ".#${attr}.pinned.version")
minor=$(cut -d . -f 1,2 <<< "$current")

latest=$(
    curl --fail --silent --show-error --location 'https://go.dev/dl/?mode=json&include=all' \
        | jq --raw-output --arg prefix "go${minor}." '
            map(select(.stable and (.version | startswith($prefix))) | .version | ltrimstr("go"))
            | sort_by(split(".") | map(tonumber))
            | last // empty
        '
)
if [[ -z "$latest" ]]; then
    printf 'go.dev has no stable go %s release\n' "$minor" >&2
    exit 1
fi

if [[ "$latest" == "$current" ]]; then
    exit 0
fi

nix-update \
    --version "$latest" \
    --override-filename "packages/go/${minor}.nix" \
    "${attr}.pinned"

git commit --quiet --all --message "${attr}: $current -> $latest"

#!/usr/bin/env nix-shell
#! nix-shell -i bash -I nixpkgs=https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz -p coreutils curl jq
# shellcheck shell=bash
set -eu -o pipefail

BASEDIR=$(dirname "$0")

pushd "$BASEDIR"
trap popd EXIT

# TODO:
# - Filter for stable and experimental mods by factorio_version (in info_json) in releases.

echo "Updating mods."

jq -r '.[].name' < mods.json | sort -u | while read -r name; do
    echo "$name" 1>&2
    mod_json="$(curl -s https://mods.factorio.com/api/mods/"$(echo -n "${name}" | jq -sRr @uri)"/full)"
    version="$(jq -r '.releases[] | .version' <<< "$mod_json" | sort -V | tail -n1)"
    echo "$version" 1>&2

    release_json="$(jq -r ".releases[] | select(.version == \"${version}\")" <<< "$mod_json")"

    info_json="$(jq '.info_json' <<< "$release_json")"
    dependencies="$(jq '.dependencies' <<< "$info_json")"

    jq "{ name: \"$name\", version, file_name, download_url, sha1, dependencies: $dependencies}" <<< "$release_json"
done | jq -s . > mods.new.json
mv mods.new.json mods.json

echo "Update successful."

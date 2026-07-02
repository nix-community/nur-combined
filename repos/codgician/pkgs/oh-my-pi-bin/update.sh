#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix

set -euo pipefail

nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/oh-my-pi-bin/default.nix"

repo="can1357/oh-my-pi"

# Resolve the latest release tag (strip the leading "v" for the Nix version).
new_tag=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | jq -r .tag_name)
new_version="${new_tag#v}"

if [ -z "$new_version" ] || [ "$new_version" = "null" ]; then
    echo "Error: Could not resolve latest release tag" >&2
    exit 1
fi

old_version=$(sed -nE 's/^\s*version = "(.*)".*/\1/p' "$path")

if [[ "$old_version" == "$new_version" ]]; then
    echo "Current version $old_version is up-to-date"
    exit 0
fi

echo "Updating oh-my-pi-bin: $old_version -> $new_version"

base_url="https://github.com/${repo}/releases/download/v${new_version}"

get_hash() {
    nix store prefetch-file --json "$1" | jq -r .hash
}

sed -i "s/version = \"$old_version\"/version = \"$new_version\"/" "$path"

# system : release asset name
for pair in \
    "x86_64-linux:omp-linux-x64" \
    "aarch64-linux:omp-linux-arm64" \
    "x86_64-darwin:omp-darwin-x64" \
    "aarch64-darwin:omp-darwin-arm64"; do
    system="${pair%%:*}"
    asset="${pair#*:}"
    hash=$(get_hash "$base_url/$asset")
    sed -i "/$system = {/,/};/s|hash = \"sha256-[^\"]*\"|hash = \"$hash\"|" "$path"
done

echo "Updated oh-my-pi-bin: $old_version -> $new_version"

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix

set -euo pipefail

nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/oh-my-pi-bin/default.nix"

repo="can1357/oh-my-pi"

# Resolve the latest stable release tag. Prefer the GitHub API (optionally
# authenticated) but fall back to the HTML /releases/latest redirect so the
# script still works when unauthenticated API calls are rate-limited (403).
auth_args=()
token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -n "$token" ]; then
    auth_args=(-H "Authorization: Bearer ${token}")
fi

new_tag=""
if api_json=$(curl -fsSL "${auth_args[@]}" \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: oh-my-pi-bin-update" \
    "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null); then
    new_tag=$(jq -r '
        select(.draft | not)
        | select(.prerelease | not)
        | .tag_name // empty
    ' <<< "$api_json")
fi

if [ -z "$new_tag" ] || [ "$new_tag" = "null" ]; then
    # /releases/latest 302s to /releases/tag/<tag> for the newest stable release.
    effective=$(curl -fsSIL \
        -H "User-Agent: oh-my-pi-bin-update" \
        -o /dev/null -w '%{url_effective}' \
        "https://github.com/${repo}/releases/latest")
    new_tag=$(sed -nE 's|.*/tag/(v[^/?#]+)$|\1|p' <<< "$effective")
fi

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

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git curl jq prefetch-npm-deps nix-prefetch-github

set -eou pipefail

nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/open-webui-ztx888/default.nix"

new_version="$(curl --silent "https://api.github.com/repos/ztx888/open-webui/releases" | jq '.[0].tag_name' --raw-output)"
new_version="${new_version:1}"
old_version="$(sed -nE 's/^\s*version = "(.*)".*/\1/p' "$path")"

if [[ "$old_version" == "$new_version" ]]; then
    echo "Current version $old_version is up-to-date"
    exit 0
fi

echo "Updating open-webui-ztx888: $old_version -> $new_version"

new_hash="$(nix-prefetch-github ztx888 open-webui --rev "v${new_version}" | jq -r '.hash')"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl -sS -O --output-dir "$tmpdir" "https://raw.githubusercontent.com/ztx888/open-webui/refs/tags/v${new_version}/package-lock.json"
new_npm_hash=$(prefetch-npm-deps "$tmpdir/package-lock.json")

sed -i -e "s/version = \"$old_version\"/version = \"$new_version\"/" \
    -e "s|hash = \"sha256-[^\"]*\"|hash = \"$new_hash\"|" \
    -e "s|npmDepsHash = \"sha256-[^\"]*\"|npmDepsHash = \"$new_npm_hash\"|" "$path"

echo "Updated open-webui-ztx888: $old_version -> $new_version"

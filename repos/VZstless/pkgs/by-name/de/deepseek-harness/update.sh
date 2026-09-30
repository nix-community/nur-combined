#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nodejs prefetch-npm-deps nix

set -euo pipefail

dir="$(dirname "${BASH_SOURCE[0]}")"

if [[ ! -w "$dir" ]]; then
    echo "error: $dir is not writable -- this script seems to be running" >&2
    echo "       from a read-only store copy (e.g. via 'nix flake run .#update')." >&2
    echo "       Run it from your repository checkout instead:" >&2
    echo "       ./pkgs/by-name/de/deepseek-harness/update.sh" >&2
    exit 1
fi

pkg="@deepseek-ai/dsh"

version="$(curl -fsSL "https://registry.npmjs.org/${pkg//\//%2F}" | jq -r '."dist-tags".latest')"
current="$(sed -n 's/^  version = "\(.*\)";/\1/p' "$dir/package.nix")"

if [[ "$version" == "$current" ]]; then
    echo "deepseek-harness is already up-to-date ($version)"
    exit 0
fi

echo "Updating deepseek-harness $current -> $version"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "https://registry.npmjs.org/${pkg}/-/${pkg#@deepseek-ai/}-$version.tgz" \
    -o "$tmp/dsh.tgz"
tar xzf "$tmp/dsh.tgz" --strip-components=1 -C "$tmp"

(cd "$tmp" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund)

# -f so an existing read-only package-lock.json (mode 444) still gets replaced
cp -f "$tmp/package-lock.json" "$dir/package-lock.json"

srcHash="$(nix store prefetch-file --json "https://registry.npmjs.org/${pkg}/-/${pkg#@deepseek-ai/}-$version.tgz" | jq -r '.hash')"
npmDepsHash="$(prefetch-npm-deps "$dir/package-lock.json")"

sed -i \
    -e "s|^  version = \".*\";$|  version = \"$version\";|" \
    -e "s|dsh-.*\.tgz\"|dsh-$version.tgz\"|" \
    -e "s|^    hash = \".*\";$|    hash = \"$srcHash\";|" \
    -e "s|^  npmDepsHash = \".*\";$|  npmDepsHash = \"$npmDepsHash\";|" \
    "$dir/package.nix"

echo "Updated to $version"

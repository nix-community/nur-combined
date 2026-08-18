#!/usr/bin/env bash
# Point packaging/nix/package.nix at a released tag.
#
#   update.sh v0.1.3
#
# The hash fetchFromGitHub wants is of the unpacked tree, not of any tarball,
# so it cannot be worked out with sha256sum the way the AUR and winget ones
# can -- it has to come from Nix itself.
set -euo pipefail

tag="${1:?usage: update.sh <tag>}"
version="${tag#v}"
here="$(cd "$(dirname "$0")" && pwd)"
file="$here/package.nix"

command -v nix >/dev/null || { echo "this needs nix" >&2; exit 1; }

echo "prefetching MopigamesYT/moonlight-os at $tag"
hash="$(nix --extra-experimental-features 'nix-command flakes' \
	flake prefetch --json "github:MopigamesYT/moonlight-os/$tag" | grep -o '"hash":"[^"]*"' | head -1 | cut -d'"' -f4)"

[ -n "$hash" ] || { echo "could not prefetch a hash" >&2; exit 1; }

sed -i \
	-e "s|^  version = \".*\";|  version = \"$version\";|" \
	-e "s|    hash = \".*\";|    hash = \"$hash\";|" \
	"$file"

echo "package.nix -> $version, $hash"
grep -E '^  version|    hash' "$file"

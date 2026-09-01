#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ]]; then
  echo "usage: $0 vMAJOR.MINOR.PATCH" >&2
  exit 2
fi

tag="$1"
version="${tag#v}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
package="$root/packaging/nix/package.nix"
release_lock="$(mktemp)"
trap 'rm -f "$release_lock"' EXIT

curl --fail --location --silent --show-error \
  "https://raw.githubusercontent.com/moonlight-os/helios/$tag/package-lock.json" \
  --output "$release_lock"

source_json="$(nix shell nixpkgs#nix-prefetch-github nixpkgs#nix-prefetch-git \
  -c nix-prefetch-github moonlight-os helios --rev "$tag" --fetch-submodules)"
source_hash="$(jq -r .hash <<<"$source_json")"
npm_hash="$(nix run nixpkgs#prefetch-npm-deps -- "$release_lock")"

sed -i -E \
  -e "s/version = \"[^\"]+\";/version = \"$version\";/" \
  -e "/src = fetchFromGitHub \{/,/^  \};/s#hash = \"sha256-[^\"]+\";#hash = \"$source_hash\";#" \
  -e "s#npmDepsHash = \"sha256-[^\"]+\";#npmDepsHash = \"$npm_hash\";#" \
  "$package"

echo "package.nix -> $version"

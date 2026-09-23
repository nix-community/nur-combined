#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl gnugrep gnused gnutar gzip jq nix nix-prefetch-git nix-update
# shellcheck shell=bash
#
# Usage: update.sh [skia-bindings-version]
#
# rust-skia has to match the skia-bindings version its consumers lock, so by
# default the version is taken from sequin's Cargo.lock rather than crates.io.
# Updates the crate src/cargoHash, the rust-skia/skia fork tag, and
# externals.json (regenerated from that fork's DEPS file).

set -euo pipefail

dir="$(CDPATH="" cd "$(dirname "$0")" && pwd)"
pkg="$dir/package.nix"
# nix-update evaluates the package set in NixOS/default.nix
cd "$dir/../../.."

# Externals needed on Linux for the features we might build.
wanted=(expat harfbuzz icu libjpeg-turbo libpng libwebp vulkanmemoryallocator wuffs zlib)

old_vsn="$(grep --only-matching --perl-regexp '^  version = "\K[^"]+' "$pkg")"

if (($#)); then
  new_vsn=$1
else
  sequin_src="$(nix-build --no-out-link -A sequin.src)"
  new_vsn="$(grep -A1 '^name = "skia-bindings"$' "$sequin_src/Cargo.lock" |
    grep --only-matching --perl-regexp '^version = "\K[^"]+')"
fi

if [ "$old_vsn" = "$new_vsn" ]; then
  echo "rust-skia is already at $new_vsn, skipping"
  exit 0
fi

echo "rust-skia: $old_vsn -> $new_vsn"

# The Skia fork tag is recorded in the crate's [package.metadata].
skia_tag="$(curl -fsSL "https://static.crates.io/crates/skia-bindings/skia-bindings-$new_vsn.crate" |
  tar -xzO "skia-bindings-$new_vsn/Cargo.toml" |
  sed -n '/^\[package\.metadata\]/,/^\[/p' |
  grep --only-matching --perl-regexp '^skia = "\K[^"]+')"

skia_json="$(nix flake prefetch --json "github:rust-skia/skia/$skia_tag")"
skia_hash="$(jq -r .hash <<<"$skia_json")"
skia_src="$(jq -r .storePath <<<"$skia_json")"

echo "skia: $skia_tag ($skia_hash)"

sed -i \
  -e '/repo = "skia";/,/hash = / {
    s|tag = "[^"]*";|tag = "'"$skia_tag"'";|
    s|hash = "[^"]*";|hash = "'"$skia_hash"'";|
  }' \
  "$pkg"

json='{}'
for name in "${wanted[@]}"; do
  spec="$(grep --only-matching --perl-regexp \
    "^\s*\"third_party/externals/$name\"\s*:\s*\"\K[^\"]+" "$skia_src/DEPS")"
  url=${spec%@*}
  rev=${spec##*@}
  hash="$(nix-prefetch-git --quiet --url "$url" --rev "$rev" | jq -r .hash)"
  json="$(jq --arg n "$name" --arg u "$url" --arg r "$rev" --arg h "$hash" \
    '.[$n] = {url: $u, rev: $r, hash: $h}' <<<"$json")"
done
jq -S . <<<"$json" >"$dir/externals.json"

nix-update rust-skia --version "$new_vsn"

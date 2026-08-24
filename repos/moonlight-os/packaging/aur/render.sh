#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "usage: $0 vVERSION COMMIT BINARY_SHA256 GIT_VERSION OUTPUT_DIR" >&2
  exit 2
fi

tag="$1"
commit="$2"
binary_sha256="$3"
git_version="$4"
output="$5"
version="${tag#v}"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ]]; then
  echo "invalid release tag: $tag" >&2
  exit 2
fi
if [[ ! "$commit" =~ ^[0-9a-f]{40}$ ]]; then
  echo "invalid commit: $commit" >&2
  exit 2
fi
if [[ ! "$binary_sha256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "invalid binary SHA-256: $binary_sha256" >&2
  exit 2
fi

mkdir -p "$output/helios" "$output/helios-bin" "$output/helios-git"
cp "$here/helios.install" "$output/helios/helios.install"
cp "$here/helios.install" "$output/helios-bin/helios.install"
cp "$here/helios.install" "$output/helios-git/helios.install"

sed \
  -e "s/@VERSION@/$version/g" \
  -e "s/@COMMIT@/$commit/g" \
  "$here/PKGBUILD.source.in" > "$output/helios/PKGBUILD"
sed \
  -e "s/@VERSION@/$version/g" \
  -e "s/@BINARY_SHA256@/$binary_sha256/g" \
  "$here/PKGBUILD.bin.in" > "$output/helios-bin/PKGBUILD"
sed \
  -e "s/@GIT_VERSION@/$git_version/g" \
  "$here/PKGBUILD.git.in" > "$output/helios-git/PKGBUILD"

for package in helios helios-bin helios-git; do
  (cd "$output/$package" && makepkg --printsrcinfo > .SRCINFO)
done

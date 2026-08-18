#!/bin/sh
# Render the winget manifest templates for one release.
#
#   render.sh <tag> <dist-dir> [out-dir]
#
# <tag> is the git tag the release was published under (v2026.08.14); the
# winget PackageVersion is the same thing without the leading v, because
# winget sorts versions and a leading letter makes it sort them as strings.
#
# <dist-dir> holds the built binaries -- the hashes come from the files that
# were actually uploaded, never from a hash written down by hand.
set -eu

tag="${1:?usage: render.sh <tag> <dist-dir> [out-dir]}"
dist="${2:?usage: render.sh <tag> <dist-dir> [out-dir]}"
out="${3:-manifests}"

here="$(cd "$(dirname "$0")" && pwd)"
version="${tag#v}"
date="$(date -u +%Y-%m-%d)"

x64="$dist/mlos-host-utils-windows-amd64.exe"
arm64="$dist/mlos-host-utils-windows-arm64.exe"
for f in "$x64" "$arm64"; do
	[ -f "$f" ] || { echo "missing $f" >&2; exit 1; }
done

sha() { sha256sum "$1" | cut -d' ' -f1 | tr 'a-f' 'A-F'; }
sha_x64="$(sha "$x64")"
sha_arm64="$(sha "$arm64")"

# winget-pkgs wants manifests under manifests/<first letter, lowercased>/
# <Publisher>/<Package>/<Version>/.
dest="$out/m/MopigamesYT/MlosHostUtils/$version"
mkdir -p "$dest"

for src in "$here"/MopigamesYT.MlosHostUtils*.yaml; do
	sed -e "s|__VERSION__|$version|g" \
	    -e "s|__TAG__|$tag|g" \
	    -e "s|__RELEASE_DATE__|$date|g" \
	    -e "s|__SHA256_X64__|$sha_x64|g" \
	    -e "s|__SHA256_ARM64__|$sha_arm64|g" \
	    "$src" > "$dest/$(basename "$src")"
done

echo "rendered $version into $dest"
ls -1 "$dest"

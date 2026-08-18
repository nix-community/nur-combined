#!/bin/sh
# Render the AUR PKGBUILD for one release.
#
#   render.sh <tag> [out-dir]
#
# The checksum is taken from the tarball GitHub actually serves for the tag,
# downloaded here, rather than from anything built locally: what the AUR
# checks at install time is that URL, so that is the only file whose hash
# means anything.
set -eu

tag="${1:?usage: render.sh <tag> [out-dir]}"
out="${2:-build}"

here="$(cd "$(dirname "$0")" && pwd)"
version="${tag#v}"
url="https://github.com/MopigamesYT/moonlight-os/archive/refs/tags/$tag.tar.gz"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "fetching $url"
curl -fsSL -o "$tmp/src.tar.gz" "$url"
sum="$(sha256sum "$tmp/src.tar.gz" | cut -d' ' -f1)"

mkdir -p "$out"
sed -e "s|__VERSION__|$version|g" -e "s|__SHA256__|$sum|g" \
	"$here/PKGBUILD" > "$out/PKGBUILD"

echo "rendered $version into $out/PKGBUILD  (sha256 $sum)"

# .SRCINFO is what the AUR actually reads, and it has to agree with the
# PKGBUILD -- so it is generated from it, never written by hand.  makepkg
# refuses to run as root, which is why CI does this as a build user.
if command -v makepkg >/dev/null 2>&1; then
	(cd "$out" && makepkg --printsrcinfo > .SRCINFO)
	echo "generated $out/.SRCINFO"
else
	echo "makepkg not found: .SRCINFO not generated (run this on Arch, or in CI)" >&2
fi

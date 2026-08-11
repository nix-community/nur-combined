#! /bin/sh

dir="$(cd "$(dirname "$0")" && pwd)"
BUILDDIR="$dir/_build"
mkdir -p "$BUILDDIR"

packages="golang-github-biezhi-gorm-paginator pwngrid pwnagotchi"
export DEB_BUILD_OPTIONS=noautodbgsym

usage () {
    echo >&2 "Usage: $0 <$(echo "$packages" | tr ' ' '|')>"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

package="$1"
ok=
for p in $packages; do
    if [ "$p" = "$package" ]; then ok=1; break; fi
done
if [ -z "$ok" ]; then usage; fi

pkg_ver="$(dpkg-parsechangelog --file "$dir/$package/debian/changelog" --show-field Version)"
src_ver="${pkg_ver%-*}"
orig="${package}_${src_ver}.orig.tar.gz"

if ! [ -f "$dir/$orig" ]; then
    (cd "$dir/$package" && uscan --download-current-version)
fi

if ! [ -d "$BUILDDIR/$package-$src_ver" ]; then
    rm -rf "$BUILDDIR/$package-$src_ver"
    tar --extract --file "$orig" --strip-components=1 --one-top-level="$BUILDDIR/$package-$src_ver"
    if ! [ -d "$BUILDDIR/$package-$src_ver" ]; then
        echo "Error extracting package source - $BUILDDIR/$package-$src_ver doesn't exist"
        exit 1
    fi
fi

if ! [ -L "$BUILDDIR/$orig" ]; then
    ln -s "$dir/$orig" "$BUILDDIR/$orig"
fi

cp -a "$package/debian" "$BUILDDIR/$package-$src_ver"

(cd "$BUILDDIR/$package-$src_ver" && dpkg-buildpackage --no-sign)


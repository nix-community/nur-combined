#!/usr/bin/env bash
# Build binary packages from a source package, in a container, via debcraft.
# _build/ doubles as the local repository so packages can build against .debs
# produced earlier in the same run.
set -euo pipefail

pkg="$1"
dist="${2:-sid}"  # a codename: sid, trixie, noble, plucky, ...
top="$(cd "$(dirname "$0")/.." && pwd)"
build="${DEB_BUILD_DIR:-$top/_build}"

src="$(dpkg-parsechangelog --file "$top/pkgs/$pkg/debian/changelog" --show-field Source)"
ver="$(dpkg-parsechangelog --file "$top/pkgs/$pkg/debian/changelog" --show-field Version)"

"$(dirname "$0")/mksource.sh" "$pkg"

export CONTAINERS_REGISTRIES_CONF="$top/registries.conf"

# This repo does not publish dbgsym packages; debcraft forwards DEB* into the
# container.
export DEB_BUILD_OPTIONS="${DEB_BUILD_OPTIONS:+$DEB_BUILD_OPTIONS }noautodbgsym"

# debcraft mounts $PWD into the container and passes the target through as
# given, so the .dsc has to be named relative to the working directory.
cd "$build"

# --skip-sources: mksource.sh already made the source package, and rebuilding it
# in the container drops component tarballs debcraft does not stage.
exec debcraft build \
    --skip-sources \
    --distribution "$dist" \
    --build-dirs-path "$build" \
    --extra-repository "$build" \
    --release-to "$build" \
    "${src}_${ver}.dsc"

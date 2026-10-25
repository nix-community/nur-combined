#!/bin/sh
# Compile on Fedora or openSUSE; do not repackage an Arch/Ubuntu binary as RPM.
set -eu
cd "$(dirname "$0")/.."
for tool in cargo rpm rpmbuild; do
  command -v "$tool" >/dev/null || { echo "Missing build tool: $tool" >&2; exit 1; }
done
. /etc/os-release
case "$ID" in
  fedora) tag="fc$VERSION_ID" ;;
  opensuse-tumbleweed|opensuse-leap) tag="opensuse${VERSION_ID:-tumbleweed}" ;;
  *) echo 'Build this package on Fedora or openSUSE.' >&2; exit 1 ;;
esac
tag=$(printf '%s' "$tag" | tr -cd 'a-zA-Z0-9.')
version=$(sed -n 's/^version = "\([^"]*\)"/\1/p' Cargo.toml | head -1)
export CARGO_TARGET_DIR=target
host=$(rustc -vV | sed -n 's/^host: //p')
cargo build --release --locked --target "$host"
binary="$PWD/target/$host/release/spotlight"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
mkdir -p "$work/SOURCES" "$work/SPECS" "$work/BUILD" "$work/BUILDROOT" "$work/RPMS" "$work/SRPMS"
stage="$work/payload/spotlight-$version"
sh packaging/stage-linux.sh "$binary" "$stage"
tar -C "$work/payload" -czf "$work/SOURCES/spotlight-$version-payload.tar.gz" "spotlight-$version"
cp packaging/rpm/spotlight.spec "$work/SPECS/"
rpmbuild -bb --define "_topdir $work" --define "spotlight_version $version" \
  --define "dist .$tag" "$work/SPECS/spotlight.spec"
mkdir -p dist
found=false
for package in "$work"/RPMS/*/spotlight-*.rpm; do
  [ -f "$package" ] || continue
  cp "$package" dist/
  found=true
done
[ "$found" = true ] || { echo 'rpmbuild produced no package' >&2; exit 1; }

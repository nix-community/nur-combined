#!/bin/sh
# Build on the target Debian/Ubuntu release so dependency versions are accurate.
set -eu
cd "$(dirname "$0")/.."
for tool in cargo dpkg dpkg-deb dpkg-shlibdeps; do
  command -v "$tool" >/dev/null || { echo "Missing build tool: $tool" >&2; exit 1; }
done
. /etc/os-release
case "$ID" in ubuntu|debian) ;; *) echo 'Build this package on Ubuntu or Debian.' >&2; exit 1 ;; esac
version=$(sed -n 's/^version = "\([^"]*\)"/\1/p' Cargo.toml | head -1)
arch=$(dpkg --print-architecture)
case "$arch" in amd64|arm64) ;; *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; esac
suffix=$(printf '%s%s' "$ID" "$VERSION_ID" | tr -cd 'a-zA-Z0-9.')
package_version="$version-1+$suffix"
export CARGO_TARGET_DIR=target
host=$(rustc -vV | sed -n 's/^host: //p')
cargo build --release --locked --target "$host"
binary="$PWD/target/$host/release/spotlight"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
stage="$work/stage"
sh packaging/stage-linux.sh "$binary" "$stage"
# dpkg-shlibdeps needs a source control context to consult native symbols/shlibs.
mkdir -p "$work/debian"
cat > "$work/debian/control" <<'CONTROL'
Source: spotlight
Section: utils
Priority: optional
Maintainer: Danny <danny19862025@users.noreply.github.com>
Standards-Version: 4.7.0

Package: spotlight
Architecture: any
Description: Keyboard-first native Linux productivity launcher
CONTROL
deps=$(cd "$work" && dpkg-shlibdeps -O -e"$stage/usr/lib/spotlight/spotlight")
deps=$(printf '%s\n' "$deps" | sed -n 's/^shlibs:Depends=//p')
[ -n "$deps" ] || { echo 'Could not determine shared-library dependencies' >&2; exit 1; }
mkdir -p "$stage/DEBIAN"
cat > "$stage/DEBIAN/control" <<CONTROL
Package: spotlight
Version: $package_version
Section: utils
Priority: optional
Architecture: $arch
Maintainer: Danny <danny19862025@users.noreply.github.com>
Installed-Size: $(du -sk "$stage/usr" | cut -f1)
Depends: $deps, libgtk-4-1 (>= 4.10)
Suggests: python3, curl, ripgrep, xdg-utils, wl-clipboard, tesseract-ocr, keepassxc, gnupg, dnsutils, iputils-ping, iproute2, network-manager, plasma-workspace
Homepage: https://github.com/danny19862025/spotlight
Description: Keyboard-first native Linux productivity launcher
 Search applications and files, calculate, and manage notes and snippets.
 KDE-specific integrations require their corresponding desktop services.
CONTROL
mkdir -p dist
dpkg-deb --root-owner-group --build "$stage" "dist/spotlight_${package_version}_${arch}.deb"
printf 'Created dist/spotlight_%s_%s.deb\n' "$package_version" "$arch"

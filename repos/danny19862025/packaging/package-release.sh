#!/bin/sh
# Package an already-built binary. Never include runtime data or a working tree.
set -eu
cd "$(dirname "$0")/.."
[ "$#" -le 1 ] || { echo 'Usage: packaging/package-release.sh [target-triple]' >&2; exit 2; }
triple=${1:-$(rustc -vV | sed -n 's/^host: //p')}
case "$triple" in
    x86_64-unknown-linux-gnu|aarch64-unknown-linux-gnu) ;;
    *) echo "Unsupported release target: $triple" >&2; exit 2 ;;
esac
version=$(sed -n 's/^version = "\([^"]*\)"/\1/p' Cargo.toml | head -1)
binary=${SPOTLIGHT_BINARY:-target/release/spotlight}
[ -x "$binary" ] || { echo "Build $binary first with cargo build --release --locked" >&2; exit 1; }
name="spotlight-$version-$triple"
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT HUP INT TERM
root="$stage/$name"
mkdir -p "$root/bin" "$root/lib/spotlight" "$root/share/applications" \
    "$root/share/icons/hicolor/scalable/apps" "$root/share/licenses/spotlight"
install -m755 "$binary" "$root/lib/spotlight/spotlight"
cat > "$root/bin/spotlight" <<'LAUNCHER'
#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export GSK_RENDERER=cairo
exec "$root/lib/spotlight/spotlight" "$@"
LAUNCHER
chmod 755 "$root/bin/spotlight"
install -m644 docs/community-plugins.toml "$root/lib/spotlight/"
install -m644 packaging/spotlight.desktop "$root/share/applications/"
install -m644 assets/spotlight.svg "$root/share/icons/hicolor/scalable/apps/"
install -m644 LICENSE assets/UNICODE-LICENSE.txt assets/QRCODEGEN-LICENSE.txt "$root/share/licenses/spotlight/"
install -m644 docs/PACKAGING.md "$root/INSTALL.md"
mkdir -p dist
tar -C "$stage" -czf "dist/$name.tar.gz" "$name"
(cd dist && sha256sum "$name.tar.gz" > "$name.tar.gz.sha256")
printf 'Created dist/%s.tar.gz\n' "$name"

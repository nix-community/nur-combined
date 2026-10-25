#!/bin/sh
# Stage only distributable files; never copy a user's configuration or working tree.
set -eu
[ "$#" -eq 2 ] || { echo 'Usage: stage-linux.sh BINARY ABSOLUTE_DESTDIR' >&2; exit 2; }
binary=$1
root=$2
case "$root" in /*) ;; *) echo 'DESTDIR must be absolute' >&2; exit 2 ;; esac
[ "$root" != / ] || { echo 'Refusing to stage into /' >&2; exit 2; }
[ -f "$binary" ] && [ -x "$binary" ] || { echo "Missing executable: $binary" >&2; exit 1; }
binary=$(CDPATH= cd -- "$(dirname -- "$binary")" && pwd)/$(basename -- "$binary")
cd "$(dirname "$0")/.."
install -Dm755 "$binary" "$root/usr/lib/spotlight/spotlight"
install -dm755 "$root/usr/bin"
cat > "$root/usr/bin/spotlight" <<'LAUNCHER'
#!/bin/sh
export GSK_RENDERER=cairo
exec /usr/lib/spotlight/spotlight "$@"
LAUNCHER
chmod 755 "$root/usr/bin/spotlight"
install -Dm644 docs/community-plugins.toml "$root/usr/lib/spotlight/community-plugins.toml"
install -Dm644 packaging/spotlight.desktop "$root/usr/share/applications/spotlight.desktop"
install -Dm644 assets/spotlight.svg "$root/usr/share/icons/hicolor/scalable/apps/spotlight.svg"
for license in LICENSE assets/UNICODE-LICENSE.txt assets/QRCODEGEN-LICENSE.txt; do
  install -Dm644 "$license" "$root/usr/share/licenses/spotlight/${license##*/}"
done
install -Dm644 LICENSE "$root/usr/share/doc/spotlight/copyright"

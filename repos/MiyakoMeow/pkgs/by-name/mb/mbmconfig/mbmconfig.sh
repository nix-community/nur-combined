#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="@out@/share/mbmconfig"
APP_DIR="$APP_ROOT/mBMconfig"
WINE_PACKAGE="@wineWow64Packages@"

BASE_DATA_DIR="${XDG_DATA_HOME:-"$HOME/.local/share"}"
USER_DATA="$BASE_DATA_DIR/mbmconfig"

export WINEDEBUG=-all
export WINEARCH=win64
export WINEPREFIX="${MBMCONFIG_HOME:-"$USER_DATA/wine"}"
export PATH="${WINE_PACKAGE}/bin:$PATH"

mkdir -p "$USER_DATA"

if [ ! -d "$WINEPREFIX" ]; then
  wineboot -u 2>/dev/null || true
fi

export WINEDLLOVERRIDES="mscoree,mshtml=d"
MONO_DIR="${WINE_PACKAGE}/share/wine/mono"
MONO_MSI=$(find "$MONO_DIR" -maxdepth 1 -name "wine-mono-*.msi" -print -quit 2>/dev/null || true)
if [ -n "$MONO_MSI" ] && [ ! -d "$WINEPREFIX/drive_c/windows/mono" ]; then
  wine msiexec /i "$MONO_MSI" /qn 2>/dev/null || true
fi
export WINEDLLOVERRIDES="mshtml="

RUNTIME_DIR=$(mktemp -d -t mbmconfig.XXXXXX)

cleanup() {
  rm -rf "$RUNTIME_DIR"
}
trap cleanup EXIT

cp -r "$APP_DIR"/. "$RUNTIME_DIR"/
chmod -R u+rwX "$RUNTIME_DIR"

if [ -f "$APP_DIR/mBMconfig.exe.config" ]; then
  if [ ! -f "$USER_DATA/mBMconfig.exe.config" ] || [ -L "$USER_DATA/mBMconfig.exe.config" ]; then
    rm -f "$USER_DATA/mBMconfig.exe.config"
    cp "$APP_DIR/mBMconfig.exe.config" "$USER_DATA/mBMconfig.exe.config"
  fi
  cp -f "$USER_DATA/mBMconfig.exe.config" "$RUNTIME_DIR/mBMconfig.exe.config"
fi

for item in "$USER_DATA"/*; do
  [ -e "$item" ] || continue
  name="$(basename "$item")"
  [ "$name" = "mBMconfig.exe.config" ] && continue
  [ -e "$RUNTIME_DIR/$name" ] && rm -rf "$RUNTIME_DIR/$name"
  if [ -d "$item" ]; then
    ln -sfT "$item" "$RUNTIME_DIR/$name"
  else
    ln -sf "$item" "$RUNTIME_DIR/$name"
  fi
done

cd "$RUNTIME_DIR"
wine "mBMconfig.exe" "$@"

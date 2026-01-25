#!/usr/bin/env bash
set -euo pipefail

# mBMplay 启动脚本
# 使用 Wine 运行 mBMplay，支持 .NET 应用

APP_ROOT="@out@/share/mbmplay"
APP_DIR="$APP_ROOT/mBMplay"
WINE_PACKAGE="@wine64Packages@"

BASE_DATA_DIR="${XDG_DATA_HOME:-"$HOME/.local/share"}"
USER_DATA="$BASE_DATA_DIR/mbmplay"

export WINEDEBUG=-all
export WINEARCH=win64
export WINEPREFIX="${MBMPLAY_HOME:-"$USER_DATA/wine"}"
export PATH="${WINE_PACKAGE}/bin:$PATH"

# 创建用户数据目录
mkdir -p "$USER_DATA"

# 初始化 wine 前缀（如果不存在）
if [ ! -d "$WINEPREFIX" ]; then
  wineboot -u 2>/dev/null || true
fi

# 提供快速烟雾测试：仅验证脚本与目录准备是否正常
if [ "$(printenv MBMPLAY_SMOKE)" = "1" ]; then
  echo "mbmplay smoke-ok"
  exit 0
fi

# 禁用内置 mscoree/mshtml 以便安装 wine-mono
export WINEDLLOVERRIDES="mscoree,mshtml=d"

# 初始化前缀并安装 wine-mono（仅在未安装时执行）
MONO_DIR="${WINE_PACKAGE}/share/wine/mono"
MONO_MSI=$(find "$MONO_DIR" -maxdepth 1 -name "wine-mono-*.msi" -print -quit 2>/dev/null || true)
if [ -n "$MONO_MSI" ] && [ ! -d "$WINEPREFIX/drive_c/windows/mono" ]; then
  wine msiexec /i "$MONO_MSI" /qn 2>/dev/null || true
fi

# 允许 mshtml，避免影响程序内嵌浏览器行为
export WINEDLLOVERRIDES="mshtml="

# 创建运行时目录（可写的临时目录，用于程序运行）
RUNTIME_DIR=$(mktemp -d -t mbmplay.XXXXXX)

cleanup() {
  rm -rf "$RUNTIME_DIR"
}
trap cleanup EXIT

# 复制应用文件到运行时目录
cp -r "$APP_DIR"/. "$RUNTIME_DIR"/
chmod -R u+rwX "$RUNTIME_DIR"

# 将用户数据目录中的文件链接到运行时目录
for item in "$USER_DATA"/*; do
  [ -e "$item" ] || continue
  name="$(basename "$item")"
  [ -e "$RUNTIME_DIR/$name" ] && rm -rf "$RUNTIME_DIR/$name"
  if [ -d "$item" ]; then
    ln -sfT "$item" "$RUNTIME_DIR/$name"
  else
    ln -sf "$item" "$RUNTIME_DIR/$name"
  fi
done

cd "$RUNTIME_DIR"
wine "mBMplay.exe" "$@"

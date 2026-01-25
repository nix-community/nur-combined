#!/usr/bin/env bash
set -euo pipefail

# pBMSC 启动脚本
# 使用 Wine 运行 pBMSC，支持 .NET 应用
#
# 文件打开提示：Wine文件对话框无法默认显示隐藏文件。
# 建议通过以下方式打开文件：
# 1. 直接从系统文件管理器拖拽文件到程序窗口
# 2. 在文件对话框中手动点击"显示隐藏文件"按钮

APP_ROOT="@out@/share/pbmsc"
APP_DIR="$APP_ROOT"
WINE_PACKAGE="@wineWow64Packages@"

BASE_DATA_DIR="${XDG_DATA_HOME:-"$HOME/.local/share"}"
USER_DATA="$BASE_DATA_DIR/pbmsc"

export WINEDEBUG=-all
export WINEARCH=win64
export WINEPREFIX="${PBMSC_HOME:-"$USER_DATA/wine"}"
export PATH="${WINE_PACKAGE}/bin:$PATH"

# 创建用户数据目录
mkdir -p "$USER_DATA"

# 初始化 wine 前缀（如果不存在）
if [ ! -d "$WINEPREFIX" ]; then
  wineboot -u 2>/dev/null || true
fi

# 提供快速烟雾测试：仅验证脚本与目录准备是否正常
if [ "$(printenv PBMSC_SMOKE)" = "1" ]; then
  echo "pbmsc smoke-ok"
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
RUNTIME_DIR=$(mktemp -d -t pbmsc.XXXXXX)

cleanup() {
  local EXCLUDE_PATTERNS=("*.tmp" "*.temp" "*.cache" "*.log" "*.bak" "*.old" "*~" "*.lock" "*.swp")

  # 同步运行时中新增的文件和目录到用户数据
  find "$RUNTIME_DIR" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d $'\0' item; do
    name="$(basename "$item")"
    skip=false

    # 跳过临时和不需要持久化的文件
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
      case "$name" in
        $pattern) skip=true; break ;;
      esac
    done

    [ "$skip" = true ] && continue
    
    if [ -f "$item" ]; then
      if [ ! -f "$APP_DIR/$name" ]; then
        cp -f "$item" "$USER_DATA/" 2>/dev/null || true
      fi
    elif [ -d "$item" ]; then
      if [ "$name" != "wineprefix" ] && [ ! -d "$USER_DATA/$name" ]; then
        cp -r --no-preserve=all "$item" "$USER_DATA/$name" 2>/dev/null || true
      fi
    fi
  done
  rm -rf "$RUNTIME_DIR"
}
trap cleanup EXIT

# 复制应用文件到运行时目录
cp -r "$APP_DIR"/. "$RUNTIME_DIR"/
chmod -R u+rwX "$RUNTIME_DIR"

# 确保 pBMSC.exe.config 文件作为独立副本存在
if [ -f "$APP_DIR/pBMSC.exe.config" ]; then
  if [ ! -f "$USER_DATA/pBMSC.exe.config" ] || [ -L "$USER_DATA/pBMSC.exe.config" ]; then
    rm -f "$USER_DATA/pBMSC.exe.config"
    cp "$APP_DIR/pBMSC.exe.config" "$USER_DATA/pBMSC.exe.config"
  fi
  cp -f "$USER_DATA/pBMSC.exe.config" "$RUNTIME_DIR/pBMSC.exe.config"
fi

# 将用户数据目录中的文件和目录链接到运行时目录（跳过配置文件，已单独处理）
for item in "$USER_DATA"/*; do
  [ -e "$item" ] || continue
  name="$(basename "$item")"
  [ "$name" = "pBMSC.exe.config" ] && continue
  [ -e "$RUNTIME_DIR/$name" ] && rm -rf "$RUNTIME_DIR/$name"
  if [ -d "$item" ]; then
    # macOS 不支持 ln -sfT，使用 -n 替代
    ln -sfn "$item" "$RUNTIME_DIR/$name"
  else
    ln -sf "$item" "$RUNTIME_DIR/$name"
  fi
done

cd "$RUNTIME_DIR"
wine "pBMSC.exe" "$@"

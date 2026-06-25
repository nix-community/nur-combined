#!/usr/bin/env bash
#
# 把 caddy-with-plugins 的插件版本同步到各自最新，再委托
# scripts/update-caddy-hash.sh 回填 vendor hash。
#
# 版本来源：统一走 Go module proxy 的 @latest 端点——有 tag 的模块返回最新 tag，
# 无 tag 的模块（如 caddy-tailscale）返回默认分支 HEAD 的 pseudo-version。
# 主用 proxy.golang.org，失败回退 goproxy.cn。
#
# 模块列表从 pkgs/caddy-with-plugins/default.nix 的 plugins 数组解析，
# 不在此硬编码，保持单一来源。
#
# 依赖：curl、jq、nix-build（回填 hash 时需要）。
#
# 用法:
#   scripts/update-caddy-plugins.sh            # 同步版本并刷新 hash
#   scripts/update-caddy-plugins.sh --dry-run  # 只打印 old -> new，不写文件、不构建

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_FILE="$SCRIPT_DIR/../pkgs/caddy-with-plugins/default.nix"
HASH_SCRIPT="$SCRIPT_DIR/update-caddy-hash.sh"

# 版本解析用的 proxy（依次尝试，首个成功即用）
PROXIES=( "https://proxy.golang.org" "https://goproxy.cn" )

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# 从 PKG_FILE 的 plugins 数组里解析出 module path（双引号包裹的 "owner/x@ver"）。
mapfile -t modules < <(
  grep -oE '"github\.com/[^"]+@[^"]+"' "$PKG_FILE" \
    | sed -E 's/^"//; s/@.*//' \
    | sort -u
)

if [ "${#modules[@]}" -eq 0 ]; then
  echo "no plugins found in $PKG_FILE"
  exit 1
fi

# module -> 最新版本（有 tag 返回最新 tag；无 tag 返回 HEAD 的 pseudo-version）
latest_version() {
  local module="$1" proxy ver
  for proxy in "${PROXIES[@]}"; do
    ver=$(curl -fsSL --max-time 15 "${proxy}/${module}/@latest" 2>/dev/null \
      | jq -r '.Version // empty' 2>/dev/null || true)
    [ -n "$ver" ] && { echo "$ver"; return 0; }
  done
  return 1
}

# module -> PKG_FILE 中当前的版本串（只看双引号包裹的 plugin 条目，忽略注释）
current_version() {
  local module="$1"
  grep -oE "\"${module//./\\.}@[^\"]+\"" "$PKG_FILE" | head -1 \
    | sed -E "s|^\"${module//./\\.}@||; s|\"$||"
}

# module newver -> 把 PKG_FILE 里双引号包裹的 `"module@<任意>"` 版本段替换为 newver
set_version() {
  local module="$1" newver="$2"
  sed -i -E "s|(\"${module//./\\.}@)[^\"]+|\1${newver}|" "$PKG_FILE"
}

echo "syncing latest plugin versions -> $PKG_FILE  (dry-run=$DRY_RUN)"
changed=0
for module in "${modules[@]}"; do
  cur="$(current_version "$module")"
  if ! latest="$(latest_version "$module")"; then
    echo "  [skip] $module: 无法解析最新版本（当前 $cur）"
    continue
  fi
  if [ "$cur" = "$latest" ]; then
    echo "  [ok]   $module: $cur（已是最新）"
  else
    echo "  [upd]  $module: $cur -> $latest"
    [ "$DRY_RUN" -eq 0 ] && set_version "$module" "$latest"
    changed=1
  fi
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo
  echo "dry-run: 未写文件、未刷新 hash"
  exit 0
fi

# 无条件刷新：caddy 自身版本随 nixpkgs（`nix flake update`）变化，与插件是否更新无关。
echo
echo "刷新 vendor hash via scripts/update-caddy-hash.sh"
"$HASH_SCRIPT"

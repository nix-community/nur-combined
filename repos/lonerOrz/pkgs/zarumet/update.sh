#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Package metadata（必须配置）
# =============================================================================

owner="Immelancholy"
repo="Zarumet"
pname="zarumet"

PKG_FILE="default.nix"
BUILD_TARGET=".#${pname}"

# 需要更新的 hash 列表（顺序即 build 顺序，必须满足依赖拓扑）
HASH_KEYS=(hash cargoHash)

DUMMY_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# =============================================================================
# 路径
# =============================================================================

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/$PKG_FILE"

# 临时工作目录（不污染仓库）
workdir="$(mktemp -d)"
build_log="$workdir/build.log"

# =============================================================================
# （可选）预处理钩子（必须在更新 rev 之前）
# =============================================================================

pre_update_hook() {
  :
}

# =============================================================================
# 回退机制（任何失败都回滚）
# =============================================================================

backup="$(mktemp)"
cp "$package_file" "$backup"

rollback() {
  echo "❌ 更新失败，回滚 $PKG_FILE"
  cp "$backup" "$package_file"
}
trap rollback EXIT

# =============================================================================
# 0️⃣ 检查是否需要更新（必须是第一阶段）
# =============================================================================

echo "🔍 Checking latest upstream revision"

# 使用 github-rev-fetch.sh 获取最新 commit（支持 GITHUB_TOKEN 认证避免限流）
latest_rev="$(
  "$script_dir/../../.github/script/github-rev-fetch.sh" "$owner/$repo"
)"

if [[ -z "$latest_rev" ]]; then
  echo "❌ 无法获取远端仓库信息"
  exit 1
fi

current_rev="$(
  grep -oP 'rev\s*=\s*"\K[^"]+' "$package_file" || true
)"

if [[ "$latest_rev" == "$current_rev" ]]; then
  echo "✅ 已是最新版本，无需更新"
  trap - EXIT
  rm -f "$backup"
  rm -rf "$workdir"
  exit 0
fi

echo "⬆️ 发现更新"
echo "  current: $current_rev"
echo "  latest : $latest_rev"

# =============================================================================
# 1️⃣ pre_update_hook（在 rev 变化之前）
# =============================================================================

pre_update_hook

# =============================================================================
# 2️⃣ 更新 rev
# =============================================================================

sed -i -E \
  "s|(rev\s*=\s*\")[^\"]*(\")|\1$latest_rev\2|" \
  "$package_file"

# =============================================================================
# 3️⃣ 逐个 hash 获取（逐次收敛，一 build 一 hash）
# =============================================================================
# 语义保证：
#   - 每一轮 build 都运行在“之前 hash 已修复”的表达式之上
#   - 支持 hash = "" / hash = "..." 两种状态
#   - 对 buildRustPackage 是合法且正确的
# =============================================================================

for key in "${HASH_KEYS[@]}"; do
  echo "🧪 Updating hash: $key"

  # 1️⃣ 写入 dummy（允许空值，字段级锚定）
  sed -i -E \
    "s|(^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\")[^\"]*(\"[[:space:]]*;)|\1${DUMMY_HASH}\2|" \
    "$package_file"

  # 2️⃣ 触发 FOD mismatch
  if nix build "$BUILD_TARGET" 2>"$build_log"; then
    echo "❌ 预期失败但构建成功（hash 未生效）"
    exit 1
  fi

  # 3️⃣ 从 build log 提取真实 hash
  new_hash="$(
    grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' "$build_log" | head -n1 || true
  )"

  if [[ -z "$new_hash" ]]; then
    echo "❌ 未能提取 $key"
    tail -n20 "$build_log"
    exit 1
  fi

  echo "✔ $key = $new_hash"

  # 4️⃣ 回填真实 hash（同样字段级锚定）
  sed -i -E \
    "s|(^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\")${DUMMY_HASH}(\"[[:space:]]*;)|\1${new_hash}\2|" \
    "$package_file"
done

# =============================================================================
# 4️⃣ 最终验证
# =============================================================================

# echo "🏁 Final build verification"
# nix build "$BUILD_TARGET"

# =============================================================================
# 成功
# =============================================================================

trap - EXIT
rm -f "$backup"
rm -rf "$workdir"

echo "✅ Update finished successfully"

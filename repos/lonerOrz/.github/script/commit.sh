#!/usr/bin/env bash
set -euo pipefail

# DEBUG=1 ./script.sh 时才启用 xtrace
[ "${DEBUG:-}" = "1" ] && set -x

# -----------------------------------------------------------------------------
# 本脚本用于：
# 1. 自动检测 pkgs/ 下发生变化的包
# 2. 按优先级判断变化类型并生成合理的 commit message
#
# 优先级：
#   1️⃣ passthru.versionPolicy.file（generated / 特殊包）
#   2️⃣ version 变化
#   3️⃣ rev / tag 变化
#   4️⃣ internal changes（兜底）
# -----------------------------------------------------------------------------

# 清空暂存区，确保后续提交完全由脚本控制
git reset HEAD >/dev/null 2>&1 || true

# 获取 pkgs/ 下发生变化的包名（一级目录）
changed_pkgs=$(
  git diff --name-only --relative pkgs/ \
    | awk -F/ '{print $2}' \
    | sort -u || true
)

# 如果没有检测到任何包变化，直接退出
if [ -z "$changed_pkgs" ]; then
  echo "没有检测到 pkgs 下的改动"
  exit 0
fi

# 遍历每一个发生变化的包
for pkg in $changed_pkgs; do
  dir="pkgs/$pkg"

  # 如果目录不存在（例如被删除），跳过
  [ -d "$dir" ] || continue

  echo "处理包: $pkg"

  # ---------------------------------------------------------------------------
  # 1️⃣ 检测 passthru.versionPolicy.file
  #
  # 语义：
  #   - 该字段存在，说明这是一个 generated / 特殊包
  #   - 不解析具体版本，只要指定文件变化就提交
  # ---------------------------------------------------------------------------
  policy_file=""
  policy_file=$(nix eval --raw ".#${pkg}.passthru.versionPolicy.file" 2>/dev/null || true)

  if [ -n "$policy_file" ] && [ -f "$dir/$policy_file" ]; then
    if git diff --name-only HEAD -- "$dir/$policy_file" | grep -q .; then
      msg="$pkg: update sources (generated)"
      echo "$msg"

      git add "$dir/$policy_file"
      if ! git diff --cached --quiet; then
        git commit -m "$msg"
      fi
      # 已处理，直接进入下一个包
      continue
    fi
  fi

  # ---------------------------------------------------------------------------
  # 2️⃣ 常规包：优先检查 version 是否变化
  #
  # 只检查 default.nix 中的 version
  # ---------------------------------------------------------------------------
  version_file="$dir/default.nix"

  if [ -f "$version_file" ]; then
    if git diff HEAD -- "$version_file" | grep -qE '^[+-].*version\s*='; then
      old_version=$(
        git show HEAD:"$version_file" 2>/dev/null \
          | awk -F'"' '/version\s*=/ {v=$2} END{print v}'
      )
      new_version=$(
        awk -F'"' '/version\s*=/ {v=$2} END{print v}' "$version_file"
      )

      if [ -n "$old_version" ] && [ -n "$new_version" ] && [ "$old_version" != "$new_version" ]; then
        msg="$pkg: $old_version -> $new_version"
      else
        msg="$pkg: version changed"
      fi

      echo "$msg"
      git add "$dir"
      if ! git diff --cached --quiet; then
        git commit -m "$msg"
      fi
      continue
    fi
  fi

  # ---------------------------------------------------------------------------
  # 3️⃣ version 未变，检查 rev / tag 是否变化
  #
  # 适用于跟踪 git snapshot / tag 的包
  # ---------------------------------------------------------------------------
  if [ -f "$version_file" ]; then
    if git diff HEAD -- "$version_file" | grep -qE '^[+-][[:space:]]*(rev|tag)\s*='; then
      old_value=$(
        git show HEAD:"$version_file" 2>/dev/null \
          | grep -E '^[[:space:]]*(rev|tag)\s*=' \
          | tail -n1 \
          | sed -E 's/.*"([^"]+)".*/\1/' || true
      )

      new_value=$(
        grep -E '^[[:space:]]*(rev|tag)\s*=' "$version_file" \
          | tail -n1 \
          | sed -E 's/.*"([^"]+)".*/\1/' || true
      )

      # 如果是 commit hash，仅显示前 7 位
      old_short="${old_value:0:7}"
      new_short="${new_value:0:7}"

      msg="$pkg: ${old_short:-changed} -> ${new_short:-changed}"
      echo "$msg"

      git add "$dir"
      if ! git diff --cached --quiet; then
        git commit -m "$msg"
      fi
      continue
    fi
  fi

  # ---------------------------------------------------------------------------
  # 4️⃣ 兜底：既不是 version / rev / tag / generated
  #
  # 统一认为是内部实现变更
  # ---------------------------------------------------------------------------
  if git diff --name-only HEAD -- "$dir" | grep -q .; then
    msg="$pkg: internal changes"
    echo "$msg"

    git add "$dir"
    if ! git diff --cached --quiet; then
      git commit -m "$msg"
    fi
  fi
done

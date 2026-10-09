#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# 为 pkgs/ 下发生变化的包自动生成 commit。
#
# 版本检测：
#   直接读 nix 在「真实平台」上算出的 .version 属性，与版本存在哪个文件、
#   以什么格式书写完全无关 —— 未来新增任何 xxx.nix 存版本都无需加特例。
#
#   真实平台 = flake.nix 的 systems ∩ 包的 meta.platforms
#   （例：qq 的 flake 只支持 linux，darwin 不会被 eval，也不会污染消息）
#
#   快照方式：
#     before = 指向 HEAD 的临时 worktree 内 eval（一次建好，循环提交也不受影响）
#     after  = 当前工作树 eval
#   逐平台比较，仅列出真正变化的平台。
#
#   版本变化消息：pkg(平台): old -> new；多平台以 "; " 分隔。
#   无逐平台版本语义时（hash/rev 变更、新包）沿用整包口径：pkg: ...
#
#   兜底：nix 不把 src.rev 暴露成属性，故 rev/tag/hash 仍走文件级检测。
# -----------------------------------------------------------------------------
set -euo pipefail

[ "${DEBUG:-}" = "1" ] && set -x

git reset HEAD >/dev/null 2>&1 || true

REPO_ROOT="$(git rev-parse --show-toplevel)"
DEFAULT_NIX="$REPO_ROOT/default.nix"
FLAKE_NIX="$REPO_ROOT/flake.nix"

# 解析 flake.nix 的 `systems = [ ... ];`；解析失败兜底两个常见平台
get_flake_systems() {
  local s
  s=$(awk '
    /^[[:space:]]*systems[[:space:]]*=[[:space:]]*\[/ { inb = 1; next }
    inb && /\]/ { exit }
    inb {
      gsub(/^[[:space:]]*|[[:space:]]*$/, "")
      gsub(/"/, "")
      if ($0 != "") print $0
    }
  ' "$FLAKE_NIX")
  if [ -z "$s" ]; then
    echo "x86_64-linux"
    echo "aarch64-linux"
  else
    echo "$s"
  fi
}

# 在指定仓库根 $3、指定平台 $2 上 eval 包的 version；失败返回空
eval_version() {
  local pkg="$1" sys="$2" root="$3"
  nix eval --raw --impure --system "$sys" -f "$root/default.nix" "${pkg}.version" 2>/dev/null || true
}

# 取包声明的 meta.platforms（一行一个）；失败或无声明返回空
eval_pkg_platforms() {
  nix eval --json --impure --system x86_64-linux -f "$DEFAULT_NIX" "${1}.meta.platforms" 2>/dev/null \
    | jq -r '.[]? // empty' 2>/dev/null || true
}

# 交集：从 stdin 读集合 A（一行一个），与文件 $1 中的集合 B 求交
intersection() {
  local f="$1"
  while IFS= read -r a; do
    [ -z "$a" ] && continue
    grep -qxF "$a" "$f" 2>/dev/null && echo "$a"
  done || true
}

short() {
  local s="$1"
  [ -n "$s" ] && echo "${s:0:9}" || echo "-"
}

# 文件级 rev/tag 检测：优先 JSON（rev/tag 字段），否则 Nix 字面量；找不到返回空
rev_of() {
  jq -r '.rev // .tag // empty' "$1" 2>/dev/null \
    || awk '/^[[:space:]]*(rev|tag)[[:space:]]*=[[:space:]]*"/ {
      v = $0; sub(/.*[=][[:space:]]*"/, "", v); sub(/".*/, "", v); print v; exit
    }' "$1" 2>/dev/null
}

# 收集变化的包（一级目录）：已跟踪改动 + 未跟踪新目录
changed_pkgs=$(
  {
    git diff --name-only --relative pkgs/ 2>/dev/null
    git ls-files --others --exclude-standard -- pkgs/ 2>/dev/null
  } \
    | awk -F/ 'NF >= 2 { print $2 }' \
    | sort -u || true
)

if [ -z "$changed_pkgs" ]; then
  echo "没有检测到 pkgs 下的改动"
  exit 0
fi

FLAKE_SYS_FILE="$(mktemp)"
get_flake_systems > "$FLAKE_SYS_FILE"

# before 快照：一次性建一个指向 HEAD 的临时 worktree，独立且不受循环提交影响
WT="$(mktemp -d)"
if ! git worktree add -q "$WT" HEAD 2>/dev/null; then
  WT=""
fi
cleanup() {
  [ -n "$WT" ] && git worktree remove --force "$WT" >/dev/null 2>&1 || true
  rm -f "$FLAKE_SYS_FILE" "$PKG_SYS_FILE" "$REAL_SYS_FILE" "${OLD_F:-}"
}
trap cleanup EXIT

for pkg in $changed_pkgs; do
  dir="pkgs/$pkg"
  [ -d "$dir" ] || continue

  echo "处理包: $pkg"

  # 真实平台 = flake systems ∩ meta.platforms；meta 无声明则退用 flake 全集
  PKG_SYS_FILE="$(mktemp)"
  eval_pkg_platforms "$pkg" > "$PKG_SYS_FILE" || true
  [ ! -s "$PKG_SYS_FILE" ] && cp "$FLAKE_SYS_FILE" "$PKG_SYS_FILE"

  REAL_SYS_FILE="$(mktemp)"
  intersection "$FLAKE_SYS_FILE" < "$PKG_SYS_FILE" > "$REAL_SYS_FILE"
  # 交集为空（理论不发生）→ 兜底 flake 全集
  [ ! -s "$REAL_SYS_FILE" ] && cp "$FLAKE_SYS_FILE" "$REAL_SYS_FILE"

  # after：当前工作树
  unset AFTER; declare -A AFTER
  while IFS= read -r sys; do
    [ -z "$sys" ] && continue
    AFTER["$sys"]="$(eval_version "$pkg" "$sys" "$REPO_ROOT")"
  done < "$REAL_SYS_FILE"

  # before：HEAD worktree
  unset BEFORE; declare -A BEFORE
  if [ -n "$WT" ]; then
    while IFS= read -r sys; do
      [ -z "$sys" ] && continue
      BEFORE["$sys"]="$(eval_version "$pkg" "$sys" "$WT")"
    done < "$REAL_SYS_FILE"
  fi

  # 逐平台比较，仅收集真正变化的
  ver_changed=0
  items=()
  while IFS= read -r sys; do
    [ -z "$sys" ] && continue
    b="${BEFORE[$sys]:-}"
    n="${AFTER[$sys]:-}"
    if [ -n "$n" ] && [ "$b" != "$n" ]; then
      ver_changed=1
      if [ -z "$b" ]; then
        items+=("${pkg}(${sys}): new -> ${n}")
      else
        items+=("${pkg}(${sys}): ${b} -> ${n}")
      fi
    fi
  done < "$REAL_SYS_FILE"

  msg=""
  if [ "$ver_changed" -eq 1 ]; then
    if [ "${#items[@]}" -eq 1 ]; then
      msg="${items[0]}"
    else
      joined=""
      for it in "${items[@]}"; do
        [ -z "$joined" ] && joined="$it" || joined="$joined; $it"
      done
      msg="$joined"
    fi
  else
    # 版本未变 → 文件级 rev/tag/hash 兜底
    newf="$(git diff --name-only HEAD -- "$dir" 2>/dev/null | head -1)"
    [ -z "$newf" ] && newf="$(git ls-files --others --exclude-standard -- "$dir" 2>/dev/null | head -1)"

    if [ -n "$newf" ]; then
      OLD_F="$(mktemp)"
      git show "HEAD:$newf" > "$OLD_F" 2>/dev/null || true
      if [ ! -s "$OLD_F" ]; then
        msg="$pkg: new package"
      else
        or="$(rev_of "$OLD_F")"; nr="$(rev_of "$newf")"
        if [ -n "$or" ] && [ -n "$nr" ] && [ "$or" != "$nr" ]; then
          msg="$pkg: update rev $(short "$or") -> $(short "$nr")"
        else
          msg="$pkg: update source hash"
        fi
      fi
      rm -f "$OLD_F"; OLD_F=""
    else
      msg="$pkg: internal changes"
    fi
  fi

  echo "$msg"
  git add "$dir"
  git diff --cached --quiet || git commit -m "$msg"

  rm -f "$PKG_SYS_FILE" "$REAL_SYS_FILE"
  PKG_SYS_FILE=""; REAL_SYS_FILE=""
done

#!/usr/bin/env bash
set -euo pipefail

# execute-update-script.sh
# 在 GitHub Actions 的 update-package job 中执行，接收一个包属性路径作为参数。
# 使用 git worktree 来处理可写性问题

if [ $# -lt 1 ]; then
  echo "用法: bash scripts/update-packages/execute-update-script.sh <package-attr-path>"
  exit 1
fi

PACKAGE="$1"
WORKDIR="${GITHUB_WORKSPACE:-$PWD}"

# Helper: 向 GitHub Actions 的 $GITHUB_OUTPUT 追加输出（本地调试时退回到 stdout）
append_github_output() {
  # $1 = key, $2 = value
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf '%s=%s\n' "$1" "$2" >> "$GITHUB_OUTPUT"
  else
    printf '%s=%s\n' "$1" "$2"
  fi
}

# 创建临时 worktree
init_worktree() {
  local wt_dir branch_name
  wt_dir=$(mktemp -d)
  branch_name="update-$(date +%s)-$$"
  
  # 先进入工作目录执行，避免任何路径相关的问题
  (git worktree add -b "$branch_name" "$wt_dir" HEAD) 2>/dev/null
  
  # 输出目录和分支名
  echo "$wt_dir|$branch_name"
}

cleanup_worktree() {
  if [ -n "${WT_DIR:-}" ] && [ -n "${BRANCH_NAME:-}" ]; then
    git worktree remove --force "$WT_DIR" 2>/dev/null || true
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
  fi
}

# 设置 Git 用户信息
git config --global user.email "actions@github.com"
git config --global user.name "GitHub Actions"

# 传入绝对 flake 引用，避免内置 '.' 被拒绝
export FLAKE_REF="path:$WORKDIR"

# 准备执行环境变量（兼容不同脚本类型）
export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_BROKEN=1
export NIXPKGS_ALLOW_INSECURE=1

# 使用临时 HOME 目录以防脚本写入 HOME
export HOME="${HOME:-/tmp}"

# 创建临时 worktree
echo "创建临时 worktree..."
worktree_info=$(init_worktree)
WT_DIR="${worktree_info%%|*}"
BRANCH_NAME="${worktree_info##*|}"
trap cleanup_worktree EXIT

echo "Worktree: $WT_DIR"

# 设置 worktree 中的 flake 引用
export FLAKE_REF="path:$WT_DIR"

echo "获取包 $PACKAGE 的 updateScript"

# 临时文件存储 stderr
nix_stderr=$(mktemp)
nix_stdout=$(mktemp)
trap "rm -f '$nix_stderr' '$nix_stdout'" RETURN

# 尝试获取 updateScript，捕获输出和错误
if ! nix eval --impure --json --expr "
  let
    f = builtins.getFlake (builtins.getEnv \"FLAKE_REF\");
    sys = \"x86_64-linux\";
    lp = builtins.getAttr sys f.legacyPackages;
    pkgsN = import <nixpkgs> {};
    lib = pkgsN.lib;
    path = lib.strings.splitString \".\" \"${PACKAGE}\";
    pkg = lib.attrsets.attrByPath path null lp;
  in
    if pkg == null then throw \"no pkg\"
    else if (pkg ? passthru && pkg.passthru ? updateScript) then pkg.passthru.updateScript
    else if (pkg ? updateScript) then pkg.updateScript
    else throw \"no updateScript\"
" --argstr FLAKE_REF "$WT_DIR" >"$nix_stdout" 2>"$nix_stderr"; then
  echo "获取 updateScript 失败，错误信息:"
  cat "$nix_stderr"
  exit 1
fi

script_json=$(cat "$nix_stdout")

script_type=$(echo "$script_json" | jq -r 'type')

# 将 store 路径替换为 worktree 路径
rewrite_paths() {
  local cmd_array=("$@")
  local new_array=()
  
  for arg in "${cmd_array[@]}"; do
    if [[ "$arg" =~ ^/nix/store/[a-z0-9]+-(.+)$ ]]; then
      local filename="${BASH_REMATCH[1]}"
      local replaced
      if find "$WT_DIR" -name "$filename" -type f 2>/dev/null | read -r replaced; then
        new_array+=("$replaced")
        continue
      fi
    fi
    new_array+=("$arg")
  done
  
  printf '%s\n' "${new_array[@]}"
}

# 执行命令数组
execute_command_array() {
  local script_array=("$@")
  
  # 重写路径
  local rewritten
  mapfile -t rewritten < <(rewrite_paths "${script_array[@]}")
  
  local cmd="${rewritten[0]}"
  
  # 处理 nix-update 命令
  if [[ "$cmd" == "nix-update" ]] || [[ "$cmd" =~ ^/nix/store/.*/bin/nix-update$ ]]; then
    local new_command=("nix-update")
    local has_flake=0
    
    for ((i=1; i<${#rewritten[@]}; i++)); do
      arg="${rewritten[$i]}"
      if [[ "$arg" == "--flake" ]]; then
        has_flake=1
      fi
      if [[ "$arg" == -* || "$arg" == *=* ]]; then
        new_command+=("$arg")
      fi
    done
    
    if [[ $has_flake -eq 0 ]]; then
      new_command+=("--flake")
    fi
    
    new_command+=("$PACKAGE")
    
    echo "执行: ${new_command[@]}"
    cd "$WT_DIR"
    "${new_command[@]}"
  else
    # 其他命令直接在 worktree 中执行
    echo "执行: ${rewritten[@]}"
    cd "$WT_DIR"
    "${rewritten[@]}"
  fi
}

echo "执行更新脚本..."
case "$script_type" in
  "array")
    mapfile -t script_array < <(echo "$script_json" | jq -r '.[]')
    execute_command_array "${script_array[@]}"
    ;;
  "string")
    command_str=$(echo "$script_json" | jq -r '.')
    # 将字符串拆分为数组以便重写
    read -r -a script_array <<< "$command_str"
    execute_command_array "${script_array[@]}"
    ;;
  "object")
    if echo "$script_json" | jq -e 'has("command")' >/dev/null; then
      command_type=$(echo "$script_json" | jq -r '.command | type')
      if [ "$command_type" = "array" ]; then
        mapfile -t script_array < <(echo "$script_json" | jq -r '.command[]')
        execute_command_array "${script_array[@]}"
      elif [ "$command_type" = "string" ]; then
        command_str=$(echo "$script_json" | jq -r '.command')
        read -r -a script_array <<< "$command_str"
        execute_command_array "${script_array[@]}"
      else
        echo "错误：不支持的 command 类型: $command_type"
        exit 1
      fi
    else
      echo "错误：属性集缺少 command 字段"
      exit 1
    fi
    ;;
  *)
    echo "错误：未知的 updateScript 类型: $script_type"
    exit 1
    ;;
esac

# 检查变更并同步到主仓库
cd "$WT_DIR"
if [ -n "$(git status --porcelain)" ]; then
  # 复制变更文件到主仓库
  for file in $(git diff --name-only HEAD); do
    if [ -f "$file" ]; then
      mkdir -p "$(dirname "$WORKDIR/$file")"
      cp "$file" "$WORKDIR/$file"
      echo "已更新: $file"
    fi
  done
  
  # 处理新增文件
  for file in $(git status --porcelain | grep '^??' | cut -c4-); do
    if [ -f "$file" ]; then
      mkdir -p "$(dirname "$WORKDIR/$file")"
      cp "$file" "$WORKDIR/$file"
      git -C "$WORKDIR" add "$file"
      echo "已添加: $file"
    fi
  done
  
  cd "$WORKDIR"
  
  append_github_output "has_update" "true"
  echo "更新完成: $PACKAGE"
else
  cd "$WORKDIR"
  
  append_github_output "has_update" "false"
  echo "没有更新: $PACKAGE"
fi

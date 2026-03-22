#!/usr/bin/env bash
set -euo pipefail

# execute-update-script.sh
# 在 GitHub Actions 的 update-package job 中执行，接收一个包属性路径作为参数。
# 直接在当前分支执行更新脚本

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

# Worktree 隔离：仅在本地执行时启用（GitHub Actions 已有分支隔离）
USE_WORKTREE=false
if [ -z "${GITHUB_ACTIONS:-}" ]; then
  USE_WORKTREE=true
  WORKTREE_DIR=$(mktemp -d)

  echo "创建 worktree 隔离环境: $WORKTREE_DIR"
  git worktree add "$WORKTREE_DIR" HEAD --detach 2>/dev/null || {
    # fallback: 如果 worktree 失败，直接使用主目录
    echo "警告: worktree 创建失败，将在主目录执行"
    USE_WORKTREE=false
    rm -rf "$WORKTREE_DIR"
  }

  if [ "$USE_WORKTREE" = true ]; then
    export FLAKE_REF="path:$WORKTREE_DIR"
    cd "$WORKTREE_DIR"
  fi
fi

EXEC_DIR="${WORKTREE_DIR:-$WORKDIR}"

# 注入 UPDATE_NIX_* 环境变量（与 nixpkgs update.py 一致）
# 临时文件存储 stderr
nix_stderr=$(mktemp)
nix_stdout=$(mktemp)
cleanup() {
  if [ "${USE_WORKTREE:-false}" = true ] && [ -d "${WORKTREE_DIR:-}" ]; then
    echo "同步变更回工作目录..."
    rsync -av --exclude='.git' "$WORKTREE_DIR"/ "$WORKDIR"/ 2>/dev/null || true
    git worktree remove --force "$WORKTREE_DIR" 2>/dev/null || true
    rm -rf "$WORKTREE_DIR"
  fi
  rm -f "$nix_stderr" "$nix_stdout"
}
trap cleanup EXIT

echo "获取包元信息..."
pkg_info=$(nix eval --impure --json --expr "
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
    else {
      name = pkg.name or \"\";
      pname = pkg.pname or (lib.getName pkg);
      version = pkg.version or (lib.getVersion pkg);
    }
" 2>"$nix_stderr" || {
  echo "警告: 无法获取包元信息 (nix eval 失败)"
  cat "$nix_stderr" >&2
  echo '{}'
})

export UPDATE_NIX_NAME=$(echo "$pkg_info" | jq -r '.name // ""')
export UPDATE_NIX_PNAME=$(echo "$pkg_info" | jq -r '.pname // ""')
export UPDATE_NIX_OLD_VERSION=$(echo "$pkg_info" | jq -r '.version // ""')
export UPDATE_NIX_ATTR_PATH="$PACKAGE"

echo "  UPDATE_NIX_NAME=$UPDATE_NIX_NAME"
echo "  UPDATE_NIX_PNAME=$UPDATE_NIX_PNAME"
echo "  UPDATE_NIX_OLD_VERSION=$UPDATE_NIX_OLD_VERSION"
echo "  UPDATE_NIX_ATTR_PATH=$UPDATE_NIX_ATTR_PATH"

echo "获取包 $PACKAGE 的 updateScript"

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
" --argstr FLAKE_REF "$WORKDIR" >"$nix_stdout" 2>"$nix_stderr"; then
  echo "获取 updateScript 失败，错误信息:"
  cat "$nix_stderr"
  exit 1
fi

script_json=$(cat "$nix_stdout")
script_type=$(echo "$script_json" | jq -r 'type')

execute_command_array() {
  local script_array=("$@")
  local cmd="${script_array[0]}"

  if [[ "$cmd" == "nix-update" ]] || [[ "$cmd" =~ ^/nix/store/.*/bin/nix-update$ ]]; then
    local new_command=("nix-update")
    local has_flake=0

    for ((i=1; i<${#script_array[@]}; i++)); do
      arg="${script_array[$i]}"
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
    cd "$EXEC_DIR"
    "${new_command[@]}"
  else
    # 其他命令直接在当前目录执行
    echo "执行: ${script_array[@]}"
    cd "$EXEC_DIR"
    "${script_array[@]}"
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
    # 将字符串拆分为数组以便执行
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

echo "更新脚本执行完成: $PACKAGE"

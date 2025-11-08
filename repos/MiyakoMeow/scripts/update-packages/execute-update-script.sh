#!/usr/bin/env bash
set -euo pipefail

# execute-update-script.sh
# 在 GitHub Actions 的 update-package job 中执行，接收一个包属性路径作为参数。

if [ $# -lt 1 ]; then
  echo "用法: bash scripts/update-packages/execute-update-script.sh <package-attr-path>"
  exit 1
fi

PACKAGE="$1"

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
export FLAKE_REF="path:${GITHUB_WORKSPACE:-$PWD}"

# 准备执行环境变量（兼容不同脚本类型）
export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_BROKEN=1
export NIXPKGS_ALLOW_INSECURE=1

echo "NIX_PATH=$NIX_PATH"

# 使用临时HOME目录以防脚本写入HOME
export ORI_HOME="$HOME"
export HOME=$(mktemp -d)

echo "获取包 $PACKAGE 的updateScript"
script_json=$(nix eval --impure --json --expr "
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
")
script_type=$(echo "$script_json" | jq -r 'type')

# 将命令数组重写为使用完整属性路径的 nix-update，并保留标志参数
execute_command_array() {
  local script_array=("$@")
  local cmd="${script_array[0]}"

  # 将 store 路径的 nix-update 规范化为 "nix-update"
  if [[ "$cmd" =~ ^/nix/store/.*/bin/nix-update$ ]]; then
    cmd="nix-update"
    script_array[0]="nix-update"
  fi

  if [[ "$cmd" == "nix-update" ]]; then
    local new_command=("nix-update")
    local has_flake=0

    # 保留所有以 - 开头或包含 = 的标志参数；丢弃位置参数，最后追加完整属性路径
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

    echo "替换后的命令: ${new_command[@]}"
    "${new_command[@]}"
  else
    # 非 nix-update 命令按原样执行
    echo "执行更新命令(数组): ${script_array[@]}"
    "${script_array[@]}"
  fi
}

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
        echo "错误：不支持的command类型: $command_type"
        exit 1
      fi
    else
      echo "错误：属性集缺少command字段"
      exit 1
    fi
    ;;
  *)
    echo "错误：未知的updateScript类型: $script_type"
    exit 1
    ;;
esac

# 恢复原始HOME并清理临时目录
export TEMP_HOME="$HOME"
export HOME="$ORI_HOME"
rm -rf "$TEMP_HOME"

# 检查是否有需要提交的更改（不在此处提交，交由后续PR步骤）
if [ -n "$(git status --porcelain)" ]; then
    append_github_output "has_update" "true"
    echo "更新完成: $PACKAGE"
else
    append_github_output "has_update" "false"
    echo "没有更新: $PACKAGE"
fi
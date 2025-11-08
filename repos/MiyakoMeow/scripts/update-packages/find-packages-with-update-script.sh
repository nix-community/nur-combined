#!/usr/bin/env bash
set -euo pipefail

# find-packages-with-update-script.sh
# 从 flake 的 legacyPackages 中查找具有 updateScript 的包并去重（优先按 group）
#
# 输出:
# - 向 GitHub Actions 输出变量 $GITHUB_OUTPUT 写入:
#   package_list: JSON 数组字符串, 包含要更新的包属性路径
#   package_count: 要更新的条目数
#
# 使用示例（在 workflow step 的 run 中）:
#   bash scripts/update-packages/find-packages-with-update-script.sh
#
# 要求:
# - 在 GitHub Actions 中运行时, 默认环境变量 GITHUB_WORKSPACE 与 GITHUB_OUTPUT 可用
# - 依赖 nix, jq 已安装（工作流中应已安装）
#
# 该脚本基于原先 workflow 中的逻辑抽取，保持行为一致。

# Helper: print to GITHUB_OUTPUT (compatible with GitHub Actions)
append_github_output() {
  # $1 = key, $2 = value
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    # GitHub Actions 符合规范的输出方式（新式）
    printf '%s=%s\n' "$1" "$2" >> "$GITHUB_OUTPUT"
  else
    # 回退：打印到 stdout (旧式)
    # 为了简化，这里直接输出 key=value 到 stdout
    printf '%s=%s\n' "$1" "$2"
  fi
}

echo "开始查找具有 updateScript 的包..."

# 设置 flake 引用为当前工作区的绝对路径，避免 '.' 解析问题
export FLAKE_REF="path:${GITHUB_WORKSPACE:-$PWD}"

# 允许非自由软件（与 workflow 中行为一致）
export NIXPKGS_ALLOW_UNFREE=1

# 临时文件
TMPDIR=$(mktemp -d)
cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

ALL_PACKAGES_FILE="$TMPDIR/all-packages.txt"
PACKAGE_LIST_FILE="$TMPDIR/package-list.txt"

# 递归收集 legacyPackages 下具有 updateScript 的派生（含 groups）
echo "收集所有候选包属性路径..."
nix eval --impure --json --expr "
  let
    f = builtins.getFlake (builtins.getEnv \"FLAKE_REF\");
    sys = \"x86_64-linux\";
    lp = builtins.getAttr sys f.legacyPackages;
    pkgsN = import <nixpkgs> {};
    lib = pkgsN.lib;
    hasUS = pkg: (pkg ? passthru && pkg.passthru ? updateScript) || (pkg ? updateScript);
    collect = attrs: path:
      lib.concatMap (name:
        let v = attrs.\${name}; p = path ++ [ name ]; in
        if lib.isDerivation v then
          if hasUS v then [ (lib.concatStringsSep \".\" p) ] else []
        else if lib.isAttrs v then collect v p
        else []
      ) (builtins.attrNames attrs);
  in collect lp []
" | jq -r '.[]' > "$ALL_PACKAGES_FILE"

# 初始化 package list
: > "$PACKAGE_LIST_FILE"

# 不再使用 unique_groups/unique_commands 去重 —— 保留所有具有 updateScript 的包

# 遍历所有候选包，提取 updateScript 并按规则去重
while IFS= read -r pkg; do
  # 尝试获取 updateScript（如果失败也不要盲目跳过，改为包含包以避免遗漏）
  set +e
  script_output=$(nix eval --impure --json --expr "
    let
      f = builtins.getFlake (builtins.getEnv \"FLAKE_REF\");
      sys = \"x86_64-linux\";
      lp = builtins.getAttr sys f.legacyPackages;
      pkgsN = import <nixpkgs> {};
      lib = pkgsN.lib;
      path = lib.strings.splitString \".\" \"${pkg}\";
      pkg = lib.attrsets.attrByPath path null lp;
    in
      if pkg == null then throw \"no pkg\"
      else if (pkg ? passthru && pkg.passthru ? updateScript) then pkg.passthru.updateScript
      else if (pkg ? updateScript) then pkg.updateScript
      else throw \"no updateScript\"
  " 2>/dev/null)
  ret=$?
  set -e

  if [ $ret -ne 0 ]; then
    # 无法读取 updateScript（可能为解析错误或其它原因），仍将包包含在列表中以避免遗漏
    echo "警告: 无法读取 ${pkg} 的 updateScript，包含在更新列表中"
    echo "$pkg" >> "$PACKAGE_LIST_FILE"
    # 跳到下一个包
    continue
  fi

  # 简化逻辑：只要成功读取到了 updateScript 就包含该包（不再按 group/command 去重）
  # 这样可以保证像 free-download-manager 和 lampghost-dev 这样的包不会被误跳过。
  if ! grep -Fxq "$pkg" "$PACKAGE_LIST_FILE"; then
    echo "$pkg" >> "$PACKAGE_LIST_FILE"
  else
    echo "包 $pkg 已在列表中，跳过重复添加"
  fi

done < "$ALL_PACKAGES_FILE"

PACKAGE_COUNT=$(wc -l < "$PACKAGE_LIST_FILE" | awk '{print $1}')
echo "找到 ${PACKAGE_COUNT} 个需要更新的条目:"
cat "$PACKAGE_LIST_FILE"

# 输出到 GitHub Actions 输出变量
package_list_json=$(cat "$PACKAGE_LIST_FILE" | jq -R -s -c 'split("\n") | map(select(. != ""))')
append_github_output "package_list" "$package_list_json"
append_github_output "package_count" "$PACKAGE_COUNT"

echo "完成: 已写入 package_list 和 package_count 到 GitHub 输出变量。"

#!/usr/bin/env bash

# Script to build each cacheable package individually with garbage collection
# This helps to save disk space in CI environments

set -e

echo "Step 1: Fetching all packages from default.nix with their pnames..."

# 获取 default.nix 中所有包的属性名到 pname 的映射
pkg_to_pname_mapping=$(nix eval --impure --expr "
  let
    nurAttrs = import ./default.nix { pkgs = import <nixpkgs> {}; };
    isReserved = n: n == \"lib\" || n == \"overlays\" || n == \"modules\";
    attrs = builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs);
    mapping = builtins.listToAttrs (
      map (n: {
        name = nurAttrs.\${n}.pname or nurAttrs.\${n}.name or n;
        value = n;  # 属性名
      }) attrs
    );
  in
    mapping
" --json)

echo "Package name to attribute name mapping:"
echo "$pkg_to_pname_mapping"

echo "Step 2: Fetching all cacheable packages from ci.nix..."

# 获取 ci.cachePkgs 中的 pname
cacheable_pnames=$(nix eval --impure --expr "
  let
    ci = import ./ci.nix {};
    getPname = p: if p ? pname then p.pname else (p.name or \"unknown\");
  in
    builtins.map getPname ci.cachePkgs
" --json)

echo "Cacheable package names:"
echo "$cacheable_pnames"

# 解析 JSON 输出以获得 pname 数组
mapfile -t cacheable_pnames_array < <(echo "$cacheable_pnames" | jq -r '.[]')

# 根据映射找出对应的属性名
packages_to_build=()

for cache_pname in "${cacheable_pnames_array[@]}"; do
  # 在映射中查找对应的属性名
  attr_name=$(echo "$pkg_to_pname_mapping" | jq -r --arg cpname "$cache_pname" '.[$cpname] // empty')
  if [ -n "$attr_name" ] && [ "$attr_name" != "null" ]; then
    packages_to_build+=("$attr_name")
  else
    echo "Warning: Could not find attribute name for pname: $cache_pname"
  fi
done

echo "Step 3: List of packages to build:"
printf '%s\n' "${packages_to_build[@]}"

# 更改到项目目录
cd "$(dirname "$0")"

total=${#packages_to_build[@]}
count=0

for package_attr_name in "${packages_to_build[@]}"; do
  count=$((count+1))
  echo "[$count/$total] Building package: $package_attr_name"
  
  # 使用标准的 nix build 语法构建特定包
  nix build ".#$package_attr_name" -L
  
  # 构建完成后运行垃圾回收以清理中间构建产物
  echo "Running garbage collection..."
  nix-collect-garbage -d
  
  echo "Successfully built: $package_attr_name"
done

echo "All packages built successfully with individual garbage collection."
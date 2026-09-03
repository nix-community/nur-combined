#!/usr/bin/env bash
# 共享函数库，供各包的 update.sh 使用
# 用法：source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"

# 解析 -f/--force 参数
parse_args() {
  force=false
  if [[ ${1-} == "-f" || ${1-} == "--force" ]]; then
    force=true
  fi
}

# 初始化路径：SCRIPT_DIR, REPO_ROOT, package_dir, src_info, pubspec_lock_json, git_hashes_json
# BASH_SOURCE[0] 是共享库本身，BASH_SOURCE[1] 是调用脚本
setup_paths() {
  SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[1]}")" >/dev/null 2>&1 && pwd)
  REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
  cd "$REPO_ROOT"
  package_dir=$SCRIPT_DIR
  src_info=$package_dir/src-info.json
  pubspec_lock_json=$package_dir/pubspec.lock.json
  git_hashes_json=$package_dir/git-hashes.json
}

# 从 _sources/generated.json 读取版本和源码哈希
# 输出：设置 version, source_sha256
read_source_info() {
  version=$(jq -r ".\"$package_name\".src.rev" _sources/generated.json)
  source_sha256=$(jq -r ".\"$package_name\".src.sha256" _sources/generated.json)
  if [[ -z $source_sha256 || $source_sha256 == "null" ]]; then
    echo "Failed to read source sha256 from _sources/generated.json."
    exit 1
  fi
}

# 检查 src-info.json 是否过时，如果未变化则退出
check_stale() {
  if [[ -f $src_info && $force != true ]]; then
    local old_source_sha256
    old_source_sha256=$(jq -r '.sourceSha256 // empty' "$src_info" || true)
    if [[ -n $old_source_sha256 && $old_source_sha256 == "$source_sha256" ]]; then
      echo "src-info.json is up to date (sourceSha256=$source_sha256), skipping."
      exit 0
    fi
  fi
}

# 通过 nix build 提取哈希值
# 参数：$1 = nix 表达式，$2 = 日志标签
# 输出：设置 extracted_hash
nix_build_hash() {
  local expr="$1"
  local label="$2"
  # fd3 暂存真实 stdout 的指向，供管道内把 nix 的 stdout 送回终端直通
  exec 3>&1
  # stderr（含 -L 构建日志与失败信息）经 tee 实时回显，同时流入下游提取 hash；
  # 2>&1 1>&3：stderr 并入管道，，stdout 经 fd3 直通终端；末尾 || true 兜底 grep 无匹配时的退出码

  echo "$label build output is:"
  extracted_hash=$(
    { nix build -L --impure --expr "$expr" 2>&1 1>&3 || true; } |
      tee /dev/stderr |
      tr -s ' ' |
      grep -Po "got: \K.+$" || true
  )
  exec 3>&-
  if [ -z "$extracted_hash" ]; then
    echo "Failed to extract hash from build output."
    exit 1
  fi
  echo "$label hash is: $extracted_hash"
}

# 将 pubspec.lock (YAML) 转换为 JSON，存入 pubspec.lock.json
# 参数：$1 = lock 文件路径（相对 _sources/）
convert_pubspec_lock() {
  local lock_path="$1"
  yq eval --output-format=json --prettyPrint "_sources/$lock_path" >"$pubspec_lock_json"
}

# 通过 dart.fetchGitHashesScript 计算 git 依赖哈希，存入 git-hashes.json
fetch_git_hashes() {
  local script
  script=$(nix eval --raw nixpkgs#dart.fetchGitHashesScript 2>/dev/null || true)
  if [[ -z $script ]]; then
    echo "Failed to evaluate nixpkgs#dart.fetchGitHashesScript." >&2
    exit 1
  fi
  "$script" -i "$pubspec_lock_json" -o "$git_hashes_json"
}

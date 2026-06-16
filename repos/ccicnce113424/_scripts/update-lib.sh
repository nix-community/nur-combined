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

# 初始化路径：SCRIPT_DIR, REPO_ROOT, package_dir, src_info
# BASH_SOURCE[0] 是共享库本身，BASH_SOURCE[1] 是调用脚本
setup_paths() {
  SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[1]}")" >/dev/null 2>&1 && pwd)
  REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
  cd "$REPO_ROOT"
  package_dir=$SCRIPT_DIR
  src_info=$package_dir/src-info.json
}

# 从 _sources/generated.json 读取版本和源码哈希
# 参数：$1 = jq 命令（jq 或 jaq）
# 输出：设置 version, source_sha256
read_source_info() {
  local jq_cmd="${1:-jq}"
  version=$($jq_cmd -r ".\"$package_name\".src.rev" _sources/generated.json)
  source_sha256=$($jq_cmd -r ".\"$package_name\".src.sha256" _sources/generated.json)
  if [[ -z $source_sha256 || $source_sha256 == "null" ]]; then
    echo "Failed to read source sha256 from _sources/generated.json."
    exit 1
  fi
}

# 检查 src-info.json 是否过时，如果未变化则退出
# 参数：$1 = jq 命令（jq 或 jaq）
check_stale() {
  local jq_cmd="${1:-jq}"
  if [[ -f $src_info && $force != true ]]; then
    local old_source_sha256
    old_source_sha256=$($jq_cmd -r '.sourceSha256 // empty' "$src_info" || true)
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
  build_output=$(nix build --impure --expr "$expr" 2>&1) || true
  echo "$label build output is:"
  echo "$build_output"
  extracted_hash=$(tr -s ' ' <<<$build_output | grep -Po "got: \K.+$")
  if [ -z "$extracted_hash" ]; then
    echo "Failed to extract hash from build output."
    exit 1
  fi
  echo "$label hash is: $extracted_hash"
}

# 从 pubspec.lock 获取所有 git 依赖的哈希
# 参数：$1 = lock 文件路径
# 输出：设置 git_hashes_object
fetch_git_hashes() {
  local lock_path="$1"
  git_hashes_object=$(
    jaq --from yaml -r '.packages
      | to_entries
      | map(select(.value.source == "git"))
      | map({
          key: .key,
          url: .value.description.url,
          ref: (.value.description["resolved-ref"] // .value.description.ref // "HEAD")
        })
      | .[]
      | "\(.key) \(.url) \(.ref)"' "_sources/$lock_path" |
      while read -r name url ref; do
        echo "Fetching $name from $url ($ref)..." >&2
        hash=$(
          nix-prefetch-git --quiet --url "$url" --rev "$ref" |
            jaq -r .hash 2>/dev/null
        )
        if [[ -z $hash ]]; then
          echo "Failed to parse hash for $name from nix-prefetch-git output" >&2
          continue
        fi
        jaq -n --arg name "$name" --arg hash "$hash" '{ ($name): $hash }'
      done |
      jaq -s 'add'
  )
  if [[ -z ${git_hashes_object:-} ]]; then
    git_hashes_object='{}'
  fi
}

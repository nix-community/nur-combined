#!/usr/bin/env bash
set -euo pipefail

# 取消所有暂存区改动
git reset

# 获取 pkgs 下有改动的包
changed_pkgs=$(git diff --name-only | grep '^pkgs/' | cut -d/ -f2 | sort -u || true)

if [ -z "$changed_pkgs" ]; then
    echo "没有检测到 pkgs 下的改动"
    exit 0
fi

for pkg in $changed_pkgs; do
    dir="pkgs/$pkg"
    file=""
    type=""

    if [ -f "$dir/sources.nix" ]; then
        file="$dir/sources.nix"
        type="sources"
    elif [ -f "$dir/default.nix" ]; then
        file="$dir/default.nix"
        type="default"
    else
        continue
    fi

    # 检查文件中是否有 version 改动
    if git diff HEAD -- "$file" | grep -qE '^[+-].*version\s*='; then
        if [ "$type" = "sources" ]; then
            msg="$pkg: version changed"
        else
            old_version=$(git show HEAD:"$file" 2>/dev/null \
                | grep -E 'version\s*=' \
                | tail -n1 \
                | sed -E 's/.*"([^"]+)".*/\1/' || true)
            new_version=$(grep -E 'version\s*=' "$file" \
                | tail -n1 \
                | sed -E 's/.*"([^"]+)".*/\1/' || true)
            msg="$pkg: $old_version -> $new_version"
        fi

        echo "$msg"

        # 添加整个包文件夹并提交
        git add "$dir"
        git commit -m "$msg"
    fi
done

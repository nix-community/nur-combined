#!/usr/bin/env bash
set -euxo pipefail

git reset

# 获取 pkgs 下改动的包
changed_pkgs=$(git diff --name-only --relative pkgs/ | awk -F/ '{print $2}' | sort -u || true)

if [ -z "$changed_pkgs" ]; then
    echo "没有检测到 pkgs 下的改动"
    exit 0
fi

for pkg in $changed_pkgs; do
    dir="pkgs/$pkg"
    file=""

    for f in sources.nix default.nix; do
        if [ -f "$dir/$f" ]; then
            file="$dir/$f"
            break
        fi
    done

    [ -z "$file" ] && continue

    # 检查 version 是否改动
    if git diff HEAD -- "$file" | grep -qE '^[+-].*version\s*='; then
        old_version=$(git show HEAD:"$file" 2>/dev/null | awk -F'"' '/version\s*=/ {v=$2} END{print v}')
        new_version=$(awk -F'"' '/version\s*=/ {v=$2} END{print v}' "$file")

        if [ "$old_version" != "$new_version" ]; then
            msg="$pkg: $old_version -> $new_version"
        else
            msg="$pkg: version changed"
        fi

        echo "$msg"

        git add "$dir"
        if ! git diff --cached --quiet; then
            git commit -m "$msg"
        fi
    fi
done

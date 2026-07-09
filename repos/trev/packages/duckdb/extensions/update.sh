#!/usr/bin/env bash

set -euo pipefail

owner=
repo=
branch=
submodule_path=duckdb
override_filename=
attr=
dry_run=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --owner)
            owner=$2
            shift 2
            ;;
        --repo)
            repo=$2
            shift 2
            ;;
        --branch)
            branch=$2
            shift 2
            ;;
        --submodule-path)
            submodule_path=$2
            shift 2
            ;;
        --override-filename)
            override_filename=$2
            shift 2
            ;;
        --attr)
            attr=$2
            shift 2
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        *)
            printf 'unknown argument: %s\n' "$1" >&2
            exit 2
            ;;
    esac
done

if [[ -z "$owner" || -z "$repo" || -z "$branch" || -z "$override_filename" || -z "$attr" ]]; then
    printf 'usage: update.sh --owner OWNER --repo REPO --branch BRANCH --override-filename FILE --attr ATTR [--submodule-path PATH] [--dry-run]\n' >&2
    exit 2
fi

duckdb_version=$(nix eval --raw .#duckdb.version)
duckdb_ref="refs/tags/v$duckdb_version"
duckdb_sha=

while IFS=$'\t' read -r sha ref; do
    case "$ref" in
        "$duckdb_ref^{}")
            duckdb_sha=$sha
            break
            ;;
        "$duckdb_ref")
            duckdb_sha=${duckdb_sha:-$sha}
            ;;
    esac
done < <(git ls-remote --tags https://github.com/duckdb/duckdb "$duckdb_ref" "$duckdb_ref^{}")

if [[ -z "$duckdb_sha" ]]; then
    printf 'could not resolve duckdb tag v%s\n' "$duckdb_version" >&2
    exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

duckdb_repo=$tmpdir/duckdb
extension_repo=$tmpdir/extension

git init -q "$duckdb_repo"
git -C "$duckdb_repo" remote add origin https://github.com/duckdb/duckdb
git -C "$duckdb_repo" fetch -q --filter=blob:none --no-tags origin "$duckdb_sha"

git init -q "$extension_repo"
git -C "$extension_repo" remote add origin "https://github.com/$owner/$repo"
git -C "$extension_repo" fetch -q --filter=blob:none --no-tags origin "$branch"

matched_extension_sha=
matched_duckdb_sha=

# Only consider branch states, not arbitrary merged side-branch commits.
while read -r extension_sha; do
    entry=$(git -C "$extension_repo" ls-tree "$extension_sha" -- "$submodule_path")
    if [[ -z "$entry" ]]; then
        continue
    fi

    read -r _mode type extension_duckdb_sha _path <<< "$entry"
    if [[ "$type" != commit ]]; then
        continue
    fi

    if git -C "$duckdb_repo" cat-file -e "$extension_duckdb_sha^{commit}" 2>/dev/null \
        && git -C "$duckdb_repo" merge-base --is-ancestor "$extension_duckdb_sha" "$duckdb_sha"; then
        matched_extension_sha=$extension_sha
        matched_duckdb_sha=$extension_duckdb_sha
        break
    fi
done < <(git -C "$extension_repo" rev-list --first-parent FETCH_HEAD)

if [[ -z "$matched_extension_sha" ]]; then
    printf 'could not find a %s/%s commit on %s whose %s submodule is at or before duckdb %s (v%s)\n' \
        "$owner" \
        "$repo" \
        "$branch" \
        "$submodule_path" \
        "$duckdb_sha" \
        "$duckdb_version" >&2
    exit 1
fi

printf 'selected %s/%s@%s with %s@%s for duckdb@%s\n' \
    "$owner" \
    "$repo" \
    "$matched_extension_sha" \
    "$submodule_path" \
    "$matched_duckdb_sha" \
    "$duckdb_sha"

if [[ "$dry_run" == true ]]; then
    exit 0
fi

nix-update \
    --commit \
    --version="branch=$matched_extension_sha" \
    --override-filename="$override_filename" \
    "$attr"

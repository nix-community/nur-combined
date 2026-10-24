#!/usr/bin/env bash

# Updates duckdb, then pins every out-of-tree extension to the commit that duckdb release builds,
# read from .github/config/extensions/<name>.cmake in the duckdb source.

set -euo pipefail

head=$(git rev-parse HEAD)

nix-update \
    --commit \
    duckdb

version=$(nix eval --raw .#duckdb.version)
src=$(nix build --no-link --print-out-paths .#duckdb.src)

readarray -t extensions < <(
    # shellcheck disable=SC2016 # nix interpolation, not shell
    nix eval --json .#duckdb.extensions --apply '
        extensions:
        map (attr: {
          inherit attr;
          inherit (extensions.${attr}.passthru.duckdbExtension) name owner repo rev;
        }) (builtins.filter (attr: extensions.${attr} ? passthru.duckdbExtension) (builtins.attrNames extensions))
    ' | jq -c '.[]'
)

for extension in "${extensions[@]}"; do
    attr=$(jq -r .attr <<< "$extension")
    name=$(jq -r .name <<< "$extension")
    owner=$(jq -r .owner <<< "$extension")
    repo=$(jq -r .repo <<< "$extension")
    rev=$(jq -r .rev <<< "$extension")

    config=$src/.github/config/extensions/$name.cmake
    if [[ ! -f "$config" ]]; then
        printf 'duckdb v%s no longer ships the %s extension (%s missing)\n' "$version" "$name" "$config" >&2
        exit 1
    fi

    url=$(awk '$1 == "GIT_URL" { print $2; exit }' "$config")
    tag=$(awk '$1 == "GIT_TAG" { print $2; exit }' "$config")

    if [[ "$url" != "https://github.com/$owner/$repo" ]]; then
        printf 'duckdb v%s builds %s from %s, not https://github.com/%s/%s\n' "$version" "$name" "$url" "$owner" "$repo" >&2
        exit 1
    fi

    if [[ "$tag" == "$rev" ]]; then
        continue
    fi

    printf 'updating %s from %s to %s for duckdb v%s\n' "$name" "$rev" "$tag" "$version"
    nix-update \
        --version="branch=$tag" \
        --override-filename="packages/duckdb/extensions/$attr.nix" \
        "duckdb.extensions.$attr"
done

if git diff --quiet; then
    exit 0
fi

# keep extension updates in the duckdb commit so they land in the same pull request
if [[ "$(git rev-parse HEAD)" != "$head" ]]; then
    git commit --quiet --all --amend --no-edit
else
    git commit --quiet --all --message "duckdb.extensions: sync with duckdb v$version"
fi

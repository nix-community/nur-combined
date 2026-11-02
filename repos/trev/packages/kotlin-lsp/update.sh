#!/usr/bin/env bash

# Updates kotlin-lsp, then pins buildDate to the build date of the new release,
# read from idea/IntelliJServerApplicationInfo.xml in lib/language-server.main.jar.

set -euo pipefail

head=$(git rev-parse HEAD)

nix-update \
    --url https://github.com/Kotlin/kotlin-lsp \
    --version-regex 'kotlin-lsp/v(.*)' \
    --commit \
    kotlin-lsp

if [[ "$(git rev-parse HEAD)" == "$head" ]]; then
    exit 0
fi

version=$(nix eval --raw .#kotlin-lsp.version)
src=$(nix build --no-link --print-out-paths .#kotlin-lsp.src)

date=$(
    unzip -p "$src/lib/language-server.main.jar" idea/IntelliJServerApplicationInfo.xml \
        | sed -n 's/.*<build .*date="\([0-9]\{12\}\)".*/\1/p'
)
if [[ -z "$date" ]]; then
    printf 'kotlin-lsp %s has no build date in IntelliJServerApplicationInfo.xml\n' "$version" >&2
    exit 1
fi

sed -i "s/buildDate = \"[0-9]*\";/buildDate = \"$date\";/" packages/kotlin-lsp/default.nix

# keep the build date in the version update commit so they land in the same pull request
git commit --quiet --all --amend --no-edit

#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}
baseline_main_program=${2:?baseline main program is required}
old_version=${3:?old version is required}
new_version_file=${4:?new version output file is required}

if [[ ! "$package" =~ ^[a-z][a-z0-9_-]{0,63}$ ]]; then
  echo "Invalid package attribute: $package" >&2
  exit 2
fi
if [[ ! "$old_version" =~ ^[0-9A-Za-z][0-9A-Za-z._+~-]{0,127}$ ]]; then
  echo "Invalid old package version: $old_version" >&2
  exit 2
fi

package_path="pkgs/$package"
.github/scripts/validate_package_source.sh "$package_path"
git add -A -- "$package_path"
if git diff --cached --quiet HEAD -- "$package_path"; then
  echo "Package candidate has no changes: $package" >&2
  exit 1
fi
before=$(git diff --cached --binary --full-index HEAD -- "$package_path" | sha256sum)

.github/scripts/run_updater.sh "$package"

outside=$(git status --porcelain --untracked-files=all -- . ":(exclude)$package_path/**")
if [[ -n "$outside" ]]; then
  echo "Updater changed files outside $package_path:" >&2
  printf '%s\n' "$outside" >&2
  exit 1
fi

git add -A -- "$package_path"
after=$(git diff --cached --binary --full-index HEAD -- "$package_path" | sha256sum)
if [[ "$before" != "$after" ]]; then
  echo "Updater changed the reviewed package; it is not idempotent" >&2
  exit 1
fi

nix fmt -- --ci "$package_path"
.github/scripts/validate_bump.sh "$package" "$baseline_main_program"

new_version=$(nix eval --raw ".#$package.version")
version_state=$(.github/scripts/classify_version.sh "$old_version" "$new_version")
if [[ "$version_state" != "advanced" ]]; then
  echo "Package version did not advance: $old_version -> $new_version" >&2
  exit 1
fi

printf '%s' "$new_version" > "$new_version_file"

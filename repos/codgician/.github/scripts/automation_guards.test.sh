#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

assert_state() {
  local old_version=$1
  local new_version=$2
  local expected=$3
  local actual
  actual=$(.github/scripts/classify_version.sh "$old_version" "$new_version")
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected $old_version -> $new_version to be $expected, got $actual" >&2
    exit 1
  fi
}

assert_route() {
  local updater_exit=$1
  local package_changes=$2
  local version_state=$3
  local deterministic_exit=$4
  local expected=$5
  local actual
  actual=$(.github/scripts/select_update_route.sh \
    "$updater_exit" \
    "$package_changes" \
    "$version_state" \
    "$deterministic_exit")
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected route $expected, got $actual" >&2
    exit 1
  fi
}

assert_state '0-unstable-2026-07-15' '0-unstable-2026-07-16' advanced
assert_state '0-unstable-2026-07-15' '0-unstable-2026-07-15' unchanged
assert_state '0-unstable-2026-07-15' '0-unstable-2026-07-14' regressed
assert_state '1.2.3' '1.2.4' advanced

assert_route 0 true unchanged '' up-to-date
assert_route 0 false '' '' up-to-date
assert_route 0 true advanced 0 deterministic
assert_route 0 true advanced 1 ai
assert_route 1 true '' '' ai
assert_route 0 true invalid '' ai

if .github/scripts/classify_version.sh \
  '0-unstable-2026-07-15' \
  '0-unstable-2026-07-15-180007' >/dev/null 2>&1; then
  echo 'Timestamped version unexpectedly passed the date-only format guard' >&2
  exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/package"
printf 'safe\n' > "$tmpdir/package/update.sh"
.github/scripts/validate_package_source.sh "$tmpdir/package"
ln -s "$tmpdir/package" "$tmpdir/package-link"
if .github/scripts/validate_package_source.sh "$tmpdir/package-link" >/dev/null 2>&1; then
  echo 'Symlinked package path unexpectedly passed the package-source guard' >&2
  exit 1
fi
printf 'DENDRO_API_KEY\n' >> "$tmpdir/package/update.sh"
if .github/scripts/validate_package_source.sh "$tmpdir/package" >/dev/null 2>&1; then
  echo 'CI credential reference unexpectedly passed the package-source guard' >&2
  exit 1
fi

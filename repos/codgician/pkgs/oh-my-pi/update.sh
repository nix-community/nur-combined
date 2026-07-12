#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils curl gawk git gnugrep gnused jq nix
# shellcheck shell=bash

set -euo pipefail

nur=$(git rev-parse --show-toplevel)
package_path="$nur/pkgs/oh-my-pi/default.nix"
repo="can1357/oh-my-pi"
fake_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sri_sha256='^sha256-[A-Za-z0-9+/]{43}=$'

if [[ -L "$package_path" || ! -f "$package_path" ]]; then
  printf 'Error: required package file is missing or a symlink: %s\n' "$package_path" >&2
  exit 1
fi

line_value() {
  local pattern=$1 path=$2 value
  value=$(sed -nE "$pattern" "$path")
  if [[ $(printf '%s\n' "$value" | sed '/^$/d' | wc -l) != 1 ]]; then
    printf 'Error: expected one value matching %q in %s\n' "$pattern" "$path" >&2
    exit 1
  fi
  printf '%s\n' "$value"
}

replace_required() {
  local path=$1 expected=$2 replacement=$3 count temporary
  count=$(grep -Fxc -- "$expected" "$path" || true)
  if [[ "$count" != 1 ]]; then
    printf 'Error: expected exactly one line in %s: %s\n' "$path" "$expected" >&2
    exit 1
  fi
  temporary=$(mktemp)
  awk -v expected="$expected" -v replacement="$replacement" '
    $0 == expected { print replacement; next }
    { print }
  ' "$path" > "$temporary"
  chmod --reference="$path" "$temporary"
  mv "$temporary" "$path"
  if grep -Fqx -- "$expected" "$path" || ! grep -Fqx -- "$replacement" "$path"; then
    printf 'Error: failed to replace expected line in %s\n' "$path" >&2
    exit 1
  fi
}

fake_hash_from_build() {
  local attr=$1 stage=$2 output hash count
  if output=$(nix build --no-link "$attr" 2>&1); then
    printf 'Error: %s %s unexpectedly built with a fake fixed-output hash\n' "$stage" "$attr" >&2
    exit 1
  fi
  hash=$(printf '%s\n' "$output" | sed -nE 's/^[[:space:]]*got:[[:space:]]*(sha256-[A-Za-z0-9+/]{43}=)[[:space:]]*$/\1/p')
  count=$(printf '%s\n' "$hash" | sed '/^$/d' | wc -l)
  if [[ "$count" != 1 ]]; then
    printf 'Error: %s hash extraction expected exactly one canonical SRI sha256 in Nix mismatch context for %s, found %s:\n%s\n' "$stage" "$attr" "$count" "$output" >&2
    exit 1
  fi
  if [[ ! "$hash" =~ $sri_sha256 ]]; then
    printf 'Error: %s produced a non-canonical SRI sha256: %q\n' "$stage" "$hash" >&2
    exit 1
  fi
  printf '%s\n' "$hash"
}

old_version=$(line_value 's/^  version = "([^"]+)";.*/\1/p' "$package_path")
release=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest")
new_tag=$(jq -er 'select(.draft == false and .prerelease == false) | .tag_name' <<< "$release")
if [[ ! "$new_tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Error: latest release tag is not a stable vX.Y.Z semver tag: %q\n' "$new_tag" >&2
  exit 1
fi
new_version=${new_tag#v}

version_compare() {
  local IFS=. index
  local -a left right
  read -r -a left <<< "$1"
  read -r -a right <<< "$2"
  for index in 0 1 2; do
    if (( 10#${left[index]} < 10#${right[index]} )); then return 1; fi
    if (( 10#${left[index]} > 10#${right[index]} )); then return 0; fi
  done
  return 0
}

if [[ "$old_version" == "$new_version" ]]; then
  printf 'Current version %s is up-to-date\n' "$old_version"
  exit 0
fi
if ! version_compare "$new_version" "$old_version"; then
  printf 'Error: refusing downgrade from %s to %s\n' "$old_version" "$new_version" >&2
  exit 1
fi

tmpdir=$(mktemp -d)
cp "$package_path" "$tmpdir/default.nix"
restore() {
  local status=$?
  if (( status != 0 )); then
    cp "$tmpdir/default.nix" "$package_path"
  fi
  rm -rf "$tmpdir"
  exit "$status"
}
trap restore EXIT

echo "Updating oh-my-pi: $old_version -> $new_version"

old_source_hash=$(line_value 's/^    hash = "(sha256-[^"]+)";.*/\1/p' "$package_path")
replace_required "$package_path" "    rev = \"v${old_version}\";" "    rev = \"${new_tag}\";"
replace_required "$package_path" "    hash = \"${old_source_hash}\";" "    hash = \"${fake_hash}\";"
replace_required "$package_path" "  version = \"${old_version}\";" "  version = \"${new_version}\";"
replace_required "$package_path" "    version = \"${old_version}\";" "    version = \"${new_version}\";"

case "$(uname -sm)" in
  "Linux x86_64") system=x86_64-linux ;;
  *)
    printf 'Error: oh-my-pi is unsupported on this system: %s\n' "$(uname -sm)" >&2
    exit 1
    ;;
esac
attr="path:${nur}#legacyPackages.${system}.oh-my-pi"
source_hash=$(fake_hash_from_build "$attr.passthru.src" source)
replace_required "$package_path" "    hash = \"${fake_hash}\";" "    hash = \"${source_hash}\";"

old_bun_deps_hash=$(line_value 's/^    outputHash = "(sha256-[^"]+)";.*/\1/p' "$package_path")
replace_required "$package_path" "    outputHash = \"${old_bun_deps_hash}\";" "    outputHash = \"${fake_hash}\";"
bun_deps_hash=$(fake_hash_from_build "$attr.passthru.bunDeps" bunDeps)
replace_required "$package_path" "    outputHash = \"${fake_hash}\";" "    outputHash = \"${bun_deps_hash}\";"

old_cargo_hash=$(line_value 's/^  cargoHash = "(sha256-[^"]+)";.*/\1/p' "$package_path")
replace_required "$package_path" "  cargoHash = \"${old_cargo_hash}\";" "  cargoHash = \"${fake_hash}\";"
cargo_hash=$(fake_hash_from_build "$attr" cargo)
replace_required "$package_path" "  cargoHash = \"${fake_hash}\";" "  cargoHash = \"${cargo_hash}\";"

nix build --no-link "$attr"

echo "Updated oh-my-pi: $old_version -> $new_version"

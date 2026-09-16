#!/usr/bin/env bash
set -euo pipefail

owner="nexmoe"
repo="VidBee"
pname="vidbee"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"

echo "Checking latest version"

raw_tag=$(
  "$script_dir/../../.github/script/github-tag-fetch.sh" \
    "${owner}/${repo}"
)

latest_version="${raw_tag#v}"

echo "Latest version: $latest_version"

current_version=$(
  grep -oP '^\s*version\s*=\s*"\K[0-9.]+' "$package_file"
)

echo "Current version: $current_version"

if [[ "$latest_version" == "$current_version" ]]; then
  echo "Package is already at the latest version ($current_version)."
  exit 0
fi

echo "Updating: $current_version -> $latest_version"

bash "$script_dir/patch.sh" "$raw_tag"

dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
dummy_pnpm="sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="

sed -i -E \
  "s|(version\s*=\s*\")[0-9.]+(\")|\1${latest_version}\2|" \
  "$package_file"

extract_hash() {
  printf '%s\n' "$1" |
    grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' |
    head -n1
}

build_with_expected_failure() {
  local output_file="$1"

  set +e
  nix build "./#${pname}" -L >"$output_file" 2>&1
  local status=$?
  set -e

  cat "$output_file"
  return "$status"
}

echo "Building to determine src hash..."

sed -i -E \
  '/baseSrc =/,/hash =/ s/(hash = ")[^"]*(")/\1'"$dummy_src"'\2/' \
  "$package_file"

src_log="$(mktemp)"
trap 'rm -f "$src_log"' EXIT

src_status=0
build_with_expected_failure "$src_log" || src_status=$?

src_hash="$(extract_hash "$(cat "$src_log")")"

if [[ -z "$src_hash" ]]; then
  echo "Failed to determine src hash."

  if [[ "$src_status" -eq 0 ]]; then
    echo "Nix build unexpectedly succeeded with the dummy src hash."
  else
    echo "Nix build failed before reporting a fixed-output hash."
  fi

  exit "${src_status:-1}"
fi

echo "New src hash: $src_hash"

sed -i \
  "s|${dummy_src}|${src_hash}|" \
  "$package_file"

echo "Building to determine pnpmDeps hash..."

sed -i -E \
  '/pnpmDeps = fetchPnpmDeps/,/hash =/ s/(hash = ")[^"]*(")/\1'"$dummy_pnpm"'\2/' \
  "$package_file"

pnpm_log="$(mktemp)"

pnpm_status=0
build_with_expected_failure "$pnpm_log" || pnpm_status=$?

pnpm_hash="$(extract_hash "$(cat "$pnpm_log")")"

if [[ -z "$pnpm_hash" ]]; then
  echo "Failed to determine pnpmDeps hash."

  if [[ "$pnpm_status" -eq 0 ]]; then
    echo "Nix build unexpectedly succeeded with the dummy pnpmDeps hash."
  else
    echo "Nix build failed before reporting a fixed-output hash."
  fi

  exit "${pnpm_status:-1}"
fi

echo "New pnpmDeps hash: $pnpm_hash"

sed -i \
  "s|${dummy_pnpm}|${pnpm_hash}|" \
  "$package_file"

echo "Update completed successfully."
echo "Package version: $latest_version"
echo "Source hash: $src_hash"
echo "pnpmDeps hash: $pnpm_hash"

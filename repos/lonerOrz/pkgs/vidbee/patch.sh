#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodejs curl

set -euo pipefail

LATEST_VERSION="${1:-latest}"

owner="nexmoe"
repo="VidBee"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pnpm_version="11.1.2"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

run_pnpm() {
  npm exec \
    --yes \
    --package="pnpm@${pnpm_version}" \
    -- \
    pnpm "$@"
}

echo "Using pnpm ${pnpm_version}"
echo "pnpm version: $(run_pnpm --version)"

echo "Fetching source: $owner/$repo ($LATEST_VERSION)"

if [[ "$LATEST_VERSION" == "latest" ]]; then
  url="https://github.com/$owner/$repo/archive/refs/heads/main.tar.gz"
else
  url="https://github.com/$owner/$repo/archive/refs/tags/$LATEST_VERSION.tar.gz"
fi

curl -fL "$url" | tar -xz -C "$work_dir"

source_dir="$(
  find "$work_dir" \
    -maxdepth 1 \
    -type d \
    -name "${repo}-*" |
    head -n1
)"

if [[ -z "$source_dir" ]]; then
  echo "Failed to locate extracted source directory."
  exit 1
fi

cd "$source_dir"

echo "Updating dependencies..."

run_pnpm add -w @sentry/browser

echo "Regenerating lockfile..."

run_pnpm install \
  --lockfile-only \
  --no-frozen-lockfile \
  --ignore-scripts

echo "Verifying better-sqlite3 version..."

resolved_version="$(
  run_pnpm list better-sqlite3 --depth Infinity 2>/dev/null |
    grep -oE 'better-sqlite3@[0-9]+\.[0-9]+\.[0-9]+' |
    head -n1 |
    cut -d@ -f2
)"

if [[ "$resolved_version" != "13.0.3" ]]; then
  echo "Expected better-sqlite3 13.0.3, got: ${resolved_version:-<unknown>}"
  echo
  echo "package.json:"
  grep -n -A5 -B5 "better-sqlite3" package.json || true
  echo
  echo "pnpm-lock.yaml:"
  grep -n -A8 -B3 "better-sqlite3" pnpm-lock.yaml || true
  exit 1
fi

echo "better-sqlite3 resolved to $resolved_version"

cp package.json "$script_dir/package.json"
cp pnpm-lock.yaml "$script_dir/pnpm-lock.yaml"

echo "Updated package.json and pnpm-lock.yaml."

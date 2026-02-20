#!/usr/bin/env bash
set -euo pipefail

PKG_FILE="pkgs/context7-mcp/default.nix"
LOCK_FILE="pkgs/context7-mcp/package-lock.json"
REPO_OWNER="upstash"
REPO_NAME="context7"

if [[ ! -f "$PKG_FILE" ]]; then
  echo "Package file not found: $PKG_FILE" >&2
  exit 1
fi

current_version=$(rg -n 'version = "' "$PKG_FILE" | sed -n 's/.*version = "\([^"]*\)".*/\1/p')
if [[ -z "$current_version" ]]; then
  echo "Failed to read current version from $PKG_FILE" >&2
  exit 1
fi

echo "Current version: $current_version"

latest_version=$(git ls-remote --tags "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" \
  | awk -F/ '{print $3}' \
  | rg '^v' \
  | sed 's/^v//' \
  | sort -V \
  | tail -n1)

if [[ -z "$latest_version" ]]; then
  echo "Failed to resolve latest version tag" >&2
  exit 1
fi

echo "Latest version:  $latest_version"

if [[ "$latest_version" == "$current_version" ]]; then
  echo "Already up-to-date."
  exit 0
fi

sed -i "s|version = \"${current_version}\";|version = \"${latest_version}\";|" "$PKG_FILE"

src_hash=$(nix shell nixpkgs#nix-prefetch-github nixpkgs#jq -c bash -lc \
  "nix-prefetch-github ${REPO_OWNER} ${REPO_NAME} --rev v${latest_version} | jq -r .hash")

if [[ -z "$src_hash" ]]; then
  echo "Failed to fetch src hash" >&2
  exit 1
fi

echo "New src hash:   $src_hash"

old_src_hash=$(rg -n 'hash = "' "$PKG_FILE" | sed -n 's/.*hash = "\([^"]*\)".*/\1/p' | head -n1)
if [[ -z "$old_src_hash" ]]; then
  echo "Failed to read existing src hash" >&2
  exit 1
fi

sed -i "s|hash = \"${old_src_hash}\";|hash = \"${src_hash}\";|" "$PKG_FILE"

tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

echo "Updating package-lock.json..."
git clone --depth 1 --branch "v${latest_version}" "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "$tmp_dir"
nix shell nixpkgs#nodejs --command bash -lc \
  "cd \"$tmp_dir\" && npm install --package-lock-only --ignore-scripts --no-fund --no-audit"

if [[ ! -f "$tmp_dir/package-lock.json" ]]; then
  echo "Failed to generate package-lock.json" >&2
  exit 1
fi

cp "$tmp_dir/package-lock.json" "$LOCK_FILE"

placeholder_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
old_npm_hash=$(rg -n 'npmDepsHash = "' "$PKG_FILE" | sed -n 's/.*npmDepsHash = "\([^"]*\)".*/\1/p')
if [[ -z "$old_npm_hash" ]]; then
  echo "Failed to read existing npmDepsHash" >&2
  exit 1
fi

sed -i "s|npmDepsHash = \"${old_npm_hash}\";|npmDepsHash = \"${placeholder_hash}\";|" "$PKG_FILE"

echo "Calculating npmDepsHash..."
set +e
build_output=$(nix build .#context7-mcp 2>&1)
build_status=$?
set -e

new_npm_hash=$(echo "$build_output" | sed -n 's/.*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' | tail -n1)

if [[ -z "$new_npm_hash" ]]; then
  echo "Failed to determine npmDepsHash. Build output:" >&2
  echo "$build_output" >&2
  exit 1
fi

echo "New npmDepsHash: $new_npm_hash"

sed -i "s|npmDepsHash = \"${placeholder_hash}\";|npmDepsHash = \"${new_npm_hash}\";|" "$PKG_FILE"

if [[ $build_status -ne 0 ]]; then
  echo "Rebuilding to verify..."
  nix build .#context7-mcp
fi

echo "Update complete: $PKG_FILE"

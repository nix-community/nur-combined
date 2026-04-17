#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodejs pnpm curl

set -euo pipefail

LATEST_VERSION="${1:-latest}"

owner="nexmoe"
repo="VidBee"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo "📦 Fetching source: $owner/$repo ($LATEST_VERSION)"

if [[ "$LATEST_VERSION" == "latest" ]]; then
  URL="https://github.com/$owner/$repo/archive/refs/heads/main.tar.gz"
else
  URL="https://github.com/$owner/$repo/archive/refs/tags/$LATEST_VERSION.tar.gz"
fi

curl -fL "$URL" | tar -xz -C "$WORK_DIR"

EXTRACTED_DIR="$(find "$WORK_DIR" -maxdepth 1 -type d -name "${repo}-*" | head -n1)"

cd "$EXTRACTED_DIR"

echo "🔧 Modifying pnpm.overrides..."

# 添加缺失的依赖
pnpm add -w @sentry/browser

pnpm pkg set "pnpm.overrides.better-sqlite3=12.8.0"
pnpm install \
  --lockfile-only \
  --no-frozen-lockfile \
  --ignore-scripts

echo "✅ Copying modified files..."

cp package.json "$script_dir/package.json"
cp pnpm-lock.yaml "$script_dir/pnpm-lock.yaml"

echo "✅ Done: package.json pnpm-lock.yaml"

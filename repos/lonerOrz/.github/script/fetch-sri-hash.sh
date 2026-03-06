#!/usr/bin/env bash
# Fetch SRI hash from URL in one step
# Usage: fetch-sri-hash.sh <url> [--unpack]
# Output: sha256-xxxxx... (SRI format)
#  - fetch-sri-hash.sh 默认不使用 --unpack（适用于 .deb、.AppImage 等二进制文件）
#  - 只有 tarball（.tar.gz、.tgz 等）才需要 --unpack

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <url> [--unpack]" >&2
  echo "Example: $0 https://example.com/file.tar.gz" >&2
  echo "         $0 https://example.com/file.deb --unpack" >&2
  exit 1
fi

URL="$1"
UNPACK="${2:-}"

# Build command with optional --unpack
if [ "$UNPACK" = "--unpack" ]; then
  SHA="$(nix-prefetch-url --quiet --unpack --type sha256 "$URL")"
else
  SHA="$(nix-prefetch-url --quiet --type sha256 "$URL")"
fi

SRI="$(nix-hash --to-sri "sha256:$SHA")"

echo "$SRI"

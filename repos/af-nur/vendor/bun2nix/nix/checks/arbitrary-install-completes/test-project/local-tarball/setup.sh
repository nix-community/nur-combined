#!/usr/bin/env bash
# Creates the local tarball dependency for testing bun2nix's handling of
# local tarballs without file: prefix (Bun strips it in the packages section).
# Run this before `bun install` in the test-project directory.

set -euo pipefail

cd "$(dirname "$0")"

mkdir -p tarball-src/package
echo '{"name":"local-tarball-dep","version":"1.0.0"}' >tarball-src/package/package.json
tar -czf dep-1.0.0.tgz -C tarball-src package
rm -rf tarball-src

echo "Created local-tarball/dep-1.0.0.tgz"

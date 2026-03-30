#!/usr/bin/env bash
# fix-fod-hashes.sh - Iteratively fix FOD hash mismatches after nix-update
#
# After nix-update bumps a package version and src hash, nested fixed-output
# derivations (e.g., bunDeps, npmDeps) may have stale hashes. This script
# repeatedly attempts a nix-build, extracts the correct hash from the error,
# patches the Nix file, and retries.
#
# Usage: fix-fod-hashes.sh <attr-name> <nix-file>

set -euo pipefail

PKG="${1:?Usage: fix-fod-hashes.sh <attr> <nix-file>}"
NIX_FILE="${2:?Usage: fix-fod-hashes.sh <attr> <nix-file>}"
MAX_ATTEMPTS="${3:-5}"

# Pre-step: invalidate platform hashes we can't verify on CI (x86_64-linux).
# This prevents accidental sed collisions if two platforms share a stale hash.
if grep -q 'aarch64-darwin' "$NIX_FILE"; then
  echo ":: Marking aarch64-darwin hash as stale (cannot verify on x86_64-linux)"
  sed -i -E \
    's|(aarch64-darwin = ")sha256-[A-Za-z0-9+/]+=*(")|\1sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\2|' \
    "$NIX_FILE"
fi

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  echo ":: Build attempt $attempt/$MAX_ATTEMPTS"

  if build_output=$(nix-build -A "$PKG" 2>&1); then
    echo ":: Build succeeded on attempt $attempt"
    exit 0
  fi

  # Nix FOD hash mismatch output:
  #   specified: sha256-OLD...
  #      got:    sha256-NEW...
  specified=$(echo "$build_output" | grep -oP 'specified:\s+\Ksha256-[A-Za-z0-9+/]+={0,2}' | head -1 || true)
  got=$(echo "$build_output" | grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/]+={0,2}' | head -1 || true)

  if [[ -z "$specified" || -z "$got" ]]; then
    echo ":: ERROR: Build failed but no hash mismatch found in output"
    echo "$build_output" | tail -30
    exit 1
  fi

  echo ":: Hash mismatch: $specified -> $got"

  if ! grep -qF "$specified" "$NIX_FILE"; then
    echo ":: ERROR: specified hash not found in $NIX_FILE"
    exit 1
  fi

  sed -i "s|$specified|$got|g" "$NIX_FILE"
done

echo ":: ERROR: Build still failing after $MAX_ATTEMPTS attempts"
exit 1

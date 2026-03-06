#!/usr/bin/env bash
# Fetch SRI hash from URL or git repo
# Usage: fetch-sri-hash.sh <url> [--unpack|--git [--fetch-submodules]]
# Output: sha256-xxxxx... (SRI format)
#
# Modes:
#   (default)  - Direct file hash via nix-prefetch-url
#   --unpack   - Unpack and hash tarball via nix-prefetch-url --unpack
#   --git      - Hash git repo via nix-prefetch-git (uses --rev if provided)
#   --fetch-submodules - Include git submodules (requires --git)

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <url> [--unpack|--git [--fetch-submodules]]" >&2
  echo "Example: $0 https://example.com/file.tar.gz" >&2
  echo "         $0 https://github.com/owner/repo --git" >&2
  echo "         $0 https://github.com/owner/repo --git --fetch-submodules" >&2
  exit 1
fi

URL="$1"
shift

UNPACK=false
GIT_MODE=false
FETCH_SUBMODULES=false

while [ $# -gt 0 ]; do
  case "$1" in
    --unpack)
      UNPACK=true
      ;;
    --git)
      GIT_MODE=true
      ;;
    --fetch-submodules)
      FETCH_SUBMODULES=true
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

if [ "$GIT_MODE" = true ]; then
  # Use nix-prefetch-git for git repositories
  PREFETCH_OPTS="--quiet --url $URL"
  if [ "$FETCH_SUBMODULES" = true ]; then
    PREFETCH_OPTS="$PREFETCH_OPTS --fetch-submodules"
  fi
  SHA=$(nix-prefetch-git $PREFETCH_OPTS | jq -r .sha256)
  SRI="$(nix hash to-sri "sha256:$SHA")"
elif [ "$UNPACK" = true ]; then
  SHA="$(nix-prefetch-url --quiet --unpack --type sha256 "$URL")"
  SRI="$(nix hash to-sri "sha256:$SHA")"
else
  SHA="$(nix-prefetch-url --quiet --type sha256 "$URL")"
  SRI="$(nix hash to-sri "sha256:$SHA")"
fi

echo "$SRI"

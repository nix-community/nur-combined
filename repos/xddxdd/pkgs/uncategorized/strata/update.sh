#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git curl nix
# shellcheck shell=bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PKG="$SCRIPT_DIR/default.nix"

CUR="${UPDATE_NIX_OLD_VERSION:-}"
if [ -z "$CUR" ]; then
  CUR=$(grep -oP 'version = "\K[0-9.]+' "$PKG" | head -1)
fi
if [ -z "$CUR" ]; then
  echo "cannot determine current version" >&2
  exit 1
fi

NEW_VERSION=$(git ls-remote --tags https://github.com/Niko1221/Strata |
  sed -n 's#.*refs/tags/v\([0-9.]*\)$#\1#p' | sort -V | tail -1)
if [ -z "$NEW_VERSION" ]; then
  echo "no version tag found" >&2
  exit 1
fi
if [ "$NEW_VERSION" = "$CUR" ]; then
  exit 0
fi

OLD_VERSION="$CUR"
OLD_STRATA_HASH=$(grep -A2 'tag = "v${finalAttrs.version}"' "$PKG" | grep -oP 'hash = "\Ksha256-[^"]+')
OLD_LLAMA_REV=$(grep -oP 'llamaRev = "\K[0-9a-f]{40}' "$PKG" | head -1)
OLD_LLAMA_HASH=$(grep -A2 'rev = llamaRev;' "$PKG" | grep -oP 'hash = "\Ksha256-[^"]+')

NEW_LLAMA=$(
  curl -fsSL "https://raw.githubusercontent.com/Niko1221/Strata/v$NEW_VERSION/setup.py" |
    grep -oP 'LLAMA_CPP_COMMIT = "\K[0-9a-f]{40}'
)
if [ -z "$NEW_LLAMA" ]; then
  echo "cannot determine llama.cpp commit for v$NEW_VERSION" >&2
  exit 1
fi

NEW_STRATA_HASH=$(nix store prefetch-file --json --unpack "https://github.com/Niko1221/Strata/archive/refs/tags/v$NEW_VERSION.tar.gz" |
  grep -oP '"hash":"\K[^"]+')
NEW_LLAMA_HASH=$(nix store prefetch-file --json --unpack "https://github.com/ggml-org/llama.cpp/archive/$NEW_LLAMA.tar.gz" |
  grep -oP '"hash":"\K[^"]+')

sed -i \
  -e "s|^  version = \"$OLD_VERSION\";|  version = \"$NEW_VERSION\";|" \
  -e "s|$OLD_STRATA_HASH|$NEW_STRATA_HASH|" \
  -e "s|$OLD_LLAMA_REV|$NEW_LLAMA|" \
  -e "s|$OLD_LLAMA_HASH|$NEW_LLAMA_HASH|" \
  "$PKG"

nix build .#strata.src .#strata.llamaSrc --no-link

#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail

# LibreOffice and its main source follow the nixpkgs input. The dictionaries
# archive is versioned separately and must be refreshed when that input moves.
root=$(git rev-parse --show-toplevel)
cd "$root"

pkg=by-name/li/libreoffice_patched/package.nix
system=$(nix eval --raw --impure --expr builtins.currentSystem)
version=$(nix eval --raw ".#legacyPackages.${system}.nixpkgs_pkgs.libreoffice.version")
release=$(python3 -c 'import sys; print(".".join(sys.argv[1].split(".")[:3]))' "$version")

dictionaries_url="https://download.documentfoundation.org/libreoffice/src/${release}/libreoffice-dictionaries-${version}.tar.xz"
dictionaries_hash=$(
  nix store prefetch-file --json "$dictionaries_url" |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["hash"])'
)
expected_dictionaries_sha256=$(
  curl -fsSL --retry 3 "${dictionaries_url}.sha256" | awk '{ print $1 }'
)
actual_dictionaries_sha256=$(
  nix hash convert --hash-algo sha256 --to base16 "$dictionaries_hash"
)
if [ "$expected_dictionaries_sha256" != "$actual_dictionaries_sha256" ]; then
  echo "update.sh: dictionaries checksum does not match upstream" >&2
  exit 1
fi

open_symbol_url=https://dev-www.libreoffice.org/extern/f543e6e2d7275557a839a164941c0a86e5f2c3f2a0042bfc434c88c6dde9e140-opens___.ttf
open_symbol_hash=$(
  nix store prefetch-file --json "$open_symbol_url" |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["hash"])'
)

PACKAGE="$pkg" \
DICTIONARIES_URL="$dictionaries_url" \
DICTIONARIES_HASH="$dictionaries_hash" \
OPEN_SYMBOL_URL="$open_symbol_url" \
OPEN_SYMBOL_HASH="$open_symbol_hash" \
python3 - <<'PY'
import os
import pathlib
import re

path = pathlib.Path(os.environ["PACKAGE"])
text = path.read_text()


def update_block(text, binding, url, hash_value):
    pattern = rf'(?ms)^  {binding} = fetchurl \{{\n.*?^  \}};'
    replacement = (
        f'  {binding} = fetchurl {{\n'
        f'    url = "{url}";\n'
        f'    hash = "{hash_value}";\n'
        '  };'
    )
    result, count = re.subn(pattern, replacement, text, count=1)
    if count != 1:
        raise SystemExit(f"update.sh: could not update {binding} in {path}")
    return result


text = update_block(
    text,
    "openSymbol",
    os.environ["OPEN_SYMBOL_URL"],
    os.environ["OPEN_SYMBOL_HASH"],
)
text = update_block(
    text,
    "dictionaries",
    os.environ["DICTIONARIES_URL"],
    os.environ["DICTIONARIES_HASH"],
)
path.write_text(text)
PY

nixfmt "$pkg"
echo "update.sh: LibreOffice ${version} companion assets are current"

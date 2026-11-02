#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update jq python3
# shellcheck shell=bash
set -euo pipefail

nix-update "$UPDATE_NIX_ATTR_PATH"
version=$(nix eval --raw ".#$UPDATE_NIX_ATTR_PATH.version")
arm64_hash=$(nix store prefetch-file --json "https://github.com/3899/ncmm/releases/download/v$version/ncmm_Linux_arm64.tar.gz" | jq -er .hash)
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
python3 - "$script_dir/default.nix" "$arm64_hash" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
text, count = re.subn(
    r'("aarch64-linux" = \{\s*archive = "arm64";\s*hash = ")[^"]*(";)',
    rf"\g<1>{sys.argv[2]}\g<2>",
    text,
    count=1,
)
if count != 1:
    raise SystemExit("failed to update the aarch64-linux asset hash")
path.write_text(text)
PY

nix build --builders "" --no-link --impure --expr "
  let flake = builtins.getFlake (toString ./.);
      pkgs = import flake.inputs.nixpkgs { system = \"aarch64-linux\"; };
  in (pkgs.callPackage $script_dir/default.nix { }).src
"

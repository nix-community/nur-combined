# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{
  writeShellScriptBin,
  git,
  nix,
  path,
  lib,
  nvfetcher,
  ...
}:
writeShellScriptBin "nvfetcher-changes" ''
  set -e

  export PATH=${git}/bin:$PATH
  export PATH=${nix}/bin:$PATH
  export PATH=${nvfetcher}/bin:$PATH

  TMP_DIR=$(mktemp --directory "/tmp/nvfetcher-changes.XXXXXX")
  function cleanup {
    rm -rf "$TMP_DIR"
  }
  trap cleanup EXIT

  git show HEAD:"$1/generated.nix" > "$TMP_DIR/old.nix"

  nvfetcher -c "$1/nvfetcher.toml" -o "$1" && nix fmt

  nix eval --expr "
    (import ${../../../lib/version-diff.nix})
      { inherit (import ${path} { }) lib; }
      {
        oldSources = \"$TMP_DIR/old.nix\";
        newSources = \"$(realpath "$1/generated.nix")\";
      }
  " --impure --raw
''

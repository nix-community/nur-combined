# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{
  writeShellScriptBin,
  git,
  nvfetcher-changes,
  lib,
}:
writeShellScriptBin "nvfetcher-commit" ''
  set -e

  export PATH=${git}/bin:$PATH
  export PATH=${nvfetcher-changes}/bin:$PATH

  TMP_DIR=$(mktemp --directory "/tmp/nvfetcher-commit.XXXXXX")
  function cleanup {
    rm -rf "$TMP_DIR"
  }
  trap cleanup EXIT

  nvfetcher-changes "$@" > "$TMP_DIR/changes"

  function commit {
    git add --all 1>&2
    git commit -S "$@" 1>&2
  }

  changelog_lines=$(wc --lines "$TMP_DIR/changes" | cut -d ' ' -f 1)
  if [ "$changelog_lines" -eq 0 ]; then
    echo "changelog is empty, skip" 1>&2
  elif [ "$changelog_lines" -eq 1 ]; then
    commit --file="$TMP_DIR/changes"
  else
    commit --file=- <<EOF
  $1/generated.nix: update

  $(cat "$TMP_DIR/changes")
  EOF
  fi

  cat "$TMP_DIR/changes"
''

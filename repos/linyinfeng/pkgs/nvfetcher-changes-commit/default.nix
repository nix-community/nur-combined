{ writeShellScriptBin, git, nvfetcher-changes, lib }:

writeShellScriptBin "nvfetcher-changes-commit" ''
  set -e

  export PATH=${git}/bin:$PATH
  export PATH=${nvfetcher-changes}/bin:$PATH

  TMP_DIR=$(mktemp --directory "/tmp/nvfetcher-changes-commit.XXXXXX")
  function cleanup {
    rm -rf "$TMP_DIR"
  }
  trap cleanup EXIT

  generated_nix_file="$1"

  nvfetcher-changes "$@" > "$TMP_DIR/changes"

  function commit {
    git add "$generated_nix_file" 1>&2
    git commit "$@" 1>&2
  }


  changelog_lines=$(wc --lines "$TMP_DIR/changes" | cut -d ' ' -f 1)
  if [ "$changelog_lines" -eq 0 ]; then
    echo "updater changelog is empty, skip" 1>&2
  elif [ "$changelog_lines" -eq 1 ]; then
    commit --file="$TMP_DIR/changes"
  else
    commit --file=- <<EOF
  $generated_nix_file: Update

  $(cat "$TMP_DIR/changes")
  EOF
  fi

  cat "$TMP_DIR/changes"
''

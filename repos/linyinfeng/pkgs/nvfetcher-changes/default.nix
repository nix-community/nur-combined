{ writeShellScriptBin, git, nix, path, lib }:

writeShellScriptBin "nvfetcher-changes" ''
  set -e

  export PATH=${git}/bin:$PATH
  export PATH=${nix}/bin:$PATH

  TMP_DIR=$(mktemp --directory "/tmp/nvfetcher-changes.XXXXXX")
  function cleanup {
    rm -rf "$TMP_DIR"
  }
  trap cleanup EXIT

  generated_nix_file="$1"

  git show HEAD:"$generated_nix_file" > "$TMP_DIR/old.nix"

  nix eval --expr "
    (import ${../../lib/version-diff.nix})
      { inherit (import ${path} { }) lib; }
      {
        oldSources = \"$TMP_DIR/old.nix\";
        newSources = \"$(realpath "$generated_nix_file")\";
      }
  " --impure --raw
''

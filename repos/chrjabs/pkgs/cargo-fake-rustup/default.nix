{
  lib,
  writeScriptBin,
  rust-overlay,
  extend,
}:
# wrapper around stable and nightly cargo to support rustup-style `+nightly`
let
  rustPkgs = extend (import rust-overlay);
  stable = rustPkgs.rust-bin.stable.latest.default;
  nightly = rustPkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
in
writeScriptBin "cargo"
  # bash
  ''
    #!/usr/bin/env bash

    if [ "$1" == "+nightly" ]; then
        shift
        export RUSTC="${lib.getExe' nightly "rustc"}"
        exec -a "$0" "${lib.getExe' nightly "cargo"}" "$@"
    fi

    export RUSTC="${lib.getExe' stable "rustc"}"
    exec -a "$0" "${lib.getExe' stable "cargo"}" "$@"
  ''

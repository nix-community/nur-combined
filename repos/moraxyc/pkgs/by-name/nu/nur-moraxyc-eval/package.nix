{
  jq,
  nix,
  nixpkgs,
  nur-moraxyc,
  runCommand,
  stdenv,
}:
runCommand "nur-moraxyc-eval"
  {
    src = nur-moraxyc;
    nativeBuildInputs = [
      nix
      jq
    ];
    meta.broken = stdenv.hostPlatform.isDarwin;
  }
  ''
    export NIX_STATE_DIR=$TMPDIR/state
    nix-env -f $src -qa \* --meta \
        --allowed-uris https://static.rust-lang.org \
        --option restrict-eval true \
        --option allow-import-from-derivation true \
        --drv-path --show-trace \
        -I nixpkgs=${nixpkgs.path} \
        -I $src \
        --json | jq -r 'values | .[].name' | sort | tee $out
  ''

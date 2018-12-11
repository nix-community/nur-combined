{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "lib-tests";
  buildInputs = with pkgs; [ nix jq ];
  NIX_PATH="nixpkgs=${pkgs.path}";
  src = pkgs.lib.cleanSource ../../.;

  buildCommand = ''
    datadir="${pkgs.nix}/share"
    export TEST_ROOT=$(pwd)/test-tmp
    export NIX_BUILD_HOOK=
    export NIX_CONF_DIR=$TEST_ROOT/etc
    export NIX_DB_DIR=$TEST_ROOT/db
    export NIX_LOCALSTATE_DIR=$TEST_ROOT/var
    export NIX_LOG_DIR=$TEST_ROOT/var/log/nix
    export NIX_STATE_DIR=$TEST_ROOT/var/nix
    export NIX_STORE_DIR=$TEST_ROOT/store
    export PAGER=cat
    cacheDir=$TEST_ROOT/binary-cache
    nix-store --init

    set +e
    nix-instantiate --eval --strict --show-trace $src/lib/tests/tests.nix --json >out 2>err
    status=$?

    if [[ $status != 0 ]]; then
      cat err 1>&2
      exit $status
    elif [[ $(cat out) != "[]" ]]; then
      cat out | jq --color-output . 1>&2
      exit $status
    else
      touch $out
    fi
  '';
}

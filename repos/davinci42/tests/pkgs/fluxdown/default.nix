{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../../default.nix { inherit pkgs; }).fluxdown-server,
}:
let
  checks = import ./eval.nix { inherit pkgs; };
  source = pkgs.lib.fileset.toSource {
    root = ../../..;
    fileset = pkgs.lib.fileset.unions [
      ./settings.py
      ../../../modules/fluxdown-configure.py
      ../../../pkgs/fluxdown-server/update-settings.py
      ../../../pkgs/fluxdown-server/settings-schema.json
    ];
  };
in
assert builtins.all (value: value) (builtins.attrValues checks);
pkgs.runCommand "fluxdown-packaging-tests"
  {
    nativeBuildInputs = [ (pkgs.python315.withPackages (packages: [ packages.websocket-client ])) ];
    FLUXDOWN_TEST_PACKAGE = package;
  }
  ''
    python3 ${source}/tests/pkgs/fluxdown/settings.py -v
    touch "$out"
  ''

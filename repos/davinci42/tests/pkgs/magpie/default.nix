{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../../default.nix { inherit pkgs; }).magpie,
}:
let
  checks = import ./eval.nix { inherit pkgs; };
  source = pkgs.lib.fileset.toSource {
    root = ../../..;
    fileset = pkgs.lib.fileset.unions [
      ./settings.py
      ../../../modules/magpie-configure.py
    ];
  };
in
assert builtins.all (value: value) (builtins.attrValues checks);
pkgs.runCommand "magpie-packaging-tests"
  {
    nativeBuildInputs = [ pkgs.python3 ];
    MAGPIE_TEST_PACKAGE = package;
  }
  ''
    python3 ${source}/tests/pkgs/magpie/settings.py -v
    touch "$out"
  ''

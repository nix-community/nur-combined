{ pkgs }:
let
  inherit (pkgs) lib;
  hostUtils = import ../lib/hostUtils.nix { inherit lib; };

  # One runner per backend directory
  runners.nixos =
    test:
    pkgs.testers.runNixOSTest {
      imports = [ test ];
      _module.args.nixosModules = hostUtils.mkNixosModules ../nixos;
    };
in
# Every file below a backend directory is a test, named after its path
lib.mapAttrs (
  backend:
  lib.mapAttrsRecursive (_: runners.${backend} or (throw "tests/${backend} has no test runner"))
) (removeAttrs (hostUtils.mkModuleTree ./.) [ "default" ])

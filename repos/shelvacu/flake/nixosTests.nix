{
  allInputs,
  flake-parts-lib,
  config,
  lib,
  mkCommon,
  vacuRoot,
  ...
}:
let
  outerConfig = config;
in
{
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "allTests";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
      };
      file = ./nixosTests.nix;
    })
  ];
  perSystem =
    { system, config, ... }:
    let
      perSystemConfig = config;
      common = mkCommon {
        inherit system;
        vacuModuleType = "nixos";
      };
      inherit (common) pkgs;
      commonTestModule = {
        hostPkgs = pkgs;
        _module.args = common.specialArgs;
        node.pkgs = pkgs;
        node.pkgsReadOnly = true;
        node.specialArgs = lib.removeAttrs common.specialArgs [ "inputs" ];
      };
      tests = {
        liam = { };
        caddy-kanidm = {
          isExistingHost = false;
          broken = true;
        };
      };
    in
    lib.optionalAttrs (system == "x86_64-linux") {
      allTests = builtins.mapAttrs (
        name:
        {
          isExistingHost ? true,
          broken ? false,
        }:
        (allInputs.nixpkgs.lib.nixos.runTest {
          imports = [
            commonTestModule
            /${vacuRoot}/tests/${name}
            {
              node.specialArgs.inputs =
                if isExistingHost then
                  outerConfig.flake.nixosConfigurations.${name}._module.specialArgs.inputs
                else
                  common.specialArgs.inputs;
            }
          ];
        })
        // {
          inherit broken;
        }
      ) tests;

      checks = lib.filterAttrs (_: v: !v.broken) perSystemConfig.allTests;
    };

  flake.qb = lib.mapAttrs' (
    name: val: lib.nameValuePair "nixos-test-${name}" val
  ) outerConfig.flake.allTests."x86_64-linux";
}

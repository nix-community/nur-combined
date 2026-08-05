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
  tests = {
    liam = { };
    caddy-kanidm = {
      isExistingHost = false;
    };
    qemu-vm = {
      isExistingHost = false;
    };
  };
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
    { system, ... }:
    let
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
    in
    lib.optionalAttrs (system == "x86_64-linux") {
      vacuBuildDerivations = lib.mapAttrs' (
        name:
        {
          isExistingHost ? true,
          broken ? false,
        }:
        lib.nameValuePair "nixos-test-${name}" (
          allInputs.nixpkgs.lib.nixos.runTest {
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
          }
        )
        // {
          inherit broken;
        }
      ) tests;
    };

  vacuBuilds = lib.mapAttrs' (
    name:
    {
      broken ? false,
      ...
    }:
    lib.nameValuePair "nixos-test-${name}" {
      aliases = [ "test-${name}" ];
      checkName = name;
      multiSystem = false;
      inherit broken;
    }
  ) tests;
}

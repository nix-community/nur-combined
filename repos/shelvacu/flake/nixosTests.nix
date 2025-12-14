{
  allInputs,
  config,
  lib,
  mkCommon,
  vacuRoot,
  ...
}:
{
  perSystem = { system, ... }: 
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
    tests = {
      liam = { };
      caddy-kanidm.isExistingHost = false;
    };
  in
  lib.optionalAttrs (system == "x86_64-linux")
  {
    checks = builtins.mapAttrs (
    name: 
    { isExistingHost ? true, }:
    allInputs.nixpkgs.lib.nixos.runTest {
      imports = [
        commonTestModule
        /${vacuRoot}/tests/${name}
        {
          node.specialArgs.inputs =
            if isExistingHost
            then config.flake.nixosConfigurations.${name}._module.specialArgs.inputs
            else common.specialArgs.inputs;
        }
      ];
    }
    ) tests;
  };

  flake.qb = lib.mapAttrs' (name: val: 
    lib.nameValuePair "check-${name}" val
  ) config.flake.checks."x86_64-linux";
}

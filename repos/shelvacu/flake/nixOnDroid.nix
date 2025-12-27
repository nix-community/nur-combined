{ allInputs, config, lib, mkCommon, vacuRoot, ... }:
let
  mkNixOnDroid = system:
    let
      common = mkCommon {
        inherit system;
        vacuModuleType = "nix-on-droid";
      };
    in
    allInputs.nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [
        /${vacuRoot}/common
        /${vacuRoot}/hosts/nix-on-droid
      ];
      extraSpecialArgs = common.specialArgs;
      inherit (common) pkgs;
    };
in
{
  options.flake.nixOnDroidConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
  config.flake.nixOnDroidConfigurations = rec {
    arm = mkNixOnDroid "aarch64-linux";
    x86 = mkNixOnDroid "x86_64-linux";
    default = arm;
  };

  config.flake.qb = rec {
    nix-on-droid = config.flake.nixOnDroidConfigurations.default.activationPackage;
    nix-on-droid-x86 = config.flake.nixOnDroidConfigurations.x86.activationPackage;
    nix-on-droid-arm = config.flake.nixOnDroidConfigurations.arm.activationPackage;
    nod = nix-on-droid;
    nod-x86 = nix-on-droid-x86;
    nod-arm = nix-on-droid-arm;
    nod-bootstrap-x86_64 = allInputs.nix-on-droid.packages.x86_64-linux.bootstrapZip-x86_64;
    nod-bootstrap-aarch64 = allInputs.nix-on-droid.packages.x86_64-linux.bootstrapZip-aarch64;
  };
}

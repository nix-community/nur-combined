{ allInputs, config, lib, mkCommon, vacuRoot, ... }:
{
  options.flake.nixOnDroidConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
  config.flake.nixOnDroidConfigurations.default =
    let
      common = mkCommon {
        system = "aarch64-linux";
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

  config.flake.qb = rec {
    nix-on-droid = config.flake.nixOnDroidConfigurations.default.activationPackage;
    nod = nix-on-droid;
    nod-bootstrap-x86_64 = allInputs.nix-on-droid.packages.x86_64-linux.bootstrapZip-x86_64;
    nod-bootstrap-aarch64 = allInputs.nix-on-droid.packages.x86_64-linux.bootstrapZip-aarch64;
  };
}

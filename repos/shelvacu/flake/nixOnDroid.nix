{
  allInputs,
  config,
  lib,
  mkCommon,
  vacuRoot,
  ...
}:
let
  mkNixOnDroid =
    system:
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
    aarch64 = mkNixOnDroid "aarch64-linux";
    x86_64 = mkNixOnDroid "x86_64-linux";
    default = aarch64;
  };
  config.vacuBuilds.nix-on-droid = {
    aliases = [ "nod" ];
    primarySystem = "aarch64-linux";
    impure = true;
  };
  config.vacuBuilds.nix-on-droid-bootstrap = {
    aliases = [ "nod-bootstrap" ];
    primarySystem = "aarch64-linux";
    impure = true;
  };
  config.perSystem =
    { system, ... }:
    let
      arch =
        {
          x86_64-linux = "x86_64";
          aarch64-linux = "aarch64";
        }
        .${system};
    in
    {
      vacuBuildDerivations = {
        nix-on-droid = config.flake.nixOnDroidConfigurations.${arch}.activationPackage;
        nix-on-droid-bootstrap = allInputs.nix-on-droid.packages.x86_64-linux."bootstrapZip-${arch}";
      };
    };
}

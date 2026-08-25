{
  lib,
  ...
}:
{
  options = {
    flake.nixUpdatePackages = lib.mkOption {
      type = with lib.types; listOf nonEmptyStr;
      default = { };
      description = ''
        Names of packages exposed via outputs.packages that should be updated using nix-update.
      '';
    };
  };
}

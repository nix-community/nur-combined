{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mods.thinkbook14p-fix;
  ideapad-laptop-tb = config.boot.kernelPackages.callPackage ./ideapad-laptop-tb.nix { };
in
{
  options.mods.thinkbook14p-fix = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ ideapad-laptop-tb ];
    boot.blacklistedKernelModules = [ "ideapad-laptop" ];
  };
}

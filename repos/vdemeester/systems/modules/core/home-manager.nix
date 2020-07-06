{ config, lib, ... }:

with lib;
let
  cfg = config.core.home-manager;
in
{
  options = {
    core.home-manager = {
      enable = mkOption { type = types.bool; default = true; description = "Enable core.home-manager"; };
    };
  };
  config = mkIf cfg.enable {
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
  };
}

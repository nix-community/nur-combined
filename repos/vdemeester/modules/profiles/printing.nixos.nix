{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.printing;
in
{
  options = {
    profiles.printing = {
      enable = mkOption {
        default = false;
        description = "Enable printing profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      printing = {
        enable = true;
        drivers = [ pkgs.gutenprint ];
      };
    };
  };
}

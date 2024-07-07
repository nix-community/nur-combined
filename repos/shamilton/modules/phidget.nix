{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.numworks;
  phidget-udev-rules = pkgs.callPackage ../pkgs/phidget-udev-rules { };
in {

  options = {
    services.phidget = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable phidget udev rules.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    services.udev.packages = [ phidget-udev-rules ];
  };
}


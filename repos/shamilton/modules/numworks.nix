{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.numworks;
  numworks-udev-rules = pkgs.callPackage ../pkgs/numworks-udev-rules { };
in {

  options = {
    services.numworks = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable numworks udev rules.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    services.udev.packages = [ numworks-udev-rules ];
  };
}


{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.monitor;
in {
  options.hardware.monitor = {
    enable = mkEnableOption ''
      Adoptions for monitor
    '';
    user = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.autorandr.enable = true;
    programs.light.enable = true;
    users.users.${cfg.user}.extraGroups = [ "video" ];
    services.ddccontrol.enable = true;
    hardware.i2c.enable = true;
  };
}

# TLP power management
{ config, lib, ... }:
let
  cfg = config.my.services.tlp;
in
{
  options.my.services.tlp = {
    enable = lib.mkEnableOption "TLP power management configuration";
  };

  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;

      settings = {
        # Keep charge between 60% and 80% to preserve battery life
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
  };
}

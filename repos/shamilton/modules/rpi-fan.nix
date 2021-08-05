{ rpi-fan }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.rpi-fan;
in
{
  options.services.rpi-fan = {
    enable = mkEnableOption "Smart fan control for the the RPi Poe Hat";
  };
  config = mkIf cfg.enable {
    systemd.services.rpi-fan = {
      path = with pkgs; [
        bc 
      ];
      description = "Smart fan control for the the RPi Poe Hat";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${rpi-fan}/bin/rpi-fan" ];
      };
    };
  };
}

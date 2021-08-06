{ rpi-fan }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.rpi-fan;
in
{
  options.services.rpi-fan = {
    enable = mkEnableOption "Smart fan control for the the RPi Poe Hat";
    overlays-dir = mkOption {
      type = types.path;
      default = null;
      description = ''
        The directory where is located the `rpi-poe.dtbo` overlay file.
        If null, the builtin directory will be used.
      '';
      example = "/home/user/custom_overlays";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.rpi-fan = {
      path = with pkgs; [
        bc 
        coreutils
        libraspberrypi
      ];
      description = "Smart fan control for the the RPi Poe Hat";
      wantedBy = [ "multi-user.target" ];
      environment = { OVERLAYS_DIR = "${cfg.overlays-dir}"; };
      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${rpi-fan}/bin/rpi-fan" ];
      };
    };
  };
}

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
      type = types.nullOr types.path;
      default = null;
      description = ''
        The directory where is located the `rpi-poe.dtbo` overlay file.
        If null, the builtin directory will be used.
      '';
      example = "/home/user/custom_overlays";
    };
    logFile = mkOption {
      type = types.path;
      default = "/var/log/rpi-fan/rpi-fan.log";
      description = ''
        The file where to save logs.
      '';
      example = "/tmp/rpi-fan.log";
    };
    logUser = mkOption {
      type = types.str;
      description = ''
        The user owner of the log file.
      '';
      example = "myuser";
    };
    logGroup = mkOption {
      type = types.str;
      description = ''
        The group owner of the log file.
      '';
      example = "mygroup";
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
      environment = if (!isNull cfg.overlays-dir) then {
        OVERLAYS_DIR = "${cfg.overlays-dir}";
      } else {} // {
        LOG_FILE = "${cfg.logFile}";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${rpi-fan}/bin/rpi-fan" ];
      };
    };
    services.logrotate = {
      enable = true;
      extraConfig = ''
        "${cfg.logFile}" {
          su ${cfg.logUser} ${cfg.logGroup}
          daily
          rotate 7
          missingok
          notifempty
        }
      '';
    };
  };
}

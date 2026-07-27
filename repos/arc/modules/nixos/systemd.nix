{ config, lib, ... }: with lib; let
  cfg = config.systemd;
  watchdogReboot = if cfg.watchdog.rebootTimeout == null then "0" else cfg.watchdog.rebootTimeout;
  watchdogRebootDefault = "10min";
in {
  options.systemd = {
    watchdog = {
      enable = mkEnableOption "runtime watchdog";
      timeout = mkOption {
        type = types.str;
        default = "60s";
      };
      rebootTimeout = mkOption {
        type = with types; nullOr str;
        default = watchdogRebootDefault;
      };
    };
  };
  config = {
    systemd = {
      settings.Manager = mkMerge [
        (mkIf cfg.watchdog.enable {
          RuntimeWatchdogSec = mkDefault cfg.watchdog.timeout;
        })
        (mkIf (cfg.watchdog.rebootTimeout != watchdogRebootDefault) {
          RebootWatchdogSec = mkDefault watchdogReboot;
        })
      ];
    };
  };
}

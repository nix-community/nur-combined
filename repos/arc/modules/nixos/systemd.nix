{ config, lib, ... }: with lib; let
  cfg = config.systemd;
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
        default = "10min";
      };
    };
  };
  config = {
    systemd = {
      extraConfig = mkMerge [
        (mkIf cfg.watchdog.enable ''
          RuntimeWatchdogSec=${cfg.watchdog.timeout}
        '')
        (mkIf (cfg.watchdog.rebootTimeout != "10min") ''
          RebootWatchdogSec=${if cfg.watchdog.rebootTimeout == null then "0" else cfg.watchdog.rebootTimeout}
        '')
      ];
    };
  };
}

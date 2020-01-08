{ config, pkgs, lib, ... }: with lib; let
  cfg = config.services.offlineimap;
in {
  options.services.offlineimap = {
    enable = mkEnableOption "offlineimap sync";
    package = mkOption {
      type = types.package;
      default = pkgs.offlineimap;
      defaultText = "pkgs.offlineimap";
    };
    period = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "hourly";
      description = "Periodic sync only";
    };
  };

  config.systemd.user = mkIf (cfg.enable && config.programs.offlineimap.enable) {
    timers.offlineimap = mkIf (cfg.period != null) {
      Unit = {
        Description = "OfflineIMAP periodic sync";
      };
      Timer = {
        OnCalendar = cfg.period;
      };
    };

    services.offlineimap = {
      Unit = {
        Description = "OfflineIMAP sync";
        After = [ "network-online.target" ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/offlineimap -u basic"
          + optionalString (cfg.period != null) " -o";
        RestartSec = "30";
        Restart = "on-failure";
      };
    };
  };
}

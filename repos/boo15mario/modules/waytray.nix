{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.waytray;
in
{
  options.services.waytray = {
    enable = mkEnableOption "waytray system tray daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.waytray;
      description = "The waytray package to use.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.waytray = {
      Unit = {
        Description = "WayTray Daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/waytray-daemon";
        Restart = "on-failure";
        RestartSec = "5s";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

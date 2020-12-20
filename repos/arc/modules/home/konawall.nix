{ pkgs, lib, config, ... }: let
  cfg = config.services.konawall;
in with lib; {
  options.services.konawall = {
    enable = mkEnableOption "enable konawall";
    tags = mkOption {
      type = types.listOf types.str;
      default = ["score:>=200" "width:>=1600" "nobody"];
    };
    interval = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "20m";
      description = "How often to rotate backgrounds (specify as a systemd interval)";
    };
  };

  config.systemd.user = mkIf cfg.enable {
    services = {
      konawall = {
        Unit = {
          Description = "Random wallpapers";
          After = ["graphical-session-pre.target"];
          PartOf = ["graphical-session.target"];
          Requisite = ["graphical-session.target"];
        };
        Service = {
          Environment = ["KONATAGS=${concatStringsSep "+" cfg.tags}"];
          Type = "oneshot";
          ExecStart = pkgs.arc'private.konawall.exec;
          RemainAfterExit = true;
          IOSchedulingClass = "idle";
          TimeoutStartSec = "5m";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
      konawall-rotation = mkIf (cfg.interval != null) {
        Unit = {
          Description = "Random wallpaper rotation";
          Requisite = ["graphical-session.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${config.systemd.package}/bin/systemctl --user restart konawall";
        };
      };
    };
    timers.konawall-rotation = mkIf (cfg.interval != null) {
      Unit = {
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };
      Timer = {
        OnUnitInactiveSec = cfg.interval;
        OnStartupSec = cfg.interval;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}

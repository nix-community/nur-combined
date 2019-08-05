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

  config.systemd.user.services = mkIf cfg.enable {
    konawall = {
      Unit = {
        Description = "Random wallpapers";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Environment = ["KONATAGS=${concatStringsSep "+" cfg.tags}"];
        Type = "oneshot";
        ExecStart = pkgs.arc'private.konawall.exec;
        IOSchedulingClass = "idle";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };

  config.systemd.user.timers = mkIf (cfg.enable && cfg.interval != null) {
    konawall = {
      Timer = {
        OnUnitInactiveSec = cfg.interval;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}

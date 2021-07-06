{ pkgs, lib, config, ... }: let
  cfg = config.services.konawall;
  arc = import ../../canon.nix { inherit pkgs; };
  service = config.systemd.user.services.konawall;
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
        Unit = rec {
          Description = "Random wallpapers";
          After = mkMerge [
            [ "graphical-session-pre.target" ]
            (mkIf config.wayland.windowManager.sway.enable [ "sway-session.target" ])
          ];
          PartOf = mkMerge [
            [ "graphical-session.target" ]
            (mkIf config.wayland.windowManager.sway.enable [ "sway-session.target" ])
          ];
          Requisite = PartOf;
        };
        Service = {
          Environment = ["KONATAGS=${concatStringsSep "+" cfg.tags}"];
          Type = "oneshot";
          ExecStart = arc.packages.personal.konawall.exec;
          RemainAfterExit = true;
          IOSchedulingClass = "idle";
          TimeoutStartSec = "5m";
        };
        Install.WantedBy = mkMerge [
          (mkDefault [ "graphical-session.target" ])
          (mkIf config.wayland.windowManager.sway.enable [ "sway-session.target" ])
        ];
      };
      konawall-rotation = mkIf (cfg.interval != null) {
        Unit = {
          Description = "Random wallpaper rotation";
          inherit (service.Unit) Requisite;
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${config.systemd.package or pkgs.systemd}/bin/systemctl --user restart konawall";
        };
      };
    };
    timers.konawall-rotation = mkIf (cfg.interval != null) {
      Unit = {
        inherit (service.Unit) After PartOf;
      };
      Timer = {
        OnUnitInactiveSec = cfg.interval;
        OnStartupSec = cfg.interval;
      };
      Install = {
        inherit (service.Install) WantedBy;
      };
    };
  };
}

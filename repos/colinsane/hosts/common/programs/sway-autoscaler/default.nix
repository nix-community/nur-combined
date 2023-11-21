{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.sway-autoscaler;
in
{
  sane.programs.sway-autoscaler = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = false;
        };

        options.defaultScale = mkOption {
          type = types.number;
          default = 1;
        };
        options.interval = mkOption {
          type = types.number;
          default = 5;
        };
      };
    };

    package = pkgs.static-nix-shell.mkBash {
      pname = "sway-autoscaler";
      pkgs = [ "jq" "sway" "util-linux" ];
      src = ./.;
    };

    services.sway-autoscaler = {
      description = "adjust global desktop scale to match the activate application";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/sway-autoscaler --loop-sec ${builtins.toString cfg.config.interval}";
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
      };
      environment.SWAY_DEFAULT_SCALE = builtins.toString cfg.config.defaultScale;
    };
  };
}

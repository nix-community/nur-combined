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

    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "sway-autoscaler";
      pkgs = {
        inherit (pkgs)
          jq
          sway
          util-linux
          ;
      };
      srcRoot = ./.;
    };

    services.sway-autoscaler = {
      description = "adjust global desktop scale to match the activate application";
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      command = lib.escapeShellArgs [
        "env"
        "SWAY_DEFAULT_SCALE=${toString cfg.config.defaultScale}"
        "sway-autoscaler"
        "--loop-sec"
        (toString cfg.config.interval)
      ];
    };
  };
}

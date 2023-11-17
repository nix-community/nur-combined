{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.gtkcord4;
in
{
  sane.programs.gtkcord4 = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    persist.byStore.private = [
      ".cache/gtkcord4"
      ".config/gtkcord4"  # empty?
    ];

    services.gtkcord4 = {
      description = "unofficial Discord chat client";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/gtkcord4";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
    };
  };
}

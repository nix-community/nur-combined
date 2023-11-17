{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.signal-desktop;
in
{
  sane.programs.signal-desktop = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    package = pkgs.signal-desktop-from-src;

    # creds, media
    persist.byStore.private = [
      ".config/Signal"
    ];

    services.signal-desktop = {
      description = "Signal Messenger";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/signal-desktop";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
    };
  };
}

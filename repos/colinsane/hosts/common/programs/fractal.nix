{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.fractal;
in
{
  sane.programs.fractal = {
    package = pkgs.fractal-nixified;
    # package = pkgs.fractal-latest;
    # package = pkgs.fractal-next;

    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    persist.private = [
      # XXX by default fractal stores its state in ~/.local/share/<build-profile>/<UUID>.
      ".local/share/hack"    # for debug-like builds
      ".local/share/stable"  # for normal releases
    ];

    suggestedPrograms = [ "gnome-keyring" ];

    services.fractal = {
      description = "auto-start and maintain fractal Matrix connection";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/fractal";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      # environment.G_MESSAGES_DEBUG = "all";
    };
  };
}

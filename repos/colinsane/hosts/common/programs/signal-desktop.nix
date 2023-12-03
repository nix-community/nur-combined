# TODO(bug): signal-desktop is known to hang on exit.
# particularly, it may fail to start (because e.g. there's no wayland session yet),
# and it will try to exit -- after which the service would restart -- but it hangs w/ no GUI instead.
# characterized by these log messages:
#
#     Dec 03 13:46:23 moby signal-desktop[4097]: [4097:1203/134623.906367:ERROR:ozone_platform_x11.cc(240)] Missing X server or $DISPLAY
#     Dec 03 13:46:23 moby signal-desktop[4097]: [4097:1203/134623.909667:ERROR:env.cc(255)] The platform failed to initialize.  Exiting.
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
      # for some reason the --ozone-platform-hint=auto flag fails when signal-desktop is launched from a service
      environment.NIXOS_OZONE_WL = "1";
    };
  };
}

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
          default = true;
        };
      };
    };

    packageUnwrapped = pkgs.signal-desktop-from-src;
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [
      "user"  # so i can click on links
    ];
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];

    # creds, media
    persist.byStore.private = [
      ".config/Signal"
    ];

    buildCost = 1;

    services.signal-desktop = {
      description = "signal-desktop Signal Messenger client";
      # depends = [ "graphical-session" ];
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      command = "signal-desktop";
    };
  };
}

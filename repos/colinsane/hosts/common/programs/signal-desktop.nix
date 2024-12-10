# XXX(2024-11-26): nixpkgs' signal-desktop has bugs on wayland:
# - it won't open a UI (though it *does* on Xwayland)
# - it may hang on exit (?), characterized by these log messages:
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

    # optionally, build this *mostly* from source (deps remain vendored), to allow e.g. for patching.
    packageUnwrapped = pkgs.signal-desktop-from-src;

    # or use the binary version:
    # packageUnwrapped = pkgs.signal-desktop.overrideAttrs (upstream: {
    #   # fix to use wayland instead of Xwayland:
    #   # - replace `NIXOS_OZONE_WL` non-empty check with `WAYLAND_DISPLAY`
    #   # - use `wayland` instead of `auto` because --ozone-platform-hint=auto still prefers X over wayland when both are available
    #   # alternatively, set env var: `ELECTRON_OZONE_PLATFORM_HINT=wayland` and ignore all of this
    #   preFixup = lib.replaceStrings
    #     [ "NIXOS_OZONE_WL" "--ozone-platform-hint=auto" ]
    #     [ "WAYLAND_DISPLAY" "--ozone-platform-hint=wayland" ]
    #     upstream.preFixup
    #   ;
    # });

    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [
      "user"  # so i can click on links
    ];
    sandbox.whitelistDri = true;  #< hopefully it makes use of this for perf?
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

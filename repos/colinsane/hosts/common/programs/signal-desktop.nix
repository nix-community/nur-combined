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

    packageUnwrapped = pkgs.signal-desktop.overrideAttrs (upstream: {
      # fix to use wayland instead of Xwayland:
      # - replace `NIXOS_OZONE_WL` non-empty check with `WAYLAND_DISPLAY`
      # - use `wayland` instead of `auto` because --ozone-platform-hint=auto still prefers X over wayland when both are available
      # alternatively, set env var: `ELECTRON_OZONE_PLATFORM_HINT=wayland` and ignore all of this
      installPhase = lib.replaceStrings
        [ "NIXOS_OZONE_WL" "--ozone-platform-hint=auto" ]
        [ "WAYLAND_DISPLAY" "--ozone-platform-hint=wayland" ]
        upstream.installPhase
      ;
    });

    sandbox.wrapperType = "inplace";  #< share/signal-desktop/app.asar refers to its out outpath

    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;  #< hopefully it makes use of this for perf?
    sandbox.whitelistPortal = [
      # "FileChooser"  #< does not use file chooser
      "OpenURI"
    ];
    sandbox.whitelistSendNotifications = true;
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
    sandbox.mesaCacheDir = ".cache/Signal/mesa";
    sandbox.tmpDir = ".cache/Signal/tmp";  # 60MB+ sqlite database(s)

    # creds, media
    persist.byStore.private = [
      ".config/Signal"
    ];

    buildCost = 1;

    mime.urlAssociations."^https://signal.me/#.+$" = "signal.desktop";  #< not sure the exact format of invite links.

    services.signal-desktop = {
      description = "signal-desktop Signal Messenger client";
      # depends = [ "graphical-session" ];
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      command = "signal-desktop";
    };
  };
}

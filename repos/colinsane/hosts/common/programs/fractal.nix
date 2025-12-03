# Fractal: GTK4 instant messenger client for the Matrix protocol
#
# very susceptible to state corruption during hard power-cycles.
# if it stalls while launching, especially with a brief message at bottom
# "unable to open store"
# then:
# - remove ~/.local/share/fractal/*
#   - this might give I/O error, in which case remove the corresponding path under
#     /nix/persist/private/home/colin/ (which can be found by correlating timestamps/sizes with that in ~/private/.local/share/stable).
# - reboot (maybe necessary).
# - now you can send messages, and read messages in unencrypted rooms, but not read messages from encrypted rooms.
# to fix encrypted message receipt:
# - start from above (fractal closed, no ~/.local/share/fractal/*)
# - use `sane-wipe fractal` and restart fractal & verify your session, OR:
# - in ~/.local/share/keyrings/Default_keyring.keyring:
#   - find the entry that says "display-name=Fractal: Matrix credentials for <mxid>"
#   - remove that entry and all associated entries (i.e. ones with same number but different :attributeN)
#   - REBOOT. otherwise keyring stuff seems to stay cached in RAM
#   - login to Fractal. give an hour to sync.
#   - it'll kick you back to a page asking you to cross-sign. open another client (Fractal on other device; FluffyChat) and do the emoji compare. success!
{ config, lib, ... }:
let
  cfg = config.sane.programs.fractal;
in
{
  sane.programs.fractal = {
    # stock fractal once used to take 2+hr to link: switch back to fractal-nixified should that happen again
    # packageUnwrapped = pkgs.fractal-nixified.optimized;

    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user.own = [ "org.gnome.Fractal" ];
    sandbox.whitelistDbus.user.call."org.freedesktop.secrets" = "*";  #< TODO: restrict to a subset of secrets
    sandbox.whitelistDri = true;  # otherwise video playback buuuuurns CPU
    sandbox.whitelistPortal = [
      "FileChooser"
      "NetworkMonitor"  # if portals are enabled, but NetworkMonitor *isn't*, then it'll hang on launch
      "OpenURI"
    ];
    sandbox.whitelistSendNotifications = true;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      # still needs these paths despite it using the portal's file-chooser :?
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
    sandbox.mesaCacheDir = ".cache/fractal/mesa";
    sandbox.tmpDir = ".cache/fractal/tmp";  # 10MB+ avatar caches (grows seemingly unbounded during runtime)

    persist.byStore.ephemeral = [
      ".cache/fractal" # ~3MB matrix-sdk-event-cache.sqlite3
    ];
    persist.byStore.private = [
      ".local/share/fractal"
    ];

    suggestedPrograms = [ "gnome-keyring" ];

    # direct room links opened from other programs, to fractal.
    mime.urlAssociations."^https?://matrix.to/#/.+$" = "org.gnome.Fractal.desktop";

    services.fractal = {
      description = "fractal Matrix client";
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];

      # env "G_MESSAGES_DEBUG=all"
      command = "fractal";
    };
  };
}

{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal;
in
{
  sane.programs.xdg-desktop-portal = {
    # rmDbusServices: because we care about ordering with the rest of the desktop, and don't want something else to auto-start this.
    packageUnwrapped = pkgs.rmDbusServices (
      pkgs.xdg-desktop-portal.overrideAttrs (upstream: {
        postPatch = (upstream.postPatch or "") + ''
          # wherever we have a default mime association, don't prompt the user to choose an app.
          # tracking issues about exposing this formally:
          # - <https://github.com/flatpak/xdg-desktop-portal/issues/780>
          # - <https://github.com/flatpak/xdg-desktop-portal/issues/471>
          # - <https://github.com/flatpak/xdg-desktop-portal/issues/472>
          #
          # the alternative to patching is to instead manually populate ~/.local/share/flatpak/db
          # according to this format (binary):
          # - <https://github.com/flatpak/xdg-desktop-portal/wiki/The-Permission-Store/16760c9f2e0a7ea7333ad5b190bd651ddc700897#storage-data-format>
          substituteInPlace --replace-fail src/open-uri.c \
            '#define DEFAULT_THRESHOLD 3' '#define DEFAULT_THRESHOLD 0'
        '';
      })
    );

    # the portal is a launcher, needs to handle anything
    sandbox.enable = false;

    services.xdg-desktop-portal = {
      description = "xdg-desktop-portal freedesktop.org portal (URI opener, file chooser, etc)";
      after = [ "graphical-session.target" ];
      # partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart="${cfg.package}/libexec/xdg-desktop-portal";
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
        # Type = "dbus";
        # BusName = "org.freedesktop.portal.Desktop";
      };

      # tracking issue for having xdg-desktop-portal locate portals via more standard directories, obviating this var:
      # - <https://github.com/flatpak/xdg-desktop-portal/issues/603>
      # i can actually almost omit it today; problem is that if you don't set it it'll look for `sway-portals.conf` in ~/.config/xdg-desktop-portal
      # but then will check its *own* output dir for {gtk,wlr}.portal.
      # arguable if that's a packaging bug, or limitation...
      environment.XDG_DESKTOP_PORTAL_DIR = "%E/xdg-desktop-portal";

      environment.G_MESSAGES_DEBUG = "all";
    };
  };

  # after #603 is resolved, i can probably stop linking `{gtk,wlr}.portal` into ~
  # and link them system-wide instead.
  # environment.pathsToLink = lib.mkIf cfg.enabled [
  #   "/share/xdg-desktop-portal/portals"
  # ];
}

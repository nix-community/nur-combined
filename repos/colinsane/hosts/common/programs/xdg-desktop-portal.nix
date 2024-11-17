# xdg-desktop-portal:
# - dbus user service which allows sandboxed applications to request specific things from their external environment.
# - frequently paired with portal implementations like `xdg-desktop-portal-gtk`, `xdg-desktop-portal-wlr`
#   wherein `xdg-desktop-portal` is the only component which speaks to the outside world, and the implementations speak only to the xdg-desktop-portal.
# - org.freedesktop.portal.OpenURI:
#   - <https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.OpenURI.html>
#   - request that the OS open some URI for the user
#   - optionally provide a list of recommended .desktop files to handle the URI
#   - xdg-desktop-portal dispatches this request to the backend (xdg-desktop-portal-gtk) which will present an app chooser to the user by default
#   - xdg-desktop-portal then executes the chosen .desktop file, passing it the URI.
#   - example (glib): `gdbus call --session --timeout 10 --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.OpenURI.OpenURI '' 'https://www.google.com' "{'ask': <false>}"`
#   - force non-flatpak glib apps to use this portal with: GTK_USE_PORTAL=1 or GIO_USE_PORTALS=1 (and then making sure the app can't see mimeapps.list)
# - org.freedesktop.portal.DynamicLauncher
#   - <https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.DynamicLauncher.html>
#   - whereas OpenURI requires a URI argument, DynamicLauncher is just "launch an app by <app_id>.desktop"
#   - example (glib): `gdbus call --session --timeout 10 --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.DynamicLauncher.Launch 'audacity.desktop' "{}"`
#   - .desktop files are searched for in ~/.local/share/xdg-desktop-portal/applications
#
# debugging:
# - show available portals: <https://codeberg.org/tytan652/door-knocker>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal;
in
{
  sane.programs.xdg-desktop-portal = {
    # rmDbusServices: because we care about ordering with the rest of the desktop, and don't want something else to auto-start this.
    packageUnwrapped = pkgs.rmDbusServicesInPlace (
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
          #
          # DEFAULT_THRESHOLD=0: fixes URLs to unconditionally open in browser, but all other file types
          # still require at least one manual choice (see `should_use_default_app`).
          # substituteInPlace src/open-uri.c \
          #   --replace-fail '#define DEFAULT_THRESHOLD 3' '#define DEFAULT_THRESHOLD 0'
          #
          substituteInPlace src/open-uri.c \
            --replace-fail 'if (default_app != NULL && use_default_app)' 'if (default_app != NULL)'
        '';
      })
    );

    # the portal is a launcher, needs to handle anything
    sandbox.enable = false;

    # portal can use the same .desktop files from the rest of my config.
    fs.".local/share/xdg-desktop-portal/applications".symlink.target = "../applications";

    env.GIO_USE_PORTALS = "1";  # instruct gio/gtk apps to use portal services; mostly not needed, except for legacy gtk3 apps like `geary`

    services.xdg-desktop-portal = {
      description = "xdg-desktop-portal freedesktop.org portal (URI opener, file chooser, etc)";
      partOf = [ "graphical-session" ];

      # tracking issue for having xdg-desktop-portal locate portals via more standard directories, obviating this var:
      # - <https://github.com/flatpak/xdg-desktop-portal/issues/603>
      # i can actually almost omit it today; problem is that if you don't set it it'll look for `sway-portals.conf` in ~/.config/xdg-desktop-portal
      # but then will check its *own* output dir for {gtk,wlr}.portal.
      # arguable if that's a packaging bug, or limitation...
      command = lib.concatStringsSep " " [
        "env"
        ''XDG_DESKTOP_PORTAL_DIR=''${HOME}/.config/xdg-desktop-portal''
        "G_MESSAGES_DEBUG=xdg-desktop-portal=all"
        "${cfg.package}/libexec/xdg-desktop-portal"
      ];
      readiness.waitDbus = "org.freedesktop.portal.Desktop";
    };

    services.xdg-permission-store = {
      # xdg-desktop-portal would *usually* dbus-activate this.
      # this service might not strictly be necssary. xdg-desktop-portal does warn if it's not present, though.
      description = "xdg-permission-store: lets xdg-desktop-portal know which handlers are 'safe'";
      # after = [ "graphical-session" ];
      dependencyOf = [ "xdg-desktop-portal" ];

      command = lib.concatStringsSep " " [
        "env"
        ''XDG_DESKTOP_PORTAL_DIR=''${HOME}/.config/xdg-desktop-portal''
        "${cfg.package}/libexec/xdg-permission-store"
      ];
      readiness.waitDbus = "org.freedesktop.impl.portal.PermissionStore";
    };
    # also available: ${cfg.package}/libexec/xdg-document-portal
    # - <https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Documents.html>
    # - shares files from its namespace with programs inside a namespace, via a fuse mount at $XDG_RUNTIME_DIR/doc
  };

  # after #603 is resolved, i can probably stop linking `{gtk,wlr}.portal` into ~
  # and link them system-wide instead.
  # environment.pathsToLink = lib.mkIf cfg.enabled [
  #   "/share/xdg-desktop-portal/portals"
  # ];
}

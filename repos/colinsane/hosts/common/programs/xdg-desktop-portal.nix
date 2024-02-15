{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal;
in
{
  sane.programs.xdg-desktop-portal = {
    packageUnwrapped = pkgs.xdg-desktop-portal.overrideAttrs (upstream: {
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
    });

    # the portal is a launcher, needs to handle anything
    sandbox.enable = false;

    services.xdg-desktop-portal = {
      description = "Portal service";
      wantedBy = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart="${cfg.package}/libexec/xdg-desktop-portal";
        Type = "dbus";
        BusName = "org.freedesktop.portal.Desktop";
      };

      # xdg-desktop-portal expects to act as a strict frontend and manage xdg-desktop-portal-{gtk,wlr,etc} itself,
      # which means it needs to know how which endpoints each backend provides and how to launch it,
      # encoded in /share/xdg-desktop-portal/portals:
      #
      # tracking issue for having xdg-desktop-portal locate portals via more standard directories, obviating this var:
      # - <https://github.com/flatpak/xdg-desktop-portal/issues/603>
      environment.XDG_DESKTOP_PORTAL_DIR = "/etc/profiles/per-user/%u/share/xdg-desktop-portal/portals";
    };
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [
    "/share/xdg-desktop-portal/portals"
  ];
}

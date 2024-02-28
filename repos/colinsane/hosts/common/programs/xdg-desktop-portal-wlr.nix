{ config, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-wlr;
in
{
  sane.programs.xdg-desktop-portal-wlr = {
    # rmDbusServices: because we care about ordering with the rest of the desktop, and don't want something else to auto-start this.
    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.xdg-desktop-portal-wlr;

    sandbox.method = "bwrap";  # TODO:sandbox: untested
    sandbox.whitelistDbus = [ "user" ];  # speak to main xdg-desktop-portal
    sandbox.whitelistWayland = true;

    fs.".config/xdg-desktop-portal/portals/wlr.portal".symlink.target =
      "${cfg.package}/share/xdg-desktop-portal/portals/wlr.portal";
    # XXX: overcome bug when manually setting `$XDG_DESKTOP_PORTAL_DIR`
    #      which causes *.portal files to be looked for in the toplevel instead of under `portals/`
    fs.".config/xdg-desktop-portal/wlr.portal".symlink.target = "portals/wlr.portal";

    services.xdg-desktop-portal-wlr = {
      description = "xdg-desktop-portal-wlr backend (provides screenshot functionality for xdg-desktop-portal)";
      after = [ "graphical-session.target" ];
      before = [ "xdg-desktop-portal.service" ];
      wantedBy = [ "xdg-desktop-portal.service" ];

      serviceConfig = {
        ExecStart="${cfg.package}/libexec/xdg-desktop-portal-wlr";
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}

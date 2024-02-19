{ config, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-gtk;
in
{
  sane.programs.xdg-desktop-portal-gtk = {
    # rmDbusServices: because we care about ordering with the rest of the desktop, and don't want something else to auto-start this.
    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.xdg-desktop-portal-gtk;

    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";
    sandbox.whitelistDbus = [ "user" ];  # speak to main xdg-desktop-portal
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".local/share/applications"  # file opener needs to find .desktop files, for their icon/name.
      # for file-chooser portal users (fractal, firefox, ...), need to provide anything they might want.
      # i think (?) portal users can only access the files here interactively, i.e. by me interacting with the portal's visual filechooser,
      # so shoving stuff here is trusting the portal but not granting any trust to the portal user.
      "Books"
      "Music"
      "Pictures"
      "Pictures/servo-macros"
      "Videos"
      "Videos/servo"
      "archive"
      "dev"
      "ref"
      "tmp"
      "use"
    ];

    fs.".config/xdg-desktop-portal/portals/gtk.portal".symlink.target =
      "${cfg.package}/share/xdg-desktop-portal/portals/gtk.portal";
    # XXX: overcome bug when manually setting `$XDG_DESKTOP_PORTAL_DIR`
    #      which causes *.portal files to be looked for in the toplevel instead of under `portals/`
    fs.".config/xdg-desktop-portal/gtk.portal".symlink.target = "portals/gtk.portal";

    services.xdg-desktop-portal-gtk = {
      description = "xdg-desktop-portal-gtk backend (provides graphical dialogs for xdg-desktop-portal)";
      after = [ "graphical-session.target" ];
      before = [ "xdg-desktop-portal.service" ];
      wantedBy = [ "xdg-desktop-portal.service" ];

      serviceConfig = {
        ExecStart="${cfg.package}/libexec/xdg-desktop-portal-gtk";
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}

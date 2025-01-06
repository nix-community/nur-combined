{ config, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-gtk;
in
{
  sane.programs.xdg-desktop-portal-gtk = {
    # rmDbusServices: because we care about ordering with the rest of the desktop, and don't want something else to auto-start this.
    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.xdg-desktop-portal-gtk;

    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # speak to main xdg-desktop-portal
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".local/share/applications"  # file opener needs to find .desktop files, for their icon/name.
      # for file-chooser portal users (fractal, firefox, ...), need to provide anything they might want.
      # i think (?) portal users can only access the files here interactively, i.e. by me interacting with the portal's visual filechooser,
      # so shoving stuff here is trusting the portal but not granting any trust to the portal user.
      "Books/Audiobooks"
      "Books/Books"
      "Books/Visual"
      "Books/local"
      "Books/servo"
      "Music"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "archive"
      "dev"
      "ref"
      "tmp"
      "use"
    ];

    services.xdg-desktop-portal-gtk = {
      description = "xdg-desktop-portal-gtk backend (provides graphical dialogs for xdg-desktop-portal)";
      # depends = [ "graphical-session" ];
      dependencyOf = [ "xdg-desktop-portal" ];

      command = "${cfg.package}/libexec/xdg-desktop-portal-gtk";
      readiness.waitDbus = "org.freedesktop.impl.portal.desktop.gtk";
    };
  };
}

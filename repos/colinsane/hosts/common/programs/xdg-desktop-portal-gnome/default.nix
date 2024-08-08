# XXX(2024-08-07): xdg-desktop-portal-gnome has a nicer filechooser than xdg-desktop-portal-gtk.
# especially, mobile friendly.
# but starting with 47.0 (unreleased), it will switch to Nautilus. so expect some work in porting.
{ config, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-gnome;
in
{
  sane.programs.xdg-desktop-portal-gnome = {
    packageUnwrapped = pkgs.xdg-desktop-portal-gnome.overrideAttrs (base: {
      patches = (base.patches or []) ++ [
        ./init_display_no_mutter.diff
      ];
    });

    fs.".config/xdg-desktop-portal/portals/gnome.portal".symlink.target =
      "${cfg.packageUnwrapped}/share/xdg-desktop-portal/portals/gnome.portal";
    # XXX: overcome bug when manually setting `$XDG_DESKTOP_PORTAL_DIR`
    #      which causes *.portal files to be looked for in the toplevel instead of under `portals/`
    fs.".config/xdg-desktop-portal/gnome.portal".symlink.target = "portals/gnome.portal";

    services.xdg-desktop-portal-gnome = {
      description = "xdg-desktop-portal-gnome backend (provides file chooser and other functionality for xdg-desktop-portal)";
      dependencyOf = [ "xdg-desktop-portal" ];

      command = "XDG_SESSION_TYPE=wayland ${cfg.package}/libexec/xdg-desktop-portal-gnome";
      readiness.waitDbus = "org.freedesktop.impl.portal.desktop.gnome";
    };
  };
}

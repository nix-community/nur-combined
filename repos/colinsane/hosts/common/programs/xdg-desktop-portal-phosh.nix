{ config, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-phosh;
in
{
  sane.programs.xdg-desktop-portal-phosh = {
    packageUnwrapped = pkgs.xdg-desktop-portal-phosh.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.wrapGAppsHook4 # pkgs.wrapGAppsNoGuiHook is not enough. it needs at least the `org.gnome.desktop.interface` schemas
      ];
    });

    sandbox.method = null;  #< TODO: sandbox

    services.xdg-desktop-portal-phosh = {
      description = "xdg-desktop-portal-phosh backend (provides FileChooser; Notifications, Settings, Wallpaper)";
      # N.B.: `phrosh` version (libexec/xdg-desktop-portal-phrosh) provides AppCHooser and Account portals
      dependencyOf = [ "xdg-desktop-portal" ];
      command = "${cfg.package}/libexec/xdg-desktop-portal-phosh";
      readiness.waitDbus = "org.freedesktop.impl.portal.desktop.phosh";
    };
  };
}

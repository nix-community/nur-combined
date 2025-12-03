# XXX(2025-11-24): xdg-desktop-portal-phosh crashes, fails to start:
# > xdg-desktop-portal-phosh[2138670]: g_settings_schema_source_lookup: assertion 'source != NULL' failed
# > xdg-desktop-portal-phosh-start: Segmentation fault
{ config, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-phosh;
in
{
  sane.programs.xdg-desktop-portal-phosh = {
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

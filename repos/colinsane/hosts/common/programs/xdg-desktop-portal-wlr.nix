{ config, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-wlr;
in
{
  sane.programs.xdg-desktop-portal-wlr = {
    # rmDbusServices: because we care about ordering with the rest of the desktop, and don't want something else to auto-start this.
    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.xdg-desktop-portal-wlr;

    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # speak to main xdg-desktop-portal
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      # not sure why it needs these
      "/sys/dev/char"
      "/sys/devices"
      "/tmp"  #< this is where it places screenshot data to share with consumers
    ];
    sandbox.mesaCacheDir = ".cache/xdg-desktop-portal-wlr/mesa";  # TODO: is this the correct app-id?

    services.xdg-desktop-portal-wlr = {
      description = "xdg-desktop-portal-wlr backend (provides screenshot functionality for xdg-desktop-portal)";
      depends = [ "pipewire" ];  # refuses to start without it
      dependencyOf = [ "xdg-desktop-portal" ];
      # partOf = [ "graphical-session" ];

      command = "${cfg.package}/libexec/xdg-desktop-portal-wlr";
      readiness.waitDbus = "org.freedesktop.impl.portal.desktop.wlr";
    };
  };
}

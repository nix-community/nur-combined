{ lib, pkgs, ... }:
let
  inherit (pkgs.kagi-epiphany) appId;
  desktop = "${appId}.desktop";
in
{
  sane.programs.kagi-epiphany = {
    sandbox.method = null;  #< TODO: sandbox
    sandbox.net = "clearnet";
    sandbox.whitelistDbus.user = true; #< TODO: finer-grain dbus sandboxing
    # sandbox.whitelistPortal = [
    #   "OpenURI"
    # ];
    # sandbox.whitelistDbus.user.own = [
    #   "org.gnome.Epiphany.WebApp_Kagi"
    # ];
    sandbox.whitelistWayland = true;

    sandbox.extraEnv.GIO_USE_PROXY_RESOLVER = "dummy";

    sandbox.extraPaths = [
      # epiphany sandboxes *itself* with bwrap, and dbus-proxy which, confusingly, causes it to *require* these paths.
      # TODO: these could maybe be mounted empty.
      "/sys/block"
      "/sys/bus"
      "/sys/class"
      "/sys/dev"
      "/sys/devices"
    ];

    buildCost = lib.mkDefault 2;

    mime.urlAssociations."^https?://(www\\.)?kagi.com$" = desktop;
    mime.urlAssociations."^https?://(www\\.)?kagi.com/.*$" = desktop;

    persist.byStore.private = [
      ".local/share/${appId}"
    ];
  };
}

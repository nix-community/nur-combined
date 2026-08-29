{ lib, pkgs, ... }:
let
  inherit (pkgs.ebay-epiphany) appId;
  desktop = "${appId}.desktop";
in
{
  sane.programs.ebay-epiphany = {
    sandbox.net = "clearnet";
    sandbox.whitelistPortal = [
      "Camera"  # otherwise it pegs the CPU and is unusable
      "DynamicLauncher"
      "OpenURI"
    ];
    sandbox.whitelistDbus.user.own = [
      appId
    ];
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

    mime.urlAssociations."^https?://([A-Za-z0-9-]+\\.)*ebay\\.com([/?].*)?$" = desktop;

    persist.byStore.private = [
      ".local/share/${appId}"
    ];
  };
}

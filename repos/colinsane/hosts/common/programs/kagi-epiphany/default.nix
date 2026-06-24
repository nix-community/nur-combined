{ lib, pkgs, ... }:
let
  inherit (pkgs.kagi-epiphany) appId;
  desktop = "${appId}.desktop";
in
{
  sane.programs.kagi-epiphany = {
    sandbox.method = null;  #< TODO: sandbox
    # sandbox.net = "clearnet";
    # sandbox.whitelistPortal = [
    #   "OpenURI"
    # ];
    # sandbox.whitelistWayland = true;

    buildCost = lib.mkDefault 2;

    mime.urlAssociations."^https?://(www\\.)?kagi.com$" = desktop;
    mime.urlAssociations."^https?://(www\\.)?kagi.com/.*$" = desktop;

    persist.byStore.private = [
      ".local/share/${appId}"
    ];
  };
}

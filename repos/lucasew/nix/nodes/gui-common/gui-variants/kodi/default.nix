{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.xserver.desktopManager.kodi.enable {
    hardware.graphics.enable = true;

    services = {
      displayManager = {
        sessionData = {
          autologinSession = lib.mkDefault "kodi";
        };
      };
      xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
        desktopManager.kodi.package = pkgs.custom.kodi;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.services.xserver.desktopManager.plasma5.enable {
  services.xserver.enable = lib.mkDefault true;
  services.xserver.displayManager.sddm.enable = lib.mkDefault true;
}

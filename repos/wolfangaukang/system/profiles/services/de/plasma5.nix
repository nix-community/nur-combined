{ config, lib, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "colemak";
    desktopManager.plasma5.enable = true;
    displayManager = {
      sddm.enable = true;
    };
  };
}

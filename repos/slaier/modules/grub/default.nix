{ config, ... }:
{
  boot.loader.grub = {
    enable = true;
    darkmatter-theme = {
      enable = true;
      style = "nixos";
    };
    default = "saved";
    device = "nodev";
    gfxmodeEfi = "1920x1080";
    efiSupport = true;
    useOSProber = true;
    splashImage = "${config.boot.loader.grub.theme}/background.png";
  };
  boot.loader.efi.canTouchEfiVariables = true;
}

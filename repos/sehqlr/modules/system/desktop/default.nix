{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    android-file-transfer
    gimp
    inkscape
    libreoffice
    networkmanagerapplet
    nix-prefetch-scripts
    vlc
  ];

  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
  };

  users.users.guest.isNormalUser = true;

  # for KDEConnect
  networking.firewall = let
    ranges = [{
      from = 1714;
      to = 1764;
    }];
  in {
    allowedTCPPortRanges = ranges;
    allowedUDPPortRanges = ranges;
  };

  fonts.enableDefaultFonts = true;

  services.flatpak.enable = true;
  xdg.portal.enable = true;
}

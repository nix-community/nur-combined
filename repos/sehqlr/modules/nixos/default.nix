{ config, lib, pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPackages = with pkgs; [
    android-file-transfer
    commonsCompress
    gimp
    inkscape
    libreoffice
    networkmanagerapplet
    vlc
  ];
  fonts.enableDefaultFonts = true;
  networking.networkmanager.enable = true;
  nix.gc.automatic = true;
  services.flatpak.enable = true;
  services.ipfs.enable = true;
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.defaultSession = "none+xmonad";
  system.autoUpgrade.enable = true;
  system.copySystemConfiguration = true;
  users.users.guest.isNormalUser = true;
  users.users.sam.description = "Sam Hatfield <hey@samhatfield.me>";
  users.users.sam.extraGroups = [ "wheel" "networkmanager" ];
  users.users.sam.isNormalUser = true;
  users.users.sam.shell = pkgs.zsh;
  xdg.portal.enable = true;
}

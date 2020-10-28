{ config, lib, pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPackages = with pkgs; [
    android-file-transfer
    commonsCompress
    gimp
    inkscape
    libreoffice
    vlc
  ];
  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  nix.gc.automatic = true;
  programs.sway.enable = true;
  services.flatpak.enable = true;
  services.ipfs.enable = true;
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  system.autoUpgrade.enable = true;
  system.copySystemConfiguration = true;
  users.users.guest.isNormalUser = true;
  users.users.sam.description = "Sam Hatfield <hey@samhatfield.me>";
  users.users.sam.extraGroups = [ "wheel" "networkmanager" "audio"];
  users.users.sam.isNormalUser = true;
  users.users.sam.shell = pkgs.zsh;
  xdg.portal.enable = true;
}

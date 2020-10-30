{ config, lib, pkgs, ... }: {
  imports = [ ./ipfs.nix ./networking.nix ./sam.nix ];
  environment.systemPackages = with pkgs; [
    android-file-transfer
    commonsCompress
    libreoffice
    vlc
  ];

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
  fonts.fontconfig.defaultFonts.monospace = [ "FiraCode Mono" ];

  nix.gc.automatic = true;

  system.autoUpgrade.enable = true;
  system.copySystemConfiguration = true;
}

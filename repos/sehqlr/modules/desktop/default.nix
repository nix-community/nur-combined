{ config, lib, pkgs, ... }: {
  imports = [ ./networking.nix ./sam.nix ];

  environment.systemPackages = with pkgs; [
    android-file-transfer
    commonsCompress
    libreoffice
    vlc
  ];

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ "FiraCode Mono" ];
}

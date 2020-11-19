{ config, lib, pkgs, ... }: {
  imports = [ ./ipfs.nix ./sam.nix ];

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

  i18n.defaultLocale = "en_US.UTF-8";

  nix.gc.automatic = true;

  system.autoUpgrade.enable = true;
  system.copySystemConfiguration = true;
}

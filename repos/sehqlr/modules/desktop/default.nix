{ config, lib, pkgs, ... }: {
  imports = [ ./networking.nix ./sam.nix ];

  environment.systemPackages = with pkgs; [
    commonsCompress
  ];

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ "FiraCode Mono" ];
}

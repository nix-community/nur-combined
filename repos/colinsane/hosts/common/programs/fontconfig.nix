{ config, lib, pkgs, ... }:
{
  fonts = lib.mkIf config.sane.programs.fontconfig.enabled {
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      emoji = [ "Font Awesome 6 Free" "Noto Color Emoji" ];
      monospace = [ "Hack" ];
      serif = [ "DejaVu Serif" ];
      sansSerif = [ "DejaVu Sans" ];
    };
    enableDefaultFonts = true;
    fonts = with pkgs; [ font-awesome noto-fonts-emoji hack-font ];
  };
}

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
    #vvv enables dejavu_fonts, freefont_ttf, gyre-fonts, liberation_ttf, unifont, noto-fonts-emoji
    enableDefaultPackages = true;
    packages = with pkgs; [ font-awesome noto-fonts-emoji hack-font ];
  };
}

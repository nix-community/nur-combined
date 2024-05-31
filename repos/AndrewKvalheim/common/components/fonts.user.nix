{ pkgs, ... }:

{
  allowedUnfree = [
    "affine-font"
    "corefonts"
  ];

  home.packages = with pkgs; [
    affine-font
    corefonts
    iosevka-custom.mono
    iosevka-custom.proportional
    iosevka-custom.term
    noto-fonts-color-emoji
    roboto
    source-serif-pro
  ];

  dconf.settings = {
    "org/gnome/desktop/interface".font-name = "Roboto 11";
    "org/gnome/desktop/interface".document-font-name = "Roboto 11";
    "org/gnome/desktop/interface".monospace-font-name = "Iosevka Custom Mono 10";
    "org/gnome/desktop/wm/preferences".titlebar-font = "Roboto Bold 11";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.emoji = [ "Noto Color Emoji" ];
    defaultFonts.monospace = [ "Iosevka Custom Mono" ];
    defaultFonts.sansSerif = [ "Roboto" ];
    defaultFonts.serif = [ "Source Serif Pro" ];
  };
}

{ config, lib, pkgs, unstable, ... }:

let
  fontsList = with pkgs; [
    meslo-lg
    awesome
    dejavu_fonts
    open-sans
    inter
    rubik
    lato
    noto-fonts
    noto-fonts-color-emoji
    fira-code-nerdfont
    liberation_ttf
    nerdfonts
    inconsolata-nerdfont
    ubuntu_font_family
  ];
in
{
  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;
    packages = fontsList;

    fontconfig = {
      defaultFonts = {
        serif = [  "Liberation Serif"  ];
        sansSerif = [ "Ubuntu" "Vazirmatn" ];
        monospace = [ "Ubuntu Mono" ];
      };
    };
  };
  environment.systemPackages = fontsList;
}

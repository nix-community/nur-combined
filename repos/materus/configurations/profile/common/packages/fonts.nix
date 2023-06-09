{ pkgs, lib, ... }:

let
  defaultFonts = [
    pkgs.dejavu_fonts
    pkgs.freefont_ttf
    pkgs.gyre-fonts
    pkgs.liberation_ttf
    pkgs.unifont
  ];
  fonts = [
    pkgs.noto-fonts
    pkgs.noto-fonts-extra
    pkgs.noto-fonts-emoji
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    pkgs.wqy_zenhei
    pkgs.corefonts
    
  ] ++ defaultFonts;

  moreFonts = [
    pkgs.ubuntu_font_family
    pkgs.monocraft
    pkgs.hack-font
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Meslo" "ProFont" ]; })
  ];
in
{

  options.materus.profile.packages.list.fonts = lib.mkOption { default = fonts; readOnly = true; visible = false; };
  options.materus.profile.packages.list.moreFonts = lib.mkOption { default = moreFonts; readOnly = true; visible = false; };

}

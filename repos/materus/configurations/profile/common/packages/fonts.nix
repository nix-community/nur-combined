{ pkgs, lib, ... }:
let
  fonts = [
    pkgs.noto-fonts
    pkgs.noto-fonts-extra
    pkgs.noto-fonts-emoji
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    pkgs.wqy_zenhei
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Meslo" "ProFont" ]; })
  ];
  moreFonts = [
    pkgs.ubuntu_font_family
    pkgs.monocraft
    pkgs.dejavu_fonts
    pkgs.hack-font
  ];
in
{

  options.materus.profile.packages.list.fonts = lib.mkOption { default = fonts; readOnly = true; visible = false; };
  options.materus.profile.packages.list.moreFonts = lib.mkOption { default = moreFonts; readOnly = true; visible = false; };

}

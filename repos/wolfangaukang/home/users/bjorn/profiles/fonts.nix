{ pkgs, ... }:

let
  iosevka_nerdfonts = pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; };
in
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    arkpandora_ttf
    iosevka_nerdfonts
    meslo-lgs-nf
  ];
}

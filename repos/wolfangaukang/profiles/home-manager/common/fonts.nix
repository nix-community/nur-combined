{ pkgs, ... }:

let
  iosevka_nerdfonts = pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; };
in {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    iosevka_nerdfonts
    arkpandora_ttf
  ];
}

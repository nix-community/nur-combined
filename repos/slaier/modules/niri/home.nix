{ pkgs, ... }:
let
  bg = "backgrounds/nixos/nix-wallpaper-dracula.png";
in
{
  home.packages = [ pkgs.swaybg ];
  xdg.dataFile."${bg}".source = "${pkgs.nixos-artwork.wallpapers.dracula}/share/${bg}";
  xdg.configFile."niri/config.kdl".source = ./niri.kdl;
}

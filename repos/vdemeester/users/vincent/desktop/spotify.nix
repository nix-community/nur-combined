{ pkgs, ... }:

{
  # FIXME: need a .desktop file..
  home.packages = with pkgs; [
    spotify
  ];
}

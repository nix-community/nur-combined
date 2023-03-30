{ config, pkgs, ... }:

{
  imports = [

    ./home-base-all.nix

    ./files-linux

    ./conf-desktop-linux/firefox.nix
    ./conf-desktop-linux/xdg.nix
    ./conf-gnome

    /home/pim/nixos/private/adevinta/home-manager/files-main
  ];


}

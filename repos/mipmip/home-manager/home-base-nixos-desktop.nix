{ config, pkgs, ... }:

{
  imports = [

    ./home-base-all.nix

    ./files-linux

    ./programs/firefox.nix
    ./gnome

    /home/pim/nixos/private/adevinta/home-manager/files-main
  ];


}

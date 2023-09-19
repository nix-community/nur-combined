{ config, pkgs, ... }:

{
  imports = [
    ./home-base-all.nix
    ./files-macos
    ./conf-desktop-macos/macos-bundle.nix
  ];
}

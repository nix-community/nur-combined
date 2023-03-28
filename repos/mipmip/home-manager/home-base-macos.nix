{ config, pkgs, ... }:

{
  imports = [
    ./home-base-all.nix
    ./files-macos
    ./programs/macos-bundle.nix
  ];
}

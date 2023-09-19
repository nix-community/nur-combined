{ lib, config, pkgs, ... }:

{
  imports = [
    ./home-base-nixos-desktop.nix
    #./files-secondbrain
    #./files-i-am-desktop
  ];
}

{ config, lib, pkgs, ... }:

{

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [

    nix-index
    patchelf
    #nix-software-center
    nix-tree
  ];
}



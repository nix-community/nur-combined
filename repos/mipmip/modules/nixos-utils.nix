{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    nix-index
    patchelf
  ];
}



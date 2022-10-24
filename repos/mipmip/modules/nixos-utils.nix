{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    #inputs.comma.packages.${system}.default
    nix-index
    patchelf
    #nix-software-center
  ];
}



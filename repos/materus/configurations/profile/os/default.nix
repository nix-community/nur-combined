{ config, pkgs, ... }:
{ 
  imports = [
    ./nix.nix
    ./fonts.nix
    
    ./games
  ];
}

{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/home-manager/sets/cli.nix
    ../../profiles/home-manager/common/home.nix
  ];
}  

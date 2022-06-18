{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/home-manager/common/home.nix
  ];

  defaultajAgordoj.cli.enable = true;
}  

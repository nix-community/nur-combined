{ config, pkgs, ... }:
{
  imports = [
    ./hardware/elitebook840g5.nix
    ./modules/system-configuration
    ./modules/desktop-configuration
  ];
}

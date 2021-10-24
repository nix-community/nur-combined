{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mipmip_pkg.hl4150cdn
  ];
}


{ config, lib, pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.minecraft
    unstable.minecraft-server
  ];
}


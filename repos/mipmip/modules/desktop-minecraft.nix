{ config, lib, pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    #pkgs.prismlauncher
    #pkgs.jdk17
    #pkgs.minecraft
    #pkgs.minecraft-server
  ];
}


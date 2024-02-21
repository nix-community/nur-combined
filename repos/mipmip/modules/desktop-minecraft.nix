{ config, lib, pkgs, pkgs-2311, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.prismlauncher
    unstable.jdk17
    unstable.minecraft
    unstable.minecraft-server
  ];
}


{ config, lib, pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.prismlauncher
    unstable.minecraft
    unstable.minecraft-server
  ];
}


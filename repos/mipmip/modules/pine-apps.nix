{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tmux
    htop
  ];
}


{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zoom-us
    teams
    slack
  ];
}


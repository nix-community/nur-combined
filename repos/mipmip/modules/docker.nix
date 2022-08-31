{ config, lib, pkgs, ... }:

{

  services.onedrive.enable = true;
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];
}




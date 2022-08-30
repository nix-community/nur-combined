{ config, lib, pkgs, ... }:

{

  services.onedrive.enable = true;

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];
}




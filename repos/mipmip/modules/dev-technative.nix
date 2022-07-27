{ config, lib, pkgs, ... }:

{

  services.onedrive.enable = true;

  environment.systemPackages = with pkgs; [
    pre-commit
    aws-mfa
    unstable.cloud-nuke
    awscli2
  ];
}


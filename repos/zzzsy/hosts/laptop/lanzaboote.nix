{ pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.sbctl
    pkgs.mokutil
  ];
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}

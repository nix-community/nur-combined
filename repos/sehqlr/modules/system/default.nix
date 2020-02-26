{ config, lib, pkgs, ... }:
{
  imports = [ ./desktop ./headless ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;
  services.ipfs.enable = true;

  nix.gc.automatic = true;
  system.autoUpgrade.enable = true;
  system.copySystemConfiguration = true;

  environment.pathsToLink = [ "/share/zsh" ];
  users.users.sam = {
    description = "Sam Hatfield <hey@samhatfield.me>";
    extraGroups = [ "wheel" "networkmanager" ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}

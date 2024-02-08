{ config, inputs, system, pkgs, unstable, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/base-common.nix
      ../../modules/base-git.nix
      ../../modules/desktop-firefox.nix
      ../../modules/desktop-gnome-45.nix
      ../../modules/nix-vm-test.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
       experimental-features = nix-command flakes
    '';
  };

  boot.plymouth.enable = true;
  boot.plymouth.theme="breeze";
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;

  networking.hostName = "gnome-45";
  networking.firewall.enable = false;
  system.stateVersion = "23.11";
}

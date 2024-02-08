# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, nixpkgs, inputs, system, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/base-common.nix
      ../../modules/base-git.nix
      ../../modules/desktop-firefox.nix
      ../../modules/desktop-fonts.nix
      ../../modules/desktop-grannyos.nix
      ../../modules/nix-desktop.nix
      ../../modules/nix-vm-test.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
            experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  #boot.kernelPackages = unstable.linuxPackages_latest;
  networking.hostName = "grannyos";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?


}

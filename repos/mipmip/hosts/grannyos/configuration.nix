# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, system, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/base-common.nix
      ../../modules/base-git.nix
      #../../modules/base-vim.nix

      ../../modules/desktop-firefox.nix
      ../../modules/desktop-fonts.nix
      ../../modules/desktop-gnome.nix

      ../../modules/nix-common.nix
      ../../modules/nix-desktop.nix
      ../../modules/nix-utils.nix
      ../../modules/nix-vm-test.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
            experimental-features = nix-command flakes
    '';
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  #boot.kernelPackages = unstable.linuxPackages_latest;
  networking.hostName = "grannyos";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize =  2048; # Use 2048MiB memory.
      cores = 3;
    };
  };

  users.users.pim.initialPassword = "test";

}

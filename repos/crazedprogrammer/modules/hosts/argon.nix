# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      ../server
    ];
  nixpkgs.overlays = import ../../pkgs/overlays;

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.tmpOnTmpfs = true;

  swapDevices = [ ];

  nix = {
    maxJobs = 4;
    buildCores = 4;
    useSandbox = "relaxed";
  };

  ## Everything below is generated from nixos-in-place; modify with caution!
  boot.kernelParams = ["boot.shell_on_fail"];
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.storePath = "/nixos/nix/store";
  boot.initrd.supportedFilesystems = [ "ext4" ];
  boot.initrd.postDeviceCommands = ''
    mkdir -p /mnt-root/old-root ;
    mount -t ext4 /dev/sda2 /mnt-root/old-root ;
  '';
  fileSystems = {
    "/" = {
      device = "/old-root/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
    "/old-root" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      ports = [18903];
    };
    # Enable the RSync daemon.
    rsyncd = {
      enable = true;
    };
  };
  programs.mosh.enable = true;

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Fix every terminal issue...
  environment.sessionVariables = { TERM = "xterm-256color"; };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";
}

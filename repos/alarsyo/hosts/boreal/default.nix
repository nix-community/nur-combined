# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  secrets = config.my.secrets;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./home.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [
    "btrfs"
    "ntfs"
  ];

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };
  };

  networking.hostName = "boreal"; # Define your hostname.
  networking.domain = "alarsyo.net";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.interfaces.enp8s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # List services that you want to enable:
  my.services = {
    borg-backup = {
      enable = true;
      repo = secrets.borg-backup.boreal-repo;
      # for a workstation, having backups spanning the last month should be
      # enough
      prune = {
        keep = {
          daily = 7;
          weekly = 4;
        };
      };
      paths = [
        "/home/alarsyo"
      ];
      exclude = [
        "/home/alarsyo/Downloads"

        # Rust builds using half my storage capacity
        "/home/alarsyo/*/target"
        "/home/alarsyo/work/rust/build"

        # don't backup nixpkgs
        "/home/alarsyo/work/nixpkgs"

        # C build crap
        "*.a"
        "*.o"
        "*.so"

        # ignore all dotfiles as .config and .cache can become quite big
        "/home/alarsyo/.*"
      ];
    };

    pipewire.enable = true;

    tailscale.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
    };
  };
  my.gui = {
    enable = true;
    isNvidia = true;
  };

  my.wakeonwlan.interfaces.phy0.methods = [
    "magic-packet"
    "disconnect"
    "gtk-rekey-failure"
    "eap-identity-request"
    "rfkill-release"
  ];

  services.udev.packages = with pkgs; [
    packages.kaleidoscope-udev-rules
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}

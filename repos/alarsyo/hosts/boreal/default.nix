# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./home.nix

    ./secrets.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmpOnTmpfs = true;

  boot.supportedFilesystems = [
    "btrfs"
    "ntfs"
  ];

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };
  };

  networking.hostName = "boreal"; # Define your hostname.
  networking.domain = "alarsyo.net";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List services that you want to enable:
  my.services = {
    restic-backup = {
      enable = true;
      repo = "b2:boreal-backup";
      passwordFile = config.age.secrets."restic-backup/boreal-password".path;
      environmentFile = config.age.secrets."restic-backup/boreal-credentials".path;

      paths = [
        "/home/alarsyo"
      ];
      exclude = [
        "/home/alarsyo/Downloads"

        # Rust builds using half my storage capacity
        "/home/alarsyo/**/target"
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

  services.udev.packages = [pkgs.chrysalis];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}

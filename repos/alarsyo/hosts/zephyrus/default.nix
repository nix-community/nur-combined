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

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };
  };

  networking.hostName = "zephyrus"; # Define your hostname.
  networking.domain = "alarsyo.net";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List services that you want to enable:
  my.services = {
    tailscale.enable = true;

    pipewire.enable = true;

    restic-backup = {
      enable = true;
      repo = "b2:zephyrus-backup";
      passwordFile = config.age.secrets."restic-backup/zephyrus-password".path;
      environmentFile = config.age.secrets."restic-backup/zephyrus-credentials".path;

      timerConfig = {
        OnCalendar = "*-*-* 13:00:00"; # laptop only gets used during the day
      };

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
  };

  services = {
    tlp = {
      settings = {
        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
    fwupd.enable = true;
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
    };
  };
  my.gui.enable = true;

  environment.systemPackages = [pkgs.arandr pkgs.chrysalis];

  services.udev.packages = [pkgs.packages.kaleidoscope-udev-rules];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings.General.Experimental = true;
  };

  programs.light.enable = true;
}

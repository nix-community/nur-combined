# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko-config.nix

    ./home.nix
    ./secrets.nix
  ];

  hardware.amdgpu.opencl = false;

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    consoleMode = "auto";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };
  };

  networking.hostName = "talos"; # Define your hostname.
  networking.domain = "alarsyo.net";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  programs = {
    light.enable = true;
  };
  services = {
    fwupd.enable = true;
    openssh.enable = true;
  };
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  my.services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    pipewire.enable = true;
  };

  my.gui.enable = true;
  my.displayManager.sddm.enable = lib.mkForce false;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings.General.Experimental = true;
  };

  # Configure console keymap
  console.keyMap = "us";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.xserver.desktopManager.plasma5.enable = true;
  services.power-profiles-daemon.enable = true;

  #programs.hyprland.enable = true;
  #programs.sway = {
  #  enable = true;
  #  wrapperFeatures.gtk = true;
  #};

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}

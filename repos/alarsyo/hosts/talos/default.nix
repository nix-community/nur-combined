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

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  # Set Wi-Fi regulatory domain. Currently always set to '00' (world), and could
  # lead to bad Wi-Fi performance
  boot.kernelParams = ["cfg80211.ieee80211_regdom=FR"];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

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
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

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
    libvirtd.enable = false;
    virtualbox.host = {
      enable = false;
    };
  };

  my.services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    pipewire.enable = true;

    restic-backup = {
      enable = true;
      repo = "b2:talos-backup";
      passwordFile = config.age.secrets."restic-backup/talos-password".path;
      environmentFile = config.age.secrets."restic-backup/talos-credentials".path;

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

        "/home/alarsyo/go"

        # C build crap
        "*.a"
        "*.o"
        "*.so"

        ".direnv"

        # test vms
        "*.qcow2"
        "*.vbox"
        "*.vdi"

        # secrets stay offline
        "/home/alarsyo/**/secrets"

        # ignore all dotfiles as .config and .cache can become quite big
        "/home/alarsyo/.*"
      ];
    };
  };

  my.gui.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings.General.Experimental = true;
  };

  hardware.keyboard.qmk.enable = true;
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

  # Enable the KDE Plasma Desktop Environment.
  my.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = [
    pkgs.foot
    # FIXME: is this needed?
    pkgs.darkman
  ];

  #programs.hyprland.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # TODO: These are overriden by files from
  # ~/.config/xdg-desktop-portal/sway-portals.conf so they should be moved to
  # home
  xdg.portal.config.sway = {
    "org.freedesktop.impl.portal.Settings" = "darkman";
    "org.freedesktop.impl.portal.Inhibit" = "none";
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}

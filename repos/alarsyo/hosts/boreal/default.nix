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

  boot.tmp.useTmpfs = true;

  boot.supportedFilesystems = {
    btrfs = true;
    ntfs = true;
  };

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

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };

  services = {
    openssh = {
      enable = true;
    };
  };
  my.gui = {
    enable = true;
    isNvidia = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    nvidia = {
      open = true;
      modesetting.enable = true;
    };
  };

  programs.foot.enable = true;
  my.displayManager.gdm.enable = true;
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "games";
    };
    defaultSession = "gnome";
  };
  services.desktopManager.gnome.enable = true;
  services.power-profiles-daemon.enable = true;

  programs.gamescope = {
    enable = true;
  };
  environment.systemPackages = [
    pkgs.gamescope-wsi
    pkgs.wineWowPackages.stable
    pkgs.bottles
    pkgs.lutris
    pkgs.gnomeExtensions.no-overview
  ];

  users.users.games = {
    hashedPassword = "$y$j9T$jOursEp6BvOSgyhtU0fca0$xAh.iLgoiDTswHVlAbvtHg4jOHXZuWhl55kSqlD.daA";
    isNormalUser = true;
    extraGroups = [
      "media"
      "networkmanager"
      "video" # for `light` permissions
    ];
    shell = pkgs.fish;
  };
}

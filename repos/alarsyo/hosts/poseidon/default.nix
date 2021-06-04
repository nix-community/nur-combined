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

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.supportedFilesystems = [ "btrfs" ];

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };
  };

  networking.hostName = "poseidon"; # Define your hostname.
  networking.domain = "alarsyo.net";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "163.172.11.110";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = {
    address = "163.172.11.1";
    interface = "eno1";
  };
  networking.nameservers = [
    "62.210.16.6"
    "62.210.16.7"
  ];
  my.networking.externalInterface = "eno1";

  # List services that you want to enable:
  my.services = {
    bitwarden_rs = {
      enable = true;
      privatePort = 8081;
      websocketPort = 3012;
    };

    borg-backup = {
      enable = true;
      repo = secrets.borg-backup.poseidon-repo;
    };

    fail2ban = {
      enable = true;
    };

    gitea = {
      enable = true;
      privatePort = 8082;
    };

    jellyfin = {
      enable = true;
    };

    lohr = {
      enable = true;
      port = 8083;
    };

    miniflux = {
      enable = true;
      adminCredentialsFile = "${../../secrets/miniflux-admin-credentials.secret}";
      privatePort = 8080;
    };

    matrix = {
      enable = true;
      registration_shared_secret = secrets.matrix-registration-shared-secret;
    };

    monitoring = {
      enable = true;
      useACME = true;
      domain = "monitoring.${config.networking.domain}";
    };

    nextcloud = {
      enable = true;
    };

    postgresql-backup = {
      enable = true;
    };

    tgv = {
      enable = true;
    };

    transmission = {
      enable = true;
      username = "alarsyo";
      password = secrets.transmission-password;
    };

    wireguard = {
      enable = true;
      iface = "wg";
      port = 51820;

      net = {
        v4 = {
          subnet = "10.0.0";
          mask = 24;
        };
        v6 = {
          subnet = "fd42:42:42";
          mask = 64;
        };
      };
    };
  };

  security.acme.acceptTerms = true;
  security.acme.email = "antoine97.martin@gmail.com";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";
  services.openssh.passwordAuthentication = false;

  # Takes a long while to build
  documentation.nixos.enable = false;
}

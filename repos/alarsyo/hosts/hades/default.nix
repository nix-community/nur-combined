# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  ...
}: let
  secrets = config.my.secrets;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./home.nix
    ./secrets.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = ["/dev/sda" "/dev/sdb"];
  };

  boot.tmpOnTmpfs = true;

  networking.hostName = "hades"; # Define your hostname.
  networking.domain = "alarsyo.net";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking.useDHCP = false;
  networking.interfaces.enp35s0.ipv4.addresses = [
    {
      address = "95.217.121.60";
      prefixLength = 26;
    }
  ];
  networking.interfaces.enp35s0.ipv6.addresses = [
    {
      address = "2a01:4f9:4a:3649::2";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "95.217.121.1";
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp35s0";
  };
  networking.nameservers = ["1.1.1.1" "1.0.0.1"];
  my.networking.externalInterface = "enp35s0";

  # List services that you want to enable:
  my.services = {
    fail2ban.enable = true;

    matrix = {
      enable = true;
      secretConfigFile = config.age.secrets."matrix-synapse/secret-config".path;
    };

    miniflux = {
      enable = true;
      adminCredentialsFile = config.age.secrets."miniflux/admin-credentials".path;
      privatePort = 8080;
    };

    restic-backup = {
      enable = true;
      repo = "b2:hades-backup-alarsyo";
      passwordFile = config.age.secrets."restic-backup/hades-password".path;
      environmentFile = config.age.secrets."restic-backup/hades-credentials".path;
      paths = ["/home/alarsyo"];
    };

    tailscale = {
      enable = true;
      exitNode = true;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";
  services.openssh.passwordAuthentication = false;

  # Takes a long while to build
  documentation.nixos.enable = false;
}

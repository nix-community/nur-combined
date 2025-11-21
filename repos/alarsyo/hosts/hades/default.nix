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

  boot.tmp.useTmpfs = true;

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

    forgejo = {
      enable = true;
      privatePort = 8082;
    };

    immich = {
      enable = true;
      port = 8089;
    };

    jellyfin = {
      enable = true;
    };

    lohr = {
      enable = true;
      port = 8083;
    };

    matrix = {
      enable = true;
      secretConfigFile = config.age.secrets."matrix-synapse/secret-config".path;
    };

    mealie = {
      enable = true;
      port = 8090;
      credentialsFile = config.age.secrets."mealie/secret-config".path;
    };

    microbin = {
      enable = true;
      privatePort = 8088;
      passwordFile = config.age.secrets."microbin/secret-config".path;
    };

    miniflux = {
      enable = true;
      adminCredentialsFile = config.age.secrets."miniflux/admin-credentials".path;
      privatePort = 8080;
    };

    navidrome = {
      enable = true;
      musicFolder.path = "${config.services.nextcloud.home}/data/alarsyo/files/Musique/Songs";
    };

    nextcloud = {
      enable = true;
      adminpassFile = config.age.secrets."nextcloud/admin-pass".path;
    };

    nginx.enable = true;

    paperless = {
      enable = true;
      port = 8085;
      passwordFile = config.age.secrets."paperless/admin-password".path;
      secretKeyFile = config.age.secrets."paperless/secret-key".path;
    };

    pleroma = {
      enable = false;
      port = 8086;
      secretConfigFile = config.age.secrets."pleroma/pleroma-config".path;
    };

    restic-backup = {
      enable = true;
      repo = "b2:hades-backup-alarsyo";
      passwordFile = config.age.secrets."restic-backup/hades-password".path;
      environmentFile = config.age.secrets."restic-backup/hades-credentials".path;
      paths = ["/home/alarsyo"];
    };

    scribe = {
      enable = true;
      port = 8087;
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "server";
    };

    transmission = {
      enable = true;
      username = "alarsyo";
    };

    vaultwarden = {
      enable = true;
      privatePort = 8081;
      websocketPort = 3012;
    };
  };

  services = {
    openssh.enable = true;
    vnstat.enable = true;

    gitlab-runner = {
      enable = true;
      settings = {
        concurrent = 4;
      };
      services = {
        nix = {
          authenticationTokenConfigFile = config.age.secrets."gitlab-runner/hades-nix-runner-env".path;
          dockerImage = "alpine";
          dockerVolumes = [
            "/nix/store:/nix/store:ro"
            "/nix/var/nix/db:/nix/var/nix/db:ro"
            "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
          ];
          dockerDisableCache = true;
          preBuildScript = pkgs.writeScript "setup-container" ''
            mkdir -p -m 0755 /nix/var/log/nix/drvs
            mkdir -p -m 0755 /nix/var/nix/gcroots
            mkdir -p -m 0755 /nix/var/nix/profiles
            mkdir -p -m 0755 /nix/var/nix/temproots
            mkdir -p -m 0755 /nix/var/nix/userpool
            mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
            mkdir -p -m 1777 /nix/var/nix/profiles/per-user
            mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
            mkdir -p -m 0700 "$HOME/.nix-defexpr"

            . ${pkgs.nix}/etc/profile.d/nix.sh

            ${pkgs.nix}/bin/nix-env -i ${lib.concatStringsSep " " (with pkgs; [nix cacert git openssh])}

            ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixpkgs-unstable
            ${pkgs.nix}/bin/nix-channel --update nixpkgs

            mkdir -p ~/.config/nix
            echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
          '';
          environmentVariables = {
            ENV = "/etc/profile";
            USER = "root";
            NIX_REMOTE = "daemon";
            PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
            NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
          };
        };
      };
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # Takes a long while to build
  documentation.nixos.enable = false;
}

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
    ./disko-configuration.nix
    ./home.nix
    ./secrets.nix
  ];

  boot.loader.grub.enable = true;
  boot.tmp.useTmpfs = true;

  networking.hostName = "thanatos"; # Define your hostname.
  networking.domain = "lrde.epita.fr";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List services that you want to enable:
  my.services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };

  services = {
    gitlab-runner = {
      enable = true;
      settings = {
        concurrent = 4;
      };
      services = {
        nix = {
          authenticationTokenConfigFile = config.age.secrets."gitlab-runner/thanatos-nix-runner-env".path;
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
        default = {
          authenticationTokenConfigFile = config.age.secrets."gitlab-runner/thanatos-runner-env".path;
          dockerImage = "debian:stable";
        };
      };
    };
    openssh.enable = true;
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  nix.gc.automatic = lib.mkForce false;
}

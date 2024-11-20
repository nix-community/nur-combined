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
      services.default = {
        authenticationTokenConfigFile = config.age.secrets."gitlab-runner/thanatos-runner-env".path;
        dockerImage = "debian:stable";
      };
    };
    openssh.enable = true;
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}

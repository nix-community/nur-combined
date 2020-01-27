{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.kampka.profiles.common;

in
{

  environment.systemPackages = with pkgs; [
    bash

    less
    ncdu

    gnugrep

    coreutils
    utillinux

    atop
    iotop

    curl
    wget
    inetutils
    dnsutils

    gzip
    bzip2
    xz
  ];

  boot.cleanTmpDir = mkDefault (! config.boot.tmpOnTmpfs);

  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
  };

  networking.firewall.enable = mkDefault true;
  networking.firewall.logRefusedConnections = mkDefault false;
  networking.firewall.extraCommands = ''
    # Nixos firewall already adds a chain that rejects all incoming by default.
    # However, I find this is more explicit.
    iptables -P INPUT DROP
  '';

  kampka.services.ntp.enable = mkDefault true;
  kampka.services.dns-cache.enable = mkDefault true;
}

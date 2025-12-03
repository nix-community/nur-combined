{ config, pkgs, ... }:
{
  imports = [ ./hardware-config.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  vacu.hostName = "lp0onfire"; # Define your hostname.
  vacu.shortHostName = "lp0";
  vacu.shell.color = "green";
  vacu.systemKind = "server";

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano
    vim
    wget
    screen
    lsof
    htop
    mosh
    dnsutils
    iperf3
    nmap
    rsync
    ethtool
    sshfs
    ddrescue
    pciutils
    ncdu
    nix-index
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  services.openssh.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "1d719394047b32ae" ];
  };

  #opens udp ports for mosh
  programs.mosh.enable = true;

  # Disable wifi card; This is sitting directly under a router and I don't want to cause interference.
  boot.blacklistedKernelModules = [ "iwlwifi" ];
}

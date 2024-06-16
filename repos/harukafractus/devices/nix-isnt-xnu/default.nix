# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, config, lib, asahi, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./asahi-silicon
    ../_linux_options
  ];

  sessions = {
    gdm.enable = true;
    gnome-minimal.enable = true;
    ibus-engines.enable = true;
  };

  workstation = {
    airprint.enable = true;
    audio.enable = true;
    wifi.provider = "wpa_supplicant";
    battery.enable = true;
  };

  #system.fsPackages = with pkgs; [ ntfs3g apfs-fuse ];
  #boot.supportedFilesystems = [ "ntfs" "apfs" ];

  networking.hostName = "nix-isnt-xnu";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.adb.enable = true;

  system.stateVersion = "unstable";
}
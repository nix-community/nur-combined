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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };
  };

  networking.hostName = "zephyrus"; # Define your hostname.
  networking.domain = "alarsyo.net";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # List services that you want to enable:
  my.services = {
    tailscale.enable = true;

    pipewire.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
      layout = "fr";
      xkbVariant = "us";
      libinput.enable = true;
    };
    tlp = {
      settings = {
        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
    fwupd.enable = true;
  };
  my.displayManager.sddm.enable = true;

  environment.systemPackages = with pkgs; [
    arandr
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  programs.light.enable = true;
}

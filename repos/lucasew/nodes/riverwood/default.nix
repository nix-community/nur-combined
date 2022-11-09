# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{self, global, pkgs, config, lib, ... }:
let
  inherit (self) inputs;
  inherit (global) username;
  hostname = "riverwood";
in
{
  imports =
    [
      ../gui-common
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
      inputs.nixos-hardware.nixosModules.common-gpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

      ./tuning.nix
      ./networking.nix
      ./dns.nix
      ./kvm.nix
      ./backup-saves.nix
      ./plymouth.nix
      ./remote-build.nix
    ]
  ;

  environment.systemPackages = with pkgs; [
    kubectl
    terraform
  ];

  services.xserver.xkbModel = "acer_laptop";

  services.simple-dashboardd = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.kvmgt.enable = false;
  virtualisation.spiceUSBRedirection.enable = true;
 
  # programs.steam.enable = true;

  programs.kdeconnect.enable = true;

  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        efiSupport = true;
        #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
        device = "nodev";
        useOSProber = true;
      };
    };
  };

  gc-hold.paths = with pkgs; [
    go gopls
    terraform
    gnumake cmake
    clang gdb ccls
    python3Packages.pylsp-mypy
    nodejs yarn
    openjdk11 maven ant
    docker-compose
    jre
  ];

  networking.hostName = hostname; # Define your hostname.

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
 
  environment.dotd."/etc/trab/nhaa".enable = true;
  services.screenkey.enable = true;

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_5_15;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

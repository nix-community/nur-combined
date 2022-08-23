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
    ]
  ;

  services.xserver.xkbModel = "acer_laptop";

  services.simple-dashboardd.enable = true;
 
  # programs.steam.enable = true;

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
    nodejs yarn
    openjdk11 maven ant
  ];

  networking.hostName = hostname; # Define your hostname.
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
 
  # nix.distributedBuilds = true;
  # nix.buildMachines = [
  #   {
  #     hostName = "mtpc.local";
  #     sshUser = "lucas59356";
  #     system = "x86_64-linux";
  #     maxJobs = 3;
  #     speedFactor = 2;
  #     supportedFeatures = [ "big-parallel" "kvm" ];
  #   }
  # ];

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

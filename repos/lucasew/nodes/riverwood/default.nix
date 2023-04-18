# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{self, global, pkgs, config, lib, unpackedInputs, ... }@args:
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
      "${unpackedInputs.nixos-hardware}/common/cpu/intel/kaby-lake"
      "${unpackedInputs.nixos-hardware}/common/gpu/intel"
      "${unpackedInputs.nixos-hardware}/common/pc/laptop/ssd"

      ./tuning.nix
      ./networking.nix
      ./dns.nix
      ./kvm.nix
      # ./zfs.nix
      ./plymouth.nix
      ./remote-build.nix
    ]
  ;

  fonts.fonts = [ "/nix/store/v8jxb2lbcmch96zg7lhf6h4smxwa3l4m-whatsapp-emoji-linux-2.22.8.79-1" ];
  services.flatpak.enable = true;

  networking.networkmanager.wifi.scanRandMacAddress = true;
  networking.hostId = "dabd2d19";
  services.cockpit.enable = true;

  services.telegram-sendmail.enable = true;

  services.cloud-savegame = {
    enable = true;
    calendar = "01:00:01";
  };

  environment.systemPackages = with pkgs; [
    kubectl
    terraform
  ];

  programs.steam.enable = true;

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
    zig zls
    terraform
    ansible vagrant
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
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

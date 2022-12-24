{ config, pkgs, hostname, ... }:

{
  imports =
    [
      ./disk-setup.nix
      ./hardware-configuration.nix
      ../../system/profiles/console.nix
      ../../system/profiles/de/pantheon.nix
      ../../system/profiles/environment.nix
      ../../system/profiles/flatpak.nix
      ../../system/profiles/graphics.nix
      ../../system/profiles/layouts.nix
      ../../system/profiles/networking.nix
      ../../system/profiles/security.nix
      ../../system/profiles/time.nix
      ../../system/profiles/users.nix
    ];

  networking.hostName = hostname;

  profile = {
    gaming = {
      enable = true;
      useSteamHardware = true;
    };
    moonlander = {
      enable = true;
      ignoreLayoutSettings = true; 
    };
    nix = {
      enableAutoOptimise = true;
      enableFlakes = true;
      enableUseSandbox = true;
    };
    sound = {
      enable = true;
      enableOSSEmulation = true;
      pipewire = {
        enable = true;
        enableAlsa32BitSupport = true;
      };
    };
    virtualization = {
      podman.enable = true;
      qemu = {
        enable = true;
        extraPkgs = with pkgs; [ virt-manager ];
        libvirtdGroupMembers = [ "bjorn" ];
      };
    };
  };

  system.stateVersion = "21.05"; # Did you read the comment?
}


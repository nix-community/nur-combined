{ config, pkgs, ... }:

{
  imports =
    [
      ./disk-setup.nix
      ./hardware-configuration.nix
      ../../profiles/nixos/console.nix
      ../../profiles/nixos/de/pantheon.nix
      ../../profiles/nixos/environment.nix
      ../../profiles/nixos/flatpak.nix
      ../../profiles/nixos/graphics.nix
      ../../profiles/nixos/layouts.nix
      ../../profiles/nixos/networking.nix
      ../../profiles/nixos/security.nix
      ../../profiles/nixos/time.nix
      ../../profiles/nixos/users.nix
      # This will be commented because we are using flakes
      # ./hardware-extras.nix
    ];

  networking.hostName = "holuhraun";

  # IMPERMANENCE
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      "/etc/secrets/initrd"
      "/var/lib"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

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


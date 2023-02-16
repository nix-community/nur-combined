{ config, lib, pkgs, hostname, inputs, ... }:

let
  inherit (lib) mkForce;
  inherit (inputs) self;

in {
  imports =
    [
      ./disk-setup.nix
      ./hardware-configuration.nix
      "${self}/system/profiles/console.nix"
      "${self}/system/profiles/de/pantheon.nix"
      "${self}/system/profiles/environment.nix"
      "${self}/system/profiles/flatpak.nix"
      "${self}/system/profiles/graphics.nix"
      "${self}/system/profiles/layouts.nix"
      "${self}/system/profiles/networking.nix"
      "${self}/system/profiles/security.nix"
      "${self}/system/profiles/time.nix"
      "${self}/system/profiles/users.nix"
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

  specialisation.simplerisk = {
    inheritParentConfig = true;
    configuration = {
      profile = {
        virtualization = {
          qemu.enable = mkForce false;
          podman.enable = mkForce false;
        };
        work.simplerisk.enable = true;
      };
      home-manager.users.bjorn.defaultajAgordoj.work.simplerisk.enable = true;
    };
  };
}

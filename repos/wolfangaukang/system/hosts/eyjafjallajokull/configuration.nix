{ pkgs, config, lib, hostname, ... }:

let
  inherit (lib) mkForce;

in {
  imports = [
    ./disk-setup.nix
    ./hardware-configuration.nix
    ../../profiles/console.nix
    ../../profiles/de/pantheon.nix
    ../../profiles/environment.nix
    ../../profiles/flatpak.nix
    ../../profiles/graphics.nix
    ../../profiles/layouts.nix
    ../../profiles/networking.nix
    ../../profiles/rfkill.nix
    ../../profiles/security.nix
    ../../profiles/time.nix
    ../../profiles/users.nix
  ];

  networking.hostName = hostname;

  profile = {
    nix = {
      enableAutoOptimise = true;
      enableFlakes = true;
      enableUseSandbox = true;
    };
    mobile-devices = {
      android.enable = true;
      ios.enable = true;
    };
    sound = {
      enable = true;
      enableOSSEmulation = true;
      pipewire = {
        enable = true;
        enableAlsa32BitSupport = true;
      };
    };
    virtualization.podman.enable = true;
  };

  # Thinkpad brightness
  hardware.acpilight.enable = true;
  services.illum.enable = true;
  users.extraGroups.video.members = [ "bjorn" ];

  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "20.09";

  #specialisation.simplerisk = {
  #  inheritParentConfig = true;
  #  configuration = {
  #    system.nixos.tags = [ "simplerisk" ];
  #    profile = {
  #      virtualization.podman.enable = mkForce false;
  #      work.simplerisk.enable = true;
  #    };
  #    home-manager.users.bjorn.defaultajAgordoj.work.simplerisk.enable = true;
  #  };
  #};
}


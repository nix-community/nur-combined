{ config, lib, hostname, inputs, ... }:

let
  inherit (lib) mkForce;
  inherit (inputs) self;

in {
  imports = [
    ./disk-setup.nix
    ./hardware-configuration.nix
    "${self}/system/profiles/console.nix"
    "${self}/system/profiles/de/pantheon.nix"
    "${self}/system/profiles/environment.nix"
    "${self}/system/profiles/flatpak.nix"
    "${self}/system/profiles/graphics.nix"
    "${self}/system/profiles/layouts.nix"
    "${self}/system/profiles/networking.nix"
    "${self}/system/profiles/rfkill.nix"
    "${self}/system/profiles/security.nix"
    "${self}/system/profiles/time.nix"
    "${self}/system/profiles/users.nix"
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

  specialisation.simplerisk = {
    inheritParentConfig = true;
    configuration = {
      profile = {
        virtualization.podman.enable = mkForce false;
        work.simplerisk.enable = true;
      };
      home-manager.users.bjorn.defaultajAgordoj.work.simplerisk.enable = true;
    };
  };
}


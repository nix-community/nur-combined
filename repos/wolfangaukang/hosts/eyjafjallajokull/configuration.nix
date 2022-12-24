{ config, lib, hostname, ... }:

{
  imports = [
    ./disk-setup.nix
    ./hardware-configuration.nix
    ../../system/profiles/console.nix
    ../../system/profiles/de/pantheon.nix
    ../../system/profiles/environment.nix
    ../../system/profiles/flatpak.nix
    ../../system/profiles/graphics.nix
    ../../system/profiles/layouts.nix
    ../../system/profiles/networking.nix
    ../../system/profiles/rfkill.nix
    ../../system/profiles/security.nix
    ../../system/profiles/time.nix
    ../../system/profiles/users.nix
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
}


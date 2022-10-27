{ config, pkgs, ... }:

{
  imports = [
    ./disk-setup.nix
    ./hardware-configuration.nix
    ../../profiles/nixos/console.nix
    ../../profiles/nixos/de/pantheon.nix
    ../../profiles/nixos/environment.nix
    ../../profiles/nixos/flatpak.nix
    ../../profiles/nixos/graphics.nix
    ../../profiles/nixos/layouts.nix
    ../../profiles/nixos/networking.nix
    ../../profiles/nixos/rfkill.nix
    ../../profiles/nixos/security.nix
    ../../profiles/nixos/time.nix
    ../../profiles/nixos/users.nix
    # This will be commented because we are using flakes
    # ./hardware-extras.nix
  ];

  networking.hostName = "eyjafjallajokull";

  # IMPERMANENCE
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      "/etc/secrets/initrd"
      "/home"
      "/var/lib"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

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

  system.stateVersion = "20.09";
}


{ config, lib, hostname, inputs, ... }:

let
  inherit (lib) mkDefault;
  inherit (inputs) self;

in {
  imports = [
    ./disk-setup.nix
    ./hardware-configuration.nix
    "${self}/system/profiles/sets/workstation.nix"
  ];

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

  sops.secrets."machine_id" = {
    sopsFile = ./secrets.yml;
    mode = "0644";
  };

  #environment.etc.machine-id.source = config.sops.secrets."machine_id".path;

  # Thinkpad brightness
  hardware.acpilight.enable = true;
  services.illum.enable = true;
  users.extraGroups.video.members = [ "bjorn" ];

  # Extra settings (22.11)
  nixpkgs.hostPlatform = mkDefault "x86_64-linux";

  system.stateVersion = "23.05";
}


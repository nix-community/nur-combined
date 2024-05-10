{ config
, lib
, pkgs
, inputs
, hostname
, overlays
, ...
}:

let
  inherit (inputs) self;

in
{
  imports = [
    inputs.nixos-hardware.nixosModules.system76

    ./disk-setup.nix
    ./hardware-configuration.nix
    "${self}/system/profiles/workstation.nix"
    "${self}/system/profiles/hyprland.nix"
  ];

  # TODO: Change until VirtualBox can be built
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
  environment.etc.machine-id.source = config.sops.secrets."machine_id".path;
  networking.hostName = hostname;
  nixpkgs = {
    inherit overlays;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };
  profile = {
    batteryNotifier = {
      enable = true;
      suspend.capacityValue = 3;
    };
    nix = {
      enableAutoOptimise = true;
      enableFlakes = true;
      enableUseSandbox = true;
    };
    mobile-devices = {
      android.enable = true;
      ios.enable = true;
    };
    predicates.unfreePackages = [
      "burpsuite"
    ];
    sound = {
      enable = true;
      enableOSSEmulation = true;
      pipewire = {
        enable = true;
        enableAlsa32BitSupport = true;
      };
    };
    virtualization.podman.enable = true;
    specialisations.work.simplerisk.enable = true;
  };
  sops.secrets."machine_id" = {
    sopsFile = ./secrets.yml;
    mode = "0644";
  };
  system.stateVersion = "23.05";
}


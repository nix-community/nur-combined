{ config, lib, pkgs, hostname, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.system76

    ./disk-setup.nix
    ./hardware-configuration.nix
    "${inputs.self}/system/profiles/sets/workstation.nix"
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
    specialisations.work.simplerisk.enable = true;
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  sops.secrets."machine_id" = {
    sopsFile = ./secrets.yml;
    mode = "0644";
  };

  environment.etc.machine-id.source = config.sops.secrets."machine_id".path;

  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "23.05";
}


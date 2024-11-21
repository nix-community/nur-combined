{ lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t430

    ./disk-setup.nix
    ./hardware-configuration.nix
    "${inputs.self}/system/profiles/workstation.nix"
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_5;

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
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "23.05";
}


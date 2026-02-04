{
  config,
  lib,
  pkgs,
  inputs,
  hostname,
  overlays,
  localLib,
  ...
}:

let
  profiles = localLib.getNixFiles "${inputs.self}/system/profiles/" [
    "workstation"
    "sway"
  ];

in
{
  imports = profiles ++ [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel-gen6

    ./disk-setup.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18; # MUST USE THIS ONE TO RECOGNIZE DISPLAY OUTPUT IN SWAY
  environment.etc.machine-id.source = config.sops.secrets."machine_id".path;
  networking.hostName = hostname;
  nixpkgs = {
    inherit overlays;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };
  powerManagement.enable = true;
  profile = {
    batteryNotifier = {
      enable = config.programs.sway.enable || config.programs.hyprland.enable;
      suspend.capacityValue = 3;
    };
    virtualization.podman.enable = true;
  };
  services = {
    acpid.enable = true;
    openssh.hostKeys = localLib.generateSshHostKeyPaths;
    thinkfan.enable = true;
    xserver.xkb.layout = lib.mkForce "colemak-bs_cl,us";
  };
  sops = {
    age = localLib.generateSopsAgeInfo;
    secrets."machine_id" = {
      sopsFile = ./secrets.yml;
      mode = "0644";
    };
  };
  system.stateVersion = "23.05";
}

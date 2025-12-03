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
    inputs.nixos-hardware.nixosModules.system76
    inputs.self.nixosModules.system76-charging-thresholds

    ./disk-setup.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  environment.etc.machine-id.source = config.sops.secrets."machine_id".path;
  networking.hostName = hostname;
  nixpkgs = {
    inherit overlays;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };
  profile = {
    batteryNotifier = {
      enable = config.programs.sway.enable || config.programs.hyprland.enable;
      suspend.capacityValue = 3;
    };
    virtualization.podman.enable = true;
  };
  services = {
    openssh.hostKeys = localLib.generateSshHostKeyPaths;
    system76-charging-threshold = {
      enable = true;
      # profile = "balanced";
      profile = "custom";
      thresholds = {
        start = 85;
        end = 90;
      };
    };
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

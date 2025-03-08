{ config
, lib
, pkgs
, inputs
, hostname
, overlays
, localLib
, ...
}:

let
  profiles = localLib.getNixFiles "${inputs.self}/system/profiles/" [ "workstation" "sway" ];


in
{
  imports = profiles ++ [
    inputs.nixos-hardware.nixosModules.system76

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
  profile.batteryNotifier = {
    enable = config.programs.sway.enable || config.programs.hyprland.enable;
    suspend.capacityValue = 3;
  };
  sops.secrets."machine_id" = {
    sopsFile = ./secrets.yml;
    mode = "0644";
  };
  system.stateVersion = "23.05";
}


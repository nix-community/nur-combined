{ lib
, pkgs
, inputs
, overlays
, hostname
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

  boot = {
    zfs.package = pkgs.zfs_2_3;
    kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  };
  networking.hostName = hostname;
  nixpkgs = {
    inherit overlays;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };
  profile = {
    moonlander = {
      enable = true;
      ignoreLayoutSettings = true;
    };
    specialisations.gaming = {
      enable = true;
      steam = {
        enable = true;
        enableSteamHardware = true;
        enableGamescope = true;
      };
    };
  };
  sops.secrets."machine_id" = {
    sopsFile = ./secrets.yml;
    mode = "0644";
  };

  #environment.etc.machine-id.source = config.sops.secrets."machine_id".path;

  # Extra settings (22.11)

  system.stateVersion = "23.05"; # Did you read the comment?

}

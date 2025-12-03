{
  lib,
  pkgs,
  inputs,
  overlays,
  hostname,
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

    ./disk-setup.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_17;
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
  services = {
    openssh.hostKeys = localLib.generateSshHostKeyPaths;
    qbittorrent = {
      enable = true;
      webuiPort = 1585;
    };
  };
  sops = {
    age = localLib.generateSopsAgeInfo;
    secrets."machine_id" = {
      sopsFile = ./secrets.yml;
      mode = "0644";
    };
  };

  #environment.etc.machine-id.source = config.sops.secrets."machine_id".path; # TODO: Try to enable it

  # Extra settings (22.11)

  system.stateVersion = "25.05"; # Did you read the comment?

}

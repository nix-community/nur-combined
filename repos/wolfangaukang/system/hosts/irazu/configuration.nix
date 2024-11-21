{ lib
, pkgs
, inputs
, overlays
, hostname
, ...
}:

let
  inherit (inputs) self;
  inherit (pkgs) virt-manager;

in
{
  imports =
    [
      inputs.nixos-hardware.nixosModules.system76

      ./disk-setup.nix
      ./hardware-configuration.nix
      "${self}/system/profiles/workstation.nix"
      "${self}/system/profiles/sway.nix"
    ];

  boot = {
    zfs.package = pkgs.zfs_2_1;
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
    nix = {
      enableAutoOptimise = true;
      enableFlakes = true;
      enableUseSandbox = true;
    };
    virtualization = {
      podman.enable = true;
      qemu = {
        enable = true;
        extraPkgs = [ virt-manager ];
        libvirtdGroupMembers = [ "bjorn" ];
      };
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

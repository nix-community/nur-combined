{ lib
, pkgs
, inputs
, overlays
, ... }:

let
  inherit (pkgs) heroic retroarch virt-manager;
  inherit (pkgs.libretro) mgba bsnes-mercury-performance;

in
{
  imports =
    [
      inputs.nixos-hardware.nixosModules.system76

      ./disk-setup.nix
      ./hardware-configuration.nix
      "${inputs.self}/system/profiles/workstation.nix"
      "${inputs.self}/system/profiles/pantheon.nix"
    ];

  # TODO: Change until ZFS support and Virtualbox can be built
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  nixpkgs = {
    inherit overlays;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "video-downloadhelper"
      "zerotierone"
      "steam-run"
      "steam"
      "steam-original"
      #"steam-runtime"
      "Oracle_VM_VirtualBox_Extension_Pack"
      "vmware-workstation"
    ];
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
    sound = {
      enable = true;
      enableOSSEmulation = true;
      pipewire = {
        enable = true;
        enableAlsa32BitSupport = true;
      };
    };
    virtualization = {
      podman.enable = true;
      qemu = {
        enable = true;
        extraPkgs = [ virt-manager ];
        libvirtdGroupMembers = [ "bjorn" ];
      };
    };
    specialisations = {
      gaming = {
        enable = true;
        steam = {
          enable = true;
          enableSteamHardware = true;
          enableGamescope = true;
        };
        # TODO: Find a way to enable options for users
        home = {
          enable = true;
          enableProtontricks = true;
          retroarch = {
            enable = true;
            package = retroarch;
            coresToLoad = [
              mgba
              bsnes-mercury-performance
            ];
          };
          extraPkgs = [ heroic ];
        };
      };
      work.simplerisk.enable = true;
    };
  };

  sops.secrets."machine_id" = {
    sopsFile = ./secrets.yml;
    mode = "0644";
  };

  boot.zfs.package = pkgs.zfs_2_1;

  #environment.etc.machine-id.source = config.sops.secrets."machine_id".path;

  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "23.05"; # Did you read the comment?

}

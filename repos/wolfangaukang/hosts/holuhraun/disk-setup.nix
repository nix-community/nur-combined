{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  fileSystems = let
    diskOptions = [ "defaults" "ssd" "compress=zstd" "noatime" "discard=async" "space_cache=v2" ];
  in {
    "/".options = [ "defaults" "size=3G" "mode=755" ];
    "/home".options = (lib.remove "noatime" diskOptions);
    "/home/.snapshots".options = diskOptions;
    "/persist".neededForBoot = true;
  };
  # Needed by ZFS
  networking.hostId = "e416e925";
  boot = {
    initrd = {
      luks.devices = {
        "nixos" = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/34bedc50-ac58-4a0f-9e76-09ec9381872f";
          keyFile = "/keyfile0.bin";
          preLVM = true;
        };
        "home" = {
          allowDiscards = true;
          keyFile = "/keyfile1.bin";
        };
        "data" = {
          allowDiscards = true;
          keyFile = "/keyfile2.bin";
        };
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
        "keyfile1.bin" = "/etc/secrets/initrd/keyfile1.bin";
        "keyfile2.bin" = "/etc/secrets/initrd/keyfile2.bin";
      };
    };
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        version = 2;
        efiSupport = true;
        enableCryptodisk = true;
      };
    };
    tmpOnTmpfs = true;
    cleanTmpDir = true;
  };
}

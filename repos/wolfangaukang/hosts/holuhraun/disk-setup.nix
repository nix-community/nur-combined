{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  fileSystems = let
    # Remember to remove noatime if using btrfs with home
    btrfsDiskOptions = [ "defaults" "ssd" "compress=zstd" "noatime" "discard=async" "space_cache=v2" ];
  in {
    "/".options = [ "defaults" "size=3G" "mode=755" ];
    "/persist".neededForBoot = true;
  };
  # Needed by ZFS
  # Enable when doing a nixos-install
  #boot.zfs.forceImportAll = true;
  # Disable the previous one and enable this after first boot
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e416e925";
  boot = {
    initrd = {
      luks.devices = {
        "nixos" = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/26226643-4614-49af-a225-ebd0a86ecbc2";
          keyFile = "/keyfile0.bin";
          preLVM = true;
        };
        "home" = {
          device = "/dev/disk/by-uuid/38ac4448-58ed-42e8-9b7e-8809c66a5ab2";
          allowDiscards = true;
          keyFile = "/keyfile1.bin";
        };
        "data" = {
          device = "/dev/disk/by-uuid/a4748398-8c8a-48d8-aca8-f4c0109457ff";
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
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
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

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  fileSystems =
    let
      diskOptions = [
        "defaults"
        "ssd"
        "compress=zstd"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    in
    {
      "/".options = [
        "defaults"
        "size=25%"
        "mode=755"
      ];
      "/.snapshots".options = diskOptions;
      "/mnt/performance".options = diskOptions;
      "/mnt/persist" = {
        neededForBoot = true;
        options = diskOptions;
      };
    };
  services.btrfs.autoScrub.enable = true;
  networking.hostId = "e416e925";
  boot = {
    initrd = {
      luks.devices = {
        "nixos" = {
          allowDiscards = true;
          keyFile = "/keyfile0.bin";
        };
        "fast" = {
          allowDiscards = true;
          keyFile = "/keyfile1.bin";
        };
        "slow" = {
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
        efiSupport = true;
        enableCryptodisk = true;
      };
    };
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };
}

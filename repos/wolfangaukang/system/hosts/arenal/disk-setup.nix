{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Extra options to filesystem
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
        "size=3G"
        "mode=755"
      ];
      "/nix".options = diskOptions;
      "/mnt/persist" = {
        neededForBoot = true;
        options = diskOptions;
      };
      "/.snapshots".options = diskOptions;
    };
  services.btrfs.autoScrub.enable = true;
  boot = {
    initrd = {
      luks.devices."root" = {
        allowDiscards = true;
        device = "/dev/disk/by-uuid/03924f8e-2aa7-4ae4-b153-95d8f1d57aeb";
        keyFile = "/keyfile0.bin";
        preLVM = true;
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    # /tmp settings
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };
}

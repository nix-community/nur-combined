{ config, pkgs, ... }:

{
  boot = {
    initrd = {
      luks.devices = {
        "root" = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/e04ada96-abd7-4805-bd25-72efe36ba507";
          keyFile = "/keyfile0.bin";
          preLVM = true;
        };
        "home" = {
          allowDiscards = true;
          keyFile = "/keyfile1.bin";
        };
        "speed" = {
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

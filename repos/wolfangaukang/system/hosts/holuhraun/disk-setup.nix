{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  fileSystems = {
    "/".options = [ "defaults" "size=3G" "mode=755" ];
    "/persist".neededForBoot = true;
  };
  # ZFS
  # Uncomment when doing a nixos-install, comment after performing the first boot
  #boot.zfs.forceImportAll = true;
  # Comment when doing a nixos-install, uncomment after first boot
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e416e925";
  services.zfs = {
    autoScrub.enable = true;
    # https://docs.oracle.com/cd/E19120-01/open.solaris/817-2271/ghzuk/index.html
    autoSnapshot = {
      enable = true;
      weekly = 5;
    };
    zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_NOTIFY_VERBOSE = 1;
    };
  };
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
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };
}

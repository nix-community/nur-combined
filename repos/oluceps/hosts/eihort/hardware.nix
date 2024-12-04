{
  config,
  inputs,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{

  zramSwap = {
    enable = true;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      systemd-boot.enable = true;
      timeout = 3;
    };

    supportedFilesystems = [ "bcachefs" ];

    kernelParams = [
      "audit=0"
      "net.ifnames=0"
      "ia32_emulation=0"
    ];

    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "mpt3sas"
      ];
      kernelModules = [
        "tpm"
        "tpm_tis"
        "tpm_crb"
        "mpt3sas" # IMPORTANT
      ];
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  disko = {
    devices = {
      disk.main = {
        device = "/dev/disk/by-id/ata-SanDisk_SD8SBAT032G_153873411000";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              priority = 0;
            };

            ESP = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "--csum xxhash64"
                ];
                subvolumes = {

                  # "/persist" = {
                  #   mountpoint = "/persist";
                  #   mountOptions = [
                  #     "compress-force=zstd:1"
                  #     "noatime"
                  #     "discard=async"
                  #     "space_cache=v2"
                  #   ];
                  # };
                  "/nix" = {
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                      "nosuid"
                      "nodev"
                    ];
                    mountpoint = "/nix";
                  };
                  # "/var" = {
                  #   mountOptions = [
                  #     "compress-force=zstd:1"
                  #     "noatime"
                  #     "discard=async"
                  #     "space_cache=v2"
                  #     "nosuid"
                  #     "nodev"
                  #   ];
                  #   mountpoint = "/var";
                  # };
                };
              };
            };
          };
        };
      };
      nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "relatime"
            "nosuid"
            "nodev"
            "size=4G"
            "mode=755"
          ];
        };
      };
    };
  };
  fileSystems = {

    "/persist".neededForBoot = true;

    "/three" = {
      device = "/dev/disk/by-uuid/134975b6-4ccc-4201-b479-105eb2382945";
      fsType = "btrfs";
      options = [
        "subvolid=5"
        "compress-force=zstd:5"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    };
    "/var" = {
      device = "/dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a";
      fsType = "btrfs";
      options = [
        "compress-force=zstd:3"
        "noatime"
        "subvol=var"
        "nosuid"
        "nodev"
      ];
    };
    # fileSystems."/nix" = {
    #   device = "/dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a";
    #   fsType = "btrfs";
    #   options = [
    #     "compress-force=zstd:3"
    #     "noatime"
    #     "subvol=nix"
    #     "nosuid"
    #     "nodev"
    #   ];
    # };
    "/persist" = {
      device = "/dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a";
      fsType = "btrfs";
      options = [
        "compress-force=zstd:3"
        "noatime"
        "subvol=persist"
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

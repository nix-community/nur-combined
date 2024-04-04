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
                  "root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                      "nosuid"
                      "nodev"
                    ];
                  };
                  "home" = {
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                      "nosuid"
                      "nodev"
                    ];
                    mountpoint = "/home";
                  };
                  "nix" = {
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
                  "var" = {
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                      "nosuid"
                      "nodev"
                    ];
                    mountpoint = "/var";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

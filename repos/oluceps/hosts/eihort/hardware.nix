{
  config,
  inputs,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  # facter.reportPath = ./facter.json;

  # zramSwap = {
  #   enable = true;
  #   swapDevices = 1;
  #   memoryPercent = 80;
  #   algorithm = "zstd";
  # };

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      timeout = 3;
    };

    kernelParams = [
      # "audit=0"
      # "net.ifnames=0"
      "ia32_emulation=0"
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.zpool=zsmalloc"
    ];

    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;

      availableKernelModules = [
        "usb_storage"
        "mpt3sas"
      ];
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  disko = {
    devices = {
      disk.main = {
        device = "/dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
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
                  "--label nixos"
                  "-f"
                  "--csum xxhash64"
                  "--features"
                  "block-group-tree"
                ];
                subvolumes = {

                  "persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                    ];
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
                  # "persist/tmp" = {
                  #   mountpoint = "/tmp";
                  #   mountOptions = [
                  #     "relatime"
                  #     "nodev"
                  #     "nosuid"
                  #     "discard=async"
                  #     "space_cache=v2"
                  #   ];
                  # };
                };
              };
            };
            plainSwap = {
              size = "32G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
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
            "size=2G"
            "mode=755"
          ];
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;

  fileSystems."/three" = {
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

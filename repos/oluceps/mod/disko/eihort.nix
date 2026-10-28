{ inputs, ... }:
{
  flake.modules.nixos."disko/eihort" = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
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
                  # The NVMe swap area must outrank the SATA SanDisk DOM below.
                  # Left unprioritized, the kernel auto-assigned -2/-3 in
                  # activation order, so the slow SATA device became the
                  # *preferred* swap: on 2026-10-28 every memory-reclaim burst
                  # turned into a multi-minute IO stall (PSI full 88%).
                  priority = 100;
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
    fileSystems = {
      "/persist".neededForBoot = true;
      "/var/lib/sea-volume" = {
        device = "pool0/sea-volume";
        fsType = "zfs";
      };
      "/pool0/storage" = {
        device = "pool0/storage";
        fsType = "zfs";
      };
      "/var/lib/clickhouse" = {
        device = "pool0/clickhouse";
        fsType = "zfs";
      };
      "pool0/relation" = {
        device = "pool0/relation";
        fsType = "zfs";
      };
    };
    swapDevices = [
      # Overflow swap only, well below the NVMe area (priority 100 above).
      # NOTE: applying a priority to an *active* swap area requires swapoff()
      # first, and this device currently holds ~14G of pages - systemd would
      # have to pull all of them back into RAM on the next activation, which
      # thrashes (and can fail) on a box that is already short on memory.
      # So: reboot (or `sudo swapoff /dev/sda` once memory allows) BEFORE the
      # next `nixos-rebuild switch`.
      {
        device = "/dev/disk/by-id/ata-SanDisk_SD8SBAT032G_153873411000";
        priority = 1;
      }
    ];
    # fileSystems."/three" = {
    #   device = "/dev/disk/by-uuid/134975b6-4ccc-4201-b479-105eb2382945";
    #   fsType = "btrfs";
    #   options = [
    #     "subvolid=5"
    #     "compress-force=zstd:5"
    #     "noatime"
    #     "discard=async"
    #     "space_cache=v2"
    #   ];
    # };

  };
}

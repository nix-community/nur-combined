{ inputs, ... }:
{
  flake.modules.nixos."disko/hastur" = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    fileSystems."/persist".neededForBoot = true;
    disko.devices = {
      disk = {
        nvme = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-WDS100T3X0C-00SJG0_21191G463913";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "2G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/efi";
                };
              };

              cryptroot = {
                label = "CRYPTROOT";
                end = "-32G";
                content = {
                  type = "luks";
                  name = "cryptroot";
                  settings = {
                    allowDiscards = true;
                    bypassWorkqueues = true;
                    crypttabExtraOpts = [
                      "same-cpu-crypt"
                      "submit-from-crypt-cpus"
                      "fido2-device=auto"
                      "tpm2-device=auto"
                      "tpm2-measure-pcr=yes"
                    ];
                  };
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
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress-force=zstd:1"
                          "noatime"
                          "discard=async"
                          "space_cache=v2"
                          "nodev"
                          "nosuid"
                        ];
                      };
                      "var" = {
                        mountpoint = "/var";
                        mountOptions = [
                          "compress-force=zstd:1"
                          "noatime"
                          "discard=async"
                          "space_cache=v2"
                        ];
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
              };
              encryptedSwap = {
                end = "100%";
                content = {
                  type = "swap";
                  randomEncryption = true;
                  discardPolicy = "once";
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
            "size=2G"
            "mode=755"
          ];
        };
      };
    };

  };
}

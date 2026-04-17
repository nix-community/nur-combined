{ inputs, ... }:
{
  flake.modules.nixos."disko/kaambl" = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    disko.devices = {
      disk = {
        nvme = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-HP_SSD_FX900_Plus_2TB_HBSE53360805325";
          content = {
            type = "gpt";
            partitions = {
              esp = {
                label = "ESP";
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
                size = "1024G";
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
                      "persist/tmp" = {
                        mountpoint = "/tmp";
                        mountOptions = [
                          "relatime"
                          "nodev"
                          "nosuid"
                          "discard=async"
                          "space_cache=v2"
                        ];
                      };
                    };
                  };
                };
              };
              encryptedSwap = {
                size = "16G";
                content = {
                  type = "swap";
                  randomEncryption = true;
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

    fileSystems."/persist".neededForBoot = true;

  };
}

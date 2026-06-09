{ inputs, ... }:
{
  flake.modules.nixos."disko/azasos" = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    fileSystems."/persist".neededForBoot = true;
    disko = {
      devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/sda";
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  size = "1M";
                  priority = 0;
                  type = "EF02";
                };
                ESP = {
                  name = "ESP";
                  size = "256M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                solid = {
                  label = "SOLID";
                  end = "-0";
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
                      "root" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress-force=zstd:1"
                          "noatime"
                          "nodev"
                          "nosuid"
                        ];
                      };
                      "nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress-force=zstd:1"
                          "noatime"
                          "nodev"
                          "nosuid"
                        ];
                      };
                      "var" = {
                        mountpoint = "/var";
                        mountOptions = [
                          "compress-force=zstd:1"
                          "noatime"
                          "nodev"
                          "nosuid"
                        ];
                      };
                      "persist" = {
                        mountpoint = "/persist";
                        mountOptions = [
                          "compress-force=zstd:1"
                          "noatime"
                        ];
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

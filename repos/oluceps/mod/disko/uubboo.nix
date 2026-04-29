{ inputs, ... }:
{
  flake.modules.nixos."disko/uubboo" = {
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
                      "nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                          "nodev"
                          "nosuid"
                        ];
                      };
                      "var" = {
                        mountpoint = "/var";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                          "nodev"
                          "nosuid"
                        ];
                      };
                      "persist" = {
                        mountpoint = "/persist";
                        mountOptions = [
                          "compress=zstd"
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
        nodev = {
          "/" = {
            fsType = "tmpfs";
            mountOptions = [
              "relatime"
              "nosuid"
              "nodev"
              "size=128M"
              "mode=755"
            ];
          };
        };
      };
    };

  };
}

{
  fileSystems."/persist".neededForBoot = true;
  disko = {

    devices = {
      disk = {
        main = {
          imageSize = "4G";
          type = "disk";
          device = "/dev/vda";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                priority = 0;
                type = "EF02";
              };
              ESP = {
                size = "256M";
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
                    "-f"
                    "--csum xxhash64"
                  ];
                  subvolumes = {
                    # "root" = {
                    #   mountpoint = "/";
                    #   mountOptions = [
                    #     "compress=zstd"
                    #     "noatime"
                    #     "nodev"
                    #     "nosuid"
                    #   ];
                    # };
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
            "size=2G"
            "mode=755"
          ];
        };
      };
    };
  };
}

{
  fileSystems."/persist".neededForBoot = true;
  disko.devices = {
    disk = {
      main = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              type = "EF02";
              label = "BOOT";
              start = "0";
              end = "+1M";
            };
            root = {
              label = "ROOT";
              end = "-0";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "--csum xxhash64"
                ];
                subvolumes = {
                  "boot" = {
                    mountpoint = "/boot";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
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
                  "root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "nodev"
                      "nosuid"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
    # nodev = {
    #   "/" = {
    #     fsType = "tmpfs";
    #     mountOptions = [
    #       "relatime"
    #       "nosuid"
    #       "nodev"
    #       "size=2G"
    #       "mode=755"
    #     ];
    #   };
    # };
  };
}

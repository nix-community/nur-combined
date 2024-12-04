_:
{

  disko = {
    enableConfig = true;

    devices = {
      disk.main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              priority = 0;
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
}

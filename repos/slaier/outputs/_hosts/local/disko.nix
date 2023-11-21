{
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }; # ESP
            windows = {
              size = "500G";
            }; # windows
            nixvar = {
              size = "500M";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix/var";
              };
            }; # nixvar
            nixos = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@persist" = {
                    mountpoint = "/persist";
                  };
                  "@nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "32G";
                    };
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                  };
                };
              };
            }; # nixos
          }; # partitions
        };
      }; #nvme0n1
    }; # disk
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=4G"
        ];
        postMountHook = ''
          mkdir -p /mnt/etc
          touch /mnt/etc/NIXOS
        '';
      };
    }; # nodev
  }; # devices
}

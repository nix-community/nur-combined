{ self, lib, ... }:

let
  inherit (builtins) fromJSON readFile;
  inherit (lib) recursiveUpdate;

  proxySettings = fromJSON (readFile ./fracture-ray/proxy.json);

  mainModule = {
    abszero = {
      users.admins = [ "weathercold" ];
      services.xray = recursiveUpdate proxySettings {
        # enable = true;
        preset = "vless-tcp-xtls-reality-client";
        reality.shortId = "77b852c767077a1a";
      };
    };

    disko.devices.disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "esp";
            size = "512M";
            type = "EF00"; # EFI system partition
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "noatime"
                "noauto"
                "nodev" # block device files for security
                "nofail"
                "nosuid" # block suid and sgid bits for security
                "x-systemd.automount"
                "x-systemd.idle-timeout=10min"
              ];
            };
          };
          data = {
            label = "data";
            size = "250G";
            content = {
              type = "btrfs";
              subvolumes = {
                home = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress-force=zstd"
                    "noatime"
                    "nodev"
                    "nosuid"
                  ];
                };
              };
            };
          };
          nixos = {
            label = "nixos";
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                root = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress-force=zstd"
                    "noatime"
                  ];
                };
                nix = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress-force=zstd"
                    "noatime"
                    "nodev"
                  ];
                };
                swap = {
                  mountpoint = "/swap";
                  mountOptions = [
                    "noatime"
                    "nodev"
                    "noexec" # block execution of binaries for security
                    "nosuid"
                  ];
                  # TODO: define swap with disko when options under
                  # `swapDevices.*` are added
                  # swap.swapfile.size = "8G";
                };
              };
            };
          };
        };
      };
    };
    swapDevices = [
      {
        device = "/swap/swapfile";
        size = 8192;
        discardPolicy = "pages";
      }
    ];

    catppuccin.accent = "pink";

    boot = {
      kernelParams = [ "resume_offset=533760" ];
      resumeDevice = "/dev/disk/by-partlabel/nixos";
    };

    users.users = rec {
      weathercold = {
        description = "Weathercold";
        isNormalUser = true;
        hashedPassword = "$6$QOTimFq0v8u6oN.I$.m0BQc/tC6/8nluwwQT7AmkbJbfNoh2PnO9biVL4wgWA22zlb/0HheieexWgISAB67r/7floX3bQpZrUjZv9v.";
      };
      root = {
        inherit (weathercold) hashedPassword;
      };
    };

    services.btrfs.autoScrub.enable = true;
  };
in

{
  imports = [ ./_options.nix ];

  nixosConfigurations.nixos-inspiron7405 = {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      profiles-full
      hardware-inspiron-7405
      catppuccin-sddm
      mainModule
    ];
  };
}

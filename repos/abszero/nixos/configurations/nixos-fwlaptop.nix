{ inputs, lib, ... }:

let
  inherit (builtins)
    fromJSON
    readDir
    readFile
    warn
    ;
  inherit (lib) recursiveUpdate;

  proxySettings =
    if (readDir ./fracture-ray ? "proxy.json") then
      fromJSON (readFile ./fracture-ray/proxy.json)
    else
      warn "proxy.json is hidden, configuration is incomplete" { };

  mainModule = {
    abszero = {
      profiles.laptop.enable = true;

      zramSwap.enable = true;

      users.admins = [ "weathercold" ];

      hardware.framework-12-13th-gen-intel.enable = true;

      services = {
        displayManager.tuigreet.enable = true;
        xray = recursiveUpdate proxySettings {
          # enable = true;
          preset = "vless-tcp-xtls-reality-client";
          reality.shortId = "77b852c767077a1a";
        };
      };

      programs.niri.enable = true;

      themes.catppuccin = {
        enable = true;
        plymouth.enable = true;
      };
    };

    disko.devices.disk.nvme0n1 = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-BC511_NVMe_SK_hynix_512GB_NY11N03371040170Q";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "esp";
            size = "512M";
            type = "EF00"; # EFI system partition
            priority = 0;
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
                "umask=0077" # rwx------
                "x-systemd.automount"
                "x-systemd.idle-timeout=10min"
              ];
            };
          };
          data = {
            label = "data";
            size = "150G";
            priority = 1;
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
            size = "100G";
            priority = 2;
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
                  ];
                };
              };
            };
          };
          swap = {
            label = "swap";
            size = "16G";
            priority = 3;
            content = {
              type = "swap";
              discardPolicy = "pages";
              resumeDevice = true;
            };
          };
        };
      };
    };

    catppuccin.accent = "pink";

    fileSystems.windows = {
      device = "/dev/disk/by-partlabel/Basic\x20data\x20partition";
      fsType = "ntfs3";
      noCheck = true;
      options = [
        "noatime"
        "noauto"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=10min"
      ];
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
  };
in

{
  imports = [ ./_options.nix ];

  nixosConfigurations.nixos-fwlaptop = {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel
      mainModule
    ];
  };
}

{
  config,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    kernelModules = [ "brutal" ];
    extraModulePackages = with config.boot.kernelPackages; [
      (callPackage "${inputs.self}/pkgs/kernel-module/tcp-brutal/package.nix" { })
    ];

    kernelParams = [
      "audit=0"
      "net.ifnames=0"
      "console=ttyS0"
      "earlyprintk=ttyS0"
      "rootdelay=300"
      "19200n8"
    ];
    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;
    };

  };

  fileSystems."/persist".neededForBoot = true;
  disko = {
    devices = {
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
                priority = 0;
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
                  };
                };
              };
            };
          };
        };
      };
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "relatime"
          "mode=755"
          "nosuid"
          "nodev"
        ];
      };
    };
  };
}

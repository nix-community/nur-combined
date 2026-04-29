/*
  Wed 20 Mar 23:41:49 +08 2024

  Azure korea nixos-anywhere apply success
*/
{
  self,
  inputs,
  ...
}:
{
  os.bootstrap.module =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        # (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        # (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
        {
          options.fw-iface = lib.mkOption {
            type = lib.types.enum [
              "UEFI"
              "BIOS"
            ];
          };
          config.fw-iface = "UEFI";
        }
        {
          time.timeZone = "Asia/Hong_Kong";
          networking = {
            nameservers = [ "8.8.8.8" ];
            usePredictableInterfaceNames = false;

            firewall.enable = false;

            useNetworkd = true;

            hostName = "bootstrap";
          };
          boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

          users.mutableUsers = false;
          users.users.root = {
            initialHashedPassword = lib.mkForce self.data.keys.hashedPasswd;
            openssh.authorizedKeys.keys = [
              self.data.keys.sshPubKey2
              self.data.keys.skSshPubKey
            ];
          };

          systemd.network.enable = true;
          services.resolved.enable = true;

          services.openssh = {
            enable = true;
            ports = [ 22 ];
            settings = {
              PasswordAuthentication = false;
              PermitRootLogin = lib.mkForce "prohibit-password";
            };
          };

          system.stateVersion = "24.05";
        }

        # {

        #   fileSystems."/persist".neededForBoot = true;
        #   disko = {
        #     devices = {
        #       disk = {
        #         main = {
        #           imageSize = "5G";
        #           device = "/dev/sda";
        #           type = "disk";
        #           content = {
        #             type = "gpt";
        #             partitions = {
        #               ESP = {
        #                 name = "ESP";
        #                 size = "256M";
        #                 type = "EF00";
        #                 priority = 0;
        #                 content = {
        #                   type = "filesystem";
        #                   format = "vfat";
        #                   mountpoint = "/efi";
        #                   mountOptions = [
        #                     "fmask=0077"
        #                     "dmask=0077"
        #                   ];
        #                 };
        #               };

        #               solid = {
        #                 label = "SOLID";
        #                 end = "-0";
        #                 content = {
        #                   type = "btrfs";
        #                   extraArgs = [
        #                     "-f"
        #                     "--csum xxhash64"
        #                   ];
        #                   subvolumes = {
        #                     "nix" = {
        #                       mountpoint = "/nix";
        #                       mountOptions = [
        #                         "compress=zstd"
        #                         "noatime"
        #                         "nodev"
        #                         "nosuid"
        #                       ];
        #                     };
        #                     "var" = {
        #                       mountpoint = "/var";
        #                       mountOptions = [
        #                         "compress=zstd"
        #                         "noatime"
        #                         "nodev"
        #                         "nosuid"
        #                       ];
        #                     };
        #                     "persist" = {
        #                       mountpoint = "/persist";
        #                       mountOptions = [
        #                         "compress=zstd"
        #                         "noatime"
        #                       ];
        #                     };
        #                     "root" = {
        #                       mountpoint = "/";
        #                       mountOptions = [
        #                         "compress=zstd"
        #                         "noatime"
        #                         "nodev"
        #                         "nosuid"
        #                       ];
        #                     };
        #                   };
        #                 };
        #               };
        #             };
        #           };
        #         };
        #       };

        #       # nodev = {
        #       #   "/" = {
        #       #     fsType = "tmpfs";
        #       #     mountOptions = [
        #       #       "relatime"
        #       #       "nosuid"
        #       #       "nodev"
        #       #       "size=2G"
        #       #       "mode=755"
        #       #     ];
        #       #   };
        #       # };
        #     };
        #   };
        #   boot = {
        #     kernelParams = [
        #       "audit=0"
        #       "net.ifnames=0"

        #       "console=ttyS0"
        #       "earlyprintk=ttyS0"
        #       "rootdelay=300"
        #     ];
        #     loader = {
        #       efi = {
        #         canTouchEfiVariables = true;
        #         efiSysMountPoint = "/efi";
        #       };
        #       systemd-boot.enable = true;
        #       # timeout = 3;
        #     };
        #     initrd = {
        #       compressor = "zstd";
        #       compressorArgs = [
        #         "-19"
        #         "-T0"
        #       ];
        #       systemd.enable = true;

        #       kernelModules = [
        #         # "hv_vmbus" # for hyper-V
        #         # "hv_netvsc"
        #         # "hv_utils"
        #         # "hv_storvsc"
        #       ];
        #     };
        #   };
        # }

        {
          boot = {
            loader = {
              # timeout = 3;
              limine = {
                enable = true;
                efiSupport = true;
                biosSupport = true;
                biosDevice = "/dev/sda";
              };
            };
            kernelParams = [
              "audit=0"
              "net.ifnames=0"
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

              kernelModules = [
                # "hv_netvsc"
                # "hv_utils"
                # "hv_storvsc"
              ];
            };
          };

          fileSystems."/persist".neededForBoot = true;
          disko = {

            devices = {
              disk = {
                main = {
                  imageSize = "2G";
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
                                "compress=zstd"
                                "noatime"
                                "nodev"
                                "nosuid"
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
            };
          };
        }

        {
          systemd.network = {
            enable = true;

            links."10-eno1" = {
              matchConfig.MACAddress = "c4:09:38:f2:3e:cb";
              linkConfig.Name = "eno1";
            };

            networks."8-eno1" = {
              matchConfig.Name = "eno1";
              networkConfig = {
                DHCP = "yes";
                IPv4Forwarding = true;
                IPv6Forwarding = true;
                IPv6AcceptRA = true;
                MulticastDNS = true;
              };
              ipv6AcceptRAConfig = {
                DHCPv6Client = false;
                # UseDNS = false;
              };

              # address = [
              # "205.198.76.6/24"
              # "2404:c140:2000:2::32:1d9f/64/48"
              # ];
              linkConfig.RequiredForOnline = "routable";
              # routes = [
              #   { Gateway = "205.198.76.1"; }
              #   {
              #     Gateway = "2404:c140:2000:2::1";
              #     GatewayOnLink = true;
              #   }
              # ];
            };
          };
        }
        inputs.disko.nixosModules.disko
        {
          nixpkgs = {
            hostPlatform = "x86_64-linux";
            overlays = with inputs; [
              fenix.overlays.default
              self.overlays.default
            ];
          };
        }
      ];
    };
}

# Headscale server deployed to Hetzner
# Install:
# 1. Boot from ISO
# 2. Set root password
# 3. `nixos-anywhere --flake <flake-path>#central-nucleus root@<ip>`
# Deploy: `deploy -s path:.#central-nucleus`
{
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) singleton;

  hostName = "central-nucleus";
  system = "x86_64-linux";
  domain = "weathercold.moe";
  ipv4 = "167.233.94.66";
  ipv6 = "2a01:4f8:1c1c:88a8::1";

  mainModule = nixos: {
    abszero = {
      profiles.server.enable = true;
      hardware.hetzner-co-x86-cx23.enable = true;
      users.admins = [ "weathercold" ];
      networking.addrs = {
        ${ipv4}.type = "ipv4";
        ${ipv6}.type = "ipv6";
      };
      services.headscale.enable = true;
    };

    disko.devices.disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          bios = {
            label = "bios";
            size = "1M";
            type = "EF02"; # BIOS boot partition for GRUB
          };
          nixos = {
            label = "nixos";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              subvolumes = {
                root = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress-force=zstd"
                    "noatime"
                  ];
                };
                swap = {
                  mountpoint = "/swap";
                  mountOptions = [
                    "noatime"
                    "nodev"
                    "noexec"
                    "nosuid"
                  ];
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
        size = 4096;
        discardPolicy = "pages";
      }
    ];

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

    networking = {
      inherit domain;
      # ipv4 is configured via DHCP
      interfaces.enp1s0.ipv6.addresses = singleton {
        address = ipv6;
        prefixLength = 64;
      };
    };

    services.caddy.extraConfig = ''
      ${domain} {
        reverse_proxy https://example.com
      }
    '';
  };
in

{
  abszero = {
    nixosConfigurations.${hostName} = {
      inherit system;
      modules = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
        mainModule
      ];
    };
    programs.ssh.knownHosts.${hostName} = {
      extraHostNames = [
        domain
        "${hostName}.ts.net"
      ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0sqleia3X4x5fo+h9ReragzkkpJWRIy+yzLcWwFlCd weathercold@central-nucleus";
    };
  };

  flake.deploy.nodes.${hostName} = {
    hostname = domain;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.${system}.activate.nixos config.flake.nixosConfigurations.${hostName};
    };
  };
}

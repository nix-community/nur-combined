# Xray server deployed to Vultr
# Install:
# 1. Upload NixOS ISO
# 2. Boot from ISO
# 3. Set root password
# 4. `nixos-anywhere --flake <flake-path>#fracture-ray root@<ip>`
# Deploy: `deploy -s path:.#fracture-ray`
{
  self,
  inputs,
  lib,
  ...
}:

let
  inherit (builtins)
    fromJSON
    readDir
    readFile
    warn
    ;
  inherit (lib) recursiveUpdate;

  proxySettings =
    if (readDir ./. ? "proxy.json") then
      fromJSON (readFile ./proxy.json)
    else
      warn "proxy.json is hidden, configuration is incomplete" { };

  mainModule = {
    abszero = {
      profiles.server.enable = true;
      users.admins = [ "weathercold" ];
      hardware.vultr-cc-intel-regular.enable = true;
      services.xray = recursiveUpdate proxySettings {
        enable = true;
        preset = "vless-tcp-xtls-reality-server";
      };
    };

    disko.devices.disk.vda = {
      type = "disk";
      device = "/dev/vda";
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
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNpRiJBIfsEXVgHQ7NuJ7uk9TEEq97EG6bISYZp+Zt+ Weathercold"
        ];
      };
      root = {
        inherit (weathercold) hashedPassword openssh;
      };
    };
  };
in

{
  imports = [ ../_options.nix ];

  nixosConfigurations.fracture-ray = {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      mainModule
    ];
  };

  flake.deploy.nodes.fracture-ray = {
    hostname = proxySettings.address;
    sshOpts = [
      "-p"
      "1337"
    ];
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.fracture-ray;
    };
  };
}

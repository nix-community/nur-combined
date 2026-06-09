# Azasos Machine Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap a new NixOS machine configuration for `azasos` based on `bootstrap.nix` patterns.

**Architecture:** Add node metadata to `registry.toml`, update central constants, and create host-specific configurations for storage, networking, secrets, and system services.

**Tech Stack:** NixOS, Disko, Vaultix, Bird (BGP), Yggdrasil.

---

### Task 1: Node Registration

**Files:**
- Modify: `registry.toml`
- Modify: `mod/constant.nix`

- [ ] **Step 1: Add azasos to registry.toml**

Add the following block to `registry.toml`:
```toml
[node.azasos]
id = 6
addrs = ["2401:b60:e0fe:3e::2"]
censor = false
nat = false
user = "riro"
ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDkqNdrR49Id2NjA01qx6E5dff5Bn6uqkmMnSZX9i1e"
link_local_addr = ""
wg_key = ""
mac = "bc:24:11:21:c7:2c"
ygg_pubkey = "c4da53e606530fca7cf7c1c756956258"
```

- [ ] **Step 2: Update mod/constant.nix**

Add `azasos = sum;` to the `hosts` attribute set in `mod/constant.nix`.

### Task 2: Storage Configuration (Disko)

**Files:**
- Create: `mod/disko/azasos.nix`

- [ ] **Step 1: Create mod/disko/azasos.nix**

```nix
{
  disko.devices = {
    disk = {
      main = {
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
                    mountOptions = [ "compress=zstd" "noatime" "nodev" "nosuid" ];
                  };
                  "nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" "nodev" "nosuid" ];
                  };
                  "var" = {
                    mountpoint = "/var";
                    mountOptions = [ "compress=zstd" "noatime" "nodev" "nosuid" ];
                  };
                  "persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
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
```

### Task 3: Secrets Configuration (Vaultix)

**Files:**
- Modify: `mod/age.nix`

- [ ] **Step 1: Add age/azasos module to mod/age.nix**

Add the following to `flake.modules.nixos`:
```nix
  flake.modules.nixos."age/azasos" =
    { config, ... }:
    {
      services.openssh.hostKeys = [
        {
          path = hostPrivKey;
          type = "ed25519";
        }
      ];
      vaultix = {
        settings.hostPubkey = config.data.node.${config.networking.hostName}.ssh_key;
        secrets = {
          sing = { };
          age = {
            mode = "400";
            owner = config.identity.user;
          };
        };
      };
    };
```

### Task 4: Network Configuration

**Files:**
- Modify: `mod/net.nix`

- [ ] **Step 1: Add net/azasos module to mod/net.nix**

Add the following to `mod/net.nix`:
```nix
  flake.modules.nixos."net/azasos" =
    { ... }:
    lib.mkMerge [
      common
      {
        networking = {
          hostName = "azasos";
        };
        systemd.network = {
          enable = true;
          wait-online = {
            enable = true;
            anyInterface = true;
          };
          links."10-eno1" = {
            matchConfig.MACAddress = "bc:24:11:21:c7:2c";
            linkConfig.Name = "eno1";
          };
          networks."8-eno1" = {
            matchConfig.Name = "eno1";
            networkConfig = {
              DHCP = "no";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
              IPv6AcceptRA = true;
              MulticastDNS = true;
            };
            ipv6AcceptRAConfig = {
              DHCPv6Client = false;
            };
            address = [ "2401:b60:e0fe:3e::2/64" ];
            routes = [ { Gateway = "2401:b60:e0fe:3e::1"; } ];
            linkConfig.RequiredForOnline = "routable";
          };
        };
      }
    ];
```

### Task 5: Host Configuration

**Files:**
- Create: `mod/hosts/azasos.nix`

- [ ] **Step 1: Create mod/hosts/azasos.nix**

```nix
{ self, inputs, ... }:
{
  os.azasos.module =
    { config, pkgs, lib, ... }:
    {
      imports =
        with self.modules;
        ((with generic; [ data fn ])
        ++ (with nixos; [
          overlay identity openssh fail2ban vaultix shared-modules users sudo base dev
          vxlan-mesh yggdrasil chrony prometheus
          (self.modules.nixos."age/azasos")
          (self.modules.nixos."net/azasos")
          (self.modules.nixos."bird/azasos")
          (import ../disko/azasos.nix)
        ])
        ++ [ (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix") ]);

      identity.user = "riro";
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "25.11";

      boot = {
        loader = {
          grub = {
            enable = true;
            device = "/dev/sda";
          };
        };
        kernelParams = [ "audit=0" "net.ifnames=0" "rootdelay=300" "19200n8" ];
        initrd = {
          compressor = "zstd";
          compressorArgs = [ "-19" "-T0" ];
          systemd.enable = true;
        };
      };
    };
}
```

### Task 6: BGP Configuration

**Files:**
- Create: `mod/bird/azasos.nix`

- [ ] **Step 1: Create mod/bird/azasos.nix**

```nix
{ self, ... }:
{
  flake.modules.nixos."bird/azasos" =
    { config, ... }:
    {
      imports = [ self.modules.nixos.bird ];
      vaultix.secrets.babel-auth = { owner = "bird"; };
      bird = {
        config = ''
          include "${config.vaultix.secrets.babel-auth.path}";
        '';
      };
    };
}
```

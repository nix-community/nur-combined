{
  flake.modules.nixos.incus =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.incus.bridgeAddr = lib.mkOption {
        type = lib.types.str;
        default = "fdcc:1::1/64";
      };
      config = {
        virtualisation.incus = {
          enable = true;
          preseed = {
            networks = [
              {
                config = {
                  "ipv6.address" = config.incus.bridgeAddr;
                  "ipv6.nat" = "false";
                  "ipv6.routing" = "true";
                  "ipv4.address" = "none";
                  "dns.mode" = "none";
                };
                name = "br0";
                type = "bridge";
              }
            ];
            profiles = [
              {
                devices = {
                  eth0 = {
                    name = "eth0";
                    type = "nic";
                    network = "br0";
                  };
                  eth1 = {
                    name = "eth1";
                    type = "nic";
                    nictype = "macvlan";
                    parent = "eno1";
                  };
                  root = {
                    path = "/";
                    pool = "default";
                    size = "64GiB";
                    type = "disk";
                  };
                };
                config = {
                  "limits.cpu" = "4";
                  "limits.memory" = "4GiB";
                  "security.secureboot" = "false";
                };
                name = "default";
              }
            ];
            storage_pools = [
              {
                config = {
                  source = "/var/lib/incus/storage-pools/default";
                };
                driver = "dir";
                name = "default";
              }
            ];
          };
        };
        users.users.${config.identity.user}.extraGroups = [ "incus-admin" ];
        environment.systemPackages = [ pkgs.talosctl ];
        networking = {
          nftables.enable = true;
          firewall.trustedInterfaces = [ "br0" ];
          nftables.tables = {
            nat = {
              family = "ip6";
              content = ''
                chain postrouting {
                  type nat hook postrouting priority srcnat; policy accept;
                  oifname "eno1" ip6 saddr fdcc:1::/64 masquerade
                }
              '';
            };
            filter = {
              family = "inet";
              content = ''
                chain forward {
                  type filter hook forward priority filter; policy drop;
                  ct state { established, related } accept
                  iifname "br0" accept
                  ip6 saddr fdcc::/16 ip6 daddr fdcc::/16 accept
                }
              '';
            };
          };
        };
        systemd.network.networks."40-br0" = {
          matchConfig.Name = "br0";
          address = [ config.incus.bridgeAddr ];
        };
      };
    };
}

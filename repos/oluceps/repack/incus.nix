{
  reIf,
  pkgs,
  config,
  user,
  lib,
  ...
}:
let
  cfg = config.repack.incus;
in
{
  options = {
    repack.incus = {
      bridgeAddr = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {

    virtualisation.incus = {
      enable = true;
      preseed = {
        networks = [ ];
        profiles = [
          {
            devices = {
              eth0 = {
                name = "eth0";
                type = "nic";
                nictype = "bridged";
                parent = "br0";
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
    networking.nftables.enable = true;
    users.users.${user}.extraGroups = [ "incus-admin" ];
    environment.systemPackages = [ pkgs.talosctl ];
    networking.firewall.trustedInterfaces = [
      "incusbr0"
      "br0"
    ];

    systemd.network.networks."10-lan" = {
      matchConfig.Name = [
        "eno1"
      ];
      networkConfig = {
        Bridge = "br0";
      };
    };

    systemd.network.netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = config.systemd.network.links."10-eno1".matchConfig.MACAddress;
      };
    };

    systemd.network.networks."10-lan-bridge" = {
      matchConfig.Name = "br0";
      networkConfig = {
        Address = [
          cfg.bridgeAddr
        ];
        Gateway = "192.168.0.1";
        DNS = [ "192.168.0.1" ];
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };

    networking.nftables.ruleset = ''
      table inet filter {
      	chain forward {
          type filter hook forward priority filter; policy drop;
       		oifname "br0" accept
      	  iifname "br0" accept
      	}
      }
    '';
  };
}

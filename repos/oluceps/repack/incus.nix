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
        networks = [
          {
            config = {
              "ipv6.address" = cfg.bridgeAddr;
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
    users.users.${user}.extraGroups = [ "incus-admin" ];
    environment.systemPackages = [ pkgs.talosctl ];
    networking = {
      nftables.enable = true;
      firewall.trustedInterfaces = [
        "br0"
      ];

      nftables.ruleset = ''
        table ip6 nat {
        	chain postrouting {
        		type nat hook postrouting priority srcnat; policy accept;
        		oifname eno1 ip6 saddr fdcc:1::/64 masquerade
        	}
        }
        table inet filter {
        	chain forward {
            type filter hook forward priority filter; policy drop;
            iifname "br0" accept
        	}
        }
      '';

      nat = {
        enable = true;
        internalIPs = [
          "172.0.0.0/24"
        ];
        externalInterface = "eno1";
      };

    };
    systemd.network.networks."40-br0" = {
      matchConfig.Name = "br0"; # floating
      address = [
        cfg.bridgeAddr
      ];
      routes = [
        {
          Destination = "172.0.0.0/24";
          Scope = "link";
        }
      ];
    };
    # systemd.network.networks."10-lan" = {
    #   matchConfig.Name = [
    #     "eno1"
    #   ];
    #   networkConfig = {
    #     Bridge = "br0";
    #   };
    # };

    # systemd.network.netdevs."br0" = {
    #   netdevConfig = {
    #     Name = "br0";
    #     Kind = "bridge";
    #     MACAddress = config.systemd.network.links."10-eno1".matchConfig.MACAddress;
    #   };
    # };

    # systemd.network.networks."10-lan-bridge" = {
    #   matchConfig.Name = "br0";
    #   networkConfig = {
    #     Address = [
    #       cfg.bridgeAddr
    #     ];
    #     Gateway = "192.168.0.1";
    #     DNS = [ "192.168.0.1" ];
    #     IPv6AcceptRA = true;
    #   };
    #   linkConfig.RequiredForOnline = "routable";
    # };

    # networking.nftables.ruleset = ''
    #   table inet filter {
    #   	chain forward {
    #       type filter hook forward priority filter; policy drop;
    #    		oifname "br0" accept
    #   	  iifname "br0" accept
    #   	}
    #   }
    # '';
  };
}

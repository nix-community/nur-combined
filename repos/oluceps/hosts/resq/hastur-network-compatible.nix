{ lib, config, ... }:
{
  services.resolved.enable = lib.mkForce true;
  # services.resolved.enable = true;
  services.resolved.extraConfig = "DNS=192.168.1.1";
  networking = {
    resolvconf.useLocalResolver = true;
    hostName = "resq"; # Define your hostname.
    domain = "nyaw.xyz";
    wireless.enable = lib.mkForce false;
    # replicates the default behaviour.
    enableIPv6 = true;
    interfaces.eth0.wakeOnLan.enable = true;
    wireless.iwd.enable = true;
    useNetworkd = true;
    useDHCP = false;
    firewall = {
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "wg*"
        "podman*"
        "dae0"
      ];
      allowedUDPPorts = [
        8080
        5173
        51820
        9918
        8013
      ];
      allowedTCPPorts = [
        8080
        9900
        2222
        5173
        1900
      ];
    };
    nftables.enable = true;
    networkmanager.enable = lib.mkForce false;
  };
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [ "wlan0" ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "3c:7c:3f:22:49:80";
      linkConfig.Name = "eth0";
    };

    links."30-rndis" = {
      matchConfig.Driver = "rndis_host";
      linkConfig = {
        NamePolicy = "keep";
        Name = "rndis";
        MACAddressPolicy = "persistent";
      };
    };
    links."40-wlan0" = {
      matchConfig.MACAddress = "70:66:55:e7:1c:b1";
      linkConfig.Name = "wlan0";
    };

    netdevs = {
      bond0 = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
          # MTUBytes = "1300";
        };
        bondConfig = {
          Mode = "active-backup";
          PrimaryReselectPolicy = "always";
          MIIMonitorSec = "1s";
        };
      };

      wg0 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = lib.readToStore /run/agenix/wg;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
              AllowedIPs = [ "10.0.1.1/32" ];
              Endpoint = "127.0.0.1:41820";
              PersistentKeepalive = 15;
            };
          }

          {
            wireguardPeerConfig = {
              PublicKey = "ANd++mjV7kYu/eKOEz17mf65bg8BeJ/ozBmuZxRT3w0=";
              AllowedIPs = [
                "10.0.1.9/32"
                "10.0.0.0/24"
              ];
              Endpoint = "127.0.0.1:41821";
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };

    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        # IP addresses the client interface will have
        address = [ "10.0.1.2/24" ];
        DHCP = "no";
      };

      "20-wired-bond0" = {
        matchConfig.Name = "eth0";

        networkConfig = {
          Bond = "bond0";
          PrimarySlave = true;
        };
      };

      "40-wireless-bond1" = {
        matchConfig.Name = "wlan0";
        networkConfig = {
          Bond = "bond1";
        };
      };

      "5-bond0" = {
        matchConfig.Name = "bond0";
        DHCP = "yes";
        dhcpV4Config.RouteMetric = 2046;
        dhcpV6Config.RouteMetric = 2046;
        # address = [ "192.168.0.2/24" ];

        networkConfig = {
          BindCarrier = [
            "eth0"
            "wlan0"
          ];
        };

        linkConfig.MACAddress = "fc:62:ba:3a:e1:5f";
      };

      "30-rndis" = {
        matchConfig.Name = "rndis";
        DHCP = "yes";
        dhcpV4Config.RouteMetric = 2044;
        dhcpV6Config.RouteMetric = 2044;
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        networkConfig = {
          DNSSEC = true;
        };
      };
    };
  };
}

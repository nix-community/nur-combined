{ lib, config, ... }:
{
  networking = {
    resolvconf.useLocalResolver = true;
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "wg0"
        "wg1"
      ];
      allowedUDPPorts = [
        80
        443
        8080
        5173
        23180
        4444
        51820
        1935
        1985
        10080
        8000
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        5173
        8448
        1935
        1985
        10080
        8000
        9000
        9001
      ];
    };
    hostId = "0bc55a2e";
    useNetworkd = true;
    useDHCP = false;

    hostName = "eihort";
    enableIPv6 = true;
    nftables = {
      enable = true;
      # for hysteria port hopping
    };
    networkmanager.enable = lib.mkForce false;
    networkmanager.dns = "none";
  };
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [
        "wg0"
        "wg1"
      ];
    };

    links."eth0" = {
      matchConfig.MACAddress = "40:16:7e:33:cf:fd";
      linkConfig = {
        Name = "eth0";
        WakeOnLan = "magic";
      };
    };

    links."eth1" = {
      matchConfig.MACAddress = "40:16:7e:33:cf:fe";
      linkConfig = {
        Name = "eth1";
        WakeOnLan = "magic";
      };
    };

    netdevs = {

      # bond0 = {
      #   netdevConfig = {
      #     Kind = "bond";
      #     Name = "bond0";
      #     # MTUBytes = "1300";
      #   };
      #   bondConfig = {
      #     Mode = "balance-alb";
      #     PrimaryReselectPolicy = "always";
      #     MIIMonitorSec = "1s";
      #   };
      # };

      wg0 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wge.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "ANd++mjV7kYu/eKOEz17mf65bg8BeJ/ozBmuZxRT3w0=";
              AllowedIPs = [ "10.0.1.9/32" ];
              Endpoint = "127.0.0.1:41821";
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };

    networks = {

      # "5-bond0" = {
      #   matchConfig.Name = "bond0";
      #   DHCP = "yes";
      #   dhcpV4Config.RouteMetric = 2046;
      #   dhcpV6Config.RouteMetric = 2046;
      #   # address = [ "192.168.0.2/24" ];

      #   networkConfig = {
      #     BindCarrier = [ "eth0" "eth1" ];
      #   };

      #   linkConfig.MACAddress = "0c:b8:ec:ff:ec:d3";
      # };
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [ "10.0.1.6/24" ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPForward = true;
        };
      };

      # "20-wired-eth0" = {
      #   matchConfig.Name = "eth0";

      #   networkConfig = {
      #     Bond = "bond0";
      #     PrimarySlave = true;
      #   };
      # };

      "5-eth0" = {
        matchConfig.Name = "eth0";
        DHCP = "yes";
        dhcpV4Config.RouteMetric = 2046;
        dhcpV6Config.RouteMetric = 2046;
      };

      # "30-wired-eth1" = {
      #   matchConfig.Name = "eth1";

      #   networkConfig = {
      #     Bond = "bond1";
      #     PrimarySlave = true;
      #   };
      # };
    };
  };
}

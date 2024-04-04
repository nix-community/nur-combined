{ config, lib, ... }:
{
  networking.domain = "ap-northeast-1.compute.internal";
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
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        5173
        8448
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "yidhra";
    enableIPv6 = true;

    nftables.enable = true;
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

    links."10-ens5" = {
      matchConfig.MACAddress = "06:2f:f4:98:b8:13";
      linkConfig.Name = "ens5";
    };

    netdevs = {

      wg1 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg1";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wgy.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "BCbrvvMIoHATydMkZtF8c+CHlCpKUy1NW+aP0GnYfRM=";
              AllowedIPs = [ "10.0.1.2/32" ];
              PersistentKeepalive = 15;
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
              AllowedIPs = [ "10.0.1.3/32" ];
              PersistentKeepalive = 15;
            };
          }

          {
            wireguardPeerConfig = {
              PublicKey = "ANd++mjV7kYu/eKOEz17mf65bg8BeJ/ozBmuZxRT3w0=";
              AllowedIPs = [
                "10.0.0.0/24"
                "10.0.1.0/24"
              ];
              Endpoint = "111.229.162.99:51820";
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };

    networks = {
      "10-wg1" = {
        matchConfig.Name = "wg1";
        address = [
          "10.0.1.1/24"
          "10.0.0.5/24"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPForward = true;
        };
      };

      "20-wired" = {
        matchConfig.Name = "ens5";
        DHCP = "yes";
        dhcpV4Config.RouteMetric = 2046;
        dhcpV6Config.RouteMetric = 2046;
        networkConfig = {
          # Bond = "bond1";
          # PrimarySlave = true;
          DNSSEC = true;
          MulticastDNS = true;
          DNSOverTLS = true;
        };
        # # REALLY IMPORTANT
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
      };
    };
  };
}

{ config, lib, ... }:
{
  services.resolved = {
    llmnr = "false";
    dnssec = "false";
    extraConfig = ''
      MulticastDNS=off
    '';
    fallbackDns = [ "8.8.8.8#dns.google" ];
    # dnsovertls = "true";
  };
  networking = {
    hosts = {
      "10.0.1.2" = [ "s3.nyaw.xyz" ];
      "10.0.2.2" = [ "attic.nyaw.xyz" ];
      "10.0.1.1" = [ "nodens.nyaw.xyz" ];
    };
    nameservers = [
      "223.5.5.5#dns.alidns.com"
      "120.53.53.53#dot.pub"
    ];
    # resolvconf.useLocalResolver = lib.mkForce true;
    resolvconf.enable = false;
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "wg0"
        "wg1"
        "podman*"
      ];
      allowedUDPPorts = [
        8080
        5173
        3330
        8880
      ];
      allowedTCPPorts = [
        8080
        9900
        2222
        5173
        3330
        8880
      ];
    };

    wireless.iwd.enable = true;
    useNetworkd = true;
    useDHCP = false;

    hostName = "kaambl"; # Define your hostname.
    domain = "nyaw.xyz";
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
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
        "wlan"
        "wg*"
      ];
    };

    links."30-rndis" = {
      matchConfig.Driver = "rndis_host";
      linkConfig = {
        NamePolicy = "keep";
        Name = "rndis";
        MACAddressPolicy = "persistent";
      };
    };
    links."40-wlan" = {
      matchConfig.Driver = "ath11k_pci";
      linkConfig.Name = "wlan0";
    };

    netdevs = {

      wg0 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wgk.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
              AllowedIPs = [ "10.0.1.0/24" ];
              Endpoint = "127.0.0.1:41820";
              PersistentKeepalive = 15;
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "49xNnrpNKHAvYCDikO3XhiK94sUaSQ4leoCnTOQjWno=";
              AllowedIPs = [ "10.0.2.0/24" ];
              Endpoint = "116.196.112.43:51820";
              PersistentKeepalive = 15;
            };
          }
          # {
          #   wireguardPeerConfig = {
          #     PublicKey = "ANd++mjV7kYu/eKOEz17mf65bg8BeJ/ozBmuZxRT3w0=";
          #     AllowedIPs = [ "10.0.1.9/32" "10.0.1.0/24" ];
          #     Endpoint = "127.0.0.1:41821";
          #     PersistentKeepalive = 15;
          #   };
          # }
        ];
      };
    };

    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "10.0.1.3/24"
          "10.0.2.3/24"
        ];
        DHCP = "no";
        routes = [
          {
            routeConfig = {
              Destination = "192.168.1.0/24";
              Gateway = "10.0.2.3";
              Scope = "link";
            };
          }
        ];
      };

      "20-wireless" = {
        matchConfig.Name = "wlan0";
        DHCP = "yes";
        dhcpV4Config.RouteMetric = 2040;
        dhcpV6Config.RouteMetric = 2046;
        networkConfig = {
          DNSSEC = true;
          MulticastDNS = true;
          DNSOverTLS = true;
        };
        # # REALLY IMPORTANT
        dhcpV4Config.UseDNS = true;
        dhcpV6Config.UseDNS = true;
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

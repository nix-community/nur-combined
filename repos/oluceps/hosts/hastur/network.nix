{ lib, config, ... }:
{
  services.resolved = {
    enable = lib.mkForce false;
    llmnr = "false";
    dnssec = "false";
    extraConfig = ''
      MulticastDNS=off
    '';
    fallbackDns = [ "8.8.8.8#dns.google" ];
    # dnsovertls = "true";
  };
  networking = {
    timeServers = [
      "ntp.sjtu.edu.cn"
      "ntp1.aliyun.com"
      "ntp.ntsc.ac.cn"
      "cn.ntp.org.cn"
    ];
    usePredictableInterfaceNames = false;
    resolvconf.useLocalResolver = true;
    nameservers = [
      "223.5.5.5#dns.alidns.com"
      "120.53.53.53#dot.pub"
    ];
    # useHostResolvConf = true;
    hosts = lib.data.hosts.${config.networking.hostName};

    hostName = "hastur"; # Define your hostname.
    domain = "nyaw.xyz";
    # replicates the default behaviour.
    enableIPv6 = true;
    # WARNING: THIS FAILED MY DHCP
    # interfaces.eth0.wakeOnLan.enable = true;
    wireless.iwd.enable = true;
    useNetworkd = true;
    useDHCP = false;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [
        "virbr0"
        "wg0"
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
        22
        8080
        9900
        2222
        5173
        1900
      ];
      allowedTCPPortRanges = [
        {
          from = 10000;
          to = 10010;
        }
      ];
    };
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
        "wlan0"
        "wg0"
      ];
    };

    # links."10-eth0" = {
    #   matchConfig.MACAddress = "3c:7c:3f:22:49:80";
    #   linkConfig.Name = "eth0";
    # };

    links."30-rndis" = {
      matchConfig.Driver = "rndis_host";
      linkConfig = {
        NamePolicy = "keep";
        Name = "rndis";
        MACAddressPolicy = "persistent";
      };
    };
    links."20-ncm" = {
      matchConfig.Driver = "cdc_ncm";
      linkConfig = {
        NamePolicy = "keep";
        Name = "ncm";
        MACAddressPolicy = "persistent";
      };
    };
    # links."40-wlan0" = {
    #   matchConfig.MACAddress = "70:66:55:e7:1c:b1";
    #   linkConfig.Name = "wlan0";
    # };

    netdevs = {
      # bond0 = {
      #   netdevConfig = {
      #     Kind = "bond";
      #     Name = "bond0";
      #     # MTUBytes = "1300";
      #   };
      #   bondConfig = {
      #     Mode = "active-backup";
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
          PrivateKeyFile = config.age.secrets.wg.path;
        };
        wireguardPeers = [
          {
            PublicKey = "49xNnrpNKHAvYCDikO3XhiK94sUaSQ4leoCnTOQjWno=";
            AllowedIPs = [ "10.0.2.0/24" ];
            Endpoint = "116.196.112.43:51820";
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
            AllowedIPs = [ "10.0.1.0/24" ];
            Endpoint = "127.0.0.1:41820";
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "jQGcU+BULglJ9pUz/MmgOWhGRjpimogvEudwc8hMR0A=";
            AllowedIPs = [ "10.0.3.0/24" ];
            Endpoint = "127.0.0.1:41821";
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "V3J9d8lUOk4WXj+dIiAZsuKJv3HxUl8J4HvX/s4eElY=";
            AllowedIPs = [ "10.0.4.0/24" ];
            Endpoint = "127.0.0.1:41822";
            PersistentKeepalive = 15;
          }
        ];
      };
    };

    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        # IP addresses the client interface will have
        address = [
          "10.0.1.2/24"
          "10.0.2.2/24"
          "10.0.3.2/24"
          "10.0.4.2/24"
        ];
        DHCP = "no";
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv4Forwarding = true;
        };
      };

      # "20-wired-bond0" = {
      #   matchConfig.Name = "eth0";

      #   networkConfig = {
      #     Bond = "bond0";
      #     PrimarySlave = true;
      #   };
      # };

      # "40-wireless-bond1" = {
      #   matchConfig.Name = "wlan0";
      #   networkConfig = {
      #     Bond = "bond1";
      #   };
      # };

      "8-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
        # dhcpV4Config.RouteMetric = 2046;
        # dhcpV6Config.RouteMetric = 2046;
        # address = [ "192.168.1.2/24" ];
        # routes = [
        #   # create default routes for both IPv6 and IPv4
        #   { routeConfig.Gateway = "192.168.1.1"; }
        #   { routeConfig.Gateway = "fe80::5e02:14ff:fea5:ad05"; }
        # ];
      };

      "25-ncm" = {
        matchConfig.Name = "ncm";
        DHCP = "yes";
        dhcpV4Config.RouteMetric = 2044;
        dhcpV6Config.RouteMetric = 2044;
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        networkConfig = {
          DNSSEC = true;
        };
      };

      "30-rndis" = {
        matchConfig.Name = "rndis";
        DHCP = "yes";
        dhcpV4Config.RouteMetric = 2044;
        dhcpV6Config.RouteMetric = 2044;
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        networkConfig = {
          DNSSEC = false;
        };
      };
    };
  };
}

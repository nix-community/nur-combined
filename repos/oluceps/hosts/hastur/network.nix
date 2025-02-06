{ lib, config, ... }:
{
  services.babeld = {
    enable = true;
    config = ''
      skip-kernel-setup true
      local-path /var/run/babeld/ro.sock
      router-id 3c:7c:3f:22:49:80

      interface wg-yidhra type tunnel rtt-min 55 rtt-max 256
      interface wg-abhoth type tunnel rtt-min 160 rtt-max 256
      interface wg-azasos type tunnel rtt-min 50 rtt-max 256
      interface wg-kaambl type tunnel rtt-min 5 rtt-max 256 rtt-decay 120
      interface wg-eihort type tunnel rtt-min 0.5 rtt-max 256 rtt-decay 32

      redistribute ip fdcc::/64 ge 64 le 128 local allow
      redistribute proto 42
      redistribute local deny
    '';
  };
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
        "podman*"
        "dae0"
      ] ++ map (n: "wg-${n}") (builtins.attrNames (lib.conn { }));
      allowedUDPPorts = [
        8080
      ];
      allowedTCPPorts = [
        8080
      ];
    };
    nftables = {
      enable = true;
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
        "wlan0"
        "wg0"
      ];
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
    links."20-ncm" = {
      matchConfig.Driver = "cdc_ncm";
      linkConfig = {
        NamePolicy = "keep";
        Name = "ncm";
        MACAddressPolicy = "persistent";
      };
    };

    # # abhoth
    # netdevs.wg0 = {
    #   netdevConfig = {
    #     Kind = "wireguard";
    #     Name = "wg0";
    #     MTUBytes = "1300";
    #   };
    #   wireguardConfig = {
    #     PrivateKeyFile = config.vaultix.secrets.wg.path;
    #     RouteTable = false;
    #   };
    #   wireguardPeers = [
    #     {
    #       # abhoth
    #       PublicKey = "jQGcU+BULglJ9pUz/MmgOWhGRjpimogvEudwc8hMR0A=";
    #       AllowedIPs = [
    #         "::/0"
    #         "0.0.0.0/0"
    #       ];
    #       Endpoint = "127.0.0.1:41821";
    #       PersistentKeepalive = 15;
    #       RouteTable = false;
    #     }
    #   ];
    # };

    # networks."10-wg0" = {
    #   matchConfig.Name = "wg0";
    #   addresses = [
    #     {
    #       Address = "fdcc::1/128";
    #       Peer = "fdcc::2/128";
    #     }
    #     {
    #       Address = "fe80::216:3eff:fe0f:37d8/64";
    #       Peer = "fe80::216:3eff:fe15:ec52/64";
    #       Scope = "link";
    #     }
    #   ];
    #   networkConfig = {
    #     DHCP = false;
    #   };
    # };

    # # azasos
    # netdevs.wg2 = {
    #   netdevConfig = {
    #     Kind = "wireguard";
    #     Name = "wg2";
    #     MTUBytes = "1300";
    #   };
    #   wireguardConfig = {
    #     PrivateKeyFile = config.vaultix.secrets.wg.path;
    #     RouteTable = false;
    #   };
    #   wireguardPeers = [
    #     {
    #       # abhoth
    #       PublicKey = "49xNnrpNKHAvYCDikO3XhiK94sUaSQ4leoCnTOQjWno=";
    #       AllowedIPs = [
    #         "::/0"
    #         "0.0.0.0/0"
    #       ];
    #       Endpoint = "116.196.112.43:51820";
    #       PersistentKeepalive = 15;
    #       RouteTable = false;
    #     }
    #   ];
    # };

    # networks."10-wg2" = {
    #   matchConfig.Name = "wg2";
    #   addresses = [
    #     {
    #       Address = "fdcc::1/128";
    #       Peer = "fdcc::3/128";
    #     }
    #     {
    #       Address = "fe80::216:3eff:fe0f:37d8/64";
    #       Peer = "fe80::216:3eff:fe7b:d228/64";
    #       Scope = "link";
    #     }
    #   ];
    #   networkConfig = {
    #     DHCP = false;
    #   };
    # };

    networks."8-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "no";
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv6AcceptRA = "yes";
      };
      linkConfig.RequiredForOnline = "routable";
      address = [ "192.168.1.2/24" ];
      routes = [
        { Gateway = "192.168.1.1"; }
      ];
    };

    networks."25-ncm" = {
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

    networks."30-rndis" = {
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
}

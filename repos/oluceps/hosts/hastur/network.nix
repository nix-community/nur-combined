{ lib, config, ... }:
{
  imports = [ ./bird.nix ];
  services = {
    resolved = {
      llmnr = "true";
      dnssec = "false";
      extraConfig = ''
        Cache=no
      '';
    };
  };
  networking = {
    timeServers = [
      "ntp1.aliyun.com"
      "240e:982:13a3:f700:70c6:e4fd:a208:19d3"
      "edu.ntp.org.cn"
      "2001:250:380a:5::10"
    ];
    usePredictableInterfaceNames = true;
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
        "tun-sing"
        "dae0"
      ];
      allowedUDPPorts = [
        8080
        5353
      ];
      allowedTCPPorts = [
        8080
      ];
    };
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
        	chain forward {
            type filter hook forward priority filter; policy drop;
            iifname "eno1" oifname "vm1" ip6 saddr fdcc::3 accept
        	}
        }
      '';
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
    # netdevs.bond0 = {
    #   netdevConfig = {
    #     Kind = "bond";
    #     Name = "bond0";
    #   };
    #   bondConfig = {
    #     Mode = "active-backup";
    #     PrimaryReselectPolicy = "always";
    #     MIIMonitorSec = "1s";
    #   };
    # };
    links = {
      "10-eno1" = {
        matchConfig.MACAddress = "3c:7c:3f:22:49:80";
        linkConfig.Name = "eno1";
      };

      "40-wlan0" = {
        matchConfig.MACAddress = "70:66:55:e7:1c:b1";
        linkConfig.Name = "wlan0";
      };
      "30-rndis" = {
        matchConfig.Driver = "rndis_host";
        linkConfig = {
          NamePolicy = "keep";
          Name = "rndis";
          MACAddressPolicy = "persistent";
        };
      };
      "20-ncm" = {
        matchConfig.Driver = "cdc_ncm";
        linkConfig = {
          NamePolicy = "keep";
          Name = "ncm";
          MACAddressPolicy = "persistent";
        };
      };
    };
    networks = {
      # "20-wired" = {
      #   matchConfig.Name = "eno1";
      #   networkConfig = {
      #     Bond = "bond0";
      #     PrimarySlave = true;
      #   };
      # };

      # "40-wireless" = {
      #   matchConfig.Name = "wlan0";
      #   networkConfig = {
      #     Bond = "bond0";
      #   };
      # };

      "8-eno1" = {
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

        linkConfig.RequiredForOnline = "routable";
        address = [ "192.168.1.2/24" ];
        dns = [ "192.168.1.1" ];
        routes = [
          { Gateway = "192.168.1.1"; }
        ];
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

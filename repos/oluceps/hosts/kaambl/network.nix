{ config, lib, ... }:
{
  services.babeld = {
    enable = true;
    config = ''
      skip-kernel-setup true
      local-path /var/run/babeld/ro.sock
      router-id 38:d5:7a:e2:19:7d

      interface wg-yidhra type tunnel rtt-min 60 rtt-max 256
      interface wg-abhoth type tunnel rtt-min 210 rtt-max 256 rtt-decay 90
      interface wg-azasos type tunnel rtt-min 55 rtt-max 256
      interface wg-hastur type tunnel rtt-min 10 rtt-max 256 rtt-decay 90
      interface wg-eihort type tunnel rtt-min 5 rtt-max 256 rtt-decay 90

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
    # dnsovertls = "opportunistic";
  };
  networking = {
    timeServers = [
      "ntp.sjtu.edu.cn"
      "ntp1.aliyun.com"
      "ntp.ntsc.ac.cn"
      "cn.ntp.org.cn"
    ];
    usePredictableInterfaceNames = false;
    hosts = lib.data.hosts.${config.networking.hostName};
    nameservers = [
      "223.5.5.5#dns.alidns.com"
      #   # "120.53.53.53#dot.pub"
    ];
    # resolvconf.useLocalResolver = lib.mkForce true;
    resolvconf.enable = false;
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "podman*"
      ] ++ map (n: "wg-${n}") (builtins.attrNames (lib.conn { }));
      allowedUDPPorts = [
        8080
      ];
      allowedTCPPorts = [
        8080
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
      enable = false;
      anyInterface = true;
      ignoredInterfaces = [
        "wlan0"
        "wg0"
      ];
    };
    links = {

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
      "40-wlan" = {
        matchConfig.Driver = "ath11k_pci";
        linkConfig.Name = "wlan0";
      };
    };

    networks = {

      "20-wireless" = {
        matchConfig.Name = "wlan0";
        networkConfig = {
          DHCP = "yes";
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          IPv6AcceptRA = true;
        };
        dhcpV4Config.RouteMetric = 2040;
        dhcpV6Config.RouteMetric = 2046;
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
    };
  };
}

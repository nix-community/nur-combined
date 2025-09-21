{ config, lib, ... }:
{
  imports = [ ./bird.nix ];
  services = {

    resolved = {
      llmnr = "true";
      dnssec = "false";
      fallbackDns = [ "8.8.8.8#dns.google" ];
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
    nameservers = [
      "120.53.53.53#dot.pub"
      "119.29.29.29"
    ];
    # resolvconf.useLocalResolver = lib.mkForce true;
    # resolvconf.enable = false;
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "podman*"
        "tun-sing"
      ];
      allowedUDPPorts = [
        8080
        5353
      ];
      allowedTCPPorts = [
        8080
      ];
    };

    wireless.iwd.enable = true;
    useNetworkd = true;

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
        linkConfig = {
          Name = "wlan0";
          WakeOnLan = "magic";
        };
      };
    };

    networks = {

      "20-wireless" = {
        matchConfig.Name = "wlan0";
        networkConfig = {
          DHCP = "ipv4";
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          IPv6AcceptRA = true;
          MulticastDNS = true;
        };
        ipv6AcceptRAConfig = {
          DHCPv6Client = false;
          # UseDNS = false;
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

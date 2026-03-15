{ lib, config, ... }:
{
  imports = [ ./bird.nix ];

  services.resolved.settings.Resolve = {
    LLMNR = "true";
    DNSSEC = "false";
    FallbackDNS = [ "8.8.8.8#dns.google" ];
    Cache = "no";
  };

  # services.resolved.enable = false;
  networking = {
    # resolvconf.useLocalResolver = true;
    hosts = lib.data.hosts.${config.networking.hostName};
    usePredictableInterfaceNames = true;
    timeServers = [
      "ntp1.aliyun.com"
      "240e:982:13a3:f700:70c6:e4fd:a208:19d3"
      "edu.ntp.org.cn"
      "2001:250:380a:5::10"
    ];
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "podman*"
      ];
      allowedUDPPorts = [
        80
        443
        5353 # mdns
      ];
      allowedTCPPorts = [
        80
        443
        3260
        21027 # syncthing
      ];
    };
    hostId = "0bc55a2e";
    useNetworkd = true;
    useDHCP = false;

    hostName = "eihort";
    domain = "nyaw.xyz";
    enableIPv6 = true;
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
        	chain forward {
            type filter hook forward priority filter; policy drop;
            iifname "eno1" oifname "vm1" accept
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
        "wg*"
      ];
    };

    links."10-eno1" = {
      matchConfig.MACAddress = "ac:1f:6b:e5:fe:3a";
      linkConfig = {
        Name = "eno1";
        WakeOnLan = "magic";
      };
    };

    links."20-eno2" = {
      matchConfig.MACAddress = "ac:1f:6b:e5:fe:3b";
      linkConfig = {
        Name = "eno2";
        WakeOnLan = "magic";
      };
    };

    networks = {
      "5-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig = {
          DHCP = "ipv4";
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          IPv6AcceptRA = true;
          MulticastDNS = true;
        };
        ipv6AcceptRAConfig = {
          DHCPv6Client = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}

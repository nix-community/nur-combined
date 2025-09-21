{ lib, config, ... }:
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
    # resolvconf.useLocalResolver = true;
    hosts = lib.data.hosts.${config.networking.hostName};
    usePredictableInterfaceNames = false;
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
        "podman0"
      ];
      allowedUDPPorts = [
        80
        443
        8080
        5353 # mdns
      ];
      allowedTCPPorts = [
        80
        443
        8080
        3260
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

    links."eno1" = {
      matchConfig.MACAddress = "ac:1f:6b:e5:fe:3a";
      linkConfig = {
        Name = "eno1";
        WakeOnLan = "magic";
      };
    };

    links."eno2" = {
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
        address = [ "192.168.1.110/24" ];
        routes = [
          { Gateway = "192.168.1.1"; }
        ];
      };
    };
  };
}

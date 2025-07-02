{ lib, config, ... }:
{
  imports = [ ./bird.nix ];
  services = {
    resolved = {
      llmnr = "true";
      dnssec = "false";
      fallbackDns = [ "8.8.8.8#dns.google" ];
    };
  };
  networking = {
    # resolvconf.useLocalResolver = true;
    hosts = lib.data.hosts.${config.networking.hostName};
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

    links."eth0" = {
      matchConfig.MACAddress = "ac:1f:6b:e5:fe:3a";
      linkConfig = {
        Name = "eth0";
        WakeOnLan = "magic";
      };
    };

    links."eth1" = {
      matchConfig.MACAddress = "ac:1f:6b:e5:fe:3b";
      linkConfig = {
        Name = "eth1";
        WakeOnLan = "magic";
      };
    };

    networks = {
      "5-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "no";
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          IPv6AcceptRA = "yes";
          MulticastDNS = true;
        };
        ipv6AcceptRAConfig = {
          DHCPv6Client = false;
          # UseDNS = false;
        };
        # dhcpV4Config.UseDNS = false;
        # dhcpV6Config.UseDNS = false;
        linkConfig.RequiredForOnline = "routable";
        address = [ "192.168.1.16/24" ];
        routes = [
          { Gateway = "192.168.1.1"; }
        ];
      };
    };
  };
}

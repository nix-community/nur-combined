{ config, lib, ... }:
{
  imports = [ ./bird.nix ];
  services = {
    resolved = {
      dnssec = "false";
      llmnr = "false";
      settings.MulticastDNS = "off";
    };
  };
  networking = {
    domain = "nyaw.xyz";
    # resolvconf.useLocalResolver = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [
        "virbr0"
      ];
      allowedUDPPorts = [
        80
        443
      ];
      allowedTCPPorts = [
        80
        443
        40119 # stls
        8776 # forward
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "nodens";
    enableIPv6 = true;

    nftables = {
      enable = true;
      # for hysteria port hopping
      # table ip6 nat {
      #   chain postrouting {
      #     type nat hook postrouting priority srcnat; policy accept;
      #     iifname { hts-yidhra, hts-kaambl } oifname eth0 ip6 saddr fdcc::/16 snat to 2400:8905::f03c:95ff:fe50:a173
      #   }
      # }
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
        "wg0"
      ];
    };
    links."10-eth0" = {
      matchConfig.MACAddress = "52:5a:26:c1:cd:bf";
      linkConfig.Name = "eth0";
    };

    networks."8-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "no";
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv6AcceptRA = true;
      };

      address = [
        "136.175.179.183/24"
      ];

      routes = [
        {
          Gateway = "193.41.250.250";
          GatewayOnLink = true;
        }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}

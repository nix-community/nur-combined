{ ... }:
{

  systemd.network = {
    enable = true;

    links."10-eth0" = {
      matchConfig.MACAddress = "bc:24:11:48:1c:f5";
      linkConfig.Name = "eth0";
    };

    networks."8-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "no";
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv6AcceptRA = true;
        MulticastDNS = true;
      };
      ipv6AcceptRAConfig = {
        DHCPv6Client = false;
        # UseDNS = false;
      };

      address = [
        "45.95.212.89/24"
        "2405:84c0:8011:3200::/48"
      ];
      linkConfig.RequiredForOnline = "routable";
      routes = [
        { Gateway = "45.95.212.1"; }
        {
          Gateway = "2405:84c0:8011::";
          GatewayOnLink = true;
        }
      ];
    };
  };
}

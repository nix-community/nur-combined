{ ... }:
{

  systemd.network = {
    enable = true;

    links."10-eth0" = {
      matchConfig.MACAddress = "fa:51:33:18:0a:00";
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
        "205.198.76.6/24"
        "2404:c140:2000:2::32:1d9f/64/48"
      ];
      linkConfig.RequiredForOnline = "routable";
      routes = [
        { Gateway = "205.198.76.1"; }
        {
          Gateway = "2404:c140:2000:2::1";
          GatewayOnLink = true;
        }
      ];
    };
  };
}

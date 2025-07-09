{ ... }:
{

  systemd.network = {
    enable = true;

    links."10-eth0" = {
      matchConfig.MACAddress = "00:db:bc:92:a8:5c";
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

      linkConfig.RequiredForOnline = "routable";
      address = [ "103.213.4.159/24" ];
      routes = [
        { Gateway = "103.213.4.1"; }
      ];
    };
  };
}

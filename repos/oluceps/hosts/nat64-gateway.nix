{ ... }:
{
  networking.jool = {
    enable = true;

    nat64 = {
      default = {
        global = {
          # standard rfc 6052 nat64 prefix
          pool6 = "64:ff9b::/96";
        };
        pool4 = [
          # explicitly define the pool for tcp, udp, and icmp traffic
          {
            protocol = "TCP";
            prefix = "192.168.255.0/24";
          }
          {
            protocol = "UDP";
            prefix = "192.168.255.0/24";
          }
          {
            protocol = "ICMP";
            prefix = "192.168.255.0/24";
          }
        ];
      };
    };
  };

  # idiomatic nixos way to set up snat masquerade for the translated ipv4 pool.
  # replace 'eth0' with your physical network interface connecting to your tp-link.
  networking.nat = {
    enable = true;
    externalInterface = "eno1";
    internalIPs = [ "192.168.255.0/24" ];
  };

  # dnsmasq configuration for dhcpv4 option 108, ipv6 ra, and dns discovery
  services.dnsmasq = {
    enable = true;
    settings = {
      # replace with your actual interface name
      interface = "eno1";

      # explicitly ignore the loopback interface to ensure no collision with 127.x.x.x
      except-interface = "lo";

      # strictly bind to the specific ip of the interface using linux netlink, avoiding the 0.0.0.0 wildcard
      bind-dynamic = true;

      # upstream dns servers for normal queries
      server = [
        "223.5.5.5"
        "2400:3200::1"
      ];

      # dhcp-range accepts a list to define both ipv4 and ipv6 behaviors simultaneously
      dhcp-range = [
        # dynamic ipv4 pool for legacy devices within your 192.168.0.x network
        "192.168.0.100,192.168.0.200,255.255.255.0,12h"
        # ipv6 ra stateless config
        "::,constructor:eno1,ra-stateless,ra-names,12h"
      ];

      dhcp-option = [
        # gateway for legacy devices (your tp-link ip)
        "option:router,192.168.0.1"
        # dns server (points to this nas so dnsmasq can answer ipv4only.arpa)
        "option:dns-server,192.168.0.3"
        # the magic rfc 8925 option 108 (timeout 1800s) instructing modern devices to drop ipv4
        "108,1800"
      ];

      enable-ra = true;

      # rfc 7050 dns64 prefix discovery.
      # modern clat clients query this to learn the "64:ff9b::" prefix.
      # host-record = "ipv4only.arpa,64:ff9b::c000:00aa,64:ff9b::c000:00ab";
      address = [
        "/ipv4only.arpa/64:ff9b::c000:aa"
        "/ipv4only.arpa/64:ff9b::c000:ab"
      ];
    };
  };
}

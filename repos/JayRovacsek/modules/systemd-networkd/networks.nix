{ config, ... }:
let phys0Exists = builtins.hasAttr "10-phys0" config.systemd.network.links;
in {
  # Use blocky over resolved so we can leverage dns filter lists
  # and local host definitions
  imports = [ ../blocky ];
  services.resolved.enable = false;

  systemd.network.networks = {
    "00-wired" = {
      matchConfig.Name = if phys0Exists then "phys0" else "en*";
      networkConfig = {
        DHCP = "ipv4";
        Domains = [ "lan" ];
      };

      dns = [ "127.0.0.1" ];

      # The kernel's route metric (same as configured with ip) decides which route to use for outgoing packets, in cases when several match. This will be the case when both wireless and wired devices on the system have active connections. To break the tie, the kernel uses the metric. If one of the connections is terminated, the other automatically wins without there being a gap with nothing configured (ongoing transfers may still not deal with this nicely but that is at a different OSI layer). 
      # Above as per: https://wiki.archlinux.org/title/Systemd-networkd
      # TLDR: prefer wired connections
      dhcpV4Config.RouteMetric = 10;
    };

    "10-wireless" = {
      matchConfig.Name = "wl*";
      networkConfig.DHCP = "yes";
      # The kernel's route metric (same as configured with ip) decides which route to use for outgoing packets, in cases when several match. This will be the case when both wireless and wired devices on the system have active connections. To break the tie, the kernel uses the metric. If one of the connections is terminated, the other automatically wins without there being a gap with nothing configured (ongoing transfers may still not deal with this nicely but that is at a different OSI layer). 
      # Above as per: https://wiki.archlinux.org/title/Systemd-networkd
      # TLDR: prefer wired connections
      dhcpV4Config.RouteMetric = 20;
    };
  };
}
